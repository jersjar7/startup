import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/is_there_a_deal_game.dart';
import 'package:mobile/features/games/which_delivery_game.dart';
import 'package:mobile/features/games/who_pays_the_overrun_game.dart';

/// Chapter three, lesson five. Contracts are the one topic in this chapter
/// with structure a test can check: an exchange has an order, an overrun is a
/// number against another number, and a delivery method is a count of lines.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in [
      'is-there-a-deal',
      'who-pays-the-overrun',
      'which-delivery',
    ]) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('is there a deal yet', () {
    test('every exchange has four turns and a valid answer', () {
      for (final r in dealRounds) {
        expect(r.lines.length, 4, reason: r.subject);
        expect(r.answer == noDeal || (r.answer >= 0 && r.answer < 4), isTrue,
            reason: r.subject);
        expect(r.rule.trim(), isNotEmpty, reason: r.subject);
      }
    });

    test('nothing binds on the first line', () {
      // Something has to be offered before anything can be accepted, so a
      // round that binds on its opening turn is a round with a missing step.
      for (final r in dealRounds) {
        expect(r.answer, isNot(0), reason: r.subject);
      }
    });

    test('the two sides alternate, so an offer is answered by the other', () {
      for (final r in dealRounds) {
        for (var i = 1; i < r.lines.length; i++) {
          expect(r.lines[i].who, isNot(r.lines[i - 1].who),
              reason: '${r.subject}: the same party speaks twice running');
        }
      }
    });

    test('the binding moment is not always in the same place', () {
      final answers = dealRounds.map((r) => r.answer).toSet();
      expect(answers.contains(noDeal), isTrue,
          reason: 'a set where something always forms teaches half the rule');
      expect(answers.length, greaterThanOrEqualTo(2));
      expect(dealRounds.where((r) => r.answer == noDeal).length, 2,
          reason: 'exactly two, so it stays a real possibility and not the '
              'obvious one');
    });

    test('both ways a deal fails are shown', () {
      final failures = dealRounds
          .where((r) => r.answer == noDeal)
          .map((r) => r.rule)
          .toSet();
      expect(failures.length, 2,
          reason: 'the two failures are for different reasons, or one of them '
              'is never met');
    });

    test('the counter-offer round really contains a counter-offer', () {
      final counter = dealRounds.firstWhere(
        (r) => r.rule.contains('counter-offer') && r.answer != noDeal,
      );
      expect(counter.answer, greaterThanOrEqualTo(2),
          reason: 'a counter-offer needs an offer before it and an acceptance '
              'after it, so it cannot bind before the third turn');
    });
  });

  group('who pays the overrun', () {
    test('the drawn bar always overruns the priced amount', () {
      for (final r in overrunRounds) {
        expect(r.actual, greaterThan(r.priced), reason: r.contract);
        expect(r.priced, greaterThan(0), reason: r.contract);
        expect(r.pricedLabel.trim(), isNotEmpty, reason: r.contract);
      }
    });

    test('both parties pay somewhere, and neither always', () {
      for (final p in Payer.values) {
        expect(overrunRounds.where((r) => r.answer == p).length,
            greaterThanOrEqualTo(2),
            reason: '$p never carries it');
      }
    });

    test('a fixed price falls on the contractor unless the scope moved', () {
      for (final r in overrunRounds.where(
        (r) => r.contract.toLowerCase().startsWith('lump sum'),
      )) {
        final scopeMoved = r.contract.toLowerCase().contains('change');
        expect(r.answer, scopeMoved ? Payer.owner : Payer.contractor,
            reason: '${r.contract}: a fixed price is fixed against a scope, '
                'and this round has the risk on the wrong side of that');
      }
    });

    test('reimbursed contracts always fall on the owner', () {
      for (final r in overrunRounds) {
        final reimbursed = r.contract.toLowerCase().contains('cost plus') ||
            r.contract.toLowerCase().contains('time and materials') ||
            r.contract.toLowerCase().contains('unit price');
        if (reimbursed) {
          expect(r.answer, Payer.owner, reason: r.contract);
        }
      }
    });

    test('the guaranteed maximum round swaps the parties at the line', () {
      final gmp = overrunRounds.firstWhere(
        (r) => r.contract.toLowerCase().contains('guaranteed maximum'),
      );
      expect(gmp.answer, Payer.contractor,
          reason: 'above the guarantee is the whole meaning of "at risk"');
    });

    test('every contract type in the lesson appears once', () {
      final kinds = overrunRounds.map((r) => r.contract).toSet();
      expect(kinds.length, overrunRounds.length,
          reason: 'a contract type is used twice, which wastes a round');
    });
  });

  group('which delivery', () {
    test('every method is the answer twice', () {
      for (final d in Delivery.values) {
        expect(deliveryRounds.where((r) => r.answer == d).length, 2,
            reason: '$d appears the wrong number of times');
      }
    });

    test('the method never repeats round to round', () {
      for (var i = 1; i < deliveryRounds.length; i++) {
        expect(deliveryRounds[i].answer, isNot(deliveryRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous method');
      }
    });

    test('the drawn shapes really differ in how many the owner holds', () {
      int held(Delivery d) => boxesFor(d).where((b) => b.$2).length;
      expect(held(Delivery.designBuild), 1,
          reason: 'design-build is one contract, and that is the whole point');
      expect(held(Delivery.designBidBuild), 2);
      expect(held(Delivery.cmAtRisk), 2);
    });

    test('the design-build shape has somebody the owner does not hold', () {
      final loose = boxesFor(Delivery.designBuild).where((b) => !b.$2);
      expect(loose, isNotEmpty,
          reason: 'without a party hanging off the design-builder, the picture '
              'does not show what the owner gave up');
    });

    test('no description names its own answer', () {
      const names = ['design-build', 'design-bid-build', 'at risk', 'CMAR'];
      for (final r in deliveryRounds) {
        for (final name in names) {
          expect(r.description.toLowerCase().contains(name.toLowerCase()),
              isFalse,
              reason: '${r.subject} says "$name"');
        }
      }
    });
  });

  group('the boards run', () {
    testWidgets('a line has to be chosen before locking in', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: IsThereADealGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE MOMENT'), findsNothing);
      expect(find.text('NOT THERE'), findsNothing);
    });

    testWidgets('binding on the inquiry is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: IsThereADealGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('line-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THERE'), findsOneWidget);
    });

    testWidgets('the acceptance is accepted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: IsThereADealGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(ValueKey('line-${dealRounds.first.answer}')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE MOMENT'), findsOneWidget);
    });

    testWidgets('putting the fixed-price overrun on the owner is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhoPaysTheOverrunGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('payer-owner')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THE OTHER SIDE'), findsOneWidget);
    });

    testWidgets('reading the single-entity job as traditional is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichDeliveryGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('delivery-designBidBuild')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('A DIFFERENT SHAPE'), findsOneWidget);
    });
  });
}
