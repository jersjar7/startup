import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/perpendicular_flip_game.dart';

/// A sitting can be left half way. These pin the two halves of that: the
/// progress store counts rounds rather than whole boards, and a screen opened
/// again starts from what is left.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    for (final id in ['perpendicular-flip', 'discriminant-gate', 'grade-sense']) {
      GameProgress.instance.reset(id);
    }
  });

  test('a board is not finished until every round is', () {
    GameProgress.registerRounds('grade-sense', 6);
    for (var i = 0; i < 5; i++) {
      GameProgress.instance.markRoundCleared('grade-sense', i, firstTry: true);
    }
    expect(GameProgress.instance.isCleared('grade-sense'), isFalse);
    expect(GameProgress.instance.isStarted('grade-sense'), isTrue);

    GameProgress.instance.markRoundCleared('grade-sense', 5, firstTry: false);
    expect(GameProgress.instance.isCleared('grade-sense'), isTrue);
  });

  test('the same round cleared twice counts once', () {
    GameProgress.registerRounds('discriminant-gate', 8);
    GameProgress.instance.markRoundCleared('discriminant-gate', 0, firstTry: true);
    GameProgress.instance.markRoundCleared('discriminant-gate', 0, firstTry: true);
    expect(GameProgress.instance.roundsCleared('discriminant-gate').length, 1);
    expect(GameProgress.instance.firstTryCount('discriminant-gate'), 1);
  });

  test('a lesson reads as in progress while any of its work is unfinished', () {
    final lesson = mathematicsMap.lessons.first;
    GameProgress.registerRounds('perpendicular-flip', 8);
    expect(GameProgress.instance.stateOf(lesson), LessonState.notStarted);

    GameProgress.instance
        .markRoundCleared('perpendicular-flip', 0, firstTry: true);
    expect(GameProgress.instance.stateOf(lesson), LessonState.inProgress);
  });

  testWidgets('reopening a half-finished board resumes it', (tester) async {
    GameProgress.registerRounds('perpendicular-flip', 8);
    for (var i = 0; i < 3; i++) {
      GameProgress.instance
          .markRoundCleared('perpendicular-flip', i, firstTry: true);
    }

    await tester.pumpWidget(
      const MaterialApp(home: PerpendicularFlipGame()),
    );

    // The counter picks up where it was left, not at zero.
    expect(find.text('3/8'), findsOneWidget);
    // And the round on screen is one of the five still outstanding.
    expect(find.textContaining('LAY IT'), findsOneWidget);
  });

  testWidgets('a finished board opens on its done screen', (tester) async {
    GameProgress.registerRounds('perpendicular-flip', 8);
    for (var i = 0; i < 8; i++) {
      GameProgress.instance
          .markRoundCleared('perpendicular-flip', i, firstTry: false);
    }

    await tester.pumpWidget(
      const MaterialApp(home: PerpendicularFlipGame()),
    );
    expect(find.text('ALL DONE'), findsOneWidget);
  });
}
