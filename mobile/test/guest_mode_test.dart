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
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/daily/daily_repository.dart';
import 'package:mobile/features/games/board.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/game_sync.dart';
import 'package:mobile/features/games/guest_log.dart';
import 'package:mobile/features/guest/guest_tabs.dart';
import 'package:mobile/features/home/home_shell.dart';
import 'package:mobile/features/study/study_tab.dart';

import 'support/fonts.dart';

/// Using the app without an account (Apple guideline 5.1.1(v), rejected
/// 2026-10-20; docs/adr/0026-guest-mode.md). The promise to the owner was that
/// a guest's progress lives on the phone and nothing about them reaches the
/// database. The stand-in server below keeps the real one's rules: the
/// study content and the Daily's preview are open, and every account route
/// answers 401 without a session (service/routes/*.js, verifyAuth).
class _Server extends ApiClient {
  final calls = <String>[];
  final posted = <String, List<Map<String, dynamic>?>>{};
  String? _session;

  static const _open = ['/content/', '/daily/preview'];
  bool _isOpen(String path) => _open.any(path.startsWith);

  @override
  void setToken(String? token) {
    _session = token;
    super.setToken(token);
  }

  void _gate(String path) {
    calls.add(path);
    if (_session == null && !_isOpen(path) && !path.startsWith('/auth/')) {
      throw ApiException('Unauthorized', statusCode: 401);
    }
  }

  @override
  Future<dynamic> get(String path) async {
    _gate(path);
    if (path.startsWith('/daily/preview')) {
      return {
        'number': 31,
        'date': '2026-10-20',
        'games': [
          {
            'gameId': 'which-property',
            'chapterId': 'fluid-mechanics',
            'rounds': 6,
          },
          {'gameId': 'z-or-s', 'chapterId': 'statics', 'rounds': 6},
          {'gameId': 'one-log', 'chapterId': 'mathematics', 'rounds': 6},
        ],
        'total': 18,
      };
    }
    if (path == '/auth/me') return {'email': 'new@school.edu'};
    if (path.startsWith('/account/state'))
      return {
        'phone': {'games': {}},
      };
    return <String, dynamic>{};
  }

  @override
  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    _gate(path);
    (posted[path] ??= []).add(body);
    if (path == '/auth/create' || path == '/auth/login') {
      return {'token': 't', 'email': 'new@school.edu'};
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

  /// Calls that touched anything belonging to an account.
  List<String> get accountCalls =>
      calls.where((p) => !_isOpen(p) && !p.startsWith('/auth/')).toList();
}

void main() {
  setUpAll(() async {
    await loadBrandFonts();
    await loadMathFonts();
  });

  late _Server server;
  late AuthController auth;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    Notifications.tapped.value = null;
    GameProgress.instance.clearAll();
    appClock = () => DateTime(2026, 10, 20, 9);
    server = _Server();
    auth = AuthController(api: server, storage: AppStorage())
      ..status = AuthStatus.unauthenticated
      ..onboardingSeen = true;
    await auth.startGuest();
  });
  tearDown(() {
    appClock = DateTime.now;
    AppPalette.dark = false;
  });

  Future<GoRouter> open(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
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
    return router;
  }

  Future<void> tab(WidgetTester tester, HomeTab t) async {
    HomeShell.select(t);
    await tester.pumpAndSettle();
  }

  testWidgets('a guest lands on Study, with the whole map open', (
    tester,
  ) async {
    await open(tester);
    expect(find.byType(HomeShell), findsOneWidget);
    expect(find.text('NOT SIGNED IN'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(
      find.textContaining('Rounds you finish are kept on this phone'),
      findsOneWidget,
    );
    expect(find.text('Start'), findsWidgets);
    expect(server.accountCalls, isEmpty);
  });

  testWidgets('the Daily shows today\'s concepts and asks for an account to '
      'play', (tester) async {
    await open(tester);
    await tab(tester, HomeTab.daily);
    expect(find.text('Today\'s Daily'), findsOneWidget);
    expect(find.text('Sign up to play'), findsOneWidget);
    expect(find.textContaining('so it needs an account'), findsOneWidget);
    expect(server.calls, contains(startsWith('/daily/preview')));
    expect(server.accountCalls, isEmpty);
  });

  testWidgets('Profile says what an account adds, and the sheet has nothing '
      'to delete', (tester) async {
    await open(tester);
    await tab(tester, HomeTab.profile);
    expect(
      find.text('Your progress lives on this phone for now.'),
      findsOneWidget,
    );
    for (final line in accountAdds) {
      expect(find.text(line), findsOneWidget);
    }
    await tester.tap(find.byType(GuestAvatar).first);
    await tester.pumpAndSettle();
    expect(find.text('Not signed in'), findsOneWidget);
    expect(find.text('Study reminders'), findsNothing);
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    expect(find.text('Contact us'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Delete account'), findsNothing);
    expect(server.accountCalls, isEmpty);
  });

  testWidgets('a guest cannot reach the Daily\'s own screens', (tester) async {
    final router = await open(tester);
    router.go('/daily/step');
    await tester.pumpAndSettle();
    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets('a guest\'s round stays on the phone and is never sent', (
    tester,
  ) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: MaterialApp(
          home: Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    final session = BoardSession(
      gameId: 'which-property',
      chapterId: 'fluid-mechanics',
      total: 6,
      sourceProblemIdOf: (_) => 'fm-fp-q1',
    );
    session.submit(ok: true, context: ctx);
    await tester.pumpAndSettle();
    session.next();
    session.submit(ok: false, context: ctx);
    await tester.pumpAndSettle();

    expect(GameProgress.instance.roundsCleared('which-property'), {0});
    expect((await GuestLog.all()).map((e) => e.correct), [true, false]);
    expect(server.calls, isEmpty);
    session.dispose();
  });

  test(
    'signing up sends the guest\'s rounds to the new account, once',
    () async {
      await GuestLog.add([for (var r = 1; r <= 4; r++) _event(round: r)]);
      await auth.register('new@school.edu', 'a-long-password');
      await pumpEventQueue();

      final sent = server.posted['/sync/events']!;
      expect(sent, hasLength(1));
      expect((sent.single!['events'] as List), hasLength(4));
      expect(await GuestLog.all(), isEmpty);
      expect(auth.guest, isFalse);
      expect(await AppStorage().guestMode(), isFalse);
    },
  );

  test('a failed send keeps the rounds for next time', () async {
    final failing = _FailingSync();
    final a = AuthController(api: failing, storage: AppStorage())
      ..status = AuthStatus.unauthenticated;
    await a.startGuest();
    await GuestLog.add([_event(round: 1)]);
    await a.signIn('new@school.edu', 'pw');
    await pumpEventQueue();
    expect(await GuestLog.all(), hasLength(1));
    expect(a.guest, isTrue);
  });

  test('signing out leaves the phone with nobody\'s rounds', () async {
    auth
      ..guest = false
      ..status = AuthStatus.authenticated;
    GameProgress.instance.markRoundCleared('which-property', 0, firstTry: true);
    await auth.signOut();
    expect(GameProgress.instance.totalRoundsCleared, 0);
    expect(await GuestLog.all(), isEmpty);
  });

  group('screens for the owner', () {
    for (final night in [false, true]) {
      final mode = night ? 'night' : 'day';
      testWidgets('guest screens, $mode', (tester) async {
        AppPalette.dark = night;
        GameProgress.instance.markRoundCleared(
          'which-property',
          0,
          firstTry: true,
        );
        GameProgress.instance.markRoundCleared(
          'which-property',
          1,
          firstTry: true,
        );
        GameProgress.instance.markRoundCleared(
          'which-property',
          2,
          firstTry: false,
        );
        GameProgress.instance.markRoundCleared(
          'which-property',
          3,
          firstTry: true,
        );
        await open(tester);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/guest/study-$mode.png'),
        );
        await tab(tester, HomeTab.daily);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/guest/daily-$mode.png'),
        );
        await tab(tester, HomeTab.profile);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/guest/profile-$mode.png'),
        );
        await tester.tap(find.byType(GuestAvatar).first);
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/guest/account-sheet-$mode.png'),
        );
      });
    }
  });
}

class _FailingSync extends _Server {
  @override
  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    if (path == '/sync/events')
      throw ApiException('no signal', isNetwork: true);
    return super.post(path, body);
  }
}

GameEvent _event({required int round}) => GameEvent(
  sourceProblemId: 'fm-fp-q1',
  chapterId: 'fluid-mechanics',
  gameId: 'which-property',
  round: round,
  correct: true,
);
