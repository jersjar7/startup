import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'survey_figures.dart';

/// Which Length Is Which — the third item for `angles-distances-bearings`.
///
/// A shot up a hillside makes a right triangle, and three different lengths
/// come out of it: what the instrument measured along the line of sight,
/// what the plan wants across the ground, and how much higher one end is
/// than the other. The lesson's problem is a cosine, which is paper work.
/// What is not paper work is knowing which of the three you are being asked
/// for, because every trap on that problem is a length swapped for its
/// neighbor.
class WhichLengthIsWhichGame extends StatefulWidget {
  const WhichLengthIsWhichGame({super.key});

  @override
  State<WhichLengthIsWhichGame> createState() =>
      _WhichLengthIsWhichGameState();
}

@immutable
class ShotRound {
  const ShotRound({
    required this.subject,
    required this.setting,
    required this.sight,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Sight sight;
  final Side3 answer;
  final String why;
  final String source;
}

const shotRounds = <ShotRound>[
  ShotRound(
    subject: 'the lesson\'s own shot',
    setting:
        'The total station reads 250.00 meters up an 8 degree angle. The '
        'plan of the site needs a length. Tap the one it needs.',
    sight: Sight(slope: 250, angle: 8),
    answer: Side3.flat,
    why:
        'The horizontal one, along the bottom. A plan is a view from '
        'straight above, so every length on it is the flat one, whatever the '
        'ground does in between. That is the 247.56 in the lesson, and it is '
        'shorter than the 250 the instrument read, as the flat side of a '
        'right triangle always is.',
    source: 'surv-adb-q2',
  ),
  ShotRound(
    subject: 'what the instrument actually read',
    setting:
        'Before any conversion, tap the length the total station measured '
        'when it sent its beam to the prism.',
    sight: Sight(slope: 250, angle: 8),
    answer: Side3.slope,
    why:
        'The sloping one, along the line of sight. An EDM measures the '
        'straight line from itself to the prism and nothing else. Everything '
        'else on this drawing is worked out afterward, which is why the '
        'slope distance is the number you should expect to be given and '
        'never the number the question wants.',
    source: 'surv-adb-q2',
  ),
  ShotRound(
    subject: 'how much higher the far point is',
    setting:
        'The two ends are at different elevations. Tap the length that is '
        'the difference between them.',
    sight: Sight(slope: 180, angle: 14),
    answer: Side3.rise,
    why:
        'The upright one at the far end. This is the sine of the angle times '
        'the slope distance, and on the lesson\'s own shot it is 34.79 '
        'meters, which is offered there as a wrong answer to the horizontal '
        'question. It is a perfectly good number. It is an answer to a '
        'different question.',
    source: 'surv-adb-q2',
  ),
  ShotRound(
    subject: 'a shot downhill',
    setting:
        'The prism is below the instrument this time, 12 degrees down. The '
        'plan still needs its length. Tap it.',
    sight: Sight(slope: 210, angle: -12),
    answer: Side3.flat,
    why:
        'The horizontal one again. Downhill changes the sign of the '
        'elevation difference and changes nothing else: the flat distance is '
        'still the slope distance times the cosine, and it is still shorter '
        'than the slope distance. Cosine does not care which way the angle '
        'goes.',
    source: 'surv-adb-q2',
  ),
  ShotRound(
    subject: 'dragging a tape over the ground',
    setting:
        'Forget the instrument. A crew chains this line with a tape laid '
        'along the ground. Tap what their tape reads.',
    sight: Sight(slope: 160, angle: 18),
    answer: Side3.slope,
    why:
        'The sloping one. A tape pulled along sloping ground measures the '
        'slope distance just as the beam does, which is why chained lengths '
        'on a hill have to be reduced before they can go on a plan. It is '
        'the same correction and the same cosine.',
    source: 'surv-adb-q2',
  ),
  ShotRound(
    subject: 'the longest of the three',
    setting:
        'A steep shot, 32 degrees up. Tap whichever of the three lengths is '
        'the longest, whatever the numbers turn out to be.',
    sight: Sight(slope: 140, angle: 32),
    answer: Side3.slope,
    why:
        'The sloping one, always. It is the hypotenuse, so it is longer than '
        'either of the other two no matter how steep or how flat the ground '
        'is. That is the sense check on the lesson\'s trap of dividing by the '
        'cosine instead of multiplying: it returns a flat distance LONGER '
        'than the slope distance, which cannot happen.',
    source: 'surv-adb-q2',
  ),
];

class _WhichLengthIsWhichGameState extends State<WhichLengthIsWhichGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-length-is-which',
    chapterId: 'surveying',
    total: shotRounds.length,
    sourceProblemIdOf: (round) => shotRounds[round].source,
  )..addListener(_onSession);

  Side3? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ShotRound get _round => shotRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Length Is Which',
        closing:
            'One shot, three lengths. The instrument and the tape both read '
            'the sloping one, the plan wants the flat one, and the upright '
            'one is the difference in elevation. The sloping one is the '
            'longest of the three every time, which catches the mistake of '
            'dividing by the cosine instead of multiplying by it.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: shotBrief,
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
            'TAP THE LENGTH IT NAMES',
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
          const SizedBox(height: 12),
          _Hill(
            sight: r.sight,
            picked: _picked,
            answer: r.answer,
            locked: answered,
            onPick: answered ? null : (s) => setState(() => _picked = s),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$HD = SD\cos\alpha \qquad VD = SD\sin\alpha$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'ANOTHER SIDE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Hill extends StatelessWidget {
  const _Hill({
    required this.sight,
    required this.picked,
    required this.answer,
    required this.locked,
    required this.onPick,
  });

  final Sight sight;
  final Side3? picked;
  final Side3 answer;
  final bool locked;
  final void Function(Side3)? onPick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final size = Size(box.maxWidth, 220);
        return GestureDetector(
          onTapUp: onPick == null
              ? null
              : (details) {
                  final hit =
                      SlopePainter.at(size, sight, details.localPosition);
                  if (hit != null) onPick!(hit);
                },
          child: Container(
            height: size.height,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: SlopePainter(
                    sight: sight,
                    picked: picked,
                    answer: locked ? answer : null,
                    locked: locked,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
