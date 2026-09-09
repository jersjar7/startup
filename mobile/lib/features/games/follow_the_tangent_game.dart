import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'calculus_figures.dart';
import 'lesson_brief.dart';
import 'root_figures.dart';

/// Follow the Tangent — the first item for `numerical-methods`.
///
/// Newton's method is a formula that hides a picture: slide down the tangent
/// until it meets the axis, and stand there. Every mistake the lesson names is
/// a mistake about the picture. Adding the correction instead of subtracting
/// sends you the wrong way along the tangent. Reaching for the root itself is
/// forgetting that ONE iteration only gets you as far as the tangent goes. And
/// a nearly flat tangent, which is what a derivative near zero means, meets
/// the axis a very long way off, which is the whole of the warning about
/// divergence. So the tangent is drawn and the student says where it lands.
class FollowTheTangentGame extends StatefulWidget {
  const FollowTheTangentGame({super.key});

  @override
  State<FollowTheTangentGame> createState() => _FollowTheTangentGameState();
}

@immutable
class TangentRound {
  const TangentRound({
    required this.shown,
    required this.poly,
    required this.start,
    required this.from,
    required this.to,
    required this.candidates,
    required this.answer,
    required this.why,
    required this.source,
  });

  /// The function as it is written on the card.
  final String shown;
  final Poly poly;

  /// Where this iteration starts.
  final double start;

  /// The span of x on screen.
  final double from;
  final double to;

  /// Places on the axis worth pointing at. Every one of them is somewhere a
  /// real mistake would put you.
  final List<double> candidates;
  final int answer;
  final String why;
  final String source;

  /// What one iteration actually gives, worked out from the curve rather than
  /// taken on trust.
  double get step => poly.at(start) / poly.d.at(start);
  double get next => start - step;
}

const tangentRounds = <TangentRound>[
  TangentRound(
    shown: r'f(x) = x^2 - 4',
    poly: Poly([-4, 0, 1]),
    start: 4,
    from: 0,
    to: 6.5,
    candidates: [2, 2.5, 4, 5.5],
    answer: 1,
    why:
        'The tangent at 4 meets the axis at 2.5, and that is where one '
        'iteration leaves you. The root is at 2 and you are not there yet; '
        'one step of Newton gets you closer, not finished.',
    source: 'math-num-q1',
  ),
  TangentRound(
    shown: r'f(x) = x^2 - 16',
    poly: Poly([-16, 0, 1]),
    start: 8,
    from: 0,
    to: 12,
    candidates: [4, 5, 8, 11],
    answer: 1,
    why:
        'Forty eight over sixteen is three, taken AWAY from eight. Eleven is '
        'what adding it gives, and it walks you away from the root instead of '
        'towards it.',
    source: 'math-num-q1',
  ),
  TangentRound(
    shown: r'f(x) = 2x - 6',
    poly: Poly([-6, 2]),
    start: 1,
    from: -2,
    to: 5,
    candidates: [-1, 1, 3],
    answer: 2,
    why:
        'When the function IS a straight line, the tangent is the function, so '
        'one iteration lands exactly on the root. This is the best case '
        'Newton has and it is why the method converges so fast near a root, '
        'where every curve is nearly straight.',
    source: 'math-num-q3',
  ),
  TangentRound(
    shown: r'f(x) = x^2 - 9',
    poly: Poly([-9, 0, 1]),
    start: 6,
    from: 0,
    to: 9,
    candidates: [3, 3.75, 6, 8.25],
    answer: 1,
    why:
        'Twenty seven over twelve is 2.25, so the tangent lands at 3.75 with '
        'the root at 3 still ahead. A second iteration from here would land '
        'much closer, which is what fast convergence looks like.',
    source: 'math-num-q1',
  ),
  TangentRound(
    shown: r'f(x) = x^2 - 4',
    poly: Poly([-4, 0, 1]),
    start: 0.5,
    from: -4,
    to: 6,
    candidates: [-3.25, 0.5, 2, 4.25],
    answer: 3,
    why:
        'Here the slope is only 1, so the tangent is nearly flat and it takes '
        'a very long walk to reach the axis. One step throws you from 0.5 all '
        'the way to 4.25, further from the root than you started. This is the '
        'divergence the lesson warns about, and a flat derivative is what '
        'causes it.',
    source: 'math-num-q3',
  ),
  TangentRound(
    shown: r'f(x) = 4 - x^2',
    poly: Poly([4, 0, -1]),
    start: 4,
    from: 0,
    to: 6.5,
    candidates: [2, 2.5, 4, 5.5],
    answer: 1,
    why:
        'Upside down, and nothing changes. The function and its slope are '
        'both negative now, and the two minus signs cancel in the division, '
        'so the step is the same size and the same direction as the first '
        'round.',
    source: 'math-num-q1',
  ),
];

class _FollowTheTangentGameState extends State<FollowTheTangentGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'follow-the-tangent',
    chapterId: 'mathematics',
    total: tangentRounds.length,
    sourceProblemIdOf: (round) => tangentRounds[round].source,
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

  TangentRound get _round => tangentRounds[_session.round];

  static String _write(double v) =>
      v == v.roundToDouble() ? '${v.toInt()}' : '$v';

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Follow the Tangent',
        closing:
            'One iteration slides down the tangent to the axis and stops '
            'there. It lands short of the root, on the far side of a flat '
            'slope, or exactly on it if the function was a line. Grinding out '
            'the arithmetic belongs at a desk.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: newtonBrief,
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
            'ONE ITERATION, ON THE PICTURE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Where does one step of Newton leave you?',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: MathBlock(
              '${r.shown}, \\quad x_0 = ${_write(r.start)}',
              fontSize: 16,
            ),
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
                  painter: RootPainter(
                    poly: r.poly,
                    x0: r.from,
                    x1: r.to,
                    tangentAt: r.start,
                    candidates: r.candidates,
                    picked: _picked,
                    truth: answered ? r.answer : null,
                    revealed: answered,
                  ),
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
                  child: _LandingButton(
                    key: ValueKey('landing-$i'),
                    label: _write(r.candidates[i]),
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
              title: _session.correct! ? 'THAT IS THE LANDING' : 'NOT THERE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _LandingButton extends StatelessWidget {
  const _LandingButton({
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
          child: Text(
            label,
            style: AppTheme.mono(size: 15, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
