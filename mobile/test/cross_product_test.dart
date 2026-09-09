import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/cross_figures.dart';
import 'package:mobile/features/games/fix_the_sign_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/which_region_game.dart';
import 'package:mobile/features/games/which_way_turns_game.dart';

/// Lesson thirteen. The turn item states arrows and the answer comes out of
/// them, so the two are checked against each other here, including the pair of
/// rounds that exist only to be the same arrows in the opposite order.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['which-way-turns', 'which-region', 'fix-the-sign']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('which way does it turn', () {
    test('every verdict matches the arrows that produced it', () {
      for (final r in turnRounds) {
        final byHand = r.first.x * r.second.y - r.first.y * r.second.x;
        expect(r.k, closeTo(byHand, 1e-9));
        switch (r.answer) {
          case Turn.counter:
            expect(byHand, greaterThan(0));
          case Turn.clockwise:
            expect(byHand, lessThan(0));
          case Turn.none:
            expect(byHand, closeTo(0, 1e-9));
        }
      }
    });

    test('all three verdicts are reachable', () {
      expect(turnRounds.map((r) => r.answer).toSet(), Turn.values.toSet());
    });

    test('one pair of rounds is the same arrows, swapped', () {
      var found = false;
      for (final a in turnRounds) {
        for (final b in turnRounds) {
          if (a.first == b.second && a.second == b.first) {
            expect(
              a.answer,
              isNot(b.answer),
              reason: 'swapping the order has to change the answer',
            );
            found = true;
          }
        }
      }
      expect(
        found,
        isTrue,
        reason: 'without a swapped pair the item never shows order mattering',
      );
    });

    test('every arrow fits the grid', () {
      for (final r in turnRounds) {
        for (final v in [r.first, r.second]) {
          expect(v.x.abs(), lessThanOrEqualTo(6));
          expect(v.y.abs(), lessThanOrEqualTo(6));
        }
      }
    });
  });

  group('which region', () {
    test('all three shapes are the answer somewhere', () {
      expect(regionRounds.map((r) => r.answer).toSet(), Region.values.toSet());
    });

    test('the two edges are never square to each other', () {
      // A right angle collapses the parallelogram onto the box, and the round
      // would then have two correct answers.
      for (final r in regionRounds) {
        final dot = r.u.x * r.v.x + r.u.y * r.v.y;
        expect(
          dot.abs(),
          greaterThan(1e-9),
          reason: 'perpendicular edges make the box and the parallelogram the '
              'same shape',
        );
      }
    });

    test('the two edges are never parallel either', () {
      for (final r in regionRounds) {
        final cross = r.u.x * r.v.y - r.u.y * r.v.x;
        expect(cross.abs(), greaterThan(1e-9), reason: 'a flat plot');
      }
    });

    test('a halving round and a whole round share one pair of edges', () {
      final pairs = <String, Set<Region>>{};
      for (final r in regionRounds) {
        pairs.putIfAbsent('${r.u}|${r.v}', () => {}).add(r.answer);
      }
      expect(
        pairs.values.any(
          (s) => s.contains(Region.triangle) &&
              s.contains(Region.parallelogram),
        ),
        isTrue,
        reason: 'the factor of two only lands when the picture is identical',
      );
    });
  });

  group('fix the sign', () {
    test('the bad line is a real line, or there is none', () {
      for (final r in expansions) {
        expect(r.terms.length, 3);
        if (r.bad != null) expect(r.bad, inInclusiveRange(0, 2));
      }
    });

    test('more than one round is completely clean', () {
      expect(
        expansions.where((r) => r.bad == null).length,
        greaterThan(1),
        reason: 'if only one is clean, saying so becomes a guess',
      );
    });

    test('a clean round really does carry the plus minus plus pattern', () {
      for (final r in expansions.where((r) => r.bad == null)) {
        expect(r.terms[0].working.startsWith('+'), isTrue);
        expect(
          r.terms[1].working.startsWith('-'),
          isTrue,
          reason: 'the middle term is subtracted, always',
        );
        expect(r.terms[2].working.startsWith('+'), isTrue);
      }
    });

    test('the middle sign is the fault more than once', () {
      expect(
        expansions.where((r) => r.bad == 1).length,
        greaterThanOrEqualTo(2),
        reason: 'it is the one the lesson spends its tip on',
      );
    });

    test('every line names which component it is', () {
      for (final r in expansions) {
        for (final t in r.terms) {
          expect(t.working, contains('\\big['));
          expect(t.value, isNotEmpty);
        }
      }
    });
  });

  group('the boards run', () {
    testWidgets('calling a clockwise turn counterclockwise is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichWayTurnsGame()));
      await tester.pumpAndSettle();

      // Round one turns counterclockwise, so clockwise is the wrong call.
      await tester.tap(find.byKey(const ValueKey('turn-clockwise')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THE OTHER WAY'), findsOneWidget);
    });

    testWidgets('the triangle is wrong when the parallelogram was asked for', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichRegionGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('region-triangle')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT SHAPE'), findsOneWidget);
    });

    testWidgets('the j line is found', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: FixTheSignGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('term-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE ONE'), findsOneWidget);
    });
  });
}
