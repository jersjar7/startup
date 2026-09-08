import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/pick_u_game.dart';
import 'package:mobile/features/games/whats_missing_game.dart';
import 'package:mobile/features/games/which_way_simpler_game.dart';

/// Lesson nine. Its first item is the only one in the app whose answer is a
/// PAIR that has to agree with itself, and the gate cannot describe that, so
/// the du half is pinned here.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['pick-u', 'which-way-simpler', 'whats-missing']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('pick u, pick du', () {
    test('both halves point at a real choice', () {
      for (final r in uSubRounds) {
        expect(r.uAnswer, inInclusiveRange(0, r.uOptions.length - 1));
        expect(r.duAnswer, inInclusiveRange(0, r.duOptions.length - 1));
        expect(r.uOptions.toSet().length, r.uOptions.length, reason: r.integrand);
        expect(
          r.duOptions.toSet().length,
          r.duOptions.length,
          reason: r.integrand,
        );
      }
    });

    test('the du on offer is the derivative of the u on offer', () {
      // Checked by hand against the lesson, one pair per round, because
      // nothing in the app does symbolic differentiation.
      const pairs = {
        r'\sin x': r'\cos x\,dx',
        r'x^2+1': r'2x\,dx',
        r'\cos x': r'-\sin x\,dx',
        r'3x^2': r'6x\,dx',
        r'\ln x': r'\frac{1}{x}\,dx',
      };
      for (final r in uSubRounds) {
        if (r.noSub) continue;
        final u = r.uOptions[r.uAnswer];
        expect(
          pairs.containsKey(u),
          isTrue,
          reason: '$u is not a u this test knows how to check',
        );
        expect(
          r.duOptions[r.duAnswer],
          pairs[u],
          reason: 'the du picked for $u is not its derivative',
        );
      }
    });

    test('a round with no substitution in it is in the set', () {
      expect(
        uSubRounds.any((r) => r.noSub),
        isTrue,
        reason: 'otherwise the item teaches that there is always a u',
      );
      expect(uSubRounds.where((r) => r.noSub).length, 1);
    });

    test('the right u is not always in the same place', () {
      final live = uSubRounds.where((r) => !r.noSub);
      expect(live.map((r) => r.uAnswer).toSet().length, greaterThan(1));
    });
  });

  group('which way gets simpler', () {
    test('every round offers exactly two legal choices', () {
      for (final r in partsRounds) {
        expect(r.branches.length, 2, reason: r.integral);
        expect(r.answer, inInclusiveRange(0, 1));
        expect(r.branches[0].u, isNot(r.branches[1].u));
      }
    });

    test('the two branches are each other, swapped', () {
      // u of one branch is dv of the other, minus the dx. A branch pair that
      // does not swap is not showing the same decision made both ways.
      for (final r in partsRounds) {
        final a = r.branches[0];
        final b = r.branches[1];
        expect(b.dv.startsWith(a.u), isTrue, reason: r.integral);
        expect(a.dv.startsWith(b.u), isTrue, reason: r.integral);
      }
    });

    test('the better branch is not always the same one', () {
      expect(partsRounds.map((r) => r.answer).toSet(), {0, 1});
    });
  });

  group("what's missing", () {
    test('every verdict in the checklist gets used', () {
      final used = missingRounds.map((r) => r.answer).toSet();
      expect(
        used.length,
        missingVerdicts.length,
        reason: 'a verdict nobody ever needs is a distractor, not a checklist '
            'item',
      );
    });

    test('more than one round is actually finished', () {
      expect(
        missingRounds.where((r) => r.answer == 0).length,
        greaterThan(1),
        reason: 'if only one is clean, "it is finished" becomes a guess',
      );
    });

    test('a plus C round and a definite round both appear', () {
      expect(missingRounds.any((r) => !r.problem.contains('_')), isTrue);
      expect(missingRounds.any((r) => r.problem.contains('_')), isTrue);
    });
  });

  group('the boards run', () {
    testWidgets('pick u will not submit on one half of the pair', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: PickUGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('BOTH HALVES'), findsNothing);
      expect(find.textContaining('WRONG du'), findsNothing);
    });

    testWidgets('a right u with a wrong du is named as exactly that', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: PickUGame()));
      await tester.pumpAndSettle();

      // Round one: u = sin x is right, and any du but the first is wrong.
      await tester.tap(find.byKey(const ValueKey('u-0')));
      await tester.tap(find.byKey(const ValueKey('du-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('RIGHT u, WRONG du'), findsOneWidget);
    });

    testWidgets('the harder branch is marked wrong', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichWaySimplerGame()));
      await tester.pumpAndSettle();

      // Round one's second branch is the one that makes it worse.
      await tester.tap(find.byKey(const ValueKey('branch-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT WAY IS HARDER'), findsOneWidget);
    });

    testWidgets('a missing plus C is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhatsMissingGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('verdict-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('CAUGHT IT'), findsOneWidget);
    });
  });
}
