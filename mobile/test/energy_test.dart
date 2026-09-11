import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/does_the_mass_matter_game.dart';
import 'package:mobile/features/games/energy_figures.dart';
import 'package:mobile/features/games/more_in_than_out_game.dart';
import 'package:mobile/features/games/where_the_energy_goes_game.dart';

/// Chapter six, lesson four. The lesson's own three answers, and the wrong
/// ones it names, worked out here.
void main() {
  group('the arithmetic the lesson is built on', () {
    const g = 9.81;

    test('the block off the smooth ramp reaches 7.67', () {
      expect(math.sqrt(2 * g * 3), closeTo(7.67, 0.005));
      // Its three wrong answers, each the same expression with a piece gone.
      expect(g * 3, closeTo(29.4, 0.05));
      expect(2 * g * 3, closeTo(58.9, 0.05));
      expect(math.sqrt(g * 3), closeTo(5.42, 0.005));
    });

    test('the pump needs 12.3 kilowatts at the motor', () {
      const useful = 1000 * 0.05 * g * 20;
      expect(useful / 1000, closeTo(9.81, 0.01));
      expect(useful / 0.8 / 1000, closeTo(12.3, 0.05));
      // And the named wrong turn: multiplying by the efficiency instead.
      expect(useful * 0.8 / 1000, closeTo(7.85, 0.01));
      // Which is smaller than the useful power, and so cannot be an input.
      expect(useful * 0.8, lessThan(useful));
    });

    test('the sliding block stops after 10.9 meters', () {
      expect(64 / (2 * 0.3 * g), closeTo(10.87, 0.01));
      // Its three wrong answers.
      expect(64 / (0.3 * g), closeTo(21.7, 0.05));
      expect(64 / g, closeTo(6.52, 0.01));
      expect(64 / (0.3 * 10 * g), closeTo(2.17, 0.01));
    });

    test('mass really does cancel in both of those', () {
      double speedOff(double mass) => math.sqrt(2 * g * 3);
      double slideOf(double mass) => 0.5 * mass * 64 / (0.3 * mass * g);
      expect(speedOff(5), closeTo(speedOff(500), 1e-12));
      expect(slideOf(5), closeTo(slideOf(500), 1e-9));
      expect(slideOf(5), closeTo(10.87, 0.01));
    });
  });

  group('an energy account has to balance', () {
    test('the right account balances, and an unbalanced one is never it', () {
      // One distractor deliberately shows more coming out than went in, which
      // is a real thing to be able to spot. What must never happen is the
      // answer itself failing to add up.
      for (final r in ledgerRounds) {
        expect(r.truth.balances, isTrue,
            reason: '${r.subject}: the right account does not add up');
        for (final o in r.options) {
          if (identical(o, r.truth)) continue;
          if (!o.balances) {
            expect(o.end, greaterThan(o.start + o.added - o.gone),
                reason: '${r.subject}: an unbalanced distractor should be one '
                    'that invents energy, not one that quietly loses it');
          }
        }
      }
    });

    test('the right account is the only one telling that story', () {
      for (final r in ledgerRounds) {
        final right = r.truth;
        for (final o in r.options) {
          if (identical(o, right)) continue;
          final same = o.movingStart == right.movingStart &&
              o.heightStart == right.heightStart &&
              o.springStart == right.springStart &&
              o.movingEnd == right.movingEnd &&
              o.heightEnd == right.heightEnd &&
              o.springEnd == right.springEnd &&
              o.gone == right.gone &&
              o.added == right.added;
          expect(same, isFalse,
              reason: '${r.subject}: two accounts are the same');
        }
      }
    });

    test('conservation and loss are both on the board', () {
      expect(ledgerRounds.where((r) => r.truth.conserved), isNotEmpty);
      expect(ledgerRounds.where((r) => r.truth.gone > 0), isNotEmpty);
      expect(ledgerRounds.where((r) => r.truth.added > 0), isNotEmpty);
    });

    test('a spring round keeps its energy rather than losing it', () {
      final spring = ledgerRounds
          .firstWhere((r) => r.truth.springStart > 0 || r.truth.springEnd > 0);
      expect(spring.truth.conserved, isTrue,
          reason: 'a spring is a store, not a loss');
    });

    test('the three panels of a round share one scale', () {
      for (final r in ledgerRounds) {
        for (final o in r.options) {
          expect(o.tallest, lessThanOrEqualTo(r.tallest + 1e-9));
        }
        expect(r.tallest, greaterThan(0));
      }
    });
  });

  group('does-the-mass-matter is honest about what cancels', () {
    test('all three answers are used', () {
      expect(massRounds.map((r) => r.answer).toSet(), Heavier.values.toSet());
    });

    test('the ties are the ones whose formula has no mass in it', () {
      // A bare m, not the m in a backslash mu.
      final massSymbol = RegExp(r'(?<!\\)m(?!u)');
      for (final r in massRounds) {
        final hasMass = massSymbol.hasMatch(r.formula);
        expect(r.answer == Heavier.tie, !hasMass,
            reason: '${r.subject}: the formula and the answer disagree about '
                'whether mass matters');
      }
    });

    test('the spring round really does favor the light one', () {
      final spring = massRounds.firstWhere((r) => r.subject.contains('spring'));
      expect(spring.answer, Heavier.light);
      // Same energy into two masses: the lighter one leaves faster.
      double speed(double mass) => math.sqrt(200 / mass);
      expect(speed(2), greaterThan(speed(8)));
    });
  });

  group('more-in-than-out keeps the direction straight', () {
    test('an output wanted from an input multiplies, and the reverse divides',
        () {
      for (final r in powerRounds) {
        if (r.answer == Step.divideByEta) {
          expect(r.asked.toLowerCase().contains('motor') ||
              r.asked.toLowerCase().contains('input'), isTrue,
              reason: '${r.subject}: dividing is for getting the input');
        }
        if (r.answer == Step.multiplyByEta) {
          expect(
              r.asked.toLowerCase().contains('water') ||
                  r.asked.toLowerCase().contains('deliver'),
              isTrue,
              reason: '${r.subject}: multiplying is for getting the output');
        }
      }
    });

    test('every round offers its own answer exactly once', () {
      for (final r in powerRounds) {
        expect(r.options.where((s) => s == r.answer).length, 1,
            reason: '${r.subject}');
        expect(r.options.toSet().length, r.options.length,
            reason: '${r.subject}: a step is offered twice');
      }
    });

    test('both of the two ways to write power get asked for', () {
      expect(powerRounds.where((r) => r.answer == Step.forceTimesSpeed),
          isNotEmpty);
      expect(powerRounds.where((r) => r.answer == Step.workOverTime),
          isNotEmpty);
    });

    test('the input is always the bigger number', () {
      const out = 9.81;
      const eta = 0.8;
      expect(out / eta, greaterThan(out));
      expect(out * eta, lessThan(out));
    });
  });
}
