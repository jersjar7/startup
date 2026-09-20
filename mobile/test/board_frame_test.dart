import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/games/board.dart';
import 'package:mobile/features/games/feedback_sheet.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/perpendicular_flip_game.dart';

import 'support/fonts.dart';

/// The shared frame in the app language (references 13, 13b, 13c, 18): the
/// round with the book's one-time dot, the flag above the pill, the
/// feedback sheet, the peach panel after a miss, and the done screen.
/// Photographed on one real game; the frame is the same for all 375.

Widget _app(Widget home) => MaterialApp(
  theme: AppTheme.light,
  debugShowCheckedModeBanner: false,
  home: home,
);

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

void main() {
  setUpAll(loadBrandFonts);
  setUp(() {
    GameProgress.instance.reset('perpendicular-flip');
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('the round, first time ever: the book wears its dot', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(_app(const PerpendicularFlipGame()));
    await _settle(tester);
    expect(find.text('0/8'), findsOneWidget);
    expect(find.byTooltip('Something unclear?'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/00-frame/round.png'),
    );

    // Tapping the book puts the dot away for good.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('book_dot_seen'), isNull);
    await tester.tap(find.byTooltip('Parallel and perpendicular'));
    await tester.pumpAndSettle();
    expect(prefs.getBool('book_dot_seen'), isTrue);
  });

  testWidgets('the flag opens the feedback sheet', (tester) async {
    _phone(tester);
    SharedPreferences.setMockInitialValues({'book_dot_seen': true});
    await tester.pumpWidget(_app(const PerpendicularFlipGame()));
    await _settle(tester);
    await tester.tap(find.byTooltip('Something unclear?'));
    await tester.pumpAndSettle();
    expect(find.text('Something unclear?'), findsOneWidget);
    // Before an answer there is no answer or explanation to flag.
    expect(find.text('The question'), findsOneWidget);
    expect(find.text('How to play'), findsOneWidget);
    expect(find.text('The explanation'), findsNothing);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/00-frame/feedback-sheet.png'),
    );
    // Sending with nothing written is refused in place, not sent.
    await tester.tap(find.text('Send it'));
    await tester.pumpAndSettle();
    expect(find.text('Write a line first.'), findsOneWidget);
  });

  testWidgets('after an answer the sheet offers all six parts', (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      _app(
        const Scaffold(
          backgroundColor: AppColors.fog,
          body: FeedbackSheet(
            gameId: 'perpendicular-flip',
            gameName: 'Perpendicular Flip',
            chapterId: 'mathematics',
            round: 2,
            answered: true,
          ),
        ),
      ),
    );
    await _settle(tester);
    for (final label in FeedbackSheet.after.map((k) => k.$2)) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/00-frame/feedback-sheet-answered.png'),
    );
  });

  testWidgets('a miss: the peach panel', (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      _app(
        const Scaffold(
          backgroundColor: AppColors.fog,
          body: Padding(
            padding: EdgeInsets.all(24),
            child: Align(
              alignment: Alignment.topCenter,
              child: BoardFeedback(
                correct: false,
                title: 'NOT THAT ONE',
                body:
                    'Flipping alone leaves the line leaning the same way. '
                    'Perpendicular needs the sign changed too.',
              ),
            ),
          ),
        ),
      ),
    );
    await _settle(tester);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/00-frame/miss.png'),
    );
  });

  testWidgets('the done screen', (tester) async {
    _phone(tester);
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
    await _settle(tester);
    expect(find.text('8 of 8', findRichText: true), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/00-frame/done.png'),
    );
  });
}
