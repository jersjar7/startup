import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/games/board.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/which_ratio_game.dart';
import 'package:mobile/features/shared/widgets/kit.dart';

import '../support/fonts.dart';
import 'tablet_support.dart';

/// A round on a tablet (TABLET.md, "A round", T04 to T06): the drawing
/// beside the answers, the concept docked beside the round at 960 and up,
/// and nothing the round knows lost on a rotation.
Widget _app(Widget home) => MaterialApp(
  theme: AppPalette.dark ? AppTheme.dark : AppTheme.light,
  debugShowCheckedModeBanner: false,
  home: home,
);

Future<void> _round(WidgetTester tester, Size size) async {
  setWindow(tester, size);
  await tester.pumpWidget(_app(const WhichRatioGame()));
  await settle(tester);
}

Future<void> _pickTan(WidgetTester tester) async {
  await tester.tap(find.text('tan'));
  await tester.pumpAndSettle();
}

Future<void> _golden(WidgetTester tester, String name) => expectLater(
  find.byType(MaterialApp),
  matchesGoldenFile('../goldens/tablet/$name.png'),
);

void main() {
  setUpAll(loadBrandFonts);
  setUp(() {
    GameProgress.instance.reset('which-ratio');
    SharedPreferences.setMockInitialValues({'book_dot_seen': true});
  });

  testWidgets('landscape: the drawing beside the answers', (tester) async {
    await _round(tester, landscape);
    final figure = tester.getRect(find.byType(CustomPaint).first);
    final pill = tester.getRect(find.text('Lock it in'));
    final question = tester.getRect(find.text('WHICH RATIO CONNECTS THEM'));
    // The answer column is to the right of the drawing, the question level
    // with its top.
    expect(question.left, greaterThan(600));
    expect(pill.left, greaterThan(600));
    expect(figure.width, greaterThan(500));
    await _pickTan(tester);
    await _golden(tester, 'round-landscape');
    await tester.tap(find.text('Lock it in'));
    await settle(tester);
    await _golden(tester, 'round-answered-landscape');
  });

  testWidgets('portrait: one column, the drawing larger', (tester) async {
    await _round(tester, portrait);
    await _pickTan(tester);
    await _golden(tester, 'round-portrait');
  });

  testWidgets('the book docks the concept beside the round, still playable', (
    tester,
  ) async {
    await _round(tester, landscape);
    await tester.tap(find.byTooltip(ratiosBrief.title));
    await settle(tester);
    expect(find.byKey(const ValueKey('concept-beside')), findsOneWidget);
    // No second pill: the round's is the window's one action.
    expect(find.text('Back to the round'), findsNothing);
    // The round stays playable beside it.
    await _pickTan(tester);
    await _golden(tester, 'round-with-concept-landscape');
    await tester.tap(find.byTooltip('Close the concept'));
    await settle(tester);
    expect(find.byKey(const ValueKey('concept-beside')), findsNothing);
  });

  testWidgets('the flag docks the report beside the round (T19)', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'book_dot_seen': true,
      'flag_dot_seen': true,
    });
    await _round(tester, landscape);
    await tester.tap(find.byTooltip('Something unclear?'));
    await settle(tester);
    expect(find.byKey(const ValueKey('feedback-beside')), findsOneWidget);
    expect(find.text('Something unclear?'), findsOneWidget);
    await _golden(tester, 'feedback-sheet-landscape');
    await tester.tap(find.byTooltip('Close').last);
    await settle(tester);
    expect(find.byKey(const ValueKey('feedback-beside')), findsNothing);
  });

  testWidgets('a rotation keeps the pick, the round and the open concept', (
    tester,
  ) async {
    await _round(tester, landscape);
    await _pickTan(tester);
    await tester.tap(find.byTooltip(ratiosBrief.title));
    await settle(tester);
    for (final size in [portrait, phone, splitHalf, landscape]) {
      tester.view.physicalSize = size;
      await settle(tester);
      // The pick is still made: the pill takes a tap.
      final pill = tester.widget<PillButton>(find.byType(PillButton).first);
      expect(pill.onTap, isNotNull, reason: 'pick lost at $size');
      expect(find.text('0/8'), findsOneWidget, reason: 'round at $size');
      expect(
        find.byKey(const ValueKey('concept-beside')),
        findsOneWidget,
        reason: 'concept closed at $size',
      );
    }
  });

  testWidgets('split screen beside the Handbook is the phone round', (
    tester,
  ) async {
    await _round(tester, splitHalf);
    // The phone frame: the flag above the pill, not beside it.
    final flag = tester.getRect(find.byTooltip('Something unclear?'));
    final pill = tester.getRect(find.byType(PillButton));
    expect(flag.bottom, lessThanOrEqualTo(pill.top));
  });

  testWidgets('night, landscape', (tester) async {
    AppPalette.dark = true;
    addTearDown(() => AppPalette.dark = false);
    await _round(tester, landscape);
    await tester.tap(find.byTooltip(ratiosBrief.title));
    await settle(tester);
    await _golden(tester, 'round-with-concept-landscape-night');
  });

  for (final (o, size) in [('landscape', landscape), ('portrait', portrait)]) {
    testWidgets('the round done, $o (T19b)', (tester) async {
      setWindow(tester, size);
      GameProgress.instance.reset('perpendicular-flip');
      for (var r = 0; r < 8; r++) {
        GameProgress.instance.markRoundCleared(
          'perpendicular-flip',
          r,
          firstTry: r < 6,
        );
      }
      final session = BoardSession(
        gameId: 'perpendicular-flip',
        chapterId: 'mathematics',
        total: 8,
        sourceProblemIdOf: (r) => 'math-slq-q$r',
      );
      await tester.pumpWidget(
        _app(
          BoardDone(
            session: session,
            title: 'You can build the perpendicular by hand.',
            closing:
                'Knowing the rule is not the same as solving with it. The '
                'full problems belong at a desk, on paper.',
          ),
        ),
      );
      await settle(tester);
      expect(tester.takeException(), isNull);
      await _golden(tester, 'round-done-$o');
    });
  }
}
