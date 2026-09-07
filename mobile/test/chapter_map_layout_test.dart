import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/chapter_map_screen.dart';
import 'package:mobile/features/games/game_catalog.dart';

/// The path is drawn, not laid out by Flutter's own widgets, so it is the one
/// screen where a narrow phone could silently push a label off the edge or
/// overflow a row. These pin it across the range of real handset widths.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  // 320 = iPhone SE 1st gen, 430 = 17 Pro Max. Everything shipping sits inside.
  const widths = [320.0, 360.0, 375.0, 390.0, 420.0, 430.0];

  Widget app(double width) => MediaQuery(
        data: MediaQueryData(size: Size(width, 850)),
        child: const MaterialApp(
          home: ChapterMapScreen(chapter: mathematicsMap, masteryPct: 24),
        ),
      );

  for (final width in widths) {
    testWidgets('lays out with no overflow at ${width.toInt()}pt',
        (tester) async {
      tester.view.physicalSize = Size(width, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(app(width));
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps every lesson label on screen at ${width.toInt()}pt',
        (tester) async {
      tester.view.physicalSize = Size(width, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(app(width));

      for (final lesson in mathematicsMap.lessons) {
        final finder = find.text(lesson.name);
        if (finder.evaluate().isEmpty) continue; // below the fold, not laid out
        final rect = tester.getRect(finder);
        expect(rect.left, greaterThanOrEqualTo(0),
            reason: '${lesson.name} runs off the left at ${width}pt');
        expect(rect.right, lessThanOrEqualTo(width),
            reason: '${lesson.name} runs off the right at ${width}pt');
      }
    });
  }

  testWidgets('every lesson in the chapter gets a node', (tester) async {
    tester.view.physicalSize = const Size(390, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app(390));
    expect(find.text('Straight Lines & Quadratics'), findsOneWidget);
    expect(find.text('Numerical Methods: Root-Finding'), findsOneWidget);
  });
}
