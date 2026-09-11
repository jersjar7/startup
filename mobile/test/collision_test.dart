import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/collision_figures.dart';
import 'package:mobile/features/games/stick_or_bounce_game.dart';
import 'package:mobile/features/games/stretch_the_time_game.dart';
import 'package:mobile/features/games/what_survives_the_crash_game.dart';

/// Chapter six, lesson five. The engine is held against the lesson's own
/// three answers and against the wrong ones it names.
void main() {
  group('the engine reproduces the lesson it was built from', () {
    test('the locked bumpers leave at 10 meters a second', () {
      const cars = Crash(massA: 2000, massB: 1000, speedA: 15, e: 0);
      expect(cars.afterA, closeTo(10, 1e-9));
      expect(cars.afterB, closeTo(10, 1e-9),
          reason: 'they are stuck together and must leave at one speed');
      // Its named wrong answer: the wrong total mass underneath.
      expect(30000 / 4000, closeTo(7.5, 1e-9));
    });

    test('the balls leave at 2 and 6', () {
      const balls = Crash(massA: 2, massB: 2, speedA: 8, e: 0.5);
      expect(balls.afterA, closeTo(2, 1e-9));
      expect(balls.afterB, closeTo(6, 1e-9));
      // And what the same balls would do at the two extremes, which is what
      // the lesson's wrong answers are really about.
      const stuck = Crash(massA: 2, massB: 2, speedA: 8, e: 0);
      expect(stuck.afterA, closeTo(4, 1e-9));
      expect(stuck.afterB, closeTo(4, 1e-9));
      const perfect = Crash(massA: 2, massB: 2, speedA: 8, e: 1);
      expect(perfect.afterA, closeTo(0, 1e-9),
          reason: 'at e of one with equal masses the striker stops dead');
      expect(perfect.afterB, closeTo(8, 1e-9));
    });

    test('the barrier puts 200,000 newtons on the car', () {
      expect(1500 * 20 / 0.15, closeTo(200000, 1e-6));
      // Its named wrong answers: the momentum change reported as a force, and
      // multiplying by the time instead of dividing.
      expect(1500 * 20, closeTo(30000, 1e-9));
      expect(1500 * 20 * 0.15, closeTo(4500, 1e-9));
    });
  });

  group('what a collision keeps', () {
    test('momentum survives every crash on the board', () {
      for (final r in surviveRounds) {
        expect(r.crash.momentumKept, isTrue,
            reason: '${r.subject}: momentum is not conserved');
      }
      for (final r in impactRounds) {
        expect(r.crash.momentumKept, isTrue, reason: r.subject);
      }
    });

    test('energy survives exactly the perfect bounces', () {
      for (final r in surviveRounds) {
        expect(r.crash.energyKept, r.crash.e == 1,
            reason: '${r.subject}: the energy and the restitution disagree');
      }
    });

    test('a crash never ends with more energy than it started with', () {
      for (final r in surviveRounds) {
        expect(r.crash.energyAfter, lessThanOrEqualTo(r.crash.energyBefore + 1e-6),
            reason: '${r.subject}');
      }
    });

    test('the bullet loses almost all of it and the coupling loses a lot', () {
      final bullet = surviveRounds.firstWhere((r) => r.subject.contains('bullet'));
      expect(bullet.energyLeft, lessThan(2));
      final wagons = surviveRounds.firstWhere((r) => r.subject.contains('wagon'));
      expect(wagons.energyLeft, inInclusiveRange(30, 80));
    });
  });

  group('stick-or-bounce reads the sentence', () {
    test('the kind matches the number in the crash', () {
      for (final r in impactRounds) {
        switch (r.answer) {
          case Impact.plastic:
            expect(r.crash.e, 0, reason: r.subject);
            expect(r.equations, 1, reason: r.subject);
          case Impact.elastic:
            expect(r.crash.e, 1, reason: r.subject);
            expect(r.equations, 2, reason: r.subject);
          case Impact.between:
            expect(r.crash.e, greaterThan(0), reason: r.subject);
            expect(r.crash.e, lessThan(1), reason: r.subject);
            expect(r.equations, 2, reason: r.subject);
        }
      }
    });

    test('a sticking crash really does leave both at one speed', () {
      for (final r in impactRounds.where((r) => r.crash.sticks)) {
        expect(r.crash.afterA, closeTo(r.crash.afterB, 1e-9),
            reason: '${r.subject}: they stick but leave at different speeds');
      }
    });

    test('all three kinds are asked about', () {
      expect(impactRounds.map((r) => r.answer).toSet(), Impact.values.toSet());
    });
  });

  group('stretch-the-time keeps the areas honest', () {
    test('a round that says the areas match really does have them match', () {
      for (final r in pulseRounds) {
        if (!r.setting.contains('same')) continue;
        if (r.setting.contains('do NOT') || r.setting.contains('not')) continue;
        final areas = r.options.map((p) => p.impulse).toSet();
        expect(areas.length, 1,
            reason: '${r.subject}: the round claims equal impulses and the '
                'pulses do not agree');
      }
    });

    test('the answer is the only one that fits the question', () {
      for (final r in pulseRounds) {
        final chosen = r.options[r.answer];
        for (var i = 0; i < r.options.length; i++) {
          if (i == r.answer) continue;
          final other = r.options[i];
          final same = other.force == chosen.force &&
              other.seconds == chosen.seconds;
          expect(same, isFalse,
              reason: '${r.subject}: two pulses are identical');
        }
      }
    });

    test('the gentle rounds pick the longest and the harsh ones the tallest',
        () {
      for (final r in pulseRounds) {
        final chosen = r.options[r.answer];
        if (r.asked.contains('easiest') || r.asked.contains('drawing back')) {
          expect(chosen.seconds,
              r.options.map((p) => p.seconds).reduce((a, b) => a > b ? a : b),
              reason: '${r.subject}: the gentle one should last longest');
        }
        if (r.asked.contains('biggest force') ||
            r.asked.contains('pile driver')) {
          expect(chosen.force,
              r.options.map((p) => p.force).reduce((a, b) => a > b ? a : b),
              reason: '${r.subject}: the harsh one should be the tallest');
        }
      }
    });

    test('the round about a bigger impulse really has a bigger one', () {
      final bigger =
          pulseRounds.firstWhere((r) => r.asked.contains('changes the momentum'));
      final chosen = bigger.options[bigger.answer];
      for (var i = 0; i < bigger.options.length; i++) {
        if (i == bigger.answer) continue;
        expect(bigger.options[i].impulse, lessThan(chosen.impulse),
            reason: 'the answer should carry the biggest impulse');
      }
    });
  });
}
