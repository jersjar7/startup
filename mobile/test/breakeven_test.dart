import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/breakeven_figures.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/what_is_the_saving_game.dart';
import 'package:mobile/features/games/which_bucket_game.dart';
import 'package:mobile/features/games/which_side_wins_game.dart';

/// Chapter four, lesson three. The break-even rounds are two straight lines
/// and a marked volume, so the test evaluates them: which line is lower where
/// the marker sits, whether the two ever cross inside the drawn window, and
/// whether the round's own answer agrees. A chart that disagrees with its
/// answer is the whole defect available here.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in [
      'which-bucket',
      'which-side-wins',
      'what-is-the-saving',
    ]) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('which bucket', () {
    test('every bucket is the answer, and sunk more than once', () {
      final answers = bucketRounds.map((r) => r.answer).toList();
      expect(answers.toSet().length, buckets.length,
          reason: 'a bucket nobody ever needs is a dead row');
      expect(answers.where((a) => a == 2).length, 2,
          reason: 'the sunk cost is the trap the lesson names and one round is '
              'not enough of it');
    });

    test('the answer never repeats round to round', () {
      for (var i = 1; i < bucketRounds.length; i++) {
        expect(bucketRounds[i].answer, isNot(bucketRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous bucket');
      }
    });

    test('a sunk round says the money is gone and cannot come back', () {
      for (final r in bucketRounds.where((r) => r.answer == 2)) {
        final text = r.cost.toLowerCase();
        expect(
          text.contains('ago') || text.contains('was spent'),
          isTrue,
          reason: '${r.subject}: nothing says the money is already spent',
        );
      }
    });

    test('no cost names its own bucket', () {
      const giveaways = [
        'fixed',
        'variable',
        'sunk',
        'opportunity',
        'marginal',
      ];
      for (final r in bucketRounds) {
        final text = r.cost.toLowerCase();
        for (final word in giveaways) {
          expect(text.contains(word), isFalse,
              reason: '${r.subject} says "$word"');
        }
      }
    });

    test('all three problems in the lesson are drawn on', () {
      expect(bucketRounds.map((r) => r.source).toSet().length,
          greaterThanOrEqualTo(2));
    });
  });

  group('which side wins', () {
    test('the answer is whichever line is lower at the marker', () {
      for (final r in winsRounds) {
        final a = r.lines[0].at(r.at);
        final b = r.lines[1].at(r.at);
        final expected = (a - b).abs() < 0.005 ? 2 : (a < b ? 0 : 1);
        expect(r.answer, expected,
            reason: '${r.subject}: at ${r.at} the two cost '
                '${a.toStringAsFixed(0)} and ${b.toStringAsFixed(0)}');
      }
    });

    test('the marker sits inside the drawn window', () {
      for (final r in winsRounds) {
        expect(r.at, inInclusiveRange(0, r.qTo), reason: r.subject);
        expect(r.qTo, greaterThan(0), reason: r.subject);
      }
    });

    test('one round has the lines never crossing, and the rest do', () {
      final painters = [
        for (final r in winsRounds)
          BreakEvenPainter(lines: r.lines, qTo: r.qTo, at: r.at),
      ];
      final never = painters.where((p) => p.crossing == null).length;
      expect(never, 1,
          reason: 'exactly one round should have no break-even volume, so it '
              'stays a surprise rather than a pattern');
    });

    test('the dominated round really is worse on both counts', () {
      // The point of it: higher fixed AND higher variable means no crossing
      // and no volume at which it wins.
      final dominated = winsRounds.firstWhere((r) =>
          BreakEvenPainter(lines: r.lines, qTo: r.qTo, at: r.at).crossing ==
          null);
      final loser = dominated.answer == 0 ? 1 : 0;
      final winner = 1 - loser;
      expect(dominated.lines[loser].fixed,
          greaterThan(dominated.lines[winner].fixed),
          reason: 'the losing option should start higher');
      expect(dominated.lines[loser].variable,
          greaterThan(dominated.lines[winner].variable),
          reason: 'and rise faster');
    });

    test('both sides of a crossing are asked about', () {
      // One round below the crossing and one above, on the same pair, is what
      // makes the idea land.
      final below = winsRounds.where((r) {
        final c = BreakEvenPainter(lines: r.lines, qTo: r.qTo, at: r.at)
            .crossing;
        return c != null && r.at < c;
      });
      final above = winsRounds.where((r) {
        final c = BreakEvenPainter(lines: r.lines, qTo: r.qTo, at: r.at)
            .crossing;
        return c != null && r.at > c;
      });
      expect(below.length, greaterThanOrEqualTo(2));
      expect(above.length, greaterThanOrEqualTo(2));
    });

    test('one round sits exactly on the crossing', () {
      expect(winsRounds.where((r) => r.answer == 2).length, 1,
          reason: 'the break-even volume itself is a real answer and needs '
              'exactly one round');
    });
  });

  group('what is the saving', () {
    test('every round offers four numbers, each named once', () {
      for (final r in savingRounds) {
        expect(r.options.length, 4, reason: r.subject);
        expect(r.options.map((o) => o.$1).toSet().length, 4,
            reason: '${r.subject}: a number is offered twice');
        expect(r.options.map((o) => o.$2).toSet().length, 4,
            reason: '${r.subject}: two options are explained the same way');
      }
    });

    test('the answer is not always in the same place', () {
      expect(savingRounds.map((r) => r.answer).toSet().length,
          greaterThanOrEqualTo(3));
      for (var i = 1; i < savingRounds.length; i++) {
        expect(savingRounds[i].answer, isNot(savingRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous position');
      }
    });

    test('the gross saving is offered wherever there is a net one', () {
      // The trap the lesson names. If the larger, wronger number is not on
      // the board, the round never asks the question.
      // Only where there is something to subtract. The round with no new
      // annual cost has no separate gross figure to offer, which is the point
      // of including it.
      for (final r in savingRounds) {
        if (!r.options[r.answer].$2.contains('less')) continue;
        final hasGross = r.options.any(
          (o) => !o.$2.contains('less') && !o.$2.contains('plus'),
        );
        expect(hasGross, isTrue,
            reason: '${r.subject}: nobody is offered the gross figure');
      }
    });

    test('one round has no payback at all', () {
      final none = savingRounds.where(
        (r) => r.options[r.answer].$1 == 'Nothing does',
      );
      expect(none.length, 1,
          reason: 'a new cost larger than the saving means no payback period, '
              'and a formula will hand back a number anyway');
    });

    test('one round has nothing to subtract', () {
      // So the subtraction reads as a response to a cost rather than a ritual.
      final clean = savingRounds.any(
        (r) => r.options[r.answer].$2 == 'the repairs avoided',
      );
      expect(clean, isTrue);
    });

    test('every round explains itself', () {
      for (final r in savingRounds) {
        expect(r.why.length, greaterThan(90), reason: r.subject);
        expect(r.scenario.length, greaterThan(110), reason: r.subject);
      }
    });
  });

  group('the boards run', () {
    testWidgets('a bucket has to be chosen before locking in', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichBucketGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT BUCKET'), findsNothing);
      expect(find.text('A DIFFERENT BUCKET'), findsNothing);
    });

    testWidgets('putting the old plant into one option is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichBucketGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('bucket-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('A DIFFERENT BUCKET'), findsOneWidget);
    });

    testWidgets('the cheap start wins on a light day', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichSideWinsGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(ValueKey('side-${winsRounds.first.answer}')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('CHEAPER THERE'), findsOneWidget);
    });

    testWidgets('comparing the per-unit rates alone is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichSideWinsGame()));
      await tester.pumpAndSettle();

      // Round one is a light day, where the flatter line has not caught up.
      await tester.tap(find.byKey(const ValueKey('side-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THE OTHER SIDE'), findsOneWidget);
    });

    testWidgets('the gross saving is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhatIsTheSavingGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('saving-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('A DIFFERENT ONE'), findsOneWidget);
    });
  });
}
