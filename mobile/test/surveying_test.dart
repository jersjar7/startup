import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/survey_figures.dart';
import 'package:mobile/features/games/find_it_on_the_plan_game.dart';
import 'package:mobile/features/games/which_rule_turns_it_game.dart';
import 'package:mobile/features/games/which_length_is_which_game.dart';
import 'package:mobile/features/games/level_figures.dart';
import 'package:mobile/features/games/higher_or_lower_game.dart';
import 'package:mobile/features/games/what_is_that_point_game.dart';
import 'package:mobile/features/games/which_run_is_allowed_more_game.dart';

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

  group('leveling reproduces the lesson', () {
    test('one setup: HI 101.52 and point A at 99.17', () {
      const run = Level(
        marks: [Stake(name: 'BM', elevation: 100), Stake(name: 'A', elevation: 99.17)],
        clearances: [1.52],
      );
      expect(run.sightAt(0), closeTo(101.52, 0.001));
      expect(run.readingAt(0, 0), closeTo(1.52, 0.001));
      expect(run.readingAt(0, 1), closeTo(2.35, 0.001));
      // Its named slips: the two readings swapped, both added, both taken
      // off.
      expect(100 - 1.52 + 2.35, closeTo(100.83, 0.001));
      expect(100 + 1.52 + 2.35, closeTo(103.87, 0.001));
      expect(100 - 1.52 - 2.35, closeTo(96.13, 0.001));
    });

    test('two setups: TP-1 at 251.44 and B at 254.70', () {
      const run = Level(
        marks: [
          Stake(name: 'BM-1', elevation: 250),
          Stake(name: 'TP-1', elevation: 251.44),
          Stake(name: 'B', elevation: 254.7),
        ],
        clearances: [3.18, 1.95],
      );
      expect(run.setups, 2);
      expect(run.sightAt(0), closeTo(254.62, 0.001));
      expect(run.readingAt(0, 0), closeTo(4.62, 0.001));
      expect(run.readingAt(0, 1), closeTo(3.18, 0.001));
      // Its named slip, now that it is a choice: the first height of
      // instrument carried into the second setup.
      expect(254.62 - 1.95, closeTo(252.67, 0.001));
    });

    test('the loop closure and its two named slips', () {
      const loop = Loop(miles: 4, constant: 0.05);
      expect(loop.allowable, closeTo(0.10, 0.0001));
      expect((499.97 - 500).abs(), closeTo(0.03, 0.0001));
      expect(0.05 / math.sqrt(4), closeTo(0.025, 0.0001));
      expect(0.05 * 4, closeTo(0.20, 0.0001));
    });
  });

  group('reading a pair of rods', () {
    test('the bigger reading is always the lower point', () {
      for (final r in sightRounds) {
        final first = r.level.readingAt(0, 0);
        final last = r.level.readingAt(0, 1);
        if (r.answer == Perch.lower) {
          expect(last, greaterThan(first), reason: r.subject);
        } else if (r.answer == Perch.higher) {
          expect(last, lessThan(first), reason: r.subject);
        } else {
          expect(last, closeTo(first, 0.001), reason: r.subject);
        }
      }
    });

    test('every round says the readings its drawing shows', () {
      for (final r in sightRounds) {
        for (final i in [0, 1]) {
          final shown = r.level.readingAt(0, i).toStringAsFixed(2);
          expect(r.setting.contains(shown), isTrue,
              reason: '${r.subject} wants $shown');
        }
      }
    });

    test('all three answers turn up', () {
      expect(sightRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('the ground is never drawn before the answer is in', () {
      // The painter takes showGround, and the item passes `answered`. If a
      // round could be read off the drawing it would not be a question.
      for (final r in sightRounds) {
        expect(r.level.marks.length, 2, reason: r.subject);
      }
    });
  });

  group('what each point is in the book', () {
    test('first is a backsight, last a foresight, the rest turning points',
        () {
      for (final r in runRounds) {
        final n = r.level.marks.length;
        if (r.asking == 0) {
          expect(r.answer, Peg.back, reason: r.subject);
        } else if (r.asking == n - 1) {
          expect(r.answer, Peg.fore, reason: r.subject);
        } else {
          expect(r.answer, Peg.turning, reason: r.subject);
        }
      }
    });

    test('a turning point is read from two setups and the ends from one', () {
      const run = Level(
        marks: [
          Stake(name: 'BM', elevation: 60),
          Stake(name: 'TP-1', elevation: 61.8),
          Stake(name: 'P', elevation: 62.4),
        ],
      );
      expect(run.setups, 2);
      expect(run.roleOf(0), Peg.back);
      expect(run.roleOf(1), Peg.turning);
      expect(run.roleOf(2), Peg.fore);
    });

    test('all three answers turn up, and turning points twice', () {
      final answers = runRounds.map((r) => r.answer).toList();
      expect(answers.toSet().length, 3);
      expect(answers.where((a) => a == Peg.turning).length,
          greaterThanOrEqualTo(2));
    });

    test('the runs are drawn inside the panel and spread across it', () {
      const size = Size(286, 220);
      for (final r in runRounds) {
        for (var i = 0; i < r.level.marks.length; i++) {
          final at = LevelPainter.spotOf(size, r.level, i);
          expect(at.dx, inInclusiveRange(10, size.width - 10),
              reason: r.subject);
          expect(at.dy, inInclusiveRange(10, size.height - 10),
              reason: r.subject);
        }
        // The sight line has to clear the rods it reads.
        for (var s = 0; s < r.level.setups; s++) {
          expect(r.level.readingAt(s, s), greaterThan(0), reason: r.subject);
          expect(r.level.readingAt(s, s + 1), greaterThan(0),
              reason: r.subject);
        }
      }
    });
  });

  group('what a loop is allowed to be out by', () {
    test('four times the distance is twice the allowance', () {
      const short = Loop(miles: 1, constant: 0.05);
      const long = Loop(miles: 4, constant: 0.05);
      expect(long.allowable / short.allowable, closeTo(2, 1e-9));
    });

    test('under a mile the root tightens it instead', () {
      expect(const Loop(miles: 0.25, constant: 0.05).allowable,
          closeTo(0.025, 1e-9));
    });

    test('a longer run can still be allowed less', () {
      final shortLoose = const Loop(miles: 1, constant: 0.05).allowable;
      final longTight = const Loop(miles: 4, constant: 0.024).allowable;
      expect(shortLoose, greaterThan(longTight));
      // And the round that says so is in the item.
      expect(
          slackRounds.any((r) =>
              r.answer == Roomier.left && r.right.miles > r.left.miles),
          isTrue);
    });

    test('every round answers with the bigger allowance', () {
      for (final r in slackRounds) {
        if (r.answer == Roomier.left) {
          expect(r.left.allowable, greaterThan(r.right.allowable),
              reason: r.subject);
        } else if (r.answer == Roomier.right) {
          expect(r.right.allowable, greaterThan(r.left.allowable),
              reason: r.subject);
        } else {
          expect(r.left.allowable, closeTo(r.right.allowable, 1e-9),
              reason: r.subject);
        }
      }
      expect(slackRounds.map((r) => r.answer).toSet().length, 3);
    });
  });
}
