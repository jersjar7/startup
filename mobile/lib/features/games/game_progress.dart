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
        }),
      );
    } catch (_) {
      // Local convenience only. Never surface a storage failure to the student.
    }
  }

  Set<int> roundsCleared(String gameId) => _rounds[gameId] ?? const {};

  int firstTryCount(String gameId) => _firstTry[gameId] ?? 0;

  /// True once every round of [gameId] has been cleared.
  bool isCleared(String gameId) {
    final total = _totalRounds[gameId];
    if (total == null) return false;
    return roundsCleared(gameId).length >= total;
  }

  /// Somewhere between untouched and finished.
  bool isStarted(String gameId) => roundsCleared(gameId).isNotEmpty;

  void markRoundCleared(String gameId, int round, {required bool firstTry}) {
    final set = _rounds.putIfAbsent(gameId, () => <int>{});
    if (set.add(round)) {
      if (firstTry) _firstTry[gameId] = (_firstTry[gameId] ?? 0) + 1;
      notifyListeners();
      _save();
    }
  }

  /// Start the whole thing over (the "play again" path).
  void reset(String gameId) {
    _rounds.remove(gameId);
    _firstTry.remove(gameId);
    notifyListeners();
    _save();
  }

  /// How many rounds each board has, registered by the game screens so the map
  /// can tell "half done" from "done" without knowing what a round is.
  static final Map<String, int> _totalRounds = {};
  static void registerRounds(String gameId, int total) =>
      _totalRounds[gameId] = total;

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
