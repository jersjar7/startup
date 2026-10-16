import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/notifications/notifications.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../games/game_catalog.dart';
import '../home/home_shell.dart';
import '../shared/widgets/kit.dart';
import 'daily_models.dart';
import 'daily_repository.dart';
import 'daily_run.dart';
import 'daily_share.dart';
import 'daily_widgets.dart';

/// The end of the Daily: the same done screen the games use (reference 13c),
/// with the score as the hero, the rounds as bars, the time and the streak.
///
/// The result is sent the moment this opens. Without a signal it is kept on
/// the phone and sent next time, and the screen says so.
class DailyDoneScreen extends StatefulWidget {
  const DailyDoneScreen({super.key});

  @override
  State<DailyDoneScreen> createState() => _DailyDoneScreenState();
}

class _DailyDoneScreenState extends State<DailyDoneScreen> {
  DailyPuzzle? _puzzle;
  late DailyMine _mine;
  DailyStreak? _streak;
  bool _sending = true;
  bool _kept = false;

  @override
  void initState() {
    super.initState();
    final run = DailyRun.instance;
    _puzzle = run.puzzle;
    final rounds = run.result;
    _mine = DailyMine(
      score: run.score,
      total: rounds.fold(0, (s, g) => s + g.length),
      ms: run.elapsedMs,
      rounds: rounds,
    );
    if (_puzzle != null) _send();
  }

  Future<void> _send() async {
    final puzzle = _puzzle!;
    final repo = DailyRepository.of(context);
    final sent = await repo.submit(
      number: puzzle.number,
      date: puzzle.date,
      rounds: _mine.rounds,
      ms: _mine.ms,
    );
    // Played either way: the result is safe, on the server or on the phone.
    await DailyRun.instance.clear();
    final streak =
        sent?.streak ??
        DailyStreak(
          current: puzzle.streak.playedToday
              ? puzzle.streak.current
              : puzzle.streak.current + 1,
          best: puzzle.streak.best,
          playedToday: true,
        );
    Notifications().dailyState(
      lastPlayedDay: puzzle.date,
      streak: streak.current,
    );
    if (!mounted) return;
    setState(() {
      _sending = false;
      _kept = sent == null;
      if (sent != null) _mine = sent.mine;
      _streak = streak;
    });
  }

  void _close() {
    HomeShell.select(HomeTab.daily);
    context.canPop() ? context.pop() : context.go('/home');
  }

  /// "You missed one in Statics and two in Surveying, and they all came
  /// back." Said by chapter, because that is what a student remembers.
  String _line(DailyPuzzle puzzle) {
    if (_mine.score == _mine.total) return 'Every one on the first try.';
    const words = ['none', 'one', 'two', 'three', 'four', 'five', 'six'];
    final parts = <String>[];
    var missed = 0;
    for (var g = 0; g < _mine.rounds.length && g < puzzle.games.length; g++) {
      final n = _mine.rounds[g].where((r) => !r).length;
      if (n == 0) continue;
      missed += n;
      final chapter = chapterMaps[puzzle.games[g].chapterId]?.name ?? 'a game';
      parts.add('${n < words.length ? words[n] : '$n'} in $chapter');
    }
    final list = parts.length <= 1
        ? parts.join()
        : '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
    final back = missed == 1 ? 'it came back' : 'they all came back';
    return 'On the first try. You missed $list, and $back.';
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = _puzzle;
    if (puzzle == null) {
      return const Scaffold(backgroundColor: AppColors.fog);
    }
    final streak = _streak;

    return Scaffold(
      backgroundColor: AppColors.fog,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  RoundIconButton(
                    icon: Icons.close_rounded,
                    label: 'Close',
                    onTap: _close,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.spring,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('TODAY\'S DAILY', style: AppTheme.eyebrow()),
                        const Spacer(),
                        Text('DONE', style: AppTheme.eyebrow()),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Text.rich(
                      TextSpan(
                        text: '${_mine.score}',
                        style: AppTheme.display(
                          size: 112,
                          height: 0.8,
                          tracking: -0.07,
                        ),
                        children: [
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: 'of ${_mine.total}',
                            style: AppTheme.display(
                              size: 28,
                              weight: FontWeight.w700,
                              height: 0.8,
                              tracking: -0.03,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    DailyBars(rows: _mine.rounds, missed: AppColors.cream),
                    const SizedBox(height: 18),
                    Text(
                      _line(puzzle),
                      style: AppTheme.body(size: 15, weight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _Half(
                      color: AppColors.cream,
                      eyebrow: 'TIME',
                      value: clockOf(_mine.ms),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Half(
                      color: AppColors.butter,
                      eyebrow: 'STREAK',
                      value: streak == null ? '' : '${streak.current}',
                      unit: streak == null
                          ? ''
                          : streak.current == 1
                          ? 'day'
                          : 'days',
                    ),
                  ),
                ],
              ),
              if (_kept) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.peach,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'No signal right now. Your score is saved on this phone '
                    'and goes up the next time you open the Daily.',
                    style: AppTheme.body(size: 14),
                  ),
                ),
              ],
              const SizedBox(height: 30),
              Row(
                children: [
                  TextAction(
                    label: 'Share',
                    onTap: () =>
                        showDailyShare(context, date: puzzle.date, mine: _mine),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: PillButton(
                      label: _sending ? 'Sending' : 'How others did',
                      onTap: _sending ? null : _close,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Half extends StatelessWidget {
  const _Half({
    required this.color,
    required this.eyebrow,
    required this.value,
    this.unit = '',
  });

  final Color color;
  final String eyebrow;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(eyebrow, style: AppTheme.eyebrow()),
          Text.rich(
            TextSpan(
              text: value,
              style: AppTheme.display(size: 52, height: 0.82, tracking: -0.06),
              children: [
                if (unit.isNotEmpty) const TextSpan(text: ' '),
                TextSpan(
                  text: unit,
                  style: AppTheme.body(
                    size: 14,
                    weight: FontWeight.w600,
                  ).copyWith(letterSpacing: 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
