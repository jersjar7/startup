import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/buckle_or_squash_game.dart';
import 'package:mobile/features/games/column_figures.dart';
import 'package:mobile/features/games/what_are_the_ends_worth_game.dart';
import 'package:mobile/features/games/which_way_does_it_fold_game.dart';

/// Chapter seven, lesson nine. The engine is held against the lesson's own
/// three answers and against the wrong ones it names.
void main() {
  group('the engine reproduces the lesson it was built from', () {
    test('the pinned four meter column carries 2,467 kilonewtons', () {
      // Problem one: 4 m, pinned both ends, I = 20 million, E = 200 GPa.
      const post = Post(
        length: 4000,
        top: End.pinned,
        bottom: End.pinned,
        i: 20e6,
      );
      expect(post.k, 1.0);
      expect(post.criticalLoad / 1000, closeTo(2467, 1));

      // Its named wrong answers, each of them the wrong K: the cantilever
      // value quarters it, the fixed-fixed value quadruples it, and a K of
      // four divides it by sixteen.
      double withK(double k) =>
          math.pi * math.pi * 200000 * 20e6 / math.pow(k * 4000, 2) / 1000;
      expect(withK(2), closeTo(617, 1));
      expect(withK(0.5), closeTo(9870, 2));
      expect(withK(4), closeTo(154, 1));
    });

    test('one end fixed and one pinned carries 2,420 kilonewtons', () {
      // Problem two: 5 m, fixed and pinned, I = 15 million.
      const post = Post(
        length: 5000,
        top: End.pinned,
        bottom: End.fixed,
        i: 15e6,
      );
      expect(post.k, 0.7);
      expect(post.effectiveLength, closeTo(3500, 1e-9));
      // The lesson rounds this to 2,420.
      expect(post.criticalLoad / 1000, closeTo(2420, 4));

      // The first named wrong K value checks out.
      double withK(double k) =>
          math.pi * math.pi * 200000 * 15e6 / math.pow(k * 5000, 2) / 1000;
      expect(withK(1), closeTo(1184, 1));
      // And so do the other two, now that they are the fixed-fixed and the
      // cantilever values for THIS column.
      expect(withK(0.5), closeTo(4737, 2));
      expect(withK(2), closeTo(296, 1));
    });

    test('the slender column buckles at 87.7 megapascals', () {
      // Problem three: 6 m, pinned both ends, r = 40, yield 250.
      const post = Post(
        length: 6000,
        top: End.pinned,
        bottom: End.pinned,
        radius: 40,
        area: 5000,
      );
      expect(post.slenderness, closeTo(150, 1e-9));
      expect(post.criticalStress, closeTo(87.7, 0.05));
      expect(post.governs, Governs.buckling);

      // Its named wrong answer: half the slenderness gives four times the
      // stress, which is above yield and so could not happen anyway.
      expect(math.pi * math.pi * 200000 / (75 * 75), closeTo(351, 1));
      expect(351, greaterThan(post.yieldStress));
    });
  });

  group('what the four cases mean', () {
    Post ends(End top, End bottom) =>
        Post(length: 4000, top: top, bottom: bottom);

    test('the handbook has exactly four, and they come out right', () {
      expect(ends(End.pinned, End.pinned).k, 1.0);
      expect(ends(End.fixed, End.fixed).k, 0.5);
      expect(ends(End.fixed, End.pinned).k, 0.7);
      expect(ends(End.pinned, End.fixed).k, 0.7);
      expect(ends(End.free, End.fixed).k, 2.0);
      expect(ends(End.fixed, End.free).k, 2.0);
    });

    test('a cantilever column is sixteen times weaker than a fixed one', () {
      // The lesson's own warning, as a number: K goes from a half to two, so
      // the effective length quadruples and the load falls by sixteen.
      final fixed = ends(End.fixed, End.fixed);
      final cantilever = ends(End.fixed, End.free);
      expect(fixed.criticalLoad / cantilever.criticalLoad, closeTo(16, 1e-9));
    });

    test('fixing the ends never makes a column weaker', () {
      final pinned = ends(End.pinned, End.pinned);
      expect(ends(End.fixed, End.pinned).criticalLoad,
          greaterThan(pinned.criticalLoad));
      expect(ends(End.fixed, End.fixed).criticalLoad,
          greaterThan(pinned.criticalLoad));
      expect(ends(End.fixed, End.free).criticalLoad,
          lessThan(pinned.criticalLoad));
    });

    test('the buckled shape says where the effective length comes from', () {
      // A pinned end has to be a point of zero deflection; a fixed end has to
      // leave the support straight; a free end does neither.
      for (final pair in [
        (End.pinned, End.pinned),
        (End.fixed, End.fixed),
        (End.pinned, End.fixed),
        (End.free, End.fixed),
        // And the same two the other way up, which the drawing has to follow.
        (End.fixed, End.pinned),
        (End.fixed, End.free),
      ]) {
        final post = ends(pair.$1, pair.$2);
        final shape = buckledShape(post);
        // A held end cannot have moved sideways; a free end swings furthest.
        for (final (end, point) in [
          (post.bottom, shape.first),
          (post.top, shape.last),
        ]) {
          if (end == End.free) {
            expect(point.dy.abs(), closeTo(1, 1e-9),
                reason: 'a free end should swing furthest on a '
                    '${post.k} column');
          } else {
            expect(point.dy.abs(), lessThan(1e-9),
                reason: 'a held end of a ${post.k} column has moved sideways');
          }
        }
        // A fixed end leaves its support without turning, so the curve is
        // flat there: the first step is smaller than the next one.
        if (post.bottom == End.fixed) {
          expect(shape[1].dy.abs(),
              lessThan((shape[2].dy - shape[1].dy).abs() + 1e-12),
              reason: 'a fixed base is not drawn leaving straight');
        }
      }
    });
  });

  group('long columns and short ones', () {
    test('the crossover is where Euler meets yield', () {
      const post = Post(length: 4000, top: End.pinned, bottom: End.pinned);
      expect(post.transition, closeTo(88.86, 0.02));
      // At that slenderness the two stresses really are the same number.
      final atCross =
          math.pi * math.pi * post.e / math.pow(post.transition, 2);
      expect(atCross, closeTo(post.yieldStress, 1e-6));
    });

    test('a stronger steel does nothing for a slender column', () {
      // Euler has no yield stress in it at all, which is the fact worth
      // carrying out of this lesson.
      const mild = Post(
        length: 6000,
        top: End.pinned,
        bottom: End.pinned,
        radius: 40,
      );
      const strong = Post(
        length: 6000,
        top: End.pinned,
        bottom: End.pinned,
        radius: 40,
        yieldStress: 450,
      );
      expect(strong.criticalStress, closeTo(mild.criticalStress, 1e-9));
      expect(strong.criticalLoad, closeTo(mild.criticalLoad, 1e-9));
      // What it DOES change is where the crossover sits.
      expect(strong.transition, lessThan(mild.transition));
    });

    test('a stubby column yields instead of buckling', () {
      const stub = Post(
        length: 1600,
        top: End.pinned,
        bottom: End.pinned,
        radius: 40,
      );
      expect(stub.slenderness, closeTo(40, 1e-9));
      expect(stub.criticalStress, greaterThan(stub.yieldStress));
      expect(stub.governs, Governs.yielding);
    });

    test('right at the crossover, neither one governs cleanly', () {
      const borderline = Post(
        length: 3556,
        top: End.pinned,
        bottom: End.pinned,
        radius: 40,
      );
      expect(borderline.slenderness, closeTo(88.9, 0.1));
      expect(borderline.governs, Governs.together);
    });
  });

  group('the column curve is drawn where the arithmetic says', () {
    const size = Size(300, 180);

    test('a slender column is marked to the right of the crossover', () {
      const post = Post(
        length: 6000,
        top: End.pinned,
        bottom: End.pinned,
        radius: 40,
      );
      const painter = ColumnCurvePainter(post: post);
      final mark = painter.markAt(size);
      const at = ColumnCurvePainter(
        post: Post(
          length: 3556,
          top: End.pinned,
          bottom: End.pinned,
          radius: 40,
        ),
      );
      expect(mark.dx, greaterThan(at.markAt(size).dx));
      // And lower down the page, because a longer column fails at less.
      expect(mark.dy, greaterThan(at.markAt(size).dy));
    });

    test('the mark stays inside the box whatever the column', () {
      for (final length in [1200.0, 3000.0, 6000.0, 9000.0]) {
        final post = Post(
          length: length,
          top: End.pinned,
          bottom: End.pinned,
          radius: 40,
        );
        final mark = ColumnCurvePainter(post: post).markAt(size);
        expect(mark.dx, inInclusiveRange(0, size.width));
        expect(mark.dy, inInclusiveRange(0, size.height));
      }
    });
  });

  group('what-are-the-ends-worth draws the column it scores', () {
    test('every round answers with one of the four table values', () {
      for (final r in endsRounds) {
        expect(EndsRound.values.contains(r.post.k), isTrue,
            reason: '${r.subject}: K is not one of the four');
        expect(r.answer, isNot(-1));
      }
    });

    test('all four cases are covered', () {
      expect(endsRounds.map((r) => r.post.k).toSet(),
          EndsRound.values.toSet());
    });

    test('the drawing and the factor cannot disagree', () {
      // K comes off the two ends, and the two ends are what gets drawn, so a
      // round cannot show one arrangement and score another.
      for (final r in endsRounds) {
        final ends = {r.post.top, r.post.bottom};
        if (ends.contains(End.free)) {
          expect(r.post.k, 2.0, reason: '${r.subject}');
        } else if (ends.length == 1 && r.post.top == End.fixed) {
          expect(r.post.k, 0.5, reason: '${r.subject}');
        } else if (ends.length == 1) {
          expect(r.post.k, 1.0, reason: '${r.subject}');
        } else {
          expect(r.post.k, 0.7, reason: '${r.subject}');
        }
      }
    });

    test('the same two ends the other way up score the same', () {
      final upright = endsRounds.firstWhere(
          (r) => r.post.bottom == End.fixed && r.post.top == End.pinned);
      final inverted = endsRounds.firstWhere(
          (r) => r.post.top == End.fixed && r.post.bottom == End.pinned);
      expect(upright.post.k, inverted.post.k);
      expect(upright.answer, inverted.answer);
    });
  });

  group('which-way-does-it-fold reads the section', () {
    test('the answer is the axis with the smaller second moment', () {
      for (final r in foldRounds) {
        final x = r.section.ownIx;
        final y = r.section.ownIy;
        switch (r.answer) {
          case About.horizontal:
            expect(x, lessThan(y), reason: '${r.subject}');
          case About.vertical:
            expect(y, lessThan(x), reason: '${r.subject}');
          case About.either:
            expect((x - y).abs() / x, lessThan(0.02), reason: '${r.subject}');
        }
      }
    });

    test('the difference is big enough to see, where there is one', () {
      // A section whose two second moments are within a few percent cannot be
      // judged by looking, so a round either has a clear weak axis or is one
      // of the deliberately symmetric ones.
      for (final r in foldRounds) {
        if (r.answer == About.either) continue;
        final ratio = r.section.ownIx / r.section.ownIy;
        final apart = ratio > 1 ? ratio : 1 / ratio;
        expect(apart, greaterThan(1.4),
            reason: '${r.subject}: the two axes are too close to call by eye');
      }
    });

    test('all three answers are used', () {
      expect(foldRounds.map((r) => r.answer).toSet(), About.values.toSet());
    });

    test('turning a section over moves the weak axis with it', () {
      final onEdge = foldRounds[1];
      final flat = foldRounds[2];
      expect(onEdge.answer, About.vertical);
      expect(flat.answer, About.horizontal);
      // And the column is exactly as strong either way, which is the point.
      expect(
        onEdge.section.ownIx < onEdge.section.ownIy
            ? onEdge.section.ownIx
            : onEdge.section.ownIy,
        closeTo(
          flat.section.ownIx < flat.section.ownIy
              ? flat.section.ownIx
              : flat.section.ownIy,
          1,
        ),
      );
    });
  });

  group('buckle-or-squash is decided by the curve', () {
    test('every verdict comes out of the column, not the round', () {
      for (final r in slenderRounds) {
        final ratio = r.post.criticalStress / r.post.yieldStress;
        switch (r.answer) {
          case Governs.buckling:
            expect(ratio, lessThan(0.95), reason: '${r.subject}');
          case Governs.yielding:
            expect(ratio, greaterThan(1.05), reason: '${r.subject}');
          case Governs.together:
            expect(ratio, inInclusiveRange(0.95, 1.05),
                reason: '${r.subject}');
        }
      }
    });

    test('all three verdicts appear', () {
      expect(slenderRounds.map((r) => r.answer).toSet(),
          Governs.values.toSet());
    });

    test('the stronger steel rounds differ only in the steel', () {
      final mild = slenderRounds.first;
      final strong = slenderRounds[3];
      expect(strong.post.length, mild.post.length);
      expect(strong.post.radius, mild.post.radius);
      expect(strong.post.yieldStress, greaterThan(mild.post.yieldStress));
      // Same column, same buckling stress: Euler cannot see the strength.
      expect(strong.post.criticalStress,
          closeTo(mild.post.criticalStress, 1e-9));
      expect(strong.answer, mild.answer);
    });

    test('the flagpole round is slender because of its ends', () {
      final pole = slenderRounds.last;
      expect(pole.post.length, lessThan(slenderRounds.first.post.length));
      expect(pole.post.k, 2.0);
      // Shorter column, same slenderness, because the effective length is
      // what counts.
      expect(pole.post.slenderness,
          closeTo(slenderRounds.first.post.slenderness, 1e-9));
    });
  });
}
