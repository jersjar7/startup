import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/how_many_protections_game.dart';
import 'package:mobile/features/games/lifecycle_figures.dart';
import 'package:mobile/features/games/over_the_whole_life_game.dart';
import 'package:mobile/features/games/which_protection_game.dart';

/// Chapter three, lesson seven, and the last of the chapter. The life-cycle
/// rounds are numbers and the test adds them up; the rest is coverage and
/// fairness, which is what this chapter has needed throughout.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in [
      'which-protection',
      'how-many-protections',
      'over-the-whole-life',
    ]) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('which protection', () {
    test('every protection on the board is the answer exactly once', () {
      final answers = protectionRounds.map((r) => r.answer).toList();
      expect(answers.toSet().length, answers.length,
          reason: 'a protection is the answer twice while another never is');
      expect(answers.toSet().length, protections.length,
          reason: 'the six are the whole taxonomy and all of them should '
              'come up');
    });

    test('no asset names the protection it needs', () {
      const giveaways = ['patent', 'trademark', 'copyright', 'trade secret'];
      for (final r in protectionRounds) {
        final text = r.asset.toLowerCase();
        for (final word in giveaways) {
          expect(text.contains(word), isFalse,
              reason: '${r.subject} says "$word"');
        }
      }
    });

    test('the trade secret round turns on not disclosing', () {
      final secret = protectionRounds.firstWhere(
        (r) => protections[r.answer].$1 == 'Trade secret',
      );
      final text = secret.asset.toLowerCase();
      expect(
        text.contains('no intention of telling') || text.contains('never'),
        isTrue,
        reason: 'without an unwillingness to disclose, a patent would do just '
            'as well and the round has two answers',
      );
    });

    test('the patent round says the firm will publish', () {
      final patent = protectionRounds.firstWhere(
        (r) => protections[r.answer].$1 == 'Utility patent',
      );
      expect(patent.asset.toLowerCase().contains('publish'), isTrue,
          reason: 'the patent bargain is disclosure, and a round that does not '
              'mention it is asking the student to guess which way the firm '
              'would jump');
    });

    test('every round explains itself at length', () {
      for (final r in protectionRounds) {
        expect(r.why.length, greaterThan(90), reason: r.subject);
        expect(r.asset.length, greaterThan(80), reason: r.subject);
      }
    });
  });

  group('how many protections', () {
    test('the answers are not all the same size', () {
      final sizes = countRounds.map((r) => r.answer.length).toSet();
      expect(sizes.length, greaterThanOrEqualTo(3),
          reason: 'if the count barely varies the board can be cleared by '
              'counting rather than by reading');
      expect(sizes, contains(4), reason: 'the four-protection project is the '
          'lesson\'s own problem and has to be in the set');
      expect(sizes, contains(1));
    });

    test('every index is inside the list, and none is repeated', () {
      for (final r in countRounds) {
        expect(r.answer, isNotEmpty, reason: r.subject);
        expect(r.answer.toSet().length, r.answer.length, reason: r.subject);
        for (final i in r.answer) {
          expect(i, inInclusiveRange(0, kinds.length - 1), reason: r.subject);
        }
      }
    });

    test('a patent and a trade secret never cover the same project alone', () {
      // They can coexist on different assets, which one round shows. What
      // cannot happen is a round where they are the only two and the scene
      // has just one thing in it.
      for (final r in countRounds) {
        if (r.answer.length == 2 && r.answer.contains(0) && r.answer.contains(3)) {
          expect(r.project.toLowerCase().contains('coating'), isTrue,
              reason: '${r.subject}: a patent and a secret together need two '
                  'separate assets in the scene');
        }
      }
    });

    test('every protection is needed somewhere', () {
      final used = <int>{for (final r in countRounds) ...r.answer};
      expect(used.length, kinds.length,
          reason: 'a protection nobody ever needs is a dead row');
    });
  });

  group('over the whole life', () {
    test('the winner is the shorter bar, worked out from the bar', () {
      for (final r in lifeRounds) {
        final totals = r.options.map((o) => o.total).toList();
        final shortest = totals[0] <= totals[1] ? 0 : 1;
        expect(r.answer, shortest, reason: r.subject);
        expect(totals[0], isNot(totals[1]),
            reason: '${r.subject}: the two totals are equal, so there is no '
                'answer to give');
      }
    });

    test('every option has all four stages, and none is empty', () {
      for (final r in lifeRounds) {
        expect(r.options.length, 2, reason: r.subject);
        for (final o in r.options) {
          expect(o.stages.length, stageNames.length, reason: r.subject);
          for (final s in o.stages) {
            expect(s, greaterThan(0),
                reason: '${r.subject}: a stage that costs nothing is not a '
                    'stage of a life');
          }
        }
      }
    });

    test('most rounds punish reading only the first block', () {
      // The whole item. If the cheapest to build is also the winner every
      // time, the picture is decoration.
      final trap = lifeRounds
          .where((r) => r.cheapestToBuild != r.answer)
          .length;
      expect(trap, greaterThanOrEqualTo(4),
          reason: 'only $trap of ${lifeRounds.length} rounds punish reading '
              'the first segment on its own');
    });

    test('one round has the cheapest to build win outright', () {
      final honest = lifeRounds
          .where((r) => r.cheapestToBuild == r.answer)
          .length;
      expect(honest, greaterThanOrEqualTo(1),
          reason: 'a set where the expensive option always wins trains '
              'somebody to pick the expensive option');
    });

    test('the deciding stage is not always the same one', () {
      // Maintenance, operation and disposal each decide at least one round,
      // or the item is one idea repeated six times.
      final deciders = <int>{};
      for (final r in lifeRounds) {
        final a = r.options[0].stages;
        final b = r.options[1].stages;
        var widest = 0;
        var at = 0;
        for (var s = 0; s < a.length; s++) {
          final gap = (a[s] - b[s]).abs();
          if (gap > widest) {
            widest = gap;
            at = s;
          }
        }
        deciders.add(at);
      }
      expect(deciders.length, greaterThanOrEqualTo(3),
          reason: 'only ${deciders.length} of the four stages ever decide a '
              'round');
    });
  });

  group('the boards run', () {
    testWidgets('a protection has to be chosen before locking in', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichProtectionGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE ONE'), findsNothing);
      expect(find.text('A DIFFERENT ONE'), findsNothing);
    });

    testWidgets('patenting the algorithm they will not disclose is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichProtectionGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('protection-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('A DIFFERENT ONE'), findsOneWidget);
    });

    testWidgets('naming only the patent on the four-asset project is caught', (
      tester,
    ) async {
      size(tester);
      await tester
          .pumpWidget(const MaterialApp(home: HowManyProtectionsGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('kind-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT SET'), findsOneWidget);
    });

    testWidgets('all four together are accepted', (tester) async {
      size(tester);
      await tester
          .pumpWidget(const MaterialApp(home: HowManyProtectionsGame()));
      await tester.pumpAndSettle();

      for (final i in countRounds.first.answer) {
        await tester.tap(find.byKey(ValueKey('kind-$i')));
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS ALL OF THEM'), findsOneWidget);
    });

    testWidgets('choosing the cheapest to build is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: OverTheWholeLifeGame()));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(ValueKey('option-${lifeRounds.first.cheapestToBuild}')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('ADD IT AGAIN'), findsOneWidget);
    });
  });
}
