import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/notifications/notification_plan.dart';
import 'package:mobile/core/notifications/notifications.dart';
import 'package:mobile/core/router.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/auth/create_screen.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/home/home_shell.dart';
import 'package:mobile/features/profile/account_extras.dart';
import 'package:mobile/features/profile/exam_outcome_card.dart';
import 'package:mobile/features/profile/outcome_link_screen.dart';
import 'package:mobile/features/profile/pass_card_screen.dart';
import 'package:mobile/features/profile/profile_tab.dart';
import 'package:mobile/features/profile/profile_views.dart';
import 'package:mobile/features/study/chapter_bands.dart' show cardNameFor;
import 'package:mobile/features/study/study_tab.dart' show appClock;

import 'support/fonts.dart';

/// ADR 0023 in the app: what we call a student, the two faces of Profile,
/// and the pass card, from the app's own question, from the results email's
/// link, and from Profile for good. The server is a stand-in that keeps the
/// real one's rules (service/passCardAccess.js, service/routes/email.js).
/// Every case is listed in docs/mobile/name-profile-passcard-cases.md.

class FakeServer extends ApiClient {
  Map<String, dynamic> me = {'email': 's@x.com'};
  Map<String, dynamic>? link; // what the email's token sees
  Map<String, dynamic> mastery = {};
  final posts = <String, Map<String, dynamic>?>{};
  final gets = <String>[];
  final puts = <String, Map<String, dynamic>?>{};

  @override
  Future<dynamic> get(String path) async {
    gets.add(path);
    if (path == '/auth/me') return me;
    if (path == '/diagnostic/mastery') return {'chapterMastery': mastery};
    if (path.startsWith('/email/pass-card/')) {
      if (link == null) throw ApiException('No card here.', statusCode: 404);
      return link;
    }
    if (path.startsWith('/email/exam-result/')) {
      final passed = path.contains('a=passed');
      return {
        'ok': true,
        'answer': passed ? 'passed' : 'failed',
        'already': false,
        'heading': passed ? 'Congratulations' : 'Thank you for telling us',
        'msg': passed ? 'That is a big one.' : 'Most people sit it again.',
        'card': passed,
        'offerAttempt': true,
      };
    }
    if (path.startsWith('/email/exam-attempt/')) return {'ok': true};
    if (path.startsWith('/auth/schools?q=')) {
      final q = Uri.decodeQueryComponent(path.split('q=').last).toLowerCase();
      return {
        'schools': [
          'Brigham Young University',
          'Brigham Young University-Idaho',
        ].where((n) => n.toLowerCase().contains(q)).toList(),
      };
    }
    throw ApiException('Not here', statusCode: 404);
  }

  @override
  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    posts[path] = body;
    if (path == '/auth/card-name' || path.endsWith('/name')) {
      final name = body!['name'] as String;
      return {
        ...?link,
        ...?me['passCard'] as Map<String, dynamic>?,
        'cardName': name,
        'suggestedName': name,
      };
    }
    return {'ok': true};
  }

  @override
  Future<dynamic> put(String path, [Map<String, dynamic>? body]) async {
    puts[path] = body;
    me = {...me, ...?body};
    return me;
  }
}

const _card = {
  'firstName': 'Sammy',
  'lastName': null,
  'hasName': true,
  'cardName': null,
  'suggestedName': 'Sammy',
  'answeredAt': '2026-11-29T15:00:00Z',
};

late FakeServer server;

Future<AuthController> _pump(
  WidgetTester tester,
  Widget home, {
  bool signedIn = true,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final auth = AuthController(api: server, storage: AppStorage())
    ..user = signedIn ? server.me : null
    ..status = signedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated
    ..onboardingSeen = true;
  await tester.pumpWidget(
    ChangeNotifierProvider<AuthController>.value(
      value: auth,
      child: MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: home,
      ),
    ),
  );
  await _settle(tester);
  return auth;
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 400));
  }
}

void _wipe() {
  for (final chapter in chapterMaps.values) {
    for (final lesson in chapter.lessons) {
      for (final game in lesson.games) {
        GameProgress.instance.reset(game.id);
      }
    }
  }
}

void main() {
  setUpAll(() async {
    await loadBrandFonts();
    PackageInfo.setMockInitialValues(
      appName: 'FE for Raccoons',
      packageName: 'com.fe4raccoons.mobile',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    appClock = () => DateTime(2026, 12, 1, 10);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Notifications.tapped.value = null;
    server = FakeServer();
    debugResetProfileOpen();
    _wipe();
  });
  tearDown(_wipe);

  group('Profile, the empty face', () {
    testWidgets('website history shows as context, and Start goes where the '
        'points are (P2)', (tester) async {
      server.me = {'email': 's@x.com', 'firstName': 'Ana', 'currentStreak': 12};
      server.mastery = {
        'structural': {'totalMastery': 5, 'deskScore': 5},
        'mathematics': {'totalMastery': 60, 'deskScore': 60},
      };
      await _pump(tester, const HomeShell());
      expect(
        find.text('Ana, your website work came with you.'),
        findsOneWidget,
      );
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Studied on the website'), findsOneWidget);
      // Ranked by points left: an untouched heavy chapter outranks a
      // started one (focusChapters, the same as the mastery screen).
      expect(find.text('most points left'), findsOneWidget);
    });

    testWidgets('website figures that fail to load fall back to the plain '
        'face, never zeros (P3)', (tester) async {
      server.mastery = {};
      await _pump(tester, const HomeShell());
      expect(find.text('Your FE prep starts here.'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('one cleared round turns it, for good (P4)', (tester) async {
      await _pump(tester, const HomeShell());
      expect(find.text('Start here'), findsOneWidget);
      final game = chapterMaps['mathematics']!.lessons.first.builtGames.first;
      GameProgress.instance.markRoundCleared(game.id, 0, firstTry: true);
      await _settle(tester);
      expect(find.text('Good start.'), findsOneWidget);
      expect(find.text('Carry on'), findsOneWidget);
      expect(find.textContaining('rounds left'), findsOneWidget);
      // "Mathematics · Round 2 of N" under the button (owner, 2026-10-16).
      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.textContaining('Round 2 of'), findsOneWidget);
    });

    testWidgets(
      'a small phone scrolls rather than cutting anything off (P14)',
      (tester) async {
        await _pump(tester, const HomeShell(), size: const Size(320, 568));
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(ProfileTab), const Offset(0, -400));
        await _settle(tester);
        expect(find.text('Start here'), findsOneWidget);
      },
    );
  });

  group('the headline says what is true today (owner, 2026-10-16)', () {
    final today = DateTime(2026, 12, 1, 10);
    String h({
      String name = 'Sam',
      String? last,
      int streak = 0,
      int? exam,
      String? chapter,
      bool done = false,
    }) => underwayHeadline(
      name: name,
      today: today,
      lastStudyAtOpen: last,
      streak: streak,
      examDays: exam,
      chapterJustDone: chapter,
      allDone: done,
    );

    test('back the same day', () {
      expect(h(last: '2026-12-01', streak: 9, exam: 2), 'Back for more, Sam.');
    });
    test('a run of three days or more', () {
      expect(h(last: '2026-11-30', streak: 5), '5 days running, Sam.');
      expect(h(last: '2026-11-30', streak: 2), 'Welcome back, Sam.');
    });
    test('back after three days or more away', () {
      expect(h(last: '2026-11-27'), 'Good to see you again, Sam.');
      expect(h(last: '2026-11-29'), 'Welcome back, Sam.');
    });
    test('the exam close', () {
      expect(h(last: '2026-11-30', exam: 12), '12 days to go, Sam.');
      expect(h(last: '2026-11-30', exam: 3), 'Almost there, Sam.');
      expect(h(last: '2026-11-30', exam: 15), 'Welcome back, Sam.');
      // Past: not a countdown.
      expect(h(last: '2026-11-30', exam: -2), 'Welcome back, Sam.');
    });
    test('a chapter just finished', () {
      expect(h(last: '2026-11-30', chapter: 'Statics'), 'Statics, done.');
    });
    test('the first day ever', () {
      expect(h(), 'Good start, Sam.');
    });
    test('everything done outranks all of it', () {
      expect(h(last: '2026-12-01', done: true), 'Every lesson done, Sam.');
    });
    test('no name: the sentence stands alone', () {
      expect(h(name: '', last: '2026-12-01'), 'Back for more.');
      expect(h(name: '', streak: 4, last: '2026-11-30'), '4 days running.');
    });
    test('first match wins, in the agreed order', () {
      // Same day beats a streak; a streak beats the exam; away beats the exam.
      expect(h(last: '2026-12-01', streak: 4), 'Back for more, Sam.');
      expect(h(last: '2026-11-30', streak: 4, exam: 5), '4 days running, Sam.');
      expect(h(last: '2026-11-20', exam: 5), 'Good to see you again, Sam.');
      expect(
        h(last: '2026-11-30', exam: 5, chapter: 'Statics'),
        '5 days to go, Sam.',
      );
    });

    testWidgets('a round played today does not read as an earlier visit', (
      tester,
    ) async {
      server.me = {
        'email': 's@x.com',
        'firstName': 'Sam',
        'lastSessionDate': '2026-11-30',
      };
      await _pump(tester, const HomeShell());
      final game = chapterMaps['mathematics']!.lessons.first.builtGames.first;
      GameProgress.instance.markRoundCleared(game.id, 0, firstTry: true);
      // The server now says today, but the app opened before that round.
      server.me = {...server.me, 'lastSessionDate': '2026-12-01'};
      await _settle(tester);
      expect(find.text('Welcome back, Sam.'), findsOneWidget);
    });
  });

  group('Profile, once a pass is recorded', () {
    testWidgets('the card takes the exam\'s place, and opens (P13)', (
      tester,
    ) async {
      server.me = {
        'email': 's@x.com',
        'firstName': 'Sammy',
        'examOutcomeResolved': true,
        'passCard': _card,
      };
      await _pump(tester, const HomeShell());
      expect(find.text('You passed the FE.'), findsOneWidget);
      await tester.tap(find.text('Your pass card'));
      await _settle(tester);
      expect(find.byType(PassCardScreen), findsOneWidget);
    });

    testWidgets('a stale outcome reminder opens the card, not the question '
        '(O4)', (tester) async {
      server.me = {
        'email': 's@x.com',
        'examOutcomeResolved': true,
        'passCard': _card,
      };
      await _pump(tester, const HomeShell());
      Notifications.tapped.value = NotifyKind.outcome;
      await _settle(tester);
      expect(find.byType(PassCardScreen), findsOneWidget);
    });

    testWidgets('a stale reminder after a fail says thank you (O4)', (
      tester,
    ) async {
      server.me = {'email': 's@x.com', 'examOutcomeResolved': true};
      await _pump(tester, const HomeShell());
      Notifications.tapped.value = NotifyKind.outcome;
      await _settle(tester);
      expect(
        find.text('Thank you. We already have your answer.'),
        findsOneWidget,
      );
    });
  });

  group('the pass card', () {
    testWidgets('asks, filled in with the account\'s name, and saves the '
        'card\'s own (C4, C5, C6)', (tester) async {
      server.me = {'email': 's@x.com', 'firstName': 'Sammy', 'passCard': _card};
      await _pump(tester, const PassCardScreen());
      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.controller.text, 'Sammy');
      expect(find.text('Save or share'), findsNothing); // nothing to keep yet

      await tester.enterText(find.byType(EditableText), 'Samantha Reyes');
      await tester.pump();
      await tester.tap(find.text('Make my card'));
      await _settle(tester);
      expect(server.posts['/auth/card-name'], {'name': 'Samantha Reyes'});
      expect(find.text('Save or share'), findsOneWidget);
    });

    testWidgets('from the email\'s link it reads and saves by the token, '
        'signed out (C1, C13)', (tester) async {
      server.link = _card;
      await _pump(tester, const PassCardScreen(token: 'tok'), signedIn: false);
      expect(server.gets, contains('/email/pass-card/tok'));
      await tester.tap(find.text('Make my card'));
      await _settle(tester);
      expect(server.posts.keys, contains('/email/pass-card/tok/name'));
      // Nothing of a signed-in account is touched.
      expect(server.posts.keys, isNot(contains('/auth/card-name')));
    });

    testWidgets('an empty name cannot be confirmed (C6)', (tester) async {
      server.me = {
        'email': 's@x.com',
        'passCard': {..._card, 'suggestedName': null},
      };
      await _pump(tester, const PassCardScreen());
      await tester.tap(find.text('Make my card'));
      await _settle(tester);
      expect(server.posts, isEmpty);
    });

    testWidgets('an old link, or no pass, says so (C14)', (tester) async {
      server.link = null;
      await _pump(tester, const PassCardScreen(token: 'old'), signedIn: false);
      expect(find.text('No card here.'), findsOneWidget);
    });
  });

  testWidgets('"I passed" on the app\'s own question goes straight on to '
      'the card (C4)', (tester) async {
    server.me = {'email': 's@x.com', 'firstName': 'Sammy'};
    late AuthController auth;
    auth = await _pump(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: SingleChildScrollView(
            child: ExamOutcomeCard(auth: context.read<AuthController>()),
          ),
        ),
      ),
    );
    // The answer lands, and the account now carries the card.
    server.me = {...server.me, 'examOutcomeResolved': true, 'passCard': _card};
    await tester.tap(find.text('I passed'));
    await _settle(tester);
    await tester.tap(find.text('First'));
    await _settle(tester);
    expect(server.posts['/user/exam-outcome'], isNotNull);
    expect(find.byType(PassCardScreen), findsOneWidget);
    expect(auth.user?['passCard'], isNotNull);
  });

  group('the results email, opened in the app', () {
    testWidgets('"I passed" records it and goes on to the card (C1)', (
      tester,
    ) async {
      server.link = _card;
      await _pump(
        tester,
        const OutcomeLinkScreen(token: 'tok', answer: 'passed'),
        signedIn: false,
      );
      expect(
        server.gets,
        contains('/email/exam-result/tok?a=passed&format=json'),
      );
      expect(find.text('Congratulations'), findsOneWidget);
      // The attempt is offered, and optional.
      await tester.tap(find.text('FIRST'));
      await _settle(tester);
      expect(server.gets, contains('/email/exam-attempt/tok?n=1&format=json'));
      await tester.tap(find.text('Get my card'));
      await _settle(tester);
      expect(find.byType(PassCardScreen), findsOneWidget);
    });

    testWidgets('"Not this time" offers the next date, signed in (C17)', (
      tester,
    ) async {
      await _pump(
        tester,
        const OutcomeLinkScreen(token: 'tok', answer: 'failed'),
      );
      expect(find.text('Thank you for telling us'), findsOneWidget);
      expect(find.text('Set my next exam date'), findsOneWidget);
      expect(find.text('Get my card'), findsNothing);
    });
  });

  testWidgets('the email\'s links open their screens through the real '
      'router, signed out (C1, C13)', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    server.link = _card;
    final auth = AuthController(api: server, storage: AppStorage())
      ..status = AuthStatus.unauthenticated
      ..onboardingSeen = true;
    final router = buildRouter(auth);
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    router.go('/api/email/exam-result/tok?a=passed');
    await _settle(tester);
    expect(find.byType(OutcomeLinkScreen), findsOneWidget);
    router.go('/pass-card/tok');
    await _settle(tester);
    expect(find.byType(PassCardScreen), findsOneWidget);
    router.go('/api/email/exam-attempt/tok?n=2');
    await _settle(tester);
    expect(find.byType(OutcomeLinkScreen), findsOneWidget);
    expect(server.gets, contains('/email/exam-attempt/tok?n=2&format=json'));
  });

  group('school suggestions, the same list in both places', () {
    Future<void> typeSchool(WidgetTester tester, String text) async {
      await tester.enterText(find.byType(EditableText).last, text);
      await tester.pump(const Duration(milliseconds: 300)); // the debounce
      await _settle(tester);
    }

    testWidgets('the sign-up step suggests as it is typed, signed out', (
      tester,
    ) async {
      await _pump(tester, const CreateScreen(), signedIn: false);
      await tester.enterText(find.byType(EditableText), 's@x.edu');
      await tester.tap(find.byTooltip('Next'));
      await _settle(tester);
      await tester.tap(find.text('Skip')); // the name
      await _settle(tester);
      await tester.enterText(find.byType(EditableText), 'longenough1');
      await tester.tap(find.byTooltip('Next'));
      await _settle(tester);
      expect(find.text('Where do\nyou study?'), findsOneWidget);

      await typeSchool(tester, 'Brigham');
      expect(server.gets, contains('/auth/schools?q=Brigham'));
      expect(find.text('Brigham Young University'), findsOneWidget);
      expect(
        find.text('Not listed? Type it and we will take it.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Brigham Young University'));
      await _settle(tester);
      final field = tester.widget<EditableText>(find.byType(EditableText).last);
      expect(field.controller.text, 'Brigham Young University');
      // Picked: the list closes rather than reopening under the choice.
      expect(find.text('Brigham Young University-Idaho'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('one letter asks nothing', (tester) async {
      await _pump(tester, const CreateScreen(), signedIn: false);
      await tester.enterText(find.byType(EditableText), 's@x.edu');
      await tester.tap(find.byTooltip('Next'));
      await _settle(tester);
      await tester.tap(find.text('Skip'));
      await _settle(tester);
      await tester.enterText(find.byType(EditableText), 'longenough1');
      await tester.tap(find.byTooltip('Next'));
      await _settle(tester);
      await typeSchool(tester, 'B');
      expect(server.gets.where((p) => p.startsWith('/auth/schools')), isEmpty);
    });

    testWidgets('the account sheet\'s school editor still suggests', (
      tester,
    ) async {
      await _pump(tester, const HomeShell());
      await tester.tap(find.byTooltip('Account'));
      await _settle(tester);
      await tester.tap(find.byType(SchoolRow));
      await _settle(tester);
      await typeSchool(tester, 'Brigham');
      expect(find.text('Brigham Young University'), findsOneWidget);
    });

    test('both places use the one shared list', () {
      // So the sign-up can never again be missing what the sheet has.
      for (final f in [
        'lib/features/auth/create_screen.dart',
        'lib/features/profile/account_extras.dart',
      ]) {
        final src = File(f).readAsStringSync();
        expect(src, contains('SchoolSuggestions('), reason: f);
      }
      final sheet = File(
        'lib/features/profile/account_extras.dart',
      ).readAsStringSync();
      expect(
        RegExp(r'/auth/schools').allMatches(sheet).length,
        1,
        reason: 'one search, in SchoolSuggestions, not a second copy',
      );
    });
  });

  group('already graduated, a real answer', () {
    Future<void> toSchoolStep(WidgetTester tester) async {
      // A router, because creating the account moves on to /verify.
      await _pump(
        tester,
        Router.withConfig(
          config: GoRouter(
            initialLocation: '/create',
            routes: [
              GoRoute(path: '/create', builder: (_, _) => const CreateScreen()),
              GoRoute(
                path: '/verify',
                builder: (_, _) => const Scaffold(body: Text('VERIFY')),
              ),
            ],
          ),
        ),
        signedIn: false,
      );
      await tester.enterText(find.byType(EditableText), 's@x.edu');
      await tester.tap(find.byTooltip('Next'));
      await _settle(tester);
      await tester.tap(find.text('Skip'));
      await _settle(tester);
      await tester.enterText(find.byType(EditableText), 'longenough1');
      await tester.tap(find.byTooltip('Next'));
      await _settle(tester);
    }

    testWidgets('the tap shows it, and sign-up sends it', (tester) async {
      await toSchoolStep(tester);
      expect(find.text('Not set'), findsOneWidget);
      await tester.tap(find.text('I have already graduated'));
      await tester.pumpAndSettle();
      // Before: the tap cleared the year and the screen still said Not set.
      expect(find.text('Already graduated'), findsOneWidget);
      expect(find.text('Not set'), findsNothing);

      await tester.enterText(
        find.byType(EditableText),
        'Brigham Young University',
      );
      await tester.tap(find.byTooltip('Create account'));
      await _settle(tester);
      expect(server.posts['/auth/create'], containsPair('graduated', true));
      expect(
        server.posts['/auth/create']!.containsKey('graduationYear'),
        isFalse,
      );
    });

    testWidgets('then asks when, as a past year, and sends it', (tester) async {
      await toSchoolStep(tester);
      await tester.tap(find.text('I have already graduated'));
      await tester.pumpAndSettle();
      final now = DateTime.now().year;
      // The past, year only: no terms, no years still to come.
      expect(find.text('Where did\nyou study?'), findsOneWidget);
      expect(find.text('SPRING'), findsNothing);
      expect(find.text('${now + 1}'), findsNothing);
      // The strip builds only the years on screen; scroll it along.
      await tester.scrollUntilVisible(
        find.text('${now - 7}'),
        80,
        scrollable: find
            .descendant(
              of: find.byType(ListView).last,
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('${now - 7}'));
      await tester.pumpAndSettle();
      expect(find.text('Graduated ${now - 7}'), findsOneWidget);

      await tester.enterText(
        find.byType(EditableText),
        'Brigham Young University',
      );
      await tester.tap(find.byTooltip('Create account'));
      await _settle(tester);
      expect(server.posts['/auth/create'], containsPair('graduated', true));
      expect(
        server.posts['/auth/create'],
        containsPair('graduationYear', '${now - 7}'),
      );
    });

    testWidgets('"I am still in school" takes it back', (tester) async {
      await toSchoolStep(tester);
      await tester.tap(find.text('I have already graduated'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('I am still in school'));
      await tester.pumpAndSettle();
      expect(find.text('Not set'), findsOneWidget);
      expect(find.text('SPRING'), findsOneWidget);
      expect(find.text('${DateTime.now().year + 1}'), findsOneWidget);
    });

    testWidgets('the account sheet shows it, keeps it and saves it', (
      tester,
    ) async {
      server.me = {
        'email': 's@x.com',
        'school': {'name': 'BYU', 'graduationYear': null, 'graduated': true},
      };
      await _pump(tester, const HomeShell());
      await tester.tap(find.byTooltip('Account'));
      await _settle(tester);
      expect(find.text('BYU, graduated'), findsOneWidget);
      // A finished answer: no "Add graduation" nudge.
      expect(find.text('Add graduation'), findsNothing);
      await tester.tap(find.byType(SchoolRow));
      await _settle(tester);
      expect(find.text('Already graduated'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await _settle(tester);
      expect(server.posts['/user/school'], containsPair('graduated', true));
    });
  });

  group('what we call a student', () {
    testWidgets('the account sheet changes it (N7)', (tester) async {
      server.me = {'email': 's@x.com', 'firstName': 'Sam'};
      await _pump(tester, const HomeShell());
      await tester.tap(find.byTooltip('Account'));
      await _settle(tester);
      expect(find.byType(NameRow), findsOneWidget);
      await tester.tap(find.byType(NameRow));
      await _settle(tester);
      await tester.enterText(find.byType(EditableText), 'Samantha');
      await tester.tap(find.text('Save'));
      await _settle(tester);
      expect(server.puts['/user/profile'], {'firstName': 'Samantha'});
    });
  });
}
