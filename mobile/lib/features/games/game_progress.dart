import 'package:flutter/foundation.dart';

import 'game_catalog.dart';

/// Prototype progress store: which games have been cleared, held in memory.
///
/// Real progress belongs on the server next to the existing spaced scheduler
/// (see docs/mobile/sync-design.md). This exists so the map can show its
/// states while the format is being designed, and it resets on app restart.
class GameProgress extends ChangeNotifier {
  GameProgress._();
  static final GameProgress instance = GameProgress._();

  final Set<String> _cleared = {};

  bool isCleared(String gameId) => _cleared.contains(gameId);

  void markCleared(String gameId) {
    if (_cleared.add(gameId)) notifyListeners();
  }

  int clearedIn(LessonNode lesson) =>
      lesson.builtGames.where((g) => _cleared.contains(g.id)).length;

  LessonState stateOf(LessonNode lesson) {
    if (!lesson.playable) return LessonState.notBuilt;
    final done = clearedIn(lesson);
    if (done == 0) return LessonState.notStarted;
    if (done < lesson.builtGames.length) return LessonState.inProgress;
    return LessonState.cleared;
  }
}

enum LessonState {
  /// Games for this lesson have not been authored yet. Said out loud.
  notBuilt,
  notStarted,
  inProgress,
  cleared,
}
