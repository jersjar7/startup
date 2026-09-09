import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/does_it_hold_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/practice_or_title_game.dart';
import 'package:mobile/features/games/who_may_do_that_game.dart';

/// Chapter three, lesson three. Three boards that all present the same shape,
/// a scenario and three tiers, which is exactly the shape a student can learn
/// to game. So the checks are about whether the tiers are really earning
/// their place: every one of them used, never twice running, and never
/// deducible from the wording.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['who-may-do-that', 'does-it-hold', 'practice-or-title']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('who may do that', () {
    test('every tier is the answer at least twice', () {
      for (final s in Standing.values) {
        expect(standingRounds.where((r) => r.answer == s).length,
            greaterThanOrEqualTo(2),
            reason: '$s is barely used');
      }
    });

    test('the tier never repeats round to round', () {
      for (var i = 1; i < standingRounds.length; i++) {
        expect(standingRounds[i].answer, isNot(standingRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous tier');
      }
    });

    test('the action never states its own conclusion', () {
      // Naming a licensed engineer who is directing the work is context and
      // has to be allowed; what may not appear is wording that answers the
      // question, which is what these phrases do.
      const giveaways = [
        'only a',
        'requires a licence',
        'requires a license',
        'no licence',
        'no license',
        'unlicensed',
        'not licensed',
      ];
      for (final r in standingRounds) {
        final text = r.action.toLowerCase();
        for (final phrase in giveaways) {
          expect(text.contains(phrase), isFalse,
              reason: '${r.subject} says "$phrase" in the action itself');
        }
      }
    });

    test('every round cites a rule and explains itself', () {
      for (final r in standingRounds) {
        expect(r.rule.contains('Model Law'), isTrue, reason: r.subject);
        expect(r.why.length, greaterThan(80), reason: r.subject);
      }
    });

    test('both problems that define the boundary are drawn on', () {
      expect(standingRounds.map((r) => r.source).toSet().length,
          greaterThanOrEqualTo(2));
    });
  });

  group('does the exemption hold', () {
    test('every outcome is the answer twice', () {
      for (final e in Exemption.values) {
        expect(exemptionRounds.where((r) => r.answer == e).length, 2,
            reason: '$e appears the wrong number of times');
      }
    });

    test('the outcome never repeats round to round', () {
      for (var i = 1; i < exemptionRounds.length; i++) {
        expect(exemptionRounds[i].answer, isNot(exemptionRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous outcome');
      }
    });

    test('a holding round names somebody licensed who is directing it', () {
      for (final r in exemptionRounds.where((r) => r.answer == Exemption.holds)) {
        final text = r.scene.toLowerCase();
        expect(text.contains('engineer'), isTrue,
            reason: '${r.subject}: nobody licensed is anywhere in the scene');
      }
    });

    test('a no-charge round really has nobody in charge', () {
      for (final r
          in exemptionRounds.where((r) => r.answer == Exemption.noCharge)) {
        final text = r.scene.toLowerCase();
        expect(
          text.contains('no licensed') ||
              text.contains('nobody in that office is licensed') ||
              text.contains('nobody is directing'),
          isTrue,
          reason: '${r.subject}: the scene never says the charge is missing',
        );
      }
    });

    test('every scene is long enough to be judged', () {
      for (final r in exemptionRounds) {
        expect(r.scene.length, greaterThan(120), reason: r.subject);
        expect(r.why.trim(), isNotEmpty, reason: r.subject);
      }
    });
  });

  group('practice, or the title', () {
    test('every verdict is the answer twice', () {
      for (final v in Verdict.values) {
        expect(verdictCases.where((r) => r.answer == v).length, 2,
            reason: '$v appears the wrong number of times');
      }
    });

    test('the verdict never repeats round to round', () {
      for (var i = 1; i < verdictCases.length; i++) {
        expect(verdictCases[i].answer, isNot(verdictCases[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous verdict');
      }
    });

    test('a title round claims the title and a practice round does not', () {
      for (final r in verdictCases) {
        final claimsTitle = r.scene.contains('Professional Engineer') ||
            r.scene.contains('PE after it');
        if (r.answer == Verdict.title) {
          expect(claimsTitle, isTrue,
              reason: '${r.subject}: nobody claims the title in it');
        }
        if (r.answer == Verdict.practice) {
          expect(claimsTitle, isFalse,
              reason: '${r.subject}: a title claim muddies a work-only round');
        }
      }
    });

    test('one practice round is delivered through software', () {
      // The lesson's whole point about the medium. Without it the item is a
      // generic unlicensed-practice drill.
      final software = verdictCases.any((r) =>
          r.answer == Verdict.practice &&
          (r.scene.contains('app') || r.scene.contains('software')));
      expect(software, isTrue,
          reason: 'nothing here tests that the medium is not part of the test');
    });

    test('one clean round is software that decides nothing', () {
      final clean = verdictCases.any((r) =>
          r.answer == Verdict.neither &&
          (r.scene.contains('spreadsheet') || r.scene.contains('software')));
      expect(clean, isTrue,
          reason: 'without it, the lesson reads as "software is always '
              'practice", which is the opposite mistake');
    });

    test('every case cites a rule', () {
      for (final r in verdictCases) {
        expect(r.rule.contains('110.20'), isTrue, reason: r.subject);
        expect(r.why.length, greaterThan(80), reason: r.subject);
      }
    });
  });

  group('the boards run', () {
    testWidgets('a tier has to be chosen before locking in', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhoMayDoThatGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE TIER'), findsNothing);
      expect(find.text('A DIFFERENT TIER'), findsNothing);
    });

    testWidgets('letting an intern seal the drainage plans is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhoMayDoThatGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('standing-intern')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('A DIFFERENT TIER'), findsOneWidget);
    });

    testWidgets('the shop drawing comparison is accepted as exempt', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: DoesItHoldGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('exemption-holds')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS IT'), findsOneWidget);
    });

    testWidgets('calling the comparison unlicensed practice is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: DoesItHoldGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('exemption-finalCall')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THE OTHER CONDITION'), findsOneWidget);
    });

    testWidgets('excusing the deck app as a tool is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: PracticeOrTitleGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('verdict-neither')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT ONE'), findsOneWidget);
    });
  });
}
