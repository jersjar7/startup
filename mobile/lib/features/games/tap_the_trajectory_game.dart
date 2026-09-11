import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'kinematics_figures.dart';
import 'lesson_brief.dart';

/// Tap the Trajectory — the second item for `particle-kinematics`.
///
/// A projectile is two problems that never speak to each other: across, where
/// nothing changes, and up and down, where gravity is pulling the whole time.
/// Every trap in the lesson's own projectile problem comes from mixing them,
/// starting with using the launch speed where the vertical piece of it
/// belongs.
///
/// So the arc is drawn with five moments marked on it and the question asks
/// which moment something is true at. Nothing is computed.
class TapTheTrajectoryGame extends StatefulWidget {
  const TapTheTrajectoryGame({super.key});

  @override
  State<TapTheTrajectoryGame> createState() => _TapTheTrajectoryGameState();
}

@immutable
class ArcRound {
  const ArcRound({
    required this.subject,
    required this.asked,
    required this.flight,
    required this.answer,
    required this.why,
    required this.source,
    this.everywhere = false,
  });

  final String subject;
  final String asked;
  final Flight flight;

  /// The moment it is true at, or the launch when the answer is really
  /// everywhere and the standing choice is the right one.
  final Moment answer;

  /// True when the honest answer is that it is the same the whole way.
  final bool everywhere;

  final String why;
  final String source;
}

const _lob = Flight(speed: 20, degrees: 60);
const _flat = Flight(speed: 24, degrees: 35);

const arcRounds = <ArcRound>[
  ArcRound(
    subject: 'a ball thrown at sixty degrees',
    asked: 'Tap the moment when the ball is not moving UP or DOWN at all.',
    flight: _lob,
    answer: Moment.apex,
    why:
        'The top. The upward part of the velocity runs steadily down through '
        'zero and out the other side, and the instant it passes zero is the '
        'highest point. That is the fact the lesson\'s own problem turns on: '
        'set the vertical velocity to zero and the height falls out. The ball '
        'is still moving at the top, just not up.',
    source: 'dyn-pk-q2',
  ),
  ArcRound(
    subject: 'the same throw',
    asked: 'Tap the moment when the ball is moving SLOWEST.',
    flight: _lob,
    answer: Moment.apex,
    why:
        'The top again, and for the same reason: the across part of the speed '
        'never changes, so the whole speed is smallest when the up and down '
        'part is nothing. Slowest is not stopped. At the top the ball is still '
        'traveling across at ten meters a second, which is why it lands a long '
        'way from where it left.',
    source: 'dyn-pk-q2',
  ),
  ArcRound(
    subject: 'the same throw again',
    asked:
        'Tap the moment when the ball has the greatest acceleration.',
    flight: _lob,
    answer: Moment.launch,
    everywhere: true,
    why:
        'None of them: the acceleration is the same the whole way, nine point '
        'eight one downward, including at the top. Speed and acceleration are '
        'different things, and at the top the ball has run out of upward speed '
        'while gravity carries on pulling exactly as hard as it did at the '
        'start. That is why it comes back down.',
    source: 'dyn-pk-q2',
  ),
  ArcRound(
    subject: 'a flatter throw',
    asked:
        'Tap the moment when the ball is moving FASTEST across the ground, '
        'ignoring up and down.',
    flight: _flat,
    answer: Moment.launch,
    everywhere: true,
    why:
        'None of them: the across speed never changes at all. There is no '
        'force acting sideways once the ball has left, so that piece of the '
        'motion is the simplest thing in dynamics, a steady walk at a constant '
        'speed, and it is the same at the launch, the top and the landing.',
    source: 'dyn-pk-q2',
  ),
  ArcRound(
    subject: 'the same flatter throw',
    asked:
        'Tap the moment when the ball is falling fastest.',
    flight: _flat,
    answer: Moment.landing,
    why:
        'The landing. Gravity has been adding to the downward speed from the '
        'top onward, so it is biggest at the last instant. On level ground it '
        'comes back exactly as fast as it left, with the vertical part turned '
        'around, which is a handy check on any projectile answer.',
    source: 'dyn-pk-q2',
  ),
  ArcRound(
    subject: 'halfway up',
    asked:
        'Tap the moment when the ball has HALF as much upward speed as it '
        'started with.',
    flight: _lob,
    answer: Moment.rising,
    why:
        'A quarter of the way through the flight. The upward speed falls off '
        'steadily, so it is half gone a quarter of the way along and all gone '
        'at the halfway point, which is the top. Note what that does NOT mean: '
        'the ball is not halfway up. Height goes with the square of the time '
        'left, so at this point it is already three quarters of the way to the '
        'top.',
    source: 'dyn-pk-q2',
  ),
];

class _TapTheTrajectoryGameState extends State<TapTheTrajectoryGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'tap-the-trajectory',
    chapterId: 'dynamics',
    total: arcRounds.length,
    sourceProblemIdOf: (round) => arcRounds[round].source,
  )..addListener(_onSession);

  Moment? _picked;
  bool _pickedNone = false;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ArcRound get _round => arcRounds[_session.round];

  bool get _right =>
      _round.everywhere ? _pickedNone : _picked == _round.answer;

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Tap the Trajectory',
        closing:
            'Across and up and down are two separate problems. Across never '
            'changes. Up and down runs steadily downhill through zero at the '
            'top. The acceleration is the same everywhere, gravity, including '
            'at the moment the ball is slowest. Split them at the start and '
            'never mix them again.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: flightBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() {
                _picked = null;
                _pickedNone = false;
              });
              _session.next();
            }
          : ((_picked == null && !_pickedNone)
                ? null
                : () => _session.submit(ok: _right, context: context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TAP A MOMENT IN THE FLIGHT',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.asked,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, 220);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: answered
                    ? null
                    : (details) {
                        final hit = FlightPainter.nearest(
                          r.flight,
                          size,
                          Moment.values,
                          details.localPosition,
                        );
                        if (hit != null) {
                          setState(() {
                            _picked = hit;
                            _pickedNone = false;
                          });
                        }
                      },
                child: EngineeringGrid(
                  minor: 18,
                  major: 90,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: CustomPaint(
                      painter: FlightPainter(
                        flight: r.flight,
                        moments: Moment.values,
                        picked: _pickedNone ? null : _picked,
                        truth: answered && !r.everywhere ? r.answer : null,
                        locked: answered,
                        showVelocities: answered,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            answered
                ? 'the arrows are the velocity at each moment'
                : 'five moments, from the launch to the landing',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          if (_picked != null && !_pickedNone && !answered) ...[
            const SizedBox(height: 6),
            Text(
              _picked!.plain,
              style: AppTheme.mono(size: 12, color: AppColors.ember),
            ),
          ],
          const SizedBox(height: 12),
          _None(
            selected: _pickedNone,
            locked: answered,
            isTruth: r.everywhere,
            onTap: answered
                ? null
                : () => setState(() {
                      _pickedNone = true;
                      _picked = null;
                    }),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE MOMENT' : 'NOT THERE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _None extends StatelessWidget {
  const _None({
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    if (locked && isTruth) {
      border = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
    } else {
      border = AppColors.line;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: const Text(
            'No single moment: it is the same the whole way',
            style: TextStyle(fontSize: 15, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
