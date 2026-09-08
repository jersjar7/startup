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
    testWidgets('every concept lays out with no overflow at ${width.toInt()}pt',
        (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (final s in const [perpendicularBrief, discriminantBrief, gradeBrief]) {
        await tester.pumpWidget(wrap(s, width));
        expect(tester.takeException(), isNull, reason: s.title);
      }
    });
  }

  testWidgets('the station trap is stated, not left to the item', (tester) async {
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
    expect(whichLawBrief.formulas.length, 2);
    expect(whichLawBrief.formulas.first.$2, contains(r'\sin A'));
    expect(whichLawBrief.formulas.last.$2, contains(r'\cos C'));

    expect(ratiosBrief.formulas.length, 3);
    expect(discriminantBrief.formulas.any((f) => f.$2.contains('pm')), isTrue,
        reason: 'the discriminant needs the formula it comes out of');
  });

  testWidgets('the laws are on screen, not just described', (tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(whichLawBrief, 390));
    expect(find.text('LAW OF SINES'), findsOneWidget);
    expect(find.text('LAW OF COSINES'), findsOneWidget);
  });

  test('every built item carries its own concept', () {
    for (final lesson in mathematicsMap.lessons) {
      for (final game in lesson.builtGames) {
        expect(game.brief, isNotNull, reason: '${game.name} has no reference');
      }
    }
  });
}
