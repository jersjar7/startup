import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'kinematics_figures.dart';
import 'lesson_brief.dart';

/// Speeding Up or Turning — the third item for `particle-kinematics`.
///
/// On a curved path the acceleration comes in two pieces at right angles: one
/// along the road that changes how fast you are going, and one square to it,
/// pointing at the middle of the bend, that changes which way you are going.
/// The lesson's hardest problem names both of the mistakes: reporting one
/// piece as the whole thing, and adding two things that sit at right angles.
///
/// The arithmetic is a square root and belongs on paper. Which arrow is which,
/// and whether a thing going round a bend at a steady speed is accelerating at
/// all, is the part worth a phone.
class SpeedingUpOrTurningGame extends StatefulWidget {
  const SpeedingUpOrTurningGame({super.key});

  @override
  State<SpeedingUpOrTurningGame> createState() =>
      _SpeedingUpOrTurningGameState();
}

@immutable
class CornerRound {
  const CornerRound({
    required this.subject,
    required this.setting,
    required this.asked,
    required this.bend,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;

  /// What the round wants tapped.
  final String asked;

  final Bend bend;
  final Piece answer;
  final String why;
  final String source;

  /// The arrows drawn. The total is only worth drawing when both pieces are
  /// there to add.
  List<Piece> get shown => bend.alongRoad == 0
      ? [Piece.toward]
      : [Piece.along, Piece.toward, Piece.total];
}

const cornerRounds = <CornerRound>[
  CornerRound(
    subject: 'a car on a bend, speeding up',
    setting:
        'Thirty meters a second round a two hundred meter bend, and the driver '
        'is pressing on at two meters a second squared.',
    asked: 'Tap the arrow that shows how fast it is GAINING SPEED.',
    bend: Bend(speed: 30, radius: 200, alongRoad: 2),
    answer: Piece.along,
    why:
        'The arrow along the road, and it is the smaller of the two here. '
        'Tangential acceleration is the only piece that changes the reading on '
        'the speedometer. The other arrow is bigger and does nothing to it at '
        'all.',
    source: 'dyn-pk-q3',
  ),
  CornerRound(
    subject: 'the same car',
    setting: 'The same instant on the same bend.',
    asked: 'Tap the arrow that shows how fast it is CHANGING DIRECTION.',
    bend: Bend(speed: 30, radius: 200, alongRoad: 2),
    answer: Piece.toward,
    why:
        'The arrow pointing at the middle of the bend, four and a half meters '
        'a second squared, more than twice the other one. This is v squared '
        'over the radius, and the square is why speed matters so much on a '
        'bend: going half as fast again through the same curve nearly doubles '
        'it.',
    source: 'dyn-pk-q3',
  ),
  CornerRound(
    subject: 'the whole of it',
    setting:
        'Both pieces are drawn. The lesson asks for the size of the total '
        'acceleration.',
    asked: 'Tap the arrow that is the TOTAL acceleration.',
    bend: Bend(speed: 30, radius: 200, alongRoad: 2),
    answer: Piece.total,
    why:
        'The diagonal one, and it is worth seeing why it is not the two added '
        'up. They sit at right angles, so they combine the way the sides of a '
        'right triangle do: four point nine two, not six and a half. The '
        'lesson names both wrong answers, reporting four and a half on its own '
        'and adding the two together.',
    source: 'dyn-pk-q3',
  ),
  CornerRound(
    subject: 'a train at a steady speed',
    setting:
        'A train goes round a six hundred meter curve at a constant twenty '
        'five meters a second. The driver touches nothing.',
    asked:
        'Tap the arrow showing its acceleration, if it has one.',
    bend: Bend(speed: 25, radius: 600, alongRoad: 0),
    answer: Piece.toward,
    why:
        'It has one, pointing at the middle of the curve, and this is the '
        'round worth remembering. Steady speed is not the same as no '
        'acceleration: the direction is changing, and changing direction IS '
        'accelerating. It is what the passengers feel leaning them outward and '
        'what the rails have to push against.',
    source: 'dyn-pk-q3',
  ),
  CornerRound(
    subject: 'braking into a tighter bend',
    setting:
        'Twenty meters a second round an eighty meter bend, braking at three '
        'meters a second squared.',
    asked: 'Tap the arrow that shows how fast it is CHANGING DIRECTION.',
    bend: Bend(speed: 20, radius: 80, alongRoad: -3),
    answer: Piece.toward,
    why:
        'Toward the middle, five meters a second squared, and note that it is '
        'still toward the middle even though the car is slowing down. The '
        'turning piece never points anywhere else. What braking did was turn '
        'the along-the-road arrow around, which is why it now points backward '
        'against the motion.',
    source: 'dyn-pk-q3',
  ),
  CornerRound(
    subject: 'the same braking car',
    setting: 'Same instant, same two pieces.',
    asked: 'Tap the arrow that is the TOTAL acceleration.',
    bend: Bend(speed: 20, radius: 80, alongRoad: -3),
    answer: Piece.total,
    why:
        'The diagonal, leaning backward and inward: five point eight three, '
        'from a three and a five combined as a right triangle. The total '
        'acceleration of something on a bend almost never points where it is '
        'going or where it came from, and the tires have to deliver all of it '
        'through the same patch of road.',
    source: 'dyn-pk-q3',
  ),
];

class _SpeedingUpOrTurningGameState extends State<SpeedingUpOrTurningGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'speeding-up-or-turning',
    chapterId: 'dynamics',
    total: cornerRounds.length,
    sourceProblemIdOf: (round) => cornerRounds[round].source,
  )..addListener(_onSession);

  Piece? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  CornerRound get _round => cornerRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Speeding Up or Turning',
        closing:
            'Along the road changes how fast. Toward the middle of the bend '
            'changes which way, and it is there even at a steady speed. They '
            'sit at right angles, so the total is the two combined as a right '
            'triangle and never the two added up.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: bendBrief,
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
            'TAP AN ARROW ON THE ROAD',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.setting,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            r.asked,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, 210);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: answered
                    ? null
                    : (details) {
                        final hit = BendPainter.nearest(
                          r.bend,
                          size,
                          r.shown,
                          details.localPosition,
                        );
                        if (hit != null) setState(() => _picked = hit);
                      },
                child: EngineeringGrid(
                  minor: 18,
                  major: 90,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: CustomPaint(
                      painter: BendPainter(
                        bend: r.bend,
                        show: r.shown,
                        picked: _picked,
                        truth: answered ? r.answer : null,
                        locked: answered,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$a_t = \dot{v}, \quad a_n = \dfrac{v^2}{\rho}, \quad '
              r'a = \sqrt{a_t^2 + a_n^2}$',
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'A DIFFERENT ARROW',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
