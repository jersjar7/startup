import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/before_or_during_game.dart';
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
}
