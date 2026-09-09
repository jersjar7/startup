import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'interval_figures.dart';
import 'lesson_brief.dart';

/// How Many Samples — the third item for `confidence-intervals-estimation`.
///
/// The lesson's hard problem is the sample size formula and both of its named
/// traps are about what you do with the answer: forgetting to square, and
/// handing in the decimal. Neither is arithmetic. They are both about the
/// shape of the thing, and the shape is a curve.
///
/// So the margin is drawn against the number of samples, the target is drawn
/// as a line to get under, and the candidates are marked on the curve. Sixty
/// one sits just above the line and sixty two sits just below it, which is
/// what rounding up means, and halving the margin visibly costs four times the
/// samples, which is what the square is for.
class HowManySamplesGame extends StatefulWidget {
  const HowManySamplesGame({super.key});

  @override
  State<HowManySamplesGame> createState() => _HowManySamplesGameState();
}

@immutable
class SizeRound {
  const SizeRound({
    required this.subject,
    required this.ask,
    required this.k,
    required this.target,
    required this.candidates,
    required this.from,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String ask;

  /// The margin at a single sample, so the margin at n is k over root n. It is
  /// z times sigma, and it is the only thing a round needs to declare.
  final double k;

  /// The margin the round is asking for.
  final double target;

  /// Marked on the curve, smallest first.
  final List<int> candidates;

  /// Where the drawn window starts. A round decided by one sample is drawn
  /// zoomed in, because that is where the teaching is.
  final int from;
  final int answer;
  final String why;
  final String source;
}

const sizeRounds = <SizeRound>[
  SizeRound(
    subject: 'daily traffic counts at an intersection',
    ask: 'The margin has to be 200 vehicles. How many days do you count?',
    k: 1568,
    target: 200,
    candidates: [60, 61, 62],
    from: 48,
    answer: 2,
    why:
        'The formula gives 61.47, and 61 days leaves the margin just above the '
        'line. You cannot count for half a day, and you cannot round down to a '
        'number that misses the spec, so it is 62.',
    source: 'stat-ci-q3',
  ),
  SizeRound(
    subject: 'liquid limit on soil samples',
    ask: '25 samples give a margin of 4. How many give a margin of 2?',
    k: 20,
    target: 2,
    candidates: [50, 100, 200],
    from: 0,
    answer: 1,
    why:
        'Halving the margin costs four times the samples, because the margin '
        'falls with the ROOT of n. Doubling to fifty gets you to about 2.8, '
        'which is most of the effort and none of the answer.',
    source: 'stat-ci-q3',
  ),
  SizeRound(
    subject: 'a survey being retendered to a tighter spec',
    ask: '36 counts give a margin of 6. How many give a margin of 2?',
    k: 36,
    target: 2,
    candidates: [324, 648, 1296],
    from: 0,
    answer: 0,
    why:
        'A third of the margin costs nine times the samples. This is the number '
        'that ends conversations about tightening a spec, and it is worth being '
        'able to produce before the meeting rather than after.',
    source: 'stat-ci-q3',
  ),
  SizeRound(
    subject: 'compressive strength on a small pour',
    ask: 'The margin has to be 50 psi. How many cylinders?',
    k: 196,
    target: 50,
    candidates: [15, 16, 20],
    from: 9,
    answer: 1,
    why:
        'The formula gives 15.37. Fifteen is not enough and sixteen is, and '
        'twenty is paying for precision the specification never asked for.',
    source: 'stat-ci-q3',
  ),
  SizeRound(
    subject: 'a spec that has just been relaxed',
    ask: '64 samples give a margin of 5. How many give a margin of 10?',
    k: 40,
    target: 10,
    candidates: [16, 32, 128],
    from: 0,
    answer: 0,
    why:
        'It runs the other way too. Letting the margin double lets the sample '
        'size drop to a quarter, which is the cheapest saving on the sheet and '
        'the first thing worth asking a client about.',
    source: 'stat-ci-q3',
  ),
  SizeRound(
    subject: 'a material that turns out to vary more than assumed',
    ask:
        '30 samples were planned on sigma = 400. Sigma is really 800, and the '
        'margin must hold. How many samples?',
    k: 1568,
    target: 143.1,
    candidates: [30, 60, 120],
    from: 0,
    answer: 2,
    why:
        'Sigma sits inside the square, so doubling it costs four times the '
        'samples to stand still. Everything in this formula that doubles on the '
        'top costs a factor of four on the bottom.',
    source: 'stat-ci-q1',
  ),
];

class _HowManySamplesGameState extends State<HowManySamplesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-many-samples',
    chapterId: 'statistics',
    total: sizeRounds.length,
    sourceProblemIdOf: (round) => sizeRounds[round].source,
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

  SizeRound get _round => sizeRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Many Samples',
        closing:
            'The margin falls with the root of n, so halving it costs four '
            'times the samples and a third of it costs nine times. And the '
            'answer always rounds UP: a sample size that misses the spec is not '
            'a sample size.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: sampleSizeBrief,
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
            'GET UNDER THE LINE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.ask,
            style: const TextStyle(
              fontSize: 15.5,
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
              height: 230,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: MarginCurvePainter(
                    k: r.k,
                    target: r.target,
                    candidates: r.candidates,
                    nFrom: r.from,
                    nTo: (r.from + (r.candidates.last - r.from) * 1.18).round(),
                    picked: _picked,
                    truth: answered ? r.answer : null,
                    revealed: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < r.candidates.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _CountButton(
                    key: ValueKey('count-$i'),
                    label: '${r.candidates[i]}',
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
              title: _session.correct! ? 'THAT IS ENOUGH' : 'NOT ENOUGH',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }

}

/// The margin a given sample size actually delivers, which is what the picture
/// is drawing and what the tests check.
double marginAt(SizeRound r, int n) => r.k / math.sqrt(n);

class _CountButton extends StatelessWidget {
  const _CountButton({
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
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(label, style: AppTheme.code(size: 16)),
        ),
      ),
    );
  }
}
