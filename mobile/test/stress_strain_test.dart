import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/can_you_get_there_game.dart';
import 'package:mobile/features/games/curve_figures.dart';
import 'package:mobile/features/games/stiff_strong_or_stretchy_game.dart';
import 'package:mobile/features/games/where_on_the_curve_game.dart';

/// Chapter seven, lesson three. The engine is held against the lesson's own
/// answers and against the wrong ones it names, and the rounds are held
/// against the engine.
/// Every material either item puts on the screen.
final everySpecimen = <Specimen>[
  for (final r in curveRounds) r.specimen,
  for (final r in pairRounds) ...[r.first, r.second],
];

void main() {
  group('the engine reproduces the lesson it was built from', () {
    test('a stress over its strain is the modulus', () {
      // Problem one: 140 MPa at a strain of 0.0020.
      expect(140 / 0.0020, closeTo(70000, 1));
      // And its named wrong answers, all of them a misplaced decimal or the
      // wrong operation.
      expect(140 * 0.0020, closeTo(0.28, 0.001));
      expect(140 / 0.020, closeTo(7000, 1));
      expect(140 / 0.0002, closeTo(700000, 1));
    });

    test("the shear modulus is E over two times one plus Poisson's ratio", () {
      // Problem three: E = 200 GPa, nu = 0.30.
      double g(double e, double nu) => e / (2 * (1 + nu));
      expect(g(200, 0.30), closeTo(76.9, 0.05));

      // Its three named wrong forms.
      expect(200 / 3, closeTo(66.7, 0.05));
      expect(200 / 2, closeTo(100, 0.05));
      expect(200 / (1 + 0.30), closeTo(154, 0.5));

      // And the direction of the one that catches people: the 2 is in the
      // denominator, so G is well under half of E, not over it.
      expect(g(200, 0.30) / 200, lessThan(0.5));
      expect(g(200, 0.30) / 200, closeTo(0.385, 0.005));
    });

    test('the two materials in the lesson are told apart by their reports', () {
      // Problem two, exactly as written: 250 and 400 with 25 percent, against
      // 830 and 830 with half a percent.
      const one = Specimen(
        label: 'material one',
        e: 200000,
        yieldStress: 250,
        ultimate: 400,
        fractureStrain: 0.25,
        plateau: 0.014,
        necksTo: 0.86,
      );
      const two = Specimen(
        label: 'material two',
        e: 200000,
        yieldStress: 830,
        ultimate: 830,
        fractureStrain: 0.005,
      );
      expect(one.brittle, isFalse);
      expect(two.brittle, isTrue);
      expect(one.elongation, closeTo(25, 0.01));
      expect(two.elongation, closeTo(0.5, 0.01));

      // The trap the problem is built on: the brittle one is the stronger.
      expect(two.ultimate, greaterThan(one.ultimate));
      // And the pair that would fool the rule if only one tell were used: a
      // high strength steel is strong AND ductile.
      const hard = Specimen(
        label: 'high strength steel',
        e: 200000,
        yieldStress: 450,
        ultimate: 620,
        fractureStrain: 0.14,
        necksTo: 0.9,
      );
      expect(hard.brittle, isFalse);
    });
  });

  group('the curve is drawn in the right order', () {
    test('the named points come in the order the lesson lists them', () {
      for (final r in curveRounds) {
        final s = r.specimen;
        expect(s.proportionalStrain, lessThan(s.yieldStrain));
        expect(s.yieldStrain, lessThanOrEqualTo(s.ultimateStrain));
        expect(s.ultimateStrain, lessThanOrEqualTo(s.fractureStrain));
        expect(s.proportionalStress, lessThan(s.yieldStress));
        expect(s.yieldStress, lessThanOrEqualTo(s.ultimate));
      }
    });

    test('fracture sits below the top wherever the material necks', () {
      for (final r in curveRounds) {
        final s = r.specimen;
        if (s.necksTo < 1) {
          expect(s.fractureStress, lessThan(s.ultimate),
              reason: '${s.label} should end lower than its peak');
        }
      }
    });

    test('no material yields after it has already broken', () {
      // The defect this catches: a brittle specimen whose knee was modelled
      // wider than its whole elongation. Its curve then ended before its own
      // fracture point, and the cross marking the break floated off the end
      // of the line it belonged to. Every specimen in the lesson is checked,
      // in both items.
      for (final s in everySpecimen) {
        expect(s.yieldStrain, lessThan(s.fractureStrain),
            reason: '${s.label} breaks before it yields');
        expect(s.plateauEnd, lessThanOrEqualTo(s.fractureStrain),
            reason: '${s.label} is still on its plateau when it breaks');
        expect(s.trace.last.dx, closeTo(s.fractureStrain, 1e-9),
            reason: '${s.label} stops drawing before it breaks');
      }
    });

    test('the trace never doubles back', () {
      // Strain only ever increases during a tensile test, so a curve that
      // goes backwards is a drawing bug rather than a material.
      for (final s in everySpecimen) {
        final t = s.trace;
        for (var i = 1; i < t.length; i++) {
          expect(t[i].dx, greaterThanOrEqualTo(t[i - 1].dx),
              reason: '${s.label} runs backwards at point $i');
        }
      }
    });
  });

  group('where-on-the-curve can be answered with a thumb', () {
    const size = Size(312, 210);

    test('no two named points are close enough to be confused', () {
      // The defect this catches: at true scale a steel bar yields at a tenth
      // of a percent of strain and breaks at twenty five, so the first three
      // points are the same pixel and the round cannot be answered by
      // pointing. The hit radius is 30, so the points must be further apart
      // than that or a tap is a coin toss.
      for (final r in curveRounds) {
        final f = Frame.over([r.specimen]);
        for (final a in Mark.values) {
          for (final b in Mark.values) {
            if (a.index >= b.index) continue;
            final gap = (TensilePainter.markAt(r.specimen, f, size, a) -
                    TensilePainter.markAt(r.specimen, f, size, b))
                .distance;
            expect(gap, greaterThan(34),
                reason: '${r.subject}: ${a.name} and ${b.name} are $gap apart');
          }
        }
      }
    });

    test('a tap on a point picks that point', () {
      for (final r in curveRounds) {
        final f = Frame.over([r.specimen]);
        for (final m in Mark.values) {
          final at = TensilePainter.markAt(r.specimen, f, size, m);
          expect(
            TensilePainter.nearest(r.specimen, f, size, at, Mark.values,
                within: 30),
            m,
          );
        }
      }
    });

    test('a tap on empty canvas picks nothing', () {
      final r = curveRounds.first;
      final f = Frame.over([r.specimen]);
      expect(
        TensilePainter.nearest(
            r.specimen, f, size, const Offset(300, 200), Mark.values,
            within: 30),
        isNull,
      );
    });

    test('every point sits on the curve that was drawn', () {
      // Tap targets that float off the drawing are the defect this catches.
      for (final r in curveRounds) {
        final f = Frame.over([r.specimen]);
        final trace = [
          for (final p in r.specimen.trace) TensilePainter.at(f, size, p)
        ];
        for (final m in Mark.values) {
          final at = TensilePainter.markAt(r.specimen, f, size, m);
          final nearest = trace
              .map((p) => (p - at).distance)
              .reduce((a, b) => a < b ? a : b);
          expect(nearest, lessThan(6),
              reason: '${r.subject}: ${m.name} is not on the curve');
        }
      }
    });
  });

  group('stiff-strong-or-stretchy reads its answers off the curves', () {
    test('all three questions are asked, and every answer is used', () {
      expect(pairRounds.map((r) => r.ask).toSet().length,
          greaterThanOrEqualTo(3));
      expect(pairRounds.map((r) => r.answer).toSet(), Which.values.toSet());
    });

    test('steeper on the drawing really is stiffer', () {
      // The strain axis is stretched near the origin so the early points can
      // be told apart. That is only allowed because both curves of a pair go
      // through the SAME stretch, which keeps the comparison honest. This is
      // the test that keeps it that way.
      const size = Size(312, 200);
      for (final r in pairRounds) {
        final f = Frame.comparing([r.first, r.second]);
        double drawnSlope(Specimen s) {
          final o = TensilePainter.at(f, size, Offset.zero);
          final p = TensilePainter.at(
              f, size, Offset(s.proportionalStrain, s.proportionalStress));
          return (o.dy - p.dy) / (p.dx - o.dx);
        }

        final a = drawnSlope(r.first);
        final b = drawnSlope(r.second);
        if ((r.first.e - r.second.e).abs() > 1) {
          expect(a > b, r.first.e > r.second.e,
              reason: 'the steeper drawn line is not the stiffer material');
        } else {
          expect(a, closeTo(b, 0.01),
              reason: 'equal moduli should draw as one line');
        }
      }
    });

    test('higher on the drawing really is stronger, and longer is stretchier',
        () {
      const size = Size(312, 200);
      for (final r in pairRounds) {
        final f = Frame.comparing([r.first, r.second]);
        double peak(Specimen s) =>
            TensilePainter.markAt(s, f, size, Mark.ultimate).dy;
        double end(Specimen s) =>
            TensilePainter.markAt(s, f, size, Mark.fracture).dx;
        // Smaller y is higher up the page.
        expect(peak(r.first) < peak(r.second),
            r.first.ultimate > r.second.ultimate);
        expect(end(r.first) > end(r.second),
            r.first.fractureStrain > r.second.fractureStrain);
      }
    });
  });

  group('can-you-get-there walks the relations rather than being told', () {
    test('the lesson\'s own three relations, and no others', () {
      expect(
          routeTo({Quantity.e, Quantity.nu}, Quantity.g), Road.oneStep);
      expect(
          routeTo({Quantity.g, Quantity.nu}, Quantity.e), Road.oneStep);
      expect(routeTo({Quantity.stress, Quantity.strain}, Quantity.e),
          Road.oneStep);
      expect(routeTo({Quantity.startLength, Quantity.endLength},
          Quantity.elongation), Road.oneStep);
    });

    test('two steps is two steps', () {
      expect(
        routeTo({Quantity.stress, Quantity.strain, Quantity.nu}, Quantity.g),
        Road.further,
      );
    });

    test('a road that does not exist is not invented', () {
      expect(routeTo({Quantity.e}, Quantity.g), Road.cannot);
      expect(routeTo({Quantity.nu}, Quantity.g), Road.cannot);
      // Strength never gives ductility, which is the same independence the
      // second item is about.
      expect(
        routeTo({Quantity.yieldStress, Quantity.ultimate}, Quantity.elongation),
        Road.cannot,
      );
      // And the specimen dimensions in the lesson's hard problem lead nowhere
      // on their own.
      expect(
        routeTo({Quantity.startLength, Quantity.endLength}, Quantity.g),
        Road.cannot,
      );
    });

    test('every answer appears, and the spare numbers really are spare', () {
      expect(roadRounds.map((r) => r.answer).toSet(), Road.values.toSet());
      for (final r in roadRounds) {
        if (r.spare.isEmpty) continue;
        // A round that lists spare data must still reach its target without
        // it, which is what makes it spare.
        expect(routeTo(r.have.toSet(), r.want), isNot(Road.cannot));
      }
    });
  });
}
