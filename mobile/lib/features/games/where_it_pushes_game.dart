import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'fluid_figures.dart';
import 'lesson_brief.dart';

/// Where It Pushes — the first item for `hydrostatic-forces-buoyancy`.
///
/// Two depths matter on a submerged gate and they are not the same one. The
/// force is worked out from the pressure at the CENTROID, and it acts lower
/// down, at the center of pressure. Both of this lesson's first two problems
/// are lost between those two facts, and the whole thing is a picture: the
/// pressure grows with depth, so the push is bottom heavy, so the resultant
/// sits below the middle.
class WhereItPushesGame extends StatefulWidget {
  const WhereItPushesGame({super.key});

  @override
  State<WhereItPushesGame> createState() => _WhereItPushesGameState();
}

@immutable
class GateRound {
  const GateRound({
    required this.subject,
    required this.asked,
    required this.gate,
    required this.among,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Gate gate;
  final List<Mark3> among;
  final Mark3 answer;
  final String why;
  final String source;
}

/// The lesson's own gate: two meters by three, top edge at the surface.
const _lessonGate = Gate(wide: 2, tall: 3);

/// The same gate with its top two meters under.
const _sunkGate = Gate(wide: 2, tall: 3, topDepth: 2);

/// And dropped to the bottom of a deep reservoir.
const _deepGate = Gate(wide: 2, tall: 3, topDepth: 12);

const pushRounds2 = <GateRound>[
  GateRound(
    subject: 'the lesson\'s gate',
    asked:
        'The force is the pressure at one of these depths times the area. Tap '
        'the depth it uses.',
    gate: _lessonGate,
    among: [Mark3.topEdge, Mark3.centroid, Mark3.pressure, Mark3.bottomEdge],
    answer: Mark3.centroid,
    why:
        'The centroid, halfway down a gate whose top is at the surface. The '
        'pressure there is the AVERAGE pressure on the face, which is why '
        'multiplying it by the area gives the whole force: 9,810 times 1.5 '
        'times 6, about 88 kilonewtons. Using the bottom instead doubles it, '
        'which is that problem\'s named trap.',
    source: 'fm-hfb-q1',
  ),
  GateRound(
    subject: 'the same gate again',
    asked: 'Tap the point where that resultant force actually acts.',
    gate: _lessonGate,
    among: [Mark3.topEdge, Mark3.centroid, Mark3.pressure, Mark3.bottomEdge],
    answer: Mark3.pressure,
    why:
        'Lower down, at the center of pressure: two meters, which is two '
        'thirds of the way down this gate. Look at the pressure arrows to see '
        'why. There is far more push near the bottom than the top, so the '
        'resultant of them sits below the middle. The force is worked out AT '
        'the centroid and applied BELOW it.',
    source: 'fm-hfb-q2',
  ),
  GateRound(
    subject: 'which of the two is deeper',
    asked:
        'Tap whichever of these two sits deeper on this gate, the centroid or '
        'the center of pressure.',
    gate: _lessonGate,
    among: [Mark3.centroid, Mark3.pressure],
    answer: Mark3.pressure,
    why:
        'The center of pressure, always. The offset between them is the '
        'second moment of the face over the centroid depth times the area, '
        'and every one of those is positive, so the answer can never come out '
        'above the centroid. If yours does, the arithmetic went wrong '
        'somewhere.',
    source: 'fm-hfb-q2',
  ),
  GateRound(
    subject: 'a gate with its top two meters under',
    asked:
        'The same gate, now drowned. Tap the depth that goes into the force '
        'formula.',
    gate: _sunkGate,
    among: [Mark3.topEdge, Mark3.centroid, Mark3.bottomEdge],
    answer: Mark3.centroid,
    why:
        'Still the centroid, which is now three and a half meters down: the '
        'top edge plus half the height. Nothing about the formula changed '
        'when the gate went under. What changed is the number, and this gate '
        'takes more than twice the force the surface-topped one did.',
    source: 'fm-hfb-q1',
  ),
  GateRound(
    subject: 'the same gate, far deeper',
    asked:
        'Now the gate sits twelve meters down. Tap the depth the force '
        'formula uses.',
    gate: _deepGate,
    among: [Mark3.topEdge, Mark3.centroid, Mark3.bottomEdge],
    answer: Mark3.centroid,
    why:
        'The centroid again, at 13.5 meters. Worth knowing what happened to '
        'the center of pressure down here: the offset is the same 4.5 over '
        'the centroid depth times the area, and with the depth that large it '
        'has shrunk to about 6 centimeters. Deep gates are very nearly '
        'uniformly loaded, so the two points all but meet.',
    source: 'fm-hfb-q2',
  ),
  GateRound(
    subject: 'where it does not act',
    asked:
        'Somebody has taken moments about the hinge using the bottom edge. '
        'Tap where the resultant really acts on this gate.',
    gate: _lessonGate,
    among: [Mark3.topEdge, Mark3.centroid, Mark3.pressure, Mark3.bottomEdge],
    answer: Mark3.pressure,
    why:
        'At the center of pressure, a third of the height up from the bottom. '
        'This is the one that costs marks on an overturning check: the '
        'magnitude can be perfect and the moment still wrong, because the arm '
        'was measured to the wrong point. Force from the centroid, moment '
        'from the center of pressure.',
    source: 'fm-hfb-q2',
  ),
];

class _WhereItPushesGameState extends State<WhereItPushesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'where-it-pushes',
    chapterId: 'fluid-mechanics',
    total: pushRounds2.length,
    sourceProblemIdOf: (round) => pushRounds2[round].source,
  )..addListener(_onSession);

  Mark3? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  GateRound get _round => pushRounds2[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Where It Pushes',
        closing:
            'The force comes from the pressure at the CENTROID times the '
            'area, and it acts lower, at the center of pressure, because the '
            'push is bottom heavy. For a gate with its top at the surface '
            'that is two thirds of the way down. The deeper the gate, the '
            'smaller the gap between the two, until on a deep gate they are '
            'centimeters apart.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: gateBrief,
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
            'TAP THE POINT ON THE GATE',
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
              final size = Size(box.maxWidth, 260);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: answered
                    ? null
                    : (details) {
                        final hit = GatePainter.nearest(
                            size, r.gate, r.among, details.localPosition);
                        if (hit != null) setState(() => _picked = hit);
                      },
                child: EngineeringGrid(
                  minor: 18,
                  major: 90,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: CustomPaint(
                      painter: GatePainter(
                        gate: r.gate,
                        among: r.among,
                        picked: _picked,
                        answer: r.answer,
                        locked: answered,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'the arrows are the water pressure, growing with depth',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
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
