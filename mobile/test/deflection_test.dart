import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/add_it_up_game.dart';
import 'package:mobile/features/games/deflection_figures.dart';
import 'package:mobile/features/games/diagram_figures.dart';
import 'package:mobile/features/games/fix_the_bounce_game.dart';
import 'package:mobile/features/games/which_line_in_the_table_game.dart';

/// Chapter seven, lesson six. The table is held against the lesson's own
/// three answers and against the wrong entries it names.
void main() {
  group('the table reproduces the lesson it was built from', () {
    test('the four meter beam sags 2.67 millimeters', () {
      // Problem one: 4 m simply supported, 20 kN at midspan, E = 200 GPa,
      // I = 50 million.
      final sag = Entry.ssPoint
          .sag(load: 20000, span: 4000, e: 200000, i: 50e6);
      expect(sag, closeTo(2.67, 0.01));

      // Its named wrong answers: the two wrong divisors, and the cantilever
      // entry used on a simply supported beam, which is sixteen times more.
      expect(20000 * 4000 * 4000 * 4000 / (96 * 200000 * 50e6),
          closeTo(1.33, 0.01));
      expect(20000 * 4000 * 4000 * 4000 / (24 * 200000 * 50e6),
          closeTo(5.33, 0.01));
      final wrongTable = Entry.cantPoint
          .sag(load: 20000, span: 4000, e: 200000, i: 50e6);
      expect(wrongTable, closeTo(42.7, 0.05));
      expect(wrongTable / sag, closeTo(16, 0.001));
    });

    test('the cantilever sags 13.5 millimeters', () {
      // Problem two: 3 m cantilever, 8 kN/m, E = 200 GPa, I = 30 million.
      final sag =
          Entry.cantUdl.sag(load: 8, span: 3000, e: 200000, i: 30e6);
      expect(sag, closeTo(13.5, 0.01));

      // And the simply supported entry, which the lesson names as the swap
      // to avoid: it comes to 1.41 mm, nearly ten times less, and it is the
      // fourth choice on the list.
      final wrongTable =
          Entry.ssUdl.sag(load: 8, span: 3000, e: 200000, i: 30e6);
      expect(wrongTable, closeTo(1.41, 0.01));
      expect(sag / wrongTable, closeTo(9.6, 0.001));
    });

    test('the two loads add up to eleven millimeters', () {
      // Problem three: 6 m simply supported, 24 kN at midspan AND 4 kN/m all
      // the way, E = 200 GPa, I = 80 million.
      final fromPoint =
          Entry.ssPoint.sag(load: 24000, span: 6000, e: 200000, i: 80e6);
      final fromSpread =
          Entry.ssUdl.sag(load: 4, span: 6000, e: 200000, i: 80e6);
      expect(fromPoint, closeTo(6.75, 0.01));
      expect(fromSpread, closeTo(4.22, 0.01));
      expect(fromPoint + fromSpread, closeTo(11.0, 0.05));
    });

    test('the off centre entry agrees with the midspan one at midspan', () {
      // Two table lines that have to meet in the middle: putting the off
      // centre load at the middle must give the midspan answer.
      final middle = Entry.ssOffset
          .sag(load: 20000, span: 4000, e: 200000, i: 50e6, at: 2000);
      final named =
          Entry.ssPoint.sag(load: 20000, span: 4000, e: 200000, i: 50e6);
      expect(middle, closeTo(named, 1e-9));
    });
  });

  group('what the table says about changing a beam', () {
    test('span is cubed under a point load and to the fourth under a spread',
        () {
      double point(double l) =>
          Entry.ssPoint.sag(load: 10000, span: l, e: 200000, i: 40e6);
      double spread(double l) =>
          Entry.ssUdl.sag(load: 10, span: l, e: 200000, i: 40e6);
      expect(point(8000) / point(4000), closeTo(8, 1e-9));
      expect(spread(8000) / spread(4000), closeTo(16, 1e-9));
    });

    test('stiffness is E times I, and both count once', () {
      final base = Entry.ssPoint
          .sag(load: 10000, span: 4000, e: 200000, i: 40e6);
      expect(
        Entry.ssPoint.sag(load: 10000, span: 4000, e: 400000, i: 40e6),
        closeTo(base / 2, 1e-9),
      );
      expect(
        Entry.ssPoint.sag(load: 10000, span: 4000, e: 200000, i: 80e6),
        closeTo(base / 2, 1e-9),
      );
    });

    test('a cantilever is sixteen times a simply supported beam', () {
      // The lesson's own callout, both ways round.
      final ss = Entry.ssPoint.sag(load: 5000, span: 3000, e: 200000, i: 20e6);
      final cant =
          Entry.cantPoint.sag(load: 5000, span: 3000, e: 200000, i: 20e6);
      expect(cant / ss, closeTo(16, 1e-9));
      final ssw = Entry.ssUdl.sag(load: 5, span: 3000, e: 200000, i: 20e6);
      final cantw = Entry.cantUdl.sag(load: 5, span: 3000, e: 200000, i: 20e6);
      expect(cantw / ssw, closeTo(9.6, 1e-9));
    });
  });

  group('the shapes are drawn the way the beams actually bend', () {
    test('a simply supported beam is flat at the ends and worst inside', () {
      for (final entry in [Entry.ssPoint, Entry.ssUdl]) {
        final shape = entry.shape(span: 6000);
        expect(shape.first.dy, closeTo(0, 1e-9),
            reason: '${entry.name} does not start on its support');
        expect(shape.last.dy, closeTo(0, 1e-9),
            reason: '${entry.name} does not finish on its support');
        final worst = shape.reduce((a, b) => a.dy > b.dy ? a : b);
        expect(worst.dx, closeTo(3000, 100),
            reason: '${entry.name} does not sag most at the middle');
      }
    });

    test('a cantilever is worst at the free end and held at the wall', () {
      for (final entry in [Entry.cantPoint, Entry.cantUdl]) {
        final shape = entry.shape(span: 4000);
        expect(shape.first.dy, closeTo(0, 1e-9));
        expect(shape.last.dy, closeTo(1, 1e-9),
            reason: '${entry.name} does not sag most at its tip');
        // And it leaves the wall horizontally, which is what built in means.
        final first = shape[1].dy - shape[0].dy;
        final second = shape[2].dy - shape[1].dy;
        expect(first, lessThan(second),
            reason: '${entry.name} does not leave the wall flat');
      }
    });

    test('an off centre load sags most on its own side of midspan', () {
      final shape = Entry.ssOffset.shape(span: 10000, at: 3000);
      final worst = shape.reduce((a, b) => a.dy > b.dy ? a : b);
      expect(worst.dx, lessThan(5000));
      expect(worst.dx, greaterThan(3000),
          reason: 'the worst sag sits between the load and the middle');
    });

    test('every shape sags downward the whole way and never lifts', () {
      for (final entry in Entry.values) {
        for (final p in entry.shape(span: 5000, at: 1500)) {
          expect(p.dy, greaterThanOrEqualTo(-1e-9),
              reason: '${entry.name} lifts off its supports at ${p.dx}');
          expect(p.dy, lessThanOrEqualTo(1 + 1e-9));
        }
      }
    });
  });

  group('which-line-in-the-table draws the beam it is asking about', () {
    test('the beam on the screen is the beam of the answer', () {
      for (final r in tableRounds) {
        if (r.answer == -1) continue;
        final entry = r.options[r.answer];
        expect(r.beam.supportsAt.length, entry.cantilever ? 1 : 2,
            reason: '${r.subject}: the drawing and the answer disagree about '
                'the supports');
        expect(r.beam.spreads.isNotEmpty, entry.spread,
            reason: '${r.subject}: the drawing and the answer disagree about '
                'the load');
      }
    });

    test('the round with no single line really needs two', () {
      final combined = tableRounds.where((r) => r.answer == -1);
      expect(combined.length, 1);
      final r = combined.first;
      expect(r.beam.points, isNotEmpty);
      expect(r.beam.spreads, isNotEmpty,
          reason: 'a beam needing two lines has to carry two kinds of load');
    });

    test('no round offers the same line twice', () {
      for (final r in tableRounds) {
        expect(r.options.toSet().length, r.options.length,
            reason: '${r.subject}: a line is offered twice');
      }
    });

    test('every wrong line on offer is a real entry in the table', () {
      // A distractor that is not in the handbook teaches nothing: the whole
      // skill is telling real entries apart.
      for (final r in tableRounds) {
        for (final e in r.options) {
          expect(Entry.values.contains(e), isTrue);
        }
      }
    });
  });

  group('fix-the-bounce ranks its options by the table', () {
    test('the winner really is the smallest sag', () {
      for (final r in bounceRounds) {
        final best = r.sagWith(r.cures[r.answer]);
        for (var i = 0; i < r.cures.length; i++) {
          if (i == r.answer) continue;
          expect(r.sagWith(r.cures[i]), greaterThan(best * 1.02),
              reason: '${r.subject}: option ${i + 1} is within two percent of '
                  'the answer, which is too close to call by reading');
        }
      }
    });

    test('a change that does nothing really does nothing', () {
      // The higher grade steel rounds. Same E, same I, same span: the table
      // cannot tell the difference, and neither can the beam.
      final idle = bounceRounds
          .expand((r) => r.cures.map((c) => (r, c)))
          .where((pair) => pair.$2.e == 1 &&
              pair.$2.i == 1 &&
              pair.$2.span == 1 &&
              pair.$2.load == 1);
      expect(idle, isNotEmpty);
      for (final (round, cure) in idle) {
        expect(round.sagWith(cure), closeTo(round.sagNow, 1e-9));
      }
    });

    test('the answer moves around between rounds', () {
      expect(bounceRounds.map((r) => r.answer).toSet().length,
          greaterThanOrEqualTo(3));
    });
  });

  group('add-it-up splits the load and never the supports', () {
    /// What a split really carries, so a pair can be checked against the beam
    /// it claims to add up to rather than trusted.
    (int, int, Set<int>) shapeOf(Loading beam) => (
          beam.points.length,
          beam.spreads.length,
          {for (final p in beam.points) (p.$1 * 1000).round()},
        );

    String describe(Loading beam) => [
          beam.supportsAt.length,
          beam.span,
          for (final p in beam.points) 'P${(p.$1 * 1000).round()}',
          for (final sp in beam.spreads) 'w${sp.from}-${sp.to}',
        ].join('|');

    test('the right pair has the right supports and the right loads', () {
      for (final r in splitRounds) {
        if (r.answer == -1) continue;
        final (a, b) = r.pairs[r.answer];
        for (final piece in [a, b]) {
          expect(piece.supportsAt.length, r.whole.supportsAt.length,
              reason: '${r.subject}: a piece is held differently from the '
                  'beam it came from');
          expect(piece.span, r.whole.span);
        }
        // The two pieces between them carry everything the whole beam does,
        // and nothing it does not.
        final points = <int>{...shapeOf(a).$3, ...shapeOf(b).$3};
        expect(points, shapeOf(r.whole).$3,
            reason: '${r.subject}: the split loses or invents a point load');
        expect(a.spreads.length + b.spreads.length, r.whole.spreads.length,
            reason: '${r.subject}: the split loses or invents a spread load');
      }
    });

    test('every wrong pair is wrong in a way you can see', () {
      for (final r in splitRounds) {
        for (var i = 0; i < r.pairs.length; i++) {
          if (i == r.answer) continue;
          final (a, b) = r.pairs[i];
          final wrongSupports = a.supportsAt.length !=
                  r.whole.supportsAt.length ||
              b.supportsAt.length != r.whole.supportsAt.length;
          final points = <int>{...shapeOf(a).$3, ...shapeOf(b).$3};
          final wrongLoads = points.length != shapeOf(r.whole).$3.length ||
              !points.containsAll(shapeOf(r.whole).$3) ||
              a.spreads.length + b.spreads.length != r.whole.spreads.length;
          // The same beam offered twice is the other visible mistake: it is
          // the real load counted once too often.
          // A record holding a Set compares by identity, so the two beams
          // are compared through a plain description of what they carry.
          final sameTwice = describe(a) == describe(b);
          expect(wrongSupports || wrongLoads || sameTwice, isTrue,
              reason: '${r.subject}: pair ${i + 1} adds up to the beam too, '
                  'so the round has two right answers');
        }
      }
    });

    test('the beam that needs no split is a table entry on its own', () {
      final alone = splitRounds.where((r) => r.answer == -1);
      expect(alone.length, 1);
      final r = alone.first;
      expect(r.whole.points.length + r.whole.spreads.length, 1,
          reason: 'a beam that needs no split carries exactly one load');
    });
  });
}
