import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/stress_or_twist_game.dart';
import 'package:mobile/features/games/torsion_figures.dart';
import 'package:mobile/features/games/which_area_twists_it_game.dart';
import 'package:mobile/features/games/which_j_is_it_game.dart';

/// Chapter seven, lesson two. The engine is held against the lesson's own
/// three worked answers and against the wrong answers it names, and the rounds
/// are held against the engine.
void main() {
  group('the engine reproduces the lesson it was built from', () {
    test('the fifty millimeter shaft is twenty point four megapascals', () {
      // Problem one: 50 mm solid, 500 N.m = 500,000 N.mm.
      const shaft = Shaft(outerD: 50, torque: 500000);
      expect(shaft.j, closeTo(613592, 1));
      expect(shaft.shearStress, closeTo(20.4, 0.05));

      // The lesson names two wrong answers. Taking the diameter for c doubles
      // it, and so does using the area moment I underneath, because I is half
      // of J and it is on the bottom. BOTH land on 40.7, and neither of them
      // lands on the 10.2 the lesson attributes to the second one: 10.2 is
      // half the right answer, which needs a J twice too big, not half.
      expect(500000 * 50 / shaft.j, closeTo(40.7, 0.05));
      expect(500000 * 25 / shaft.i, closeTo(40.7, 0.05));
      expect(shaft.shearStress / 2, closeTo(10.2, 0.05));
    });

    test('the forty millimeter shaft twists 0.0224 radians', () {
      // Problem two: 40 mm solid, 1.5 m, 300 N.m, G = 80 GPa.
      const shaft =
          Shaft(outerD: 40, length: 1500, torque: 300000, g: 80000);
      expect(shaft.j, closeTo(251327, 1));
      expect(shaft.twist, closeTo(0.0224, 0.0001));

      // And the three wrong answers it names: the area moment underneath
      // doubles the twist, a J twice too big halves it, and 1.28 is the same
      // answer in degrees wearing the label of radians.
      expect(300000 * 1500 / (80000 * shaft.i), closeTo(0.0448, 0.0001));
      expect(300000 * 1500 / (80000 * 2 * shaft.j), closeTo(0.0112, 0.0001));
      expect(shaft.twist * 180 / math.pi, closeTo(1.28, 0.01));
    });

    test('the hollow shaft carries 4.12 kilonewton meters', () {
      // Problem three: 80 mm outside, 60 mm bore, 60 MPa allowed.
      const shaft = Shaft(outerD: 80, innerD: 60);
      expect(shaft.j, closeTo(2748894, 1));

      double torqueAt(double allow, double c) => allow * shaft.j / c;
      expect(torqueAt(60, 40) / 1e6, closeTo(4.12, 0.01));

      // Its named wrong answers. Taking the outside DIAMETER for c halves the
      // capacity. The 5.50 comes from the INNER radius, 30, standing in for
      // the outer one, not from ignoring the bore as the lesson says: ignoring
      // the bore gives 6.03, which is not even on the list.
      expect(torqueAt(60, 80) / 1e6, closeTo(2.06, 0.01));
      expect(torqueAt(60, 30) / 1e6, closeTo(5.50, 0.01));
      const solid = Shaft(outerD: 80);
      expect(60 * solid.j / 40 / 1e6, closeTo(6.03, 0.01));
      expect(torqueAt(60, 20) / 1e6, closeTo(8.25, 0.01));
    });

    test('a bore takes out far less than it takes away', () {
      // The reason shafts are hollow, and the reason the fourth power matters:
      // a hole half the diameter removes a quarter of the metal and only a
      // sixteenth of the stiffness.
      const solid = Shaft(outerD: 80);
      const bored = Shaft(outerD: 80, innerD: 40);
      expect(bored.j / solid.j, closeTo(15 / 16, 0.001));
      final metal = 1 - math.pow(40 / 80, 2);
      expect(metal, closeTo(0.75, 0.001));
    });

    test('J is twice I, and stiffness is the twist formula turned around', () {
      const shaft = Shaft(outerD: 50, length: 1000, g: 80000);
      expect(shaft.j / shaft.i, closeTo(2, 1e-9));
      expect(shaft.stiffness * shaft.twist, closeTo(shaft.torque, 1));
    });
  });

  group('which-j-is-it asks about the lesson and nothing else', () {
    test('every round offers three expressions and one standing refusal', () {
      for (final r in jRounds) {
        expect(r.options.length, 3);
        expect(r.options.toSet().length, 3);
        expect(r.answer, greaterThanOrEqualTo(-1));
        expect(r.answer, lessThan(3));
      }
    });

    test('the only round with no right expression is the one that is not round',
        () {
      for (final r in jRounds) {
        expect(r.answer == -1, r.circular == false,
            reason: 'a formula fits a round section and only a round section');
      }
      expect(jRounds.where((r) => !r.circular).length, 1);
    });
  });

  group('stress-or-twist works its answers out rather than declaring them', () {
    test('nothing in the lesson moves the stress on its own', () {
      // c and J are locked together on a round shaft, so there is no change
      // that touches the stress and leaves the twist where it was. The item
      // offers no such choice, and this is the reason.
      for (final r in shaftRounds) {
        expect(Moves.values.contains(r.answer), isTrue);
      }
      expect(shaftRounds.map((r) => r.answer).toSet(),
          {Moves.twistOnly, Moves.both, Moves.neither});
    });

    test('the length and the shear modulus move the twist alone', () {
      const short = Shaft(outerD: 50, length: 1000);
      const long = Shaft(outerD: 50, length: 2000);
      expect(long.twist / short.twist, closeTo(2, 1e-9));
      expect(long.shearStress, closeTo(short.shearStress, 1e-9));

      const soft = Shaft(outerD: 50, g: 27000);
      expect(soft.shearStress, closeTo(short.shearStress, 1e-9));
      expect(soft.twist / short.twist, closeTo(80000 / 27000, 1e-9));
    });

    test('E is in none of it', () {
      const plain = Shaft(outerD: 50, e: 200000);
      const alloy = Shaft(outerD: 50, e: 320000);
      expect(alloy.twist, closeTo(plain.twist, 1e-12));
      expect(alloy.shearStress, closeTo(plain.shearStress, 1e-12));
    });

    test('reversing the torque changes neither size', () {
      const forward = Shaft(outerD: 50, torque: 500000);
      const back = Shaft(outerD: 50, torque: -500000);
      expect(back.shearStress, closeTo(forward.shearStress, 1e-9));
      expect(back.twist, closeTo(forward.twist, 1e-9));
    });
  });

  group('which-area-twists-it offers three different areas', () {
    test('every round shows the median area exactly once', () {
      for (final r in areaRounds) {
        expect(r.panels.where((p) => p == Region.median).length, 1);
        expect(r.panels.toSet().length, 3);
        expect(r.answer, isNot(-1));
      }
    });

    test('the right panel is not always in the same place', () {
      expect(areaRounds.map((r) => r.answer).toSet().length,
          greaterThanOrEqualTo(3));
    });

    test('the median area sits between the bore and the outside', () {
      for (final r in areaRounds) {
        final t = r.tube;
        final outer = t.shape == TubeShape.round
            ? math.pi * math.pow(t.width / 2, 2)
            : t.width * t.height;
        final inner = t.shape == TubeShape.round
            ? math.pi * math.pow(t.width / 2 - t.wall, 2)
            : (t.width - 2 * t.wall) * (t.height - 2 * t.wall);
        expect(t.medianArea, greaterThan(inner));
        expect(t.medianArea, lessThan(outer));
      }
    });

    test('the metal is a small fraction of what the formula wants', () {
      // The reason the wrong answer is worth a round: on a thin wall it is not
      // a few percent out, it is an order of magnitude.
      const thin = Tube(shape: TubeShape.round, width: 100, height: 100, wall: 4);
      expect(thin.thin, isTrue);
      expect(thin.materialArea / thin.medianArea, lessThan(0.2));

      const heavy =
          Tube(shape: TubeShape.round, width: 100, height: 100, wall: 16);
      expect(heavy.thin, isFalse);
    });

    test('the three outlines are far enough apart to be told apart', () {
      // The defect this catches: at true scale a thin wall is a pixel or two,
      // the outside face and the median line land on top of each other, and
      // the round cannot be answered by looking at it. Every round is checked,
      // because a round that fails this is unanswerable, not merely ugly.
      const box = Size(96, 118);
      for (final r in areaRounds) {
        final wall = TubePainter.drawnWall(r.tube, box);
        final scale = TubePainter.scaleFor(r.tube, box);
        expect(wall * scale / 2, greaterThan(5),
            reason: '${r.subject}: the median line has no daylight around it');
        // And the drawing never UNDERSTATES a wall, so a heavy section still
        // looks heavy.
        expect(wall, greaterThanOrEqualTo(r.tube.wall));

        // The other half of the same defect: on a long thin section the tube
        // is drawn narrow, the opened-up wall eats the bore, and what was a
        // tube reads as a solid bar. The hole has to stay a hole.
        final bore = TubePainter.outlineAt(r.tube, box, wall).getBounds();
        expect(math.min(bore.width, bore.height), greaterThan(20),
            reason: '${r.subject}: the bore has closed up');
      }
    });

    test('the three panels are drawn to one scale', () {
      // A comparison is a lie unless every panel measures the same. The three
      // panels of a row share one tube and one box, so the outside face must
      // land in exactly the same place in all three, and only the shading may
      // differ. Measured off the painter's own layout, not assumed.
      const tube =
          Tube(shape: TubeShape.square, width: 80, height: 80, wall: 4);
      const box = Size(96, 118);
      final wall = TubePainter.drawnWall(tube, box);
      final outside = TubePainter.outlineAt(tube, box, 0).getBounds();
      final median = TubePainter.outlineAt(tube, box, wall / 2).getBounds();
      final bore = TubePainter.outlineAt(tube, box, wall).getBounds();

      // In from the outside, and evenly spaced, because the median line is
      // halfway through the wall.
      expect(median.width, lessThan(outside.width));
      expect(bore.width, lessThan(median.width));
      expect(outside.width - median.width,
          closeTo(median.width - bore.width, 0.01));

      // And it fits the box it was given, whichever region is shaded.
      expect(outside.width, lessThanOrEqualTo(box.width));
      expect(outside.height, lessThanOrEqualTo(box.height));
      expect(outside.center.dx, closeTo(box.width / 2, 0.01));
      expect(outside.center.dy, closeTo(box.height / 2, 0.01));
    });
  });
}
