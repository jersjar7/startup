import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'grid_figures.dart';
import 'lesson_brief.dart';

/// Place the Center — the first item for `circles-conics`.
///
/// Answered by putting a finger on a coordinate grid, which is what the
/// content asks for: reading a center off an equation is a spatial claim, and
/// picking a pair of numbers out of a list lets a student who has the sign
/// backwards get there by elimination. Here the sign is the answer.
class PlaceTheCenterGame extends StatefulWidget {
  const PlaceTheCenterGame({super.key});

  @override
  State<PlaceTheCenterGame> createState() => _PlaceTheCenterGameState();
}

@immutable
class CenterRound {
  const CenterRound({
    required this.equation,
    required this.center,
    required this.radius,
    required this.why,
    required this.source,
  });

  final String equation;

  /// The center the equation describes.
  final (int, int) center;
  final double radius;
  final String why;
  final String source;
}

const centerRounds = <CenterRound>[
  CenterRound(
    equation: r'(x-5)^2 + (y+3)^2 = 64',
    center: (5, -3),
    radius: 8,
    why:
        'The sign inside flips: (y + 3) is (y − (−3)), so k is −3. And 64 is '
        'r squared, which makes the radius 8, not 64.',
    source: 'math-cc-q1',
  ),
  CenterRound(
    equation: r'(x+2)^2 + (y-4)^2 = 9',
    center: (-2, 4),
    radius: 3,
    why:
        'A plus inside means a negative coordinate and a minus means a '
        'positive one. Radius 3, because 9 is the square.',
    source: 'math-cc-q1',
  ),
  CenterRound(
    equation: r'x^2 + (y+6)^2 = 25',
    center: (0, -6),
    radius: 5,
    why:
        'No bracket on x means h is zero: the center sits on the y-axis, six '
        'below the origin.',
    source: 'math-cc-q1',
  ),
  CenterRound(
    equation: r'(x+6)^2 + (y+1)^2 = 4',
    center: (-6, -1),
    radius: 2,
    why: 'Both signs are plus, so both coordinates are negative. Radius 2.',
    source: 'math-cc-q1',
  ),
  CenterRound(
    equation: r'(x-3)^2 + (y-3)^2 = 49',
    center: (3, 3),
    radius: 7,
    why: 'Both minus, so both positive. The radius is 7, not 49.',
    source: 'math-cc-q1',
  ),
  CenterRound(
    equation: r'(x+4)^2 + y^2 = 16',
    center: (-4, 0),
    radius: 4,
    why: 'No bracket on y puts the center on the x-axis, four to the left.',
    source: 'math-cc-q1',
  ),
  CenterRound(
    equation: r'(x-5)^2 + (y+3)^2 = 16',
    center: (5, -3),
    radius: 4,
    why:
        'Same center as the first round with a different right-hand side: the '
        'number on the right changes the size, never the place.',
    source: 'math-cc-q2',
  ),
  CenterRound(
    equation: r'(x-2)^2 + (y+5)^2 = 36',
    center: (2, -5),
    radius: 6,
    why: 'Two across, five down, radius 6.',
    source: 'math-cc-q1',
  ),
];

class _PlaceTheCenterGameState extends State<PlaceTheCenterGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'place-the-center',
    chapterId: 'mathematics',
    total: centerRounds.length,
    sourceProblemIdOf: (round) => centerRounds[round].source,
  )..addListener(_onSession);

  (int, int)? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  CenterRound get _round => centerRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Place the Center',
        closing:
            'The sign inside the bracket is the opposite of the '
            'coordinate, and the number on the right is the radius squared. '
            'Those two are most of what circles are worth on the exam.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: circleFormBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _picked = null);
              _session.next();
            }
          : (_picked == null
                ? null
                : () => _session.submit(
                    ok: _picked == r.center,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PUT A FINGER ON THE CENTER',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Center(child: MathBlock(r.equation, fontSize: 21)),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, box.maxWidth);
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: ColoredBox(
                    color: AppColors.white,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: answered
                          ? null
                          : (details) {
                              final hit = GridGeometry(
                                size,
                              ).nearest(details.localPosition);
                              if (hit != null) setState(() => _picked = hit);
                            },
                      child: CustomPaint(
                        painter: GridPainter(
                          picked: _picked,
                          truth: r.center,
                          revealed: answered,
                          radius: r.radius,
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
              title: _session.correct! ? 'CORRECT' : 'NOT THERE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
