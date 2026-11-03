import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tablet.dart';
import '../shared/widgets/kit.dart';
import '../shared/widgets/split_page.dart';
import 'daily_board.dart';
import 'daily_calendar.dart';
import 'daily_models.dart';

/// Yesterday's final board, opened from "Yesterday's score" on the Daily tab
/// (owner, 2026-11-02). Only offered to a student who played yesterday, so
/// there is always a place to show. The same spread and rows as today's
/// results, on the Daily's butter ground, under the place itself.
class DailyYesterdayScreen extends StatefulWidget {
  const DailyYesterdayScreen({
    super.key,
    required this.date,
    required this.results,
  });

  /// Yesterday, 'YYYY-MM-DD'.
  final String date;
  final DailyResults results;

  @override
  State<DailyYesterdayScreen> createState() => _DailyYesterdayScreenState();
}

class _DailyYesterdayScreenState extends State<DailyYesterdayScreen> {
  int _board = 0; // 0 everyone, 1 school

  @override
  Widget build(BuildContext context) {
    final results = widget.results;
    final school = results.school;
    final showing = _board == 1 && school?.board != null
        ? school!.board!
        : results.everyone;
    final me = showing.me ?? results.everyone.me;
    final total = results.everyone.me?.total ?? me?.total ?? 0;

    if (AppTablet.of(context) == SizeClass.expanded) {
      // T21c: the place and the spread on the left, the board's rows right.
      return Material(
        color: AppColors.butter,
        child: SplitPage(
          leftWidth: 520,
          left: [
            RoundIconButton(
              icon: Icons.chevron_left_rounded,
              label: 'Back',
              onTap: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 40),
            Text(
              '${dailyDayLine(widget.date)} · final · '
                      '${showing.players} played'
                  .toUpperCase(),
              style: AppTheme.eyebrow(),
            ),
            const SizedBox(height: 10),
            Text(
              me == null
                  ? 'Yesterday\'s board'
                  : '${ordinal(me.rank)} of ${showing.players} yesterday',
              style: AppTablet.headlineXL(),
            ),
            if (school != null) ...[
              const SizedBox(height: 18),
              DailyBoardChips(
                school: school,
                board: _board,
                onBoard: (i) => setState(() => _board = i),
              ),
            ],
            const SizedBox(height: 24),
            DailySpread(
              board: showing,
              total: total,
              mine: me?.score ?? -1,
              large: true,
            ),
          ],
          rightTopPad: 88,
          right: [
            Text('THE BOARD', style: AppTheme.eyebrow(color: AppColors.ink2)),
            const SizedBox(height: 22),
            for (final p in boardRows(showing)) ...[
              DailyPlaceRow(
                rank: p.rank,
                name: p.isYou ? 'You' : p.name,
                score: p.score,
                ms: p.ms,
                you: p.isYou,
                large: true,
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      );
    }
    return Material(
      color: AppColors.butter,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            30 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: RoundIconButton(
                  icon: Icons.chevron_left_rounded,
                  label: 'Back',
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                '${dailyDayLine(widget.date)} · final · '
                        '${showing.players} played'
                    .toUpperCase(),
                style: AppTheme.eyebrow(),
              ),
              const SizedBox(height: 10),
              Text(
                me == null
                    ? 'Yesterday\'s board'
                    : '${ordinal(me.rank)} of ${showing.players} yesterday',
                style: AppTheme.display(size: 44),
              ),
              if (school != null) ...[
                const SizedBox(height: 18),
                DailyBoardChips(
                  school: school,
                  board: _board,
                  onBoard: (i) => setState(() => _board = i),
                ),
              ],
              const SizedBox(height: 12),
              DailyStandings(
                board: showing,
                total: total,
                mine: me?.score ?? -1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 1 -> '1st', 2 -> '2nd', 11 -> '11th', 23 -> '23rd'.
String ordinal(int n) {
  final teen = n % 100;
  if (teen >= 11 && teen <= 13) return '${n}th';
  return switch (n % 10) {
    1 => '${n}st',
    2 => '${n}nd',
    3 => '${n}rd',
    _ => '${n}th',
  };
}
