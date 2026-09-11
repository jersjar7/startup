import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'rotation_figures.dart';

/// Same Spin, Different Speed — the first item for
/// `rigid-body-kinematics-mass-moi`.
///
/// One spinning body has ONE angular velocity and as many speeds as it has
/// points, because v is r times omega and every point sits at its own r. That
/// is the whole of the lesson's second problem once the units are sorted out,
/// and the units are arithmetic.
///
/// So the body is drawn with points marked on it and the answer is which point
/// the question is about, with a standing choice for the questions whose
/// honest answer is that every point is the same.
class SameSpinDifferentSpeedGame extends StatefulWidget {
  const SameSpinDifferentSpeedGame({super.key});

  @override
  State<SameSpinDifferentSpeedGame> createState() =>
      _SameSpinDifferentSpeedGameState();
}

@immutable
class SpinRound {
  const SpinRound({
    required this.subject,
    required this.asked,
    required this.spinner,
    required this.answer,
    required this.why,
    required this.source,
    this.everywhere = false,
    this.arm = false,
  });

  final String subject;
  final String asked;
  final Spinner spinner;

  /// Which marked point, or anything when the honest answer is that they all
  /// share it.
  final int answer;

  /// True when the standing choice is the right one.
  final bool everywhere;

  /// Drawn as a swinging arm rather than as a wheel.
  final bool arm;

  final String why;
  final String source;
}

const _wheel = Spinner(
  rpm: 3600,
  radius: 0.15,
  marks: [(0.15, 20), (0.10, 150), (0.05, 265)],
);

/// Two marks at the same radius and nothing else, for the round about where a
/// point sits AROUND the circle. Offering a third at a different radius would
/// have made the question about something else.
const _rimPair = Spinner(
  rpm: 3600,
  radius: 0.15,
  marks: [(0.15, 35), (0.15, 215)],
);

const _boom = Spinner(
  rpm: 2,
  radius: 12,
  marks: [(12, 0), (8, 0), (6, 0), (3, 0)],
);

const spinRounds = <SpinRound>[
  SpinRound(
    subject: 'a grinding wheel at 3,600 rpm',
    asked: 'Tap the point on the wheel that is moving FASTEST.',
    spinner: _wheel,
    answer: 0,
    why:
        'The one on the rim. Speed is the radius times the angular velocity, '
        'so the further out a point sits the faster it travels: the rim of '
        'this wheel is doing about fifty six meters a second while the mark '
        'nearest the middle is under twenty, and they are the same piece of '
        'steel turning together.',
    source: 'dyn-rbk-q2',
  ),
  SpinRound(
    subject: 'the same wheel',
    asked:
        'Tap the point with the greatest ANGULAR velocity, how fast it is '
        'going round.',
    spinner: _wheel,
    answer: 0,
    everywhere: true,
    why:
        'None of them: every point on a rigid body shares one angular '
        'velocity. They all get round once in the same time, so they all turn '
        'through the same angle every second. That is what makes a body rigid, '
        'and it is why omega belongs to the wheel while v belongs to a point.',
    source: 'dyn-rbk-q2',
  ),
  SpinRound(
    subject: 'the same wheel again',
    asked:
        'Tap the point being pulled hardest toward the middle.',
    spinner: _wheel,
    answer: 0,
    why:
        'The rim again. The acceleration toward the middle is r omega '
        'squared, so it grows with the radius just as the speed does, and it '
        'is what tears a grinding wheel apart if it is spun too fast: three '
        'times the radius here is three times the pull.',
    source: 'dyn-rbk-q2',
  ),
  SpinRound(
    subject: 'two points on the rim',
    asked:
        'Both marked points sit on the rim, on opposite sides. Tap the faster '
        'of the two.',
    spinner: _rimPair,
    answer: 0,
    everywhere: true,
    why:
        'Neither: they are the same. Where a point sits around the circle '
        'makes no difference at all, only how far out it is. The two rim '
        'points are traveling in different DIRECTIONS at this instant, which '
        'is a real difference and not a difference in speed.',
    source: 'dyn-rbk-q2',
  ),
  SpinRound(
    subject: 'a crane boom swinging at 2 rpm',
    asked: 'Tap the place on the boom that is moving fastest.',
    spinner: _boom,
    arm: true,
    answer: 0,
    why:
        'The tip, twelve meters out. Two turns a minute sounds gentle and the '
        'tip is still doing about two and a half meters a second, which is a '
        'brisk walk with a load hanging off it. The same slow rotation is '
        'almost nothing at the mast.',
    source: 'dyn-rbk-q2',
  ),
  SpinRound(
    subject: 'half the speed',
    asked:
        'Tap the place on the boom moving at HALF the speed of the tip.',
    spinner: _boom,
    arm: true,
    answer: 2,
    why:
        'Six meters out, halfway along. Speed runs straight with the radius, '
        'with no square anywhere, so half the distance from the pivot is '
        'exactly half the speed. The pull toward the middle is the one that '
        'goes with the square, and at six meters that is a QUARTER of what the '
        'tip feels, not a half.',
    source: 'dyn-rbk-q2',
  ),
];

class _SameSpinDifferentSpeedGameState
    extends State<SameSpinDifferentSpeedGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'same-spin-different-speed',
    chapterId: 'dynamics',
    total: spinRounds.length,
    sourceProblemIdOf: (round) => spinRounds[round].source,
  )..addListener(_onSession);

  int? _picked;
  bool _pickedNone = false;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SpinRound get _round => spinRounds[_session.round];

  bool get _right => _round.everywhere ? _pickedNone : _picked == _round.answer;

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Same Spin, Different Speed',
        closing:
            'One body, one angular velocity, and a different speed at every '
            'radius. Speed is r omega and the pull toward the middle is r '
            'omega squared, so both grow as you go out and neither depends on '
            'where a point sits around the circle. And rpm is not omega: it '
            'takes two pi over sixty to get there.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: spinBrief,
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
            'TAP A POINT ON THE BODY',
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
              final size = Size(box.maxWidth, r.arm ? 150 : 230);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: answered
                    ? null
                    : (details) {
                        final hit = SpinnerPainter.nearest(
                          r.spinner,
                          size,
                          details.localPosition,
                          arm: r.arm,
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
                      painter: SpinnerPainter(
                        spinner: r.spinner,
                        picked: _pickedNone ? null : _picked,
                        truth: answered && !r.everywhere ? r.answer : null,
                        locked: answered,
                        arm: r.arm,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Center(
            child: MathText(
              r'$v = r\omega, \quad a_n = r\omega^2$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
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
              title: _session.correct! ? 'THAT IS THE POINT' : 'NOT THAT ONE',
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
            'No single point: they are equal on this',
            style: TextStyle(fontSize: 15, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
