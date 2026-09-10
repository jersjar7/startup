import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'friction_figures.dart';
import 'lesson_brief.dart';

/// Which Side Is Tight — the second item for `friction`.
///
/// The lesson's tip callout says it outright: before the belt formula is any
/// use at all, work out which end is the tight one, and it is the end in the
/// direction the belt is trying to slip. Get that backward and every number
/// after it is upside down, because the two tensions differ by a factor that
/// on a real capstan runs into the hundreds.
///
/// So nothing is computed here. A drum is drawn with the belt on it, chevrons
/// on the belt say which way it is creeping, and the answer is tapping the end
/// that carries the bigger pull. The second round is the first round's picture
/// with the chevrons reversed, which is the whole rule in one comparison.
class WhichSideIsTightGame extends StatefulWidget {
  const WhichSideIsTightGame({super.key});

  @override
  State<WhichSideIsTightGame> createState() => _WhichSideIsTightGameState();
}

@immutable
class LapRound {
  const LapRound({
    required this.subject,
    required this.setting,
    required this.lap,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Lap lap;
  final String why;
  final String source;

  /// Worked out from which way the belt is creeping and where each end sits,
  /// never declared beside the round.
  bool get answer => lap.tightIsEnd;
}

const lapRounds = <LapRound>[
  LapRound(
    subject: 'a rope round a bollard',
    setting:
        'A mooring line is taken half a turn round a bollard on the quay. The '
        'ship is drifting off and dragging the rope round the post the way the '
        'chevrons show. A dockhand holds the other end.',
    lap: Lap(
      startDeg: 90,
      sweepDeg: 180,
      creep: Creep.counter,
      startLabel: 'the dockhand',
      endLabel: 'the ship',
    ),
    why:
        'The ship, every time. Friction drags backward on the rope the whole '
        'way round the post, so the pull grows from the end the rope is coming '
        'from to the end it is heading toward. That is the point of a bollard: '
        'the dockhand holds a little and the post holds the rest.',
    source: 'stat-fri-q2',
  ),
  LapRound(
    subject: 'the same rope, creeping the other way',
    setting:
        'The same line on the same bollard, but now a tug has taken up the '
        'slack and the rope is creeping round the post the opposite way.',
    lap: Lap(
      startDeg: 90,
      sweepDeg: 180,
      creep: Creep.clockwise,
      startLabel: 'the dockhand',
      endLabel: 'the ship',
    ),
    why:
        'The dockhand now, and the picture has not changed at all. Only the '
        'chevrons did. The tight side is not a place on the drawing and it is '
        'not whichever line looks busier: it is wherever the belt is being '
        'dragged toward.',
    source: 'stat-fri-q2',
  ),
  LapRound(
    subject: 'a brake band on a drum',
    setting:
        'A steel band lies against a turning drum. One end is bolted to the '
        'frame, the other is pulled by the brake lever. The drum is dragging '
        'the band the way the chevrons show.',
    lap: Lap(
      startDeg: 200,
      sweepDeg: 140,
      creep: Creep.clockwise,
      startLabel: 'the anchor bolt',
      endLabel: 'the lever',
    ),
    why:
        'The anchor bolt. The drum drags the band toward that end, so that is '
        'where the tension has been piling up, and it is why the bolt is the '
        'fat part of a band brake and the lever is not. Design the bolt for '
        'the lever force and it shears off.',
    source: 'stat-fri-q2',
  ),
  LapRound(
    subject: 'a rope over a pipe',
    setting:
        'A rope runs along the ground, up over a scaffold pipe and away. It '
        'only touches the pipe for a quarter turn. A load on one end is '
        'winning and the rope is creeping as the chevrons show.',
    lap: Lap(
      startDeg: 270,
      sweepDeg: 90,
      creep: Creep.counter,
      startLabel: 'the laborer',
      endLabel: 'the load',
    ),
    why:
        'The load. A quarter turn is not much contact and the rule does not '
        'care how much there is: less lap only means the two pulls are closer '
        'together, never that they swap places. Which side is tight and how '
        'much bigger it is are two separate questions.',
    source: 'stat-fri-q2',
  ),
  LapRound(
    subject: 'two and a half turns round a post',
    setting:
        'The same rope taken round and round the post instead. The load is '
        'still trying to run away in the same direction.',
    lap: Lap(
      startDeg: 90,
      sweepDeg: 900,
      creep: Creep.counter,
      startLabel: 'one hand',
      endLabel: 'the load',
    ),
    why:
        'Still the load, and now by an enormous margin. The lap angle goes '
        'into an exponent, so turns multiply rather than add and a couple more '
        'of them let one hand hold something no one could lift. What did not '
        'change is which end is tight.',
    source: 'stat-fri-q2',
  ),
  LapRound(
    subject: 'a capstan being hauled in',
    setting:
        'A line is taken well over half a turn round a powered capstan. The '
        'capstan is winning and drawing the line in the direction the chevrons '
        'show.',
    lap: Lap(
      startDeg: 45,
      sweepDeg: 200,
      creep: Creep.clockwise,
      startLabel: 'the winch drum',
      endLabel: 'the anchor chain',
    ),
    why:
        'The winch drum end, because that is where the line is being pulled '
        'toward. The anchor chain is heavy and looks like the serious end, and '
        'looking is not the test. Find the chevrons, follow them, and the end '
        'they point at is the one carrying more.',
    source: 'stat-fri-q2',
  ),
];

class _WhichSideIsTightGameState extends State<WhichSideIsTightGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-side-is-tight',
    chapterId: 'statics',
    total: lapRounds.length,
    sourceProblemIdOf: (round) => lapRounds[round].source,
  )..addListener(_onSession);

  bool? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  LapRound get _round => lapRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Side Is Tight',
        closing:
            'The tight side is the end the belt is being dragged toward. Find '
            'that before anything else, because the formula puts the tight '
            'side on the left and the slack side on the right, and swapping '
            'them turns a holding force into a fraction of one. Then, and only '
            'then, put the lap angle into radians.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: beltBrief,
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
            'TAP THE END CARRYING MORE',
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
          const SizedBox(height: 10),
          _Drum(
            round: r,
            picked: _picked,
            locked: answered,
            onTap: answered ? null : (e) => setState(() => _picked = e),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE TIGHT SIDE' : 'THE OTHER END',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Drum extends StatelessWidget {
  const _Drum({
    required this.round,
    required this.picked,
    required this.locked,
    required this.onTap,
  });

  final LapRound round;
  final bool? picked;
  final bool locked;
  final void Function(bool)? onTap;

  static const _height = 270.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: _height,
        width: double.infinity,
        child: EngineeringGrid(
          minor: 18,
          major: 90,
          child: LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, _height);
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: DrumPainter(
                        lap: round.lap,
                        picked: picked,
                        locked: locked,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  _target(false, size),
                  _target(true, size),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _target(bool isEnd, Size size) {
    final at = DrumPainter.endPoint(round.lap, size, isEnd);
    const box = 52.0;
    return Positioned(
      key: ValueKey('end-$isEnd'),
      left: at.dx - box / 2,
      top: at.dy - box / 2,
      width: box,
      height: box,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null ? null : () => onTap!(isEnd),
        child: const SizedBox.expand(),
      ),
    );
  }
}
