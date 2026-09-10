import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/axial_figures.dart';
import 'package:mobile/features/games/does_it_build_stress_game.dart';
import 'package:mobile/features/games/what_comes_out_game.dart';
import 'package:mobile/features/games/which_stretches_more_game.dart';

/// Chapter seven, lesson one. The engine is held against the lesson's own
/// three worked answers and against the wrong answers it names, and the
/// rounds are held against the engine.
void main() {
  group('the engine reproduces the lesson it was built from', () {
    test('the steel rod is forty seven point seven megapascals', () {
      // Problem one: 20 mm diameter, 15 kN pull.
      final area = math.pi * 20 * 20 / 4;
      expect(area, closeTo(314.2, 0.1));
      final rod = Bar(
          length: 1000, area: area, load: 15000, stuff: Stuff.steel);
      expect(rod.stress, closeTo(47.7, 0.1));

      // And the two wrong areas the lesson names: taking the diameter for the
      // radius, and taking the circumference for the area.
      final asRadius = math.pi * 20 * 20;
      expect(15000 / asRadius, closeTo(11.9, 0.1));
      final asCircumference = math.pi * 20;
      expect(15000 / asCircumference, closeTo(238.7, 0.1));
    });

    test('the aluminum rod stretches two point eight six millimetres', () {
      // Problem two: 2.5 m, 30 by 50 mm, 120 kN, E = 70 GPa.
      const rod = Bar(
          length: 2500, area: 1500, load: 120000, stuff: Stuff.aluminum);
      expect(rod.stretch, closeTo(2.86, 0.01));
      expect(Stuff.aluminum.e, 70000);

      // Leaving the length in metres beside an area in square millimetres is
      // the named disaster, and it is out by exactly a thousand.
      const wrong = Bar(
          length: 2.5, area: 1500, load: 120000, stuff: Stuff.aluminum);
      expect(rod.stretch / wrong.stretch, closeTo(1000, 0.001));
    });

    test('the restrained steel bar carries a hundred and seventeen', () {
      // Problem three: 1 m steel, 20 to 70 degrees, held at both ends.
      const bar = Rod(
          length: 1000, stuff: Stuff.steel, held: Held.bothEnds, warmBy: 50);
      expect(bar.alpha, closeTo(11.7e-6, 1e-9));
      expect(bar.stress, closeTo(117, 0.5));
      expect(bar.outcome, Outcome.squeezed);

      // The free growth, which the lesson names as the wrong answer with the
      // wrong units on it.
      expect(bar.freeMove, closeTo(0.585, 0.001));

      // And halving the temperature change halves the stress, which is the
      // other named distractor.
      const halved = Rod(
          length: 1000, stuff: Stuff.steel, held: Held.bothEnds, warmBy: 25);
      expect(halved.stress, closeTo(58.5, 0.5));
    });

    test('a restrained bar does not care how long or how thick it is', () {
      // The lesson says the cross-section cancels. Length cancels too.
      const short = Rod(
          length: 300, stuff: Stuff.steel, held: Held.bothEnds, warmBy: 50);
      const long = Rod(
          length: 9000, stuff: Stuff.steel, held: Held.bothEnds, warmBy: 50);
      expect(short.stress, closeTo(long.stress, 0.001));
    });
  });

  group('which of two bars moves further', () {
    const expected = <int, int>{0: 1, 1: 1, 2: 0, 3: 1, 4: 1, 5: -1};

    test('the app and the hand-worked set agree', () {
      for (var i = 0; i < moveMoreRounds.length; i++) {
        expect(moveMoreRounds[i].answer, expected[i],
            reason: 'round ${i + 1} of which-stretches-more');
      }
    });

    test('a round with a winner wins by enough to see', () {
      for (var i = 0; i < moveMoreRounds.length; i++) {
        final r = moveMoreRounds[i];
        if (r.answer < 0) continue;
        final a = r.bars[0].stretch;
        final b = r.bars[1].stretch;
        final ratio = a > b ? a / b : b / a;
        expect(ratio, greaterThan(1.5),
            reason: 'round ${i + 1}: the two bars are too close to call');
      }
    });

    test('a round with nothing between them really has nothing', () {
      for (var i = 0; i < moveMoreRounds.length; i++) {
        final r = moveMoreRounds[i];
        if (r.answer >= 0) continue;
        expect(r.bars[0].stretch, closeTo(r.bars[1].stretch, 1e-9),
            reason: 'round ${i + 1} says the two match and they do not');
        // And it has to be a real change, not the same bar drawn twice.
        expect(r.bars[0].length == r.bars[1].length &&
            r.bars[0].area == r.bars[1].area, isFalse,
            reason: 'round ${i + 1} draws the same bar twice');
      }
    });

    test('every round really changes something', () {
      for (var i = 0; i < moveMoreRounds.length; i++) {
        final r = moveMoreRounds[i];
        expect(r.bars[0] == r.bars[1], isFalse,
            reason: 'round ${i + 1} draws one bar twice');
        expect(r.labels.length, r.bars.length);
      }
    });

    test('both answers and the draw all turn up', () {
      final answers = moveMoreRounds.map((r) => r.answer).toSet();
      for (final want in [0, 1, -1]) {
        expect(answers, contains(want));
      }
    });

    test('the two bars are drawn to one scale', () {
      // A bar twice as long has to look twice as long, or the comparison
      // being asked for is not on the screen.
      const size = Size(360, 230);
      for (var i = 0; i < moveMoreRounds.length; i++) {
        final r = moveMoreRounds[i];
        final s = BarPairPainter.scaleFor(r.bars, size);
        expect(s, greaterThan(0));
        final drawn = r.bars.map((b) => b.length * s).toList();
        expect(drawn[0] / drawn[1],
            closeTo(r.bars[0].length / r.bars[1].length, 0.001),
            reason: 'round ${i + 1} draws the lengths out of proportion');
        for (final d in drawn) {
          expect(d, lessThanOrEqualTo(size.width),
              reason: 'round ${i + 1} draws a bar wider than the figure');
        }
      }
    });

    test('a bar with four times the area is drawn twice as thick', () {
      // Every bar came out at the same hairline once, which made the round
      // about area say something the drawing flatly contradicted.
      const size = Size(360, 230);
      for (var i = 0; i < moveMoreRounds.length; i++) {
        final r = moveMoreRounds[i];
        final t = BarPairPainter.thickScaleFor(r.bars, size);
        final drawn = r.bars.map((b) => b.thickness * t).toList();
        expect(drawn[0] / drawn[1],
            closeTo(math.sqrt(r.bars[0].area / r.bars[1].area), 0.001),
            reason: 'round ${i + 1} draws the thicknesses out of proportion');
        for (final d in drawn) {
          expect(d, greaterThan(8),
              reason: 'round ${i + 1} draws a bar too thin to see');
        }
      }
      // And the round that says so out loud really shows it.
      final fatter = moveMoreRounds[2];
      final t = BarPairPainter.thickScaleFor(fatter.bars, size);
      expect(fatter.bars[1].thickness * t / (fatter.bars[0].thickness * t),
          closeTo(2, 0.001));
    });

    test('the two rows do not overlap', () {
      const size = Size(360, 230);
      for (final r in moveMoreRounds) {
        final a = BarPairPainter.rowFor(r.bars, size, 0);
        final b = BarPairPainter.rowFor(r.bars, size, 1);
        expect(a.overlaps(b), isFalse);
        expect(a.height, greaterThan(44));
      }
    });
  });

  group('what falls out of a substitution', () {
    const expected = <int, Gives>{
      0: Gives.stress,
      1: Gives.length,
      2: Gives.mixedUnits,
      3: Gives.pureNumber,
      4: Gives.stress,
      5: Gives.mixedUnits,
    };

    test('the app and the hand-worked set agree', () {
      for (var i = 0; i < sumRounds.length; i++) {
        expect(sumRounds[i].answer, expected[i],
            reason: 'round ${i + 1} of what-comes-out');
      }
    });

    test('a mixed round would pass a dimension check, which is the point', () {
      // The whole reason this mistake survives: the units cancel perfectly.
      // If they did not, anyone would catch it.
      for (var i = 0; i < sumRounds.length; i++) {
        final r = sumRounds[i];
        if (r.answer != Gives.mixedUnits) continue;
        var f = 0;
        var l = 0;
        var t = 0;
        for (final term in r.sum.over) {
          final (a, b, c) = term.unit.dims;
          f += a;
          l += b;
          t += c;
        }
        for (final term in r.sum.under) {
          final (a, b, c) = term.unit.dims;
          f -= a;
          l -= b;
          t -= c;
        }
        final tidy = (f == 1 && l == -2 && t == 0) ||
            (f == 0 && l == 1 && t == 0) ||
            (f == 0 && l == 0 && t == 0);
        expect(tidy, isTrue,
            reason: 'round ${i + 1} is meant to be a mixed sum that still '
                'cancels tidily, and its dimensions do not even cancel');
      }
    });

    test('a round that is not mixed really is written in one length', () {
      for (var i = 0; i < sumRounds.length; i++) {
        final r = sumRounds[i];
        if (r.answer == Gives.mixedUnits) continue;
        expect(r.sum.mixed, isFalse, reason: 'round ${i + 1}');
      }
    });

    test('every answer appears and none of them dominates', () {
      final counts = {
        for (final v in Gives.values)
          v: sumRounds.where((r) => r.answer == v).length,
      };
      for (final v in Gives.values) {
        expect(counts[v], greaterThanOrEqualTo(1), reason: '${v.name} never');
      }
      expect(counts.values.reduce(math.max), lessThanOrEqualTo(3));
    });

    test('every term is written with a unit and the sum renders', () {
      for (var i = 0; i < sumRounds.length; i++) {
        final r = sumRounds[i];
        expect(r.sum.over, isNotEmpty);
        for (final t in [...r.sum.over, ...r.sum.under]) {
          expect(t.symbol.isNotEmpty, isTrue);
          expect(t.unit.shown.isNotEmpty, isTrue);
        }
        expect(r.sum.latex, contains(r.sum.over.first.symbol),
            reason: 'round ${i + 1} does not put its own terms in the '
                'expression it shows');
      }
    });
  });

  group('what a held bar is left carrying', () {
    const expected = <int, Outcome>{
      0: Outcome.nothing,
      1: Outcome.squeezed,
      2: Outcome.stretched,
      3: Outcome.nothing,
      4: Outcome.squeezed,
      5: Outcome.squeezed,
    };

    test('the app and the hand-worked set agree', () {
      for (var i = 0; i < heatRounds.length; i++) {
        expect(heatRounds[i].answer, expected[i],
            reason: 'round ${i + 1} of does-it-build-stress');
      }
    });

    test('nothing carrying nothing, and everything else carrying something',
        () {
      for (var i = 0; i < heatRounds.length; i++) {
        final r = heatRounds[i];
        if (r.answer == Outcome.nothing) {
          expect(r.rod.stress, 0,
              reason: 'round ${i + 1} says no stress and has some');
        } else {
          expect(r.rod.stress, greaterThan(1),
              reason: 'round ${i + 1} says there is stress and there is barely '
                  'any');
        }
      }
    });

    test('the gap pair differs only by how far it was warmed', () {
      // Rounds four and five are the same bar and the same gap, and the
      // answer turns on whether the growth outruns the gap.
      final a = heatRounds[3].rod;
      final b = heatRounds[4].rod;
      expect(a.length, b.length);
      expect(a.gap, b.gap);
      expect(a.stuff, b.stuff);
      expect(a.held, Held.withGap);
      expect(b.held, Held.withGap);
      expect(a.freeMove.abs(), lessThan(a.gap));
      expect(b.freeMove.abs(), greaterThan(b.gap));
      expect(heatRounds[3].answer, isNot(heatRounds[4].answer));
    });

    test('a gap round with stress only fights for what is left', () {
      // Closing the gap costs it nothing. Only the growth after contact
      // becomes stress, so a bar with a gap must end up easier off than the
      // same bar with none.
      final r = heatRounds[4].rod;
      final noGap = Rod(
          length: r.length,
          stuff: r.stuff,
          held: Held.bothEnds,
          warmBy: r.warmBy);
      expect(r.stress, lessThan(noGap.stress));
      expect(r.stress, greaterThan(0));
    });

    test('warming and cooling the same bar answer opposite ways', () {
      final warm = heatRounds[1].rod;
      final cool = heatRounds[2].rod;
      expect(warm.length, cool.length);
      expect(warm.stuff, cool.stuff);
      expect(warm.warmBy, -cool.warmBy);
      expect(warm.stress, closeTo(cool.stress, 0.001));
      expect(heatRounds[1].answer, isNot(heatRounds[2].answer));
    });

    test('every answer appears and none of them dominates', () {
      final counts = {
        for (final v in Outcome.values)
          v: heatRounds.where((r) => r.answer == v).length,
      };
      for (final v in Outcome.values) {
        expect(counts[v], greaterThanOrEqualTo(1), reason: '${v.name} never');
      }
      expect(counts.values.reduce(math.max), lessThanOrEqualTo(3));
    });
  });
}
