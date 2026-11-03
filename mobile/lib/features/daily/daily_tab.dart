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
import 'daily_board.dart';
import 'daily_calendar.dart';
import 'daily_models.dart';
import 'daily_repository.dart';
import 'daily_run.dart';
import 'daily_share.dart';
import 'daily_widgets.dart';
import 'daily_yesterday.dart';

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

  /// Yesterday's final board, kept only when this student is on it: the
  /// "Yesterday's score" link shows for nobody else.
  DailyResults? _yesterday;
  int? _yesterdayNumber;

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
      // Yesterday's board, asked for alongside today's: the number before
      // today's, by the same local calendar.
      final yesterdayNumber = puzzle.number - 1;
      final yesterdayAsk = yesterdayNumber >= 1
          ? repo
                .results(yesterdayNumber)
                .then<DailyResults?>((r) => r, onError: (_) => null)
          : Future<DailyResults?>.value();
      DailyResults? results;
      var resultsFailed = false;
      if (puzzle.mine != null) {
        try {
          results = await repo.results(puzzle.number);
        } catch (_) {
          resultsFailed = true;
        }
      }
      final asked = await yesterdayAsk;
      // No answer (no signal): keep the board already shown for that day.
      final yesterday = asked == null
          ? (_yesterdayNumber == yesterdayNumber ? _yesterday : null)
          : (asked.everyone.me != null ? asked : null);
      Notifications().dailyState(
        // Played yesterday is enough for the morning reminder to point at
        // yesterday's board, even before today's is played.
        lastPlayedDay: puzzle.mine != null
            ? puzzle.date
            : yesterday != null
            ? dayBefore(puzzle.date)
            : null,
        streak: puzzle.streak.current,
      );
      if (!mounted) return;
      setState(() {
        _puzzle = puzzle;
        _results = results;
        _resultsFailed = resultsFailed;
        _yesterday = yesterday;
        _yesterdayNumber = yesterdayNumber;
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

  void _openYesterday(DailyPuzzle puzzle, DailyResults board) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            DailyYesterdayScreen(date: dayBefore(puzzle.date), results: board),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = _puzzle;
    final yesterday = _yesterday;
    final onYesterday = puzzle == null || yesterday == null
        ? null
        : () => _openYesterday(puzzle, yesterday);
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
                      onYesterday: onYesterday,
                    )
                  : _Results(
                      puzzle: puzzle,
                      results: _results,
                      failed: _resultsFailed,
                      board: _board,
                      onBoard: (i) => setState(() => _board = i),
                      onYesterday: onYesterday,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

String _dayLine(String iso) => dailyDayLine(iso);

/// The date or board eyebrow over the screen's headline, with the
/// "Yesterday's score" link at the top right when there is a board to show.
///
/// The link sits over the heading rather than in a row of its own, so the
/// heading never moves when it appears. Its touch target reaches down into
/// the gap and the headline's first line, which take no taps.
class _Heading extends StatelessWidget {
  const _Heading({
    required this.eyebrow,
    required this.headline,
    required this.onYesterday,
  });

  final String eyebrow;
  final String headline;
  final VoidCallback? onYesterday;

  @override
  Widget build(BuildContext context) {
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(right: onYesterday == null ? 0 : 128),
          child: Text(
            eyebrow,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.eyebrow(),
          ),
        ),
        const SizedBox(height: 10),
        Text(headline, style: AppTheme.display(size: 44)),
      ],
    );
    if (onYesterday == null) return column;
    return Stack(
      children: [
        column,
        Positioned(
          top: 0,
          right: 0,
          child: _YesterdayLink(onTap: onYesterday!),
        ),
      ],
    );
  }
}

/// Small and light on purpose, so it never competes with the headline
/// (owner, 2026-11-02).
class _YesterdayLink extends StatelessWidget {
  const _YesterdayLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              'Yesterday\'s score',
              style:
                  AppTheme.body(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.mutedOnLight,
                    height: 1.2,
                  ).copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.mutedOnLight,
                  ),
            ),
          ),
        ),
      ),
    );
  }
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
    this.guest = false,
    this.onYesterday,
  });

  final DailyPuzzle puzzle;
  final bool playable;

  /// No account: today's concepts are shown, and the button asks for one.
  final bool guest;

  /// Today's run when one is under way.
  final DailyRun? run;
  final VoidCallback onPlay;

  /// Opens yesterday's final board; null hides the link.
  final VoidCallback? onYesterday;

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
        _Heading(
          eyebrow: _dayLine(puzzle.date).toUpperCase(),
          headline: 'Today\'s Daily',
          onYesterday: onYesterday,
        ),
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
              if (guest)
                const _GuestPlay()
              else if (playable)
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
        if (guest)
          const _GuestWhy()
        else
          StreakTile(
            current: puzzle.streak.current,
            playedToday: puzzle.streak.playedToday,
          ),
      ],
    );
  }
}

// ───────────────────────────── a guest's Daily ─────────────────────

/// The Daily for somebody using the app without an account (Apple
/// 5.1.1(v)). The Daily ranks a result against everyone who played and
/// keeps a streak, so playing it needs an account; today's three concepts
/// are shown anyway, from the public preview, and every one of them is in
/// Study for free.
class GuestDailyTab extends StatefulWidget {
  const GuestDailyTab({super.key});

  @override
  State<GuestDailyTab> createState() => _GuestDailyTabState();
}

class _GuestDailyTabState extends State<GuestDailyTab> {
  DailyPuzzle? _puzzle;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    DailyPuzzle? puzzle;
    try {
      puzzle = await DailyRepository.of(context).preview(appClock());
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _puzzle = puzzle ?? _puzzle;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = _puzzle;
    return Material(
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
            child: puzzle != null
                ? _Today(
                    puzzle: puzzle,
                    playable: false,
                    run: null,
                    onPlay: () {},
                    guest: true,
                  )
                : _GuestNoPreview(loading: _loading),
          ),
        ),
      ),
    );
  }
}

/// Without a signal there is no list of today's concepts, but what the
/// Daily is and what it needs still stand.
class _GuestNoPreview extends StatelessWidget {
  const _GuestNoPreview({required this.loading});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _dayLine(appClock().toIso8601String()).toUpperCase(),
          style: AppTheme.eyebrow(),
        ),
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
              Text(
                'Three concepts a day, then see how you did against everyone '
                'else today.',
                style: AppTheme.body(size: 14, color: AppColors.mutedOnLight),
              ),
              const SizedBox(height: 22),
              if (loading)
                const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.charcoal,
                    ),
                  ),
                )
              else
                const _GuestPlay(),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const _GuestWhy(),
      ],
    );
  }
}

class _GuestPlay extends StatelessWidget {
  const _GuestPlay();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PillButton(
          label: 'Sign up to play',
          onTap: () => context.push('/create'),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have one?',
              style: AppTheme.body(size: 14, color: AppColors.mutedOnLight),
            ),
            TextAction(label: 'Sign in', onTap: () => context.push('/signin')),
          ],
        ),
      ],
    );
  }
}

class _GuestWhy extends StatelessWidget {
  const _GuestWhy();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.charcoal.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        'The Daily ranks you against everyone who played today and keeps '
        'your streak, so it needs an account. These concepts are in Study, '
        'free to play now.',
        style: AppTheme.body(size: 14, height: 1.45),
      ),
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
                  // The concept as the website names it; the mark beside it
                  // already says the chapter (owner, 2026-10-17).
                  lessonForGame(game.gameId)?.name ?? chapter?.name ?? '',
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
    this.onYesterday,
  });

  final DailyPuzzle puzzle;
  final DailyResults? results;
  final bool failed;
  final int board;
  final ValueChanged<int> onBoard;

  /// Opens yesterday's final board; null hides the link.
  final VoidCallback? onYesterday;

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
        _Heading(
          eyebrow: showing == null
              ? 'TODAY\'S DAILY'
              : 'TODAY\'S DAILY · ${showing.players} PLAYED',
          headline: headline,
          onYesterday: onYesterday,
        ),
        if (school != null) ...[
          const SizedBox(height: 18),
          DailyBoardChips(school: school, board: board, onBoard: onBoard),
        ],
        const SizedBox(height: 12),
        if (showing != null) ...[
          DailyStandings(board: showing, total: mine.total, mine: mine.score),
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
}
