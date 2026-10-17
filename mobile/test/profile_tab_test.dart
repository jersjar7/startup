import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/home/home_shell.dart';
import 'package:mobile/features/profile/badges_page.dart';
import 'package:mobile/features/profile/concepts_page.dart';
import 'package:mobile/features/profile/profile_tab.dart';
import 'package:mobile/features/study/study_tab.dart' show appClock;

import 'support/fonts.dart';

/// The Profile tab is the home: the next-concept hero, exam day, days
/// studied, mastery, and the account sheet behind the avatar. Photographed
/// on day one and a few weeks in, inside the shell so the dock is in frame.

Widget _app(Map<String, dynamic> user) {
  final auth = AuthController(api: ApiClient(), storage: AppStorage())
    ..user = user
    ..status = AuthStatus.authenticated
    // Already toured: these tests are about the screen, not the tour, which
    // otherwise opens over it on first launch.
    ..onboardingSeen = true;
  return ChangeNotifierProvider<AuthController>.value(
    value: auth,
    child: MaterialApp(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const HomeShell(),
    ),
  );
}

void _clear(String chapterId, int lessons) {
  final chapter = chapterMaps[chapterId]!;
  for (final lesson in chapter.lessons.take(lessons)) {
    for (final game in lesson.builtGames) {
      for (var r = 0; r < game.rounds; r++) {
        GameProgress.instance.markRoundCleared(game.id, r, firstTry: true);
      }
    }
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

/// Fonts load from the asset bundle asynchronously; give them a beat before
/// the first frame that matters.
Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 60)),
  );
  await tester.pumpAndSettle();
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Profile fires two requests at a server that is not there; the timeouts
/// have to run out before the tree is torn down.
Future<void> _drain(WidgetTester tester) =>
    tester.pump(const Duration(minutes: 2));

void main() {
  setUpAll(() async {
    await loadBrandFonts();
    PackageInfo.setMockInitialValues(
      appName: 'FE for Raccoons',
      packageName: 'com.fe4raccoons.mobile',
      version: '1.0.0',
      buildNumber: '1100',
      buildSignature: '',
    );
    // A Friday morning, so the greeting and the exam date never drift.
    appClock = () => DateTime(2026, 9, 18, 10);
  });

  setUp(() {
    _wipe();
    debugResetProfileOpen();
  });
  tearDown(_wipe);

  testWidgets('day one: an invitation, no numbers of the student\'s own', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(_app({'firstName': 'Jerson', 'email': 'j@x.edu'}));
    await _settle(tester);

    expect(find.byType(ProfileTab), findsOneWidget);
    // Everybody opens the app with nothing done in it (owner, 2026-10-16).
    expect(find.text('Jerson, your FE prep starts here.'), findsOneWidget);
    // The facts describe the app, not a student with nothing done yet.
    expect(find.text('15'), findsOneWidget);
    expect(find.text('chapters'), findsOneWidget);
    expect(find.text('When is your exam?'), findsOneWidget);
    expect(find.text('Start here'), findsOneWidget);
    expect(find.textContaining('Mathematics'), findsOneWidget);
    // No zero anywhere, and the Daily is its own tab, never repeated here.
    expect(find.text('0'), findsNothing);
    expect(find.textContaining('Daily'), findsOneWidget); // the dock's label

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home/profile-day-one.png'),
    );
    await _drain(tester);
  });

  testWidgets('no name: the sentence stands without one', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app({'email': 'j@x.edu'}));
    await _settle(tester);
    expect(find.text('Your FE prep starts here.'), findsOneWidget);
    await _drain(tester);
  });

  testWidgets('week five: the lesson in flight, counted in rounds', (
    tester,
  ) async {
    _phone(tester);
    _clear('mathematics', 3);
    final exam = appClock().add(const Duration(days: 73));
    await tester.pumpWidget(
      _app({
        'firstName': 'Jerson',
        'email': 'j@x.edu',
        'currentStreak': 6,
        'totalXp': 1240,
        'examDate': exam.toIso8601String(),
      }),
    );
    await _settle(tester);

    // Six days studied is the total, not a run: no run is on the account,
    // so it is a plain welcome back (owner, 2026-10-16).
    expect(find.text('Welcome back, Jerson.'), findsOneWidget);
    expect(find.textContaining('rounds left'), findsOneWidget);
    expect(find.text('Carry on'), findsOneWidget);
    expect(find.text('6'), findsOneWidget); // days studied
    expect(find.text('73'), findsOneWidget); // days to the exam

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home/profile-week-five.png'),
    );

    // The avatar opens the account sheet with the actions that left the tab.
    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountSheet), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('1,240'), findsOneWidget);
    // Where the sign-up step's "change it any time" is true (ADR 0023).
    expect(find.text('Name'), findsOneWidget);
    // The version as plain text where Licences used to be; Delete account
    // is off the sheet's face (owner's call, 2026-10-13).
    expect(find.text('Version 1.0.0'), findsOneWidget);
    expect(find.text('Open source licenses'), findsNothing);
    expect(find.text('Delete account'), findsNothing);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home/account-sheet.png'),
    );

    // Delete account and About live behind the three dots.
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home/account-sheet-more.png'),
    );

    // The open source licenses are one level in, under About, as other
    // apps keep them.
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('Open source licenses'), findsOneWidget);
    expect(find.text('1.0.0'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home/account-sheet-about.png'),
    );
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    // Sign out asks first, and staying puts the account back.
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign out?'), findsOneWidget);
    expect(find.text('Stay signed in'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home/account-sheet-sign-out.png'),
    );
    await tester.tap(find.text('Stay signed in'));
    await tester.pumpAndSettle();
    expect(find.text('Sign out?'), findsNothing);
    expect(find.text('Version 1.0.0'), findsOneWidget);
    await _drain(tester);
  });

  testWidgets('Concepts and Badges open over the sheet, and Back returns to it', (
    tester,
  ) async {
    _phone(tester);
    _clear('mathematics', 1);
    final held = chapterMaps['mathematics']!.lessons.first.builtGames;
    await tester.pumpWidget(_app({'firstName': 'Jerson', 'email': 'j@x.edu'}));
    await _settle(tester);
    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.textContaining(RegExp(r'^concepts$', caseSensitive: false)).first,
    );
    await tester.pumpAndSettle();
    expect(find.byType(ConceptsScreen), findsOneWidget);
    expect(find.text(held.first.brief!.title), findsOneWidget);

    // Back returns to the sheet it was opened from, not the Profile tab.
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(ConceptsScreen), findsNothing);
    expect(find.byType(AccountSheet), findsOneWidget);

    // And the same for Badges.
    await tester.tap(
      find.textContaining(RegExp(r'^badges$', caseSensitive: false)).first,
    );
    await tester.pumpAndSettle();
    expect(find.byType(BadgesScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(BadgesScreen), findsNothing);
    expect(find.byType(AccountSheet), findsOneWidget);
    await _drain(tester);
  });
}
