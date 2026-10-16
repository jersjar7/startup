/// What the server says about the Daily (service/routes/daily.js). Plain
/// values, parsed once, so the screens never read a map.
library;

class DailyGame {
  const DailyGame({
    required this.chapterId,
    required this.gameId,
    required this.rounds,
  });

  factory DailyGame.fromJson(Map<String, dynamic> j) => DailyGame(
    chapterId: j['chapterId'] as String,
    gameId: j['gameId'] as String,
    rounds: (j['rounds'] as num).toInt(),
  );

  final String chapterId;
  final String gameId;
  final int rounds;

  Map<String, dynamic> toJson() => {
    'chapterId': chapterId,
    'gameId': gameId,
    'rounds': rounds,
  };
}

class DailyStreak {
  const DailyStreak({
    required this.current,
    required this.best,
    required this.playedToday,
  });

  factory DailyStreak.fromJson(Map<String, dynamic>? j) => DailyStreak(
    current: (j?['current'] as num?)?.toInt() ?? 0,
    best: (j?['best'] as num?)?.toInt() ?? 0,
    playedToday: j?['playedToday'] as bool? ?? false,
  );

  static const none = DailyStreak(current: 0, best: 0, playedToday: false);

  final int current;
  final int best;
  final bool playedToday;

  Map<String, dynamic> toJson() => {
    'current': current,
    'best': best,
    'playedToday': playedToday,
  };
}

/// Your own result: one list per game, one entry per round, true when it was
/// right on the first try.
class DailyMine {
  const DailyMine({
    required this.score,
    required this.total,
    required this.ms,
    required this.rounds,
  });

  factory DailyMine.fromJson(Map<String, dynamic> j) => DailyMine(
    score: (j['score'] as num).toInt(),
    total: (j['total'] as num).toInt(),
    ms: (j['ms'] as num).toInt(),
    rounds: [
      for (final g in (j['rounds'] as List? ?? const []))
        [for (final r in (g as List)) r == true],
    ],
  );

  final int score;
  final int total;
  final int ms;
  final List<List<bool>> rounds;

  Map<String, dynamic> toJson() => {
    'score': score,
    'total': total,
    'ms': ms,
    'rounds': rounds,
  };
}

class DailyPuzzle {
  const DailyPuzzle({
    required this.number,
    required this.date,
    required this.games,
    required this.total,
    required this.mine,
    required this.streak,
  });

  factory DailyPuzzle.fromJson(Map<String, dynamic> j) => DailyPuzzle(
    number: (j['number'] as num).toInt(),
    date: j['date'] as String,
    games: [
      for (final g in (j['games'] as List))
        DailyGame.fromJson((g as Map).cast<String, dynamic>()),
    ],
    total: (j['total'] as num).toInt(),
    mine: j['mine'] is Map
        ? DailyMine.fromJson((j['mine'] as Map).cast<String, dynamic>())
        : null,
    streak: DailyStreak.fromJson(
      (j['streak'] as Map?)?.cast<String, dynamic>(),
    ),
  );

  final int number;
  final String date;
  final List<DailyGame> games;
  final int total;
  final DailyMine? mine;
  final DailyStreak streak;

  DailyPuzzle copyWith({DailyMine? mine, DailyStreak? streak}) => DailyPuzzle(
    number: number,
    date: date,
    games: games,
    total: total,
    mine: mine ?? this.mine,
    streak: streak ?? this.streak,
  );

  Map<String, dynamic> toJson() => {
    'number': number,
    'date': date,
    'games': [for (final g in games) g.toJson()],
    'total': total,
    if (mine != null) 'mine': mine!.toJson(),
    'streak': streak.toJson(),
  };
}

class DailyPlace {
  const DailyPlace({
    required this.rank,
    required this.name,
    required this.score,
    required this.ms,
    required this.isYou,
  });

  factory DailyPlace.fromJson(Map<String, dynamic> j) => DailyPlace(
    rank: (j['rank'] as num).toInt(),
    name: j['name'] as String? ?? '',
    score: (j['score'] as num).toInt(),
    ms: (j['ms'] as num).toInt(),
    isYou: j['isYou'] as bool? ?? false,
  );

  final int rank;
  final String name;
  final int score;
  final int ms;
  final bool isYou;
}

class DailyMe {
  const DailyMe({
    required this.rank,
    required this.score,
    required this.total,
    required this.ms,
    required this.beat,
  });

  factory DailyMe.fromJson(Map<String, dynamic> j) => DailyMe(
    rank: (j['rank'] as num).toInt(),
    score: (j['score'] as num).toInt(),
    total: (j['total'] as num?)?.toInt() ?? 0,
    ms: (j['ms'] as num).toInt(),
    beat: (j['beat'] as num?)?.toInt(),
  );

  final int rank;
  final int score;
  final int total;
  final int ms;

  /// Percent of the other players you finished ahead of. Null when you are
  /// the only one.
  final int? beat;
}

/// One board: everyone, or one school.
class DailyBoard {
  const DailyBoard({
    required this.players,
    required this.distribution,
    required this.top,
    required this.me,
  });

  factory DailyBoard.fromJson(Map<String, dynamic> j) => DailyBoard(
    players: (j['players'] as num?)?.toInt() ?? 0,
    distribution: {
      for (final e in ((j['distribution'] as Map?) ?? const {}).entries)
        int.parse('${e.key}'): (e.value as num).toInt(),
    },
    top: [
      for (final t in (j['top'] as List? ?? const []))
        DailyPlace.fromJson((t as Map).cast<String, dynamic>()),
    ],
    me: j['me'] is Map
        ? DailyMe.fromJson((j['me'] as Map).cast<String, dynamic>())
        : null,
  );

  final int players;

  /// score -> how many players got it.
  final Map<int, int> distribution;
  final List<DailyPlace> top;
  final DailyMe? me;
}

class DailySchool {
  const DailySchool({
    required this.name,
    required this.players,
    required this.needs,
    required this.board,
  });

  factory DailySchool.fromJson(Map<String, dynamic> j) => DailySchool(
    name: j['name'] as String? ?? 'Your school',
    players: (j['players'] as num?)?.toInt() ?? 0,
    needs: (j['needs'] as num?)?.toInt() ?? 5,
    board: j['board'] is Map
        ? DailyBoard.fromJson((j['board'] as Map).cast<String, dynamic>())
        : null,
  );

  final String name;
  final int players;
  final int needs;

  /// Null until enough students from the school play the same day.
  final DailyBoard? board;

  bool get open => board != null;
}

class DailyResults {
  const DailyResults({required this.everyone, required this.school});

  factory DailyResults.fromJson(Map<String, dynamic> j) => DailyResults(
    everyone: DailyBoard.fromJson(j),
    school: j['school'] is Map
        ? DailySchool.fromJson((j['school'] as Map).cast<String, dynamic>())
        : null,
  );

  final DailyBoard everyone;
  final DailySchool? school;
}

/// "2:41". Minutes and seconds, the way a clock shows it.
String clockOf(int ms) {
  final s = (ms / 1000).round();
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final sec = (s % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$sec' : '$m:$sec';
}
