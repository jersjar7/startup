import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'daily_run.dart';

/// A Daily at a glance: one row per game, one capsule per round. Dark is
/// right on the first try, light is a miss that came back, faint is not
/// played yet. The share card is the same drawing, so it never gives an
/// answer away.
class DailyBars extends StatelessWidget {
  const DailyBars({
    super.key,
    required this.rows,
    this.firstTry = AppColors.charcoal,
    this.missed = AppColors.cream,
    this.untouched = AppColors.pipOff,
    this.height = 14,
    this.gap = 5,
  });

  /// From a run in progress.
  factory DailyBars.ofRun(DailyRun run, {double height = 12, Color? missed}) =>
      DailyBars(
        rows: [
          for (var g = 0; g < (run.puzzle?.games.length ?? 0); g++)
            [
              for (final m in run.marksOf(g))
                switch (m) {
                  RoundMark.firstTry => true,
                  RoundMark.afterMiss || RoundMark.missed => false,
                  RoundMark.untouched => null,
                },
            ],
        ],
        height: height,
        missed: missed ?? AppColors.peach,
      );

  /// true first try, false missed, null not played.
  final List<List<bool?>> rows;
  final Color firstTry;
  final Color missed;
  final Color untouched;
  final double height;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var g = 0; g < rows.length; g++) ...[
          if (g > 0) SizedBox(height: gap),
          Row(
            children: [
              for (var r = 0; r < rows[g].length; r++) ...[
                if (r > 0) SizedBox(width: gap),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: height,
                    decoration: BoxDecoration(
                      color: switch (rows[g][r]) {
                        true => firstTry,
                        false => missed,
                        null => untouched,
                      },
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// The streak as a dark row tile: the count in sunbeam, a line under it,
/// and a week of pips.
class StreakTile extends StatelessWidget {
  const StreakTile({
    super.key,
    required this.current,
    required this.playedToday,
  });

  final int current;
  final bool playedToday;

  @override
  Widget build(BuildContext context) {
    final line = playedToday
        ? 'Come back tomorrow to make it ${current + 1}'
        : current == 0
        ? 'Play today to start one'
        : 'Play today to make it ${current + 1}';
    final week = current == 0 ? 0 : ((current - 1) % 7) + 1;
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: AppColors.tile,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Text(
            '$current',
            style: AppTheme.display(
              size: 56,
              color: AppColors.sunbeam,
              height: 0.82,
              tracking: -0.06,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day streak',
                  style: AppTheme.display(
                    size: 19,
                    weight: FontWeight.w700,
                    color: AppColors.onTile,
                    height: 1.1,
                    tracking: -0.02,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  line,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.body(
                    size: 13.5,
                    color: AppColors.mutedOnDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 0; i < 7; i++) ...[
                      if (i > 0) const SizedBox(width: 4),
                      Container(
                        width: 18,
                        height: 10,
                        decoration: BoxDecoration(
                          color: i < week ? AppColors.sunbeam : AppColors.tile2,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
