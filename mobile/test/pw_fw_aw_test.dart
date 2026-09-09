import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/do_they_agree_game.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/how_long_to_compare_game.dart';
import 'package:mobile/features/games/which_way_it_pushes_game.dart';

/// Chapter four, lesson two. The study-period rounds have arithmetic in them
/// and the test does it: the least common multiple a round claims is computed
/// from the two lives it declares, so a round cannot draw one picture and
/// name another.
int _lcm(int a, int b) {
  var x = a;
  while (x % b != 0) {
    x += a;
  }
  return x;
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in [
      'which-way-it-pushes',
      'how-long-to-compare',
      'do-they-agree',
    ]) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('which way it pushes', () {
    test('every direction is the answer at least once', () {
      for (final p in Push.values) {
        expect(pushRounds.where((r) => r.answer == p).length,
            greaterThanOrEqualTo(1),
            reason: '$p never comes up');
      }
      expect(pushRounds.where((r) => r.answer == Push.up).length,
          greaterThanOrEqualTo(2),
          reason: 'costs are the common case and should look like it');
    });

    test('the direction never repeats round to round', () {
      for (var i = 1; i < pushRounds.length; i++) {
        expect(pushRounds[i].answer, isNot(pushRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous direction');
      }
    });

    test('the salvage round is one of the ones that pushes down', () {
      // The trap the lesson names. If salvage is not in the set, the item is
      // not doing the job it was written for.
      final salvage = pushRounds.firstWhere(
        (r) => r.item.contains('sell for'),
      );
      expect(salvage.answer, Push.down);
    });

    test('the sunk cost round says the money is already gone', () {
      for (final r in pushRounds.where((r) => r.answer == Push.neither)) {
        final text = r.item.toLowerCase();
        expect(text.contains('spent') || text.contains('last year'), isTrue,
            reason: '${r.subject}: nothing says the money is already gone');
        expect(text.contains('whichever') || text.contains('whatever'), isTrue,
            reason: '${r.subject}: a sunk cost has to be sunk for BOTH '
                'alternatives, or it is just a cost');
      }
    });

    test('no item states its own direction', () {
      const giveaways = ['reduces', 'increases', 'lowers', 'raises', 'sunk'];
      for (final r in pushRounds) {
        final text = r.item.toLowerCase();
        for (final word in giveaways) {
          expect(text.contains(word), isFalse,
              reason: '${r.subject} says "$word"');
        }
      }
    });
  });

  group('how long to compare over', () {
    test('the multiple a round computes is the real one', () {
      for (final r in studyRounds) {
        expect(r.multiple, _lcm(r.lifeA, r.lifeB),
            reason: '${r.subject}: ${r.lifeA} and ${r.lifeB} meet at '
                '${_lcm(r.lifeA, r.lifeB)}, and the round says ${r.multiple}');
      }
    });

    test('a round answering with the multiple really has unequal lives', () {
      for (final r in studyRounds.where((r) => r.answer == Study.multiple)) {
        expect(r.lifeA, isNot(r.lifeB), reason: r.subject);
        // The multiple is past the SHORTER life always, and past the longer
        // one only when neither divides the other.
        final shorter = r.lifeA < r.lifeB ? r.lifeA : r.lifeB;
        final longer = r.lifeA > r.lifeB ? r.lifeA : r.lifeB;
        expect(r.multiple, greaterThan(shorter), reason: r.subject);
        expect(r.multiple, greaterThanOrEqualTo(longer), reason: r.subject);
      }
    });

    test('a round answering with their own life has equal lives', () {
      for (final r in studyRounds.where((r) => r.answer == Study.shorter)) {
        expect(r.lifeA, r.lifeB,
            reason: '${r.subject}: the lives differ, so their own life is not '
                'a common period');
      }
    });

    test('an annual worth round says so in the setting', () {
      for (final r in studyRounds) {
        final wantsAw = r.setting.contains('ANNUAL WORTH');
        expect(r.answer == Study.annualWorth, wantsAw,
            reason: '${r.subject}: the method the setting names and the answer '
                'do not match');
      }
    });

    test('every answer happens twice', () {
      for (final s in Study.values) {
        expect(studyRounds.where((r) => r.answer == s).length, 2,
            reason: '$s appears the wrong number of times');
      }
    });

    test('the drawn span covers the multiple when that is the answer', () {
      for (final r in studyRounds) {
        if (r.answer == Study.multiple) {
          expect(r.span, greaterThanOrEqualTo(r.multiple),
              reason: '${r.subject}: the mark would fall off the picture');
        }
        expect(r.span, greaterThan(0), reason: r.subject);
        expect(r.span, lessThanOrEqualTo(30),
            reason: '${r.subject}: past thirty the blocks are slivers');
      }
    });

    test('one round has one life dividing the other', () {
      // Five into fifteen is the case where the multiple is just the longer
      // life, and it looks different enough to be worth its own round.
      final divides = studyRounds.any(
        (r) => r.lifeA != r.lifeB && r.multiple == (r.lifeA > r.lifeB ? r.lifeA : r.lifeB),
      );
      expect(divides, isTrue);
    });
  });

  group('do they agree', () {
    test('every cause is the answer twice', () {
      for (final c in Cause.values) {
        expect(agreeRounds.where((r) => r.answer == c).length, 2,
            reason: '$c appears the wrong number of times');
      }
    });

    test('the cause never repeats round to round', () {
      for (var i = 1; i < agreeRounds.length; i++) {
        expect(agreeRounds[i].answer, isNot(agreeRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous cause');
      }
    });

    test('a slip round says everything else was the same', () {
      // The whole point of that answer is that nothing legitimate could cause
      // it, so the report has to close off the other two explanations.
      for (final r in agreeRounds.where((r) => r.answer == Cause.arithmetic)) {
        final text = r.report.toLowerCase();
        expect(text.contains('same') || text.contains('both'), isTrue,
            reason: '${r.subject}: nothing in the report closes off the other '
                'two explanations, so a slip is not the only answer left');
      }
    });

    test('a periods round has two different lives in it', () {
      // The reports spell their numbers out, the way the rest of the app
      // does, so the durations are matched as words as well as digits.
      final duration = RegExp(
        r'(\d+|one|two|three|four|five|six|seven|eight|nine|ten|twelve|'
        r'fifteen|twenty)[ -]year',
        caseSensitive: false,
      );
      for (final r in agreeRounds.where((r) => r.answer == Cause.periods)) {
        final lives = duration
            .allMatches(r.report)
            .map((m) => m.group(1)!.toLowerCase())
            .toSet();
        expect(lives.length, greaterThanOrEqualTo(2),
            reason: '${r.subject}: found $lives, so nothing in the report '
                'supports two different periods');
      }
    });

    test('a rate round never states one rate for both', () {
      for (final r in agreeRounds.where((r) => r.answer == Cause.rate)) {
        expect(r.report.contains('the same rate'), isFalse,
            reason: '${r.subject}: the report rules out its own answer');
      }
    });

    test('every report is long enough to diagnose', () {
      for (final r in agreeRounds) {
        expect(r.report.length, greaterThan(110), reason: r.subject);
        expect(r.why.length, greaterThan(90), reason: r.subject);
      }
    });
  });

  group('the boards run', () {
    testWidgets('a direction has to be chosen before locking in', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichWayItPushesGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT WAY'), findsNothing);
      expect(find.text('THE OTHER WAY'), findsNothing);
    });

    testWidgets('the purchase price pushes the annual cost up', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichWayItPushesGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('push-up')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT WAY'), findsOneWidget);
    });

    testWidgets('comparing unequal lives as they stand is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: HowLongToCompareGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('study-shorter')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT THAT ONE'), findsOneWidget);
    });

    testWidgets('the least common multiple is accepted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: HowLongToCompareGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('study-multiple')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT PERIOD'), findsOneWidget);
    });

    testWidgets('excusing an impossible disagreement is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: DoTheyAgreeGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('cause-periods')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('SOMETHING ELSE'), findsOneWidget);
    });
  });
}
