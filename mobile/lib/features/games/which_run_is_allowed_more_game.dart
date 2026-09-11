import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'level_figures.dart';

/// Which Run Is Allowed More — the third item for `leveling`.
///
/// A level loop has to come back to the elevation it started from, and the
/// amount it is allowed to be out by is not a fixed number: it grows with
/// the length of the run, but only as the square root of it. Four times the
/// distance buys twice the tolerance, not four times. The other half of it
/// is the constant, which is set by the class of work, and a tight constant
/// on a long run can allow less than a loose one on a short run. Neither
/// half decides on its own, which is the whole item: no arithmetic, just
/// which of two runs is given more room.
class WhichRunIsAllowedMoreGame extends StatefulWidget {
  const WhichRunIsAllowedMoreGame({super.key});

  @override
  State<WhichRunIsAllowedMoreGame> createState() =>
      _WhichRunIsAllowedMoreGameState();
}

/// Which of the two runs is allowed to be out by more.
enum Roomier { left, right, same }

extension RoomierWords on Roomier {
  String get plain => switch (this) {
        Roomier.left => 'The left one',
        Roomier.right => 'The right one',
        Roomier.same => 'Neither: the same allowance',
      };
}

@immutable
class LoopRound {
  const LoopRound({
    required this.subject,
    required this.setting,
    required this.left,
    required this.right,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Loop left;
  final Loop right;
  final String why;
  final String source;

  /// Worked out from the two allowances, never declared.
  Roomier get answer {
    final gap = left.allowable - right.allowable;
    if (gap.abs() < 0.0005) return Roomier.same;
    return gap > 0 ? Roomier.left : Roomier.right;
  }

  double get biggest =>
      left.miles > right.miles ? left.miles : right.miles;
}

const slackRounds = <LoopRound>[
  LoopRound(
    subject: 'four miles against one',
    setting:
        'Two loops run to the same standard, C equal to 0.05 feet. One runs '
        'four miles round, the other one mile.',
    left: Loop(miles: 4, constant: 0.05),
    right: Loop(miles: 1, constant: 0.05),
    why:
        'The left one, at 0.10 feet against 0.05, and the point is that it '
        'is only DOUBLE. Four times the distance does not buy four times the '
        'tolerance, because the allowance goes as the square root: errors in '
        'a long run are as likely to cancel as to pile up. The left loop is '
        'the lesson\'s own, and 0.10 is the number its 0.03 misclosure has '
        'to beat.',
    source: 'surv-lev-q3',
  ),
  LoopRound(
    subject: 'the same distance, different work',
    setting:
        'Both loops run nine miles. The left is ordinary construction '
        'leveling at C equal to 0.05. The right is second order control at C '
        'equal to 0.024.',
    left: Loop(miles: 9, constant: 0.05),
    right: Loop(miles: 9, constant: 0.024),
    why:
        'The left one, 0.15 feet against 0.072. Distance is only half of it: '
        'the constant says what class of work this is, and tighter work is '
        'allowed less. The same run of ground, the same crew and the same '
        'instrument can pass as construction leveling and fail as control '
        'leveling.',
    source: 'surv-lev-q3',
  ),
  LoopRound(
    subject: 'sixteen against four',
    setting: 'Both at C equal to 0.05. Sixteen miles against four.',
    left: Loop(miles: 16, constant: 0.05),
    right: Loop(miles: 4, constant: 0.05),
    why:
        'The left one, 0.20 against 0.10. Four times the length, twice the '
        'allowance, again. Anyone who expects the tolerance to keep up with '
        'the distance will believe a long run is easier than it is: the '
        'square root is what makes long loops hard.',
    source: 'surv-lev-q3',
  ),
  LoopRound(
    subject: 'two identical loops',
    setting:
        'Two separate loops, both two miles round, both at C equal to 0.024.',
    left: Loop(miles: 2, constant: 0.024),
    right: Loop(miles: 2, constant: 0.024),
    why:
        'Neither: the same allowance, about 0.034 feet each. Nothing else '
        'enters the formula. Not the number of setups, not the ground, not '
        'how long the crew took. Only the distance and the class of work, '
        'which is what makes it a usable field check rather than a '
        'calculation.',
    source: 'surv-lev-q3',
  ),
  LoopRound(
    subject: 'a short tight loop against a long loose one',
    setting:
        'The left runs one mile at C equal to 0.05. The right runs four '
        'miles at C equal to 0.024.',
    left: Loop(miles: 1, constant: 0.05),
    right: Loop(miles: 4, constant: 0.024),
    why:
        'The left one, and only just: 0.050 feet against 0.048. The longer '
        'run is held to the tighter standard, and its four miles only double '
        'what the constant gives it, so the two very nearly meet. Longer '
        'does not always mean more room. Work out both sides before saying '
        'which.',
    source: 'surv-lev-q3',
  ),
  LoopRound(
    subject: 'a quarter of a mile',
    setting:
        'A short loop of a quarter mile against a two mile loop, both at C '
        'equal to 0.05.',
    left: Loop(miles: 0.25, constant: 0.05),
    right: Loop(miles: 2, constant: 0.05),
    why:
        'The right one, 0.071 feet against 0.025. Under a mile the square '
        'root works the other way and TIGHTENS the allowance: a quarter mile '
        'gets half the constant, not a quarter of it. A short loop that '
        'misses by a tenth of a foot is in worse trouble than a long one '
        'that does.',
    source: 'surv-lev-q3',
  ),
];

class _WhichRunIsAllowedMoreGameState extends State<WhichRunIsAllowedMoreGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-run-is-allowed-more',
    chapterId: 'surveying',
    total: slackRounds.length,
    sourceProblemIdOf: (round) => slackRounds[round].source,
  )..addListener(_onSession);

  Roomier? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  LoopRound get _round => slackRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Run Is Allowed More',
        closing:
            'What a loop may be out by is the constant times the square root '
            'of the distance, and both halves matter. Four times the length '
            'is only twice the allowance, under a mile the root tightens it '
            'instead, and the constant can hand a short run more room than a '
            'long one. If the misclosure beats that number the run stands. '
            'If not, it gets run again.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: closureBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _picked = null);
              _session.next();
            }
          : (_picked == null
                ? null
                : () => _session.submit(
                    ok: _picked == r.answer,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHICH RUN MAY BE OUT BY MORE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.setting,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < 2; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _LoopPanel(
                    loop: i == 0 ? r.left : r.right,
                    biggest: r.biggest,
                    selected:
                        _picked == (i == 0 ? Roomier.left : Roomier.right),
                    locked: answered,
                    isTruth:
                        r.answer == (i == 0 ? Roomier.left : Roomier.right),
                    onTap: answered
                        ? null
                        : () => setState(() =>
                            _picked = i == 0 ? Roomier.left : Roomier.right),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\text{allowable} = C\sqrt{M}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          _Choice(
            label: Roomier.same.plain,
            selected: _picked == Roomier.same,
            locked: answered,
            isTruth: r.answer == Roomier.same,
            onTap:
                answered ? null : () => setState(() => _picked = Roomier.same),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'THE OTHER ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _LoopPanel extends StatelessWidget {
  const _LoopPanel({
    required this.loop,
    required this.biggest,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Loop loop;
  final double biggest;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    if (locked && isTruth) {
      border = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
    } else {
      border = AppColors.line;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 175,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: EngineeringGrid(
              minor: 16,
              major: 80,
              child: CustomPaint(
                painter: LoopPainter(loop: loop, biggest: biggest),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    if (locked && isTruth) {
      border = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
    } else {
      border = AppColors.line;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
