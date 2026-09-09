import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/how_many_samples_game.dart';
import 'package:mobile/features/games/what_goes_under_game.dart';
import 'package:mobile/features/games/wider_or_narrower_game.dart';

/// Chapter two, lesson five. Every interval width and every sample size on
/// these boards is recomputed from what the round declares about its own
/// study. An item that draws a picture of the answer has to have the picture
/// and the answer agree, and only arithmetic can check that.
double _marginFor(UnderRound r, int option) {
  if (r.blank == Blank.denominator) {
    final under = switch (r.options[option]) {
      r'\sqrt{n}' => math.sqrt(r.n.toDouble()),
      r'n' => r.n.toDouble(),
      _ => 1.0,
    };
    return r.z * r.sigma / under;
  }
  return double.parse(r.options[option]) * r.sigma / math.sqrt(r.n);
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in [
      'what-goes-under',
      'wider-or-narrower',
      'how-many-samples',
    ]) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('what goes under', () {
    test('the answer is the root on a denominator round', () {
      for (final r in underRounds.where((r) => r.blank == Blank.denominator)) {
        expect(r.options[r.answer], r'\sqrt{n}', reason: r.subject);
        expect(r.options.toSet(), {r'\sqrt{n}', r'n', r'1'},
            reason: '${r.subject}: the three denominators are the three '
                'the lesson warns about');
      }
    });

    test('the answer matches the stated confidence on a multiplier round', () {
      const table = {'90': '1.645', '95': '1.960', '99': '2.576'};
      for (final r in underRounds.where((r) => r.blank == Blank.multiplier)) {
        final level = table.keys.firstWhere(
          (k) => r.given.contains('$k\\%'),
          orElse: () => '',
        );
        expect(level, isNotEmpty,
            reason: '${r.subject} never says what confidence it wants');
        expect(r.options[r.answer], table[level], reason: r.subject);
        expect(double.parse(r.options[r.answer]), closeTo(r.z, 0.001),
            reason: '${r.subject}: the round and its own picture disagree');
      }
    });

    test('the three widths are far enough apart to tell apart', () {
      for (final r in underRounds) {
        final widths = [
          for (var i = 0; i < r.options.length; i++) _marginFor(r, i),
        ]..sort();
        for (var i = 1; i < widths.length; i++) {
          expect(widths[i] / widths[i - 1], greaterThan(1.15),
              reason: '${r.subject}: two candidates draw the same interval');
        }
      }
    });

    test('the wrong denominators really are too narrow and too wide', () {
      for (final r in underRounds.where((r) => r.blank == Blank.denominator)) {
        final right = _marginFor(r, r.answer);
        final byN = _marginFor(r, r.options.indexOf('n'));
        final byNothing = _marginFor(r, r.options.indexOf('1'));
        expect(byN, lessThan(right), reason: r.subject);
        expect(byNothing, greaterThan(right), reason: r.subject);
      }
    });

    test('both blanks are used, and the answer moves around', () {
      expect(underRounds.where((r) => r.blank == Blank.denominator).length,
          greaterThanOrEqualTo(3));
      expect(underRounds.where((r) => r.blank == Blank.multiplier).length,
          greaterThanOrEqualTo(3));
      expect(underRounds.map((r) => r.answer).toSet(), {0, 1, 2},
          reason: 'the right piece has to appear in all three positions, or '
              'the board can be cleared by muscle memory');
    });

    test('every candidate on the picture has a name in words', () {
      for (final r in underRounds) {
        expect(r.names.length, r.options.length, reason: r.subject);
        expect(r.names.toSet().length, r.names.length,
            reason: '${r.subject}: two bands would be labelled the same');
        for (final n in r.names) {
          expect(n.trim(), isNotEmpty, reason: r.subject);
        }
      }
    });

    test('all three confidence levels get asked for', () {
      final levels = [
        for (final r in underRounds.where((r) => r.blank == Blank.multiplier))
          r.options[r.answer],
      ];
      expect(levels.toSet(), {'1.645', '1.960', '2.576'});
    });
  });

  group('wider or narrower', () {
    test('the drawn width agrees with the answer every time', () {
      for (final r in moveRounds) {
        switch (r.answer) {
          case Move.narrower:
            expect(r.after, lessThan(0.98), reason: r.change);
          case Move.wider:
            expect(r.after, greaterThan(1.02), reason: r.change);
          case Move.same:
            expect(r.after, 1, reason: r.change);
        }
      }
    });

    test('all three answers happen', () {
      expect(moveRounds.map((r) => r.answer).toSet(), Move.values.toSet());
    });

    test('the quadrupled sample really halves it, and t really is wider', () {
      final quadrupled = moveRounds.firstWhere(
        (r) => r.change.contains('100 samples instead of 25'),
      );
      expect(quadrupled.after, closeTo(math.sqrt(25 / 100), 0.001));

      final toT = moveRounds.firstWhere((r) => r.change.contains('t with'));
      expect(toT.after, closeTo(2.262 / 1.960, 0.005),
          reason: 'the widening is the multiplier ratio, not a guess');
    });

    test('the confidence change is the ratio of the two multipliers', () {
      final up = moveRounds.firstWhere((r) => r.change.contains('99%'));
      expect(up.after, closeTo(2.576 / 1.960, 0.005));
    });

    test('the round where nothing moves is about the mean', () {
      final still = moveRounds.firstWhere((r) => r.answer == Move.same);
      expect(still.change.contains('mean'), isTrue,
          reason: 'the only thing that leaves the width alone is the mean, and '
              'that is the whole point of including it');
    });

    test('more than one problem is drawn on', () {
      expect(moveRounds.map((r) => r.source).toSet().length,
          greaterThanOrEqualTo(3));
    });
  });

  group('how many samples', () {
    test('the answer is the smallest candidate that gets under the line', () {
      for (final r in sizeRounds) {
        final enough = [
          for (final n in r.candidates)
            if (marginAt(r, n) <= r.target * 1.0005) n,
        ];
        expect(enough, isNotEmpty, reason: '${r.subject}: nothing is enough');
        expect(r.candidates[r.answer], enough.first,
            reason: '${r.subject}: ${r.candidates[r.answer]} gives a margin of '
                '${marginAt(r, r.candidates[r.answer]).toStringAsFixed(2)} '
                'against a target of ${r.target}');
      }
    });

    test('every candidate below the answer genuinely misses', () {
      for (final r in sizeRounds) {
        for (final n in r.candidates) {
          if (n >= r.candidates[r.answer]) continue;
          expect(marginAt(r, n), greaterThan(r.target),
              reason: '${r.subject}: $n also clears the line');
        }
      }
    });

    test('the candidates are listed smallest first', () {
      for (final r in sizeRounds) {
        final sorted = [...r.candidates]..sort();
        expect(sorted, r.candidates, reason: r.subject);
        expect(r.candidates.toSet().length, r.candidates.length,
            reason: '${r.subject}: a count is offered twice');
      }
    });

    test('a round turns on rounding up by one', () {
      // The lesson names it: 61.47 days means 62 days. If no round is decided
      // by a single sample, the item never asks the question.
      final tight = sizeRounds.any((r) {
        final answer = r.candidates[r.answer];
        return r.candidates.contains(answer - 1) &&
            marginAt(r, answer - 1) / r.target < 1.02;
      });
      expect(tight, isTrue, reason: 'nothing here turns on rounding up');
    });

    test('a round turns on the fourfold rule, and one on nine', () {
      double ratio(SizeRound r) {
        final first = r.candidates.first.toDouble();
        return r.candidates[r.answer] / first;
      }

      expect(sizeRounds.any((r) => (ratio(r) - 4).abs() < 0.01), isTrue,
          reason: 'halving the margin costs four times the samples, and that '
              'has to be met head on');
      expect(
        sizeRounds.any((r) =>
            r.why.contains('nine times') || r.why.contains('A third')),
        isTrue,
      );
    });

    test('every answer position is used', () {
      expect(sizeRounds.map((r) => r.answer).toSet(), {0, 1, 2});
    });

    test('the curve has room to be drawn either side of the answer', () {
      for (final r in sizeRounds) {
        expect(r.k / math.sqrt(r.candidates.first), greaterThan(r.target * 0.4),
            reason: '${r.subject}: the whole curve is under the line already');
        expect(r.target, greaterThan(0));
      }
    });
  });

  group('the boards run', () {
    testWidgets('nothing submits until a piece is chosen', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhatGoesUnderGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE PIECE'), findsNothing);
      expect(find.text('LOOK AT THE WIDTH'), findsNothing);
    });

    testWidgets('dividing by n instead of its root is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhatGoesUnderGame()));
      await tester.pumpAndSettle();

      // Round one lists n first, which is the mistake the lesson prints in
      // bold.
      await tester.tap(find.byKey(const ValueKey('piece-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('LOOK AT THE WIDTH'), findsOneWidget);
    });

    testWidgets('the interval after the change is held back', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WiderOrNarrowerGame()));
      await tester.pumpAndSettle();

      expect(find.text('Narrower'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('move-wider')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THE OTHER WAY'), findsOneWidget);
    });

    testWidgets('rounding down on the traffic count is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: HowManySamplesGame()));
      await tester.pumpAndSettle();

      // 61 days is 61.47 rounded the wrong way.
      await tester.tap(find.byKey(const ValueKey('count-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT ENOUGH'), findsOneWidget);
    });

    testWidgets('the count that clears the line is accepted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: HowManySamplesGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('count-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS ENOUGH'), findsOneWidget);
    });
  });
}
