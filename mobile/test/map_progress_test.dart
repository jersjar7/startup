import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/chapter_map_screen.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/lesson_node.dart';

/// The map must not move a node while a sitting is covering it. That is what
/// made the fill invisible: progress was recorded mid-sitting, the map rebuilt
/// underneath, and the ring had finished climbing before the student came back.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['perpendicular-flip', 'discriminant-gate', 'grade-sense']) {
      GameProgress.instance.reset(id);
    }
  });

  LessonNodeWidget nodeFor(WidgetTester tester, String lessonId) => tester
      .widgetList<LessonNodeWidget>(find.byType(LessonNodeWidget))
      .firstWhere((w) => (w.key as ValueKey).value == lessonId);

  testWidgets('a node holds its value while progress changes underneath',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(home: ChapterMapScreen(chapter: mathematicsMap)),
    );

    final before = nodeFor(tester, 'straight-lines-quadratics');
    expect(before.fractionTo, 0);

    // A sitting finishes an item while the map is buried under it.
    for (var i = 0; i < 8; i++) {
      GameProgress.instance
          .markRoundCleared('perpendicular-flip', i, firstTry: true);
    }
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    final after = nodeFor(tester, 'straight-lines-quadratics');
    expect(after.fractionTo, 0,
        reason: 'the ring must still have the climb ahead of it');
    expect(after.fractionFrom, 0);
  });

  testWidgets('an untouched chapter starts every node settled', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(home: ChapterMapScreen(chapter: mathematicsMap)),
    );

    for (final w in tester.widgetList<LessonNodeWidget>(
        find.byType(LessonNodeWidget))) {
      expect(w.fractionFrom, w.fractionTo,
          reason: 'a first visit should not animate anything');
    }
  });
}
