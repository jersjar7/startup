import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/every_rule_game.dart';
import 'package:mobile/features/games/find_the_slip_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/point_at_the_inside_game.dart';

/// Lesson seven. Its first item is the only one in the app whose answer is a
/// SET, and its second is the only one that asks a student to find a wrong
/// line, so both get pinned harder than usual.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['every-rule', 'point-at-the-inside', 'find-the-slip']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('content', () {
    test('every rule set is defensible from the shape of the function', () {
      for (final r in ruleRounds) {
        final f = r.function;
        // A quotient is written as a fraction; a product is neither.
        if (r.rules.contains(DerivRule.quotient)) {
          expect(f.contains(r'\frac'), isTrue, reason: f);
        }
        if (r.rules.contains(DerivRule.chain)) {
          // Something other than plain x sits inside something.
          expect(
            f.contains('3x') ||
                f.contains('2x') ||
                f.contains('4x') ||
                f.contains('5x') ||
                f.contains('3x^2'),
            isTrue,
            reason: f,
          );
        }
      }
    });

    test('single-rule, multi-rule and table-only rounds all appear', () {
      expect(ruleRounds.any((r) => r.rules.isEmpty), isTrue);
      expect(ruleRounds.any((r) => r.rules.length == 1), isTrue);
      expect(ruleRounds.any((r) => r.rules.length > 1), isTrue,
          reason: 'the whole point of a set answer is that sets happen');
    });

    test('every slip points at a real line and a real reason', () {
      for (final s in slips) {
        expect(s.badLine, inInclusiveRange(0, s.lines.length - 1));
        expect(s.reason, inInclusiveRange(0, s.reasons.length - 1));
        expect(s.reasons.length, greaterThanOrEqualTo(3));
        expect(s.reasons.toSet().length, s.reasons.length);
      }
    });

    test('the slips cover the traps the lesson names', () {
      final all = slips.map((s) => s.why).join(' ').toLowerCase();
      expect(all, contains('chain'));
      expect(all, contains('lo d-hi'));
      expect(all, contains('squared'));
    });

    test('the inner function is never the whole function', () {
      for (final r in insideRounds) {
        expect(r.tokens.length, greaterThanOrEqualTo(3));
        expect(r.answer, inInclusiveRange(0, r.tokens.length - 1));
      }
    });
  });

  group('playing', () {
    testWidgets('naming only the product rule is not the full set',
        (tester) async {
      size(tester);
      // Round two needs product AND chain.
      GameProgress.instance.markRoundCleared('every-rule', 0, firstTry: true);
      await tester.pumpWidget(const MaterialApp(home: EveryRuleGame()));

      await tester.tap(find.text('Product rule'));
      await tester.pump();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();

      expect(find.text('NOT THE FULL SET'), findsOneWidget);
    });

    testWidgets('naming both rules is correct', (tester) async {
      size(tester);
      GameProgress.instance.markRoundCleared('every-rule', 0, firstTry: true);
      await tester.pumpWidget(const MaterialApp(home: EveryRuleGame()));

      await tester.tap(find.text('Product rule'));
      await tester.pump();
      await tester.tap(find.text('Chain rule'));
      await tester.pump();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();

      expect(find.text('CORRECT'), findsOneWidget);
    });

    testWidgets('a line and a reason are both required', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: FindTheSlipGame()));

      // Line only.
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('CORRECT'), findsNothing);
      expect(find.text('NOT QUITE'), findsNothing);
    });

    testWidgets('the right line with the right reason passes', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: FindTheSlipGame()));

      final s = slips.first;
      await tester.tap(find.text('${s.badLine + 1}'));
      await tester.pump();
      await tester.tap(find.text(s.reasons[s.reason]));
      await tester.pump();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();

      expect(find.text('CORRECT'), findsOneWidget);
      expect(find.text('1/6'), findsOneWidget);
    });

    testWidgets('tapping the inner function answers the first round',
        (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: PointAtTheInsideGame()));

      await tester.tap(find.byKey(const ValueKey('piece-2')));
      await tester.pump();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();

      expect(find.text('CORRECT'), findsOneWidget);
    });
  });
}
