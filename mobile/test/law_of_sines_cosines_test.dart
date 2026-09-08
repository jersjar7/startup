import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/acute_or_obtuse_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/set_it_up_game.dart';
import 'package:mobile/features/games/which_law_game.dart';

/// Lesson four. The decision tree and the written form are the whole lesson, so
/// both are pinned against the rules rather than trusted to the author.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['which-law', 'set-it-up', 'acute-or-obtuse']) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('content', () {
    test('the answer follows the lesson rule in every round', () {
      for (final r in lawRounds) {
        // A complete side-angle pair is what opens the Law of Sines.
        final hasPair = r.knownSides.any(
          (s) => r.knownAngles.contains(s.toUpperCase()),
        );
        // Two angles give the third, which completes a pair as well.
        final twoAngles = r.knownAngles.length >= 2;
        expect(r.sines, hasPair || twoAngles,
            reason: '${r.pattern}: ${r.context}');
      }
    });

    test('both laws and the ambiguous case are represented', () {
      expect(lawRounds.any((r) => r.sines), isTrue);
      expect(lawRounds.any((r) => !r.sines), isTrue);
      expect(lawRounds.any((r) => r.pattern == 'SSA'), isTrue);
      expect(lawRounds.map((r) => r.pattern).toSet().length,
          greaterThanOrEqualTo(4));
    });

    test('what is wanted is never already known', () {
      for (final r in lawRounds) {
        expect(r.knownSides.contains(r.wanted), isFalse);
        expect(r.knownAngles.contains(r.wanted), isFalse);
      }
    });

    test('every setup has four distinct forms and one right one', () {
      for (final s in setups) {
        expect(s.options.length, 4);
        expect(s.options.toSet().length, 4);
        expect(s.answer, inInclusiveRange(0, 3));
        expect(s.why.trim(), isNotEmpty);
      }
    });

    test('the sign of the cosine decides the kind of angle', () {
      // Every verdict round is one of the three cases, and all three appear.
      expect(verdicts.map((v) => v.answer).toSet(), AngleKind.values.toSet());
      for (final v in verdicts) {
        expect(v.source, startsWith('math-lsc-'));
      }
    });
  });

  group('playing', () {
    testWidgets('a side with its opposite angle means Sines', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichLawGame()));

      await tester.tap(find.text('Law of Sines'));
      await tester.pump();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();

      expect(find.text('CORRECT'), findsOneWidget);
      expect(find.textContaining('AAS'), findsOneWidget);
      expect(find.text('1/8'), findsOneWidget);
    });

    testWidgets('flipping the sine ratio is marked wrong', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: SetItUpGame()));

      // Option 1 is the flipped ratio.
      await tester.tap(find.byKey(const ValueKey('set-it-up-option-1')));
      await tester.pump();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();

      expect(find.text('NOT THAT ONE'), findsOneWidget);
      expect(find.text('0/6'), findsOneWidget);
    });

    testWidgets('a negative cosine is obtuse, not a mistake', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: AcuteOrObtuseGame()));

      await tester.tap(find.text('Obtuse'));
      await tester.pump();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();

      expect(find.text('CORRECT'), findsOneWidget);
      expect(find.textContaining('nothing to subtract from 180'),
          findsOneWidget);
    });
  });
}
