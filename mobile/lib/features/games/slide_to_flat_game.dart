import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'calculus_figures.dart';
import 'lesson_brief.dart';

/// Slide to the Flat Spot — the first item for `applications-derivatives`.
///
/// Answered by dragging, which nothing else in the app does, because the thing
/// being taught is a feeling rather than a fact: at the top of a hill and at
/// the bottom of a valley the slope is zero, and everywhere else it is not.
/// The tangent turns under the student's thumb as they move, so "set the
/// derivative to zero" stops being a ritual and becomes something they have
/// watched happen. No arithmetic is asked for, and none is possible.
class SlideToFlatGame extends StatefulWidget {
  const SlideToFlatGame({super.key});

  @override
  State<SlideToFlatGame> createState() => _SlideToFlatGameState();
}

@immutable
class FlatRound {
  const FlatRound({
    required this.ask,
    required this.subject,
    required this.unit,
    required this.poly,
    required this.x0,
    required this.x1,
    required this.startAt,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String ask;

  /// What the curve is a picture of, in the words the lesson uses.
  final String subject;

  /// The label under the axis, so the numbers mean something.
  final String unit;
  final Poly poly;
  final double x0;
  final double x1;

  /// Where the marker starts. Never the answer, and never the same distance
  /// from it twice.
  final int startAt;

  /// Where the slope is actually zero. The test checks this against the
  /// derivative rather than trusting it.
  final int answer;
  final String why;
  final String source;
}

const flatRounds = <FlatRound>[
  FlatRound(
    ask: 'Slide to the top of the hill.',
    subject: r'f(x) = -2x^2 + 16x - 5',
    unit: 'x',
    poly: Poly([-5, 16, -2]),
    x0: 0,
    x1: 8,
    startAt: 1,
    answer: 4,
    why:
        'At the top the tangent is flat, which is what f prime of x equals '
        'zero means. Here that is -4x + 16 = 0, so x = 4. Halving it to 8 is '
        'the classic slip: the 2 in front comes down as well.',
    source: 'math-ad-q1',
  ),
  FlatRound(
    ask: 'Slide to the bottom of the valley.',
    subject: r'C(h) = 3h^2 - 36h + 150',
    unit: 'h, meters',
    poly: Poly([150, -36, 3]),
    x0: 0,
    x1: 12,
    startAt: 11,
    answer: 6,
    why:
        'The cheapest wall is where the cost curve bottoms out and the '
        'tangent goes flat: 6h - 36 = 0, so h = 6 meters. Notice the curve '
        'smiles here, which is the second derivative being positive.',
    source: 'math-ad-q2',
  ),
  FlatRound(
    ask: 'Slide to the local hilltop.',
    subject: r'y(x) = x^3 - 12x^2 + 36x',
    unit: 'x, meters',
    poly: Poly([0, 36, -12, 1]),
    x0: 0,
    x1: 8,
    startAt: 7,
    answer: 2,
    why:
        'This curve goes flat twice. The first one, at x = 2, is the hilltop: '
        'the curve frowns through it. The other flat spot is the valley.',
    source: 'math-ad-q3',
  ),
  FlatRound(
    ask: 'Slide to the low point of the same curve.',
    subject: r'y(x) = x^3 - 12x^2 + 36x',
    unit: 'x, meters',
    poly: Poly([0, 36, -12, 1]),
    x0: 0,
    x1: 8,
    startAt: 1,
    answer: 6,
    why:
        'Both x = 2 and x = 6 make the slope zero. What separates them is the '
        'way the curve bends: it smiles through x = 6, so that is the low '
        'point.',
    source: 'math-ad-q3',
  ),
  FlatRound(
    ask: 'Slide to the peak elevation.',
    subject: r'y(x) = -x^2 + 12x - 20',
    unit: 'station, hundreds of feet',
    poly: Poly([-20, 12, -1]),
    x0: 0,
    x1: 12,
    startAt: 2,
    answer: 6,
    why:
        'The crest of a vertical curve is where its slope, the grade, passes '
        'through zero. Uphill on the left, downhill on the right, flat for an '
        'instant in between.',
    source: 'math-ad-q1',
  ),
  FlatRound(
    ask: 'Slide to the cheapest section.',
    subject: r'C(x) = 2x^2 - 20x + 60',
    unit: 'x, meters',
    poly: Poly([60, -20, 2]),
    x0: 0,
    x1: 10,
    startAt: 9,
    answer: 5,
    why:
        'Flat at x = 5, and the curve smiles through it, so it is a minimum. '
        'What the cheapest section COSTS is a separate question: it comes '
        'from putting 5 back into C.',
    source: 'math-ad-q2',
  ),
];

class _SlideToFlatGameState extends State<SlideToFlatGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'slide-to-flat',
    chapterId: 'mathematics',
    total: flatRounds.length,
    sourceProblemIdOf: (round) => flatRounds[round].source,
  )..addListener(_onSession);

  /// Null until the student moves it: the round's own starting place stands.
  int? _marker;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  FlatRound get _round => flatRounds[_session.round];

  void _dragTo(Offset local, Size box, FlatRound r) {
    if (_session.answered) return;
    final (yLo, yHi) = r.poly.range(r.x0, r.x1);
    final g = CurveGeometry(box, x0: r.x0, x1: r.x1, yLo: yLo, yHi: yHi);
    final x = g.mathX(local.dx).round().clamp(r.x0.toInt(), r.x1.toInt());
    if (x != _marker) setState(() => _marker = x);
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Slide to the Flat Spot',
        closing:
            'Maximum and minimum both sit where the slope is zero. Which one '
            'you are standing on is decided by the way the curve bends, not '
            'by the flat spot itself. Solving for it belongs on paper.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final marker = _marker ?? r.startAt;
    final (yLo, yHi) = r.poly.range(r.x0, r.x1);

    return BoardShell(
      session: _session,
      brief: criticalPointBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _marker = null);
              _session.next();
            }
          : () => _session.submit(ok: marker == r.answer, context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FIND THE FLAT SPOT',
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
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: MathBlock(r.subject, fontSize: 17),
          ),
          const SizedBox(height: 10),
          Text(
            'Drag the marker. The short line is the slope where you are.',
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 240,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: LayoutBuilder(
                  builder: (context, box) {
                    final size = Size(box.maxWidth, box.maxHeight);
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) => _dragTo(d.localPosition, size, r),
                      onHorizontalDragUpdate: (d) =>
                          _dragTo(d.localPosition, size, r),
                      child: CustomPaint(
                        painter: CurvePainter(
                          poly: r.poly,
                          x0: r.x0,
                          x1: r.x1,
                          yLo: yLo,
                          yHi: yHi,
                          markerX: marker.toDouble(),
                          showTangent: true,
                          reveal: answered ? r.answer.toDouble() : null,
                          revealIsRight: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          CurveTicks(x0: r.x0, x1: r.x1, unit: r.unit),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Marker at',
                style: AppTheme.mono(size: 12, color: AppColors.ink2),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.emberBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$marker',
                  style: AppTheme.mono(size: 14, color: AppColors.ember),
                ),
              ),
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'FLAT' : 'STILL SLOPING',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
