import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'scatter_figures.dart';

/// Read the Scatter — the first item for `linear-regression-correlation`.
///
/// The formula for r has four sums in it and nobody will ever evaluate one on
/// a phone. What r actually IS can be read straight off the plot: which way
/// the cloud leans gives the sign, and how tightly it hugs a line gives the
/// size. That reading is what makes the number mean something afterwards, and
/// it is the only part of this topic a screen can teach.
///
/// One round is a cloud with an obvious shape and an r of nothing at all,
/// because r measures STRAIGHT-line agreement and a student who has never met
/// that case will trust an r of zero to mean there is no relationship.
class ReadTheScatterGame extends StatefulWidget {
  const ReadTheScatterGame({super.key});

  @override
  State<ReadTheScatterGame> createState() => _ReadTheScatterGameState();
}

/// The five readings on offer, spread far enough apart that picking between
/// them is a judgement about the picture and not about a decimal place.
const rChoices = <double>[-1.0, -0.7, 0.0, 0.7, 1.0];

@immutable
class ScatterRound {
  const ScatterRound({
    required this.subject,
    required this.points,
    required this.xTo,
    required this.yTo,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final List<Pair> points;
  final int xTo;
  final int yTo;

  /// Which of [rChoices] the cloud is nearest.
  final int answer;
  final String why;
  final String source;
}

const scatterRounds = <ScatterRound>[
  ScatterRound(
    subject: 'rainfall depth against runoff volume',
    points: [Pair(1, 2), Pair(2, 3), Pair(3, 5), Pair(4, 6), Pair(5, 8),
        Pair(6, 9)],
    xTo: 7,
    yTo: 10,
    answer: 4,
    why:
        'Up and to the right, and hugging a line all the way. More rain, more '
        'runoff, and very little scatter about it, so r sits just under one.',
    source: 'stat-reg-q1',
  ),
  ScatterRound(
    subject: 'bridge age against condition rating',
    points: [Pair(1, 9), Pair(2, 8), Pair(3, 6), Pair(4, 5), Pair(5, 3),
        Pair(6, 2)],
    xTo: 7,
    yTo: 10,
    answer: 0,
    why:
        'Down and to the right, and just as tight. The minus sign is the '
        'direction and nothing else; a correlation of minus one is exactly as '
        'strong as one of plus one.',
    source: 'stat-reg-q2',
  ),
  ScatterRound(
    subject: 'blow count against shear strength',
    points: [Pair(1, 3), Pair(2, 7), Pair(3, 4), Pair(4, 8), Pair(5, 6),
        Pair(6, 9)],
    xTo: 7,
    yTo: 10,
    answer: 3,
    why:
        'It leans up, but loosely. Around zero point seven, which squares to '
        'about half, so a line through this would explain only half of what '
        'the readings do.',
    source: 'stat-reg-q1',
  ),
  ScatterRound(
    subject: 'two site measurements with nothing between them',
    points: [Pair(1, 5), Pair(2, 2), Pair(3, 7), Pair(4, 3), Pair(5, 6),
        Pair(6, 4)],
    xTo: 7,
    yTo: 10,
    answer: 2,
    why:
        'No lean at all. Knowing x tells you nothing about y here, and a '
        'regression line through this cloud would predict about as well as '
        'guessing the average every time.',
    source: 'stat-reg-q2',
  ),
  ScatterRound(
    subject: 'a gauge reading against the quantity it measures',
    points: [Pair(1, 2), Pair(2, 4), Pair(3, 6), Pair(4, 8), Pair(5, 10)],
    xTo: 7,
    yTo: 11,
    answer: 4,
    why:
        'Every reading is exactly on one line, so r is one on the nose. This '
        'is as good as it gets and it almost never happens with field data.',
    source: 'stat-reg-q1',
  ),
  ScatterRound(
    subject: 'compaction moisture against dry density',
    points: [Pair(1, 2), Pair(2, 5), Pair(3, 7), Pair(4, 7), Pair(5, 5),
        Pair(6, 2)],
    xTo: 7,
    yTo: 10,
    answer: 2,
    why:
        'There is obviously a relationship here, and r is still zero. It only '
        'measures STRAIGHT-line agreement, and this arch rises and falls by '
        'the same amount, so the two halves cancel. An r of nothing never '
        'means there is nothing going on.',
    source: 'stat-reg-q2',
  ),
];

class _ReadTheScatterGameState extends State<ReadTheScatterGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'read-the-scatter',
    chapterId: 'statistics',
    total: scatterRounds.length,
    sourceProblemIdOf: (round) => scatterRounds[round].source,
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

  ScatterRound get _round => scatterRounds[_session.round];

  static String _write(double r) => r == 0
      ? 'about 0'
      : '${r > 0 ? '+' : '−'}${r.abs() == 1 ? '1' : r.abs().toString()}';

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Read the Scatter',
        closing:
            'The lean gives the sign and the tightness gives the size. And r '
            'only ever measures how well a STRAIGHT line fits, so a cloud can '
            'have an obvious shape and a correlation of nothing.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: correlationBrief,
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
            'THE LEAN AND THE TIGHTNESS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Which correlation is this closest to?',
            style: TextStyle(
              fontSize: 16,
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
              height: 250,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: ScatterPainter(
                    points: r.points,
                    xTo: r.xTo,
                    yTo: r.yTo,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < rChoices.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _RButton(
                    key: ValueKey('r-$i'),
                    label: _write(rChoices[i]),
                    selected: _picked == i,
                    locked: answered,
                    isTruth: i == r.answer,
                    onTap: answered
                        ? null
                        : () => setState(() => _picked = i),
                  ),
                ),
              ],
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE READ' : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _RButton extends StatelessWidget {
  const _RButton({
    super.key,
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
    final Color fill;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
    }

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            style: AppTheme.mono(size: 13, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
