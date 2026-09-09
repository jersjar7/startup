import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'scatter_figures.dart';

/// Through the Means — the second item for `linear-regression-correlation`.
///
/// The intercept formula is the whole of the lesson's hard problem, and read
/// as algebra it is a rearrangement nobody remembers. Read as a picture it is
/// one fact: the least-squares line ALWAYS passes through the point where the
/// two means meet. That single fact gives you the intercept from the slope, it
/// gives you the prediction, and it is why answering with the mean of y is
/// only right at one value of x.
///
/// So the means are marked on the plot and the student picks the line that
/// could be the regression. The wrong lines lean correctly and miss the mark,
/// which is exactly what forgetting the intercept produces.
class ThroughTheMeansGame extends StatefulWidget {
  const ThroughTheMeansGame({super.key});

  @override
  State<ThroughTheMeansGame> createState() => _ThroughTheMeansGameState();
}

@immutable
class MeansRound {
  const MeansRound({
    required this.subject,
    required this.points,
    required this.xTo,
    required this.yTo,
    required this.lines,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final List<Pair> points;
  final int xTo;
  final int yTo;
  final List<FitLine> lines;

  /// The one line that both leans with the cloud and passes through the means.
  final int answer;
  final String why;
  final String source;
}

const meansRounds = <MeansRound>[
  MeansRound(
    subject: 'rainfall against runoff',
    points: [Pair(1, 4), Pair(2, 5), Pair(3, 6), Pair(4, 8), Pair(5, 9),
        Pair(6, 10)],
    xTo: 7,
    yTo: 12,
    lines: [
      FitLine(0, 1.257, label: 'A'),
      FitLine(2.6, 1.257, label: 'B'),
      FitLine(4.6, 0.4, label: 'C'),
    ],
    answer: 1,
    why:
        'B is the only one through the means. A has the right lean and starts '
        'at zero, which is the same mistake as predicting with the slope and '
        'forgetting the intercept, and it sits under every reading on the '
        'right of the plot.',
    source: 'stat-reg-q3',
  ),
  MeansRound(
    subject: 'blow count against shear strength',
    points: [Pair(1, 3), Pair(2, 4), Pair(3, 6), Pair(4, 7), Pair(5, 9),
        Pair(6, 10)],
    xTo: 7,
    yTo: 12,
    lines: [
      FitLine(6.5, 0, label: 'A'),
      FitLine(1.4, 1.457, label: 'B'),
      FitLine(4, 1.457, label: 'C'),
    ],
    answer: 1,
    why:
        'A is flat at the mean of y, which is what answering with the average '
        'every time looks like: it passes through the means and predicts the '
        'same thing for every blow count. A regression line has to lean AND '
        'go through the means.',
    source: 'stat-reg-q3',
  ),
  MeansRound(
    subject: 'age against condition rating',
    points: [Pair(1, 9), Pair(2, 8), Pair(3, 6), Pair(4, 5), Pair(5, 3),
        Pair(6, 2)],
    xTo: 7,
    yTo: 11,
    lines: [
      FitLine(10.6, -1.457, label: 'A'),
      FitLine(8, -1.457, label: 'B'),
      FitLine(10.6, -0.7, label: 'C'),
    ],
    answer: 0,
    why:
        'A. A falling line is no different: the rule is about the means, not '
        'about the sign of the slope. C starts in the right place and does '
        'not fall fast enough to reach the cloud on the right.',
    source: 'stat-reg-q3',
  ),
  MeansRound(
    subject: 'a tight pair of measurements',
    points: [Pair(1, 2), Pair(2, 4), Pair(3, 6), Pair(4, 8), Pair(5, 10)],
    xTo: 7,
    yTo: 12,
    lines: [
      FitLine(0, 2, label: 'A'),
      FitLine(2, 2, label: 'B'),
      FitLine(6, 0, label: 'C'),
    ],
    answer: 0,
    why:
        'Here the intercept really is zero, so the line through the origin is '
        'also the line through the means. The intercept is whatever the means '
        'and the slope make it, and sometimes that is nothing.',
    source: 'stat-reg-q1',
  ),
  MeansRound(
    subject: 'the same readings, offset',
    points: [Pair(1, 5), Pair(2, 6), Pair(3, 8), Pair(4, 9), Pair(5, 11)],
    xTo: 7,
    yTo: 13,
    lines: [
      FitLine(0, 1.5, label: 'A'),
      FitLine(3.3, 1.5, label: 'B'),
      FitLine(7.8, 0, label: 'C'),
    ],
    answer: 1,
    why:
        'Same shape as the round before with everything lifted, and now the '
        'intercept carries that lift. A is the identical slope through the '
        'origin and misses every point, which is the cost of dropping the '
        'intercept term.',
    source: 'stat-reg-q3',
  ),
  MeansRound(
    subject: 'a loose cloud that still leans',
    points: [Pair(1, 3), Pair(2, 7), Pair(3, 4), Pair(4, 8), Pair(5, 6),
        Pair(6, 9)],
    xTo: 7,
    yTo: 11,
    lines: [
      FitLine(3.067, 0.886, label: 'A'),
      FitLine(3.067, 1.8, label: 'B'),
      FitLine(1, 0.886, label: 'C'),
    ],
    answer: 0,
    why:
        'A, and it goes through the means even though it is nowhere near most '
        'of the readings. The rule holds however loose the cloud is; how well '
        'the line fits is what r is for, and it is a separate question.',
    source: 'stat-reg-q1',
  ),
];

class _ThroughTheMeansGameState extends State<ThroughTheMeansGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'through-the-means',
    chapterId: 'statistics',
    total: meansRounds.length,
    sourceProblemIdOf: (round) => meansRounds[round].source,
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

  MeansRound get _round => meansRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Through the Means',
        closing:
            'The least-squares line always passes through the point where the '
            'two means meet. That is where the intercept comes from, and it '
            'is why a prediction is the intercept plus the slope times x and '
            'never the slope alone.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: regressionLineBrief,
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
            'IT HAS TO GO THROUGH THE MEANS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Which of these could be the regression line?',
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
              height: 260,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: ScatterPainter(
                    points: r.points,
                    xTo: r.xTo,
                    yTo: r.yTo,
                    lines: r.lines,
                    meanPoint: true,
                    pickedLine: _picked,
                    truthLine: answered ? r.answer : null,
                    revealed: answered,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < r.lines.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _LineButton(
                    key: ValueKey('fit-$i'),
                    label: r.lines[i].label ?? '${i + 1}',
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
              title: _session.correct! ? 'THROUGH THE MEANS' : 'NOT THAT LINE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _LineButton extends StatelessWidget {
  const _LineButton({
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(label, style: AppTheme.heading(size: 17)),
        ),
      ),
    );
  }
}
