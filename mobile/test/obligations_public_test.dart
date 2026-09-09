import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/enough_or_too_far_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/in_what_order_game.dart';
import 'package:mobile/features/games/what_it_triggers_game.dart';

/// Chapter three, lesson one. Nothing in this chapter has a number in it, so
/// there is no arithmetic to recompute. What CAN be checked mechanically is
/// everything that would make a scenario item unfair: an answer the wording
/// gives away, a board that can be cleared by position rather than judgment,
/// and a verdict that never appears.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['what-it-triggers', 'in-what-order', 'enough-or-too-far']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('what does it trigger', () {
    test('every answer points at a duty that exists', () {
      for (final r in triggerRounds) {
        expect(r.answer, inInclusiveRange(0, duties.length - 1),
            reason: r.subject);
        expect(r.rule.trim(), isNotEmpty, reason: r.subject);
      }
    });

    test('every duty on the list is the answer somewhere', () {
      final used = triggerRounds.map((r) => r.answer).toSet();
      expect(used.length, duties.length,
          reason: 'a duty nobody ever needs is a row of dead text on a phone');
    });

    test('the scenario never hands over the answer', () {
      // A scenario that already names the action is a matching exercise. The
      // words below are the ones that decide a round, so none of them may
      // appear before the student has decided anything.
      const giveaways = ['refuse', 'recuse', 'disclose', 'whistle', 'board'];
      for (final r in triggerRounds) {
        final scenario = r.scenario.toLowerCase();
        expect(scenario.contains(duties[r.answer].$1.toLowerCase()), isFalse,
            reason: '${r.subject} states its own answer');
        for (final word in giveaways) {
          expect(scenario.contains(word), isFalse,
              reason: '${r.subject} says "$word" before anybody has judged '
                  'anything');
        }
      }
    });

    test('exactly one round sets nothing off, and nobody is in danger in it',
        () {
      final quiet =
          triggerRounds.where((r) => r.answer == duties.length - 1).toList();
      expect(quiet.length, 1,
          reason: 'the trap works because it is rare, not because it is common');
      final words = quiet.single.scenario.toLowerCase();
      for (final loaded in ['unsafe', 'danger', 'endanger', 'code']) {
        expect(words.contains(loaded), isFalse,
            reason: 'the quiet round says "$loaded", so it is not quiet');
      }
    });

    test('the same situation appears at two stages with two answers', () {
      // The escalation ladder is the lesson's real content, and the fastest
      // way to teach it is one story told twice.
      final school =
          triggerRounds.where((r) => r.scenario.contains('bearing capacity'));
      expect(school.length, 2, reason: 'the paired rounds are gone');
      expect(school.first.answer, isNot(school.last.answer),
          reason: 'the pair only teaches anything if the answers differ');
    });

    test('all three problems in the lesson are drawn on', () {
      expect(triggerRounds.map((r) => r.source).toSet().length, 3);
    });
  });

  group('in what order', () {
    test('three of the four are taken, and they are distinct', () {
      for (final r in ladderRounds) {
        expect(r.actions.length, 4, reason: r.subject);
        expect(r.order.length, 3, reason: r.subject);
        expect(r.order.toSet().length, 3, reason: r.subject);
        for (final i in r.order) {
          expect(i, inInclusiveRange(0, 3), reason: r.subject);
        }
        expect(r.actions.toSet().length, 4,
            reason: '${r.subject}: an action is offered twice');
      }
    });

    test('the correct order is never just the order on the board', () {
      // Otherwise the board can be cleared top to bottom without reading it.
      for (final r in ladderRounds) {
        final ascending = [...r.order]..sort();
        expect(r.order, isNot(ascending), reason: r.subject);
      }
    });

    test('the action nobody takes is not always in the same place', () {
      final nevers = [
        for (final r in ladderRounds)
          [0, 1, 2, 3].firstWhere((i) => !r.order.contains(i)),
      ];
      expect(nevers.toSet().length, greaterThanOrEqualTo(3),
          reason: 'the one to leave alone sits at ${nevers.toSet()}, which is '
              'few enough places to guess');
      for (final place in [0, 1, 2, 3]) {
        expect(nevers.where((n) => n == place).length, lessThanOrEqualTo(2),
            reason: 'position $place holds the never-action too often');
      }
    });

    test('every round says why the fourth is never taken', () {
      for (final r in ladderRounds) {
        expect(r.never.trim(), isNotEmpty, reason: r.subject);
        expect(r.never.length, greaterThan(40),
            reason: '${r.subject}: the reason is too short to be a reason');
      }
    });

    test('one round inverts the ladder for imminent danger', () {
      final urgent = ladderRounds.firstWhere(
        (r) => r.why.contains('Imminent danger'),
      );
      final first = urgent.actions[urgent.order.first].toLowerCase();
      expect(first.contains('stop'), isTrue,
          reason: 'the exception only lands if stopping the work comes first');
    });

    test('more than one problem is drawn on', () {
      expect(ladderRounds.map((r) => r.source).toSet().length,
          greaterThanOrEqualTo(3));
    });
  });

  group('enough, or too far', () {
    test('all three verdicts happen, and none is rare', () {
      for (final size in Size3.values) {
        expect(proportionRounds.where((r) => r.answer == size).length,
            greaterThanOrEqualTo(2),
            reason: '$size is barely used');
      }
    });

    test('the answer is never in the same place twice running', () {
      for (var i = 1; i < proportionRounds.length; i++) {
        expect(proportionRounds[i].answer,
            isNot(proportionRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous verdict');
      }
    });

    test('one scenario is judged three ways', () {
      // Same facts, three responses, three verdicts. That is the whole item.
      final byScenario = <String, List<Size3>>{};
      for (final r in proportionRounds) {
        byScenario.putIfAbsent(r.scenario, () => []).add(r.answer);
      }
      final triples =
          byScenario.values.where((v) => v.toSet().length == 3 && v.length == 3);
      expect(triples, isNotEmpty,
          reason: 'no scenario is judged all three ways, so nothing shows that '
              'the facts were never the difficulty');
    });

    test('no response is offered twice', () {
      final responses = proportionRounds.map((r) => r.response).toList();
      expect(responses.toSet().length, responses.length);
    });

    test('every round says which way it missed', () {
      for (final r in proportionRounds) {
        expect(r.why.trim(), isNotEmpty, reason: r.subject);
        expect(r.response.trim(), isNotEmpty, reason: r.subject);
      }
    });

    test('all three problems in the lesson are drawn on', () {
      expect(proportionRounds.map((r) => r.source).toSet().length, 3);
    });
  });

  group('the boards run', () {
    testWidgets('an obligation has to be chosen before locking in', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhatItTriggersGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE ONE'), findsNothing);
      expect(find.text('A DIFFERENT RULE'), findsNothing);
    });

    testWidgets('reaching for the whistle on round one is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhatItTriggersGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('duty-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('A DIFFERENT RULE'), findsOneWidget);
    });

    testWidgets('two steps are not enough to lock in', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: InWhatOrderGame()));
      await tester.pumpAndSettle();

      final r = ladderRounds.first;
      await tester.tap(find.byKey(ValueKey('step-${r.order[0]}')));
      await tester.tap(find.byKey(ValueKey('step-${r.order[1]}')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('IN THAT ORDER'), findsNothing);
      expect(find.text('NOT THAT ORDER'), findsNothing);
    });

    testWidgets('the right three in the wrong order are rejected', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: InWhatOrderGame()));
      await tester.pumpAndSettle();

      final r = ladderRounds.first;
      for (final i in [r.order[2], r.order[1], r.order[0]]) {
        await tester.tap(find.byKey(ValueKey('step-$i')));
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT ORDER'), findsOneWidget);
    });

    testWidgets('taking the action nobody takes is rejected', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: InWhatOrderGame()));
      await tester.pumpAndSettle();

      final r = ladderRounds.first;
      final never = [0, 1, 2, 3].firstWhere((i) => !r.order.contains(i));
      for (final i in [r.order[0], r.order[1], never]) {
        await tester.tap(find.byKey(ValueKey('step-$i')));
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT ORDER'), findsOneWidget);
      expect(find.text('THE ONE NOBODY TAKES'), findsOneWidget);
    });

    testWidgets('the right three in the right order are accepted', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: InWhatOrderGame()));
      await tester.pumpAndSettle();

      for (final i in ladderRounds.first.order) {
        await tester.tap(find.byKey(ValueKey('step-$i')));
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('IN THAT ORDER'), findsOneWidget);
    });

    testWidgets('meaning well is not enough on the committee round', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: EnoughOrTooFarGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('size-right')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT SIZE'), findsOneWidget);
    });
  });
}
