import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/survey_figures.dart';
import 'package:mobile/features/games/find_it_on_the_plan_game.dart';
import 'package:mobile/features/games/which_rule_turns_it_game.dart';
import 'package:mobile/features/games/which_length_is_which_game.dart';

/// Chapter ten. Every engine here is held against the lesson's own answers
/// and against the wrong ones it names.
void main() {
  group('the lesson reproduces its own answers', () {
    test('N 52 E is azimuth 52, and its three named slips are the other '
        'three quadrant rules', () {
      expect(const Bearing(Quad.ne, 52).azimuth, 52);
      expect(const Bearing(Quad.se, 52).azimuth, 128);
      expect(const Bearing(Quad.sw, 52).azimuth, 232);
      expect(const Bearing(Quad.nw, 52).azimuth, 308);
    });

    test('the lesson\'s own warning: S 45 W is 225, not 315', () {
      expect(const Bearing(Quad.sw, 45).azimuth, 225);
      expect(const Bearing(Quad.nw, 45).azimuth, 315);
    });

    test('the slope shot is 247.56 across and 34.79 up', () {
      const shot = Sight(slope: 250, angle: 8);
      expect(shot.flat, closeTo(247.56, 0.01));
      expect(shot.rise, closeTo(34.79, 0.01));
      // Its named slip: dividing by the cosine, which returns a flat
      // distance longer than the slope distance and cannot be right.
      expect(250 / math.cos(8 * math.pi / 180), closeTo(252.46, 0.01));
    });

    test('the traverse closes one degree short', () {
      const angles = [108, 120, 95, 132, 84];
      expect(angles.reduce((a, b) => a + b), 539);
      expect((5 - 2) * 180, 540);
      expect(539 - 540, -1);
      // Its named slip, now that it is one: the misclosure spread over the
      // five angles rather than reported whole.
      expect(-1 / 5, closeTo(-0.2, 1e-9));
    });
  });

  group('bearings and azimuths', () {
    test('every quadrant lands in its own quarter of the turn', () {
      expect(const Bearing(Quad.ne, 30).azimuth, inInclusiveRange(0, 90));
      expect(const Bearing(Quad.se, 30).azimuth, inInclusiveRange(90, 180));
      expect(const Bearing(Quad.sw, 30).azimuth, inInclusiveRange(180, 270));
      expect(const Bearing(Quad.nw, 30).azimuth, inInclusiveRange(270, 360));
    });

    test('the rule follows the quadrant and nothing else', () {
      for (final angle in [5.0, 30.0, 52.0, 85.0]) {
        expect(Bearing(Quad.ne, angle).rule, Rule.same);
        expect(Bearing(Quad.se, angle).rule, Rule.fromHalf);
        expect(Bearing(Quad.sw, angle).rule, Rule.plusHalf);
        expect(Bearing(Quad.nw, angle).rule, Rule.fromWhole);
      }
    });

    test('the drawn heading agrees with the azimuth', () {
      // North is up the sheet and east is to the right, which is the whole
      // contract between the numbers and the drawing.
      expect(const Bearing(Quad.ne, 0).heading.dy, closeTo(-1, 1e-9));
      expect(const Bearing(Quad.ne, 90).heading.dx, closeTo(1, 1e-9));
      expect(const Bearing(Quad.se, 0).heading.dy, closeTo(1, 1e-9));
      expect(const Bearing(Quad.nw, 90).heading.dx, closeTo(-1, 1e-9));
      for (final q in Quad.values) {
        final h = Bearing(q, 40).heading;
        expect(h.dx.sign, q == Quad.ne || q == Quad.se ? 1 : -1);
        expect(h.dy.sign, q == Quad.ne || q == Quad.nw ? -1 : 1);
      }
    });

    test('a bearing says itself the way a surveyor writes it', () {
      expect(const Bearing(Quad.ne, 52).plain, 'N 52° E');
      expect(const Bearing(Quad.sw, 45).plain, 'S 45° W');
    });
  });

  group('finding a bearing on the plan', () {
    test('exactly one line in each round is the one asked for', () {
      for (final r in planRounds) {
        final matches = r.shots.where((s) =>
            s.bearing.quad == r.wanted.quad &&
            s.bearing.degrees == r.wanted.degrees);
        expect(matches.length, 1, reason: r.subject);
        expect(r.answer, greaterThanOrEqualTo(0), reason: r.subject);
        expect(r.shots.length, 4, reason: r.subject);
        expect(r.shots.map((s) => s.bearing.plain).toSet().length, 4,
            reason: r.subject);
      }
      expect(planRounds.map((r) => r.answer).toSet().length, greaterThan(2));
    });

    test('the angle alone never settles it: a decoy always shares it', () {
      for (final r in planRounds) {
        final sameAngle = r.shots
            .where((s) => s.bearing.degrees == r.wanted.degrees)
            .length;
        expect(sameAngle, greaterThan(1), reason: r.subject);
      }
    });

    test('two rounds need the angle read as well as the quadrant', () {
      final needAngle = planRounds.where((r) {
        final sameQuad =
            r.shots.where((s) => s.bearing.quad == r.wanted.quad).length;
        return sameQuad > 1;
      });
      expect(needAngle.length, greaterThanOrEqualTo(2));
    });

    test('all four quadrants are asked for across the rounds', () {
      expect(planRounds.map((r) => r.wanted.quad).toSet().length, 4);
    });

    test('the points sit well apart and inside the panel', () {
      const size = Size(286, 270);
      for (final r in planRounds) {
        for (var i = 0; i < r.shots.length; i++) {
          final at = RosePainter.spotOf(size, r.shots, i);
          expect(at.dx, inInclusiveRange(12, size.width - 12),
              reason: r.subject);
          expect(at.dy, inInclusiveRange(12, size.height - 12),
              reason: r.subject);
          for (var j = i + 1; j < r.shots.length; j++) {
            final gap = (at - RosePainter.spotOf(size, r.shots, j)).distance;
            expect(gap, greaterThan(34), reason: '${r.subject} $i and $j');
          }
        }
      }
    });
  });

  group('which rule turns it', () {
    test('every round answers with the rule its quadrant asks for', () {
      for (final r in azimuthRounds) {
        expect(r.answer, r.bearing.rule, reason: r.subject);
      }
    });

    test('all four rules turn up, and the warned one turns up twice', () {
      final answers = azimuthRounds.map((r) => r.answer).toList();
      expect(answers.toSet().length, 4);
      expect(answers.where((a) => a == Rule.plusHalf).length,
          greaterThanOrEqualTo(2));
    });

    test('the setting says the same bearing the drawing does', () {
      for (final r in azimuthRounds) {
        expect(r.setting.contains(r.bearing.plain), isTrue, reason: r.subject);
      }
    });
  });

  group('which length is which', () {
    test('the flat one is always shorter and the slope one always longest',
        () {
      for (final r in shotRounds) {
        expect(r.sight.flat.abs(), lessThan(r.sight.slope));
        expect(r.sight.rise.abs(), lessThan(r.sight.slope));
      }
    });

    test('a downhill shot drops and a level one would not', () {
      expect(const Sight(slope: 210, angle: -12).rise, lessThan(0));
      expect(const Sight(slope: 210, angle: -12).flat, greaterThan(0));
      expect(const Sight(slope: 100, angle: 0).flat, closeTo(100, 1e-9));
      expect(const Sight(slope: 100, angle: 0).rise, closeTo(0, 1e-9));
    });

    test('all three lengths get asked for, and the rounds move around', () {
      final answers = shotRounds.map((r) => r.answer).toList();
      expect(answers.toSet().length, 3);
      expect(shotRounds.any((r) => r.sight.angle < 0), isTrue);
    });

    test('the three tap spots sit apart and inside the panel', () {
      // The panel is narrower than the phone: the board pads both sides.
      const size = Size(286, 220);
      for (final r in shotRounds) {
        for (final a in Side3.values) {
          final at = SlopePainter.spotOf(size, r.sight, a);
          expect(at.dx, inInclusiveRange(8, size.width - 8), reason: r.subject);
          expect(at.dy, inInclusiveRange(8, size.height - 8), reason: r.subject);
          for (final b in Side3.values) {
            if (a.index >= b.index) continue;
            final gap = (at - SlopePainter.spotOf(size, r.sight, b)).distance;
            expect(gap, greaterThan(30), reason: '${r.subject} $a and $b');
          }
        }
      }
    });
  });
}
