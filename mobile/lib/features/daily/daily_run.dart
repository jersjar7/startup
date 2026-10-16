import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'daily_models.dart';

/// Today's Daily while it is being played: which game is up, how every round
/// has gone so far, and the clock.
///
/// The games themselves do not know about the Daily. The shared frame
/// (games/board.dart) asks this whether the game it is running is the one the
/// Daily is on, and if so plays every round fresh, reports each one here, and
/// ends on the Daily's own screens instead of the game's. That keeps all 375
/// games untouched.
///
/// Saved after every round, so leaving half way keeps your place. The clock
/// only runs while a game is on screen: reading a concept sheet first is
/// never held against anybody.
class DailyRun extends ChangeNotifier {
  DailyRun._();
  static final DailyRun instance = DailyRun._();

  static const _key = 'daily_run';

  DailyPuzzle? _puzzle;
  int _game = 0;

  /// Per game, per round: what happened to it in this Daily.
  List<List<RoundMark>> _marks = [];
  int _elapsed = 0;
  final Stopwatch _clock = Stopwatch();

  DailyPuzzle? get puzzle => _puzzle;
  int get gameIndex => _game;
  bool get started => _puzzle != null;
  bool get allDone => _puzzle != null && _game >= _puzzle!.games.length;

  DailyGame? get currentGame =>
      _puzzle == null || allDone ? null : _puzzle!.games[_game];

  int get elapsedMs => _elapsed + _clock.elapsedMilliseconds;

  bool _armed = false;

  /// Called by the Daily's own screens just before they open a game, so that
  /// game runs as part of the Daily. The same game opened from the map is an
  /// ordinary sitting.
  void arm() => _armed = true;

  /// The frame's question when a game opens: is this sitting part of the
  /// Daily? Answers once per [arm]. Returns the game's place in the Daily,
  /// or null.
  int? claim(String gameId) {
    if (!_armed) return null;
    _armed = false;
    return currentGame?.gameId == gameId ? _game : null;
  }

  /// Whether this run belongs to the given Daily.
  bool isFor(int number) => _puzzle?.number == number;

  List<RoundMark> marksOf(int game) =>
      game < _marks.length ? _marks[game] : const [];

  /// Rounds of a game already cleared in this Daily.
  Set<int> clearedIn(int game) => {
    for (var i = 0; i < marksOf(game).length; i++)
      if (marksOf(game)[i].cleared) i,
  };

  /// Rounds of a game missed and not yet cleared: no longer first tries.
  Set<int> missedIn(int game) => {
    for (var i = 0; i < marksOf(game).length; i++)
      if (marksOf(game)[i] == RoundMark.missed) i,
  };

  int firstTryIn(int game) =>
      marksOf(game).where((m) => m == RoundMark.firstTry).length;

  /// The result the server takes: one list per game, true for first try.
  List<List<bool>> get result => [
    for (final g in _marks) [for (final m in g) m == RoundMark.firstTry],
  ];

  int get score => result.fold(0, (s, g) => s + g.where((r) => r).length);

  /// Starts the Daily, or carries on with it when it was already under way.
  void begin(DailyPuzzle puzzle) {
    if (_puzzle?.number == puzzle.number &&
        _puzzle!.games.length == puzzle.games.length) {
      return;
    }
    _puzzle = puzzle;
    _game = 0;
    _marks = [
      for (final g in puzzle.games) List.filled(g.rounds, RoundMark.untouched),
    ];
    _elapsed = 0;
    _clock
      ..stop()
      ..reset();
    _save();
    notifyListeners();
  }

  /// A round of a game was answered.
  void markRound(int game, int round, {required bool ok}) {
    final marks = marksOf(game);
    if (round >= marks.length) return;
    final was = marks[round];
    if (was.cleared) return;
    marks[round] = ok
        ? (was == RoundMark.missed ? RoundMark.afterMiss : RoundMark.firstTry)
        : RoundMark.missed;
    _save();
  }

  /// A game is finished; the one after it is up. Naming the game makes a
  /// second call for the same one harmless.
  void finishGame(int game) {
    if (allDone || game != _game) return;
    _game++;
    _save();
    notifyListeners();
  }

  void startClock() {
    if (!_clock.isRunning && started && !allDone) _clock.start();
  }

  void stopClock() {
    if (!_clock.isRunning) return;
    _clock.stop();
    _elapsed += _clock.elapsedMilliseconds;
    _clock.reset();
    _save();
  }

  /// The Daily is over and its result is in hand; nothing left to resume.
  Future<void> clear() async {
    _puzzle = null;
    _game = 0;
    _marks = [];
    _elapsed = 0;
    _clock
      ..stop()
      ..reset();
    notifyListeners();
    try {
      (await SharedPreferences.getInstance()).remove(_key);
    } catch (_) {}
  }

  Future<void> load() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw == null) return;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      _puzzle = DailyPuzzle.fromJson(
        (j['puzzle'] as Map).cast<String, dynamic>(),
      );
      _game = (j['game'] as num).toInt();
      _elapsed = (j['elapsed'] as num).toInt();
      _marks = [
        for (final g in (j['marks'] as List))
          [for (final m in (g as List)) RoundMark.values[(m as num).toInt()]],
      ];
      notifyListeners();
    } catch (_) {
      // A broken save is not worth a crash: the Daily starts over.
      _puzzle = null;
    }
  }

  Future<void> _save() async {
    final p = _puzzle;
    if (p == null) return;
    try {
      (await SharedPreferences.getInstance()).setString(
        _key,
        jsonEncode({
          'puzzle': p.toJson(),
          'game': _game,
          'elapsed': _elapsed + _clock.elapsedMilliseconds,
          'marks': [
            for (final g in _marks) [for (final m in g) m.index],
          ],
        }),
      );
    } catch (_) {}
  }

  @visibleForTesting
  void debugReset() {
    _armed = false;
    _puzzle = null;
    _game = 0;
    _marks = [];
    _elapsed = 0;
    _clock
      ..stop()
      ..reset();
  }
}

enum RoundMark {
  untouched,

  /// Answered wrong and not yet cleared: it comes back, and it no longer
  /// counts as a first try.
  missed,
  firstTry,
  afterMiss;

  bool get cleared => this == firstTry || this == afterMiss;
}
