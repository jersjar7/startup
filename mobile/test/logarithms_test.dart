import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/one_log_game.dart';
import 'package:mobile/features/games/order_the_moves_game.dart';
import 'package:mobile/features/games/rule_or_trap_game.dart';

/// Lesson two. Nothing here has a figure to lean on, so the content itself is
/// what has to be right: every claim's verdict, every step order, every
/// collapsed form.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['rule-or-trap', 'order-the-moves', 'one-log']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('content', () {
    test('the legal and illegal claims are both well represented', () {
      final legal = claims.where((c) => c.legal).length;
      expect(legal, greaterThan(2));
      expect(claims.length - legal, greaterThan(2));
      // The lesson's headline warning has to be in there.
      expect(
        claims.any((c) => !c.legal && c.latex.contains('x + y')),
        isTrue,
        reason: 'the sum-inside-a-log trap is the point of this item',
      );
    });

    test('every claim explains itself and names its source problem', () {
      for (final c in claims) {
        expect(c.why.trim(), isNotEmpty);
        expect(c.source, startsWith('math-log-'));
      }
    });

    test('every move set uses each step exactly once', () {
      for (final m in moveSets) {
        expect(m.answer.length, m.shown.length);
        expect(m.answer.toSet().length, m.answer.length,
            reason: 'a step is used twice in "${m.problem}"');
        expect(m.answer.every((i) => i >= 0 && i < m.shown.length), isTrue);
      }
    });

    test('no move set is already in order on screen', () {
      for (final m in moveSets) {
        final inOrder = List.generate(m.shown.length, (i) => i);
        expect(m.answer, isNot(inOrder),
            reason: 'tapping top to bottom should not win "${m.problem}"');
      }
    });

    test('every collapse has one answer and three distinct wrong forms', () {
      for (final c in collapses) {
        expect(c.options.length, 4);
        expect(c.options.toSet().length, 4);
        expect(c.answer, inInclusiveRange(0, 3));
      }
    });
  });

  group('Rule or Trap', () {
    testWidgets('calling the product rule legal is correct', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: RuleOrTrapGame()));

      await tester.tap(find.text('Legal'));
      await tester.pump();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();

      expect(find.text('CORRECT'), findsOneWidget);
      expect(find.text('1/10'), findsOneWidget);
    });

    testWidgets('a verdict is required before locking', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: RuleOrTrapGame()));
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('CORRECT'), findsNothing);
      expect(find.text('NOT QUITE'), findsNothing);
    });
  });

  group('Order the Moves', () {
    testWidgets('clearing the coefficient comes before taking the log',
        (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: OrderTheMovesGame()));

      final set = moveSets.first;
      for (final i in set.answer) {
        await tester.tap(find.text(set.shown[i]));
        await tester.pump();
      }
      await tester.tap(find.text('Lock the order'));
      await tester.pumpAndSettle();

      expect(find.text('CORRECT'), findsOneWidget);
      expect(find.text('1/4'), findsOneWidget);
    });

    testWidgets('logging first is caught and named', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: OrderTheMovesGame()));

      final set = moveSets.first;
      for (final i in [0, 1, 3, 2]) {
        await tester.tap(find.text(set.shown[i]));
        await tester.pump();
      }
      await tester.tap(find.text('Lock the order'));
      await tester.pumpAndSettle();

      expect(find.text('NOT THAT ORDER'), findsOneWidget);
      expect(find.text('0/4'), findsOneWidget);
    });
  });

  group('One Log', () {
    testWidgets('added logs multiply inside', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: OneLogGame()));

      // Option 1 is log(xy) for the first round.
      await tester.tap(find.byKey(const ValueKey('one-log-option-1')));
      await tester.pump();
      await tester.ensureVisible(find.text('Lock it in'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();

      expect(find.text('CORRECT'), findsOneWidget);
      expect(find.text('1/6'), findsOneWidget);
    });
  });
}
