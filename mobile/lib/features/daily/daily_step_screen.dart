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
import '../../core/theme/tablet.dart';
import 'daily_models.dart';

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

    final tablet = AppTablet.isTablet(context);
    final wide = AppTablet.of(context) == SizeClass.expanded;
    final close = Row(
      children: [
        RoundIconButton(
          icon: Icons.close_rounded,
          label: 'Close',
          onTap: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ],
    );
    final heading = Row(
      children: [
        Text('TODAY\'S DAILY', style: AppTheme.eyebrow()),
        const Spacer(),
        Text(
          'CONCEPT ${at + 1} OF $count',
          style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
        ),
      ],
    );
    final card = Container(
      padding: EdgeInsets.all(tablet ? 36 : 26),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(tablet ? 40 : 36),
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
                width: tablet ? 200 : 140,
                height: tablet ? 200 : 140,
                decoration: const BoxDecoration(
                  color: AppColors.springField,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: ChapterMark(
                    chapterId: game.chapterId,
                    color: AppColors.charcoal,
                    size: tablet ? 120 : 84,
                  ),
                ),
              ),
            ),
          ),
          // The concept as the website names it, over the round's own name
          // (owner, 2026-10-17).
          if (lessonForGame(game.gameId) case final lesson?) ...[
            Text(
              lesson.name,
              style: AppTheme.display(
                size: tablet ? 20 : 17,
                weight: FontWeight.w700,
                height: 1.2,
                tracking: -0.02,
                color: AppColors.mutedOnLight,
              ),
            ),
            SizedBox(height: tablet ? 12 : 6),
          ],
          Text(
            def?.name ?? game.gameId,
            style: AppTheme.display(size: tablet ? 56 : 36),
          ),
          if (def != null) ...[
            SizedBox(height: tablet ? 14 : 8),
            Text(
              def.blurb,
              style: AppTheme.body(
                size: tablet ? 18 : 15,
                color: AppColors.mutedOnLight,
              ),
            ),
          ],
          // A link in the card, not a second button: the concept belongs to
          // the game, and Play stays the one action (owner, 2026-10-16).
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
                    gameId: game.gameId,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
    final pill = PillButton(
      label: at == 0 && done == null ? 'Play' : 'Play concept ${at + 1}',
      onTap: () {
        run.arm();
        context.pushReplacement('/games/play/${game.gameId}');
      },
    );
    final justDone = done != null && doneDef != null
        ? Text(
            '${doneDef.name}: ${run.firstTryIn(done)} of '
            '${puzzle.games[done].rounds} on the first try.',
            style: AppTheme.body(
              size: tablet ? 16 : 14,
              color: AppColors.mutedOnLight,
            ),
          )
        : null;

    if (wide) {
      // T21: the three on the left, done, now and next; the one that is up
      // as its own card on the right, with Play under it.
      return Scaffold(
        backgroundColor: AppColors.fog,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTablet.screenX,
              AppTablet.spaceTop + 12,
              AppTablet.screenX,
              AppTablet.spaceTop + 8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 9,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        close,
                        const SizedBox(height: 44),
                        heading,
                        const SizedBox(height: 20),
                        for (var i = 0; i < count; i++) ...[
                          _ThreeRow(
                            game: puzzle.games[i],
                            state: i < at
                                ? _Turn.done
                                : i == at
                                ? _Turn.now
                                : _Turn.next,
                            firstTry: run.firstTryIn(i),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (justDone != null) ...[
                          const SizedBox(height: 10),
                          justDone,
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppTablet.paneGap * 2.5),
                Expanded(
                  flex: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: card),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(width: AppTablet.pillMax, child: pill),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.fog,
      body: SafeArea(
        child: Padding(
          padding: tablet
              ? const EdgeInsets.fromLTRB(
                  AppTablet.screenX,
                  AppTablet.spaceTop + 12,
                  AppTablet.screenX,
                  AppTablet.spaceTop + 8,
                )
              : const EdgeInsets.fromLTRB(24, 8, 24, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              close,
              const SizedBox(height: 26),
              heading,
              const SizedBox(height: 12),
              DailyBars.ofRun(run),
              if (justDone != null) ...[const SizedBox(height: 12), justDone],
              const SizedBox(height: 22),
              Expanded(child: card),
              const SizedBox(height: 16),
              pill,
            ],
          ),
        ),
      ),
    );
  }
}

enum _Turn { done, now, next }

/// One of the Daily's three on a tablet's step (T21): played, up now, or
/// still to come.
class _ThreeRow extends StatelessWidget {
  const _ThreeRow({
    required this.game,
    required this.state,
    required this.firstTry,
  });

  final DailyGame game;
  final _Turn state;
  final int firstTry;

  @override
  Widget build(BuildContext context) {
    final now = state == _Turn.now;
    final next = state == _Turn.next;
    final ink = now
        ? AppColors.cream
        : next
        ? AppColors.mutedOnLight
        : AppColors.charcoal;
    final muted = now ? AppColors.mutedOnDark : AppColors.mutedOnLight;
    final def = gameDefFor(game.gameId);
    final lesson = lessonForGame(game.gameId);
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: now
            ? AppColors.charcoal
            : next
            ? AppColors.creamDark
            : AppColors.cream,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: now ? AppColors.springField : AppColors.creamDark,
            ),
            child: Center(
              child: state == _Turn.done
                  ? const Icon(
                      Icons.check_rounded,
                      size: 24,
                      color: AppColors.charcoal,
                    )
                  : ChapterMark(
                      chapterId: game.chapterId,
                      color: next ? AppColors.mutedOnLight : AppColors.charcoal,
                      size: 30,
                    ),
            ),
          ),
          const SizedBox(width: 18),
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
                    size: 18,
                    weight: FontWeight.w700,
                    height: 1.2,
                    tracking: -0.02,
                    color: ink,
                  ),
                ),
                if (lesson != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    lesson.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.body(size: 14, color: muted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            switch (state) {
              _Turn.done => '$firstTry of ${game.rounds}',
              _Turn.now => 'Now',
              _Turn.next => 'Next',
            },
            style: AppTheme.mono(
              size: 13,
              weight: now ? FontWeight.w700 : FontWeight.w500,
              color: now ? AppColors.spring : muted,
            ),
          ),
        ],
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
