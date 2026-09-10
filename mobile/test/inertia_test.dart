import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/move_it_right_game.dart';
import 'package:mobile/features/games/rank_by_stiffness_game.dart';
import 'package:mobile/features/games/section_figures.dart';
import 'package:mobile/features/games/which_barely_matters_game.dart';
import 'package:mobile/features/games/which_second_moment_game.dart';

/// Lesson forty two, area moments of inertia. The table values the items lean
/// on are checked by counting the shape rather than by repeating the formula,
/// and all three lesson answers are reproduced along with the wrong ones the
/// lesson names beside them.
void main() {
  /// The second moments of a shape, found by sampling it. Shares no algebra
  /// with the handbook formulas the app uses.
  ({double ix, double iy}) byCounting(Piece piece) {
    final path = piece.outline();
    final box = piece.box;
    const steps = 460;
    final dx = box.width / steps;
    final dy = box.height / steps;
    final cell = dx * dy;
    final c = piece.centroid;
    var ix = 0.0;
    var iy = 0.0;
    for (var i = 0; i < steps; i++) {
      final x = box.left + (i + 0.5) * dx;
      for (var j = 0; j < steps; j++) {
        final y = box.top + (j + 0.5) * dy;
        if (!path.contains(Offset(x, y))) continue;
        ix += (y - c.dy) * (y - c.dy) * cell;
        iy += (x - c.dx) * (x - c.dx) * cell;
      }
    }
    return (ix: ix, iy: iy);
  }

  Iterable<Piece> everyPiece() sync* {
    for (final r in rankRounds) {
      for (final s in r.shapes) {
        yield* s.pieces;
      }
    }
    for (final r in axisRounds) {
      yield* r.profile.pieces;
    }
    for (final r in shareRounds) {
      yield* r.profile.pieces;
    }
  }

  group('every shape knows its own second moment', () {
    test('counting the shape agrees with the table value', () {
      for (final piece in everyPiece()) {
        final counted = byCounting(piece);
        expect(counted.ix, closeTo(piece.ownIx, piece.ownIx * 0.02),
            reason: 'a ${piece.kind.name} of ${piece.box.size} has the wrong '
                'Ix');
        expect(counted.iy, closeTo(piece.ownIy, piece.ownIy * 0.02),
            reason: 'a ${piece.kind.name} of ${piece.box.size} has the wrong '
                'Iy');
      }
    });

    test('the dimension square to the axis is the one that gets cubed', () {
      // The trap in the lesson's first problem, stated as a property.
      const tall = Piece(Slab.box, Offset.zero, Size(50, 200));
      const wide = Piece(Slab.box, Offset.zero, Size(200, 50));
      expect(tall.ownIx, closeTo(wide.ownIy, 0.001));
      expect(tall.ownIx / tall.ownIy, closeTo(16, 0.001));
    });
  });

  group('the lesson answers come out of the engine', () {
    test('the rectangle is three point three seven five times ten to the ei'
        'ght', () {
      // Problem one: 150 wide by 300 tall, about its own centroidal x axis.
      const bar = Profile([Piece(Slab.box, Offset.zero, Size(150, 300))]);
      expect(bar.ownIx, closeTo(3.375e8, 1e5));
      // The named wrong answers: about the base, and the two swapped over.
      expect(bar.iAboutX(0), closeTo(1.35e9, 1e6));
      expect(bar.ownIy, closeTo(8.4375e7, 1e4));
    });

    test('the parallel axis move comes out at sixteen point six seven', () {
      // Problem two: 50 by 100, from the centroid down to the base.
      const bar = Profile([Piece(Slab.box, Offset.zero, Size(50, 100))]);
      expect(bar.ownIx, closeTo(4.1667e6, 1e3));
      final transfer = bar.area * 50 * 50;
      expect(transfer, closeTo(12.5e6, 1e3));
      expect(bar.iAboutX(0), closeTo(16.667e6, 1e3));
      // And the direct formula agrees, which is the lesson's own check.
      expect(bar.iAboutX(0), closeTo(50 * 100 * 100 * 100 / 3, 1e3));
    });

    test('the composite T is three point three three times ten to the six', () {
      // Problem three: the same T as the centroid lesson, about its own axis.
      const tee = Profile([
        Piece(Slab.box, Offset(50, 0), Size(20, 80)),
        Piece(Slab.box, Offset(0, 80), Size(120, 20)),
      ]);
      expect(tee.centroid.dy, closeTo(70, 0.05));
      expect(tee.ownIx, closeTo(3.3333e6, 1e3));
      expect(tee.shareOf(0), closeTo(2.2933e6, 1e3));
      expect(tee.shareOf(1), closeTo(1.04e6, 1e3));
      // The two named wrong answers: the centroidal terms alone, and the
      // transfer terms alone.
      final ownOnly = tee.pieces.fold(0.0, (sum, p) => sum + p.ownIx);
      expect(ownOnly, closeTo(0.9333e6, 1e3));
      expect(tee.ownIx - ownOnly, closeTo(2.40e6, 1e3));
    });

    test('the centroidal axis is where a section is floppiest', () {
      // The sign rule behind the whole second item, as a property rather than
      // as a sentence.
      for (final r in axisRounds) {
        final home = r.profile.ownIx;
        for (final away in [-40.0, -5.0, 5.0, 40.0]) {
          expect(r.profile.iAboutX(r.profile.centroid.dy + away),
              greaterThan(home));
        }
      }
    });
  });

  group('ranking sections by stiffness', () {
    /// Worked out by hand from the drawings, stiffest first.
    const expected = <int, List<int>>{
      0: [1, 2, 0],
      1: [1, 0, 2],
      2: [2, 0, 1],
      3: [2, 0, 1],
      4: [1, 2, 0],
      5: [2, 0, 1],
    };

    test('the app and the hand-worked order agree', () {
      for (var i = 0; i < rankRounds.length; i++) {
        expect(rankRounds[i].answer, expected[i],
            reason: 'round ${i + 1} of rank-by-stiffness');
      }
    });

    test('each step down the order is big enough to see', () {
      // Two sections within a few per cent of each other are a coin toss.
      for (var i = 0; i < rankRounds.length; i++) {
        final r = rankRounds[i];
        for (var k = 0; k + 1 < r.answer.length; k++) {
          final more = r.shapes[r.answer[k]].ownIx;
          final less = r.shapes[r.answer[k + 1]].ownIx;
          expect(more / less, greaterThan(1.5),
              reason: 'round ${i + 1}: two of these are too close to rank by '
                  'eye');
        }
      }
    });

    test('the rounds that claim equal area really have it', () {
      for (final i in [0, 1, 2, 4]) {
        final areas = rankRounds[i].shapes.map((s) => s.area).toList();
        for (final a in areas) {
          expect(a, closeTo(areas.first, areas.first * 0.02),
              reason: 'round ${i + 1} says the sections match and they do '
                  'not');
        }
      }
    });

    test('the same-depth round really has one depth', () {
      // Round three claims the I-beam and the solid rectangle share a depth,
      // which is what makes the comparison mean anything. The square beside
      // them only shares the area.
      final beam = rankRounds[2].shapes[2].bounds.height;
      final solid = rankRounds[2].shapes[0].bounds.height;
      expect(beam, closeTo(solid, 0.5),
          reason: 'the I-beam round no longer compares like with like');
    });

    test('every round offers three, and the answer covers all of them', () {
      for (var i = 0; i < rankRounds.length; i++) {
        final r = rankRounds[i];
        expect(r.shapes.length, 3);
        expect(r.answer.toSet().length, 3,
            reason: 'round ${i + 1} ranks one section twice');
      }
    });

    test('no two sections are tapped in the same place', () {
      const size = Size(360, 215);
      for (var i = 0; i < rankRounds.length; i++) {
        final r = rankRounds[i];
        final cells = [
          for (var k = 0; k < r.shapes.length; k++)
            LineUpPainter.cellFor(r.shapes, size, k),
        ];
        for (var a = 0; a < cells.length; a++) {
          expect(cells[a].width, greaterThan(44),
              reason: 'round ${i + 1}: a section is too narrow to tap');
          for (var b = a + 1; b < cells.length; b++) {
            expect(cells[a].overlaps(cells[b]), isFalse,
                reason: 'round ${i + 1}: two sections share a tap target');
          }
        }
      }
    });

    test('the three sections are drawn to one scale', () {
      // Two shapes each stretched to fill their own cell cannot be compared,
      // and comparing them is the entire item.
      const size = Size(360, 215);
      for (final r in rankRounds) {
        final s = LineUpPainter.scaleFor(r.shapes, size);
        expect(s, greaterThan(0));
        for (final shape in r.shapes) {
          expect(shape.bounds.width * s,
              lessThanOrEqualTo(LineUpPainter.cellFor(r.shapes, size, 0).width),
              reason: 'a section is drawn wider than its cell');
        }
      }
    });
  });

  group('moving between axes', () {
    const expected = <int, Transfer>{
      0: Transfer.add,
      1: Transfer.subtract,
      2: Transfer.cannot,
      3: Transfer.add,
      4: Transfer.subtract,
      5: Transfer.cannot,
    };

    test('the app and the hand-worked set agree', () {
      for (var i = 0; i < axisRounds.length; i++) {
        expect(axisRounds[i].answer, expected[i],
            reason: 'round ${i + 1} of move-it-right');
      }
    });

    test('a round that cannot go really has neither axis on the centroid', () {
      for (var i = 0; i < axisRounds.length; i++) {
        final r = axisRounds[i];
        if (r.answer != Transfer.cannot) continue;
        for (final d in [r.from, r.to]) {
          expect((d.y - r.profile.centroid.dy).abs(),
              greaterThan(r.profile.bounds.height * 0.05),
              reason: 'round ${i + 1} has an axis close enough to the centroid '
                  'to argue about');
        }
      }
    });

    test('a round that does go has exactly one axis on the centroid', () {
      for (var i = 0; i < axisRounds.length; i++) {
        final r = axisRounds[i];
        if (r.answer == Transfer.cannot) continue;
        final on = [r.from, r.to]
            .where((d) => (d.y - r.profile.centroid.dy).abs() < 0.01)
            .length;
        expect(on, 1, reason: 'round ${i + 1} has $on centroidal axes');
      }
    });

    test('the two axes of a round are never the same line', () {
      for (var i = 0; i < axisRounds.length; i++) {
        final r = axisRounds[i];
        expect((r.from.y - r.to.y).abs(),
            greaterThan(r.profile.bounds.height * 0.05),
            reason: 'round ${i + 1} draws its two axes on top of each other');
      }
    });

    test('every answer appears and none of them dominates', () {
      final counts = {
        for (final v in Transfer.values)
          v: axisRounds.where((r) => r.answer == v).length,
      };
      for (final v in Transfer.values) {
        expect(counts[v], greaterThanOrEqualTo(1), reason: '${v.name} never');
      }
      expect(counts.values.reduce(math.max), lessThanOrEqualTo(3));
    });
  });

  group('which property a job needs', () {
    const expected = <int, Needs>{
      0: Needs.iAboutX,
      1: Needs.iAboutY,
      2: Needs.polarJ,
      3: Needs.polarJ,
      4: Needs.iAboutX,
      5: Needs.iAboutY,
    };

    test('the app and the hand-worked set agree', () {
      for (var i = 0; i < jobRounds.length; i++) {
        expect(jobRounds[i].answer, expected[i],
            reason: 'round ${i + 1} of which-second-moment');
      }
    });

    test('a bending round bends about the axis square to the load', () {
      // The rule the item exists to teach, checked as a property rather than
      // taken on trust from the round that declares the load.
      for (var i = 0; i < jobRounds.length; i++) {
        final r = jobRounds[i];
        if (r.job.twists) continue;
        final downward = r.job.load.dy.abs() > r.job.load.dx.abs();
        expect(r.answer, downward ? Needs.iAboutX : Needs.iAboutY,
            reason: 'round ${i + 1} bends about the wrong axis for its load');
      }
    });

    test('a twisting round has no push on it at all', () {
      for (var i = 0; i < jobRounds.length; i++) {
        final r = jobRounds[i];
        if (r.answer != Needs.polarJ) continue;
        expect(r.job.twists, isTrue);
        expect(r.job.load, Offset.zero,
            reason: 'round ${i + 1} draws a push on a member that is only '
                'being twisted');
      }
    });

    test('the round about a beam on its side really is on its side', () {
      // Its point is that the load sets the axis even when the section is
      // weak about it, so the section had better BE weak about it.
      final r = jobRounds[4];
      expect(r.answer, Needs.iAboutX);
      expect(r.profile.ownIx, lessThan(r.profile.ownIy),
          reason: 'the beam on its side is not actually weaker about the '
              'axis the load picks, so the round proves nothing');
    });

    test('the round about the usual way up is the other way round', () {
      final r = jobRounds[5];
      expect(r.profile.ownIx, greaterThan(r.profile.ownIy));
    });

    test('for a round shaft the polar moment is twice the bending one', () {
      // The factor the feedback claims, checked rather than asserted.
      final shaft = jobRounds[2].profile;
      expect(shaft.ownIx, closeTo(shaft.ownIy, 0.001));
      expect(shaft.ownIx + shaft.ownIy, closeTo(2 * shaft.ownIx, 0.001));
    });

    test('every answer appears and none of them dominates', () {
      final counts = {
        for (final v in Needs.values)
          v: jobRounds.where((r) => r.answer == v).length,
      };
      for (final v in Needs.values) {
        expect(counts[v], greaterThanOrEqualTo(1), reason: '${v.name} never');
      }
      expect(counts.values.reduce(math.max), lessThanOrEqualTo(3));
    });
  });

  group('which piece barely counts', () {
    const expected = <int, int>{0: 1, 1: 1, 2: 0, 3: 1, 4: 1, 5: 1};

    test('the app and the hand-worked set agree', () {
      for (var i = 0; i < shareRounds.length; i++) {
        expect(shareRounds[i].answer, expected[i],
            reason: 'round ${i + 1} of which-barely-matters');
      }
    });

    test('the winner wins by enough to see', () {
      for (var i = 0; i < shareRounds.length; i++) {
        final r = shareRounds[i];
        final shares = [
          for (var k = 0; k < r.profile.pieces.length; k++) r.profile.shareOf(k),
        ]..sort();
        // A negative contribution, which is what a hole gives, is the least
        // by a mile and needs no ratio.
        expect(shares[0] < 0 || shares[1] / shares[0] > 1.55, isTrue,
            reason: 'round ${i + 1}: the two smallest contributions are too '
                'close to call');
      }
    });

    test('half the rounds punish going by size alone', () {
      // The point of the item: the biggest piece by area is often the one
      // doing the least work.
      var biggest = 0;
      for (final r in shareRounds) {
        var fattest = 0;
        for (var k = 1; k < r.profile.pieces.length; k++) {
          if (r.profile.pieces[k].area > r.profile.pieces[fattest].area) {
            fattest = k;
          }
        }
        if (fattest == r.answer) biggest++;
      }
      expect(biggest, greaterThanOrEqualTo(2),
          reason: 'no round has the biggest piece doing the least work');
    });

    test('every piece is named', () {
      for (var i = 0; i < shareRounds.length; i++) {
        final r = shareRounds[i];
        expect(r.names.length, r.profile.pieces.length,
            reason: 'round ${i + 1} names a different number of pieces than it '
                'draws');
        expect(r.names.toSet().length, r.names.length);
      }
    });

    test('the words under the round name the piece it grades', () {
      for (var i = 0; i < shareRounds.length; i++) {
        final r = shareRounds[i];
        final want = r.names[r.answer].replaceFirst('the ', '');
        expect(r.why.toLowerCase(), contains(want.toLowerCase()),
            reason: 'round ${i + 1} never mentions ${r.names[r.answer]}');
      }
    });

    test('no two pieces are tapped in the same place', () {
      const size = Size(360, 270);
      for (var i = 0; i < shareRounds.length; i++) {
        final r = shareRounds[i];
        final boxes = [
          for (var k = 0; k < r.profile.pieces.length; k++)
            ProfilePainter.pieceRect(r.profile, size, k),
        ];
        for (var a = 0; a < boxes.length; a++) {
          for (var b = a + 1; b < boxes.length; b++) {
            // A hole sits inside its plate on purpose, and its tap target is
            // laid over the plate's, so that pair is allowed to overlap.
            if (r.profile.pieces[a].hole || r.profile.pieces[b].hole) continue;
            final overlap = boxes[a].intersect(boxes[b]);
            expect(overlap.width <= 1 || overlap.height <= 1, isTrue,
                reason: 'round ${i + 1}: two pieces are drawn over each other');
          }
        }
      }
    });
  });
}
