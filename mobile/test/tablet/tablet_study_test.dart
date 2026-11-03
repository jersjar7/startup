import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/games/chapter_map_screen.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/home/home_shell.dart';
import 'package:mobile/features/study/study_tab.dart' show appClock;

import '../support/fonts.dart';
import 'tablet_support.dart';

/// Study on a tablet: the chapter beside its live path, the lesson in the
/// chapter's place, Continue that scrolls and rings (TABLET.md, T01 to T03).
Widget _app() {
  final auth = AuthController(api: ApiClient(), storage: AppStorage())
    ..user = {
      'firstName': 'Jerson',
      'email': 'j@x.edu',
      'examDate': '2027-01-15',
    }
    ..status = AuthStatus.authenticated
    ..onboardingSeen = true;
  return ChangeNotifierProvider<AuthController>.value(
    value: auth,
    child: MaterialApp(
      theme: AppPalette.dark ? AppTheme.dark : AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const HomeShell(),
    ),
  );
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

/// As the mockups: two lessons of Mathematics cleared, one game of the
/// third (Right Triangle Trigonometry).
void _progress() {
  final math = chapterMaps['mathematics']!;
  for (final lesson in math.lessons.take(2)) {
    for (final game in lesson.builtGames) {
      for (var r = 0; r < game.rounds; r++) {
        GameProgress.instance.markRoundCleared(game.id, r, firstTry: true);
      }
    }
  }
  final first = math.lessons[2].builtGames.first;
  for (var r = 0; r < first.rounds; r++) {
    GameProgress.instance.markRoundCleared(first.id, r, firstTry: true);
  }
}

Future<void> _open(WidgetTester tester, Size size) async {
  setWindow(tester, size);
  await tester.pumpWidget(_app());
  await settle(tester);
  HomeShell.select(HomeTab.study);
  await settle(tester);
}

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
    appClock = () => DateTime(2026, 11, 3, 10);
  });

  setUp(() {
    _wipe();
    _progress();
  });
  tearDown(_wipe);

  for (final (name, size) in [
    ('landscape', landscape),
    ('portrait', portrait),
  ]) {
    testWidgets('the chapter beside its path, centred ($name)', (tester) async {
      await _open(tester, size);
      final pane = find.byType(ChapterPathPane);
      expect(pane, findsOneWidget);
      // The zigzag's middle line is the pane's middle line.
      final paneRect = tester.getRect(pane);
      final math = chapterMaps['mathematics']!;
      final a = tester.getCenter(find.byKey(ValueKey(math.lessons[0].id)));
      final b = tester.getCenter(find.byKey(ValueKey(math.lessons[1].id)));
      expect((a.dx + b.dx) / 2, closeTo(paneRect.center.dx, 0.5));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../goldens/tablet/study-$name.png'),
      );

      // Continue scrolls the path to the lesson in flight and rings it; it
      // never opens the lesson.
      await tester.tap(find.text('Continue').first);
      await settle(tester);
      expect(find.byKey(const ValueKey('path-ring')), findsOneWidget);
      expect(find.byKey(const ValueKey('lesson-pane')), findsNothing);

      // The node opens the lesson in the chapter's place; the path stays.
      await tester.tap(find.byKey(ValueKey(math.lessons[2].id)));
      await settle(tester);
      expect(find.byKey(const ValueKey('lesson-pane')), findsOneWidget);
      expect(find.byType(ChapterPathPane), findsOneWidget);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../goldens/tablet/study-lesson-$name.png'),
      );

      // The concept from the lesson: a full page, the picture beside or
      // above the steps (T07).
      await tester.tap(find.text('Read the concept first'));
      await settle(tester);
      expect(find.byType(ConceptPage), findsOneWidget);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../goldens/tablet/lesson-brief-$name.png'),
      );
      await _drain(tester);
    });

    testWidgets('all chapters beside the picked one\'s path ($name)', (
      tester,
    ) async {
      await _open(tester, size);
      await tester.tap(find.bySemanticsLabel('All chapters'));
      await settle(tester);
      await tester.tap(find.text('Statics').first);
      await settle(tester);
      expect(find.text(chapterMaps['statics']!.name), findsWidgets);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../goldens/tablet/study-grid-$name.png'),
      );
      await _drain(tester);
    });
  }

  testWidgets('the opened lesson survives a rotation', (tester) async {
    await _open(tester, landscape);
    final math = chapterMaps['mathematics']!;
    await tester.tap(find.byKey(ValueKey(math.lessons[2].id)));
    await settle(tester);
    tester.view.physicalSize = portrait;
    await settle(tester);
    expect(find.byKey(const ValueKey('lesson-pane')), findsOneWidget);
    expect(find.text(math.lessons[2].name), findsWidgets);
    tester.view.physicalSize = landscape;
    await settle(tester);
    expect(find.byKey(const ValueKey('lesson-pane')), findsOneWidget);
    await _drain(tester);
  });

  testWidgets('the path at night keeps the spring roles', (tester) async {
    AppPalette.dark = true;
    addTearDown(() => AppPalette.dark = false);
    await _open(tester, landscape);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../goldens/tablet/study-landscape-night.png'),
    );
    await _drain(tester);
  });
}
