import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'unit_circle_figures.dart';

/// Walk the Circle — the first item for `unit-circle-trig-identities`.
///
/// A new way to answer, because the content asks for it: the answer is a
/// PLACE ON A CIRCLE. Half the rounds give an angle and want the point, half
/// give the coordinates and want the angle they belong to, which is the
/// lesson's own sin-and-cos confusion put where it cannot be guessed from a
/// list of four.
class WalkTheCircleGame extends StatefulWidget {
  const WalkTheCircleGame({super.key});

  @override
  State<WalkTheCircleGame> createState() => _WalkTheCircleGameState();
}

@immutable
class CircleRound {
  const CircleRound({
    required this.ask,
    required this.answer,
    required this.choices,
    required this.why,
    required this.source,
    this.latex,
  });

  final String ask;

  /// The angle, in degrees, whose point is the answer.
  final int answer;

  /// The angles offered as dots on the rim this round.
  final List<int> choices;

  /// Coordinates shown above the circle, when the round works backwards.
  final String? latex;
  final String why;
  final String source;
}

const quarters = [0, 90, 180, 270];
const eighths = [0, 45, 90, 135, 180, 225, 270, 315];
const twelfths = [0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330];

const circleRounds = <CircleRound>[
  CircleRound(
    ask: 'Tap the point at 60 degrees.',
    answer: 60,
    choices: twelfths,
    why:
        'At 60 degrees the point is (1/2, √3/2). Cosine is the across, sine '
        'is the up, and this is the pair the exam asks for most.',
    source: 'math-uci-q1',
  ),
  CircleRound(
    ask: 'Tap the point where the across and the up are equal.',
    answer: 45,
    choices: eighths,
    why:
        'At 45 degrees both coordinates are √2/2, which is the only place in '
        'the first quadrant where cosine and sine agree.',
    source: 'math-uci-q1',
  ),
  CircleRound(
    ask: 'Tap the point these coordinates belong to.',
    latex: r'\left(\tfrac{1}{2},\; \tfrac{\sqrt{3}}{2}\right)',
    answer: 60,
    choices: twelfths,
    why:
        'Cosine is the x-coordinate, so a half across and √3/2 up is 60 '
        'degrees. Reading it the other way gives 30, which is the trap.',
    source: 'math-uci-q1',
  ),
  CircleRound(
    ask: 'Tap the point these coordinates belong to.',
    latex: r'\left(\tfrac{\sqrt{3}}{2},\; \tfrac{1}{2}\right)',
    answer: 30,
    choices: twelfths,
    why:
        'Most of the way across and only half way up is the shallow angle, '
        '30 degrees. This and 60 are the pair students swap.',
    source: 'math-uci-q1',
  ),
  CircleRound(
    ask: 'Tap the point where cosine is zero.',
    answer: 90,
    choices: quarters,
    why:
        'Straight up: nothing across, all the way up. Cosine is the across, '
        'so it is zero and sine is one.',
    source: 'math-uci-q1',
  ),
  CircleRound(
    ask: 'Tap the point at 135 degrees.',
    answer: 135,
    choices: eighths,
    why:
        'Second quadrant, the mirror of 45. Across is negative, up is still '
        'positive: (−√2/2, √2/2).',
    source: 'math-uci-q2',
  ),
  CircleRound(
    ask: 'Tap the point where both coordinates are negative.',
    answer: 225,
    choices: eighths,
    why:
        'Third quadrant. Both across and up are below zero there, so sine '
        'and cosine are both negative.',
    source: 'math-uci-q2',
  ),
  CircleRound(
    ask: 'Tap the point at 300 degrees.',
    answer: 300,
    choices: twelfths,
    why:
        'Fourth quadrant: across is positive, up is negative. Cosine is a '
        'half, sine is −√3/2.',
    source: 'math-uci-q2',
  ),
];

/// The point's coordinates, written the way the handbook writes them.
String _coordinatesOf(int degrees) {
  final point = unitCirclePoints[degrees];
  if (point == null) return '';
  return r'\left(' + point.$1 + r',\;' + point.$2 + r'\right)';
}

class _WalkTheCircleGameState extends State<WalkTheCircleGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'walk-the-circle',
    chapterId: 'mathematics',
    total: circleRounds.length,
    sourceProblemIdOf: (round) => circleRounds[round].source,
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

  CircleRound get _round => circleRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Walk the Circle',
        closing:
            'Cosine is the across, sine is the up, and the quadrant '
            'decides the signs. Knowing where a point sits is what makes the '
            'exact values worth memorising.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: unitCircleBrief,
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
            'FIND IT ON THE CIRCLE',
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
              final size = Size(box.maxWidth, 300);
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
                            ).angleNearest(details.localPosition, r.choices);
                            if (hit != null) setState(() => _picked = hit);
                          },
                    child: EngineeringGrid(
                      minor: 20,
                      major: 100,
                      child: CustomPaint(
                        painter: UnitCirclePainter(
                          choices: r.choices,
                          picked: _picked,
                          truth: r.answer,
                          revealed: answered,
                          showRayTo: answered ? r.answer : _picked,
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
              title: _session.correct! ? 'CORRECT' : 'NOT THAT POINT',
              body: r.why,
            ),
            const SizedBox(height: 12),
            Center(child: MathBlock(_coordinatesOf(r.answer), fontSize: 19)),
          ],
        ],
      ),
    );
  }
}
