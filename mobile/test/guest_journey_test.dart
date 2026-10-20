import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/notifications/notifications.dart';
import 'package:mobile/core/router.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/daily/daily_repository.dart';
import 'package:mobile/features/daily/daily_run.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/game_sync.dart';
import 'package:mobile/features/games/guest_log.dart';
import 'package:mobile/features/guest/guest_tabs.dart';
import 'package:mobile/features/home/home_shell.dart';
import 'package:mobile/features/profile/profile_tab.dart';
import 'package:mobile/features/shared/widgets/kit.dart';
import 'package:mobile/features/study/study_tab.dart';

import 'support/fonts.dart';

/// A guest's progress, end to end: from a fresh install, through "Try a
/// round first", real rounds on a real game screen, the real sign-up form,
/// to the rounds sitting on the new account. Then the hard cases: more
/// rounds than the server takes in one push, no signal halfway through, and
/// a relaunch that finishes the job.
///
/// The server is a stand-in that keeps the real one's rules: account routes
/// answer 401 without a session (verifyAuth), a push takes at most 200
/// events and keeps one row per eventId (service/routes/sync.js,
/// db/syncEvents.js), and the account's games are read back from its log.
/// What the app sends at sign-up is written to
/// test/fixtures/guest-adoption-events.json, and the server's own test
/// (service/guestAdoption.test.js) pushes exactly that through the real
/// routes, so the two sides cannot drift apart.
/// See docs/adr/0026-guest-mode.md.
class _Backend extends ApiClient {
  final accounts = <String, String>{'old@school.edu': 'old-password'};

  /// email -> eventId -> the event as the server stored it.
  final log = <String, Map<String, Map<String, dynamic>>>{};
  final calls = <String>[];
  final batches = <int>[];
  final pushes = <Map<String, dynamic>>[];

  /// Fails this many pushes (from [failFrom] on) as if there were no signal.
  int failPushes = 0;
  int failFrom = 0;

  String? _session;

  @override
  void setToken(String? token) {
    _session = token;
    super.setToken(token);
  }

  static bool _isOpen(String p) =>
      p.startsWith('/content/') ||
      p.startsWith('/daily/preview') ||
      p.startsWith('/auth/');

  List<String> get accountCalls => calls.where((p) => !_isOpen(p)).toList();

  void _gate(String path) {
    calls.add(path);
    if (_session == null && !_isOpen(path)) {
      throw ApiException('Unauthorized', statusCode: 401);
    }
  }

  @override
  Future<dynamic> get(String path) async {
    _gate(path);
    if (path == '/auth/me') {
      if (_session == null) throw ApiException('no', statusCode: 401);
      return {'email': _session, 'emailVerified': true};
    }
    if (path.startsWith('/account/state')) {
      final games = <String, Map<String, dynamic>>{};
      for (final e in (log[_session] ?? const {}).values) {
        final parts = (e['itemId'] as String).split(':');
        if (e['grade'] != 'gotIt') continue;
        final g = games.putIfAbsent(parts[1], () => {'rounds': <int>[]});
        (g['rounds'] as List<int>).add(int.parse(parts[2]));
      }
      return {
        'phone': {'games': games},
      };
    }
    if (path.startsWith('/daily/preview')) {
      return {'number': 31, 'date': '2026-10-20', 'games': [], 'total': 0};
    }
    return <String, dynamic>{};
  }

  @override
  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    _gate(path);
    if (path == '/auth/create') {
      final email = body!['email'] as String;
      accounts[email] = body['password'] as String;
      return {'token': email, 'email': email};
    }
    if (path == '/auth/login') {
      final email = body!['email'] as String;
      if (accounts[email] != body['password']) {
        throw ApiException('Wrong email or password.', statusCode: 401);
      }
      return {'token': email, 'email': email};
    }
    if (path == '/sync/events') {
      final events = (body!['events'] as List).cast<Map<String, dynamic>>();
      if (events.isEmpty || events.length > 200) {
        throw ApiException('events must be an array of 1-200', statusCode: 400);
      }
      if (failPushes > 0 && batches.length >= failFrom) {
        failPushes--;
        batches.add(-events.length);
        throw ApiException('No signal', isNetwork: true);
      }
      batches.add(events.length);
      pushes.add(body);
      final mine = log.putIfAbsent(_session!, () => {});
      for (final e in events) {
        mine.putIfAbsent(e['eventId'] as String, () => e);
      }
      return {'accepted': events.length};
    }
    return <String, dynamic>{'ok': true};
  }

  @override
  Future<dynamic> put(String path, [Map<String, dynamic>? body]) async {
    _gate(path);
    return <String, dynamic>{};
  }

  @override
  Future<dynamic> delete(String path, [Map<String, dynamic>? body]) async {
    _gate(path);
    return <String, dynamic>{};
  }
}

void main() {
  setUpAll(() async {
    await loadBrandFonts();
    await loadMathFonts();
  });

  late _Backend server;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    Notifications.tapped.value = null;
    DailyRun.instance.debugReset();
    GameProgress.instance.clearAll();
    appClock = () => DateTime(2026, 10, 20, 9);
    server = _Backend();
  });
  tearDown(() => appClock = DateTime.now);

  /// The app as it launches: the real bootstrap, the real router.
  Future<(AuthController, GoRouter)> launch(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final storage = AppStorage();
    final auth = AuthController(api: server, storage: storage);
    await auth.bootstrap();
    auth.titlesShown = true;
    final router = buildRouter(auth);
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: Provider<DailyRepository>.value(
          value: DailyRepository(server),
          child: MaterialApp.router(
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            routerConfig: router,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (auth, router);
  }

  Future<void> lockIn(WidgetTester tester, String choice) async {
    await tester.tap(find.text(choice));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lock it in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
  }

  testWidgets('a guest\'s rounds become the new account\'s, through the real '
      'screens', (tester) async {
    final (auth, router) = await launch(tester);

    // A fresh install lands on the tour. Skip it, and the welcome screen
    // offers the third way in.
    expect(find.text('Skip'), findsWidgets);
    await tester.tap(find.text('Skip').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try a round first'));
    await tester.pumpAndSettle();
    expect(auth.isGuest, isTrue);
    expect(find.text('NOT SIGNED IN'), findsOneWidget);

    // Two rounds on the real game screen: one right, one wrong.
    router.push('/games/play/which-property');
    await tester.pumpAndSettle();
    await lockIn(tester, 'Specific weight, in newtons per cubic meter');
    await lockIn(tester, 'Density, in kilograms per cubic meter');
    router.pop();
    await tester.pumpAndSettle();

    expect(server.accountCalls, isEmpty, reason: 'a guest sends nothing');
    expect(await GuestLog.all(), hasLength(2));
    expect(GameProgress.instance.roundsCleared('which-property'), {0});

    // Profile counts them and offers the account.
    HomeShell.select(HomeTab.profile);
    await tester.pumpAndSettle();
    expect(find.byType(GuestProfileTab), findsOneWidget);
    expect(find.text('round'), findsOneWidget);
    expect(find.text('Your round comes with you. Have one?'), findsOneWidget);
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    // The real sign-up form, every step.
    await tester.enterText(find.byType(TextField).first, 'new@school.edu');
    await tester.tap(find.byType(RoundNextButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'a-long-password');
    await tester.tap(find.byType(RoundNextButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // The account holds exactly the two rounds, and the phone no longer
    // keeps a guest.
    final held = server.log['new@school.edu']!.values.toList();
    expect(held.map((e) => (e['itemId'], e['grade'])).toSet(), {
      ('${propertySourceOf(1)}:which-property:1', 'gotIt'),
      ('${propertySourceOf(2)}:which-property:2', 'forgot'),
    });
    expect(await GuestLog.all(), isEmpty);
    expect(auth.guest, isFalse);
    expect(await AppStorage().guestMode(), isFalse);

    // Home is the account's own now, with the round still on the map.
    router.go('/home');
    await tester.pumpAndSettle();
    expect(find.byType(ProfileTab), findsOneWidget);
    expect(find.byType(GuestProfileTab), findsNothing);
    expect(GameProgress.instance.roundsCleared('which-property'), {0});

    _checkFixture(server.pushes.single);
  });

  testWidgets('the tour\'s last page has the same way in', (tester) async {
    final (auth, _) = await launch(tester);
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try a round first'));
    await tester.pumpAndSettle();
    expect(auth.isGuest, isTrue);
    expect(find.byType(StudyTab), findsOneWidget);
  });

  testWidgets('a guest who closes the app is still a guest, with their '
      'rounds', (tester) async {
    var (auth, _) = await launch(tester);
    await auth.completeOnboarding();
    await auth.startGuest();
    await GuestLog.add([_event(1)]);
    await tester.pumpWidget(const SizedBox());

    (auth, _) = await launch(tester);
    expect(auth.isGuest, isTrue);
    expect(find.text('NOT SIGNED IN'), findsOneWidget);
    expect(await GuestLog.all(), hasLength(1));
    expect(server.accountCalls, isEmpty);
  });

  testWidgets('450 rounds, no signal halfway through, and a relaunch: every '
      'round lands once', (tester) async {
    var (auth, router) = await launch(tester);
    await auth.completeOnboarding();
    await auth.startGuest();
    await GuestLog.add([for (var i = 0; i < 450; i++) _event(i % 6 + 1)]);
    final ids = {for (final e in await GuestLog.all()) e.eventId};
    expect(ids, hasLength(450));

    // The second push of the three fails.
    server
      ..failFrom = 1
      ..failPushes = 1;
    router.push('/signin');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'old@school.edu');
    await tester.tap(find.byType(RoundNextButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'old-password');
    await tester.tap(find.byType(RoundNextButton));
    await tester.pumpAndSettle();

    expect(server.batches, [200, -200]);
    expect(server.log['old@school.edu'], hasLength(200));
    expect(await GuestLog.all(), hasLength(250), reason: 'kept for next time');
    expect(auth.guest, isTrue, reason: 'still owed to the account');
    expect(auth.isGuest, isFalse, reason: 'but signed in');

    // The next launch sends the rest.
    await tester.pumpWidget(const SizedBox());
    (auth, router) = await launch(tester);
    expect(server.batches, [200, -200, 200, 50]);
    expect(server.log['old@school.edu']!.keys.toSet(), ids);
    expect(await GuestLog.all(), isEmpty);
    expect(auth.guest, isFalse);
    expect(server.batches.every((b) => b.abs() <= GameSync.maxBatch), isTrue);
  });
}

GameEvent _event(int round) => GameEvent(
  sourceProblemId: 'fm-fp-q1',
  chapterId: 'fluid-mechanics',
  gameId: 'which-property',
  round: round,
  correct: true,
  ts: DateTime(2026, 10, 19, 21),
);

/// What the server stores for this round: the source problem it was
/// authored from.
String propertySourceOf(int round) {
  final src = File(
    'lib/features/games/which_property_game.dart',
  ).readAsStringSync();
  final sources = RegExp(
    r"source: '([a-z0-9-]+)'",
  ).allMatches(src).map((m) => m[1]!).toList();
  return sources[round - 1];
}

/// The batch the app sent at sign-up, written for the server's own test,
/// with the parts that change every run (ids and times) fixed.
void _checkFixture(Map<String, dynamic> push) {
  final events = [
    for (final (i, e) in (push['events'] as List).indexed)
      {
        ...(e as Map).cast<String, dynamic>(),
        'eventId': 'guest-adoption-$i',
        'ts': 1792500000000 + i,
        'localDate': '2026-10-20',
      },
  ];
  final body = {...push, 'events': events};
  const path = 'test/fixtures/guest-adoption-events.json';
  final file = File(path);
  final text = const JsonEncoder.withIndent('  ').convert(body);
  if (!file.existsSync() || Platform.environment['UPDATE_FIXTURES'] == '1') {
    file
      ..createSync(recursive: true)
      ..writeAsStringSync('$text\n');
  }
  expect(
    jsonDecode(file.readAsStringSync()),
    jsonDecode(text),
    reason:
        'What the app sends changed. Rerun with UPDATE_FIXTURES=1, then run '
        'service/guestAdoption.test.js against the new file.',
  );
}
