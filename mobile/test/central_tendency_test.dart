import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/read_the_line_game.dart';
import 'package:mobile/features/games/what_weights_game.dart';
import 'package:mobile/features/games/which_readout_game.dart';

/// Chapter two, lesson one. Every statistic this lesson defines is computed
/// here from the round's own readings and checked against what the round
/// claims, so a miscounted median cannot ship.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['read-the-line', 'which-readout', 'what-weights']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('read it off the line', () {
    test('every stated answer is what the readings actually give', () {
      for (final r in lineRounds) {
        final sorted = [...r.values]..sort();
        final counts = <int, int>{};
        for (final v in sorted) {
          counts[v] = (counts[v] ?? 0) + 1;
        }
        final most = counts.values.reduce((a, b) => a > b ? a : b);
        final modes = counts.entries
            .where((e) => e.value == most)
            .map((e) => e.key)
            .toSet();

        final expected = switch (r.ask) {
          final a when a.contains('most often') => modes,
          final a when a.contains('every mode') => modes,
          final a when a.contains('range') => {sorted.first, sorted.last},
          final a when a.contains('sits between') => {
            sorted[sorted.length ~/ 2 - 1],
            sorted[sorted.length ~/ 2],
          },
          _ => {sorted[sorted.length ~/ 2]},
        };
        expect(r.answer, expected, reason: '"${r.ask}" on ${r.values}');
      }
    });

    test('a median round has an odd count and a between round an even one', () {
      for (final r in lineRounds) {
        if (r.ask.contains('sits between')) {
          expect(r.values.length.isEven, isTrue, reason: r.ask);
        }
        if (r.ask.contains('the median') && !r.ask.contains('between')) {
          expect(r.values.length.isOdd, isTrue, reason: r.ask);
        }
      }
    });

    test('every reading and every answer is on the axis', () {
      for (final r in lineRounds) {
        for (final v in [...r.values, ...r.answer]) {
          expect(v, inInclusiveRange(r.from, r.to), reason: '$v in ${r.ask}');
        }
        expect(
          r.to - r.from,
          lessThanOrEqualTo(16),
          reason: 'more ticks than that and a finger cannot pick one',
        );
      }
    });

    test('the set with an outlier really has one, and it moves the mean', () {
      final skewed = lineRounds.firstWhere((r) => r.ask.contains('long way'));
      final sorted = [...skewed.values]..sort();
      final mean = sorted.reduce((a, b) => a + b) / sorted.length;
      final median = sorted[sorted.length ~/ 2];
      expect(
        mean - median,
        greaterThan(0.75),
        reason: 'the whole point of that round is the gap between the two',
      );
    });

    test('a bimodal set is in the set', () {
      expect(lineRounds.any((r) => r.answer.length == 2 &&
          r.ask.contains('mode')), isTrue);
    });
  });

  group('which line do you read', () {
    test('every round shows a value for all six lines', () {
      for (final r in readoutRounds) {
        expect(r.values.length, readoutLines.length, reason: r.ask);
        expect(r.answer, inInclusiveRange(-1, readoutLines.length - 1));
      }
    });

    test('the sample line and the population line are both right somewhere', () {
      final answers = readoutRounds.map((r) => r.answer).toSet();
      expect(answers, contains(2), reason: 'Sx has to be right somewhere');
      expect(answers, contains(3), reason: 'and so does sigma x');
    });

    test('a round asks for something the screen does not have', () {
      expect(
        readoutRounds.where((r) => r.answer == -1).length,
        greaterThanOrEqualTo(1),
        reason: 'variance and CV are the two the calculator will not hand you',
      );
    });

    test('the sample and population rounds share one screen', () {
      final sample = readoutRounds.firstWhere((r) => r.answer == 2);
      final population = readoutRounds.firstWhere((r) => r.answer == 3);
      expect(
        sample.values,
        population.values,
        reason: 'the point is that the same screen answers two questions '
            'differently, which is invisible if the numbers change too',
      );
    });

    test('Sx and sigma x never show the same number', () {
      for (final r in readoutRounds) {
        expect(r.values[2], isNot(r.values[3]), reason: r.ask);
      }
    });
  });

  group('what gets weighted', () {
    test('the two roles are different columns, and never the label', () {
      for (final r in weightRounds) {
        expect(r.value, isNot(r.weight), reason: r.ask);
        expect(r.value, greaterThan(0), reason: 'the label column is not one');
        expect(r.weight, greaterThan(0));
        expect(r.value, lessThan(r.columns.length));
        expect(r.weight, lessThan(r.columns.length));
      }
    });

    test('every row has a cell for every column', () {
      for (final r in weightRounds) {
        for (final row in r.rows) {
          expect(row.length, r.columns.length, reason: r.ask);
        }
      }
    });

    test('the weight column is not always in the same place', () {
      expect(weightRounds.map((r) => r.weight).toSet().length, greaterThan(1));
    });

    test('a round with equal weights is in the set', () {
      final equal = weightRounds.where((r) {
        final w = r.rows.map((row) => row[r.weight]).toSet();
        return w.length == 1;
      });
      expect(
        equal.length,
        1,
        reason: 'exactly one, so "the weights collapse" stays a surprise',
      );
    });

    test('every other round has weights that actually differ', () {
      // Repeated weights are fine and realistic; what would be pointless is a
      // round where every weight is the same and the item still asks you to
      // find one. Exactly one round is allowed to be that, deliberately.
      final flat = weightRounds
          .where((r) => r.rows.map((row) => row[r.weight]).toSet().length == 1);
      expect(flat.length, 1, reason: 'found ${flat.length} flat-weight rounds');
    });
  });

  group('the boards run', () {
    testWidgets('a half-answered weighting cannot be submitted', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhatWeightsGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('column-3')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('BOTH ROLES'), findsNothing);
      expect(find.text('NOT THOSE TWO'), findsNothing);
    });

    testWidgets('naming both columns the right way round is accepted', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhatWeightsGame()));
      await tester.pumpAndSettle();

      final r = weightRounds.first;
      await tester.tap(find.byKey(ValueKey('column-${r.value}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('column-${r.weight}')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('BOTH ROLES'), findsOneWidget);
    });

    testWidgets('reading the sum instead of the mean is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichReadoutGame()));
      await tester.pumpAndSettle();

      // Round one wants the mean; line 4 is the readings added up.
      await tester.tap(find.byKey(const ValueKey('line-4')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT LINE'), findsOneWidget);
    });

    testWidgets('the dot plot will not submit an untouched axis', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: ReadTheLineGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE SPOT'), findsNothing);
      expect(find.text('NOT THERE'), findsNothing);
    });
  });
}
