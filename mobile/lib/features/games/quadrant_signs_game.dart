import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'unit_circle_figures.dart';

/// Quadrant Signs — the second item for `unit-circle-trig-identities`.
///
/// Answered by tapping a REGION rather than a point or a line, because the
/// thing being tested is where an angle lives, not a value. It exists for the
/// lesson's own trap: solving the Pythagorean identity gives a plus or minus,
/// and only the quadrant settles which.
class QuadrantSignsGame extends StatefulWidget {
  const QuadrantSignsGame({super.key});

  @override
  State<QuadrantSignsGame> createState() => _QuadrantSignsGameState();
}

@immutable
class QuadrantRound {
  const QuadrantRound({
    required this.ask,
    required this.answer,
    required this.why,
    required this.source,
    this.latex,
  });

  final String ask;
  final String? latex;

  /// 1 to 4.
  final int answer;
  final String why;
  final String source;
}

const quadrantRounds = <QuadrantRound>[
  QuadrantRound(
    ask: 'Sine is positive and cosine is negative. Tap the quadrant.',
    answer: 2,
    why:
        'Up is positive and across is negative only in the second quadrant. '
        'Sine is the up, cosine is the across.',
    source: 'math-uci-q2',
  ),
  QuadrantRound(
    ask: 'Both sine and cosine are negative. Tap the quadrant.',
    answer: 3,
    why:
        'Third quadrant: down and to the left, so both coordinates are '
        'below zero.',
    source: 'math-uci-q2',
  ),
  QuadrantRound(
    ask: 'Cosine is positive and sine is negative. Tap the quadrant.',
    answer: 4,
    why: 'Fourth quadrant: across is still positive, up has gone negative.',
    source: 'math-uci-q2',
  ),
  QuadrantRound(
    ask: 'The angle is 210 degrees. Tap its quadrant.',
    answer: 3,
    why:
        'Past 180 and short of 270 is the third quadrant, where both sine '
        'and cosine are negative.',
    source: 'math-uci-q2',
  ),
  QuadrantRound(
    ask:
        'You solved the Pythagorean identity and got this. The angle is in '
        'the second quadrant, so tap where it lives and read the sign off it.',
    latex: r'\cos\theta = \pm\frac{4}{5}',
    answer: 2,
    why:
        'The identity only ever gives you the size. The quadrant decides the '
        'sign, and in the second quadrant cosine is negative: −4/5. Taking the '
        'positive root is the trap the lesson names.',
    source: 'math-uci-q2',
  ),
  QuadrantRound(
    ask: 'Sine and cosine are both positive. Tap the quadrant.',
    answer: 1,
    why: 'First quadrant, where every trig function is positive.',
    source: 'math-uci-q1',
  ),
];

class _QuadrantSignsGameState extends State<QuadrantSignsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'quadrant-signs',
    chapterId: 'mathematics',
    total: quadrantRounds.length,
    sourceProblemIdOf: (round) => quadrantRounds[round].source,
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

  QuadrantRound get _round => quadrantRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Quadrant Signs',
        closing:
            'The identity gives you the size, the quadrant gives you the '
            'sign. Forgetting the second half is how a right answer turns '
            'into a wrong one.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: quadrantBrief,
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
            'WHERE DOES IT LIVE',
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
          if (r.latex != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: Center(child: MathBlock(r.latex!, fontSize: 20)),
            ),
          ],
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, 290);
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: answered
                        ? null
                        : (details) {
                            final hit = CircleGeometry(
                              size,
                            ).quadrantAt(details.localPosition);
                            if (hit != null) setState(() => _picked = hit);
                          },
                    child: EngineeringGrid(
                      minor: 20,
                      major: 100,
                      child: CustomPaint(
                        painter: UnitCirclePainter(
                          quadrantLabels: true,
                          highlightQuadrant: answered ? r.answer : _picked,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'CORRECT' : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
