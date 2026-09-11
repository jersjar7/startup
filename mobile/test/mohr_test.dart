import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/is_r_the_worst_game.dart';
import 'package:mobile/features/games/mohr_figures.dart';
import 'package:mobile/features/games/read_the_circle_game.dart';
import 'package:mobile/features/games/which_circle_is_it_game.dart';

/// Chapter seven, lesson eight. The circle is held against the lesson's own
/// three answers and against the wrong ones it names.
void main() {
  group('the circle reproduces the lesson it was built from', () {
    test('with no shear, the stresses given are already the principal ones',
        () {
      // Problem one: 80 tension, 20 compression, no shear.
      const s = Stress(x: 80, y: -20, xy: 0);
      expect(s.center, closeTo(30, 1e-9));
      expect(s.radius, closeTo(50, 1e-9));
      expect(s.s1, closeTo(80, 1e-9));
      expect(s.s2, closeTo(-20, 1e-9));

      // Its named wrong answers: the center on its own, and the radius on its
      // own.
      expect(s.center, closeTo(30, 1e-9));
      expect([s.radius, -s.radius], [50, -50]);
    });

    test('the three four five triangle hiding in the second problem', () {
      // Problem two: 60, 0, shear 40.
      const s = Stress(x: 60, y: 0, xy: 40);
      expect(s.center, closeTo(30, 1e-9));
      expect(s.radius, closeTo(50, 1e-9));
      expect(s.s1, closeTo(80, 1e-9));

      // The named wrong answers: the radius reported as a principal stress,
      // the normal stress on its own, and the two simply added.
      expect(s.radius, closeTo(50, 1e-9));
      expect(s.x, closeTo(60, 1e-9));
      expect(s.x + s.xy, closeTo(100, 1e-9));
      // And the lesson's claim that the shear always raises the largest
      // principal stress above the normal stress it started from.
      expect(s.s1, greaterThan(s.x));
    });

    test('the worst shear is not always the radius', () {
      // Problem three: 120, 40, shear 30. The whole circle sits in tension.
      const s = Stress(x: 120, y: 40, xy: 30);
      expect(s.center, closeTo(80, 1e-9));
      expect(s.radius, closeTo(50, 1e-9));
      expect(s.s1, closeTo(130, 1e-9));
      expect(s.s2, closeTo(30, 1e-9));
      expect(s.clearOfZero, isTrue);
      expect(s.absoluteShear, closeTo(65, 1e-9));

      // The named wrong answers: the in-plane radius, and the half difference
      // of the normal stresses with the shear left out.
      expect(s.inPlaneShear, closeTo(50, 1e-9));
      expect((s.x - s.y) / 2, closeTo(40, 1e-9));
      expect(s.center, closeTo(80, 1e-9));
    });
  });

  group('what the circle knows', () {
    test('a circle that straddles zero has its worst shear in the plane', () {
      const s = Stress(x: 80, y: -20, xy: 0);
      expect(s.clearOfZero, isFalse);
      expect(s.absoluteShear, closeTo(s.inPlaneShear, 1e-9));
    });

    test('a circle wholly in compression is worst against zero too', () {
      const s = Stress(x: -120, y: -40, xy: 30);
      expect(s.s1, lessThan(0));
      expect(s.clearOfZero, isTrue);
      expect(s.absoluteShear, closeTo(s.s2.abs() / 2, 1e-9));
      expect(s.absoluteShear, greaterThan(s.inPlaneShear));
    });

    test('equal stresses both ways is a single point, with no shear anywhere',
        () {
      const s = Stress(x: 50, y: 50, xy: 0);
      expect(s.radius, closeTo(0, 1e-12));
      expect(s.s1, closeTo(50, 1e-9));
      expect(s.s2, closeTo(50, 1e-9));
      expect(s.inPlaneShear, closeTo(0, 1e-12));
      // And yet the worst shear at the point is not zero, because the third
      // principal stress is still zero and the spread is still 50.
      expect(s.absoluteShear, closeTo(25, 1e-9));
    });

    test('pure shear is a circle centered on the origin', () {
      const s = Stress(x: 0, y: 0, xy: 40);
      expect(s.center, closeTo(0, 1e-12));
      expect(s.radius, closeTo(40, 1e-9));
      expect(s.s1, closeTo(40, 1e-9));
      expect(s.s2, closeTo(-40, 1e-9));
      // Which is the fact behind a brittle shaft in torsion cracking on a
      // spiral: pure shear is tension at forty five degrees.
      expect(s.clearOfZero, isFalse);
    });

    test('uniaxial tension runs from zero out to the stress applied', () {
      const s = Stress(x: 60, y: 0, xy: 0);
      expect(s.s2, closeTo(0, 1e-12));
      expect(s.s1, closeTo(60, 1e-9));
      expect(s.radius, closeTo(30, 1e-9));
      // The edge case where the in-plane and the absolute worst shear agree.
      expect(s.absoluteShear, closeTo(s.inPlaneShear, 1e-9));
    });

    test('the face the stresses came from sits on the circle', () {
      const s = Stress(x: 120, y: 40, xy: 30);
      final gap = (s.xFace - Offset(s.center, 0)).distance;
      expect(gap, closeTo(s.radius, 1e-9));
      final other = (s.yFace - Offset(s.center, 0)).distance;
      expect(other, closeTo(s.radius, 1e-9));
      // The two faces are opposite ends of a diameter, which is why the
      // circle is drawn through them.
      expect((s.xFace + s.yFace) / 2, Offset(s.center, 0));
    });
  });

  group('the drawing agrees with the arithmetic', () {
    const size = Size(300, 200);

    test('a circle is drawn as a circle, not an ellipse', () {
      const s = Stress(x: 120, y: 40, xy: 30);
      final span = Window.over([s]);
      final middle = MohrPainter.at(size, span, Offset(s.center, 0));
      final right = MohrPainter.spotAt(s, size, span, Spot.s1);
      final top = MohrPainter.spotAt(s, size, span, Spot.topShear);
      expect((right - middle).distance, closeTo((top - middle).distance, 0.01),
          reason: 'the two axes are drawn to different scales');
    });

    test('every marked place lands on the circle it belongs to', () {
      const s = Stress(x: 60, y: 0, xy: 40);
      final span = Window.over([s]);
      final middle = MohrPainter.at(size, span, Offset(s.center, 0));
      final r = (MohrPainter.spotAt(s, size, span, Spot.s1) - middle).distance;
      for (final spot in [Spot.s1, Spot.s2, Spot.topShear, Spot.xFace]) {
        final p = MohrPainter.spotAt(s, size, span, spot);
        expect((p - middle).distance, closeTo(r, 0.01),
            reason: '${spot.name} is drawn off the circle');
      }
      // The center is the one marked place that is NOT on it.
      expect(
        (MohrPainter.spotAt(s, size, span, Spot.center) - middle).distance,
        closeTo(0, 1e-9),
      );
    });

    test('a tap on a mark picks that mark', () {
      const s = Stress(x: 60, y: 0, xy: 40);
      final span = Window.over([s]);
      for (final spot in Spot.values) {
        final at = MohrPainter.spotAt(s, size, span, spot);
        expect(MohrPainter.nearest(s, size, span, Spot.values, at), spot);
      }
    });

    test('the marks stay clear of the axis label and of each other', () {
      // A round whose marks are closer together than a thumb is a coin toss.
      const s = Stress(x: 120, y: 40, xy: 30);
      final span = Window.over([s]);
      const spots = [Spot.s1, Spot.s2, Spot.center, Spot.topShear, Spot.xFace];
      for (var i = 0; i < spots.length; i++) {
        for (var j = i + 1; j < spots.length; j++) {
          final a = MohrPainter.spotAt(s, size, span, spots[i]);
          final b = MohrPainter.spotAt(s, size, span, spots[j]);
          expect((a - b).distance, greaterThan(24),
              reason: '${spots[i].name} and ${spots[j].name} overlap');
        }
      }
    });

    test('the whole circle fits inside the box it is drawn in', () {
      const s = Stress(x: 120, y: 40, xy: 30);
      final span = Window.over([s]);
      final middle = MohrPainter.at(size, span, Offset(s.center, 0));
      final r = (MohrPainter.spotAt(s, size, span, Spot.s1) - middle).distance;
      expect(middle.dx - r, greaterThan(0));
      expect(middle.dx + r, lessThan(size.width));
      expect(middle.dy - r, greaterThan(0));
      expect(middle.dy + r, lessThan(size.height));
    });
  });

  group('read-the-circle asks for places that are really there', () {
    const size = Size(312, 210);

    test('every round has a single place that answers it', () {
      for (final r in mohrRounds) {
        expect(MohrRound.spots.contains(r.answer), isTrue);
        expect(r.stress.radius, greaterThan(0),
            reason: '${r.subject}: a point circle has no places to tap');
      }
    });

    test('the marks never land on top of each other', () {
      for (final r in mohrRounds) {
        final window = Window.over([r.stress]);
        for (var i = 0; i < MohrRound.spots.length; i++) {
          for (var j = i + 1; j < MohrRound.spots.length; j++) {
            final a =
                MohrPainter.spotAt(r.stress, size, window, MohrRound.spots[i]);
            final b =
                MohrPainter.spotAt(r.stress, size, window, MohrRound.spots[j]);
            expect((a - b).distance, greaterThan(22),
                reason: '${r.subject}: ${MohrRound.spots[i].name} and '
                    '${MohrRound.spots[j].name} are on top of each other');
          }
        }
      }
    });

    test('the round about compression really is all compression', () {
      // The point of that round is that sigma one is the rightmost mark even
      // when every stress in the picture is a squeeze.
      final all = mohrRounds.where((r) => r.stress.s1 < 0);
      expect(all, isNotEmpty);
      for (final r in all) {
        expect(r.stress.s2, lessThan(r.stress.s1));
        expect(r.answer, Spot.s1);
      }
    });

    test('every kind of place gets asked for', () {
      expect(mohrRounds.map((r) => r.answer).toSet().length,
          greaterThanOrEqualTo(4));
    });
  });

  group('which-circle-is-it draws circles that differ', () {
    test('the right one is the real circle and the others are not', () {
      for (final r in madeRounds) {
        final right = r.circleFor(Built.right);
        expect(right.center, closeTo(r.stress.center, 1e-9));
        expect(right.radius, closeTo(r.stress.radius, 1e-9));
        for (final option in r.options) {
          if (option == Built.right) continue;
          final wrong = r.circleFor(option);
          final sameCenter = (wrong.center - right.center).abs() < 1e-6;
          final sameRadius = (wrong.radius - right.radius).abs() < 1e-6;
          expect(sameCenter && sameRadius, isFalse,
              reason: '${r.subject}: ${option.name} draws the right circle');
        }
      }
    });

    test('no two candidates in a round draw the same circle', () {
      for (final r in madeRounds) {
        final seen = <String>{};
        for (final option in r.options) {
          final c = r.circleFor(option);
          final key = '${c.center.toStringAsFixed(3)}'
              '|${c.radius.toStringAsFixed(3)}';
          expect(seen.add(key), isTrue,
              reason: '${r.subject}: two candidates are the same circle');
        }
      }
    });

    test('the three special cases are all in the item', () {
      final pureShear = madeRounds.where((r) =>
          r.stress.center.abs() < 1e-9 && r.stress.radius > 0);
      final uniaxial = madeRounds.where((r) =>
          r.stress.xy == 0 &&
          (r.stress.x == 0 || r.stress.y == 0) &&
          r.stress.radius > 0);
      final point = madeRounds.where((r) => r.stress.radius < 1e-9);
      expect(pureShear, isNotEmpty, reason: 'pure shear is not shown');
      expect(uniaxial, isNotEmpty, reason: 'uniaxial tension is not shown');
      expect(point, isNotEmpty, reason: 'the point circle is not shown');
    });

    test('a shared window keeps the three honest', () {
      // Three circles on three scales would be three unrelated pictures.
      const size = Size(312, 118);
      for (final r in madeRounds) {
        final window =
            Window.over([for (final o in r.options) r.circleFor(o)]);
        for (final option in r.options) {
          final c = r.circleFor(option);
          final middle = MohrPainter.at(size, window, Offset(c.center, 0));
          final edge = MohrPainter.at(size, window, Offset(c.s1, 0));
          final r2 = (edge - middle).distance;
          expect(middle.dx - r2, greaterThan(-1),
              reason: '${r.subject}: ${option.name} runs off the left');
          expect(middle.dx + r2, lessThan(size.width + 1),
              reason: '${r.subject}: ${option.name} runs off the right');
        }
      }
    });
  });

  group('is-r-the-worst is decided by where the circle sits', () {
    test('a circle that crosses zero answers with the radius', () {
      for (final r in worstRounds.where((r) => !r.stress.clearOfZero)) {
        expect(r.answer, Worst.radius,
            reason: '${r.subject}: zero is inside the spread already');
      }
    });

    test('a circle clear of zero answers with the far end', () {
      for (final r in worstRounds.where((r) => r.stress.clearOfZero)) {
        expect(r.answer, isNot(Worst.radius),
            reason: '${r.subject}: the radius understates the shear here');
        expect(r.sizeOf(r.answer), closeTo(r.stress.absoluteShear, 1e-9));
        expect(r.sizeOf(r.answer), greaterThan(r.stress.radius));
      }
    });

    test('the winner is clear enough to read off the drawing', () {
      for (final r in worstRounds) {
        final best = r.sizeOf(r.answer);
        for (final w in Worst.values) {
          if (w == r.answer) continue;
          expect(r.sizeOf(w), lessThan(best * 0.95),
              reason: '${r.subject}: ${w.name} is within five percent of the '
                  'answer, which cannot be judged by eye');
        }
      }
    });

    test('both sides of the trap are covered, and the compression one too', () {
      expect(worstRounds.where((r) => r.answer == Worst.radius), isNotEmpty);
      expect(worstRounds.where((r) => r.answer == Worst.halfTop), isNotEmpty);
      expect(worstRounds.where((r) => r.answer == Worst.halfBottom), isNotEmpty);
    });

    test('the lesson\'s own hard problem comes out at sixty five', () {
      final q3 = worstRounds.firstWhere((r) => r.stress.x == 120);
      expect(q3.sizeOf(q3.answer), closeTo(65, 1e-9));
      expect(q3.stress.radius, closeTo(50, 1e-9));
    });
  });
}
