import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'momentum_figures.dart';

/// Which One Needs a Block — the second item for `momentum-equation`.
///
/// The lesson's application line is thrust blocks and restrained joints, and
/// the momentum equation is how you decide where they go. The rule is short
/// and it is not obvious: pressure alone does not push a main anywhere,
/// because it pushes equally in every direction. A net force appears only
/// where the water is made to change direction, change speed, or stop. A
/// plain joint in a straight length of one bore carries nothing, whatever
/// the pressure in it.
class WhichOneNeedsABlockGame extends StatefulWidget {
  const WhichOneNeedsABlockGame({super.key});

  @override
  State<WhichOneNeedsABlockGame> createState() =>
      _WhichOneNeedsABlockGameState();
}

@immutable
class TrunkRound {
  const TrunkRound({
    required this.subject,
    required this.setting,
    required this.trunk,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Trunk trunk;
  final String why;
  final String source;

  /// Read off the run rather than declared beside it.
  int get answer => trunk.culprit;
}

const anchorRounds = <TrunkRound>[
  TrunkRound(
    subject: 'a main under a street',
    setting:
        'Three hundred millimeter main, the same bore the whole way, one '
        'pressure throughout. Which marked place has to be held?',
    trunk: Trunk(
      legs: [
        Leg(heading: Heading.east),
        Leg(heading: Heading.east),
        Leg(heading: Heading.east),
        Leg(heading: Heading.north),
      ],
    ),
    why:
        'The bend at 3. Pressure by itself pushes a straight pipe nowhere: it '
        'presses outward on every part of the wall, and those pushes cancel '
        'along the line. At the bend they stop cancelling, because the water '
        'leaves heading somewhere else, and what is left is a shove on the '
        'outside of the turn. Joints 1 and 2 are plain joints in a straight '
        'length and carry nothing.',
    source: 'fm-me-q2',
  ),
  TrunkRound(
    subject: 'a straight run that changes bore',
    setting:
        'No bends anywhere. The main runs four hundred millimeter, then two '
        'hundred and fifty.',
    trunk: Trunk(
      legs: [
        Leg(heading: Heading.east, bore: 400),
        Leg(heading: Heading.east, bore: 400),
        Leg(heading: Heading.east, bore: 250),
        Leg(heading: Heading.east, bore: 250),
      ],
    ),
    why:
        'The reducer at 2. A change of bore is a change of speed, and a '
        'change of speed is a change of momentum even though nothing has '
        'turned. The pressure faces no longer match either: there is more '
        'area facing one way than the other. That is the same sum as the '
        'lesson\'s fire hose nozzle, which is a reducer with the far end '
        'open.',
    source: 'fm-me-q3',
  ),
  TrunkRound(
    subject: 'a main stopped off for a future phase',
    setting:
        'The same bore all the way, and the end is capped, waiting on the '
        'next phase of the subdivision.',
    trunk: Trunk(
      legs: [
        Leg(heading: Heading.east),
        Leg(heading: Heading.east),
        Leg(heading: Heading.east),
      ],
      capped: true,
    ),
    why:
        'The cap at 3. A dead end is the hardest case in the list: the water '
        'stops entirely, and the full pressure stands on the whole face of '
        'the cap with nothing on the far side to answer it. Capped ends blow '
        'off unrestrained mains more often than bends do. The two joints '
        'behind it carry nothing.',
    source: 'fm-me-q1',
  ),
  TrunkRound(
    subject: 'the turn at the start',
    setting:
        'The main comes in from the west, turns, and then runs a long way '
        'north at the same bore.',
    trunk: Trunk(
      legs: [
        Leg(heading: Heading.east),
        Leg(heading: Heading.north),
        Leg(heading: Heading.north),
        Leg(heading: Heading.north),
      ],
    ),
    why:
        'The bend at 1. The two joints up the long straight length are not '
        'doing anything, however long that length is and however high the '
        'pressure in it. Length is not in the momentum equation at all. Only '
        'the change is, and the only change on this run happens at the '
        'corner.',
    source: 'fm-me-q2',
  ),
  TrunkRound(
    subject: 'a turn down the hill',
    setting:
        'Two hundred and fifty millimeter throughout. The run comes in level '
        'and then turns away south.',
    trunk: Trunk(
      legs: [
        Leg(heading: Heading.east, bore: 250),
        Leg(heading: Heading.east, bore: 250),
        Leg(heading: Heading.south, bore: 250),
        Leg(heading: Heading.south, long: 1.5, bore: 250),
      ],
    ),
    why:
        'The bend at 2. Which WAY it turns makes no difference to whether it '
        'needs holding: any turn leaves a net push, and the push always runs '
        'out along the outside of the turn. A block goes on the outside face '
        'of this one, on the far side from the corner.',
    source: 'fm-me-q2',
  ),
  TrunkRound(
    subject: 'the last length before the hydrant',
    setting:
        'Three hundred millimeter main running straight, narrowing to one '
        'hundred and fifty at the last joint.',
    trunk: Trunk(
      legs: [
        Leg(heading: Heading.east),
        Leg(heading: Heading.east),
        Leg(heading: Heading.east),
        Leg(heading: Heading.east, bore: 150),
      ],
    ),
    why:
        'The reducer at 3. It is easy to look for a corner and stop looking '
        'when there is not one. The three things that leave a net force are a '
        'change of direction, a change of speed, and a stop, and this run has '
        'the second of them at its last joint.',
    source: 'fm-me-q3',
  ),
];

class _WhichOneNeedsABlockGameState extends State<WhichOneNeedsABlockGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-one-needs-a-block',
    chapterId: 'fluid-mechanics',
    total: anchorRounds.length,
    sourceProblemIdOf: (round) => anchorRounds[round].source,
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

  TrunkRound get _round => anchorRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which One Needs a Block',
        closing:
            'Pressure on its own moves nothing: it presses every way at once '
            'and cancels along a straight pipe. A net force turns up only '
            'where the water changes direction, changes speed, or stops. '
            'Bends, reducers and dead ends get held. Plain joints in a '
            'straight length do not, at any pressure.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: thrustBrief,
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
            'TAP THE PLACE THAT NEEDS HOLDING',
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
          _Plan(
            trunk: r.trunk,
            picked: _picked,
            locked: answered,
            onPick: answered ? null : (i) => setState(() => _picked = i),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'SOMEWHERE ELSE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Plan extends StatelessWidget {
  const _Plan({
    required this.trunk,
    required this.picked,
    required this.locked,
    required this.onPick,
  });

  final Trunk trunk;
  final int? picked;
  final bool locked;
  final void Function(int)? onPick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final size = Size(box.maxWidth, 230);
        return GestureDetector(
          onTapUp: onPick == null
              ? null
              : (details) {
                  final hit =
                      TrunkPainter.at(size, trunk, details.localPosition);
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
                  painter: TrunkPainter(
                    trunk: trunk,
                    picked: picked,
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
