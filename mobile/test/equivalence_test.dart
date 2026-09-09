import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/cash_flow_figures.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/what_does_it_take_game.dart';
import 'package:mobile/features/games/which_factor_game.dart';
import 'package:mobile/features/games/which_rate_game.dart';

/// Chapter four, lesson one. Two of these items answer from a drawn cash flow
/// diagram, so the tests read the diagram: how many arrows there are, which
/// way they point, and whether the shape actually matches the factor the round
/// claims. A diagram that disagrees with its own answer is the worst defect
/// available here, because the picture is the whole question.
///
/// The shape of a set of flows, ignoring which way they point.
({int knowns, int unknowns, bool knownIsSeries, bool unknownIsSeries})
_shapeOf(List<CashFlow> flows) {
  final known = flows.where((f) => !f.unknown).toList();
  final unknown = flows.where((f) => f.unknown).toList();
  return (
    knowns: known.length,
    unknowns: unknown.length,
    knownIsSeries: known.length > 1,
    unknownIsSeries: unknown.length > 1,
  );
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['which-factor', 'which-rate', 'what-does-it-take']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('which factor', () {
    test('every factor is the answer exactly once', () {
      final answers = factorRounds.map((r) => r.answer).toList();
      expect(answers.toSet().length, answers.length,
          reason: 'a factor is the answer twice while another never is');
      expect(answers.toSet().length, factors.length,
          reason: 'the six factors are the content and all six should come up');
    });

    test('the diagram matches the factor the round names', () {
      // A factor whose first letter is A wants a series as the ANSWER; one
      // whose first letter is P or F wants a single amount. The diagram has to
      // agree, or the picture is teaching the opposite of the label.
      for (final r in factorRounds) {
        final shape = _shapeOf(r.flows);
        final wants = factors[r.answer].$1[1];
        expect(shape.unknownIsSeries, wants == 'A',
            reason: '${r.subject}: the factor asks for '
                '${wants == 'A' ? 'a series' : 'a single amount'} and the '
                'diagram draws ${shape.unknownIsSeries ? 'a series' : 'one '
                    'arrow'} as unknown');
      }
    });

    test('what is given matches the second half of the factor name', () {
      for (final r in factorRounds) {
        final shape = _shapeOf(r.flows);
        // The name reads (want/have), so the character after the slash is
        // what the round is supposed to be handing over.
        final has = factors[r.answer].$1[3];
        expect(shape.knownIsSeries, has == 'A',
            reason: '${r.subject}: the factor is given '
                '${has == 'A' ? 'a series' : 'a single amount'} and the '
                'diagram draws ${shape.knownIsSeries ? 'a series' : 'one '
                    'arrow'} as known');
      }
    });

    test('every diagram has something known and something asked for', () {
      for (final r in factorRounds) {
        final shape = _shapeOf(r.flows);
        expect(shape.knowns, greaterThan(0), reason: r.subject);
        expect(shape.unknowns, greaterThan(0), reason: r.subject);
        for (final f in r.flows) {
          expect(f.period, inInclusiveRange(0, r.periods), reason: r.subject);
        }
      }
    });

    test('the sinking fund and capital recovery rounds are both here', () {
      // The pair the lesson names, and the only reason this item exists.
      final names = [for (final r in factorRounds) factors[r.answer].$1];
      expect(names, contains(r'(A/F, i, n)'));
      expect(names, contains(r'(A/P, i, n)'));
    });

    test('more than one problem is drawn on', () {
      expect(factorRounds.map((r) => r.source).toSet().length,
          greaterThanOrEqualTo(2));
    });
  });

  group('which rate', () {
    test('every rate is the answer at least once', () {
      expect(rateRounds.map((r) => r.answer).toSet(), Rate.values.toSet());
    });

    test('the three numbers are distinct, except where they cannot be', () {
      for (final r in rateRounds) {
        final values = [
          for (final rate in Rate.values) r.valueOf(rate),
        ];
        final annual = r.quoted.contains('compounded annually');
        if (annual) {
          expect(values.toSet().length, 1,
              reason: '${r.subject}: compounded annually, all three are the '
                  'same number and the round exists to show that');
        } else {
          expect(values.toSet().length, 3,
              reason: '${r.subject}: two of the three read the same');
        }
      }
    });

    test('the effective rate is never below the nominal one', () {
      double pct(String s) =>
          double.parse(RegExp(r'[\d.]+').firstMatch(s)!.group(0)!);
      for (final r in rateRounds) {
        expect(pct(r.effective), greaterThanOrEqualTo(pct(r.nominal)),
            reason: '${r.subject}: compounding cannot earn less than the '
                'quoted rate');
        expect(pct(r.periodic), lessThanOrEqualTo(pct(r.nominal)),
            reason: '${r.subject}: a single period cannot cost more than the '
                'year it sits in');
      }
    });

    test('a question about n asks for the periodic rate', () {
      for (final r in rateRounds) {
        if (r.ask.contains('n =')) {
          expect(r.answer, Rate.periodic,
              reason: '${r.subject}: the rate has to match the n beside it');
        }
      }
      expect(rateRounds.where((r) => r.ask.contains('n =')).length,
          greaterThanOrEqualTo(2),
          reason: 'matching the rate to the period is the half of this that '
              'costs marks, and it needs more than one round');
    });

    test('the answer never repeats round to round', () {
      for (var i = 1; i < rateRounds.length; i++) {
        expect(rateRounds[i].answer, isNot(rateRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous rate');
      }
    });
  });

  group('what does it take', () {
    test('a growing diagram takes the flat part and the gradient', () {
      for (final r in takeRounds) {
        final costs = r.flows.where((f) => f.size < 0).toList();
        if (costs.length < 3) continue;
        final steps = <double>{};
        for (var i = 1; i < costs.length; i++) {
          if (costs[i].period == costs[i - 1].period + 1) {
            steps.add(
              ((costs[i].size - costs[i - 1].size) * 100).roundToDouble() / 100,
            );
          }
        }
        // Every consecutive step the same and non-zero is a gradient, and a
        // gradient always needs its own factor.
        final grows = steps.length == 1 && steps.first.abs() > 0.01;
        if (grows) {
          expect(r.answer, contains(2),
              reason: '${r.subject}: the diagram grows by a constant step and '
                  'the round does not call for the gradient');
        }
      }
    });

    test('a flat diagram never calls for the gradient', () {
      for (final r in takeRounds) {
        final costs = r.flows.where((f) => f.size < 0).toList();
        if (costs.length < 2) continue;
        final sizes = costs.map((f) => f.size).toSet();
        if (sizes.length == 1) {
          expect(r.answer, isNot(contains(2)),
              reason: '${r.subject}: nothing in the picture grows');
        }
      }
    });

    test('the answers are not all the same size', () {
      final sizes = takeRounds.map((r) => r.answer.length).toSet();
      expect(sizes, containsAll([1, 2, 3]),
          reason: 'one, two and three pieces all have to come up, or the count '
              'can be guessed');
    });

    test('every piece is needed somewhere, and none is repeated', () {
      final used = <int>{for (final r in takeRounds) ...r.answer};
      expect(used.length, pieces.length);
      for (final r in takeRounds) {
        expect(r.answer.toSet().length, r.answer.length, reason: r.subject);
        expect(r.answer, isNotEmpty, reason: r.subject);
      }
    });

    test('every arrow lands inside the drawn axis', () {
      for (final r in takeRounds) {
        for (final f in r.flows) {
          expect(f.period, inInclusiveRange(0, r.periods), reason: r.subject);
          expect(f.size, isNot(0), reason: r.subject);
        }
      }
    });

    test('the round with a salvage has an arrow pointing the other way', () {
      final mixed = takeRounds.where(
        (r) => r.flows.any((f) => f.size > 0) && r.flows.any((f) => f.size < 0),
      );
      expect(mixed, isNotEmpty,
          reason: 'money coming back has to look different from money going '
              'out, or the diagram is not doing its job');
    });
  });

  group('the boards run', () {
    testWidgets('a factor has to be chosen before locking in', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichFactorGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE ONE'), findsNothing);
      expect(find.text('THE OTHER WAY'), findsNothing);
    });

    testWidgets('capital recovery on the sinking fund round is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichFactorGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('factor-3')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THE OTHER WAY'), findsOneWidget);
    });

    testWidgets('the annual rate beside a monthly n is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichRateGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('rate-nominal')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('A DIFFERENT ONE'), findsOneWidget);
    });

    testWidgets('doing the flat part and stopping is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhatDoesItTakeGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('piece-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THOSE PIECES'), findsOneWidget);
    });

    testWidgets('both pieces together are accepted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhatDoesItTakeGame()));
      await tester.pumpAndSettle();

      for (final i in takeRounds.first.answer) {
        await tester.tap(find.byKey(ValueKey('piece-$i')));
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('ALL THE PIECES'), findsOneWidget);
    });
  });
}
