import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/section_figures.dart';
import 'package:mobile/features/games/stress_figures.dart';
import 'package:mobile/features/games/which_fiber_is_worst_game.dart';
import 'package:mobile/features/games/which_one_gets_worse_game.dart';
import 'package:mobile/features/games/which_width_which_area_game.dart';

/// Chapter seven, lesson five. The section engine is held against the
/// lesson's own three answers and against the wrong ones it names.
void main() {
  group('the engine reproduces the lesson it was built from', () {
    test('the timber beam sees twelve megapascals', () {
      // Problem one: 100 by 200 rectangle, 8 kN.m.
      final beam = boxSection(100, 200);
      expect(beam.ownIx, closeTo(66.67e6, 1e4));
      expect(beam.cMax, closeTo(100, 1e-9));
      expect(beam.bendingStressAt(beam.baseline, 8e6), closeTo(12, 0.01));
      expect(beam.bendingStressAt(beam.crown, 8e6), closeTo(-12, 0.01));

      // The section modulus route, which is the same thing with two steps
      // folded together.
      expect(beam.sectionModulus, closeTo(666667, 1));
      expect(8e6 / beam.sectionModulus, closeTo(12, 0.01));

      // The lesson's three named wrong answers: the full height for c, the
      // wrong divisor in I, and dropping the twelve altogether.
      expect(8e6 * 200 / beam.ownIx, closeTo(24, 0.02));
      expect(8e6 * 100 / (100 * 200 * 200 * 200 / 6), closeTo(6, 0.01));
      // The lesson's third named wrong answer does not come out where it
      // says. Leaving the twelve out of bh cubed gives 1.0 MPa, not the 2.4
      // on the list. Recorded here so the drift is visible rather than
      // guessed at again later.
      expect(8e6 * 100 / (100 * 200 * 200 * 200), closeTo(1.0, 0.01));
    });

    test('the peak shear in a rectangle is half again the average', () {
      // Problem two: 150 by 300, 45 kN.
      final beam = boxSection(150, 300);
      final peak = beam.shearStressAt(beam.centroid.dy, 45000);
      expect(peak, closeTo(1.5, 0.001));

      // Which is exactly 3V over 2A, the shortcut the lesson wants used.
      expect(3 * 45000 / (2 * beam.area), closeTo(1.5, 0.001));
      // And the two wrong answers: the plain average, and forgetting the two.
      expect(45000 / beam.area, closeTo(1.0, 0.001));
      expect(3 * 45000 / beam.area, closeTo(3.0, 0.001));

      // The shape of it: nothing at the faces, most at the middle, and the
      // quarter point at three quarters of the peak, which is what a parabola
      // does.
      expect(beam.shearStressAt(beam.crown, 45000), closeTo(0, 1e-6));
      expect(beam.shearStressAt(beam.baseline, 45000), closeTo(0, 1e-6));
      expect(beam.shearStressAt(beam.centroid.dy + 75, 45000),
          closeTo(1.5 * 0.75, 0.001));
    });

    test('the I-beam junction is twenty one megapascals, through the web', () {
      // Problem three: 300 deep, 150 flanges 20 thick, 10 web, V = 60 kN.
      final beam = iSection(
        depth: 300,
        flangeWidth: 150,
        flangeThickness: 20,
        webThickness: 10,
      );
      // The lesson GIVES I as 120 million, and that is not what these
      // dimensions come to: the section's own second moment is 132.4
      // million. The given number is what its answer uses, so both are
      // recorded, and no item quotes a stress value off this section.
      expect(beam.ownIx / 1e6, closeTo(132.4, 0.1));
      expect(beam.qAbove(280), closeTo(420000, 1));
      expect(beam.widthAt(280), closeTo(10, 1e-9));

      final tau = 60000 * beam.qAbove(280) / (120e6 * 10);
      expect(tau, closeTo(21.0, 0.05));

      // The named trap, the flange width in place of the web thickness, is
      // out by fifteen times.
      expect(60000 * beam.qAbove(280) / (120e6 * 150), closeTo(1.4, 0.01));
      // The lesson says its 3.33 option is the average shear, V over A. It
      // is not: this section's area is 8,600 square millimeters and V over A
      // is 6.98. Recorded rather than papered over.
      expect(beam.area, closeTo(8600, 1));
      expect(60000 / beam.area, closeTo(6.98, 0.01));
    });
  });

  group('what the section engine knows', () {
    test('the width is read on the side the shear has to pass through', () {
      final beam = iSection(
        depth: 300,
        flangeWidth: 150,
        flangeThickness: 20,
        webThickness: 10,
      );
      // Just under the top flange is web; just inside the flange is flange.
      expect(beam.widthAt(280), closeTo(10, 1e-9));
      expect(beam.widthAt(280, below: false), closeTo(150, 1e-9));
      expect(beam.widthAt(150), closeTo(10, 1e-9));
      expect(beam.widthAt(290), closeTo(150, 1e-9));
    });

    test('taking Q above or below a cut gives the same size', () {
      final beam = iSection(
        depth: 300,
        flangeWidth: 150,
        flangeThickness: 20,
        webThickness: 10,
      );
      for (final y in [40.0, 150.0, 280.0]) {
        final above = beam.qAbove(y);
        final whole = beam.qAbove(beam.baseline);
        final below = whole - above;
        expect(below.abs(), closeTo(above.abs(), 1e-6),
            reason: 'the two sides of a cut at $y do not balance');
      }
      // And the first moment of the WHOLE section about its own centroid is
      // nothing at all, which is what being the centroid means.
      expect(beam.qAbove(beam.baseline), closeTo(0, 1e-6));
    });

    test('a tee has its neutral axis nowhere near the middle', () {
      final tee = teeSection(
        depth: 300,
        flangeWidth: 200,
        flangeThickness: 40,
        webThickness: 30,
      );
      expect(tee.centroid.dy, greaterThan(tee.midHeight));
      // So the bottom fiber is further from the axis and works harder under
      // the same moment.
      expect(tee.cBottom, greaterThan(tee.cTop));
      expect(tee.bendingStressAt(tee.baseline, 10e6).abs(),
          greaterThan(tee.bendingStressAt(tee.crown, 10e6).abs()));
    });

    test('the bending stress runs straight and the shear does not', () {
      final beam = boxSection(100, 200);
      // Straight: half way out from the axis is half the stress.
      final edge = beam.bendingStressAt(beam.baseline, 5e6);
      expect(beam.bendingStressAt(beam.centroid.dy - 50, 5e6),
          closeTo(edge / 2, 1e-6));
      // Curved: half way out from the axis is three quarters of the peak.
      final peak = beam.shearStressAt(beam.centroid.dy, 30000);
      expect(beam.shearStressAt(beam.centroid.dy - 50, 30000),
          closeTo(peak * 0.75, 1e-6));
    });

    test('the two stresses peak in opposite places', () {
      final beam = boxSection(150, 300);
      expect(beam.bendingStressAt(beam.centroid.dy, 20e6), closeTo(0, 1e-9));
      expect(beam.shearStressAt(beam.crown, 40000), closeTo(0, 1e-9));
      expect(beam.shearStressAt(beam.centroid.dy, 40000), greaterThan(0));
      expect(beam.bendingStressAt(beam.crown, 20e6).abs(), greaterThan(0));
    });
  });

  group('which-fiber-is-worst is answered from the section', () {
    test('every layer is on the section it is drawn on', () {
      for (final r in fiberRounds) {
        for (final l in r.layers) {
          expect(l.y, greaterThanOrEqualTo(r.section.baseline - 1e-9));
          expect(l.y, lessThanOrEqualTo(r.section.crown + 1e-9));
        }
        expect(r.layers.length, 5);
      }
    });

    test('the neutral axis is a marked layer, wherever it falls', () {
      for (final r in fiberRounds) {
        final axis = r.section.centroid.dy;
        expect(r.layers.any((l) => (l.y - axis).abs() < 1e-6), isTrue,
            reason: '${r.subject}: the axis itself is not on offer');
      }
    });

    test('the tee round really does have its axis away from the middle', () {
      final tee = fiberRounds.firstWhere((r) => r.subject.contains('tee'));
      expect((tee.section.centroid.dy - tee.section.midHeight).abs(),
          greaterThan(tee.section.bounds.height * 0.08),
          reason: 'a tee whose axis sits at mid height teaches nothing');
    });

    test('no round has two layers that tie for the answer', () {
      for (final r in fiberRounds) {
        double score(double y) => switch (r.wanted) {
              Wanted.mostTension => r.section.bendingStressAt(y, r.moment),
              Wanted.mostCompression => -r.section.bendingStressAt(y, r.moment),
              Wanted.noBending =>
                -r.section.bendingStressAt(y, r.moment).abs(),
              Wanted.mostShear =>
                r.section.shearStressAt(y, FiberRound.shear),
            };
        final best = score(r.layers[r.answer].y);
        for (var i = 0; i < r.layers.length; i++) {
          if (i == r.answer) continue;
          expect(score(r.layers[i].y), lessThan(best - 1e-6),
              reason: '${r.subject}: layer ${i + 1} ties with the answer');
        }
      }
    });

    test('the layers are far enough apart to tap', () {
      const size = Size(312, 230);
      for (final r in fiberRounds) {
        final ys = [
          for (final l in r.layers)
            LayerPainter.layerAt(r.section, size, l.y).dy,
        ]..sort();
        for (var i = 1; i < ys.length; i++) {
          expect(ys[i] - ys[i - 1], greaterThan(26),
              reason: '${r.subject}: two layers are on top of each other');
        }
      }
    });
  });

  group('which-width-which-area marks what it says it marks', () {
    test('a width round answers with the width at the cut', () {
      for (final r in sliceRounds.where((r) => r.asks == Asks.width)) {
        final marked = r.marks[r.answer];
        expect(marked.isWidth, isTrue);
        expect(r.section.widthAt(marked.y),
            closeTo(r.section.widthAt(r.cut), 1e-6),
            reason: '${r.subject}: the marked width is not the width at the '
                'cut');
      }
    });

    test('an area round answers with the material beyond the cut', () {
      for (final r in sliceRounds.where((r) => r.asks == Asks.area)) {
        final marked = r.marks[r.answer];
        expect(marked.isWidth, isFalse);
        // Everything from the cut to the top, or from the bottom to the cut:
        // either is right, and both give the same first moment.
        final above = marked.from == r.cut && marked.to >= r.section.crown;
        final below = marked.to == r.cut && marked.from <= r.section.baseline;
        expect(above || below, isTrue,
            reason: '${r.subject}: the marked band is not one side of the cut');
        expect(r.section.qAbove(r.cut).abs(), greaterThan(0),
            reason: '${r.subject}: a cut with no Q teaches nothing');
      }
    });

    test('only one panel in an area round is a side of the cut', () {
      // Q taken above the cut and Q taken below it come to the same number,
      // so a round that offers BOTH has two right answers and marks one of
      // them wrong. That is the defect this catches.
      for (final r in sliceRounds.where((r) => r.asks == Asks.area)) {
        var valid = 0;
        for (final m in r.marks) {
          final above = m.from == r.cut && m.to >= r.section.crown;
          final below = m.to == r.cut && m.from <= r.section.baseline;
          if (above || below) valid++;
        }
        expect(valid, 1,
            reason: '${r.subject}: $valid of the three panels are correct');
      }
    });

    test('the whole section is offered, and it is worth nothing', () {
      // The distractor that matters most: Q of the entire section about its
      // own centroid is zero, so anyone choosing it is choosing a dead number.
      final whole = sliceRounds.where((r) =>
          r.asks == Asks.area &&
          r.marks.any((m) =>
              !m.isWidth &&
              m.from <= r.section.baseline &&
              m.to >= r.section.crown));
      expect(whole, isNotEmpty);
      for (final r in whole) {
        expect(r.section.qAbove(r.section.baseline), closeTo(0, 1e-6));
      }
    });

    test('no round marks the same thing twice', () {
      for (final r in sliceRounds) {
        final seen = <String>{};
        for (final m in r.marks) {
          final key = m.isWidth
              ? 'w${r.section.widthAt(m.y)}'
              : 'b${m.from}-${m.to}';
          expect(seen.add(key), isTrue,
              reason: '${r.subject}: two panels mark the same thing');
        }
      }
    });
  });

  group('which-one-gets-worse works both formulas out', () {
    test('every answer is used', () {
      expect(swapRounds.map((r) => r.answer).toSet(), Worse.values.toSet());
    });

    test('the span moves the bending and not the shear', () {
      final longer = swapRounds.first;
      expect(longer.answer, Worse.bending);
      expect(longer.after.span, longer.before.span * 2);
      // And the reactions really are unchanged, which is the whole point.
      expect(longer.after.leftReaction,
          closeTo(longer.before.leftReaction, 1e-9));
    });

    test('turning the section on its side leaves the area alone', () {
      final onSide = swapRounds[2];
      expect(onSide.answer, Worse.bending);
      expect(onSide.sectionAfter.area, closeTo(onSide.section.area, 1e-9));
      expect(onSide.sectionAfter.sectionModulus,
          lessThan(onSide.section.sectionModulus));
    });

    test('a deeper section improves bending faster than shear', () {
      final deeper = swapRounds.last;
      expect(deeper.answer, Worse.neither);
      final s0 = deeper.section;
      final s1 = deeper.sectionAfter;
      expect(s1.sectionModulus / s0.sectionModulus, closeTo(4, 0.01));
      expect(s1.area / s0.area, closeTo(2, 0.01));
    });
  });
}
