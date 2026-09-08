import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/both_sides_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/next_line_game.dart';
import 'package:mobile/features/games/run_the_loop_game.dart';

/// Lesson ten. Its first item is answered by a SEQUENCE of moves, which the
/// gate has no way to describe, so the sequences are checked here: that they
/// alternate the way the rule does, that they end somewhere sensible, and that
/// the loop really does go round more than once somewhere.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['run-the-loop', 'next-line', 'both-sides']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('run the loop', () {
    test('every round starts by putting the value in', () {
      for (final r in loopRounds) {
        expect(
          r.steps.first.move,
          LoopMove.substitute,
          reason: 'checking the form is the first move, always',
        );
      }
    });

    test('a round ends by reading it off or by ruling the rule out', () {
      for (final r in loopRounds) {
        expect(
          r.steps.last.move,
          anyOf(LoopMove.readOff, LoopMove.notApplicable),
          reason: r.opening,
        );
      }
    });

    test('nothing is differentiated before it has been substituted into', () {
      for (final r in loopRounds) {
        for (var i = 0; i < r.steps.length; i++) {
          if (r.steps[i].move == LoopMove.differentiate) {
            expect(
              i > 0 && r.steps[i - 1].move == LoopMove.substitute,
              isTrue,
              reason: '${r.opening} differentiates without looking first',
            );
          }
        }
      }
    });

    test('differentiating only ever follows an indeterminate form', () {
      const indeterminate = [r'\frac{0}{0}', r'\frac{\infty}{\infty}'];
      for (final r in loopRounds) {
        for (final s in r.steps) {
          if (s.move == LoopMove.differentiate) {
            expect(
              indeterminate.contains(s.shown),
              isTrue,
              reason: '${s.shown} is not a form the rule accepts',
            );
          }
        }
      }
    });

    test('the rule is ruled out only on a form it does not accept', () {
      for (final r in loopRounds) {
        for (final s in r.steps) {
          if (s.move == LoopMove.notApplicable) {
            expect(s.shown, isNot(r'\frac{0}{0}'));
            expect(s.shown, isNot(r'\frac{\infty}{\infty}'));
          }
        }
      }
    });

    test('the set covers one pass, two passes, and no pass at all', () {
      int passes(LoopRound r) =>
          r.steps.where((s) => s.move == LoopMove.differentiate).length;
      final counts = loopRounds.map(passes).toSet();
      expect(counts.contains(0), isTrue, reason: 'a round needing no rule');
      expect(counts.contains(1), isTrue);
      expect(counts.contains(2), isTrue, reason: 'the stopping-early trap');
    });

    test('both indeterminate forms show up', () {
      final shown = [for (final r in loopRounds) for (final s in r.steps) s.shown];
      expect(shown, contains(r'\frac{0}{0}'));
      expect(shown, contains(r'\frac{\infty}{\infty}'));
    });
  });

  group('which line comes next', () {
    test('every round offers a quotient-rule line, and it is never right', () {
      for (final r in nextLines) {
        expect(r.quotientLine, inInclusiveRange(0, r.options.length - 1));
        expect(
          r.quotientLine,
          isNot(r.answer),
          reason: '${r.from} makes the quotient rule the right answer',
        );
        // The full quotient rule always squares the denominator, so its line
        // is longer than the one the rule actually gives.
        expect(
          r.options[r.quotientLine].length,
          greaterThan(r.options[r.answer].length),
          reason: r.from,
        );
      }
    });

    test('options are distinct and the answer moves around', () {
      for (final r in nextLines) {
        expect(r.options.toSet().length, r.options.length, reason: r.from);
        expect(r.answer, inInclusiveRange(0, r.options.length - 1));
      }
      expect(nextLines.map((r) => r.answer).toSet().length, greaterThan(2));
    });
  });

  group('both sides', () {
    test('the verdict follows from the two sides, both ways', () {
      for (final r in sidesRounds) {
        expect(r.exists, r.leftPositive == r.rightPositive);
        if (r.exists) {
          expect(r.verdict, contains(r'\infty'));
        } else {
          expect(r.verdict, contains('does not exist'));
        }
      }
    });

    test('agreeing and disagreeing rounds both appear, in both signs', () {
      expect(sidesRounds.any((r) => !r.exists), isTrue);
      expect(
        sidesRounds.any((r) => r.exists && r.leftPositive),
        isTrue,
        reason: 'plus infinity has to be reachable',
      );
      expect(
        sidesRounds.any((r) => r.exists && !r.leftPositive),
        isTrue,
        reason: 'so does minus infinity',
      );
    });

    test('a round where the TOP is negative is in the set', () {
      expect(
        sidesRounds.any((r) => r.top.contains('-')),
        isTrue,
        reason: 'otherwise only the bottom ever decides the sign',
      );
    });
  });

  group('the boards run', () {
    testWidgets('cutting before looking is caught and named', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: RunTheLoopGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('move-differentiate')));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT MOVE'), findsOneWidget);
      expect(find.textContaining('Check the form first'), findsOneWidget);
    });

    testWidgets('a full loop runs to the answer', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: RunTheLoopGame()));
      await tester.pumpAndSettle();

      for (final move in loopRounds.first.steps.map((s) => s.move)) {
        await tester.tap(find.byKey(ValueKey('move-${move.name}')));
        await tester.pumpAndSettle();
      }
      expect(find.text('LOOP FINISHED'), findsOneWidget);
    });

    testWidgets('the quotient-rule line is marked wrong', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: NextLineGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('line-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT LINE'), findsOneWidget);
    });

    testWidgets('both sides must be reported before locking in', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: BothSidesGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('left-down')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('BOTH SIDES READ RIGHT'), findsNothing);
      expect(find.text('NOT BOTH'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('right-up')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('BOTH SIDES READ RIGHT'), findsOneWidget);
    });
  });
}
