import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/discriminant_gate_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/grade_sense_game.dart';

/// What each item actually grades, pinned. An item that is pretty and wrong is
/// worse than no item, and these two carry real traps from the lesson.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    GameProgress.instance.reset('grade-sense');
    GameProgress.instance.reset('discriminant-gate');
  });

  group('Grade Sense', () {
    testWidgets('the steepest is the short run, not the big rise',
        (tester) async {
      tester.view.physicalSize = const Size(420, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: GradeSenseGame()));

      // Round 1: A is 6 ft over 300, B is 6 ft over 100, C is 3 ft over 300.
      await tester.tap(find.text('B'));
      await tester.pump();
      await tester.tap(find.text('A'));
      await tester.pump();
      await tester.tap(find.text('C'));
      await tester.pump();

      await tester.tap(find.text('Lock the order'));
      await tester.pumpAndSettle();

      expect(find.text('CORRECT'), findsOneWidget);
      expect(find.text('1/6'), findsOneWidget);
    });

    testWidgets('ranking by rise alone is caught and named', (tester) async {
      tester.view.physicalSize = const Size(420, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: GradeSenseGame()));

      // A and B tie on rise, so rise-first ordering puts C last and gets the
      // top two the wrong way round.
      await tester.tap(find.text('A'));
      await tester.pump();
      await tester.tap(find.text('B'));
      await tester.pump();
      await tester.tap(find.text('C'));
      await tester.pump();
      await tester.tap(find.text('Lock the order'));
      await tester.pumpAndSettle();

      expect(find.text('NOT THE ORDER'), findsOneWidget);
      expect(find.textContaining('rise'), findsWidgets);
      // A miss is re-queued, never counted.
      expect(find.text('0/6'), findsOneWidget);
    });

    testWidgets('tapping a chosen card clears back to it', (tester) async {
      tester.view.physicalSize = const Size(420, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: GradeSenseGame()));

      await tester.tap(find.text('A'));
      await tester.pump();
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.text('A'));
      await tester.pump();
      expect(find.text('1'), findsNothing);
      expect(find.text('2'), findsNothing);
    });
  });

  test('every round has one and only one correct order', () {
    // Round 6 shipped with two stretches at exactly 2 percent, which made the
    // answer arbitrary and the game unwinnable by reasoning.
    for (var i = 0; i < gradeRounds.length; i++) {
      final grades = gradeRounds[i].stretches.map((s) => s.grade).toList();
      expect(grades.toSet().length, grades.length,
          reason: 'round ${i + 1} has two stretches at the same grade');
    }
  });

  testWidgets('the last answer is read before the summary appears',
      (tester) async {
    tester.view.physicalSize = const Size(420, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Five of six already done: one answer finishes the board.
    for (var i = 0; i < 5; i++) {
      GameProgress.instance.markRoundCleared('grade-sense', i, firstTry: true);
    }

    await tester.pumpWidget(const MaterialApp(home: GradeSenseGame()));

    final round = gradeRounds[5];
    for (final i in round.answer) {
      await tester.tap(find.text(round.stretches[i].name));
      await tester.pump();
    }
    await tester.tap(find.text('Lock the order'));
    await tester.pumpAndSettle();

    // The explanation is on screen, not the summary.
    expect(find.text('CORRECT'), findsOneWidget);
    expect(find.text('ALL DONE'), findsNothing);
    expect(find.text('See how you did'), findsOneWidget);

    await tester.tap(find.text('See how you did'));
    await tester.pumpAndSettle();
    expect(find.text('ALL DONE'), findsOneWidget);
  });

  group('Discriminant Gate', () {
    testWidgets('a curve through the axis twice has two real roots',
        (tester) async {
      tester.view.physicalSize = const Size(420, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: DiscriminantGateGame()));

      await tester.tap(find.text('Two real roots'));
      await tester.pump();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();

      expect(find.text('CORRECT'), findsOneWidget);
      expect(find.text('1/8'), findsOneWidget);
    });

    testWidgets('a wrong count is explained by where the curve sits',
        (tester) async {
      tester.view.physicalSize = const Size(420, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: DiscriminantGateGame()));

      await tester.tap(find.text('No real roots'));
      await tester.pump();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();

      expect(find.text('NOT THAT ONE'), findsOneWidget);
      expect(find.text('0/8'), findsOneWidget);
    });

    testWidgets('nothing can be locked in before a choice is made',
        (tester) async {
      tester.view.physicalSize = const Size(420, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: DiscriminantGateGame()));

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('CORRECT'), findsNothing);
      expect(find.text('NOT THAT ONE'), findsNothing);
    });
  });
}
