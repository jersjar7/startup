import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/grounds_or_not_game.dart';
import 'package:mobile/features/games/what_is_missing_yet_game.dart';
import 'package:mobile/features/games/which_section_game.dart';

/// Chapter three, lesson four. The licensure ladder is the one part of this
/// chapter with numbers in it, so the record rounds CAN be recomputed: the
/// years a degree asks for are a rule, and a record that says it has four is
/// either short or it is not.
///
/// How many years the stated degree requires. Anything not on this list would
/// be a record the item cannot check itself against.
int _yearsFor(String degree) {
  final d = degree.toLowerCase();
  if (d.startsWith('phd') || d.contains('doctor')) return 2;
  if (d.startsWith('ms') || d.contains('master')) return 3;
  return 4;
}

int _yearsHeld(String experience) =>
    int.parse(RegExp(r'^\d+').firstMatch(experience.trim())!.group(0)!);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in [
      'what-is-missing-yet',
      'grounds-or-not',
      'which-section',
    ]) {
      GameProgress.instance.reset(id);
    }
  });

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(420, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('what is missing yet', () {
    test('the stated gap is the first one the record actually has', () {
      for (final r in recordRounds) {
        final gaps = <int>[
          if (!r.degree.toLowerCase().contains('accredited')) 0,
          if (r.fe != 'Passed') 1,
          if (_yearsHeld(r.experience) < _yearsFor(r.degree)) 2,
          if (r.pe != 'Passed') 3,
          if (_yearsHeld(r.references) < 5) 4,
        ];
        final expected = gaps.isEmpty ? readyIndex : gaps.first;
        expect(r.answer, expected,
            reason: '${r.subject}: the record has gaps $gaps, so the first is '
                '$expected and the round says ${r.answer}');
      }
    });

    test('the experience is judged against the right track', () {
      // The whole trap. A doctorate asks for two years and a bachelor's for
      // four, and a round whose degree and years do not line up with its own
      // answer would teach the wrong number.
      for (final r in recordRounds) {
        final needed = _yearsFor(r.degree);
        final held = _yearsHeld(r.experience);
        if (r.answer == 2) {
          expect(held, lessThan(needed), reason: r.subject);
        } else {
          expect(held, greaterThanOrEqualTo(needed),
              reason: '${r.subject}: the years clear the bar and the round '
                  'blames something else');
        }
      }
    });

    test('every requirement is the gap somewhere, and one record clears', () {
      final answers = recordRounds.map((r) => r.answer).toSet();
      expect(answers.contains(readyIndex), isTrue,
          reason: 'a board that always finds something wrong teaches nothing');
      expect(answers.length, greaterThanOrEqualTo(4),
          reason: 'only ${answers.length} of the six answers ever come up');
    });

    test('all three degree tracks appear', () {
      final tracks = recordRounds.map((r) => _yearsFor(r.degree)).toSet();
      expect(tracks, {2, 3, 4},
          reason: 'the three tracks are the content, and a set that skips one '
              'never puts the trap in front of anybody');
    });

    test('the answer never repeats round to round', () {
      for (var i = 1; i < recordRounds.length; i++) {
        expect(recordRounds[i].answer, isNot(recordRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous gap');
      }
    });
  });

  group('grounds, or not', () {
    test('every round has four events and both answers among them', () {
      for (final r in groundsRounds) {
        expect(r.events.length, 4, reason: r.subject);
        final yes = r.events.where((e) => e.grounds).length;
        expect(yes, inInclusiveRange(1, 3),
            reason: '${r.subject}: $yes of four, so the round can be cleared '
                'by answering everything the same way');
        expect(r.events.map((e) => e.text).toSet().length, 4,
            reason: '${r.subject}: an event is listed twice');
      }
    });

    test('the pattern of answers is different in every round', () {
      final patterns = groundsRounds
          .map((r) => r.events.map((e) => e.grounds).join(','))
          .toList();
      expect(patterns.toSet().length, patterns.length,
          reason: 'two rounds share an answer pattern, which is learnable');
    });

    test('a felony is always grounds, wherever it appears', () {
      final felonies = [
        for (final r in groundsRounds)
          for (final e in r.events)
            if (e.text.toLowerCase().contains('felony')) e,
      ];
      expect(felonies, isNotEmpty);
      for (final e in felonies) {
        expect(e.grounds, isTrue, reason: '"${e.text}" is a felony and is not '
            'marked as grounds');
      }
    });

    test('a misdemeanour is grounds only when it touches honesty or work', () {
      final misdemeanours = [
        for (final r in groundsRounds)
          for (final e in r.events)
            if (e.text.toLowerCase().contains('misdemeanour')) e,
      ];
      expect(misdemeanours.length, greaterThanOrEqualTo(2),
          reason: 'the contrast needs at least one of each');
      expect(misdemeanours.where((e) => e.grounds).length,
          greaterThanOrEqualTo(1));
      expect(misdemeanours.where((e) => !e.grounds).length,
          greaterThanOrEqualTo(1));
    });

    test('unlicensed rounds and licensee rounds both appear', () {
      final unlicensed = groundsRounds.where(
        (r) => r.who.toLowerCase().contains('never been licensed') ||
            r.who.toLowerCase().contains('revoked'),
      );
      expect(unlicensed.length, greaterThanOrEqualTo(2),
          reason: 'the two lists are the point and one of them is missing');
    });
  });

  group('which section', () {
    test('every section is the answer at least once, and none twice running',
        () {
      expect(sectionRounds.map((r) => r.answer).toSet(), Section.values.toSet());
      for (var i = 1; i < sectionRounds.length; i++) {
        expect(sectionRounds[i].answer, isNot(sectionRounds[i - 1].answer),
            reason: 'round ${i + 1} repeats the previous section');
      }
    });

    test('a revoked or expired licence lands on the unlicensed list', () {
      // The hinge of the whole lesson. Anybody who used to hold a licence and
      // does not now belongs on the other list.
      final gone = sectionRounds.where((r) =>
          r.scene.contains('revoked') || r.scene.contains('expires'));
      expect(gone.length, greaterThanOrEqualTo(2));
      for (final r in gone) {
        expect(r.answer, Section.unlicensed, reason: r.subject);
      }
    });

    test('a licensee round says plainly that they hold a licence', () {
      for (final r in sectionRounds.where((r) => r.answer == Section.licensee)) {
        expect(r.scene.toLowerCase().contains('licensed'), isTrue,
            reason: '${r.subject}: nothing in the scene says they are licensed');
      }
    });

    test('the round that is neither is about conduct nobody regulates', () {
      final none = sectionRounds.firstWhere((r) => r.answer == Section.neither);
      expect(none.scene.toLowerCase().contains('competent'), isTrue,
          reason: 'the point of that round is that the work was fine');
    });

    test('both disciplinary problems are drawn on', () {
      expect(sectionRounds.map((r) => r.source).toSet().length,
          greaterThanOrEqualTo(2));
    });
  });

  group('the boards run', () {
    testWidgets('a gap has to be named before locking in', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhatIsMissingYetGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THAT IS THE GAP'), findsNothing);
      expect(find.text('LOOK AGAIN'), findsNothing);
    });

    testWidgets('passing the two-year record is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhatIsMissingYetGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('missing-ready')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('LOOK AGAIN'), findsOneWidget);
    });

    testWidgets('three of four answered is not enough to lock in', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: GroundsOrNotGame()));
      await tester.pumpAndSettle();

      for (final i in [0, 1, 2]) {
        await tester.tap(find.byKey(ValueKey('event-$i-yes')));
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('ALL FOUR'), findsNothing);
      expect(find.text('NOT ALL FOUR'), findsNothing);
    });

    testWidgets('calling every event grounds is caught', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: GroundsOrNotGame()));
      await tester.pumpAndSettle();

      for (final i in [0, 1, 2, 3]) {
        await tester.tap(find.byKey(ValueKey('event-$i-yes')));
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('NOT ALL FOUR'), findsOneWidget);
    });

    testWidgets('answering all four correctly is accepted', (tester) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: GroundsOrNotGame()));
      await tester.pumpAndSettle();

      final r = groundsRounds.first;
      for (var i = 0; i < r.events.length; i++) {
        await tester.tap(
          find.byKey(ValueKey('event-$i-${r.events[i].grounds ? 'yes' : 'no'}')),
        );
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('ALL FOUR'), findsOneWidget);
    });

    testWidgets('putting the felon on the unlicensed list is caught', (
      tester,
    ) async {
      size(tester);
      await tester.pumpWidget(const MaterialApp(home: WhichSectionGame()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('section-unlicensed')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lock it in'));
      await tester.pumpAndSettle();
      expect(find.text('THE OTHER LIST'), findsOneWidget);
    });
  });
}
