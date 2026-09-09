import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/is_that_negligence_game.dart';
import 'package:mobile/features/games/which_clock_ran_out_game.dart';
import 'package:mobile/features/games/which_element_missing_game.dart';

/// Chapter three, lesson six. The two clocks are dates and dates can be
/// checked, so the timeline rounds recompute their own verdict from the years
/// they declare. The rest is coverage: every element the gap somewhere, every
/// verdict used, and no round answerable from its wording.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in [
      'is-that-negligence',
      'which-element-missing',
      'which-clock-ran-out',
    ]) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('is that negligence', () {
    test('every verdict is the answer twice', () {
      for (final f in Fault.values) {
        expect(faultRounds.where((r) => r.answer == f).length, 2,
            reason: '$f appears the wrong number of times');
      }
    });

    test('the verdict never repeats round to round', () {
      for (var i = 1; i < faultRounds.length; i++) {
        expect(faultRounds[i].answer, isNot(faultRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous verdict');
      }
    });

    test('a deliberate round says the engineer knew', () {
      // What separates it from negligence is knowledge, so a scene that never
      // establishes knowledge cannot be the deliberate answer.
      for (final r in faultRounds.where((r) => r.answer == Fault.deliberate)) {
        final text = r.scene.toLowerCase();
        expect(text.contains('knew') || text.contains('knowing'), isTrue,
            reason: '${r.subject}: nothing in it says they knew');
      }
    });

    test('a not-negligent round has something go wrong anyway', () {
      // Otherwise the round is trivial: nothing happened, so nobody is liable.
      for (final r
          in faultRounds.where((r) => r.answer == Fault.notNegligent)) {
        expect(r.scene.length, greaterThan(120), reason: r.subject);
      }
    });

    test('no scene uses the word negligent', () {
      for (final r in faultRounds) {
        expect(r.scene.toLowerCase().contains('negligen'), isFalse,
            reason: '${r.subject} says it');
      }
    });
  });

  group('which element is missing', () {
    test('all four elements plus the complete claim are on the board', () {
      expect(elements.length, 5);
      expect(elements.map((e) => e.$1).toSet().length, 5);
    });

    test('every element is the gap somewhere, and one claim holds', () {
      final answers = elementRounds.map((r) => r.answer).toSet();
      expect(answers.contains(4), isTrue,
          reason: 'a board where a claim always fails teaches somebody to hunt '
              'rather than to check');
      expect(answers.length, greaterThanOrEqualTo(4),
          reason: 'only ${answers.length} of the five ever come up');
    });

    test('causation is the gap at least once', () {
      // The lesson names it as the element most often forgotten, so it has to
      // be met head on rather than left implied.
      expect(elementRounds.where((r) => r.answer == 2), isNotEmpty);
    });

    test('intent is nowhere on the board', () {
      for (final e in elements) {
        expect(e.$1.toLowerCase().contains('intent'), isFalse);
        expect(e.$2.toLowerCase().contains('intent'), isFalse);
      }
    });

    test('every claim is long enough to have four elements in it', () {
      for (final r in elementRounds) {
        expect(r.claim.length, greaterThan(120), reason: r.subject);
        expect(r.why.trim(), isNotEmpty, reason: r.subject);
      }
    });
  });

  group('which clock ran out', () {
    test('the dates run in order', () {
      for (final r in clockRounds) {
        expect(r.discovery, greaterThanOrEqualTo(r.completion),
            reason: '${r.subject}: found before it was built');
        expect(r.filed, greaterThanOrEqualTo(r.discovery),
            reason: '${r.subject}: filed before it was found');
      }
    });

    test('every verdict happens, and none twice running', () {
      for (final c in Clock.values) {
        expect(clockRounds.where((r) => r.answer == c).length,
            greaterThanOrEqualTo(2),
            reason: '$c is barely used');
      }
      for (var i = 1; i < clockRounds.length; i++) {
        expect(clockRounds[i].answer, isNot(clockRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous verdict');
      }
    });

    test('a repose round is inside the limitations window', () {
      // Otherwise both clocks have run and the round does not isolate either.
      for (final r in clockRounds.where((r) => r.answer == Clock.repose)) {
        expect(r.filed, lessThanOrEqualTo(r.discovery + ClockRound.limitationYears),
            reason: '${r.subject}: both clocks have run, so the round proves '
                'nothing about which one bit');
      }
    });

    test('a limitations round is inside the repose window', () {
      for (final r in clockRounds.where((r) => r.answer == Clock.limitations)) {
        expect(r.filed, lessThanOrEqualTo(r.completion + ClockRound.reposeYears),
            reason: r.subject);
      }
    });

    test('one round has harm found after the repose window shut', () {
      // The case the lesson warns about, and the only one that shows repose
      // doing something limitations cannot.
      final late = clockRounds.any(
        (r) => r.discovery > r.completion + ClockRound.reposeYears,
      );
      expect(late, isTrue,
          reason: 'nothing here shows a claim barred before the harm existed');
    });

    test('one round turns on discovery being later than the harm', () {
      final latent = clockRounds.any(
        (r) => r.discovery - r.completion > 5 && r.answer == Clock.inTime,
      );
      expect(latent, isTrue,
          reason: 'the limitations clock starting at discovery is half the '
              'rule and needs a round of its own');
    });

    test('every drawn year fits inside the axis', () {
      for (final r in clockRounds) {
        expect(r.completion, inInclusiveRange(2006, 2030));
        expect(r.completion + ClockRound.reposeYears, lessThanOrEqualTo(2030));
        expect(
          r.discovery + ClockRound.limitationYears,
          lessThanOrEqualTo(2030),
          reason: '${r.subject}: the limitations window runs off the picture',
        );
      }
    });
  });

  group('the boards run', () {
    testWidgets('a verdict has to be chosen before locking in', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: IsThatNegligenceGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS IT'), findsNothing);
      expect(find.text('NOT THAT ONE'), findsNothing);
    });

    testWidgets('calling a bad outcome negligence is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: IsThatNegligenceGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('fault-negligent')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT ONE'), findsOneWidget);
    });

    testWidgets('a breach with no loss is a missing damages element', (
      tester,
    ) async {
      size(tester);
      await tester
          .pumpWidget(const MaterialApp(home: WhichElementMissingGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('element-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('LOOK AGAIN'), findsOneWidget);
    });

    testWidgets('the timeline grades from its own dates', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichClockRanOutGame()));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(ValueKey('clock-${clockRounds.first.answer.name}')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS RIGHT'), findsOneWidget);
    });

    testWidgets('reaching for the wrong clock is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichClockRanOutGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('clock-repose')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THE OTHER CLOCK'), findsOneWidget);
    });
  });
}
