import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'statics_figures.dart';

/// Which Distance Counts — the second item for `force-systems-resultants`.
///
/// The moment arm is the perpendicular distance from the point to the line of
/// action, and every wrong answer in the lesson's crane problem is a different
/// real distance on the same drawing: the length of the boom, and the boom's
/// other projection. Neither is wrong as a measurement. They are answers to
/// questions nobody asked.
///
/// So all of them are drawn, and the question is which one counts. The line of
/// action is dashed across the figure, because the arm cannot be found without
/// it and drawing it is most of the work. One round has the line running
/// straight through the point, where the answer is that there is no arm at
/// all, and one is a couple, where the arm is the gap between the two forces
/// and the point does not matter.
class WhichDistanceCountsGame extends StatefulWidget {
  const WhichDistanceCountsGame({super.key});

  @override
  State<WhichDistanceCountsGame> createState() =>
      _WhichDistanceCountsGameState();
}

@immutable
class ArmRound {
  const ArmRound({
    required this.subject,
    required this.setting,
    required this.scene,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Scene scene;

  /// Which mark is the moment arm. Null when the line of action runs through
  /// the point and there is no arm to find.
  final int? answer;

  final String why;
  final String source;
}

/// The row under every figure, for a force that turns nothing.
const noArm = 'None. It makes no moment about that point';

const armRounds = <ArmRound>[
  ArmRound(
    subject: 'a crane boom carrying a load',
    setting:
        'A ten meter boom stands at 40 degrees and a 5,000 newton load hangs '
        'straight down from the tip. Moments are about the pivot at the base.',
    scene: Scene(
      members: [
        [Offset(0, 0), Offset(7.66, 6.43)],
      ],
      pivot: Offset(0, 0),
      forces: [StaticForce(Offset(7.66, 6.43), Offset(0, -1), '5,000 N')],
      marks: [
        Mark(Offset(0, 0), Offset(7.66, 6.43), '10 m'),
        Mark(Offset(0, 0), Offset(7.66, 0), '7.66 m'),
        Mark(Offset(0, 0), Offset(0, 6.43), '6.43 m'),
      ],
    ),
    answer: 1,
    why:
        'The horizontal one. The load hangs vertically, so its line of action '
        'is vertical, and the perpendicular distance to a vertical line is a '
        'HORIZONTAL distance. The ten meter boom is the distance to where the '
        'force is applied, which is a different thing and the answer people '
        'hand in.',
    source: 'stat-fsr-q3',
  ),
  ArmRound(
    subject: 'wind on a leaning sign post',
    setting:
        'The post leans two meters out over seven meters of height, and the '
        'wind pushes horizontally on the sign at the top. Moments are about '
        'the base.',
    scene: Scene(
      members: [
        [Offset(0, 0), Offset(2, 7)],
      ],
      pivot: Offset(0, 0),
      forces: [StaticForce(Offset(2, 7), Offset(1, 0), 'wind')],
      marks: [
        Mark(Offset(0, 0), Offset(0, 7), '7 m'),
        Mark(Offset(0, 0), Offset(2, 7), '7.28 m'),
        Mark(Offset(0, 0), Offset(2, 0), '2 m'),
      ],
    ),
    answer: 0,
    why:
        'The vertical one, and it is the same rule as the crane turned ninety '
        'degrees: a horizontal force has a vertical arm. The two meters is the '
        'perpendicular distance to a VERTICAL force, and there is not one here.',
    source: 'stat-fsr-q3',
  ),
  ArmRound(
    subject: 'a strut pushing at the pin',
    setting:
        'The strut carries load straight along its own length, aimed at the '
        'pin it is pinned to. Moments are about that pin.',
    scene: Scene(
      members: [
        [Offset(0, 0), Offset(6, 3)],
      ],
      pivot: Offset(0, 0),
      forces: [StaticForce(Offset(6, 3), Offset(-6, -3), 'F')],
      marks: [
        Mark(Offset(0, 0), Offset(6, 0), '6 m'),
        Mark(Offset(0, 0), Offset(6, 3), '6.7 m'),
        Mark(Offset(0, 0), Offset(0, 3), '3 m'),
      ],
    ),
    answer: null,
    why:
        'None of them. Follow the dashed line: it runs straight through the '
        'pin, so the perpendicular distance from the pin to it is zero and the '
        'force turns nothing. A force can be enormous and still make no moment '
        'if it is pointed at the point you are taking moments about.',
    source: 'stat-fsr-q3',
  ),
  ArmRound(
    subject: 'a bracket pulled on the corner',
    setting:
        'The bracket goes five meters up and four meters across, and the cable '
        'at the corner pulls down and out at 45 degrees. Moments are about the '
        'base.',
    scene: Scene(
      members: [
        [Offset(0, 0), Offset(0, 5), Offset(4, 5)],
      ],
      pivot: Offset(0, 0),
      forces: [StaticForce(Offset(4, 5), Offset(1, -1), 'cable')],
      marks: [
        Mark(Offset(0, 0), Offset(4, 0), '4 m'),
        Mark(Offset(0, 0), Offset(0, 5), '5 m'),
        Mark(Offset(0, 0), Offset(4.5, 4.5), '6.36 m',
            place: MarkPlace.inPlace),
      ],
    ),
    answer: 2,
    why:
        'The one drawn square to the dashed line, and it is LONGER than either '
        'of the projections. An arm is not a shortcut for a smaller distance: '
        'it is whatever runs perpendicular from the point to the line, and on '
        'an inclined force that is neither the height nor the reach.',
    source: 'stat-fsr-q3',
  ),
  ArmRound(
    subject: 'a couple on a wrench bar',
    setting:
        'Two equal and opposite forces, four meters apart, on a bar pinned two '
        'meters from the first of them. Take the moment of the PAIR together, '
        'not of either one on its own.',
    scene: Scene(
      members: [
        [Offset(0, 0), Offset(10, 0)],
      ],
      pivot: Offset(2, 0),
      forces: [
        StaticForce(Offset(4, 0), Offset(0, 1), 'F', lineOfAction: false),
        StaticForce(Offset(8, 0), Offset(0, -1), 'F', lineOfAction: false),
      ],
      marks: [
        Mark(Offset(2, 0), Offset(4, 0), '2 m'),
        Mark(Offset(4, 0), Offset(8, 0), '4 m'),
        Mark(Offset(2, 0), Offset(8, 0), '6 m'),
      ],
    ),
    answer: 1,
    why:
        'The gap between the two forces. A couple has the same moment about '
        'every point there is, so where the pin sits changes nothing, and the '
        'two distances measured from it are both beside the point. Work them '
        'through separately and the pin distances cancel down to the gap.',
    source: 'stat-fsr-q3',
  ),
  ArmRound(
    subject: 'the same crane, pulled sideways',
    setting:
        'The same ten meter boom at 40 degrees, but now the pull at the tip is '
        'horizontal rather than hanging. Moments about the base again.',
    scene: Scene(
      members: [
        [Offset(0, 0), Offset(7.66, 6.43)],
      ],
      pivot: Offset(0, 0),
      forces: [StaticForce(Offset(7.66, 6.43), Offset(1, 0), 'pull')],
      marks: [
        Mark(Offset(0, 0), Offset(7.66, 0), '7.66 m'),
        Mark(Offset(0, 0), Offset(7.66, 6.43), '10 m'),
        Mark(Offset(0, 0), Offset(0, 6.43), '6.43 m'),
      ],
    ),
    answer: 2,
    why:
        'The vertical one. Same boom, same tip, same three distances as the '
        'first round, and the arm has moved because the force turned. The arm '
        'belongs to the LINE OF ACTION, not to the member it is applied to.',
    source: 'stat-fsr-q3',
  ),
];

class _WhichDistanceCountsGameState extends State<WhichDistanceCountsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-distance-counts',
    chapterId: 'statics',
    total: armRounds.length,
    sourceProblemIdOf: (round) => armRounds[round].source,
  )..addListener(_onSession);

  int? _picked;
  bool _none = false;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ArmRound get _round => armRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Distance Counts',
        closing:
            'Draw the line of action first. The arm is whatever runs square '
            'from the point to that line, which is a horizontal distance for a '
            'vertical force and a vertical one for a horizontal force. It can '
            'be longer than the member, and if the line goes through the '
            'point there is no moment at all.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: momentBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() {
                _picked = null;
                _none = false;
              });
              _session.next();
            }
          : (_picked == null && !_none
                ? null
                : () => _session.submit(
                    ok: _none ? r.answer == null : _picked == r.answer,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TAP THE MOMENT ARM',
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
          _Figure(
            scene: r.scene,
            picked: _none ? null : _picked,
            locked: answered,
            truth: r.answer ?? -1,
            onTap: answered
                ? null
                : (i) => setState(() {
                      _none = false;
                      _picked = i;
                    }),
          ),
          const SizedBox(height: 8),
          _NoArmRow(
            selected: _none,
            locked: answered,
            isTruth: r.answer == null,
            onTap: answered
                ? null
                : () => setState(() {
                      _picked = null;
                      _none = !_none;
                    }),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT DISTANCE' : 'A DIFFERENT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

/// The figure, with a tap zone lying over each dimension line.
///
/// The zones are worked out from the same transform the painter uses, so a
/// mark and its target cannot drift apart.
class _Figure extends StatelessWidget {
  const _Figure({
    required this.scene,
    required this.picked,
    required this.locked,
    required this.truth,
    required this.onTap,
  });

  final Scene scene;
  final int? picked;
  final bool locked;
  final int truth;
  final void Function(int)? onTap;

  static const _height = 260.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: _height,
        width: double.infinity,
        child: EngineeringGrid(
          minor: 20,
          major: 100,
          child: LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, _height);
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: MomentPainter(
                        scene: scene,
                        mode: SceneMode.marks,
                        selected: picked,
                        chosen: const {},
                        locked: locked,
                        truth: truth,
                        truths: const {},
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  for (var i = 0; i < scene.marks.length; i++)
                    _zone(i, size),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _zone(int i, Size size) {
    // Straight from the same placement the painter draws, so a target cannot
    // sit somewhere its dimension line does not.
    final (from, to) = scene.placedMarks(size)[i];

    final left = math.min(from.dx, to.dx) - 6;
    final right = math.max(from.dx, to.dx) + 6;
    final top = math.min(from.dy, to.dy) - 6;
    final bottom = math.max(from.dy, to.dy) + 6;
    // A thin line needs a thicker target than it draws, but not so thick that
    // two stacked dimensions start covering each other.
    final width = math.max(right - left, 44.0);
    final height = math.max(bottom - top, 30.0);

    return Positioned(
      key: ValueKey('mark-$i'),
      left: (left + right) / 2 - width / 2,
      top: (top + bottom) / 2 - height / 2,
      width: width,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null ? null : () => onTap!(i),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _NoArmRow extends StatelessWidget {
  const _NoArmRow({
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
      key: const ValueKey('no-arm'),
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 50,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            noArm,
            style: const TextStyle(fontSize: 14.5, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
