import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/reject_or_not_game.dart';
import 'package:mobile/features/games/test_figures.dart';
import 'package:mobile/features/games/which_cell_hurts_game.dart';
import 'package:mobile/features/games/which_way_points_game.dart';

/// Chapter two, lesson six. Every verdict and every chi-square contribution is
/// recomputed here from the round's own numbers. A conclusion that disagrees
/// with the statistic sitting beside it on the screen is the worst kind of
/// content defect, because it teaches the mistake it exists to prevent.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['which-way-points', 'reject-or-not', 'which-cell-hurts']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('which way does it point', () {
    test('the answer agrees with the hypotheses the round writes out', () {
      for (final r in pointRounds) {
        final h1 = r.hypotheses.split('H1:').last.trim();
        final expected = h1.contains('!=')
            ? Tail.both
            : h1.contains('>')
            ? Tail.right
            : Tail.left;
        expect(r.answer, expected,
            reason: '${r.subject}: the picture and the hypotheses disagree');
      }
    });

    test('a directional claim carries a directional word', () {
      const directional = ['EXCEEDS', 'FALLS SHORT', 'REDUCE', 'STRONGER'];
      for (final r in pointRounds) {
        final hasWord = directional.any(r.claim.contains);
        expect(hasWord, r.answer != Tail.both,
            reason: '${r.subject}: the claim and the tail do not match');
      }
    });

    test('every arrangement is asked for, more than once', () {
      for (final tail in Tail.values) {
        expect(pointRounds.where((r) => r.answer == tail).length,
            greaterThanOrEqualTo(2),
            reason: '$tail is barely asked for');
      }
    });

    test('the null and the alternative are always both written', () {
      for (final r in pointRounds) {
        expect(r.hypotheses.contains('H0:'), isTrue, reason: r.subject);
        expect(r.hypotheses.contains('H1:'), isTrue, reason: r.subject);
      }
    });

    test('both problems that set up a test are drawn on', () {
      expect(pointRounds.map((r) => r.source).toSet().length,
          greaterThanOrEqualTo(2));
    });
  });

  group('reject or not', () {
    test('the answer agrees with the numbers on the screen', () {
      for (final r in verdictRounds) {
        final says = r.options[r.answer].toLowerCase();
        if (r.rejects) {
          expect(says.startsWith('reject'), isTrue,
              reason: '${r.subject}: ${r.statistic} beats ${r.critical} and '
                  'the answer says "$says"');
        } else {
          expect(says.startsWith('fail to reject'), isTrue,
              reason: '${r.subject}: ${r.statistic} does not beat '
                  '${r.critical} and the answer says "$says"');
        }
      }
    });

    test('the comparison is on size, so a negative statistic still rejects',
        () {
      final negative = verdictRounds.firstWhere((r) => r.statistic < 0);
      expect(negative.twoTailed, isTrue,
          reason: 'a negative statistic only makes sense against a two-tailed '
              'critical value here');
      expect(negative.rejects, isTrue);
      expect(negative.statistic.abs(), greaterThan(negative.critical));
    });

    test('every round offers the right decision with the wrong reason', () {
      // Two options share the decision and only one of them is right. Without
      // that, the item is a comparison drill and nothing else.
      for (final r in verdictRounds) {
        final want = r.rejects ? 'reject' : 'fail to reject';
        final matching = r.options.where((o) {
          final low = o.toLowerCase();
          return r.rejects
              ? low.startsWith('reject')
              : low.startsWith('fail to reject');
        });
        expect(matching.length, greaterThanOrEqualTo(2),
            reason: '${r.subject}: only one option says "$want", so the '
                'wording is never tested');
      }
    });

    test('no round offers the same sentence twice', () {
      for (final r in verdictRounds) {
        expect(r.options.toSet().length, r.options.length, reason: r.subject);
        expect(r.options.length, 3, reason: r.subject);
      }
    });

    test('both decisions happen, and the answer moves around', () {
      expect(verdictRounds.where((r) => r.rejects).length,
          greaterThanOrEqualTo(2));
      expect(verdictRounds.where((r) => !r.rejects).length,
          greaterThanOrEqualTo(2));
      expect(verdictRounds.map((r) => r.answer).toSet(), {0, 1, 2});
    });

    test('all three tests in the lesson get used', () {
      final labels = verdictRounds.map((r) => r.statLabel).join(' ');
      expect(labels.contains('z ='), isTrue);
      expect(labels.contains('t ='), isTrue);
      expect(labels.contains('X2'), isTrue);
    });

    test('everything drawn fits on its own scale', () {
      for (final r in verdictRounds) {
        expect(r.statistic.abs(), lessThan(r.to), reason: r.subject);
        expect(r.critical, lessThan(r.to), reason: r.subject);
        expect(r.critical, greaterThan(0), reason: r.subject);
        if (!r.twoTailed) {
          expect(r.statistic, greaterThanOrEqualTo(0),
              reason: '${r.subject}: a one-tailed scale starts at zero, so a '
                  'negative statistic would be drawn off the end');
        }
      }
    });
  });

  group('which cell hurts most', () {
    test('the named cell really is the biggest contributor', () {
      for (final r in hurtRounds) {
        final contributions = [for (final c in r.cells) c.contribution];
        final biggest = contributions.reduce((a, b) => a > b ? a : b);
        expect(r.cells[r.answer].contribution, biggest,
            reason: '${r.subject}: ${r.cells[r.answer].name} adds '
                '${r.cells[r.answer].contribution.toStringAsFixed(2)} and '
                'something else adds ${biggest.toStringAsFixed(2)}');
      }
    });

    test('the biggest contributor is never tied with another', () {
      for (final r in hurtRounds) {
        final sorted = [for (final c in r.cells) c.contribution]
          ..sort((a, b) => b.compareTo(a));
        expect(sorted[0] - sorted[1], greaterThan(0.2),
            reason: '${r.subject}: two cells are close enough to be a coin '
                'toss');
      }
    });

    test('the observed counts add up to the expected counts', () {
      // A goodness-of-fit table where the totals do not match is not a
      // goodness-of-fit table, and it would make every contribution wrong.
      for (final r in hurtRounds) {
        final observed = r.cells.fold<int>(0, (a, c) => a + c.observed);
        final expected = r.cells.fold<int>(0, (a, c) => a + c.expected);
        expect(observed, expected, reason: r.subject);
      }
    });

    test('rounds exist where the biggest raw gap is NOT the answer', () {
      // The whole item. If the answer is always the tallest bar, the division
      // by E is never met.
      final tricky = hurtRounds.where((r) {
        final gaps = [
          for (final c in r.cells) (c.observed - c.expected).abs(),
        ];
        final widest = gaps.reduce((a, b) => a > b ? a : b);
        return gaps[r.answer] < widest;
      });
      expect(tricky.length, greaterThanOrEqualTo(3),
          reason: 'only ${tricky.length} rounds punish reading the chart');
    });

    test('a cell that lands exactly on its expectation is shown', () {
      expect(
        hurtRounds.any((r) => r.cells.any((c) => c.contribution == 0)),
        isTrue,
        reason: 'a zero-contribution cell is what a perfect fit looks like',
      );
    });

    test('a round has uneven expectations, and a round has level ones', () {
      final level = hurtRounds.where(
        (r) => r.cells.map((c) => c.expected).toSet().length == 1,
      );
      final uneven = hurtRounds.where(
        (r) => r.cells.map((c) => c.expected).toSet().length > 1,
      );
      expect(level.length, greaterThanOrEqualTo(2));
      expect(uneven.length, greaterThanOrEqualTo(2),
          reason: 'a model that expects the same everywhere hides the reason '
              'for dividing by E');
    });

    test('every answer position gets used, and no expectation is zero', () {
      expect(hurtRounds.map((r) => r.answer).toSet().length,
          greaterThanOrEqualTo(3));
      for (final r in hurtRounds) {
        for (final c in r.cells) {
          expect(c.expected, greaterThan(0), reason: r.subject);
          expect(c.observed, greaterThanOrEqualTo(0), reason: r.subject);
        }
        expect(r.cells.map((c) => c.name).toSet().length, r.cells.length,
            reason: '${r.subject}: two categories share a name');
      }
    });
  });

  group('the boards run', () {
    testWidgets('a tail cannot be chosen by accident', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichWayPointsGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE SHAPE'), findsNothing);
      expect(find.text('THE OTHER SHAPE'), findsNothing);
    });

    testWidgets('reading "exceeds" as two-tailed is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichWayPointsGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('tail-both')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THE OTHER SHAPE'), findsOneWidget);
    });

    testWidgets('the right decision with the wrong reason is rejected', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: RejectOrNotGame()));
      await tester.pumpAndSettle();

      // Round one: option three rejects, and says the claim is proven.
      await tester.tap(find.byKey(const ValueKey('verdict-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT ONE'), findsOneWidget);
    });

    testWidgets('the correct conclusion is accepted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: RejectOrNotGame()));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(ValueKey('verdict-${verdictRounds.first.answer}')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE CALL'), findsOneWidget);
    });

    testWidgets('the contribution of every cell is shown on the reveal', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichCellHurtsGame()));
      await tester.pumpAndSettle();

      expect(find.text('WHAT EACH CELL ADDS'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('cell-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('LOOK AT THE E'), findsOneWidget);
      expect(find.text('WHAT EACH CELL ADDS'), findsOneWidget);
    });
  });
}
