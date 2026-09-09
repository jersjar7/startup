import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'normal_figures.dart';

/// Shade the Tail — the third item for `probability-distributions`.
///
/// The lesson's hard problem is a z-score problem, and both of its named traps
/// are about the picture rather than the arithmetic: handing in the pass rate
/// when the question asked for the fail rate, and mistaking the z value for a
/// probability. The dividing line is already drawn here and the z is already
/// computed. What is left is the part the exam actually charges for, which is
/// deciding WHICH area under the curve the sentence just asked for.
///
/// So the answer is a place on the curve. Put a finger on the area you want,
/// and the reveal names the column of the handbook table that hands it to you.
class ShadeTheTailGame extends StatefulWidget {
  const ShadeTheTailGame({super.key});

  @override
  State<ShadeTheTailGame> createState() => _ShadeTheTailGameState();
}

@immutable
class TailRound {
  const TailRound({
    required this.subject,
    required this.ask,
    required this.given,
    required this.cuts,
    required this.labels,
    required this.regions,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String ask;

  /// The mean, the standard deviation and the z, all worked out already.
  final String given;

  /// Where the thresholds sit, in z.
  final List<double> cuts;
  final List<String> labels;
  final List<CurveRegion> regions;
  final int answer;
  final String why;
  final String source;
}

const tailRounds = <TailRound>[
  TailRound(
    subject: '28-day cylinder strength',
    ask: 'What fraction of cylinders FAIL the 4,000 psi specification?',
    given: r'\mu = 4{,}500,\ \sigma = 300,\ z = -1.67',
    cuts: [-1.67],
    labels: ['4,000 psi'],
    regions: [
      CurveRegion(spans: [(zMin, -1.67)], column: r'1 - F(1.67) = 0.0475'),
      CurveRegion(spans: [(-1.67, zMax)], column: r'F(1.67) = 0.9525'),
    ],
    answer: 0,
    why:
        'Failing means weaker than the spec, so it is everything to the LEFT '
        'of the line. The table gives the area left of a POSITIVE z, so this '
        'one comes from the flip: one take F of 1.67.',
    source: 'stat-dist-q3',
  ),
  TailRound(
    subject: 'the same cylinders',
    ask: 'What fraction PASS the specification?',
    given: r'\mu = 4{,}500,\ \sigma = 300,\ z = -1.67',
    cuts: [-1.67],
    labels: ['4,000 psi'],
    regions: [
      CurveRegion(spans: [(zMin, -1.67)], column: r'1 - F(1.67) = 0.0475'),
      CurveRegion(spans: [(-1.67, zMax)], column: r'F(1.67) = 0.9525'),
    ],
    answer: 1,
    why:
        'Same curve, same line, other half. This is the ninety five percent '
        'answer, and handing it in when the question said "fail" is the single '
        'most common way to lose this problem.',
    source: 'stat-dist-q3',
  ),
  TailRound(
    subject: 'signal green time',
    ask: 'What fraction of cycles run LONGER than 40 seconds?',
    given: r'\mu = 32,\ \sigma = 4,\ z = +2.00',
    cuts: [2.0],
    labels: ['40 s'],
    regions: [
      CurveRegion(spans: [(zMin, 2.0)], column: r'F(2.00) = 0.9772'),
      CurveRegion(spans: [(2.0, zMax)], column: r'R(2.00) = 0.0228'),
    ],
    answer: 1,
    why:
        'Longer than means to the right, and the right tail has its own column '
        'in the table. R of z, no flip needed.',
    source: 'stat-dist-q3',
  ),
  TailRound(
    subject: 'asphalt lift thickness',
    ask: 'What fraction fall WITHIN one standard deviation of the mean?',
    given: r'\mu = 2.00\ \text{in},\ \sigma = 0.15\ \text{in}',
    cuts: [-1.0, 1.0],
    labels: ['1.85 in', '2.15 in'],
    regions: [
      CurveRegion(
        spans: [(zMin, -1.0), (1.0, zMax)],
        column: r'1 - W(1.00) = 0.3173',
      ),
      CurveRegion(spans: [(-1.0, 1.0)], column: r'W(1.00) = 0.6827'),
    ],
    answer: 1,
    why:
        'Two lines, one on each side, and the question wants the middle. The '
        'table has a column for exactly this: W of z is the area between minus '
        'z and plus z.',
    source: 'stat-dist-q3',
  ),
  TailRound(
    subject: 'a tolerance band on aggregate gradation',
    ask: 'What fraction fall OUTSIDE the tolerance band?',
    given: r'\mu = 0,\ \text{band at } \pm 1.96\sigma',
    cuts: [-1.96, 1.96],
    labels: ['lower', 'upper'],
    regions: [
      CurveRegion(
        spans: [(zMin, -1.96), (1.96, zMax)],
        column: r'1 - W(1.96) = 0.0500',
      ),
      CurveRegion(spans: [(-1.96, 1.96)], column: r'W(1.96) = 0.9500'),
    ],
    answer: 0,
    why:
        'Out of tolerance is BOTH tails, and they count as one answer because '
        'it is one quantity: whatever the middle does not account for. Take W '
        'away from one.',
    source: 'stat-dist-q3',
  ),
  TailRound(
    subject: 'daily truck counts',
    ask: 'What fraction of days carry MORE than 20 trucks?',
    given: r'\mu = 25,\ \sigma = 4,\ z = -1.25',
    cuts: [-1.25],
    labels: ['20 trucks'],
    regions: [
      CurveRegion(spans: [(zMin, -1.25)], column: r'1 - F(1.25) = 0.1056'),
      CurveRegion(spans: [(-1.25, zMax)], column: r'F(1.25) = 0.8944'),
    ],
    answer: 1,
    why:
        'The line sits BELOW the mean, so z is negative, and the answer is '
        'still the bigger piece. A negative z never means a small answer; it '
        'means the line is on the left.',
    source: 'stat-dist-q3',
  ),
];

class _ShadeTheTailGameState extends State<ShadeTheTailGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'shade-the-tail',
    chapterId: 'statistics',
    total: tailRounds.length,
    sourceProblemIdOf: (round) => tailRounds[round].source,
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

  TailRound get _round => tailRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Shade the Tail',
        closing:
            'The z-score is arithmetic and it belongs on paper. Which area the '
            'sentence wants is the part that gets marked wrong: left of the '
            'line, right of it, between two lines, or everything outside them.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: normalTableBrief,
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
            'PUT A FINGER ON THE AREA',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.ask,
            style: const TextStyle(
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
              height: 230,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: LayoutBuilder(
                  builder: (context, box) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: answered
                        ? null
                        : (down) {
                            final hit = NormalPainter.regionAt(
                              down.localPosition.dx,
                              box.maxWidth,
                              r.regions,
                            );
                            if (hit != null) setState(() => _picked = hit);
                          },
                    child: CustomPaint(
                      painter: NormalPainter(
                        regions: r.regions,
                        cuts: r.cuts,
                        labels: r.labels,
                        picked: _picked,
                        truth: answered ? r.answer : null,
                        revealed: answered,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.creamDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: MathBlock(r.given, fontSize: 15),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            Text(
              'THE TABLE HANDS YOU',
              style: AppTheme.overline(color: AppColors.ink3),
            ),
            const SizedBox(height: 6),
            MathBlock(r.regions[r.answer].column, fontSize: 16),
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE AREA' : 'THE OTHER PIECE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
