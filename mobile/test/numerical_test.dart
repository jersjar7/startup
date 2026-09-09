import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/can_it_start_game.dart';
import 'package:mobile/features/games/follow_the_tangent_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/which_method_game.dart';

/// Lesson sixteen, and the last of the Mathematics chapter. Both of its
/// drawn items state a curve and claim something about it, so the claims are
/// worked out from the curve here rather than taken on trust: the Newton step
/// from its own derivative, and the bracketing from the function's signs.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['follow-the-tangent', 'can-it-start', 'which-method']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('follow the tangent', () {
    test('the marked landing really is one Newton step', () {
      for (final r in tangentRounds) {
        expect(
          r.candidates[r.answer],
          closeTo(r.next, 1e-9),
          reason: '${r.shown} from ${r.start} does not land there',
        );
      }
    });

    test('every candidate is a mistake somebody actually makes', () {
      for (final r in tangentRounds) {
        final named = <double>{
          r.next, // right
          r.start + r.step, // added the correction instead of subtracting
          r.start, // never moved
        };
        for (final c in r.candidates) {
          final isRoot = r.poly.at(c).abs() < 1e-9;
          expect(
            named.any((v) => (v - c).abs() < 1e-9) || isRoot,
            isTrue,
            reason: '$c in ${r.shown} is not a landing anyone would pick',
          );
        }
      }
    });

    test('candidates are distinct and inside the picture', () {
      for (final r in tangentRounds) {
        expect(r.candidates.toSet().length, r.candidates.length);
        for (final c in r.candidates) {
          expect(c, inInclusiveRange(r.from, r.to), reason: '$c is off screen');
        }
        expect(r.start, inInclusiveRange(r.from, r.to));
      }
    });

    test('a straight line and a near-flat slope are both in the set', () {
      expect(
        tangentRounds.any((r) => r.poly.c.length == 2),
        isTrue,
        reason: 'a line converging in one step is the best case',
      );
      expect(
        tangentRounds.any((r) => r.poly.d.at(r.start).abs() <= 1),
        isTrue,
        reason: 'a flat slope flinging the estimate away is the worst case',
      );
    });

    test('one round overshoots past the root, and most do not', () {
      bool overshoots(TangentRound r) {
        // Any real root of the curve between where you were and where you
        // landed means the step jumped over it.
        final root = _rootNear(r);
        return root != null &&
            ((r.start < root && root < r.next) ||
                (r.next < root && root < r.start));
      }

      expect(tangentRounds.where(overshoots).length, greaterThanOrEqualTo(1));
      expect(
        tangentRounds.where(overshoots).length,
        lessThan(tangentRounds.length),
        reason: 'overshooting every time would teach that it always does',
      );
    });
  });

  group('can it start here', () {
    test('exactly one span ever qualifies, or none do', () {
      for (final r in bracketRounds) {
        final qualifying = [
          for (final s in r.brackets)
            if (r.poly.at(s.$1) * r.poly.at(s.$2) < 0) s,
        ];
        expect(
          qualifying.length,
          lessThanOrEqualTo(1),
          reason: '${r.shown} has ${qualifying.length} valid brackets, so the '
              'round has more than one right answer',
        );
        if (r.answer != null) expect(qualifying.length, 1);
      }
    });

    test('a round where nothing works is in the set', () {
      expect(
        bracketRounds.any((r) => r.answer == null),
        isTrue,
        reason: 'otherwise one of the three is always right and the escape '
            'hatch is decoration',
      );
      expect(
        bracketRounds.where((r) => r.answer == null).length,
        1,
        reason: 'more than one and "none" stops being a surprise',
      );
    });

    test('a span holding two roots is offered and does not qualify', () {
      var found = false;
      for (final r in bracketRounds) {
        for (final s in r.brackets) {
          final crossings = _crossings(r, s.$1, s.$2);
          if (crossings >= 2) {
            found = true;
            expect(
              r.poly.at(s.$1) * r.poly.at(s.$2) < 0,
              isFalse,
              reason: 'a span with two roots cannot have opposite ends',
            );
          }
        }
      }
      expect(
        found,
        isTrue,
        reason: 'the "a root is in there" trap needs a span that has one',
      );
    });

    test('every span sits inside the picture and is worth tapping', () {
      for (final r in bracketRounds) {
        for (final s in r.brackets) {
          expect(s.$1, inInclusiveRange(r.from, r.to));
          expect(s.$2, inInclusiveRange(r.from, r.to));
          expect(
            (s.$2 - s.$1) / (r.to - r.from),
            greaterThan(0.08),
            reason: '${r.shown} has a span too narrow to hit',
          );
        }
      }
    });

    test('the answer moves around the three spans', () {
      final answers = bracketRounds.map((r) => r.answer).toSet();
      expect(answers.length, greaterThan(2));
    });
  });

  group('which method', () {
    test('all three verdicts are reachable', () {
      expect(
        methodRounds.map((r) => r.answer).toSet(),
        MethodPick.values.toSet(),
      );
    });

    test('both named causes of Newton failing appear', () {
      final struggling = methodRounds
          .where((r) => r.answer == MethodPick.newtonStruggles)
          .map((r) => r.situation)
          .join(' ');
      expect(struggling, contains('flat'), reason: 'the near-zero derivative');
      expect(struggling, contains('long way'), reason: 'the far guess');
    });

    test('every situation says what is actually available', () {
      for (final r in methodRounds) {
        expect(
          r.situation.contains('derivative') ||
              r.situation.contains('slope') ||
              r.situation.contains('sign') ||
              r.situation.contains('above the axis') ||
              r.situation.contains('converge'),
          isTrue,
          reason: 'a round that names neither what you have nor what you need '
              'is a guess: ${r.situation}',
        );
      }
    });
  });

  group('the boards run', () {
    testWidgets('adding the correction instead of subtracting is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: FollowTheTangentGame()));
      await tester.pumpAndSettle();

      // Round one lands at 2.5; 5.5 is what adding the step would give.
      await tester.tap(find.byKey(const ValueKey('landing-3')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THERE'), findsOneWidget);
    });

    testWidgets('the tangent landing is accepted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: FollowTheTangentGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('landing-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE LANDING'), findsOneWidget);
    });

    testWidgets('a same-signed span is marked wrong', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: CanItStartGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('span-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT SPAN'), findsOneWidget);
    });

    testWidgets('calling for bisection when Newton is called for is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichMethodGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('method-bisection')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT ONE'), findsOneWidget);
    });
  });
}

/// A root of the round's curve inside the drawn span, if there is one.
double? _rootNear(TangentRound r) {
  const steps = 2000;
  for (var i = 0; i < steps; i++) {
    final a = r.from + (r.to - r.from) * i / steps;
    final b = r.from + (r.to - r.from) * (i + 1) / steps;
    if (r.poly.at(a) * r.poly.at(b) <= 0) return (a + b) / 2;
  }
  return null;
}

/// How many times the round's curve crosses the axis between two points.
int _crossings(BracketRound r, double a, double b) {
  const steps = 2000;
  var count = 0;
  for (var i = 0; i < steps; i++) {
    final p = a + (b - a) * i / steps;
    final q = a + (b - a) * (i + 1) / steps;
    if (r.poly.at(p) * r.poly.at(q) < 0) count++;
  }
  return count;
}
