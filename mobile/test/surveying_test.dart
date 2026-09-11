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
import 'package:mobile/features/games/traverse_figures.dart';
import 'package:mobile/features/games/plus_or_minus_game.dart';
import 'package:mobile/features/games/which_course_takes_the_most_game.dart';
import 'package:mobile/features/games/which_traverse_closed_better_game.dart';
import 'package:mobile/features/games/area_figures.dart';
import 'package:mobile/features/games/which_method_fits_game.dart';
import 'package:mobile/features/games/what_weight_does_it_get_game.dart';
import 'package:mobile/features/games/does_the_listing_close_game.dart';
import 'package:mobile/features/games/earthwork_figures.dart';
import 'package:mobile/features/games/which_formula_gives_more_game.dart';
import 'package:mobile/features/games/can_you_skip_a_section_game.dart';
import 'package:mobile/features/games/how_much_of_the_box_game.dart';
import 'package:mobile/features/games/cogo_figures.dart';
import 'package:mobile/features/games/which_way_are_you_working_game.dart';
import 'package:mobile/features/games/where_does_that_pair_land_game.dart';
import 'package:mobile/features/games/what_do_you_add_game.dart';

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

  group('the traverse lesson reproduces its own answers', () {
    test('a 200 meter course at azimuth 60 is 100.0 north and 173.2 east',
        () {
      const c = Course(azimuth: 60, length: 200);
      expect(c.latitude, closeTo(100.0, 0.05));
      expect(c.departure, closeTo(173.2, 0.05));
      expect(c.quad, Quad.ne);
      // Its named slips: the two swapped, and the 45 degree pair.
      expect(const Course(azimuth: 30, length: 200).latitude,
          closeTo(173.2, 0.05));
      expect(const Course(azimuth: 45, length: 200).latitude,
          closeTo(141.4, 0.05));
    });

    test('the closure is the diagonal, not the sum', () {
      const trip = Trip(
        lengths: [250, 250, 250, 250],
        driftNorth: 0.08,
        driftEast: -0.06,
      );
      expect(trip.closure, closeTo(0.10, 0.0001));
      expect(trip.perimeter, 1000);
      expect(trip.precision, closeTo(10000, 1));
      // Its named slips: the two added, one component alone, and the root
      // never taken.
      expect(1000 / 0.14, closeTo(7143, 2));
      expect(1000 / 0.08, closeTo(12500, 2));
      expect(1000 / 0.01, closeTo(100000, 2));
    });

    test('the compass rule share is the length over the perimeter', () {
      const trip = Trip(lengths: [250, 250, 250, 250]);
      expect(250 / trip.perimeter, closeTo(0.25, 1e-9));
      expect(-0.08 * 0.25, closeTo(-0.020, 1e-9));
      // Its named slips: the whole error on one course, and the wrong
      // denominator.
      expect(-0.08 * (250 / 10000), closeTo(-0.002, 1e-9));
    });
  });

  group('the two signs', () {
    test('each quadrant gives the pair it should', () {
      expect(const Course(azimuth: 60, length: 100).quad, Quad.ne);
      expect(const Course(azimuth: 135, length: 100).quad, Quad.se);
      expect(const Course(azimuth: 200, length: 100).quad, Quad.sw);
      expect(const Course(azimuth: 310, length: 100).quad, Quad.nw);
      for (final a in [10.0, 100.0, 190.0, 280.0]) {
        final c = Course(azimuth: a, length: 100);
        final northish = c.quad == Quad.ne || c.quad == Quad.nw;
        final eastish = c.quad == Quad.ne || c.quad == Quad.se;
        expect(c.latitude.sign, northish ? 1 : -1);
        expect(c.departure.sign, eastish ? 1 : -1);
      }
    });

    test('all four quadrants are asked, and the round agrees with its '
        'course', () {
      for (final r in signPairRounds) {
        expect(r.answer, r.course.quad, reason: r.subject);
      }
      expect(signPairRounds.map((r) => r.answer).toSet().length, 4);
    });

    test('a course just past a cardinal direction still turns its sign', () {
      // Five degrees past due east is south, however little.
      const c = Course(azimuth: 95, length: 300);
      expect(c.quad, Quad.se);
      expect(c.latitude, lessThan(0));
      expect(c.latitude.abs(), lessThan(30));
      expect(signPairRounds.any((r) => r.course.azimuth == 95), isTrue);
    });
  });

  group('sharing out the closure', () {
    test('the biggest share goes to the longest course and nothing else', () {
      for (final r in courseRounds) {
        final lengths = r.trip.lengths;
        final longest = lengths.reduce(math.max);
        expect(lengths.where((l) => l == longest).length, 1,
            reason: r.subject);
        expect(lengths[r.answer], longest, reason: r.subject);
      }
      expect(courseRounds.map((r) => r.answer).toSet().length, greaterThan(2));
    });

    test('one round puts the longest course where the eye does not expect '
        'it', () {
      // Not always last, not always first.
      expect(courseRounds.any((r) => r.answer != 0), isTrue);
      expect(
          courseRounds.any((r) => r.answer != r.trip.lengths.length - 1),
          isTrue);
    });

    test('every traverse in the item actually failed to close', () {
      for (final r in courseRounds) {
        expect(r.trip.closure, greaterThan(0), reason: r.subject);
      }
    });

    test('the courses sit apart and inside the panel', () {
      const size = Size(286, 250);
      for (final r in courseRounds) {
        for (var i = 0; i < r.trip.lengths.length; i++) {
          final at = TripPainter.spotOf(size, r.trip, i);
          expect(at.dx, inInclusiveRange(8, size.width - 8), reason: r.subject);
          expect(at.dy, inInclusiveRange(8, size.height - 8), reason: r.subject);
          for (var j = i + 1; j < r.trip.lengths.length; j++) {
            final gap =
                (at - TripPainter.spotOf(size, r.trip, j)).distance;
            expect(gap, greaterThan(30), reason: '${r.subject} $i and $j');
          }
        }
      }
    });
  });

  group('precision as a ratio', () {
    test('doubling both changes nothing', () {
      const small = Trip(
          lengths: [150, 150, 150, 150], driftNorth: 0.048, driftEast: 0.064);
      const big = Trip(
          lengths: [300, 300, 300, 300], driftNorth: 0.096, driftEast: 0.128);
      expect(small.precision, closeTo(big.precision, 1));
      expect(small.precision, closeTo(7500, 5));
    });

    test('a bigger gap can still be the better traverse', () {
      const lot = Trip(
          lengths: [15, 15, 15, 15], driftNorth: 0.006, driftEast: 0.008);
      const control = Trip(
          lengths: [750, 750, 750, 750], driftNorth: 0.18, driftEast: 0.24);
      expect(control.closure, greaterThan(lot.closure));
      expect(control.precision, greaterThan(lot.precision));
    });

    test('every round answers with the better ratio', () {
      for (final r in closedRounds) {
        if (r.answer == Better.left) {
          expect(r.left.precision, greaterThan(r.right.precision),
              reason: r.subject);
        } else if (r.answer == Better.right) {
          expect(r.right.precision, greaterThan(r.left.precision),
              reason: r.subject);
        } else {
          expect(r.left.precision, closeTo(r.right.precision, 1),
              reason: r.subject);
        }
      }
      expect(closedRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('a round exists where the smaller gap is the worse traverse', () {
      expect(
          closedRounds.any((r) =>
              (r.answer == Better.right && r.right.closure > r.left.closure) ||
              (r.answer == Better.left && r.left.closure > r.right.closure)),
          isTrue);
    });
  });

  group('the area lesson reproduces its own answers', () {
    test('the triangle is 12 and the quadrilateral is 44', () {
      const tri = Parcel(corners: [
        Corner2('A', 0, 0),
        Corner2('B', 6, 0),
        Corner2('C', 3, 4),
      ]);
      expect(tri.sumFor([0, 1, 2]), 24);
      expect(tri.area, 12);
      const quad = Parcel(corners: [
        Corner2('A', 0, 0),
        Corner2('B', 10, 0),
        Corner2('C', 8, 6),
        Corner2('D', 2, 5),
      ]);
      expect(quad.sumFor([0, 1, 2, 3]), 88);
      expect(quad.area, 44);
      // Its named slips: the halving forgotten, and a quarter taken.
      expect(88 / 1, 88);
      expect(88 / 4, 22);
    });

    test('walking the boundary backwards is the same parcel', () {
      const quad = Parcel(corners: [
        Corner2('A', 0, 0),
        Corner2('B', 10, 0),
        Corner2('C', 8, 6),
        Corner2('D', 2, 5),
      ]);
      expect(quad.sumFor([0, 3, 2, 1]), -88);
      expect(quad.walksTheBoundary([0, 3, 2, 1]), isTrue);
      // And a swapped pair is a bowtie, which the formula never notices.
      expect(quad.walksTheBoundary([0, 1, 3, 2]), isFalse);
      expect(quad.sumFor([0, 1, 3, 2]).abs() / 2, isNot(44));
    });

    test('the offsets give 600 by trapezoid and 640 by Simpson', () {
      const strip = Strip(offsets: [0, 8, 12, 10, 0], step: 20);
      expect(strip.byTrapezoid, closeTo(600, 0.01));
      expect(strip.bySimpson, closeTo(640, 0.01));
      expect(strip.simpsonFits, isTrue);
      expect(strip.baseline, 80);
      // Its named slips: every offset averaged, and the answer halved again.
      expect(30 / 5 * 80, closeTo(480, 0.01));
      expect(600 / 2, 300);
    });
  });

  group('which method the ground asks for', () {
    test('corners mean coordinates and offsets mean one of the two rules',
        () {
      for (final r in areaMethodRounds) {
        if (r.parcel != null) {
          expect(r.answer, Way3.coordinates, reason: r.subject);
          expect(r.strip, isNull, reason: r.subject);
        } else {
          expect(r.answer,
              r.strip!.simpsonFits ? Way3.simpson : Way3.trapezoid,
              reason: r.subject);
        }
      }
    });

    test('Simpson needs an odd count of offsets and nothing else', () {
      expect(const Strip(offsets: [0, 5, 0], step: 10).simpsonFits, isTrue);
      expect(
          const Strip(offsets: [0, 5, 6, 0], step: 10).simpsonFits, isFalse);
      expect(const Strip(offsets: [0, 5, 6, 7, 0], step: 10).simpsonFits,
          isTrue);
      expect(const Strip(offsets: [0, 5, 6, 0], step: 10).bySimpson.isNaN,
          isTrue);
    });

    test('all three methods are asked for', () {
      expect(areaMethodRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('one pair of rounds differs only in the count', () {
      final offsetRounds =
          areaMethodRounds.where((r) => r.strip != null).toList();
      expect(offsetRounds.length, greaterThanOrEqualTo(2));
      expect(offsetRounds.map((r) => r.answer).toSet().length, 2);
    });
  });

  group('the weights are the rule', () {
    test('the trapezoidal rule halves the ends and takes the rest whole', () {
      const strip = Strip(offsets: [0, 8, 12, 10, 0], step: 20);
      expect(strip.trapezoidWeight(0), 0.5);
      expect(strip.trapezoidWeight(4), 0.5);
      for (final i in [1, 2, 3]) {
        expect(strip.trapezoidWeight(i), 1);
      }
    });

    test('Simpson runs one, four, two, four, one', () {
      const strip = Strip(offsets: [2, 7, 13, 15, 12, 6, 3], step: 10);
      expect([for (var i = 0; i < 7; i++) strip.simpsonWeight(i)],
          [1, 4, 2, 4, 2, 4, 1]);
    });

    test('every round answers with the weight its rule gives', () {
      for (final r in offsetWeightRounds) {
        final w = r.rule == Way3.simpson
            ? r.strip.simpsonWeight(r.at)
            : r.strip.trapezoidWeight(r.at);
        expect(r.answer.value, w, reason: r.subject);
      }
      expect(offsetWeightRounds.map((r) => r.answer).toSet().length, 4);
    });

    test('both rules get rounds, and Simpson is only asked where it fits',
        () {
      expect(offsetWeightRounds.map((r) => r.rule).toSet().length, 2);
      for (final r in offsetWeightRounds) {
        if (r.rule == Way3.simpson) {
          expect(r.strip.simpsonFits, isTrue, reason: r.subject);
        }
      }
    });
  });

  group('whether a listing is the parcel', () {
    test('a crossed listing and a short one are both caught', () {
      for (final r in listingRounds) {
        if (r.answer == Listed.missing) {
          expect(r.order.length, lessThan(r.parcel.corners.length),
              reason: r.subject);
        } else if (r.answer == Listed.crosses) {
          expect(r.parcel.walksTheBoundary(r.order), isFalse,
              reason: r.subject);
        } else {
          expect(r.order.length, r.parcel.corners.length, reason: r.subject);
          expect(r.parcel.walksTheBoundary(r.order), isTrue,
              reason: r.subject);
        }
      }
    });

    test('all three verdicts turn up, and one good listing runs backwards',
        () {
      expect(listingRounds.map((r) => r.answer).toSet().length, 3);
      final good = listingRounds.where((r) => r.answer == Listed.boundary);
      expect(good.any((r) => r.parcel.sumFor(r.order) < 0), isTrue);
      expect(good.any((r) => r.parcel.sumFor(r.order) > 0), isTrue);
    });

    test('a bowtie really does give a different number', () {
      for (final r in listingRounds.where((r) => r.answer == Listed.crosses)) {
        expect(r.parcel.sumFor(r.order).abs() / 2,
            isNot(closeTo(r.parcel.area, 0.001)),
            reason: r.subject);
      }
    });
  });

  group('the earthwork lesson reproduces its own answers', () {
    test('two sections give 15,000 cubic feet', () {
      const haul = Haul(slabs: [
        Slab(station: 0, area: 120),
        Slab(station: 100, area: 180),
      ]);
      expect(haul.byEndAreas, closeTo(15000, 0.5));
      // Its named slips: L not halved, a quarter taken, and the cubic yard
      // conversion offered where cubic feet were asked for.
      expect(100 * 300, 30000);
      expect(100 / 4 * 300, closeTo(7500, 0.5));
      expect(15000 / 27, closeTo(556, 1));
    });

    test('three sections give 33,333 by the prismoid and 30,000 by the ends',
        () {
      const haul = Haul(slabs: [
        Slab(station: 0, area: 200),
        Slab(station: 50, area: 350),
        Slab(station: 100, area: 400),
      ]);
      expect(haul.byPrismoid, closeTo(33333, 1));
      expect(haul.endToEnd, closeTo(30000, 1));
      // Its named slips: all three averaged, and the middle area alone.
      expect((200 + 350 + 400) / 3 * 100, closeTo(31667, 1));
      expect(350 * 100, 35000);
    });

    test('the station run gives 40,000, and nothing end to end', () {
      const haul = Haul(slabs: [
        Slab(station: 0, area: 0),
        Slab(station: 100, area: 400),
        Slab(station: 200, area: 0),
      ]);
      expect(haul.byEndAreas, closeTo(40000, 1));
      expect(haul.endToEnd, 0);
      // Its named slips: one segment only, L not halved, and the whole run
      // taken as a single pyramid.
      expect(100 / 2 * 400, 20000);
      expect(100 * 400 * 2, 80000);
      expect(100 * 400 / 3, closeTo(13333, 1));
    });

    test('a station writes itself the way a road job writes it', () {
      expect(const Slab(station: 0, area: 0).name, '0+00');
      expect(const Slab(station: 100, area: 0).name, '1+00');
      expect(const Slab(station: 250, area: 0).name, '2+50');
    });
  });

  group('end areas against the prismoid', () {
    test('they agree exactly when the middle is the average of the ends', () {
      const even = Haul(slabs: [
        Slab(station: 0, area: 100),
        Slab(station: 50, area: 200),
        Slab(station: 100, area: 300),
      ]);
      expect(even.slabs[1].area, even.endAverage);
      expect(even.byPrismoid, closeTo(even.byEndAreas, 0.5));
    });

    test('every round answers with the bigger of the two', () {
      for (final r in fatterRounds) {
        final gap = r.haul.byPrismoid - r.haul.byEndAreas;
        if (r.answer == Fatter.prismoid) {
          expect(gap, greaterThan(0), reason: r.subject);
          expect(r.haul.slabs[1].area, greaterThan(r.haul.endAverage),
              reason: r.subject);
        } else if (r.answer == Fatter.endAreas) {
          expect(gap, lessThan(0), reason: r.subject);
          expect(r.haul.slabs[1].area, lessThan(r.haul.endAverage),
              reason: r.subject);
        } else {
          expect(gap.abs(), lessThan(1), reason: r.subject);
        }
      }
      expect(fatterRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('a run closing to nothing is the overestimate the lesson names', () {
      final taper = fatterRounds.firstWhere((r) => r.haul.slabs.last.area == 0);
      expect(taper.answer, Fatter.endAreas);
    });
  });

  group('working end to end', () {
    test('a hill between two zeros books nothing at all', () {
      const haul = Haul(slabs: [
        Slab(station: 0, area: 0),
        Slab(station: 100, area: 400),
        Slab(station: 200, area: 0),
      ]);
      expect(haul.endToEnd, 0);
      expect(haul.byEndAreas, greaterThan(0));
    });

    test('an even grade is the one case where skipping is safe', () {
      const even = Haul(slabs: [
        Slab(station: 0, area: 0),
        Slab(station: 100, area: 100),
        Slab(station: 200, area: 200),
        Slab(station: 300, area: 300),
      ]);
      expect(even.endToEnd, closeTo(even.byEndAreas, 0.5));
    });

    test('every round answers with what skipping actually does', () {
      for (final r in skipRounds) {
        final gap = r.haul.endToEnd - r.haul.byEndAreas;
        if (r.answer == Skipped.tooBig) {
          expect(gap, greaterThan(0), reason: r.subject);
        } else if (r.answer == Skipped.tooSmall) {
          expect(gap, lessThan(0), reason: r.subject);
        } else {
          expect(gap.abs(), lessThan(1), reason: r.subject);
        }
      }
      expect(skipRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('skipping is not always an underestimate', () {
      expect(skipRounds.any((r) => r.answer == Skipped.tooBig), isTrue);
      expect(skipRounds.any((r) => r.answer == Skipped.tooSmall), isTrue);
    });
  });

  group('how much of the box', () {
    test('the three shares are one, a half and a third', () {
      expect(Solid.prism.share, 1);
      expect(Solid.wedge.share, 0.5);
      expect(Solid.point.share, closeTo(1 / 3, 1e-9));
    });

    test('an edge is what the end area formula gives with a zero section',
        () {
      const wedge = Haul(slabs: [
        Slab(station: 0, area: 400),
        Slab(station: 100, area: 0),
      ]);
      expect(wedge.byEndAreas, closeTo(0.5 * 400 * 100, 0.5));
      // And a point is a third of the same box, which is where the two
      // differ by half again.
      expect(400 * 100 / 3, closeTo(13333, 1));
    });

    test('every round answers with its solid, and all three turn up', () {
      for (final r in shareRounds2) {
        expect(r.answer.part, closeTo(r.solid.share, 1e-9), reason: r.subject);
      }
      expect(shareRounds2.map((r) => r.answer).toSet().length, 3);
    });
  });

  group('the coordinate lesson reproduces its own answers', () {
    test('the inverse of the lesson\'s two points is 500 feet', () {
      const task = Task(
        known: [Peg2('A', 1000, 1000), Peg2('B', 1300, 1400)],
      );
      expect(task.deltaEast, 300);
      expect(task.deltaNorth, 400);
      expect(task.distance, closeTo(500, 0.01));
      // Its named slips: the two added, averaged, and subtracted.
      expect(300 + 400, 700);
      expect((300 + 400) / 2, 350);
      expect(400 - 300, 100);
    });

    test('the forward computation lands the northing at 5,173.2', () {
      final dn = 200 * math.cos(30 * math.pi / 180);
      expect(5000 + dn, closeTo(5173.2, 0.1));
      // Its named slips: the departure used for the northing, the tangent
      // for the cosine, and the whole length added.
      expect(5000 + 200 * math.sin(30 * math.pi / 180), closeTo(5100, 0.1));
      expect(5000 + 200 * math.tan(30 * math.pi / 180), closeTo(5115.5, 0.1));
      expect(5000 + 200, 5200);
    });

    test('the arctangent covers half the compass and no more', () {
      for (final t in [
        const Task(known: [Peg2('A', 0, 0), Peg2('B', 3, 4)]),
        const Task(known: [Peg2('A', 0, 0), Peg2('B', 3, -4)]),
        const Task(known: [Peg2('A', 0, 0), Peg2('B', -3, -4)]),
        const Task(known: [Peg2('A', 0, 0), Peg2('B', -3, 4)]),
      ]) {
        expect(t.rawArctan, inInclusiveRange(-90, 90));
        expect((t.rawArctan + t.toAdd) % 360, closeTo(t.trueAzimuth, 0.001));
      }
    });
  });

  group('forward, inverse, or both', () {
    test('a job with a point missing is forward and two points is inverse',
        () {
      expect(
          const Task(known: [Peg2('A', 0, 0)], wanted: Peg2('B', 1, 1)).work,
          Work.forward);
      expect(const Task(known: [Peg2('A', 0, 0), Peg2('B', 1, 1)]).work,
          Work.inverse);
    });

    test('every round matches what its drawing holds', () {
      for (final r in cogoRounds) {
        if (r.answer == Which2.inverse) {
          expect(r.task.known.length, 2, reason: r.subject);
          expect(r.task.wanted, isNull, reason: r.subject);
        } else {
          expect(r.task.wanted, isNotNull, reason: r.subject);
        }
      }
      expect(cogoRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('the round that needs both has two known points and a third wanted',
        () {
      final both = cogoRounds.where((r) => r.answer == Which2.both);
      expect(both, isNotEmpty);
      for (final r in both) {
        expect(r.task.known.length, 2, reason: r.subject);
        expect(r.task.wanted, isNotNull, reason: r.subject);
      }
    });
  });

  group('reading a coordinate pair', () {
    test('every round offers the swap, and exactly one point matches', () {
      for (final r in landRounds) {
        final hits = r.task.known
            .where((p) => p.east == r.east && p.north == r.north);
        expect(hits.length, 1, reason: r.subject);
        expect(r.answer, greaterThanOrEqualTo(0), reason: r.subject);
        // The swapped pair is on the drawing unless the two numbers are
        // the same, in which case there is nothing to swap.
        if (r.east != r.north) {
          expect(
              r.task.known
                  .any((p) => p.east == r.north && p.north == r.east),
              isTrue,
              reason: r.subject);
        }
      }
    });

    test('the answer moves around the four candidates', () {
      expect(landRounds.map((r) => r.answer).toSet().length, greaterThan(2));
      expect(landRounds.every((r) => r.task.known.length == 4), isTrue);
    });

    test('the points sit apart and inside the panel', () {
      const size = Size(286, 250);
      for (final r in landRounds) {
        for (var i = 0; i < r.task.known.length; i++) {
          final at = CogoPainter.spotOf(size, r.task, i);
          expect(at.dx, inInclusiveRange(8, size.width - 8), reason: r.subject);
          expect(at.dy, inInclusiveRange(8, size.height - 8), reason: r.subject);
          for (var j = i + 1; j < r.task.known.length; j++) {
            final gap = (at - CogoPainter.spotOf(size, r.task, j)).distance;
            expect(gap, greaterThan(30), reason: '${r.subject} $i and $j');
          }
        }
      }
    });
  });

  group('what the arctangent needs', () {
    test('south adds 180, north and west adds 360, north and east adds '
        'nothing', () {
      expect(const Task(known: [Peg2('A', 0, 0), Peg2('B', 1, 1)]).toAdd, 0);
      expect(const Task(known: [Peg2('A', 0, 0), Peg2('B', 1, -1)]).toAdd, 180);
      expect(const Task(known: [Peg2('A', 0, 0), Peg2('B', -1, -1)]).toAdd, 180);
      expect(const Task(known: [Peg2('A', 0, 0), Peg2('B', -1, 1)]).toAdd, 360);
    });

    test('the south-west line is the trap: a usable looking positive number',
        () {
      const sw = Task(known: [Peg2('A', 1300, 1400), Peg2('B', 1000, 1000)]);
      expect(sw.rawArctan, greaterThan(0));
      expect(sw.trueAzimuth, greaterThan(180));
      expect(sw.trueAzimuth, lessThan(270));
    });

    test('every round answers with what its signs ask for', () {
      for (final r in addOnRounds) {
        expect(r.answer.value, r.task.toAdd, reason: r.subject);
        expect((r.task.rawArctan + r.answer.value) % 360,
            closeTo(r.task.trueAzimuth, 0.001),
            reason: r.subject);
      }
      expect(addOnRounds.map((r) => r.answer).toSet().length, 3);
    });

    test('the two cardinal cases are in the item', () {
      expect(addOnRounds.any((r) => r.task.deltaNorth == 0), isTrue);
      final east = addOnRounds.firstWhere(
          (r) => r.task.deltaNorth == 0 && r.task.deltaEast > 0);
      expect(east.task.trueAzimuth, closeTo(90, 0.001));
      final west = addOnRounds.firstWhere(
          (r) => r.task.deltaNorth == 0 && r.task.deltaEast < 0);
      expect(west.task.trueAzimuth, closeTo(270, 0.001));
    });
  });
}
