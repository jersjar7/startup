import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/kinetics_figures.dart';
import 'package:mobile/features/games/mass_or_weight_game.dart';
import 'package:mobile/features/games/push_it_or_spin_it_game.dart';
import 'package:mobile/features/games/which_piece_drives_it_game.dart';

/// Chapter six, lesson three. The engine is held against the lesson's own
/// three answers and against the wrong ones it names.
void main() {
  group('the engine reproduces the lesson it was built from', () {
    test('the crate accelerates at 3 meters a second squared', () {
      // Problem one: 80 kg, 240 N, no friction.
      expect(240 / 80, closeTo(3, 1e-9));
      // Its named wrong answers: the division upside down, and the force
      // turned into a weight it never was.
      expect(80 / 240, closeTo(0.33, 0.005));
      expect(240 * 9.81 / 80, closeTo(29.4, 0.05));
    });

    test('the block on the slope accelerates at 4.91', () {
      // Problem two: 500 N block, 30 degrees, frictionless.
      const block = Slope2(degrees: 30, weight: 500);
      expect(block.mass, closeTo(50.97, 0.01));
      expect(block.along, closeTo(250, 0.01));
      expect(block.accel, closeTo(4.905, 0.005));

      // And its named wrong answers: the cosine piece, and the force reported
      // as though it were an acceleration.
      expect(block.wrongAccel, closeTo(8.50, 0.005));
      expect(block.along, closeTo(250, 0.01));
    });

    test('the disk spins up at 10 radians a second squared', () {
      // Problem three: 10 kg, 0.3 m, 15 N at the rim.
      final i = 0.5 * 10 * 0.3 * 0.3;
      expect(i, closeTo(0.45, 1e-9));
      expect(15 * 0.3 / i, closeTo(10, 1e-9));
      // Its three named wrong answers, each a step skipped.
      expect(15 * 0.3 / (10 * 0.3 * 0.3), closeTo(5, 1e-9));
      expect(15 / i, closeTo(33.3, 0.05));
      expect(15 * 0.3 / 0.09, closeTo(50, 1e-9));
    });
  });

  group('what a slope does to a weight', () {
    test('the two pieces always come back to the whole weight', () {
      for (final degrees in [15.0, 30.0, 45.0, 55.0]) {
        final slope = Slope2(degrees: degrees, weight: 400);
        final together = math.sqrt(
            slope.along * slope.along + slope.square * slope.square);
        expect(together, closeTo(400, 1e-6),
            reason: 'at $degrees the pieces do not add back up');
      }
    });

    test('they cross over at forty five degrees', () {
      const gentle = Slope2(degrees: 15, weight: 400);
      const steep = Slope2(degrees: 55, weight: 400);
      const even = Slope2(degrees: 45, weight: 400);
      expect(gentle.square, greaterThan(gentle.along));
      expect(steep.along, greaterThan(steep.square));
      expect(even.along, closeTo(even.square, 1e-6));
    });

    test('the acceleration does not depend on the weight', () {
      const light = Slope2(degrees: 30, weight: 50);
      const heavy = Slope2(degrees: 30, weight: 5000);
      expect(light.accel, closeTo(heavy.accel, 1e-12));
      expect(light.accel, closeTo(9.81 * 0.5, 1e-9));
    });
  });

  group('mass-or-weight reads the sentence', () {
    test('every round says what it was given and what it wants', () {
      for (final r in unitRounds) {
        expect(r.setting, isNotEmpty);
        expect(r.wanted, isNotEmpty);
      }
    });

    test('all three steps are used, and more than once between them', () {
      expect(unitRounds.map((r) => r.answer).toSet(), Prep.values.toSet());
      expect(unitRounds.length, 6);
    });

    test('the rounds that need no conversion really need none', () {
      // A mass wanted where a mass was given, or a force where a force was
      // given. The wording of the round has to carry that.
      for (final r in unitRounds.where((r) => r.answer == Prep.useAsIs)) {
        final givenMass = r.setting.contains('kilogram');
        final wantsMass = r.wanted.contains('MASS');
        expect(givenMass, wantsMass,
            reason: '${r.subject}: it asks for the other one');
      }
    });

    test('the US units round is still the same question', () {
      final us = unitRounds.firstWhere((r) => r.setting.contains('pound'));
      expect(us.answer, Prep.divideByG);
      expect(us.why.contains('thirty two point two'), isTrue,
          reason: 'the US round should say which g it uses');
    });
  });

  group('which-piece-drives-it draws arrows where it says', () {
    const size = Size(312, 230);

    test('the two pieces are drawn square to each other', () {
      for (final r in slopeRounds) {
        final (seat, _, _) = SlopePainter2.layout(r.slope, size);
        final along = SlopePainter2.headOf(r.slope, size, Arrow.along) - seat;
        final square = SlopePainter2.headOf(r.slope, size, Arrow.square) - seat;
        expect(along.dx * square.dx + along.dy * square.dy, closeTo(0, 0.01),
            reason: '${r.subject}: the two pieces are not at right angles');
      }
    });

    test('the normal force is the square piece the other way', () {
      for (final r in slopeRounds) {
        final (seat, _, _) = SlopePainter2.layout(r.slope, size);
        final square = SlopePainter2.headOf(r.slope, size, Arrow.square) - seat;
        final normal = SlopePainter2.headOf(r.slope, size, Arrow.normal) - seat;
        expect((square + normal).distance, lessThan(0.01),
            reason: '${r.subject}: the surface is not answering the press');
      }
    });

    test('the arrows are far enough apart to tap', () {
      for (final r in slopeRounds) {
        for (var i = 0; i < r.arrows.length; i++) {
          for (var j = i + 1; j < r.arrows.length; j++) {
            final a = SlopePainter2.headOf(r.slope, size, r.arrows[i]);
            final b = SlopePainter2.headOf(r.slope, size, r.arrows[j]);
            expect((a - b).distance, greaterThan(30),
                reason: '${r.subject}: ${r.arrows[i].name} and '
                    '${r.arrows[j].name} are on top of each other');
          }
        }
      }
    });

    test('a round asking which piece is bigger really has a bigger one', () {
      for (final r in slopeRounds.where((r) => r.asked.contains('LARGER'))) {
        final bigger = r.slope.along > r.slope.square ? Arrow.along : Arrow.square;
        expect(r.answer, bigger, reason: '${r.subject}');
        final ratio = r.slope.along > r.slope.square
            ? r.slope.along / r.slope.square
            : r.slope.square / r.slope.along;
        expect(ratio, greaterThan(1.3),
            reason: '${r.subject}: the two are too close to call by eye');
      }
    });
  });

  group('push-it-or-spin-it is decided by the setup', () {
    test('an axle means no moving off', () {
      for (final r in shoveRounds.where((r) => r.pushed.held == Held2.axle)) {
        expect(r.answer, Needs2.moment, reason: '${r.subject}');
      }
    });

    test('a force through the middle spins nothing', () {
      for (final r
          in shoveRounds.where((r) => r.pushed.lands == Lands.middle)) {
        expect(r.answer, isNot(Needs2.both), reason: '${r.subject}');
      }
    });

    test('free and off center needs both', () {
      for (final r in shoveRounds.where((r) =>
          r.pushed.held != Held2.axle && r.pushed.lands != Lands.middle)) {
        expect(r.answer, Needs2.both, reason: '${r.subject}');
      }
    });

    test('all three answers are used', () {
      expect(shoveRounds.map((r) => r.answer).toSet(), Needs2.values.toSet());
    });
  });
}
