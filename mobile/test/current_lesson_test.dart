import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/game_progress.dart';

/// The one node on a chapter path that breathes: the lesson the student is
/// in the middle of. Never an untouched one, because nothing on the map locks
/// and pointing at an untouched node would imply an order it does not impose.
void main() {
  late ChapterMap chapter;
  late LessonNode a;
  late LessonNode b;

  setUp(() {
    chapter = chapterMaps.values.firstWhere(
      (c) => c.lessons.where((l) => l.builtGames.length >= 2).length >= 2,
    );
    final playable = chapter.lessons.where((l) => l.builtGames.length >= 2);
    a = playable.first;
    b = playable.elementAt(1);
    for (final l in chapter.lessons) {
      for (final g in l.games) {
        GameProgress.instance.reset(g.id);
      }
    }
  });

  test('an untouched chapter points at nothing', () {
    expect(GameProgress.instance.currentLessonIn(chapter), isNull);
  });

  test('the lesson last played in, while it is unfinished', () {
    GameProgress.instance.markRoundCleared(
      a.builtGames[0].id,
      1,
      firstTry: true,
    );
    GameProgress.instance.markRoundCleared(
      b.builtGames[0].id,
      1,
      firstTry: true,
    );
    expect(GameProgress.instance.currentLessonIn(chapter), b.id);
  });

  test('a finished lesson hands the cue to the next unfinished one', () {
    GameProgress.instance.markRoundCleared(
      a.builtGames[0].id,
      1,
      firstTry: true,
    );
    for (final g in b.builtGames) {
      for (var r = 1; r <= GameProgress.roundsIn(g.id); r++) {
        GameProgress.instance.markRoundCleared(g.id, r, firstTry: true);
      }
    }
    expect(GameProgress.instance.stateOf(b), LessonState.cleared);
    expect(GameProgress.instance.currentLessonIn(chapter), a.id);
  });
}
