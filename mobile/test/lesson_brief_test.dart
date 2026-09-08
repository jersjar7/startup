import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/lesson_brief.dart';

/// The brief carries three figures, one of them a row of three panels, which
/// is the shape most likely to overflow on a small phone.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final width in const [320.0, 360.0, 390.0, 430.0]) {
    testWidgets('the idea lays out with no overflow at ${width.toInt()}pt',
        (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(size: Size(width, 900)),
            child: const LessonBriefView(
              lessonName: 'Straight Lines & Quadratics',
              sections: straightLinesBrief,
            ),
          ),
        ),
      ));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('it defines the terms the items lean on', (tester) async {
    tester.view.physicalSize = const Size(390, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: LessonBriefView(
          lessonName: 'Straight Lines & Quadratics',
          sections: straightLinesBrief,
        ),
      ),
    ));

    expect(find.text('Parallel and perpendicular'), findsOneWidget);
    expect(find.text('The discriminant'), findsOneWidget);
    expect(find.text('Grade, rise and run'), findsOneWidget);
    // The station trap is stated in words, not left to the item to teach.
    expect(find.textContaining('3+00 means 300 feet'), findsOneWidget);
  });
}
