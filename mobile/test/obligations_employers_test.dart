import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/can_you_claim_that_game.dart';
import 'package:mobile/features/games/can_you_seal_it_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/who_has_to_agree_game.dart';

/// Chapter three, lesson two. Nothing here has a number in it either, so the
/// checks are about fairness and coverage: a board that can be cleared by
/// counting, an answer the wording gives away, a rule that never comes up.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in [
      'can-you-seal-it',
      'who-has-to-agree',
      'can-you-claim-that',
    ]) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('can you seal it', () {
    test('all three answers happen, and none is rare', () {
      for (final seal in Seal.values) {
        expect(sealRounds.where((r) => r.answer == seal).length,
            greaterThanOrEqualTo(1),
            reason: '$seal never comes up');
      }
      expect(sealRounds.where((r) => r.answer == Seal.no).length,
          greaterThanOrEqualTo(2),
          reason: 'refusing is the common answer and should look like it');
    });

    test('the coordination answer really is a coordination case', () {
      // "Seal your part" is only right when somebody else has sealed theirs.
      // Without that, it is a hedge dressed as an answer.
      for (final r in sealRounds.where((r) => r.answer == Seal.myPart)) {
        expect(r.situation.toLowerCase().contains('sealed'), isTrue,
            reason: '${r.subject}: nobody else has sealed anything');
        expect(r.rule, 'B.3', reason: r.subject);
      }
    });

    test('every yes has both halves and every no is missing one', () {
      for (final r in sealRounds) {
        if (r.answer == Seal.yes) {
          expect(r.rule, isNot('B.1'),
              reason: '${r.subject}: a competence rule cannot license a seal');
        }
        expect(r.rule.startsWith('B.'), isTrue, reason: r.subject);
        expect(r.why.trim(), isNotEmpty, reason: r.subject);
      }
    });

    test('both halves of the seal test are each the reason somewhere', () {
      final rules = sealRounds.map((r) => r.rule).toSet();
      expect(rules, containsAll(['B.1', 'B.2', 'B.3']),
          reason: 'competence, responsible charge and coordination all have to '
              'be the deciding rule at least once');
    });

    test('the situation never states its own answer', () {
      const giveaways = ['responsible charge', 'not qualified', 'decline'];
      for (final r in sealRounds) {
        final text = r.situation.toLowerCase();
        for (final word in giveaways) {
          expect(text.contains(word), isFalse,
              reason: '${r.subject} says "$word"');
        }
      }
    });
  });

  group('who has to agree', () {
    test('the last party on every board is the one that ends it', () {
      for (final r in consentRounds) {
        expect(r.parties.last, noConsent, reason: r.subject);
        expect(r.parties.length, 4, reason: r.subject);
        expect(r.parties.toSet().length, 4,
            reason: '${r.subject}: a party is listed twice');
      }
    });

    test('nobody consents alongside nobody', () {
      // Picking "no consent makes this acceptable" and a consenting party at
      // the same time is incoherent, so no answer may contain both.
      for (final r in consentRounds) {
        final last = r.parties.length - 1;
        if (r.answer.contains(last)) {
          expect(r.answer, [last], reason: r.subject);
        }
      }
    });

    test('the answer is not always the same size', () {
      final sizes = consentRounds.map((r) => r.answer.length).toSet();
      expect(sizes.length, greaterThan(1),
          reason: 'if every answer is the same size the board can be cleared '
              'by counting rather than by reading');
      expect(sizes, containsAll([1, 2]));
    });

    test('some rounds cannot be fixed by consent, and some can', () {
      final last = consentRounds.first.parties.length - 1;
      final unfixable =
          consentRounds.where((r) => r.answer.contains(last)).length;
      expect(unfixable, greaterThanOrEqualTo(2),
          reason: 'a gratuity and a public-body conflict both need showing');
      expect(consentRounds.length - unfixable, greaterThanOrEqualTo(3),
          reason: 'and disclosure has to be the answer more often than not');
    });

    test('every party index is inside its own list', () {
      for (final r in consentRounds) {
        for (final i in r.answer) {
          expect(i, inInclusiveRange(0, r.parties.length - 1),
              reason: r.subject);
        }
        expect(r.answer.toSet().length, r.answer.length, reason: r.subject);
        expect(r.answer, isNotEmpty, reason: r.subject);
      }
    });

    test('each round names the rule it turns on', () {
      for (final r in consentRounds) {
        expect(r.rule.contains('B.'), isTrue, reason: r.subject);
      }
      final rules = consentRounds.map((r) => r.rule).join(' ');
      for (final rule in ['B.4', 'B.5', 'B.7', 'B.8']) {
        expect(rules.contains(rule), isTrue, reason: '$rule never comes up');
      }
    });
  });

  group('can you claim that', () {
    test('every round offers three lines and one of them is allowed', () {
      for (final r in claimRounds) {
        expect(r.claims.length, 3, reason: r.subject);
        expect(r.claims.toSet().length, 3,
            reason: '${r.subject}: a line is offered twice');
        expect(r.answer, inInclusiveRange(0, 2), reason: r.subject);
      }
    });

    test('the allowed line is not always in the same place', () {
      expect(claimRounds.map((r) => r.answer).toSet(), {0, 1, 2});
      for (var i = 1; i < claimRounds.length; i++) {
        expect(claimRounds[i].answer, isNot(claimRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous position');
      }
    });

    test('the honest line is not simply the longest one', () {
      // If the right answer is always the wordiest, the board can be cleared
      // without reading a word of it.
      final longest = claimRounds
          .where((r) =>
              r.claims[r.answer].length ==
              r.claims.map((c) => c.length).reduce((a, b) => a > b ? a : b))
          .length;
      expect(longest, lessThanOrEqualTo(claimRounds.length ~/ 2),
          reason: 'the allowed line is the longest in $longest of '
              '${claimRounds.length} rounds, which is a rule somebody will '
              'find before they find the ethics');
    });

    test('every round says what actually happened before it asks', () {
      for (final r in claimRounds) {
        expect(r.facts.trim(), isNotEmpty, reason: r.subject);
        expect(r.facts.length, greaterThan(60),
            reason: '${r.subject}: the facts are too thin to judge a claim on');
        expect(r.rule, 'C.1', reason: r.subject);
      }
    });
  });

  group('the boards run', () {
    testWidgets('a seal decision cannot be skipped', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: CanYouSealItGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS RIGHT'), findsNothing);
      expect(find.text('NOT QUITE'), findsNothing);
    });

    testWidgets('taking the roundabout on adjacent experience is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: CanYouSealItGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('seal-yes')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT QUITE'), findsOneWidget);
    });

    testWidgets('nothing submits until a party is chosen', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhoHasToAgreeGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS EVERYONE'), findsNothing);
      expect(find.text('NOT THAT SET'), findsNothing);
    });

    testWidgets('one of the two cities is not enough', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhoHasToAgreeGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('party-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT SET'), findsOneWidget);
    });

    testWidgets('picking nobody clears the parties already picked', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhoHasToAgreeGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('party-0')));
      await tester.tap(find.byKey(const ValueKey('party-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('party-3')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      // Round one is fixable by consent, so "nobody" alone is the wrong set,
      // and it has to be alone rather than sitting beside the two cities.
      expect(find.text('NOT THAT SET'), findsOneWidget);
    });

    testWidgets('both cities together are accepted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhoHasToAgreeGame()));
      await tester.pumpAndSettle();

      for (final i in consentRounds.first.answer) {
        await tester.tap(find.byKey(ValueKey('party-$i')));
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS EVERYONE'), findsOneWidget);
    });

    testWidgets('claiming the bridge design is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: CanYouClaimThatGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('claim-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT ONE'), findsOneWidget);
    });
  });
}
