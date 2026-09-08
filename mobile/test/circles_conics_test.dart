import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/balance_both_sides_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/grid_figures.dart';
import 'package:mobile/features/games/place_the_center_game.dart';
import 'package:mobile/features/games/read_the_equation_game.dart';

/// Lesson six. Two of its three items are answered by pointing at something,
/// so the geometry and the token layout are pinned as well as the content.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in [
      'place-the-center',
      'read-the-equation',
      'balance-both-sides',
    ]) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('the grid', () {
    const g = GridGeometry(Size(360, 360));

    test('the axes run the way a student expects', () {
      expect(g.toScreen(3, 0).dx, greaterThan(g.origin.dx));
      expect(g.toScreen(0, 3).dy, lessThan(g.origin.dy), reason: 'up is up');
      expect(g.toScreen(-3, 0).dx, lessThan(g.origin.dx));
    });

    test('a tap on a lattice point finds it', () {
      for (final p in [(0, 0), (5, -3), (-6, -1), (2, 6)]) {
        expect(g.nearest(g.toScreen(p.$1, p.$2)), p);
      }
    });

    test('a tap anywhere on the grid lands on the nearest point', () {
      // The pitch is about 28 points on a phone, under the 44 a fingertip
      // wants, so nothing is a dead tap: a near miss costs the neighbour.
      final nearlyOrigin = g.toScreen(0, 0) + const Offset(9, -9);
      expect(g.nearest(nearlyOrigin), (0, 0));
      final leaningNext = g.toScreen(0, 0) + Offset(g.step * 0.6, 0);
      expect(g.nearest(leaningNext), (1, 0));
    });

    test('a tap outside the grid finds nothing', () {
      // Well beyond the last labelled point in both directions.
      expect(g.nearest(g.toScreen(6, 6) + const Offset(120, -120)), isNull);
    });
  });

  group('content', () {
    test('every centre fits on the grid the student is given', () {
      for (final r in centerRounds) {
        expect(r.center.$1.abs(), lessThanOrEqualTo(8));
        expect(r.center.$2.abs(), lessThanOrEqualTo(8));
      }
    });

    test('both sign traps are exercised', () {
      // A plus inside must appear (negative coordinate) and a minus inside
      // (positive coordinate), or the item only ever tests one direction.
      expect(centerRounds.any((r) => r.center.$2 < 0), isTrue);
      expect(centerRounds.any((r) => r.center.$2 > 0), isTrue);
      expect(centerRounds.any((r) => r.center.$1 < 0), isTrue);
    });

    test('the radius is never the number written in the equation', () {
      for (final r in centerRounds) {
        final rhs = double.parse(r.equation.split('=').last.trim());
        expect(r.radius * r.radius, closeTo(rhs, 0.001),
            reason: '${r.equation} does not describe radius ${r.radius}');
        expect(r.radius, isNot(rhs),
            reason: 'a round where r equals r squared teaches nothing');
      }
    });

    test('every asked-for token exists in its equation', () {
      for (final r in readRounds) {
        expect(r.answer, inInclusiveRange(0, r.tokens.length - 1));
        expect(r.tokens.length, greaterThanOrEqualTo(3));
      }
    });

    test('completing the square is asked on both sides every time', () {
      for (final b in balances) {
        expect(b.answers.length, greaterThan(b.slotsOnLeft),
            reason: 'the right-hand side has no blank, so nothing is balanced');
        // What goes on the left has to reappear on the right.
        final left = b.answers.take(b.slotsOnLeft).toList();
        final right = b.answers.skip(b.slotsOnLeft).toList();
        expect(right, left,
            reason: 'the two sides of "${b.left.first}" do not match');
        for (final a in b.answers) {
          expect(b.chips, contains(a));
        }
      }
    });

    test('the halve-without-squaring mistake is always on offer', () {
      for (final b in balances) {
        final wrong = b.chips.where((c) => !b.answers.contains(c));
        expect(wrong, isNotEmpty,
            reason: '"${b.left.first}" offers no wrong number at all');
      }
    });
  });

  group('playing', () {
    testWidgets('tapping the centre answers the first round', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: PlaceTheCenterGame()));

      final canvas = find.byType(CustomPaint).last;
      final rect = tester.getRect(canvas);
      final g = GridGeometry(rect.size);
      await tester.tapAt(rect.topLeft + g.toScreen(5, -3));
      await tester.pump();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('CORRECT'), findsOneWidget);
      expect(find.text('1/8'), findsOneWidget);
    });

    testWidgets('flipping the sign of the centre is marked wrong',
        (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: PlaceTheCenterGame()));

      final canvas = find.byType(CustomPaint).last;
      final rect = tester.getRect(canvas);
      final g = GridGeometry(rect.size);
      // (5, 3) instead of (5, -3): the trap the lesson names first.
      await tester.tapAt(rect.topLeft + g.toScreen(5, 3));
      await tester.pump();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THERE'), findsOneWidget);
      expect(find.textContaining('sign inside flips'), findsOneWidget);
    });

    testWidgets('tapping the right-hand side answers the radius question',
        (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: ReadTheEquationGame()));

      await tester.tap(find.byKey(const ValueKey('token-4')));
      await tester.pump();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();

      expect(find.text('CORRECT'), findsOneWidget);
      expect(find.textContaining('radius SQUARED'), findsOneWidget);
    });

    testWidgets('filling only the left-hand side is not balanced',
        (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: BalanceBothSidesGame()));

      // 25 and 9 belong on the left; put 5 and 3 on the right instead.
      for (final value in ['25', '9', '5', '3']) {
        await tester.tap(find.widgetWithText(InkWell, value).first);
        await tester.pump();
      }
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();

      expect(find.text('NOT BALANCED'), findsOneWidget);
    });
  });
}
