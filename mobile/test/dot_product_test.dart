import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/open_or_closed_game.dart';
import 'package:mobile/features/games/shadow_falls_game.dart';
import 'package:mobile/features/games/take_the_diagonal_game.dart';

/// Lesson twelve. Its answers are a set of cells, a sign, and a place on a
/// line; only the middle one is a choice the gate can look at. So the numbers
/// behind all three are checked here against the vectors themselves.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['take-the-diagonal', 'open-or-closed', 'shadow-falls']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('take the diagonal', () {
    test('the answer is the diagonal and nothing else', () {
      for (final r in diagonalRounds) {
        expect(r.answer.length, r.n);
        for (final cell in r.answer) {
          expect(cell ~/ r.n, cell % r.n, reason: 'cell $cell is off-diagonal');
        }
      }
    });

    test('both vectors have a component for every axis', () {
      for (final r in diagonalRounds) {
        expect(r.a.length, r.n);
        expect(r.b.length, r.n);
      }
    });

    test('no two cells in a round read the same', () {
      // Two identical-looking cells means one turns green and its twin turns
      // red, which reads as arbitrary rather than as a rule. It happens
      // whenever one vector repeats a component.
      for (final r in diagonalRounds) {
        final texts = <String>[
          for (var row = 0; row < r.n; row++)
            for (var col = 0; col < r.n; col++) r.cell(row, col),
        ];
        expect(
          texts.toSet().length,
          texts.length,
          reason: 'a round with A=${r.a} and B=${r.b} shows the same product '
              'in two places',
        );
      }
    });

    test('two and three dimensional rounds both appear', () {
      final sizes = diagonalRounds.map((r) => r.n).toSet();
      expect(sizes, containsAll([2, 3]));
    });

    test('negatives, a zero component, and a zero result all appear', () {
      expect(
        diagonalRounds.any((r) => r.a.any((v) => v < 0) || r.b.any((v) => v < 0)),
        isTrue,
      );
      expect(
        diagonalRounds.any((r) => r.a.contains(0) || r.b.contains(0)),
        isTrue,
      );
      int dot(DiagonalRound r) {
        var sum = 0;
        for (var i = 0; i < r.n; i++) {
          sum += r.a[i] * r.b[i];
        }
        return sum;
      }

      expect(
        diagonalRounds.any((r) => dot(r) == 0),
        isTrue,
        reason: 'a perpendicular pair is the case worth meeting early',
      );
    });
  });

  group('open or closed', () {
    test('every stated sign is the sign the components give', () {
      for (final r in signRounds) {
        final byHand = r.a.x * r.b.x + r.a.y * r.b.y;
        expect(r.dot, closeTo(byHand, 1e-9));
        switch (r.answer) {
          case DotSign.positive:
            expect(byHand, greaterThan(0));
          case DotSign.zero:
            expect(byHand, closeTo(0, 1e-9));
          case DotSign.negative:
            expect(byHand, lessThan(0));
        }
      }
    });

    test('all three verdicts are reachable', () {
      expect(signRounds.map((r) => r.answer).toSet(), DotSign.values.toSet());
    });

    test('a perpendicular pair of different lengths is in the set', () {
      expect(
        signRounds.any(
          (r) =>
              r.answer == DotSign.zero &&
              (r.a.length - r.b.length).abs() > 1,
        ),
        isTrue,
        reason: 'otherwise a right angle looks like it needs equal arrows',
      );
    });

    test('a round sits in the quadrant nobody expects', () {
      expect(
        signRounds.any((r) => r.a.x < 0 && r.a.y < 0),
        isTrue,
        reason: 'the angle between them is the story, not where they sit',
      );
    });

    test('both arrows fit the grid', () {
      for (final r in signRounds) {
        for (final v in [r.a, r.b]) {
          expect(v.x.abs(), lessThanOrEqualTo(7));
          expect(v.y.abs(), lessThanOrEqualTo(7));
        }
      }
    });
  });

  group('where the shadow falls', () {
    test('every member direction really is one long', () {
      for (final r in shadowRounds) {
        expect(
          r.unit.length,
          closeTo(1, 1e-9),
          reason: '${r.member} is not normalized, so its marks would lie',
        );
      }
    });

    test('every shadow lands on a whole mark, inside the ruler', () {
      for (final r in shadowRounds) {
        final exact = r.force.x * r.unit.x + r.force.y * r.unit.y;
        expect(
          exact,
          closeTo(r.answer.toDouble(), 1e-9),
          reason: '${r.member} gives a shadow between two marks',
        );
        expect(r.answer, inInclusiveRange(-4, 7));
      }
    });

    test('a negative shadow and a zero shadow are both in the set', () {
      expect(shadowRounds.any((r) => r.answer < 0), isTrue);
      expect(
        shadowRounds.any((r) => r.answer == 0),
        isTrue,
        reason: 'perpendicular has to show up as a length of nothing',
      );
    });

    test('most members are written at a length that is not one', () {
      // If every member arrived already normalized, the division would never
      // matter and the item would quietly stop teaching the thing it exists
      // for. The card shows the member as an engineer would write it.
      final needsDividing = shadowRounds
          .where((r) => !r.member.contains('1\\hat{i} + 0'))
          .length;
      expect(
        needsDividing,
        greaterThanOrEqualTo(5),
        reason: 'the division has to be doing work in most rounds',
      );
    });
  });

  group('the boards run', () {
    testWidgets('an off-diagonal cell is marked wrong', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: TakeTheDiagonalGame()));
      await tester.pumpAndSettle();

      // Round one is two by two: cells 0 and 3 are the diagonal, 1 is not.
      await tester.tap(find.byKey(const ValueKey('cell-0')));
      await tester.tap(find.byKey(const ValueKey('cell-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THOSE CELLS'), findsOneWidget);
    });

    testWidgets('the whole diagonal is accepted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: TakeTheDiagonalGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('cell-0')));
      await tester.tap(find.byKey(const ValueKey('cell-3')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THE DIAGONAL'), findsOneWidget);
    });

    testWidgets('a right angle reads as perpendicular, not merely right', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: OpenOrClosedGame()));
      await tester.pumpAndSettle();

      // Round one leans the same way, so zero is the wrong call.
      await tester.tap(find.byKey(const ValueKey('sign-zero')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT SIGN'), findsOneWidget);
    });

    testWidgets('the shadow board will not submit an untouched member', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: ShadowFallsGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE SHADOW'), findsNothing);
      expect(find.text('NOT THAT FAR'), findsNothing);
    });
  });
}
