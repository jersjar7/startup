import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/depreciation_figures.dart';
import 'package:mobile/features/games/find_the_factor_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/match_the_dollars_game.dart';
import 'package:mobile/features/games/where_the_cost_went_game.dart';

/// Chapter four, lesson six. The MACRS percentages are quoted from the
/// handbook and everything these three items claim is computed from them, so
/// the first thing this test does is check the table itself: every column has
/// to add up to a hundred percent, or every book value on the board is wrong
/// and nothing else here is worth checking.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in [
      'find-the-factor',
      'where-the-cost-went',
      'match-the-dollars',
    ]) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('the table itself', () {
    test('every column writes the asset off completely', () {
      for (final entry in macrsFactors.entries) {
        final total = entry.value.fold<double>(0, (a, b) => a + b);
        expect(total, closeTo(100, 0.01),
            reason: '${entry.key} year property adds to $total percent, so it '
                'either leaves book value stranded or claims money twice');
      }
    });

    test('the half-year convention shows up as an extra year', () {
      // The one hard thing about the table, and the reason the item exists.
      for (final entry in macrsFactors.entries) {
        expect(entry.value.length, entry.key + 1,
            reason: '${entry.key} year property should run over '
                '${entry.key + 1} years');
      }
    });

    test('the deduction is front-loaded, not flat', () {
      for (final entry in macrsFactors.entries) {
        // The first year lands exactly on the straight line rate: declining
        // balance at double the rate, halved by the convention. That is the
        // whole reason the straight line answer looks like a real row.
        final straightLine = 100 / entry.key;
        expect(entry.value.first, closeTo(straightLine, 0.01),
            reason: '${entry.key} year: the first year should sit on the '
                'straight line figure');
        final biggest = entry.value.reduce((a, b) => a > b ? a : b);
        expect(entry.value[1], biggest,
            reason: '${entry.key} year: the second year should be the largest');
        expect(entry.value.last, lessThan(entry.value[1]),
            reason: '${entry.key} year: it should taper');
      }
    });
  });

  group('find the factor', () {
    test('every round points at a cell that exists, or at none', () {
      for (final r in cellRounds) {
        expect(macrsFactors.containsKey(r.recovery), isTrue, reason: r.subject);
        expect(r.year, greaterThan(0), reason: r.subject);
        if (!r.exhausted) {
          expect(r.year, lessThanOrEqualTo(macrsFactors[r.recovery]!.length),
              reason: r.subject);
          expect(r.factor, greaterThan(0), reason: r.subject);
        }
      }
    });

    test('the whole table fits on the screen it is drawn on', () {
      for (final c in classes) {
        expect(macrsFactors[c]!.length, lessThanOrEqualTo(tableYears),
            reason: '$c year property has more years than the table has rows, '
                'so part of its column cannot be tapped');
      }
    });

    test('one round has nothing left to claim', () {
      expect(cellRounds.where((r) => r.exhausted).length, 1,
          reason: 'an asset outliving its schedule is the clearest form of '
              'the half-year point and needs exactly one round');
    });

    test('one round asks past the class name and still finds a year', () {
      // Five year property in its sixth year. Counting rows against the name
      // of the class puts you one short, and this is where it costs you.
      final late = cellRounds.where(
        (r) => !r.exhausted && r.year > r.recovery,
      );
      expect(late, isNotEmpty,
          reason: 'nothing on the board is answered by a row past the number '
              'in the property class name');
    });

    test('every column of the table is used', () {
      expect(cellRounds.map((r) => r.recovery).toSet(), classes.toSet(),
          reason: 'a column nobody is ever sent to is a column nobody learns '
              'to find');
    });

    test('the straight line answer is a real cell somewhere', () {
      // The named trap. Dividing the cost by the class name lands on a
      // percentage that IS in the table, which is what makes it convincing.
      final r = cellRounds.first;
      final straightLine = 100 / r.recovery;
      expect(macrsFactors[r.recovery]!.contains(straightLine), isTrue,
          reason: 'the first round is chosen so that the straight line answer '
              'looks like a legitimate row');
      expect(r.factor, isNot(straightLine),
          reason: 'and it has to be the wrong one');
    });

    test('the answer moves around the table', () {
      final cells = cellRounds.map((r) => '${r.recovery}-${r.year}').toSet();
      expect(cells.length, cellRounds.length,
          reason: 'two rounds send you to the same cell');
      for (var i = 1; i < cellRounds.length; i++) {
        expect(cellRounds[i].year, isNot(cellRounds[i - 1].year),
            reason: 'round ${i + 1} repeats the previous row');
      }
    });

    test('every round explains itself', () {
      for (final r in cellRounds) {
        expect(r.why.length, greaterThan(110), reason: r.subject);
        expect(r.ask.length, greaterThan(10), reason: r.subject);
      }
    });
  });

  group('where the cost went', () {
    /// The three stretches, recomputed here from the table rather than taken
    /// from the item.
    double amount(CostRound r, int from, int to) {
      var pct = 0.0;
      for (var y = from; y <= to; y++) {
        pct += macrsFactors[r.recovery]![y - 1];
      }
      return r.cost * pct / 100;
    }

    test('what is left plus what has gone comes to the cost', () {
      for (final r in costRounds) {
        final gone = amount(r, 1, r.through);
        final left = amount(r, r.through + 1, macrsFactors[r.recovery]!.length);
        expect(gone + left, closeTo(r.cost, 1),
            reason: '${r.subject}: the bar does not add up to the asset');
      }
    });

    test('the three stretches are three different amounts', () {
      // If two of them came to the same number the round could be answered by
      // accident, and the whole item is about telling them apart.
      for (final r in costRounds) {
        final values = <String>{};
        for (final p in r.order) {
          final (from, to) = r.rangeOf(p);
          values.add(amount(r, from, to).round().toString());
        }
        expect(values.length, 3, reason: '${r.subject}: two stretches are the '
            'same amount');
      }
    });

    test('the answer is the stretch the question asks for', () {
      for (final r in costRounds) {
        expect(r.order[r.answer], r.ask, reason: r.subject);
        expect(r.order.toSet().length, 3,
            reason: '${r.subject}: a stretch is offered twice');
      }
    });

    test('book value is asked for more often than anything else', () {
      final asks = costRounds.map((r) => r.ask).toList();
      expect(asks.where((a) => a == Part.left).length, 3,
          reason: 'book value is the thing the lesson tests and it should be '
              'the thing the board mostly asks for');
      for (final p in Part.values) {
        expect(asks.where((a) => a == p).length, greaterThanOrEqualTo(1),
            reason: '$p is never asked, so its bracket is decoration');
      }
    });

    test('the accumulated stretch is always on the board', () {
      // Handing in accumulated depreciation instead of book value is the
      // named trap, and it can only be caught if it is offered.
      for (final r in costRounds) {
        expect(r.order, contains(Part.soFar), reason: r.subject);
        expect(r.order, contains(Part.left), reason: r.subject);
      }
    });

    test('every round has years on both sides of where it has got to', () {
      for (final r in costRounds) {
        expect(r.through, greaterThan(0), reason: r.subject);
        expect(r.through, lessThan(macrsFactors[r.recovery]!.length),
            reason: '${r.subject}: nothing is left, so there is no book value '
                'stretch to bracket');
      }
    });

    test('the answer position moves', () {
      expect(costRounds.map((r) => r.answer).toSet().length, 3);
      for (var i = 1; i < costRounds.length; i++) {
        expect(costRounds[i].answer, isNot(costRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous bracket position');
      }
    });

    test('one round is a nearly written off asset still worth money', () {
      // Book value is not market value, which is the other thing people carry
      // out of this lesson wrong.
      final late = costRounds.where(
        (r) => r.through == macrsFactors[r.recovery]!.length - 1,
      );
      expect(late, isNotEmpty);
      expect(late.first.asset.toLowerCase().contains('sell'), isTrue,
          reason: 'the round has to say the thing is still worth something, '
              'or it does not make the point');
    });
  });

  group('match the dollars', () {
    double combined(DollarsRound r) =>
        r.real + r.inflation + r.real * r.inflation / 100;

    test('the answer matches the rate to the kind of dollars', () {
      for (final r in dollarsRounds) {
        final want = r.actual ? Adjust.combined : Adjust.real;
        expect(r.order[r.answer], want, reason: r.subject);
      }
    });

    test('the compounded rate is worked out, not typed in', () {
      for (final r in dollarsRounds) {
        expect(r.valueOf(Adjust.combined), closeTo(combined(r), 0.0001),
            reason: r.subject);
        expect(r.valueOf(Adjust.sum), closeTo(r.real + r.inflation, 0.0001),
            reason: r.subject);
      }
    });

    test('adding and compounding are always both offered, and differ', () {
      // The whole second trap. If only one of the two is on the board there
      // is nothing to get wrong.
      for (final r in dollarsRounds) {
        expect(r.order, contains(Adjust.sum), reason: r.subject);
        expect(r.order, contains(Adjust.combined), reason: r.subject);
        final gap = r.valueOf(Adjust.combined) - r.valueOf(Adjust.sum);
        expect(gap, greaterThan(0.05),
            reason: '${r.subject}: the two read the same to two decimals, so '
                'dropping the cross term costs nothing');
      }
    });

    test('the four rates are four different numbers', () {
      for (final r in dollarsRounds) {
        final shown = {
          for (final a in r.order) r.valueOf(a).toStringAsFixed(2),
        };
        expect(shown.length, 4,
            reason: '${r.subject}: two of the rates print the same');
      }
    });

    test('one round has a cross term worth most of a point', () {
      // The lesson's warning is about rates large enough for it to matter.
      final big = dollarsRounds.where(
        (r) => r.valueOf(Adjust.combined) - r.valueOf(Adjust.sum) > 0.5,
      );
      expect(big.length, greaterThanOrEqualTo(2),
          reason: 'at four and three percent the cross term is a tenth of a '
              'point and easy to dismiss, so the board needs rates where it '
              'is not');
    });

    test('both kinds of dollars come up, and the same rates give two answers', () {
      expect(dollarsRounds.where((r) => r.actual).length, 4);
      expect(dollarsRounds.where((r) => !r.actual).length, 2);

      // Two rounds with identical rates and different dollars, so that what
      // changed is visibly the dollars and not the economy.
      final pairs = <String, Set<bool>>{};
      for (final r in dollarsRounds) {
        pairs.putIfAbsent('${r.real}/${r.inflation}', () => <bool>{}).add(r.actual);
      }
      expect(pairs.values.any((kinds) => kinds.length == 2), isTrue,
          reason: 'no two rounds share their rates, so nothing isolates the '
              'kind of dollars as the thing that decides');
    });

    test('half the rounds only describe the dollars', () {
      // Naming them every time would make it a lookup rather than a reading.
      final named = dollarsRounds.where(
        (r) =>
            r.situation.contains('actual dollars') ||
            r.situation.contains('constant dollars'),
      );
      expect(named.length, lessThanOrEqualTo(3),
          reason: '${named.length} rounds say it outright, so the wording is '
              'never the thing being read');
    });

    test('the answer position moves', () {
      expect(dollarsRounds.map((r) => r.answer).toSet().length, 4);
      for (var i = 1; i < dollarsRounds.length; i++) {
        expect(dollarsRounds[i].answer, isNot(dollarsRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous position');
      }
    });

    test('every round explains itself', () {
      for (final r in dollarsRounds) {
        expect(r.why.length, greaterThan(110), reason: r.subject);
        expect(r.situation.length, greaterThan(110), reason: r.subject);
      }
    });
  });

  group('the boards run', () {
    testWidgets('a cell has to be picked before locking in', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: FindTheFactorGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT CELL'), findsNothing);
      expect(find.text('A DIFFERENT CELL'), findsNothing);
    });

    testWidgets('the straight line row is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: FindTheFactorGame()));
      await tester.pumpAndSettle();

      // Sixty thousand over five years is twelve thousand, which is twenty
      // percent, which is the row above the answer.
      await tester.tap(find.byKey(const ValueKey('cell-5-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('A DIFFERENT CELL'), findsOneWidget);
    });

    testWidgets('the right cell is accepted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: FindTheFactorGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('cell-5-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT CELL'), findsOneWidget);
    });

    testWidgets('handing in the accumulated depreciation is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhereTheCostWentGame()));
      await tester.pumpAndSettle();

      // Round one wants the book value and offers the accumulated figure
      // first, which is the trap the lesson names.
      await tester.tap(find.byKey(const ValueKey('stretch-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('ANOTHER STRETCH'), findsOneWidget);
    });

    testWidgets('the stretch still on the books is accepted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhereTheCostWentGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(ValueKey('stretch-${costRounds.first.answer}')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT STRETCH'), findsOneWidget);
    });

    testWidgets('adding the two rates and stopping is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: MatchTheDollarsGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('adjust-sum')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('A DIFFERENT RATE'), findsOneWidget);
    });

    testWidgets('the compounded rate is accepted on actual dollars', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: MatchTheDollarsGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('adjust-combined')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT RATE'), findsOneWidget);
    });
  });
}
