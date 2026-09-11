import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/before_or_during_game.dart';
import 'package:mobile/features/games/crack_figures.dart';
import 'package:mobile/features/games/out_of_the_furnace_game.dart';
import 'package:mobile/features/games/thermal_figures.dart';
import 'package:mobile/features/games/which_arm_game.dart';
import 'package:mobile/features/games/which_one_moves_most_game.dart';
import 'package:mobile/features/games/edge_or_inside_game.dart';
import 'package:mobile/features/games/which_cracks_first_game.dart';
import 'package:mobile/features/games/coupon_figures.dart';
import 'package:mobile/features/games/curve_figures.dart';
import 'package:mobile/features/games/true_or_engineering_game.dart';

/// Chapter eight, lesson one. Held against the lesson's own three answers and
/// against the picture each round is asking a reader to point at.
void main() {
  group('the definitions reproduce the lesson', () {
    test('sixty kilonewtons over a hundred and fifty square millimeters', () {
      const coupon = Coupon(
        areaBefore: 150,
        lengthBefore: 50,
        stretch: 0.125,
        thinnedTo: 0.99,
      );
      expect(60000 / coupon.areaBefore, closeTo(400, 0.5));
      // The named slip: the kilonewtons never converted.
      expect(60 / coupon.areaBefore, closeTo(0.4, 0.001));
    });

    test('a tenth of a millimeter on a fifty millimeter gauge', () {
      const coupon = Coupon(
        areaBefore: 150,
        lengthBefore: 50,
        stretch: 0.125,
        thinnedTo: 0.99,
      );
      final strain = coupon.stretch / coupon.lengthBefore;
      expect(strain, closeTo(0.0025, 1e-9));
      expect(175 / strain, closeTo(70000, 1));
      // The named slip: the stretch used as though it were already a strain,
      // which is out by the whole gauge length.
      expect(175 / coupon.stretch, closeTo(1400, 1));
      expect((175 / coupon.stretch) * coupon.lengthBefore,
          closeTo(70000, 1));
    });

    test('true stress at the onset of necking is 598', () {
      const at = 0.15;
      const engineering = 520.0;
      expect(engineering * (1 + at), closeTo(598, 0.5));
      // The named slips: dividing instead of multiplying, and multiplying by
      // the strain rather than by one plus it.
      expect(engineering / (1 + at), closeTo(452, 0.5));
      expect(engineering * at, closeTo(78, 0.5));
    });
  });

  group('the coupon drawing says what the round is about', () {
    test('a measurement taken now is never the one taken before', () {
      for (final r in dimRounds) {
        expect(r.coupon.lengthNow, greaterThan(r.coupon.lengthBefore),
            reason: r.subject);
        if (r.answer == Dim.areaNow) {
          expect(r.coupon.necked, isTrue,
              reason: '${r.subject}: a round about the area right now needs a '
                  'bar that has visibly drawn in');
        }
      }
    });

    test('the four labels are far enough apart for a thumb', () {
      const size = Size(340, 250);
      for (final a in Dim.values) {
        for (final b in Dim.values) {
          if (a == b) continue;
          final gap =
              (CouponPainter.tagAt(size, a) - CouponPainter.tagAt(size, b))
                  .distance;
          expect(gap, greaterThan(30),
              reason: '${a.name} and ${b.name} are ${gap.round()} apart');
        }
      }
    });

    test('a tap lands on the label nearest it', () {
      const size = Size(340, 250);
      for (final d in Dim.values) {
        expect(CouponPainter.nearest(size, CouponPainter.tagAt(size, d)), d);
      }
      // A tap in the corner is not a choice at all.
      expect(CouponPainter.nearest(size, const Offset(336, 246)), isNull);
    });

    test('every measurement is asked for by at least one round', () {
      expect(dimRounds.map((r) => r.answer).toSet(), Dim.values.toSet());
    });

    test('both problems about the original bar are cited', () {
      expect(dimRounds.map((r) => r.source).toSet().length,
          greaterThanOrEqualTo(2));
    });
  });

  group('the two curves of one test', () {
    Specimen specimenOf(Reading pick) =>
        readingRounds.firstWhere((r) => r.answer == pick).specimen;

    test('true stress is never below engineering stress', () {
      for (final r in readingRounds) {
        final plain = r.specimen.trace;
        final real = r.specimen.trueTrace;
        for (var i = 0; i < plain.length; i++) {
          expect(real[i].dy, greaterThanOrEqualTo(plain[i].dy - 1e-9),
              reason: '${r.subject} at strain ${plain[i].dx}');
        }
      }
    });

    test('the true curve climbs all the way to the break', () {
      for (final r in readingRounds) {
        final real = r.specimen.trueTrace;
        for (var i = 1; i < real.length; i++) {
          expect(real[i].dy, greaterThanOrEqualTo(real[i - 1].dy - 1e-6),
              reason: '${r.subject}: the true stress dipped at strain '
                  '${real[i].dx}, which no real test does');
        }
      }
    });

    test('the engineering curve does come down at the end', () {
      for (final r in readingRounds) {
        final plain = r.specimen.trace;
        expect(plain.last.dy, lessThan(r.specimen.ultimate),
            reason: '${r.subject}: nothing to read if it does not turn over');
      }
    });

    test('below yield the two are the same line', () {
      final s = specimenOf(Reading.same);
      final plain = s.trace;
      final real = s.trueTrace;
      for (var i = 0; i < plain.length; i++) {
        if (plain[i].dx > s.yieldStrain) break;
        expect((real[i].dy - plain[i].dy) / math.max(plain[i].dy, 1),
            lessThan(0.01),
            reason: 'they should be within a percent of each other here');
      }
    });

    test('the lesson\'s own specimen converts to its own answer', () {
      final s = readingRounds
          .firstWhere((r) => r.subject.contains('mill certificate'))
          .specimen;
      expect(s.ultimate, 520);
      expect(s.ultimateStrain, closeTo(0.15, 0.01));
      expect(s.ultimate * (1 + s.ultimateStrain), closeTo(598, 6));
    });

    test('the two curves are far enough apart to tell apart when tapped', () {
      const size = Size(340, 230);
      for (final r in readingRounds) {
        if (r.answer == Reading.same) continue;
        final frame = Frame.over([r.specimen], headroom: 1.85);
        final plain =
            BothPainter.pointsOf(r.specimen, frame, size, BothPainter.engineering);
        final real =
            BothPainter.pointsOf(r.specimen, frame, size, BothPainter.truth);
        // At the end of the test, where every one of these rounds is looking.
        expect((plain.last - real.last).distance, greaterThan(34),
            reason: '${r.subject}: the two ends are on top of each other');
      }
    });

    test('a tap on a curve picks that curve', () {
      const size = Size(340, 230);
      final r = readingRounds.firstWhere((x) => x.answer == Reading.real);
      final frame = Frame.over([r.specimen], headroom: 1.85);
      final real =
          BothPainter.pointsOf(r.specimen, frame, size, BothPainter.truth);
      final plain = BothPainter.pointsOf(
          r.specimen, frame, size, BothPainter.engineering);
      expect(BothPainter.nearest(r.specimen, frame, size, real.last),
          BothPainter.truth);
      expect(BothPainter.nearest(r.specimen, frame, size, plain.last),
          BothPainter.engineering);
    });

    test('the whole of both curves stays on the panel', () {
      const size = Size(340, 230);
      for (final r in readingRounds) {
        final frame = Frame.over([r.specimen], headroom: 1.85);
        for (final which in [BothPainter.engineering, BothPainter.truth]) {
          for (final p in BothPainter.pointsOf(r.specimen, frame, size, which)) {
            expect(p.dy, greaterThanOrEqualTo(0),
                reason: '${r.subject} runs off the top');
            expect(p.dy, lessThanOrEqualTo(size.height),
                reason: '${r.subject} runs off the bottom');
          }
        }
      }
    });

    test('all three answers are used', () {
      expect(readingRounds.map((r) => r.answer).toSet(), Reading.values.toSet());
    });
  });

  group('the fracture formula reproduces the lesson', () {
    test('the steel plate with a ten millimeter edge crack holds 236', () {
      const plate = Plate(
        flaw: Flaw.edgeLeft,
        crackMm: 10,
        stress: 200,
        toughness: 46,
        material: 'steel',
      );
      expect(plate.y, 1.1);
      expect(plate.a, closeTo(0.010, 1e-12));
      expect(plate.criticalStress, closeTo(236, 1));

      // Its named slips: the interior factor, and the factor squared.
      const asInternal = Plate(
        flaw: Flaw.internal,
        crackMm: 20,
        stress: 200,
        toughness: 46,
        material: 'steel',
      );
      expect(asInternal.a, closeTo(0.010, 1e-12));
      expect(asInternal.criticalStress, closeTo(260, 1));
      expect(46 / (1.21 * math.sqrt(math.pi * 0.01)), closeTo(215, 1));
      // And the crack left in millimeters.
      expect(46 / (1.1 * math.sqrt(math.pi * 10)), closeTo(7.5, 0.1));
    });

    test('the aluminum part tolerates a 3.8 millimeter edge crack', () {
      const plate = Plate(
        flaw: Flaw.edgeLeft,
        crackMm: 1,
        stress: 200,
        toughness: 24,
        material: 'aluminum',
      );
      expect(plate.criticalCrackMm, closeTo(3.8, 0.1));

      // With the interior factor instead, 4.6, which is the named slip.
      const asInternal = Plate(
        flaw: Flaw.internal,
        crackMm: 1,
        stress: 200,
        toughness: 24,
        material: 'aluminum',
      );
      expect(asInternal.criticalCrackMm / 2, closeTo(4.6, 0.1));
    });
  });

  group('edge-or-inside offers one right reading', () {
    test('the answer follows from where the crack is', () {
      for (final r in crackRounds) {
        expect(r.answer.y, r.plate.y, reason: r.subject);
        expect(r.answer.half, !r.plate.flaw.isEdge, reason: r.subject);
      }
    });

    test('every round offers all four readings, once each', () {
      for (final r in crackRounds) {
        expect(r.options.toSet().length, 4, reason: r.subject);
        expect(r.options.contains(r.answer), isTrue, reason: r.subject);
      }
    });

    test('no two choices in a round read the same', () {
      for (final r in crackRounds) {
        final labels = r.options.map(r.labelFor).toSet();
        expect(labels.length, r.options.length, reason: r.subject);
      }
    });

    test('the right answer is not always in the same place', () {
      final spots = crackRounds.map((r) => r.options.indexOf(r.answer)).toSet();
      expect(spots.length, greaterThan(2));
    });

    test('both geometries are asked about', () {
      expect(crackRounds.map((r) => r.plate.flaw.isEdge).toSet(), {true, false});
    });

    test('the crack is drawn inside the plate it is in', () {
      const size = Size(340, 180);
      final box = PlatePainter.body(size);
      for (final r in crackRounds) {
        final (from, to) = PlatePainter.crackLine(r.plate, size);
        expect(from.dx, greaterThanOrEqualTo(box.left - 0.01), reason: r.subject);
        expect(to.dx, lessThanOrEqualTo(box.right + 0.01), reason: r.subject);
        expect(to.dx - from.dx, greaterThan(14),
            reason: '${r.subject}: the crack is too small to see');
        if (r.plate.flaw == Flaw.internal) {
          expect(from.dx, greaterThan(box.left + 8),
              reason: '${r.subject}: an internal crack must not touch an edge');
          expect(to.dx, lessThan(box.right - 8), reason: r.subject);
        }
      }
    });
  });

  group('which-cracks-first is callable without a calculator', () {
    test('the answer is whichever has used more of its toughness', () {
      for (final r in firstRounds) {
        switch (r.answer) {
          case Goes.left:
            expect(r.left.usedUp, greaterThan(r.right.usedUp),
                reason: r.subject);
          case Goes.right:
            expect(r.right.usedUp, greaterThan(r.left.usedUp),
                reason: r.subject);
          case Goes.together:
            expect(r.left.usedUp, closeTo(r.right.usedUp, 1e-9),
                reason: r.subject);
        }
      }
    });

    test('a round with a winner has a clear one', () {
      for (final r in firstRounds.where((r) => r.answer != Goes.together)) {
        expect(r.ratio, greaterThan(1.3),
            reason: '${r.subject}: too close to call by eye');
      }
    });

    test('the round that cancels really cancels', () {
      final tie = firstRounds.firstWhere((r) => r.answer == Goes.together);
      expect(tie.right.crackMm, tie.left.crackMm * 4);
      expect(tie.right.stress, tie.left.stress / 2);
      expect(tie.left.driving, closeTo(tie.right.driving, 1e-9));
    });

    test('no plate is already broken before the round starts', () {
      for (final r in firstRounds) {
        expect(r.left.broken, isFalse, reason: r.subject);
        expect(r.right.broken, isFalse, reason: r.subject);
      }
    });

    test('all three answers are used', () {
      expect(firstRounds.map((r) => r.answer).toSet(), Goes.values.toSet());
    });

    test('the pair that measures the same is drawn the same', () {
      // The round about an edge crack against an internal one of the same
      // length would be a trick if the drawing gave it away by length.
      final r = firstRounds
          .firstWhere((x) => x.subject.contains('an internal one'));
      expect(r.left.crackMm, r.right.crackMm);
      expect(r.left.flaw.isEdge, isTrue);
      expect(r.right.flaw.isEdge, isFalse);
    });
  });

  group('thermal movement reproduces the lesson', () {
    test('the twenty five meter girder moves 10.2 millimeters', () {
      const girder =
          Member(stuff: Stuff.steel, meters: 25, from: 5, to: 40);
      expect(girder.change, 35);
      expect(girder.movement, closeTo(10.24, 0.02));

      // The named slips: adding the temperatures, and the 25 read as a
      // temperature change rather than a length.
      const added = Member(stuff: Stuff.steel, meters: 25, from: -5, to: 40);
      expect(added.change, 45);
      expect(added.movement, closeTo(13.2, 0.05));
      expect(11.7e-6 * 25000 * 25, closeTo(7.3, 0.05));
      expect(11.7e-6 * 2500 * 35, closeTo(1.02, 0.02));
    });

    test('the lesson\'s three coefficients are the ones used', () {
      expect(Stuff.steel.alpha, 11.7e-6);
      expect(Stuff.concrete.alpha, 10e-6);
      expect(Stuff.aluminum.alpha, 23e-6);
    });

    test('every round can be called without a calculator', () {
      for (final r in growRounds.where((r) => r.answer != Biggest.same)) {
        expect(r.lead, greaterThan(1.4),
            reason: '${r.subject}: the top two are too close');
      }
    });

    test('the round about thickness is an exact tie', () {
      final tie = growRounds.firstWhere((r) => r.answer == Biggest.same);
      final travels = tie.members.map((m) => m.travel).toSet();
      expect(travels.length, 1);
      expect(tie.members.map((m) => m.note).toSet().length, 3,
          reason: 'the three have to differ in something, or there is no '
              'question');
    });

    test('the answer matches the arithmetic in every round', () {
      for (final r in growRounds) {
        final travels = [for (final m in r.members) m.travel];
        final best = travels.reduce((a, b) => a > b ? a : b);
        switch (r.answer) {
          case Biggest.top:
            expect(travels[0], best, reason: r.subject);
          case Biggest.middle:
            expect(travels[1], best, reason: r.subject);
          case Biggest.bottom:
            expect(travels[2], best, reason: r.subject);
          case Biggest.same:
            expect(travels.toSet().length, 1, reason: r.subject);
        }
      }
    });

    test('all four answers are used', () {
      expect(growRounds.map((r) => r.answer).toSet(), Biggest.values.toSet());
    });

    test('a tap lands in the row it looks like', () {
      const size = Size(340, 270);
      for (var i = 0; i < 3; i++) {
        expect(MemberPainter.rowAt(size, Offset(100, MemberPainter.rowY(size, i))),
            i);
      }
    });
  });

  group('the furnace rounds follow the lesson\'s own rule', () {
    test('fast from austenite is martensite, slow is the soft pair', () {
      for (final r in furnaceRounds) {
        final cool = r.cool;
        if (!cool.wasAustenite) {
          expect(r.answer, Comes.unchanged, reason: r.subject);
          continue;
        }
        // How long it took to come down through the transformation.
        final crossing = _throughTheChange(cool);
        switch (r.answer) {
          case Comes.hardBrittle:
          case Comes.hardTough:
            expect(crossing, lessThan(1),
                reason: '${r.subject}: martensite needs a fast drop');
          case Comes.softDuctile:
            expect(crossing, greaterThan(1),
                reason: '${r.subject}: the soft pair needs a slow one');
          case Comes.unchanged:
            fail('${r.subject}: it was austenite, so something happened');
        }
      }
    });

    test('the tempered round is the only one that goes back up', () {
      for (final r in furnaceRounds) {
        // A reheat is a rise AFTER the route has left its peak. The first
        // climb into the furnace is not one.
        var peak = 0;
        for (var i = 1; i < r.cool.legs.length; i++) {
          if (r.cool.legs[i].dy > r.cool.legs[peak].dy) peak = i;
        }
        var reheated = false;
        for (var i = peak + 1; i < r.cool.legs.length; i++) {
          if (r.cool.legs[i].dy > r.cool.legs[i - 1].dy + 1) reheated = true;
        }
        expect(reheated, r.answer == Comes.hardTough, reason: r.subject);
      }
    });

    test('every round offers all four outcomes, once each', () {
      for (final r in furnaceRounds) {
        expect(r.options.toSet().length, 4, reason: r.subject);
        expect(r.options.contains(r.answer), isTrue, reason: r.subject);
      }
    });

    test('the right answer moves around', () {
      final spots =
          furnaceRounds.map((r) => r.options.indexOf(r.answer)).toSet();
      expect(spots.length, greaterThan(2));
    });

    test('all four outcomes are the answer somewhere', () {
      expect(furnaceRounds.map((r) => r.answer).toSet(), Comes.values.toSet());
    });

    test('every route ends at room temperature', () {
      for (final r in furnaceRounds) {
        expect(r.cool.legs.last.dy, lessThan(40), reason: r.subject);
      }
    });
  });

  group('the lever rule is drawn the way it works', () {
    test('the lesson\'s own tie line gives its own answer', () {
      const tie = Tie(solid: 10, overall: 30, liquid: 40);
      expect(tie.liquidShare, closeTo(0.667, 0.001));
      expect(tie.solidShare, closeTo(0.333, 0.001));
      expect(tie.liquidShare + tie.solidShare, closeTo(1, 1e-12));
      // The named slips: the arms swapped, the alloy over the liquid, and a
      // denominator measured from zero.
      expect(tie.toLiquid / tie.whole, closeTo(0.333, 0.001));
      expect(tie.overall / tie.liquid, closeTo(0.75, 0.001));
      expect(tie.toSolid / tie.liquid, closeTo(0.5, 0.001));
    });

    test('an alloy near a boundary is mostly that phase', () {
      final near = tieRounds
          .firstWhere((r) => r.subject.contains('close to the solid'));
      expect(near.tie.liquidShare, lessThan(0.25));
      final far = tieRounds
          .firstWhere((r) => r.subject.contains('close to the liquid'));
      expect(far.tie.solidShare, lessThan(0.3));
    });

    test('the halfway round really is halfway', () {
      final half =
          tieRounds.firstWhere((r) => r.subject.contains('halfway'));
      expect(half.tie.liquidShare, closeTo(0.5, 1e-9));
    });

    test('every alloy sits between its two boundaries', () {
      for (final r in tieRounds) {
        expect(r.tie.overall, greaterThan(r.tie.solid), reason: r.subject);
        expect(r.tie.overall, lessThan(r.tie.liquid), reason: r.subject);
      }
    });

    test('all three pieces get asked for', () {
      expect(tieRounds.map((r) => r.answer).toSet(), Arm.values.toSet());
    });

    test('the three bars never overlap, and a tap finds each', () {
      const size = Size(340, 255);
      for (final r in tieRounds) {
        final bars = {
          for (final a in Arm.values) a: TiePainter.barOf(size, r.tie, a)
        };
        expect(bars[Arm.toSolid]!.overlaps(bars[Arm.toLiquid]!), isFalse,
            reason: r.subject);
        for (final a in Arm.values) {
          expect(bars[a]!.width, greaterThan(24),
              reason: '${r.subject}: ${a.name} is too narrow to tap');
          expect(TiePainter.nearest(size, r.tie, bars[a]!.center), a,
              reason: r.subject);
        }
      }
    });
  });
}

/// How long a route spends coming down through the austenite line, in the
/// route's own hours. Short is a quench.
double _throughTheChange(Cool cool) {
  for (var i = 1; i < cool.legs.length; i++) {
    final a = cool.legs[i - 1];
    final b = cool.legs[i];
    if (a.dy > Cool.austenite && b.dy < Cool.austenite) {
      final share = (a.dy - Cool.austenite) / (a.dy - b.dy);
      final crossed = a.dx + (b.dx - a.dx) * share;
      // From the crossing to the end of that leg is the drop itself.
      return b.dx - crossed;
    }
  }
  return double.infinity;
}
