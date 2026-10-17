import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_exception.dart';
import '../../core/notifications/notifications.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../games/board.dart';
import '../games/game_catalog.dart';
import '../games/game_progress.dart';
import '../shared/widgets/kit.dart';
import '../study/chapter_marks.dart';
import '../study/study_tab.dart' show appClock;
import 'daily_models.dart';
import 'daily_repository.dart';
import 'daily_run.dart';
import 'daily_share.dart';
import 'daily_widgets.dart';

/// Tab 3, the Daily: three whole games from three chapters, the same for
/// every student today, played once (owner's call, 2026-10-15).
///
/// Before you play it shows today's three games, one button and your streak.
/// After, it shows how everyone did: how many got each score, the top two
/// and you. Your school's board joins once enough of its students play the
/// same day. On a butter ground, so it never looks like Profile.
class DailyTab extends StatefulWidget {
  const DailyTab({super.key, this.visible = true});

  /// Whether the tab is the one on screen. Coming into view reloads it, so
  /// a new day, or a Daily just finished, is never shown stale.
  final bool visible;

  @override
  State<DailyTab> createState() => _DailyTabState();
}

class _DailyTabState extends State<DailyTab> {
  DailyPuzzle? _puzzle;
  DailyResults? _results;
  bool _loading = true;
  bool _failed = false;

  /// The failure was the server saying no, not the phone having no signal.
  bool _refused = false;
  bool _resultsFailed = false;
  bool _runLoaded = false;
  int _board = 0; // 0 everyone, 1 school

  @override
  void initState() {
    super.initState();
    DailyRun.instance.addListener(_onRun);
    DailyRepository.played.addListener(_load);
    _load();
  }

  @override
  void didUpdateWidget(DailyTab old) {
    super.didUpdateWidget(old);
    if (widget.visible && !old.visible) _load();
  }

  @override
  void dispose() {
    DailyRun.instance.removeListener(_onRun);
    DailyRepository.played.removeListener(_load);
    super.dispose();
  }

  /// The run changes from inside other screens' builds (a game claiming its
  /// Daily slot, a finished game handing back), so a change that lands
  /// mid-build waits for the frame to finish instead of asking to rebuild
  /// during it. Found by the Daily walk-throughs (TEST-JOURNEYS.md).
  void _onRun() {
    if (!mounted) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  Future<void> _load() async {
    final repo = DailyRepository.of(context);
    if (!_runLoaded) {
      _runLoaded = true;
      await DailyRun.instance.load();
    }
    if (_puzzle == null && mounted) setState(() => _loading = true);
    await repo.sendPending();
    try {
      var puzzle = await repo.today(appClock());
      // A result still waiting to be sent is played all the same.
      final kept = await repo.pending();
      if (puzzle.mine == null &&
          kept != null &&
          kept['number'] == puzzle.number) {
        final rounds = [
          for (final g in kept['rounds'] as List)
            [for (final r in g as List) r == true],
        ];
        puzzle = puzzle.copyWith(
          mine: DailyMine(
            score: rounds.fold(0, (s, g) => s + g.where((r) => r).length),
            total: rounds.fold(0, (s, g) => s + g.length),
            ms: (kept['ms'] as num).toInt(),
            rounds: rounds,
          ),
        );
      }
      DailyResults? results;
      var resultsFailed = false;
      if (puzzle.mine != null) {
        try {
          results = await repo.results(puzzle.number);
        } catch (_) {
          resultsFailed = true;
        }
      }
      Notifications().dailyState(
        lastPlayedDay: puzzle.mine != null ? puzzle.date : null,
        streak: puzzle.streak.current,
      );
      if (!mounted) return;
      setState(() {
        _puzzle = puzzle;
        _results = results;
        _resultsFailed = resultsFailed;
        _failed = false;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _failed = _puzzle == null;
        _refused = e is ApiException && !e.isNetwork;
        _loading = false;
      });
    }
  }

  /// Every game in today's Daily is one this phone has, with the same rounds.
  /// A phone on an older version may not, and then it has to say so rather
  /// than play a different puzzle from everybody else.
  bool _playable(DailyPuzzle p) => p.games.every(
    (g) =>
        (gameDefFor(g.gameId)?.built ?? false) &&
        GameProgress.roundsIn(g.gameId) == g.rounds,
  );

  void _play(DailyPuzzle puzzle) {
    final run = DailyRun.instance..begin(puzzle);
    if (run.allDone) {
      context.push('/daily/done');
    } else {
      context.push('/daily/step');
    }
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = _puzzle;
    // Off screen in the shell's stack: nothing here should keep animating.
    return TickerMode(
      enabled: widget.visible,
      child: Material(
        color: AppColors.butter,
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppColors.charcoal,
            backgroundColor: AppColors.cream,
            onRefresh: _load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16,
                22,
                16,
                30 + MediaQuery.paddingOf(context).bottom,
              ),
              child: puzzle == null
                  ? _Waiting(
                      failed: _failed,
                      refused: _refused,
                      loading: _loading,
                      onRetry: _load,
                    )
                  : puzzle.mine == null
                  ? _Today(
                      puzzle: puzzle,
                      playable: _playable(puzzle),
                      run: DailyRun.instance.isFor(puzzle.number)
                          ? DailyRun.instance
                          : null,
                      onPlay: () => _play(puzzle),
                    )
                  : _Results(
                      puzzle: puzzle,
                      results: _results,
                      failed: _resultsFailed,
                      board: _board,
                      onBoard: (i) => setState(() => _board = i),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _dayLine(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return '';
  return '${_weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';
}

/// Before the first answer from the server, or when there is none.
class _Waiting extends StatelessWidget {
  const _Waiting({
    required this.failed,
    required this.refused,
    required this.loading,
    required this.onRetry,
  });

  final bool failed;
  final bool refused;
  final bool loading;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _dayLine(DateTime.now().toIso8601String()).toUpperCase(),
          style: AppTheme.eyebrow(),
        ),
        const SizedBox(height: 10),
        Text('Today\'s Daily', style: AppTheme.display(size: 44)),
        const SizedBox(height: 22),
        Container(
          height: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(36),
          ),
          child: failed && !loading
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      refused ? 'NOT OPEN YET' : 'NO SIGNAL',
                      style: AppTheme.eyebrow(),
                    ),
                    const Spacer(),
                    Text(
                      refused
                          ? 'Today\'s Daily is not open yet.'
                          : 'Today\'s Daily comes from the server, once a day.',
                      style: AppTheme.display(size: 26, height: 1.1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      refused
                          ? 'Check the date on your phone, then try again in '
                                'a minute.'
                          : 'Once they are on the phone they play without a '
                                'signal. Try again when you have one.',
                      style: AppTheme.body(
                        size: 15,
                        color: AppColors.mutedOnLight,
                      ),
                    ),
                    const SizedBox(height: 18),
                    PillButton(label: 'Try again', onTap: onRetry),
                  ],
                )
              : const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

/// Today's three games, the button and the streak.
class _Today extends StatelessWidget {
  const _Today({
    required this.puzzle,
    required this.playable,
    required this.run,
    required this.onPlay,
  });

  final DailyPuzzle puzzle;
  final bool playable;

  /// Today's run when one is under way.
  final DailyRun? run;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final minutes = (puzzle.total / 6).round().clamp(1, 9);
    final going = run != null && run!.started;
    final label = going
        ? 'Pick up concept ${run!.gameIndex + 1} of ${puzzle.games.length}'
        : 'Play today\'s';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_dayLine(puzzle.date).toUpperCase(), style: AppTheme.eyebrow()),
        const SizedBox(height: 10),
        Text('Today\'s Daily', style: AppTheme.display(size: 44)),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(36),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('SAME FOR EVERYONE', style: AppTheme.eyebrow()),
              const SizedBox(height: 6),
              // The payoff, said before playing: it is only shown after, so
              // a newcomer could not know it was coming (owner, 2026-10-16).
              Text(
                'Play, then see how you did against everyone else today.',
                style: AppTheme.body(size: 14, color: AppColors.mutedOnLight),
              ),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  text: '${puzzle.games.length}',
                  style: AppTheme.display(
                    size: 84,
                    height: 0.82,
                    tracking: -0.06,
                  ),
                  children: [
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: 'concepts, about $minutes min',
                      style: AppTheme.display(
                        size: 22,
                        weight: FontWeight.w700,
                        tracking: -0.02,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < puzzle.games.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _GameRow(
                  game: puzzle.games[i],
                  done: going && i < run!.gameIndex,
                ),
              ],
              const SizedBox(height: 16),
              if (playable)
                PillButton(label: label, onTap: onPlay)
              else
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.peach,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Today\'s Daily has a concept this version of the app does '
                    'not have yet. Update the app to play it.',
                    style: AppTheme.body(size: 15),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        StreakTile(
          current: puzzle.streak.current,
          playedToday: puzzle.streak.playedToday,
        ),
      ],
    );
  }
}

class _GameRow extends StatelessWidget {
  const _GameRow({required this.game, required this.done, this.onAgain});

  final DailyGame game;
  final bool done;

  /// After the Daily: plays the game again as ordinary practice.
  final VoidCallback? onAgain;

  @override
  Widget build(BuildContext context) {
    final def = gameDefFor(game.gameId);
    final chapter = chapterMaps[game.chapterId];
    return Container(
      height: 64,
      padding: const EdgeInsets.fromLTRB(10, 0, 16, 0),
      decoration: BoxDecoration(
        color: done ? AppColors.springField : AppColors.creamDark,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: done ? AppColors.charcoal : AppColors.fog,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: done
                  ? const Icon(
                      Icons.check_rounded,
                      size: 22,
                      color: AppColors.springOnDark,
                    )
                  : ChapterMark(
                      chapterId: game.chapterId,
                      color: AppColors.charcoal,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  def?.name ?? game.gameId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.display(
                    size: 16,
                    weight: FontWeight.w700,
                    height: 1.15,
                    tracking: -0.02,
                  ),
                ),
                Text(
                  chapter?.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.body(
                    size: 12.5,
                    weight: FontWeight.w500,
                    color: AppColors.mutedOnLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (onAgain != null)
            TextAction(label: 'Play again', onTap: onAgain!)
          else
            Text(
              '${game.rounds}',
              style: AppTheme.mono(size: 12, color: AppColors.mutedOnLight),
            ),
        ],
      ),
    );
  }
}

/// After you play: how everyone did.
class _Results extends StatelessWidget {
  const _Results({
    required this.puzzle,
    required this.results,
    required this.failed,
    required this.board,
    required this.onBoard,
  });

  final DailyPuzzle puzzle;
  final DailyResults? results;
  final bool failed;
  final int board;
  final ValueChanged<int> onBoard;

  @override
  Widget build(BuildContext context) {
    final mine = puzzle.mine!;
    final school = results?.school;
    final showing = board == 1 && school?.board != null
        ? school!.board!
        : results?.everyone;
    final me = showing?.me;

    final String headline;
    if (showing == null) {
      headline = '${mine.score} of ${mine.total} today';
    } else if (showing.players <= 1) {
      headline = 'First one in today';
    } else if (me?.rank == 1) {
      headline = 'Top of the board today';
    } else {
      headline = 'You beat ${me?.beat ?? 0}% today';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          showing == null
              ? 'TODAY\'S DAILY'
              : 'TODAY\'S DAILY · ${showing.players} PLAYED',
          style: AppTheme.eyebrow(),
        ),
        const SizedBox(height: 10),
        Text(headline, style: AppTheme.display(size: 44)),
        if (school != null) ...[
          const SizedBox(height: 18),
          Row(
            children: [
              _Chip(
                label: 'Everyone',
                on: board == 0 || !school.open,
                onTap: () => onBoard(0),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: _Chip(
                  label: school.open
                      ? school.name
                      : '${school.name}, at ${school.needs} players',
                  on: board == 1 && school.open,
                  enabled: school.open,
                  onTap: () => onBoard(1),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        if (showing != null) ...[
          _Spread(board: showing, total: mine.total, mine: mine.score),
          const SizedBox(height: 10),
          for (final p in _rows(showing)) ...[
            _Place(
              rank: p.rank,
              name: p.isYou ? 'You' : p.name,
              score: p.score,
              ms: p.ms,
              you: p.isYou,
            ),
            const SizedBox(height: 6),
          ],
        ] else
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DailyBars(rows: mine.rounds, missed: AppColors.peach),
                const SizedBox(height: 14),
                Text(
                  failed
                      ? 'How everyone did shows once you are back online.'
                      : 'Your score goes up the next time you have a signal.',
                  style: AppTheme.body(size: 14, color: AppColors.mutedOnLight),
                ),
              ],
            ),
          ),
        if (school != null && !school.open) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '${school.name}\'s board opens once ${school.needs} students '
              'from it play the same day. ${school.players} so far today.',
              style: AppTheme.body(size: 13, color: AppColors.mutedOnLight),
            ),
          ),
        ],
        const SizedBox(height: 18),
        StreakTile(current: puzzle.streak.current, playedToday: true),
        const SizedBox(height: 22),
        // Replays are plain practice: opened like any game from Study, never
        // armed for the Daily, so the first try stays the one on the board
        // (owner, 2026-10-16).
        Text('TODAY\'S CONCEPTS', style: AppTheme.eyebrow()),
        const SizedBox(height: 6),
        Text(
          'Play them again as practice. Your first try is the one that counts.',
          style: AppTheme.body(size: 14, color: AppColors.mutedOnLight),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < puzzle.games.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _GameRow(
            game: puzzle.games[i],
            done: false,
            onAgain: () {
              final id = puzzle.games[i].gameId;
              BoardSession.playFresh(id);
              context.push('/games/play/$id');
            },
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            TextAction(
              label: 'Share your result',
              onTap: () =>
                  showDailyShare(context, date: puzzle.date, mine: mine),
            ),
            const Spacer(),
            Text(
              'NEXT ONE AT MIDNIGHT',
              style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
            ),
          ],
        ),
      ],
    );
  }

  /// The top names, then you when you are not already among them.
  List<DailyPlace> _rows(DailyBoard b) {
    final rows = [...b.top];
    final me = b.me;
    if (me != null && !rows.any((r) => r.isYou)) {
      rows.add(
        DailyPlace(
          rank: me.rank,
          name: 'You',
          score: me.score,
          ms: me.ms,
          isYou: true,
        ),
      );
    }
    return rows;
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.on,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final bool on;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: enabled,
      selected: on,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: on ? AppColors.charcoal : AppColors.creamDark,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.display(
                    size: 15,
                    weight: FontWeight.w700,
                    height: 1,
                    tracking: -0.01,
                    color: on
                        ? AppColors.cream
                        : enabled
                        ? AppColors.charcoal
                        : AppColors.mutedOnLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// How the scores spread: one bar per score, the longest the most common,
/// yours dark. Six rows at most; the tail is folded into the last.
class _Spread extends StatelessWidget {
  const _Spread({required this.board, required this.total, required this.mine});

  final DailyBoard board;
  final int total;
  final int mine;

  @override
  Widget build(BuildContext context) {
    final scores = board.distribution.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    final rows = <(String, int, bool)>[];
    for (var i = 0; i < scores.length; i++) {
      final s = scores[i];
      if (i == 5 && scores.length > 6) {
        final rest = scores.sublist(5);
        rows.add((
          '≤$s',
          rest.fold(0, (n, r) => n + board.distribution[r]!),
          rest.contains(mine),
        ));
        break;
      }
      rows.add(('$s', board.distribution[s]!, s == mine));
    }
    final most = rows.fold(1, (m, r) => r.$2 > m ? r.$2 : m);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FIRST TRY, OUT OF $total',
            style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
          ),
          const SizedBox(height: 14),
          for (final r in rows) ...[
            Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(r.$1, style: AppTheme.mono(size: 12)),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (_, box) => Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: (box.maxWidth * r.$2 / most).clamp(
                          28,
                          box.maxWidth,
                        ),
                        height: 20,
                        padding: const EdgeInsets.only(right: 8),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: r.$3
                              ? AppColors.charcoal
                              : AppColors.creamDark,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${r.$2}',
                          style: AppTheme.mono(
                            size: 11,
                            weight: FontWeight.w600,
                            color: r.$3 ? AppColors.cream : AppColors.charcoal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _Place extends StatelessWidget {
  const _Place({
    required this.rank,
    required this.name,
    required this.score,
    required this.ms,
    required this.you,
  });

  final int rank;
  final String name;
  final int score;
  final int ms;
  final bool you;

  @override
  Widget build(BuildContext context) {
    final muted = you ? AppColors.mutedOnDark : AppColors.mutedOnLight;
    final ink = you ? AppColors.cream : AppColors.charcoal;
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: you ? AppColors.charcoal : AppColors.cream,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              '$rank',
              style: AppTheme.mono(
                size: 13,
                weight: FontWeight.w600,
                color: muted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.body(
                size: 14.5,
                weight: FontWeight.w500,
                color: ink,
              ),
            ),
          ),
          Text('$score', style: AppTheme.mono(size: 12.5, color: ink)),
          SizedBox(
            width: 52,
            child: Text(
              clockOf(ms),
              textAlign: TextAlign.right,
              style: AppTheme.mono(size: 12.5, color: muted),
            ),
          ),
        ],
      ),
    );
  }
}
