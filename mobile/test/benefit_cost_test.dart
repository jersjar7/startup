import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/roll_it_back_game.dart';
import 'package:mobile/features/games/tree_figures.dart';
import 'package:mobile/features/games/where_does_it_go_game.dart';
import 'package:mobile/features/games/which_one_do_you_build_game.dart';

/// Chapter four, lesson four. Two of these three items carry arithmetic that
/// the student never has to do, which means the rounds have to be right on
/// their own. So the test does the arithmetic: every individual and
/// incremental benefit-cost ratio is recomputed from the round's own cost and
/// benefit figures, and every expected value is recomputed from the tree's own
/// probabilities and endings. A round whose answer disagrees with its numbers
/// is the whole defect available here.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in [
      'where-does-it-go',
      'which-one-do-you-build',
      'roll-it-back',
    ]) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('where does it go', () {
    test('every slot is the answer, and costs more than once', () {
      for (final s in Slot.values) {
        expect(slotRounds.where((r) => r.answer == s).length,
            greaterThanOrEqualTo(1),
            reason: '$s never comes up');
      }
      expect(slotRounds.where((r) => r.answer == Slot.cost).length, 2,
          reason: 'the operating cost belongs underneath and one round of it '
              'is not enough, because leaving it out is the named trap');
    });

    test('the two disbenefit rounds are harm rather than spending', () {
      // The distinction the whole item rests on. A disbenefit is something
      // that happens TO the public, so it cannot be described as the agency
      // paying for something.
      for (final r in slotRounds.where((r) => r.answer == Slot.disbenefit)) {
        final text = r.item.toLowerCase();
        expect(text.contains('paid by the agency'), isFalse, reason: r.subject);
      }
      expect(slotRounds.where((r) => r.answer == Slot.disbenefit).length, 2,
          reason: 'misfiling a disbenefit into the denominator is the other '
              'named trap and needs more than one round');
    });

    test('no item names its own slot', () {
      const giveaways = ['benefit', 'disbenefit', 'numerator', 'denominator'];
      for (final r in slotRounds) {
        final text = r.item.toLowerCase();
        for (final word in giveaways) {
          expect(text.contains(word), isFalse,
              reason: '${r.subject} says "$word"');
        }
      }
    });

    test('the slot never repeats three times running', () {
      for (var i = 2; i < slotRounds.length; i++) {
        final same = slotRounds[i].answer == slotRounds[i - 1].answer &&
            slotRounds[i].answer == slotRounds[i - 2].answer;
        expect(same, isFalse, reason: 'rounds ${i - 1} to ${i + 1} are a rut');
      }
    });

    test('both of the lesson problems are drawn on', () {
      expect(slotRounds.map((r) => r.source).toSet().length,
          greaterThanOrEqualTo(2));
    });
  });

  group('which one do you build', () {
    /// The analysis the lesson describes, done here from scratch rather than
    /// borrowed from the item: throw out anything under one, then step up
    /// while each step pays for itself.
    int worked(BuildRound r) {
      var best = -1;
      for (var i = 0; i < r.options.length; i++) {
        if (r.options[i].benefit / r.options[i].cost < 1) continue;
        if (best < 0) {
          best = i;
          continue;
        }
        final dB = r.options[i].benefit - r.options[best].benefit;
        final dC = r.options[i].cost - r.options[best].cost;
        if (dC > 0 && dB / dC >= 1) best = i;
      }
      return best;
    }

    test('the answer is what incremental analysis actually gives', () {
      for (final r in buildRounds) {
        expect(r.answer, worked(r), reason: r.subject);
        expect(r.answer, greaterThanOrEqualTo(0),
            reason: '${r.subject}: nothing survives, so there is no answer');
      }
    });

    test('the options are in order of cost, which the analysis needs', () {
      for (final r in buildRounds) {
        for (var i = 1; i < r.options.length; i++) {
          expect(r.options[i].cost, greaterThan(r.options[i - 1].cost),
              reason: '${r.subject}: option ${i + 1} is not dearer than the '
                  'one before it');
        }
      }
    });

    test('the highest individual ratio is usually the wrong answer', () {
      // The entire point of the item. If picking the best-looking ratio got
      // you through most rounds, the trap would never bite.
      var tempted = 0;
      for (final r in buildRounds) {
        var top = 0;
        for (var i = 1; i < r.options.length; i++) {
          if (r.options[i].ratio > r.options[top].ratio) top = i;
        }
        if (top == r.answer) tempted++;
      }
      expect(tempted, lessThanOrEqualTo(1),
          reason: 'the highest individual ratio wins $tempted rounds out of '
              '${buildRounds.length}, so the wrong method mostly works');
    });

    test('one round throws an option out before the stepping starts', () {
      final anyBelowOne = buildRounds.where(
        (r) => r.options.any((o) => o.ratio < 1),
      );
      expect(anyBelowOne, isNotEmpty,
          reason: 'checking each option on its own first is half the method '
              'and never comes up');
    });

    test('one round stops at the cheapest and one goes all the way', () {
      expect(buildRounds.any((r) => r.answer == 0), isTrue,
          reason: 'a step that does not pay for itself never happens');
      expect(buildRounds.any((r) => r.answer == r.options.length - 1), isTrue,
          reason: 'stepping all the way up never happens');
    });

    test('the reveal only prints comparisons the analysis made', () {
      // Consecutive pairs would show a comparison against an option that had
      // already been beaten, which is not what incremental analysis does.
      for (final r in buildRounds) {
        expect(r.steps.length, r.options.length, reason: r.subject);
        expect(r.steps.last.contains('out') || r.steps.last.contains('keep') ||
            r.steps.last.contains('stop') || r.steps.last.contains('in'),
            isTrue,
            reason: '${r.subject}: the last step says nothing');
      }
    });

    test('the answer is not always in the same place', () {
      expect(buildRounds.map((r) => r.answer).toSet().length,
          greaterThanOrEqualTo(3));
      for (var i = 1; i < buildRounds.length; i++) {
        expect(buildRounds[i].answer, isNot(buildRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous position');
      }
    });
  });

  group('roll it back', () {
    test('the probabilities at every circle add to one', () {
      for (final r in treeRounds) {
        for (final b in r.branches.where((b) => b.isChance)) {
          var total = 0.0;
          for (final e in b.ends) {
            total += e.p;
          }
          expect(total, closeTo(1, 0.0001),
              reason: '${r.subject}: ${b.name} adds to $total');
        }
      }
    });

    test('the answer is the branch with the lowest expected cost', () {
      for (final r in treeRounds) {
        var best = 0;
        for (var i = 1; i < r.branches.length; i++) {
          if (r.branches[i].expected < r.branches[best].expected) best = i;
        }
        expect(r.answer, best, reason: r.subject);
      }
    });

    test('no two branches are within a hair of each other', () {
      // A round decided by a tenth is a round decided by arithmetic, and
      // nothing here is supposed to need a calculator.
      for (final r in treeRounds) {
        final values = [for (final b in r.branches) b.expected]..sort();
        for (var i = 1; i < values.length; i++) {
          expect((values[i] - values[i - 1]).abs() / values[i],
              greaterThan(0.08),
              reason: '${r.subject}: two branches are ${values[i - 1]} and '
                  '${values[i]}, which is too close to call by eye');
        }
      }
    });

    test('an expected cost lands between its own endings', () {
      // The property every round is answered by, so it had better hold.
      for (final r in treeRounds) {
        for (final b in r.branches.where((b) => b.isChance)) {
          final (lo, hi) = b.span;
          expect(b.expected, greaterThan(lo), reason: '${r.subject}: ${b.name}');
          expect(b.expected, lessThan(hi), reason: '${r.subject}: ${b.name}');
        }
      }
    });

    test('one round needs no probabilities at all', () {
      // Every ending of the winning branch under every certain price: the
      // odds cannot change the answer and the round exists to show that.
      final free = treeRounds.where((r) {
        final win = r.branches[r.answer];
        if (!win.isChance) return false;
        final (_, hi) = win.span;
        return r.branches.every((b) => b == win || b.expected > hi);
      });
      expect(free.length, 1,
          reason: 'bracketing the answer before weighing it is the first '
              'thing to try and it needs exactly one round');
    });

    test('taking the worst ending as certain loses a round', () {
      // The lesson's second named trap. It has to actually cost somebody
      // something, or the item is not testing it.
      final punished = treeRounds.where((r) {
        var pick = 0;
        for (var i = 1; i < r.branches.length; i++) {
          final worst = r.branches[i].span.$2;
          if (worst < r.branches[pick].span.$2) pick = i;
        }
        return pick != r.answer;
      });
      expect(punished.length, greaterThanOrEqualTo(2),
          reason: 'treating the worst case as certain gets through all but '
              '${punished.length} rounds');
    });

    test('counting only the cheapest ending loses a round', () {
      // And the first named trap: reading the branch as the money spent today.
      final punished = treeRounds.where((r) {
        var pick = 0;
        for (var i = 1; i < r.branches.length; i++) {
          if (r.branches[i].span.$1 < r.branches[pick].span.$1) pick = i;
        }
        return pick != r.answer;
      });
      expect(punished.length, greaterThanOrEqualTo(2),
          reason: 'reading the price today as the price of the branch gets '
              'through too much of this');
    });

    test('one round hides a probability, and it is the one that decides', () {
      final hidden = treeRounds.where(
        (r) => r.branches.any((b) => b.ends.any((e) => e.note != null)),
      );
      expect(hidden.length, 1,
          reason: 'the lesson warns that an unlabeled branch still carries '
              'whatever is left over, and it needs exactly one round');
      final r = hidden.first;
      final b = r.branches.firstWhere((b) => b.isChance);
      final loose = b.ends.firstWhere((e) => e.note != null);
      final withoutIt = () {
        var total = 0.0;
        var mass = 0.0;
        for (final e in b.ends) {
          if (e.note != null) continue;
          total += e.p * e.cost;
          mass += e.p;
        }
        return total / mass;
      }();
      expect(withoutIt, lessThan(r.branches[r.answer].expected),
          reason: 'skipping the loose branch has to CHANGE the decision, or '
              'the round does not teach the warning');
      expect(loose.cost, greaterThan(b.expected),
          reason: 'the loose branch has to be the expensive one to matter');
    });

    test('the answer moves around', () {
      expect(treeRounds.map((r) => r.answer).toSet().length,
          greaterThanOrEqualTo(3));
      for (var i = 1; i < treeRounds.length; i++) {
        expect(treeRounds[i].answer, isNot(treeRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous branch position');
      }
    });

    test('every round explains itself', () {
      for (final r in treeRounds) {
        expect(r.why.length, greaterThan(110), reason: r.subject);
        expect(r.situation.length, greaterThan(110), reason: r.subject);
        expect(r.rollback.length, r.branches.length, reason: r.subject);
      }
    });

    test('the drawn tree is tall enough for what is on it', () {
      for (final r in treeRounds) {
        for (final b in r.branches) {
          if (!b.isChance) continue;
          // Twenty-six points per ending plus room for the branch name.
          expect(TreePainter.rowHeight(b),
              greaterThanOrEqualTo(26.0 * b.ends.length + 26),
              reason: '${r.subject}: ${b.name} would draw over itself');
        }
      }
    });
  });

  group('the boards run', () {
    testWidgets('a slot has to be chosen before locking in', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhereDoesItGoGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS WHERE'), findsNothing);
      expect(find.text('SOMEWHERE ELSE'), findsNothing);
    });

    testWidgets('the construction cost goes underneath', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhereDoesItGoGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('slot-cost')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS WHERE'), findsOneWidget);
    });

    testWidgets('picking the best individual ratio is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichOneDoYouBuildGame()));
      await tester.pumpAndSettle();

      // Round one is the lesson's own drainage problem, where the cheapest
      // option has the highest ratio and is not the answer.
      await tester.tap(find.byKey(const ValueKey('build-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT ONE'), findsOneWidget);
    });

    testWidgets('the branch itself is what gets tapped', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: RollItBackGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT BRANCH'), findsNothing);

      await tester.tap(find.byKey(ValueKey('branch-${treeRounds.first.answer}')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT BRANCH'), findsOneWidget);
    });

    testWidgets('taking the certain price on round one is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: RollItBackGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('branch-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('ANOTHER BRANCH'), findsOneWidget);
    });
  });
}
