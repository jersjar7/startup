import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/calculus_figures.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/sign_the_bend_game.dart';
import 'package:mobile/features/games/slide_to_flat_game.dart';
import 'package:mobile/features/games/what_was_asked_game.dart';

/// Lesson eight. Two of its three items state a CURVE and ask a question about
/// it, so the answers are checked against the curve's own derivatives rather
/// than taken on trust. A wrong number in a round is a failing test here, not
/// a confusing round in someone's hand.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['slide-to-flat', 'sign-the-bend', 'what-was-asked']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('the arithmetic behind the curves', () {
    test('a polynomial differentiates the way it should', () {
      // f(x) = -2x^2 + 16x - 5  ->  f'(x) = -4x + 16, f''(x) = -4
      const f = Poly([-5, 16, -2]);
      expect(f.at(4), closeTo(27, 1e-9));
      expect(f.d.at(4), closeTo(0, 1e-9));
      expect(f.dd.at(0), closeTo(-4, 1e-9));
    });
  });

  group('slide to the flat spot', () {
    test('every stated answer really is where the slope is zero', () {
      for (final r in flatRounds) {
        expect(
          r.poly.d.at(r.answer.toDouble()),
          closeTo(0, 1e-9),
          reason: '${r.subject} is not flat at x = ${r.answer}',
        );
      }
    });

    test('the ask matches the way the curve bends there', () {
      for (final r in flatRounds) {
        final bend = r.poly.dd.at(r.answer.toDouble());
        final wantsHigh =
            r.ask.contains('hill') ||
            r.ask.contains('peak') ||
            r.ask.contains('top');
        expect(
          wantsHigh ? bend < 0 : bend > 0,
          isTrue,
          reason: '"${r.ask}" does not match the bend at x = ${r.answer}',
        );
      }
    });

    test('the answer is inside the span, and never where you start', () {
      for (final r in flatRounds) {
        expect(r.answer, inInclusiveRange(r.x0.toInt(), r.x1.toInt()));
        expect(r.startAt, inInclusiveRange(r.x0.toInt(), r.x1.toInt()));
        expect(r.startAt, isNot(r.answer), reason: r.ask);
      }
    });

    test('a curve with two flat spots is asked about both ways', () {
      final cubics = flatRounds.where((r) => r.poly.c.length == 4).toList();
      expect(cubics.length, greaterThanOrEqualTo(2));
      expect(cubics.map((r) => r.answer).toSet().length, greaterThan(1));
    });
  });

  group('sign the bend', () {
    test('a divider is only an inflection point when the sign flips', () {
      for (final r in bendRounds) {
        final flip = r.inflection;
        if (flip != null) {
          expect(r.poly.dd.at(flip), closeTo(0, 1e-9), reason: r.subject);
        }
        // Every cut that is NOT the flip has the same bend on both sides.
        final up = r.bendsUp;
        for (var i = 0; i < r.cuts.length; i++) {
          if (r.cuts[i] != flip) {
            expect(up[i], up[i + 1], reason: 'cut ${r.cuts[i]} of ${r.subject}');
          }
        }
      }
    });

    test('rounds where nothing flips are in the set', () {
      expect(
        bendRounds.any((r) => r.inflection == null),
        isTrue,
        reason: 'without these the item teaches that there is always a flip',
      );
      expect(bendRounds.any((r) => r.inflection != null), isTrue);
    });

    test('both flip directions appear', () {
      final flipping = bendRounds.where((r) => r.inflection != null);
      expect(flipping.any((r) => r.bendsUp.first == false), isTrue);
      expect(flipping.any((r) => r.bendsUp.first == true), isTrue);
    });

    test('a region is wide enough to hold a thumb', () {
      for (final r in bendRounds) {
        for (final (a, b) in r.regions) {
          expect(
            (b - a) / (r.x1 - r.x0),
            greaterThan(0.2),
            reason: '${r.subject} has a sliver of a region',
          );
        }
      }
    });
  });

  group('what was asked', () {
    test('every quantity in a round is distinct', () {
      for (final r in askedRounds) {
        expect(r.quantities.toSet().length, r.quantities.length, reason: r.question);
      }
    });

    test('the same working is asked two different ways somewhere', () {
      final byWorking = <String, Set<int>>{};
      for (final r in askedRounds) {
        byWorking.putIfAbsent(r.working, () => {}).add(r.answer);
      }
      expect(
        byWorking.values.any((answers) => answers.length > 1),
        isTrue,
        reason: 'the point of the item is that the question decides, not the '
            'working',
      );
    });

    test('a location and a value are both correct answers somewhere', () {
      final answers = [for (final r in askedRounds) r.quantities[r.answer]];
      expect(answers.any((a) => a.startsWith('x =') || a.startsWith('h =')), isTrue);
      expect(answers.any((a) => a.contains('(4)') || a.contains('(6)')), isTrue);
    });
  });

  group('the boards run', () {
    testWidgets('slide to flat grades the marker against the flat spot', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: SlideToFlatGame()));
      await tester.pumpAndSettle();

      // The marker starts away from the answer, so locking in immediately is
      // wrong and the round comes back.
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('STILL SLOPING'), findsOneWidget);
    });

    testWidgets('sign the bend will not accept a half-filled strip', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: SignTheBendGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('NO FLIP'),
        findsNothing,
        reason: 'an unmarked strip cannot be submitted',
      );
      expect(find.text('NOT THE BEND IT HAS'), findsNothing);
    });

    testWidgets('what was asked marks the wrong quantity wrong', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhatWasAskedGame()));
      await tester.pumpAndSettle();

      // Round one wants the height; tap the cost instead.
      await tester.tap(find.byKey(const ValueKey('quantity-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('TRUE, BUT NOT ASKED'), findsOneWidget);
    });
  });
}
