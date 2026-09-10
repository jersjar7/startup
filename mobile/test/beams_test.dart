import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/beam_figures.dart' show Spread;
import 'package:flutter/material.dart';
import 'package:mobile/features/games/beam_figures.dart' show BeamPainter;
import 'package:mobile/features/games/diagram_figures.dart';
import 'package:mobile/features/games/jump_bend_or_neither_game.dart';
import 'package:mobile/features/games/where_it_peaks_game.dart';
import 'package:mobile/features/games/which_diagram_belongs_game.dart';

/// Chapter seven, lesson four. The engine is held against the lesson's own
/// three worked answers and against the wrong ones it names.
void main() {
  group('the engine reproduces the lesson it was built from', () {
    test('a midspan load on a six meter beam peaks at 27', () {
      // Problem one: 6 m simply supported, 18 kN at the middle.
      const beam = Loading(span: 6, points: [(3, 18)]);
      expect(beam.leftReaction, closeTo(9, 1e-9));
      expect(beam.rightReaction, closeTo(9, 1e-9));
      expect(beam.peakMomentAt, closeTo(3, 1e-6));
      expect(beam.peakMoment, closeTo(27, 1e-6));

      // Which is PL/4, and the lesson's named wrong answers are the other
      // divisors and the full load in place of the reaction.
      expect(18 * 6 / 4, closeTo(27, 1e-9));
      expect(18 * 6 / 8, closeTo(13.5, 1e-9));
      expect(18 * 3, closeTo(54, 1e-9));
      expect(18 * 6, closeTo(108, 1e-9));

      // The moment is zero at both supports, which is what a pin and a roller
      // mean, and the shear changes sign under the load.
      expect(beam.momentAt(0), closeTo(0, 1e-6));
      expect(beam.momentAt(6, after: false), closeTo(0, 1e-6));
      expect(beam.shearAt(3, after: false), closeTo(9, 1e-9));
      expect(beam.shearAt(3), closeTo(-9, 1e-9));
    });

    test('a uniform load on an eight meter beam peaks at 40', () {
      // Problem two: 8 m, 5 kN/m the whole way.
      const beam = Loading(span: 8, spreads: [Spread(0, 8, 5, 5)]);
      expect(beam.totalDown, closeTo(40, 1e-9));
      expect(beam.leftReaction, closeTo(20, 1e-9));
      expect(beam.peakMomentAt, closeTo(4, 1e-6));
      expect(beam.peakMoment, closeTo(40, 1e-6));

      // wL squared over eight, and the three named wrong divisors.
      expect(5 * 64 / 8, closeTo(40, 1e-9));
      expect(5 * 64 / 16, closeTo(20, 1e-9));
      expect(5 * 64 / 4, closeTo(80, 1e-9));
      expect(5 * 64 / 2, closeTo(160, 1e-9));

      // And the shape: shear runs straight from plus twenty to minus twenty,
      // and the moment is a parabola, so the quarter point is not half the
      // peak.
      expect(beam.shearAt(0), closeTo(20, 1e-9));
      expect(beam.shearAt(8, after: false), closeTo(-20, 1e-9));
      expect(beam.shearAt(2), closeTo(10, 1e-9));
      expect(beam.momentAt(2), closeTo(30, 1e-6));
    });

    test('an off center load peaks under the load, not at midspan', () {
      // Problem three: 10 m, 30 kN at 4 m from the left.
      const beam = Loading(span: 10, points: [(4, 30)]);
      expect(beam.rightReaction, closeTo(12, 1e-9));
      expect(beam.leftReaction, closeTo(18, 1e-9));
      expect(beam.peakMomentAt, closeTo(4, 1e-6));
      expect(beam.peakMoment, closeTo(72, 1e-6));

      // Pab over L, and the lesson's three named wrong answers, each of which
      // is a real place on this beam or a real quantity used wrongly.
      expect(30 * 4 * 6 / 10, closeTo(72, 1e-9));
      expect(12 * 4, closeTo(48, 1e-9));
      expect(30 * 4, closeTo(120, 1e-9));
      expect(12 * 5, closeTo(60, 1e-9));

      // The midspan moment really is 60, which is why that distractor is
      // tempting: it is a true number, answering a question nobody asked.
      expect(beam.momentAt(5), closeTo(60, 1e-6));
      expect(beam.momentAt(5), lessThan(beam.peakMoment));
    });
  });

  group('the rules the diagrams are drawn by', () {
    test('an upward reaction jumps the shear up, a load jumps it down', () {
      const beam = Loading(span: 6, points: [(3, 18)]);
      expect(beam.shearAt(0, after: false), closeTo(0, 1e-9));
      expect(beam.shearAt(0), closeTo(9, 1e-9));
      expect(beam.shearAt(3) - beam.shearAt(3, after: false),
          closeTo(-18, 1e-9));
    });

    test('the slope of the moment is the shear', () {
      const beam = Loading(span: 8, spreads: [Spread(0, 8, 5, 5)]);
      for (final x in [1.0, 2.5, 5.0, 7.0]) {
        const h = 1e-4;
        final slope = (beam.momentAt(x + h) - beam.momentAt(x - h)) / (2 * h);
        expect(slope, closeTo(beam.shearAt(x), 1e-3),
            reason: 'at $x the moment does not climb at the rate of the shear');
      }
    });

    test('the slope of the shear is minus the load', () {
      const beam = Loading(span: 8, spreads: [Spread(0, 8, 5, 5)]);
      const h = 1e-4;
      final slope = (beam.shearAt(4 + h) - beam.shearAt(4 - h)) / (2 * h);
      expect(slope, closeTo(-5, 1e-3));
    });

    test('the change in moment is the area under the shear', () {
      const beam = Loading(span: 10, points: [(4, 30)]);
      // From the left support to the load: a rectangle of shear, 18 by 4.
      expect(beam.momentAt(4) - beam.momentAt(0), closeTo(18 * 4, 1e-6));
      // And from the load to the right support: minus twelve over six meters,
      // which takes it back to zero.
      expect(beam.momentAt(10, after: false) - beam.momentAt(4),
          closeTo(-12 * 6, 1e-6));
    });

    test('a couple jumps the moment and leaves the shear alone', () {
      const beam = Loading(span: 8, couples: [(4, 24)]);
      expect(beam.momentAt(4) - beam.momentAt(4, after: false),
          closeTo(24, 1e-6));
      expect(beam.shearAt(4), closeTo(beam.shearAt(4, after: false), 1e-9));
      // And it still has to come back to zero at the far support.
      expect(beam.momentAt(8, after: false), closeTo(0, 1e-6));
    });

    test('a cantilever hogs, and its worst moment is at the wall', () {
      const beam = Loading(span: 4, held: Held.cantilever, points: [(4, 10)]);
      expect(beam.leftReaction, closeTo(10, 1e-9));
      expect(beam.wallMoment, closeTo(-40, 1e-9));
      expect(beam.peakMomentAt, closeTo(0, 1e-6));
      expect(beam.momentAt(0), closeTo(-40, 1e-6));
      expect(beam.momentAt(4, after: false), closeTo(0, 1e-6));
      // A uniform load on a cantilever is wL squared over two, which the
      // lesson names as the formula people reach for by mistake on a simply
      // supported beam.
      const udl = Loading(span: 8, held: Held.cantilever,
          spreads: [Spread(0, 8, 5, 5)]);
      expect(udl.momentAt(0).abs(), closeTo(5 * 64 / 2, 1e-6));
    });

    test('an overhang puts a hogging moment over the support', () {
      const beam = Loading(span: 10, b: 8, points: [(10, 12)]);
      expect(beam.momentAt(8).abs(), closeTo(24, 1e-6));
      expect(beam.momentAt(8), lessThan(0));
      expect(beam.peakMomentAt, closeTo(8, 1e-6));
    });
  });

  group('which-diagram-belongs offers three different drawings', () {
    /// How far apart two candidate lines are, sampled along the beam and
    /// measured after each is scaled to its own height, which is how they are
    /// drawn.
    double apart(List<Offset> a, List<Offset> b, double span) {
      double height(List<Offset> c) =>
          c.map((p) => p.dy.abs()).reduce((x, y) => x > y ? x : y);
      double read(List<Offset> c, double x) {
        for (var i = 1; i < c.length; i++) {
          if (c[i].dx >= x) {
            final run = c[i].dx - c[i - 1].dx;
            final on = run <= 0 ? 1.0 : (x - c[i - 1].dx) / run;
            return c[i - 1].dy + (c[i].dy - c[i - 1].dy) * on;
          }
        }
        return c.last.dy;
      }

      final ha = height(a);
      final hb = height(b);
      var worst = 0.0;
      for (var i = 0; i <= 40; i++) {
        final x = span * i / 40;
        final ya = ha == 0 ? 0.0 : read(a, x) / ha;
        final yb = hb == 0 ? 0.0 : read(b, x) / hb;
        final gap = (ya - yb).abs();
        if (gap > worst) worst = gap;
      }
      return worst;
    }

    test('no two options in a round draw the same line', () {
      // The gate checks that no option is REPEATED. This checks the harder
      // thing: that two options which are described differently do not come
      // out identical on the screen, which would leave a round with two right
      // answers. Straightening a moment diagram that is already straight is
      // exactly how that happens.
      for (final r in shapeRounds) {
        final drawn = [
          for (final t in r.options) variant(r.beam, r.asked, t),
        ];
        for (var i = 0; i < drawn.length; i++) {
          for (var j = i + 1; j < drawn.length; j++) {
            expect(apart(drawn[i], drawn[j], r.beam.span), greaterThan(0.08),
                reason: '${r.subject}: options ${i + 1} and ${j + 1} draw the '
                    'same picture');
          }
        }
      }
    });

    test('exactly one option is the beam it sits under', () {
      for (final r in shapeRounds) {
        expect(r.options.where((t) => t == Twist.none).length, 1);
        expect(r.answer, isNot(-1));
        expect(
          variant(r.beam, r.asked, r.options[r.answer]),
          r.beam.curve(r.asked),
        );
      }
    });

    test('every named mistake gets used', () {
      final used = {for (final r in shapeRounds) ...r.options};
      expect(used, Twist.values.toSet());
    });
  });

  group('where-it-peaks is decided by the beam, not by the round', () {
    test('the marked place really is the worst one on offer', () {
      for (final r in peakRounds) {
        final answer = r.spots[r.answer];
        for (final x in r.spots) {
          if (x == answer) continue;
          expect(r.beam.momentAt(x).abs(),
              lessThan(r.beam.momentAt(answer).abs() - 1e-6),
              reason: '${r.subject}: $x ties with the answer');
        }
      }
    });

    test('the answer is the beam\'s true peak, not just the best on offer', () {
      // A round that offered five places and missed the real peak would be
      // teaching the wrong thing while marking itself correct.
      for (final r in peakRounds) {
        expect(r.spots[r.answer], closeTo(r.beam.peakMomentAt, 1e-6),
            reason: '${r.subject}: the real peak is not among the places '
                'offered');
      }
    });

    test('midspan is on offer somewhere it is wrong', () {
      // The lesson's own trap: on a beam whose load is not central the peak
      // is not at midspan, and a round has to let you make that mistake or it
      // is not testing anything. The lesson's own off centre beam cannot
      // carry it, because there its midspan lands a meter from the answer and
      // two marks that close cannot both be tapped with a thumb. So it lives
      // on the two load round, where the spacing allows it.
      final withMidspan = peakRounds.where((r) =>
          r.spots.contains(r.beam.span / 2) &&
          r.spots[r.answer] != r.beam.span / 2);
      expect(withMidspan, isNotEmpty);
      final round = withMidspan.first;
      expect(round.beam.momentAt(round.beam.span / 2).abs(),
          greaterThan(0),
          reason: 'a trap worth offering is a real number, not zero');
    });

    test('the marks are far enough apart to tap', () {
      const size = Size(312, 190);
      for (final r in peakRounds) {
        for (var i = 1; i < r.spots.length; i++) {
          final a = BeamPainter.stationAt(size, r.beam.span, r.spots[i - 1]);
          final b = BeamPainter.stationAt(size, r.beam.span, r.spots[i]);
          expect((a - b).distance, greaterThan(34),
              reason: '${r.subject}: two marks are on top of each other');
        }
      }
    });
  });

  group('jump-bend-or-neither reads the diagram it is asking about', () {
    test('all four answers are used', () {
      expect(markRounds.map((r) => r.answer).toSet(), Does.values.toSet());
    });

    test('a force steps the shear and only bends the moment', () {
      const beam = Loading(span: 6, points: [(3, 18)]);
      const atLoad = SpotRound(
        subject: '', beam: beam, at: 3, asked: Diagram.shear,
        why: '', source: 'mm-smd-q1',
      );
      const momentThere = SpotRound(
        subject: '', beam: beam, at: 3, asked: Diagram.moment,
        why: '', source: 'mm-smd-q1',
      );
      expect(atLoad.answer, Does.jumpsDown);
      expect(momentThere.answer, Does.bends);
    });

    test('a couple steps the moment and leaves the shear alone', () {
      const beam = Loading(span: 8, couples: [(4, 24)]);
      const onMoment = SpotRound(
        subject: '', beam: beam, at: 4, asked: Diagram.moment,
        why: '', source: 'mm-smd-q3',
      );
      const onShear = SpotRound(
        subject: '', beam: beam, at: 4, asked: Diagram.shear,
        why: '', source: 'mm-smd-q3',
      );
      expect(onMoment.answer, Does.jumpsUp);
      expect(onShear.answer, Does.carriesOn);
    });
  });
}
