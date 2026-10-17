import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../games/game_catalog.dart';
import '../games/lesson_brief.dart';
import '../shared/widgets/kit.dart';
import '../study/chapter_marks.dart';
import 'daily_run.dart';
import 'daily_widgets.dart';

/// Before each of the Daily's games: which game is next, from which chapter,
/// its concept one tap away, and one button to play it.
///
/// The clock is stopped here. Reading the concept first is what turns a
/// guess into something learned, so it never costs time.
class DailyStepScreen extends StatelessWidget {
  const DailyStepScreen({super.key, this.justFinished});

  /// The game that was just finished, when this follows one.
  final int? justFinished;

  @override
  Widget build(BuildContext context) {
    final run = DailyRun.instance;
    final game = run.currentGame;
    final puzzle = run.puzzle;
    if (game == null || puzzle == null) {
      return const Scaffold(backgroundColor: AppColors.fog);
    }
    final def = gameDefFor(game.gameId);
    final chapter = chapterMaps[game.chapterId];
    final count = puzzle.games.length;
    final at = run.gameIndex;
    final done = justFinished;
    final doneDef = done == null ? null : gameDefFor(puzzle.games[done].gameId);
    final brief = def?.brief;

    return Scaffold(
      backgroundColor: AppColors.fog,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  RoundIconButton(
                    icon: Icons.close_rounded,
                    label: 'Close',
                    onTap: () =>
                        context.canPop() ? context.pop() : context.go('/home'),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Text('TODAY\'S DAILY', style: AppTheme.eyebrow()),
                  const Spacer(),
                  Text(
                    'CONCEPT ${at + 1} OF $count',
                    style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DailyBars.ofRun(run),
              if (done != null && doneDef != null) ...[
                const SizedBox(height: 12),
                Text(
                  '${doneDef.name}: ${run.firstTryIn(done)} of '
                  '${puzzle.games[done].rounds} on the first try.',
                  style: AppTheme.body(size: 14, color: AppColors.mutedOnLight),
                ),
              ],
              const SizedBox(height: 22),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (chapter?.name ?? '').toUpperCase(),
                        style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: const BoxDecoration(
                              color: AppColors.spring,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: ChapterMark(
                                chapterId: game.chapterId,
                                color: AppColors.charcoal,
                                size: 84,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        def?.name ?? game.gameId,
                        style: AppTheme.display(size: 36),
                      ),
                      if (def != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          def.blurb,
                          style: AppTheme.body(
                            size: 15,
                            color: AppColors.mutedOnLight,
                          ),
                        ),
                      ],
                      // A link in the card, not a second button: the concept
                      // belongs to the game, and Play stays the one action
                      // (owner, 2026-10-16).
                      if (brief != null) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Transform.translate(
                            offset: const Offset(6, 0),
                            child: TextAction(
                              label: 'Read the concept first',
                              onTap: () => showConcept(
                                context,
                                brief,
                                back: 'Back to the Daily',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PillButton(
                label: at == 0 && done == null ? 'Play' : 'Play concept ${at + 1}',
                onTap: () {
                  run.arm();
                  context.pushReplacement('/games/play/${game.gameId}');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What a Daily game ends on instead of its own summary: the next game's
/// step, or, after the last one, the Daily's result.
class DailyAfterGame extends StatefulWidget {
  const DailyAfterGame({super.key, required this.game});

  final int game;

  @override
  State<DailyAfterGame> createState() => _DailyAfterGameState();
}

class _DailyAfterGameState extends State<DailyAfterGame> {
  @override
  void initState() {
    super.initState();
    final run = DailyRun.instance..finishGame(widget.game);
    if (run.allDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pushReplacement('/daily/done');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (DailyRun.instance.allDone) {
      return const Scaffold(backgroundColor: AppColors.fog);
    }
    return DailyStepScreen(justFinished: widget.game);
  }
}
