import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/chapter_map_screen.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/lesson_node.dart';
import 'package:mobile/features/games/road_segment.dart';

/// Work finished in an earlier run has to show as finished the moment the map
/// opens. It did not: the map only learned how many rounds an item had when
/// that item was opened, so after a new build a cleared lesson looked
/// untouched until you tapped into it.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['perpendicular-flip', 'discriminant-gate', 'grade-sense']) {
      GameProgress.instance.reset(id);
    }
  });

  test('the catalog declares how long every built board is', () {
    for (final chapter in chapterMaps.values) {
      for (final lesson in chapter.lessons) {
        for (final game in lesson.builtGames) {
          expect(game.rounds, greaterThan(0),
              reason: '${game.name} does not say how many rounds it has');
        }
      }
    }
  });

  test('a finished board reads as finished with nothing else loaded', () {
    for (var i = 0; i < GameProgress.roundsIn('grade-sense'); i++) {
      GameProgress.instance.markRoundCleared('grade-sense', i, firstTry: true);
    }
    expect(GameProgress.instance.isCleared('grade-sense'), isTrue);
  });

  testWidgets('a cleared lesson opens the map already green', (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Everything in lesson one, finished in some earlier run.
    for (final id in ['perpendicular-flip', 'discriminant-gate', 'grade-sense']) {
      for (var i = 0; i < GameProgress.roundsIn(id); i++) {
        GameProgress.instance.markRoundCleared(id, i, firstTry: true);
      }
    }

    await tester.pumpWidget(
      const MaterialApp(home: ChapterMapScreen(chapter: mathematicsMap)),
    );

    final node = tester
        .widgetList<LessonNodeWidget>(find.byType(LessonNodeWidget))
        .firstWhere(
            (w) => (w.key as ValueKey).value == 'straight-lines-quadratics');

    expect(node.state, NodeState.cleared);
    expect(node.fractionTo, 1);
    expect(node.fractionFrom, 1, reason: 'nothing to animate on a cold launch');
    expect(find.text('All 3 done'), findsOneWidget);

    // And the road out of it is already walked.
    final road = tester
        .widgetList<RoadSegment>(find.byType(RoadSegment))
        .firstWhere(
            (w) => (w.key as ValueKey).value == 'road-straight-lines-quadratics');
    expect(road.travelled, 1);
  });

  testWidgets('an unfinished lesson leaves its road pale', (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    GameProgress.instance
        .markRoundCleared('perpendicular-flip', 0, firstTry: true);

    await tester.pumpWidget(
      const MaterialApp(home: ChapterMapScreen(chapter: mathematicsMap)),
    );

    final road = tester
        .widgetList<RoadSegment>(find.byType(RoadSegment))
        .firstWhere(
            (w) => (w.key as ValueKey).value == 'road-straight-lines-quadratics');
    expect(road.travelled, 0);
  });
}
