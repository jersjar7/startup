import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'breakeven_figures.dart';
import 'lesson_brief.dart';
import 'liability_row.dart';

/// Which Side Wins — the second item for `cost-types-breakeven`.
///
/// A break-even question is two straight lines and the place they cross, and
/// the algebra hides both. The lesson's named traps are subtracting the
/// variable costs in the wrong order, which gives a negative volume, and
/// comparing the per-unit rates while ignoring the fixed costs entirely.
/// Neither survives contact with the picture.
///
/// So the lines are drawn, a volume is marked, and the question is which
/// method is cheaper standing there. One round has the lines never cross,
/// because a student who always hunts for a break-even volume will find one
/// that is not there.
class WhichSideWinsGame extends StatefulWidget {
  const WhichSideWinsGame({super.key});

  @override
  State<WhichSideWinsGame> createState() => _WhichSideWinsGameState();
}

@immutable
class WinsRound {
  const WinsRound({
    required this.subject,
    required this.setting,
    required this.lines,
    required this.qTo,
    required this.at,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;

  /// Exactly two, and the answer is whichever is lower at [at].
  final List<CostLine> lines;
  final double qTo;
  final double at;
  final String why;
  final String source;

  /// Worked out from the lines rather than declared. Index two is the tie.
  int get answer {
    final a = lines[0].at(at);
    final b = lines[1].at(at);
    if ((a - b).abs() < 0.005) return 2;
    return a < b ? 0 : 1;
  }
}

const winsRounds = <WinsRound>[
  WinsRound(
    subject: 'owned trucks against a rented fleet',
    setting:
        'Owned trucks cost 4,200 dollars a day plus 3 dollars a cubic yard. A '
        'rented fleet costs 1,200 a day plus 7.30 a yard. Today the job is a '
        'light one.',
    lines: [
      CostLine('Owned', 4200, 3),
      CostLine('Rented', 1200, 7.30),
    ],
    qTo: 1400,
    at: 300,
    why:
        'Below the crossing the cheap start wins, because there is not enough '
        'work to spread the yard and the insurance over. Comparing the per '
        'yard rates alone says the opposite and is wrong on every light day.',
    source: 'econ-ctb-q2',
  ),
  WinsRound(
    subject: 'the same two methods, a heavy day',
    setting:
        'The same two methods, and today there is a great deal to move.',
    lines: [
      CostLine('Owned', 4200, 3),
      CostLine('Rented', 1200, 7.30),
    ],
    qTo: 1400,
    at: 1200,
    why:
        'Past the crossing the steep line has caught up and gone by. The fixed '
        'cost is now spread thin and the rate per yard is what is left to pay '
        'for, which is the whole reason anybody owns trucks.',
    source: 'econ-ctb-q2',
  ),
  WinsRound(
    subject: 'exactly at the crossing',
    setting:
        'The same two methods again, at the volume where the two daily totals '
        'come out identical.',
    lines: [
      CostLine('Owned', 4200, 3),
      CostLine('Rented', 1200, 7.30),
    ],
    qTo: 1400,
    at: 697.674,
    why:
        'The break-even volume itself, and it is a real answer rather than a '
        'trick. Below it one method wins and above it the other does, which is '
        'the only thing the number is ever used for.',
    source: 'econ-ctb-q2',
  ),
  WinsRound(
    subject: 'a method that is worse everywhere',
    setting:
        'One batching option costs more to set up AND more per cubic meter '
        'than the other. The plant is running at a middling volume.',
    lines: [
      CostLine('Option A', 900, 4),
      CostLine('Option B', 1800, 6),
    ],
    qTo: 600,
    at: 300,
    why:
        'The lines never cross, so there is no break-even volume to find. When '
        'one option starts higher and rises faster it loses at every volume, '
        'and hunting for a crossing produces a negative number and a wrong '
        'answer.',
    source: 'econ-ctb-q2',
  ),
  WinsRound(
    subject: 'a plant against a supplier',
    setting:
        'An on-site batch plant costs 6,000 dollars a week to run plus 40 '
        'dollars a cubic meter. Buying it in costs nothing weekly and 95 a '
        'meter. This week is quiet.',
    lines: [
      CostLine('On site', 6000, 40),
      CostLine('Bought in', 0, 95),
    ],
    qTo: 300,
    at: 60,
    why:
        'Nothing fixed at all is the extreme case of a cheap start. Buying in '
        'costs nothing until you order something, and on a quiet week that '
        'beats a plant standing idle.',
    source: 'econ-ctb-q2',
  ),
  WinsRound(
    subject: 'the same plant, a busy week',
    setting: 'The same two options, and this week the pours are back to back.',
    lines: [
      CostLine('On site', 6000, 40),
      CostLine('Bought in', 0, 95),
    ],
    qTo: 300,
    at: 250,
    why:
        'Fifty five dollars a meter saved, times enough meters, pays for a '
        'plant. The crossing sits near a hundred and ten meters and everything '
        'past it belongs to the option with the fixed cost.',
    source: 'econ-ctb-q2',
  ),
];

class _WhichSideWinsGameState extends State<WhichSideWinsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-side-wins',
    chapterId: 'economics',
    total: winsRounds.length,
    sourceProblemIdOf: (round) => winsRounds[round].source,
  )..addListener(_onSession);

  int? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  WinsRound get _round => winsRounds[_session.round];

  /// How this line sits against the other one, in both dimensions.
  static String _describe(WinsRound r, int i) {
    final mine = r.lines[i];
    final theirs = r.lines[1 - i];
    final start = mine.fixed > theirs.fixed
        ? 'the higher start'
        : (mine.fixed < theirs.fixed ? 'the lower start' : 'the same start');
    final rise = mine.variable > theirs.variable
        ? 'the steeper rise'
        : (mine.variable < theirs.variable
              ? 'the flatter rise'
              : 'the same rise');
    return '$start, $rise';
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Side Wins',
        closing:
            'Below the crossing the cheap start wins and above it the cheap '
            'rate does. Comparing the per unit rates on their own ignores '
            'where each line starts, and when one option starts higher and '
            'rises faster there is no crossing to find at all.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: breakEvenBrief,
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
            'CHEAPER AT THE MARKED VOLUME',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.setting,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 190,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: BreakEvenPainter(
                    lines: r.lines,
                    qTo: r.qTo,
                    at: r.at,
                    revealed: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            LiabilityRow(
              key: ValueKey('side-$i'),
              title: i < 2 ? r.lines[i].name : 'They cost the same',
              // Described from BOTH numbers. Comparing only the fixed cost
              // told the student a steeper line was the flatter one on the
              // round where one option is worse on every count.
              note: i < 2 ? _describe(r, i) : 'the marked volume is the crossing',
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'CHEAPER THERE' : 'THE OTHER SIDE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
