import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/above_or_below_game.dart';
import 'package:mobile/features/games/section_figures.dart';
import 'package:mobile/features/games/tap_its_centroid_game.dart';
import 'package:mobile/features/games/which_distance_goes_in_game.dart';

/// Lesson forty one, centroids of composite shapes. Every table value the
/// items rely on is checked here by counting the shape rather than by
/// repeating the formula, and the three lesson answers are reproduced whole,
/// along with the wrong answers the lesson names.
void main() {
  /// Area and centroid found by sampling the drawing itself. It shares no
  /// algebra with the handbook formulas the app uses, so the two agreeing
  /// means the app has the table right.
  ({double area, Offset centroid}) byCounting(Piece piece) {
    final path = piece.outline();
    final box = piece.box;
    const steps = 420;
    final dx = box.width / steps;
    final dy = box.height / steps;
    var hits = 0;
    var sx = 0.0;
    var sy = 0.0;
    for (var i = 0; i < steps; i++) {
      final x = box.left + (i + 0.5) * dx;
      for (var j = 0; j < steps; j++) {
        final y = box.top + (j + 0.5) * dy;
        if (!path.contains(Offset(x, y))) continue;
        hits++;
        sx += x;
        sy += y;
      }
    }
    return (
      area: hits * dx * dy,
      centroid: Offset(sx / hits, sy / hits),
    );
  }

  Iterable<Piece> everyPiece() sync* {
    for (final r in sitRounds) {
      yield* r.profile.pieces;
    }
    for (final r in spotRounds) {
      yield* r.profile.pieces;
    }
    for (final r in dropRounds) {
      yield* r.profile.pieces;
    }
  }

  group('every shape knows its own area and centroid', () {
    test('counting the shape agrees with the table value', () {
      for (final piece in everyPiece()) {
        final counted = byCounting(piece);
        final scale = math.max(piece.box.width, piece.box.height);
        expect(counted.area, closeTo(piece.span, piece.span * 0.01),
            reason: 'a ${piece.kind.name} of ${piece.box.size} has the wrong '
                'area');
        expect(counted.centroid.dx,
            closeTo(piece.centroid.dx, scale * 0.01),
            reason: 'a ${piece.kind.name} of ${piece.box.size} has its '
                'centroid in the wrong place across');
        expect(counted.centroid.dy,
            closeTo(piece.centroid.dy, scale * 0.01),
            reason: 'a ${piece.kind.name} of ${piece.box.size} has its '
                'centroid in the wrong place up');
      }
    });

    test('a hole has the same shape and the opposite area', () {
      for (final piece in everyPiece()) {
        expect(piece.area, piece.hole ? -piece.span : piece.span);
        expect(piece.span, greaterThan(0));
      }
    });

    test('every kind of shape the tables cover turns up somewhere', () {
      final seen = everyPiece().map((p) => p.kind).toSet();
      for (final kind in Slab.values) {
        expect(seen, contains(kind), reason: '${kind.name} is never drawn');
      }
    });
  });

  group('the lesson answers come out of the engine', () {
    test('the T section is seventy millimetres up', () {
      // Problem one: a 20 by 80 web under a 120 by 20 flange.
      const tee = Profile([
        Piece(Slab.box, Offset(50, 0), Size(20, 80)),
        Piece(Slab.box, Offset(0, 80), Size(120, 20)),
      ]);
      expect(tee.centroid.dy, closeTo(70, 0.05));
      expect(tee.area, closeTo(4000, 0.5));
      // And the two wrong answers the lesson names.
      expect(tee.midHeight, closeTo(50, 0.05));
      final unweighted = (40 + 90) / 2;
      expect(unweighted, closeTo(65, 0.05));
    });

    test('the plate with a hole is ninety seven and a half up', () {
      // Problem two: a 300 by 200 plate with a 60 diameter hole at y = 150.
      const plate = Profile([
        Piece(Slab.box, Offset(0, 0), Size(300, 200)),
        Piece(Slab.disc, Offset(120, 120), Size(60, 60), hole: true),
      ]);
      expect(plate.centroid.dy, closeTo(97.5, 0.1));
      expect(plate.area, closeTo(60000 - math.pi * 900, 1));
      // Ignoring the hole gives a hundred, and adding it instead of
      // subtracting it gives a hundred and two and a half.
      expect(plate.midHeight, closeTo(100, 0.05));
      final added = (60000 * 100 + math.pi * 900 * 150) /
          (60000 + math.pi * 900);
      expect(added, closeTo(102.4, 0.2));
    });

    test('the built-up section is ninety one and a bit up', () {
      // Problem three: three rectangles, the bottom flange the widest.
      const section = Profile([
        Piece(Slab.box, Offset(0, 0), Size(200, 30)),
        Piece(Slab.box, Offset(85, 30), Size(30, 140)),
        Piece(Slab.box, Offset(25, 170), Size(150, 30)),
      ]);
      expect(section.centroid.dy, closeTo(91.3, 0.1));
      expect(section.area, closeTo(14700, 0.5));
      expect(section.midHeight, closeTo(100, 0.05));
      // Measuring from the top instead of the bottom gives the other
      // distractor the lesson names.
      expect(200 - section.centroid.dy, closeTo(108.7, 0.1));
    });
  });

  group('which side of halfway the centroid falls', () {
    const expected = <int, Sit>{
      0: Sit.above,
      1: Sit.below,
      2: Sit.onIt,
      3: Sit.below,
      4: Sit.below,
      5: Sit.above,
    };

    test('the app and the hand-worked set agree', () {
      for (var i = 0; i < sitRounds.length; i++) {
        expect(sitRounds[i].answer, expected[i],
            reason: 'round ${i + 1} of above-or-below-middle');
      }
    });

    test('a round called symmetric really is symmetric', () {
      for (var i = 0; i < sitRounds.length; i++) {
        final r = sitRounds[i];
        if (r.answer != Sit.onIt) continue;
        expect((r.profile.centroid.dy - r.profile.midHeight).abs(),
            lessThan(0.001),
            reason: 'round ${i + 1} is called symmetric and is only nearly '
                'symmetric');
      }
    });

    test('a round that is not on the line is clear of it', () {
      // A centroid a hair off halfway is a coin toss, not a question.
      for (var i = 0; i < sitRounds.length; i++) {
        final r = sitRounds[i];
        if (r.answer == Sit.onIt) continue;
        final gap = (r.profile.centroid.dy - r.profile.midHeight).abs();
        expect(gap, greaterThan(r.profile.bounds.height * 0.012),
            reason: 'round ${i + 1} sits too near halfway to call by eye');
      }
    });

    test('the T pair and the hole pair are the same shape turned over', () {
      // Rounds one and two are one T either way up, and five and six are one
      // plate with the hole moved. Each pair has to answer opposite ways.
      for (final (a, b) in [(0, 1), (4, 5)]) {
        final one = sitRounds[a].profile;
        final two = sitRounds[b].profile;
        expect(one.area, closeTo(two.area, 0.5));
        expect(one.bounds.size, two.bounds.size);
        expect(sitRounds[a].answer, isNot(sitRounds[b].answer));
      }
    });

    test('every answer appears and none of them dominates', () {
      final counts = {
        for (final v in Sit.values)
          v: sitRounds.where((r) => r.answer == v).length,
      };
      for (final v in Sit.values) {
        expect(counts[v], greaterThanOrEqualTo(1), reason: '${v.name} never');
      }
      expect(counts.values.reduce(math.max), lessThanOrEqualTo(3));
    });
  });

  group('tapping the centroid of one shape', () {
    const size = Size(360, 340);

    test('exactly one candidate is the centroid, and it is not close', () {
      for (var i = 0; i < spotRounds.length; i++) {
        final r = spotRounds[i];
        final truth = r.profile.centroid;
        final near = [
          for (final s in r.spots)
            if ((s - truth).distance < 0.02) s,
        ];
        expect(near.length, 1,
            reason: 'round ${i + 1} of tap-its-centroid has ${near.length} '
                'candidates on the answer');
        for (var k = 0; k < r.spots.length; k++) {
          if (k == r.answer) continue;
          final scale = math.max(
              r.profile.bounds.width, r.profile.bounds.height);
          expect((r.spots[k] - truth).distance, greaterThan(scale * 0.12),
              reason: 'round ${i + 1} candidate ${k + 1} is so near the '
                  'answer it cannot be told apart');
        }
      }
    });

    test('no two candidates are tapped in the same place', () {
      for (var i = 0; i < spotRounds.length; i++) {
        final r = spotRounds[i];
        final tips = [
          for (final s in r.spots)
            ProfilePainter.toScreen(r.profile, s, size),
        ];
        for (var a = 0; a < tips.length; a++) {
          for (var b = a + 1; b < tips.length; b++) {
            expect((tips[a] - tips[b]).distance, greaterThan(44),
                reason: 'round ${i + 1}: candidates land on each other');
          }
          expect(tips[a].dx > 4 && tips[a].dx < size.width - 4, isTrue,
              reason: 'round ${i + 1}: a candidate is off the side');
          expect(tips[a].dy > 4 && tips[a].dy < size.height - 4, isTrue,
              reason: 'round ${i + 1}: a candidate is off the top or bottom');
        }
      }
    });

    test('the words under the round name the candidate it grades', () {
      for (var i = 0; i < spotRounds.length; i++) {
        final r = spotRounds[i];
        expect(r.why, startsWith('Point ${r.answer + 1}'),
            reason: 'round ${i + 1} explains a different point than it marks');
      }
    });

    test('the mirrored pair really is mirrored, and answers differently', () {
      final a = spotRounds[0];
      final b = spotRounds[1];
      expect(a.profile.pieces.single.kind, b.profile.pieces.single.kind);
      expect(a.profile.pieces.single.flip, isNot(b.profile.pieces.single.flip));
      expect(a.spots, b.spots);
      expect(a.answer, isNot(b.answer));
    });

    test('the answer of the last round lies outside the metal', () {
      // An angle's centroid falls in the notch, which is worth having seen.
      final r = spotRounds.last;
      final inside = r.profile.pieces
          .any((p) => p.outline().contains(r.profile.centroid));
      expect(inside, isFalse,
          reason: 'the angle round no longer shows a centroid outside the '
              'shape, which was the point of it');
    });
  });

  group('which distance belongs in the sum', () {
    const size = Size(360, 260);

    test('exactly one candidate runs from the axis to that piece', () {
      for (var i = 0; i < dropRounds.length; i++) {
        final r = dropRounds[i];
        final want = r.profile.pieces[r.piece].centroid.dy;
        final good = [
          for (var k = 0; k < r.drops.length; k++)
            if ((r.drops[k].from - r.profile.baseline).abs() < 0.01 &&
                (r.drops[k].to - want).abs() < 0.01)
              k,
        ];
        expect(good.length, 1,
            reason: 'round ${i + 1} of which-distance-goes-in has '
                '${good.length} workable distances');
        expect(r.answer, good.single);
      }
    });

    test('every candidate is a real distance on the drawing', () {
      for (var i = 0; i < dropRounds.length; i++) {
        final r = dropRounds[i];
        for (final d in r.drops) {
          expect((d.to - d.from).abs(), greaterThan(0),
              reason: 'round ${i + 1} offers a distance of nothing');
          for (final at in [d.from, d.to]) {
            expect(at >= r.profile.baseline - 0.01 &&
                at <= r.profile.crown + 0.01, isTrue,
                reason: 'round ${i + 1} measures to somewhere off the '
                    'section');
          }
        }
        expect(r.drops.map((d) => d.label).toSet().length, r.drops.length);
      }
    });

    test('at least one wrong distance is one people actually take', () {
      // A round whose distractors are all obvious nonsense teaches nothing.
      // These are the two real mistakes: stopping at the edge of the piece,
      // and measuring from somewhere other than the chosen axis.
      var edge = 0;
      var elsewhere = 0;
      for (final r in dropRounds) {
        for (var k = 0; k < r.drops.length; k++) {
          if (k == r.answer) continue;
          final d = r.drops[k];
          final p = r.profile.pieces[r.piece];
          if ((d.to - p.box.top).abs() < 0.01 ||
              (d.to - p.box.bottom).abs() < 0.01) {
            edge++;
          }
          if ((d.from - r.profile.baseline).abs() > 0.01) elsewhere++;
        }
      }
      expect(edge, greaterThanOrEqualTo(4));
      expect(elsewhere, greaterThanOrEqualTo(2));
    });

    test('the words under the round name the distance it grades', () {
      for (var i = 0; i < dropRounds.length; i++) {
        final r = dropRounds[i];
        expect(r.why, startsWith('Distance ${r.answer + 1}'),
            reason: 'round ${i + 1} explains a different distance');
      }
    });

    test('no two dimensions are tapped in the same place', () {
      for (var i = 0; i < dropRounds.length; i++) {
        final r = dropRounds[i];
        final lanes = [
          for (var k = 0; k < r.drops.length; k++)
            ProfilePainter.laneFor(r.profile, size, r.drops, k),
        ];
        for (var a = 0; a < lanes.length; a++) {
          for (var b = a + 1; b < lanes.length; b++) {
            expect((lanes[a] - lanes[b]).abs(), greaterThan(44),
                reason: 'round ${i + 1}: two dimensions share a lane');
          }
          expect(lanes[a] > 4 && lanes[a] < size.width - 4, isTrue,
              reason: 'round ${i + 1}: a dimension is off the figure');
        }
      }
    });

    test('the piece asked about is one of the pieces drawn', () {
      for (var i = 0; i < dropRounds.length; i++) {
        final r = dropRounds[i];
        expect(r.piece >= 0 && r.piece < r.profile.pieces.length, isTrue,
            reason: 'round ${i + 1} points at a piece that is not there');
      }
    });

    test('a hole is measured like anything else', () {
      final r = dropRounds.last;
      expect(r.profile.pieces[r.piece].hole, isTrue);
      expect(r.drops[r.answer].from, r.profile.baseline);
      expect(r.drops[r.answer].to,
          closeTo(r.profile.pieces[r.piece].centroid.dy, 0.01));
    });
  });
}
