import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'daily_models.dart';

/// The pieces of a Daily board, shared by today's results on the Daily tab
/// and yesterday's final board: the Everyone / school chips, the score
/// spread and the place rows.

/// The top names, then you when you are not already among them.
List<DailyPlace> boardRows(DailyBoard b) {
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

/// How a board came out: the score spread, then the top two and you.
class DailyStandings extends StatelessWidget {
  const DailyStandings({
    super.key,
    required this.board,
    required this.total,
    required this.mine,
  });

  final DailyBoard board;

  /// Rounds in that day's Daily.
  final int total;

  /// Your first-try score, the bar drawn dark.
  final int mine;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DailySpread(board: board, total: total, mine: mine),
        const SizedBox(height: 10),
        for (final p in boardRows(board)) ...[
          DailyPlaceRow(
            rank: p.rank,
            name: p.isYou ? 'You' : p.name,
            score: p.score,
            ms: p.ms,
            you: p.isYou,
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

/// Everyone, then the school's board once enough of its students played.
class DailyBoardChips extends StatelessWidget {
  const DailyBoardChips({
    super.key,
    required this.school,
    required this.board,
    required this.onBoard,
  });

  final DailySchool school;

  /// 0 everyone, 1 school.
  final int board;
  final ValueChanged<int> onBoard;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DailyBoardChip(
          label: 'Everyone',
          on: board == 0 || !school.open,
          onTap: () => onBoard(0),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: DailyBoardChip(
            label: school.open
                ? school.name
                : '${school.name}, at ${school.needs} players',
            on: board == 1 && school.open,
            enabled: school.open,
            onTap: () => onBoard(1),
          ),
        ),
      ],
    );
  }
}

class DailyBoardChip extends StatelessWidget {
  const DailyBoardChip({
    super.key,
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
class DailySpread extends StatelessWidget {
  const DailySpread({
    super.key,
    required this.board,
    required this.total,
    required this.mine,
  });

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

class DailyPlaceRow extends StatelessWidget {
  const DailyPlaceRow({
    super.key,
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
