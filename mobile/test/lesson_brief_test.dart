import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/lesson_brief.dart';

/// Each item's reference covers that item and nothing else. Opening it mid
/// round should answer the question in front of you.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget wrap(BriefSection s, double width) => MaterialApp(
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(size: Size(width, 900)),
        child: ConceptView(section: s),
      ),
    ),
  );

  for (final width in const [320.0, 360.0, 390.0, 430.0]) {
    testWidgets(
      'every concept lays out with no overflow at ${width.toInt()}pt',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        for (final s in const [
          perpendicularBrief,
          discriminantBrief,
          gradeBrief,
        ]) {
          await tester.pumpWidget(wrap(s, width));
          expect(tester.takeException(), isNull, reason: s.title);
        }
      },
    );
  }

  testWidgets('the station trap is stated, not left to the item', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(gradeBrief, 390));
    expect(find.text('Grade, rise and run'), findsOneWidget);
    expect(find.textContaining('3+00 means 300 feet'), findsOneWidget);
    // And it does NOT carry the other two concepts.
    expect(find.textContaining('discriminant'), findsNothing);
    expect(find.textContaining('perpendicular'), findsNothing);
  });

  test('a card that names a law also shows it', () {
    // A reference that says WHEN to use something without showing WHAT it is
    // reads as arbitrary: you cannot learn the law from it.
    expect(whichLawBrief.spoken.length, 2);
    expect(whichLawBrief.spoken.first.$2, contains(r'\sin A'));
    expect(whichLawBrief.spoken.last.$2, contains(r'\cos C'));

    expect(ratiosBrief.spoken.length, 3);
    expect(
      discriminantBrief.spoken.any((f) => f.$2.contains('pm')),
      isTrue,
      reason: 'the discriminant needs the formula it comes out of',
    );
  });

  testWidgets('the laws are on screen, not just described', (tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(whichLawBrief, 390));
    expect(find.text('LAW OF SINES'), findsOneWidget);
    expect(find.text('LAW OF COSINES'), findsOneWidget);
  });

  test('every card shows the thing it teaches', () {
    // The rule the owner set after "Which law, and when" explained a law
    // without printing it: a card must carry the formula, rule or named
    // relation it is about, not only prose about when to use it.
    const cards = [
      perpendicularBrief,
      discriminantBrief,
      gradeBrief,
      logRulesBrief,
      undoExponentBrief,
      combineLogsBrief,
      ratiosBrief,
      sideNamesBrief,
      componentsBrief,
      whichLawBrief,
      setupBrief,
      obtuseBrief,
    ];
    for (final c in cards) {
      expect(
        c.spoken.isNotEmpty || c.formulas.isNotEmpty || c.formula != null,
        isTrue,
        reason: '"${c.title}" states no rule of its own',
      );
      for (final (label, latex, _) in c.spoken) {
        expect(label.trim(), isNotEmpty);
        expect(latex.trim(), isNotEmpty);
        expect(
          latex.contains(r'\\'),
          isFalse,
          reason: 'double-escaped LaTeX in "${c.title}" will not render',
        );
      }
    }
  });

  test('every built item carries its own concept', () {
    for (final lesson in mathematicsMap.lessons) {
      for (final game in lesson.builtGames) {
        expect(game.brief, isNotNull, reason: '${game.name} has no reference');
      }
    }
  });

  // The picture-first sheet (owner's call, 2026-09-30): a drawing the
  // student just played with, then the idea in short steps a reader who has
  // never heard the words can follow, then each rule read out in words. The
  // rule applies to every sheet that has been rewritten; the count only
  // grows until every chapter is done.
  group('picture-first sheets', () {
    final all = <BriefSection>[
      for (final chapter in chapterMaps.values)
        for (final lesson in chapter.lessons)
          for (final game in lesson.builtGames)
            if (game.brief != null) game.brief!,
    ];
    final pictureFirst = all.where((c) => c.picture != null).toList();

    test('the rewrite has not gone backwards', () {
      expect(pictureFirst.length, greaterThanOrEqualTo(24));
    });

    test('every picture-first sheet has short steps and spoken rules', () {
      for (final c in pictureFirst) {
        expect(c.steps.length, inInclusiveRange(3, 4), reason: c.title);
        for (final (eyebrow, text) in c.steps) {
          expect(eyebrow.trim(), isNotEmpty, reason: c.title);
          final words = text.trim().split(RegExp(r'\s+')).length;
          expect(
            words,
            lessThanOrEqualTo(60),
            reason:
                '"${c.title}" step "$eyebrow" runs $words words; one idea, said short',
          );
        }
        expect(c.spoken, isNotEmpty, reason: '"${c.title}" states no rule');
        for (final (label, latex, words) in c.spoken) {
          expect(label.trim(), isNotEmpty, reason: c.title);
          expect(latex.contains(r'\\'), isFalse, reason: c.title);
          expect(
            words.trim(),
            isNotEmpty,
            reason: '"${c.title}" does not read "$label" out',
          );
        }
        expect(
          c.figure,
          BriefFigure.none,
          reason: '"${c.title}" still carries a rule list',
        );
        expect(
          c.body,
          isEmpty,
          reason: '"${c.title}" still carries the old paragraph',
        );
      }
    });

    testWidgets(
      'every picture-first sheet lays out with no overflow at 320pt',
      (tester) async {
        tester.view.physicalSize = const Size(320, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        for (final s in pictureFirst) {
          await tester.pumpWidget(wrap(s, 320));
          expect(tester.takeException(), isNull, reason: s.title);
        }
      },
    );
  });
}
