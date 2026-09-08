import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/land_the_resultant_game.dart';
import 'package:mobile/features/games/reaches_further_game.dart';
import 'package:mobile/features/games/stretch_it_game.dart';
import 'package:mobile/features/games/vector_figures.dart';

/// Lesson eleven. Two of its items are answered by pointing at a grid or by
/// working a number, neither of which the gate can describe, so the arithmetic
/// behind every round is checked here against the arrows themselves.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['land-the-resultant', 'stretch-it', 'reaches-further']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('the arithmetic behind the arrows', () {
    test('a vector knows its own length and sum', () {
      expect(const Vec(3, 4).length, closeTo(5, 1e-9));
      expect(const Vec(-3, -4).length, closeTo(5, 1e-9));
      expect(const Vec(1, 2) + const Vec(3, 4), const Vec(4, 6));
      expect(const Vec(2, -1) * 3, const Vec(6, -3));
    });
  });

  group('land the resultant', () {
    test('every answer lands inside the grid the student can see', () {
      for (final r in resultantRounds) {
        final (x, y) = r.answer;
        expect(x.abs(), lessThanOrEqualTo(6), reason: r.ask);
        expect(y.abs(), lessThanOrEqualTo(6), reason: r.ask);
        for (final p in r.parts) {
          expect(p.x.abs(), lessThanOrEqualTo(6));
          expect(p.y.abs(), lessThanOrEqualTo(6));
        }
      }
    });

    test('adding the lengths would never have got there', () {
      for (final r in resultantRounds) {
        var sumOfLengths = 0.0;
        for (final p in r.parts) {
          sumOfLengths += p.length;
        }
        var total = const Vec(0, 0);
        for (final p in r.parts) {
          total = total + p;
        }
        expect(
          total.length,
          lessThan(sumOfLengths - 1e-9),
          reason: '${r.ask} would come out the same either way, so it does '
              'not teach the difference',
        );
      }
    });

    test('negative components and a full cancellation both appear', () {
      expect(
        resultantRounds.any((r) => r.parts.any((p) => p.x < 0 || p.y < 0)),
        isTrue,
      );
      expect(
        resultantRounds.any((r) => r.answer == (0, 0)),
        isTrue,
        reason: 'two arrows adding to nothing is the clearest case there is',
      );
    });

    test('a round with three arrows is in the set', () {
      expect(resultantRounds.any((r) => r.parts.length > 2), isTrue);
      for (final r in resultantRounds) {
        expect(r.labels.length, r.parts.length, reason: r.ask);
      }
    });
  });

  group('stretch it to fit', () {
    test('the stated multiplier really does give the asked length', () {
      for (final r in stretchRounds) {
        final made = r.direction * r.answer.toDouble();
        expect(
          made.length,
          closeTo(r.wantLength, 1e-9),
          reason: '${r.shown} times ${r.answer} is not ${r.wantLength} long',
        );
      }
    });

    test('the opposite rounds are the negative ones, and only those', () {
      for (final r in stretchRounds) {
        expect(
          r.opposite,
          r.answer < 0,
          reason: '${r.shown} says one thing and multiplies by another',
        );
      }
    });

    test('rounds that are not unit length are in the set', () {
      final loose = stretchRounds.where((r) => !r.isUnit).toList();
      expect(
        loose.length,
        greaterThanOrEqualTo(2),
        reason: 'without these the multiplier is always the magnitude, which '
            'is the belief the item exists to break',
      );
      for (final r in loose) {
        expect(
          r.answer.abs(),
          isNot(r.wantLength.round()),
          reason: '${r.shown} would let the wrong rule get the right answer',
        );
      }
    });

    test('every answer is inside what the stepper can reach', () {
      for (final r in stretchRounds) {
        expect(r.answer, inInclusiveRange(-6, 6));
        expect(r.answer, isNot(0));
        final made = r.direction * r.answer.toDouble();
        expect(made.x.abs(), lessThanOrEqualTo(8));
        expect(made.y.abs(), lessThanOrEqualTo(8));
      }
    });
  });

  group('which reaches further', () {
    test('counting the components up gets every round wrong', () {
      for (final r in reachRounds) {
        expect(
          r.bySum,
          isNot(r.answer),
          reason: '${r.a} against ${r.b} rewards adding the parts up',
        );
      }
    });

    test('ties are in the set, and so is each side winning', () {
      final answers = reachRounds.map((r) => r.answer).toList();
      expect(answers, contains(Reach.same));
      expect(answers, contains(Reach.first));
      expect(answers, contains(Reach.second));
      expect(
        answers.where((a) => a == Reach.same).length,
        lessThan(reachRounds.length ~/ 2),
        reason: 'if half of them are ties, guessing the tie pays',
      );
    });

    test('both arrows fit the grid', () {
      for (final r in reachRounds) {
        for (final v in [r.a, r.b]) {
          expect(v.x.abs(), lessThanOrEqualTo(7));
          expect(v.y.abs(), lessThanOrEqualTo(7));
        }
      }
    });
  });

  group('the boards run', () {
    testWidgets('the resultant board will not submit an untouched grid', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: LandTheResultantGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS WHERE'), findsNothing);
      expect(find.text('NOT THERE'), findsNothing);
    });

    testWidgets('the multiplier moves and the round grades it', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: StretchItGame()));
      await tester.pumpAndSettle();

      // Round one wants 5; it starts at 1, so lock in early and be wrong.
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT LONG'), findsOneWidget);
    });

    testWidgets('a tie can be answered as a tie', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: ReachesFurtherGame()));
      await tester.pumpAndSettle();

      // Round one is not a tie, so calling it one is wrong.
      await tester.tap(find.byKey(const ValueKey('reach-same')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT ONE'), findsOneWidget);
    });
  });
}
