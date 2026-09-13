import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/storage/app_storage.dart';
import 'game_catalog.dart';

/// What the student has finished, held per ROUND so a sitting can be left
/// half way and picked up later.
///
/// This is a local mirror for the map and for resume. The real record is the
/// event log on the server (see game_sync.dart): every answered round is sent
/// as it happens, so quitting mid-board never loses the work, even if this
/// mirror is wiped.
class GameProgress extends ChangeNotifier {
  GameProgress._();
  static final GameProgress instance = GameProgress._();

  AppStorage? _storage;

  /// gameId -> the round numbers cleared so far.
  final Map<String, Set<int>> _rounds = {};

  /// gameId -> how many rounds were cleared on the first attempt.
  final Map<String, int> _firstTry = {};

  /// The game a round was last cleared in. The map uses it to mark the
  /// lesson the student is in the middle of.
  String? _lastGame;

  Future<void> load(AppStorage storage) async {
    _storage = storage;
    try {
      final raw = await storage.readGameProgress();
      if (raw == null) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in (data['rounds'] as Map<String, dynamic>).entries) {
        _rounds[entry.key] = {...(entry.value as List).cast<int>()};
      }
      for (final entry
          in (data['firstTry'] as Map<String, dynamic>? ?? {}).entries) {
        _firstTry[entry.key] = entry.value as int;
      }
      _lastGame = data['lastGame'] as String?;
      notifyListeners();
    } catch (_) {
      // A corrupt mirror is not worth failing a launch over: the server still
      // holds the record. Start clean.
      _rounds.clear();
      _firstTry.clear();
    }
  }

  Future<void> _save() async {
    final storage = _storage;
    if (storage == null) return;
    try {
      await storage.writeGameProgress(
        jsonEncode({
          'rounds': _rounds.map((k, v) => MapEntry(k, v.toList()..sort())),
          'firstTry': _firstTry,
          if (_lastGame != null) 'lastGame': _lastGame,
        }),
      );
    } catch (_) {
      // Local convenience only. Never surface a storage failure to the student.
    }
  }

  Set<int> roundsCleared(String gameId) => _rounds[gameId] ?? const {};

  int firstTryCount(String gameId) => _firstTry[gameId] ?? 0;

  /// True once every round of [gameId] has been cleared. The totals come from
  /// the catalog, so this is right from the first frame of a cold launch.
  bool isCleared(String gameId) {
    final total = roundsIn(gameId);
    if (total == 0) return false;
    return roundsCleared(gameId).length >= total;
  }

  /// Somewhere between untouched and finished.
  bool isStarted(String gameId) => roundsCleared(gameId).isNotEmpty;

  void markRoundCleared(String gameId, int round, {required bool firstTry}) {
    final set = _rounds.putIfAbsent(gameId, () => <int>{});
    _lastGame = gameId;
    if (set.add(round)) {
      if (firstTry) _firstTry[gameId] = (_firstTry[gameId] ?? 0) + 1;
    }
    notifyListeners();
    _save();
  }

  /// Start the whole thing over (the "play again" path).
  void reset(String gameId) {
    _rounds.remove(gameId);
    _firstTry.remove(gameId);
    notifyListeners();
    _save();
  }

  /// How many rounds each board has, read from the catalog once.
  static final Map<String, int> _roundCounts = {
    for (final chapter in chapterMaps.values)
      for (final lesson in chapter.lessons)
        for (final game in lesson.games) game.id: game.rounds,
  };

  static int roundsIn(String gameId) => _roundCounts[gameId] ?? 0;

  /// Which lesson each game belongs to, read from the catalog once.
  static final Map<String, String> _lessonOfGame = {
    for (final chapter in chapterMaps.values)
      for (final lesson in chapter.lessons)
        for (final game in lesson.games) game.id: lesson.id,
  };

  /// Which chapter each game belongs to, read from the catalog once.
  static final Map<String, String> _chapterOfGame = {
    for (final chapter in chapterMaps.values)
      for (final lesson in chapter.lessons)
        for (final game in lesson.games) game.id: chapter.id,
  };

  /// The last item a round was cleared in, if any.
  String? get lastGameId => _lastGame;

  /// The chapter the student last did anything in, if it is still unfinished.
  ChapterMap? get lastChapter {
    final id = _lastGame == null ? null : _chapterOfGame[_lastGame];
    if (id == null) return null;
    final chapter = chapterMaps[id];
    if (chapter == null) return null;
    return nextLessonIn(chapter) == null ? null : chapter;
  }

  /// What to do next in a chapter: the lesson being worked through if there
  /// is one, otherwise the first lesson not yet cleared.
  ///
  /// Null means the chapter is finished. Nothing here implies an order the
  /// map does not impose: a student can open any node, this only decides what
  /// the one Continue button on the home screen points at.
  LessonNode? nextLessonIn(ChapterMap chapter) {
    for (final lesson in chapter.lessons) {
      if (stateOf(lesson) == LessonState.inProgress) return lesson;
    }
    for (final lesson in chapter.lessons) {
      final state = stateOf(lesson);
      if (state != LessonState.cleared && state != LessonState.notBuilt) {
        return lesson;
      }
    }
    return null;
  }

  /// True once any round anywhere in [chapter] has been cleared.
  bool hasTouched(ChapterMap chapter) {
    for (final lesson in chapter.lessons) {
      for (final game in lesson.builtGames) {
        if (isStarted(game.id)) return true;
      }
    }
    return false;
  }

  /// The lesson in [chapter] the student is in the middle of, if any: the one
  /// they last played a round in while it is still unfinished, otherwise the
  /// first unfinished-but-started lesson on the path. Never a lesson they
  /// have not touched: nothing on the map locks, so pointing at an untouched
  /// node would imply an order the map does not impose.
  String? currentLessonIn(ChapterMap chapter) {
    final last = _lastGame == null ? null : _lessonOfGame[_lastGame];
    for (final lesson in chapter.lessons) {
      if (lesson.id == last && stateOf(lesson) == LessonState.inProgress) {
        return lesson.id;
      }
    }
    for (final lesson in chapter.lessons) {
      if (stateOf(lesson) == LessonState.inProgress) return lesson.id;
    }
    return null;
  }

  /// How far through a lesson's items the student is, 0 to 1.
  double fractionOf(LessonNode lesson) {
    final total = lesson.builtGames.length;
    if (total == 0) return 0;
    return clearedIn(lesson) / total;
  }

  int clearedIn(LessonNode lesson) =>
      lesson.builtGames.where((g) => isCleared(g.id)).length;

  LessonState stateOf(LessonNode lesson) {
    if (!lesson.playable) return LessonState.notBuilt;
    final done = clearedIn(lesson);
    if (done == lesson.builtGames.length) return LessonState.cleared;
    if (done > 0 || lesson.builtGames.any((g) => isStarted(g.id))) {
      return LessonState.inProgress;
    }
    return LessonState.notStarted;
  }
}

enum LessonState {
  /// Not authored yet. Said out loud rather than dressed as a locked level.
  notBuilt,
  notStarted,
  inProgress,
  cleared,
}
