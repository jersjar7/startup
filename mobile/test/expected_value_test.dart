import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/add_the_squares_game.dart';
import 'package:mobile/features/games/expectation_figures.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/mind_the_order_game.dart';
import 'package:mobile/features/games/where_it_balances_game.dart';

/// Chapter two, lesson four. Every balance point, every total and every
/// hypotenuse on these three boards is recomputed here from the round's own
/// numbers. A fulcrum that does not actually balance the beam is the kind of
/// defect nobody would catch by looking.
double _expected(List<Outcome> outcomes) =>
    outcomes.fold<double>(0, (a, o) => a + o.value * o.percent / 100);

double _expectedOfSquares(List<Outcome> outcomes) => outcomes.fold<double>(
  0,
  (a, o) => a + o.value * o.value * o.percent / 100,
);

/// The net moment about a point. Zero is level.
double _moment(List<Outcome> outcomes, double at) =>
    outcomes.fold<double>(0, (a, o) => a + o.percent * (o.value - at));

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['where-it-balances', 'mind-the-order', 'add-the-squares']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('where it balances', () {
    test('the probabilities of a round add up to one', () {
      for (final r in balanceRounds) {
        final total = r.outcomes.fold<int>(0, (a, o) => a + o.percent);
        expect(total, 100, reason: '${r.subject} sums to $total percent');
      }
    });

    test('the answering fulcrum is where the beam actually balances', () {
      for (final r in balanceRounds) {
        final at = r.fulcrums[r.answer];
        expect(at, closeTo(_expected(r.outcomes), 0.001),
            reason: '${r.subject}: E(X) is ${_expected(r.outcomes)}, not $at');
        expect(_moment(r.outcomes, at), closeTo(0, 0.01),
            reason: '${r.subject}: the winning fulcrum still tips');
      }
    });

    test('every other fulcrum genuinely tips the beam', () {
      for (final r in balanceRounds) {
        for (var i = 0; i < r.fulcrums.length; i++) {
          if (i == r.answer) continue;
          expect(_moment(r.outcomes, r.fulcrums[i]).abs(), greaterThan(20),
              reason: '${r.subject}: fulcrum $i is too close to level to be '
                  'visibly wrong');
        }
      }
    });

    test('the fulcrums are far enough apart to tell apart', () {
      for (final r in balanceRounds) {
        final sorted = [...r.fulcrums]..sort();
        expect(sorted, r.fulcrums, reason: '${r.subject}: A B C run backwards');
        for (var i = 1; i < sorted.length; i++) {
          expect(sorted[i] - sorted[i - 1], greaterThanOrEqualTo(1.4),
              reason: '${r.subject}: two fulcrums are a thumb apart');
        }
      }
    });

    test('everything drawn is inside the beam', () {
      for (final r in balanceRounds) {
        for (final o in r.outcomes) {
          expect(o.value, inInclusiveRange(0, r.to.toInt()),
              reason: r.subject);
        }
        for (final f in r.fulcrums) {
          expect(f, inInclusiveRange(0, r.to), reason: r.subject);
        }
      }
    });

    test('the mode trap and the plain-average trap are both on offer', () {
      // Both of the lesson's named wrong answers have to appear as a fulcrum
      // somewhere, or the item never puts them in front of anybody.
      final modeOffered = balanceRounds.any((r) {
        final heaviest = r.outcomes
            .reduce((a, b) => a.percent >= b.percent ? a : b)
            .value
            .toDouble();
        return r.fulcrums.contains(heaviest) &&
            r.fulcrums[r.answer] != heaviest;
      });
      final averageOffered = balanceRounds.any((r) {
        final plain = r.outcomes.fold<int>(0, (a, o) => a + o.value) /
            r.outcomes.length;
        return r.fulcrums.any((f) => (f - plain).abs() < 0.001) &&
            (r.fulcrums[r.answer] - plain).abs() > 0.001;
      });
      expect(modeOffered, isTrue, reason: 'no round offers the tallest block');
      expect(averageOffered, isTrue,
          reason: 'no round offers the unweighted average');
    });

    test('one round balances on a value that cannot occur', () {
      final ghost = balanceRounds.any(
        (r) => !r.outcomes.any((o) => o.value == r.fulcrums[r.answer]),
      );
      expect(ghost, isTrue,
          reason: 'an expected value that is not an outcome is the fact this '
              'item exists to show');
    });

    test('one round is symmetric, so the tallest block IS the answer', () {
      final symmetric = balanceRounds.any((r) {
        final heaviest =
            r.outcomes.reduce((a, b) => a.percent >= b.percent ? a : b);
        return r.fulcrums[r.answer] == heaviest.value;
      });
      expect(symmetric, isTrue,
          reason: 'the mode trap works because it is sometimes right, and an '
              'item that never shows that is teaching a superstition');
    });
  });

  group('mind the order', () {
    test('the probabilities of a round add up to one', () {
      for (final r in orderRounds) {
        expect(r.outcomes.fold<int>(0, (a, o) => a + o.percent), 100,
            reason: r.subject);
      }
    });

    test('the two answering totals are the two the formula names', () {
      for (final r in orderRounds) {
        expect(r.first, isNonNegative, reason: '${r.subject}: no E(X squared)');
        expect(r.second, isNonNegative,
            reason: '${r.subject}: no square of the mean');
        expect(r.first, isNot(r.second));
        expect(r.totals[r.first].role, TotalRole.eSquared);
        expect(r.totals[r.second].role, TotalRole.meanSquared);
      }
    });

    test('the round computes its own arithmetic correctly', () {
      for (final r in orderRounds) {
        expect(r.mean, closeTo(_expected(r.outcomes), 1e-9));
        expect(r.meanOfSquares, closeTo(_expectedOfSquares(r.outcomes), 1e-9));
        expect(r.variance,
            closeTo(_expectedOfSquares(r.outcomes) -
                math.pow(_expected(r.outcomes), 2), 1e-9));
      }
    });

    test('a variance is positive, and the wrong order makes it negative', () {
      for (final r in orderRounds) {
        expect(r.variance, greaterThan(0), reason: r.subject);
        expect(r.mean * r.mean - r.meanOfSquares, lessThan(0),
            reason: '${r.subject}: the wrong order has to be visibly wrong');
      }
    });

    test('every round offers all five totals, each named once', () {
      for (final r in orderRounds) {
        expect(r.totals.length, 5, reason: r.subject);
        expect(r.totals.map((t) => t.role).toSet().length, 5,
            reason: '${r.subject}: two chips claim the same role');
        expect(r.totals.map((t) => t.latex).toSet().length, 5,
            reason: '${r.subject}: two chips are written the same');
      }
    });

    test('the answer is not in the same place round after round', () {
      for (var i = 1; i < orderRounds.length; i++) {
        expect(orderRounds[i].first, isNot(orderRounds[i - 1].first),
            reason: 'round ${i + 1} keeps the first total where it was');
      }
    });

    test('a round where the two totals sit close together is in the set', () {
      // Far apart, the order is obvious. Close together is where it is not.
      final tight = orderRounds.any(
        (r) => (r.meanOfSquares - r.mean * r.mean) / r.meanOfSquares < 0.15,
      );
      expect(tight, isTrue,
          reason: 'nothing here punishes a careless swap');
    });
  });

  group('add the squares', () {
    test('the answer is the root of the sum of the squares', () {
      for (final r in squaresRounds) {
        final variance = r.legA * r.legA + r.legB * r.legB;
        final wanted = r.wantsVariance ? variance : math.sqrt(variance);
        final stated = double.parse(
          r.options[r.answer].split(' ').first,
        );
        expect(stated, closeTo(wanted, 0.01),
            reason: '${r.subject}: the answer says ${r.options[r.answer]} and '
                'the legs give $wanted');
      }
    });

    test('the sum of the legs is offered as a wrong answer every time', () {
      // It is the mistake the whole item exists for. A round that does not
      // offer it is a round that never asks the question.
      for (final r in squaresRounds) {
        // On a round that wants the variance the same mistake shows up
        // squared, because adding the spreads and then squaring is what
        // somebody doing it wrong would hand in.
        final sum = r.legA + r.legB;
        final wrong = r.wantsVariance ? sum * sum : sum;
        final offered = r.options.any((o) {
          final v = double.tryParse(o.split(' ').first);
          return v != null && (v - wrong).abs() < 0.05;
        });
        expect(offered, isTrue,
            reason: '${r.subject}: nobody is offered ${wrong.toInt()}');
      }
    });

    test('the answer is never the sum, and never the same place twice', () {
      for (final r in squaresRounds) {
        final answer = double.parse(r.options[r.answer].split(' ').first);
        final sum = r.legA + r.legB;
        expect(answer, isNot(closeTo(r.wantsVariance ? sum * sum : sum, 0.05)),
            reason: r.subject);
      }
      for (var i = 1; i < squaresRounds.length; i++) {
        expect(squaresRounds[i].answer, isNot(squaresRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous position');
      }
    });

    test('no round offers the same number twice', () {
      for (final r in squaresRounds) {
        final values = [
          for (final o in r.options) double.parse(o.split(' ').first),
        ];
        expect(values.toSet().length, values.length, reason: r.subject);
        expect(r.options.length, 3, reason: r.subject);
      }
    });

    test('a variance round is in the set, and hides the hypotenuse', () {
      final variance = squaresRounds.where((r) => r.wantsVariance);
      expect(variance, isNotEmpty,
          reason: 'forgetting the square root is one of the two named traps');
      for (final r in variance) {
        expect(r.ask.contains('VARIANCE'), isTrue, reason: r.subject);
      }
    });

    test('a round carries a coefficient, and doubles the leg before drawing',
        () {
      final scaled = squaresRounds.firstWhere(
        (r) => r.combination.contains('2D'),
      );
      // The leg drawn has to be 2 sigma, not sigma, or the picture would
      // disagree with the formula it sits under.
      expect(scaled.legA, 6);
      expect(scaled.aLabel.contains('2('), isTrue);
    });

    test('the legs are different lengths, so the triangle reads as one', () {
      for (final r in squaresRounds) {
        expect(r.legA, isNot(r.legB), reason: r.subject);
        expect(r.legA, greaterThan(0));
        expect(r.legB, greaterThan(0));
      }
    });
  });

  group('the boards run', () {
    testWidgets('the beam will not be judged untouched', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhereItBalancesGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('IT SITS LEVEL'), findsNothing);
      expect(find.text('IT TIPS'), findsNothing);
    });

    testWidgets('putting the fulcrum in the middle of the range tips it', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhereItBalancesGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('fulcrum-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('IT TIPS'), findsOneWidget);
    });

    testWidgets('one total is not enough to lock in', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: MindTheOrderGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('total-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('IN THAT ORDER'), findsNothing);
      expect(find.text('NOT LIKE THAT'), findsNothing);
    });

    testWidgets('the right two totals in the wrong order are rejected', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: MindTheOrderGame()));
      await tester.pumpAndSettle();

      final r = orderRounds.first;
      await tester.tap(find.byKey(ValueKey('total-${r.second}')));
      await tester.tap(find.byKey(ValueKey('total-${r.first}')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT LIKE THAT'), findsOneWidget);
    });

    testWidgets('the right two totals in the right order are accepted', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: MindTheOrderGame()));
      await tester.pumpAndSettle();

      final r = orderRounds.first;
      await tester.tap(find.byKey(ValueKey('total-${r.first}')));
      await tester.tap(find.byKey(ValueKey('total-${r.second}')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('IN THAT ORDER'), findsOneWidget);
    });

    testWidgets('adding the two standard deviations is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: AddTheSquaresGame()));
      await tester.pumpAndSettle();

      // Round one offers 11.0 kN first, which is three plus eight.
      await tester.tap(find.byKey(const ValueKey('total-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT ONE'), findsOneWidget);
    });
  });
}
