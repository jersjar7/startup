import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'survey_figures.dart';

/// Find It on the Plan — the first item for `angles-distances-bearings`.
///
/// A bearing is two pieces of information wearing one hat: the quadrant it
/// starts and finishes in, and the angle turned off the meridian. Both of
/// the lesson's named traps come from reading one and assuming the other, so
/// the rounds put the same angle in more than one quadrant and make the
/// reader find the line that is actually described. Nothing here is
/// computed. It is map reading, which is most of what surveying asks of
/// anybody.
class FindItOnThePlanGame extends StatefulWidget {
  const FindItOnThePlanGame({super.key});

  @override
  State<FindItOnThePlanGame> createState() => _FindItOnThePlanGameState();
}

@immutable
class PlanRound {
  const PlanRound({
    required this.subject,
    required this.wanted,
    required this.shots,
    required this.why,
    required this.source,
  });

  final String subject;

  /// The bearing the round asks for, in the surveyor's own words.
  final Bearing wanted;
  final List<Shot> shots;
  final String why;
  final String source;

  /// Worked out by matching the drawing to the bearing, never declared.
  int get answer => shots.indexWhere((s) =>
      s.bearing.quad == wanted.quad && s.bearing.degrees == wanted.degrees);
}

const planRounds = <PlanRound>[
  PlanRound(
    subject: 'the lesson\'s own bearing',
    wanted: Bearing(Quad.ne, 52),
    shots: [
      Shot(bearing: Bearing(Quad.ne, 52), name: 'A'),
      Shot(bearing: Bearing(Quad.se, 52), name: 'B'),
      Shot(bearing: Bearing(Quad.sw, 52), name: 'C'),
      Shot(bearing: Bearing(Quad.nw, 52), name: 'D'),
    ],
    why:
        'A. Every one of these four lines is 52 degrees off the meridian, so '
        'the angle tells you nothing on its own: the quadrant is doing all '
        'the work. Read it as an instruction. N 52 E means stand facing '
        'north and turn 52 degrees toward the east, which lands up and to '
        'the right. Its azimuth is the same 52, and that is the lesson\'s '
        'own answer.',
    source: 'surv-adb-q1',
  ),
  PlanRound(
    subject: 'south and west',
    wanted: Bearing(Quad.sw, 30),
    shots: [
      Shot(bearing: Bearing(Quad.ne, 30), name: 'A'),
      Shot(bearing: Bearing(Quad.nw, 30), name: 'B'),
      Shot(bearing: Bearing(Quad.sw, 30), name: 'C'),
      Shot(bearing: Bearing(Quad.se, 30), name: 'D'),
    ],
    why:
        'C, down and to the left. The first letter says which end of the '
        'meridian you start from, and S means you are facing south before '
        'you turn at all. The second letter says which way you turn. Both '
        'letters point away from north here, which is the case people get '
        'backwards most often.',
    source: 'surv-adb-q1',
  ),
  PlanRound(
    subject: 'north and west',
    wanted: Bearing(Quad.nw, 68),
    shots: [
      Shot(bearing: Bearing(Quad.nw, 68), name: 'A'),
      Shot(bearing: Bearing(Quad.sw, 68), name: 'B'),
      Shot(bearing: Bearing(Quad.ne, 68), name: 'C'),
      Shot(bearing: Bearing(Quad.se, 68), name: 'D'),
    ],
    why:
        'A. Sixty-eight degrees is most of a right angle, so the line lies '
        'nearly along the east and west line and only a little north of it. '
        'A bearing near 90 is nearly square to the meridian, and one near 0 '
        'is nearly along it. That is worth knowing as a sense check before '
        'any number is written down.',
    source: 'surv-adb-q1',
  ),
  PlanRound(
    subject: 'a shallow angle',
    wanted: Bearing(Quad.se, 15),
    shots: [
      Shot(bearing: Bearing(Quad.sw, 15), name: 'A'),
      Shot(bearing: Bearing(Quad.se, 15), name: 'B'),
      Shot(bearing: Bearing(Quad.nw, 15), name: 'C'),
      Shot(bearing: Bearing(Quad.ne, 15), name: 'D'),
    ],
    why:
        'B, almost straight down the sheet and leaning slightly east. S 15 E '
        'is a line that very nearly runs due south, and its azimuth is 165: '
        'the 180 that would be due south, less the 15 it leans back toward '
        'the east.',
    source: 'surv-adb-q1',
  ),
  PlanRound(
    subject: 'the same quadrant twice',
    wanted: Bearing(Quad.ne, 20),
    shots: [
      Shot(bearing: Bearing(Quad.ne, 70), name: 'A'),
      Shot(bearing: Bearing(Quad.ne, 20), name: 'B'),
      Shot(bearing: Bearing(Quad.nw, 20), name: 'C'),
      Shot(bearing: Bearing(Quad.se, 20), name: 'D'),
    ],
    why:
        'B. Two of these are in the north-east quadrant, so this time the '
        'quadrant is not enough either and the angle has to be read as well. '
        'N 20 E hugs the meridian. N 70 E, the other north-east line, is '
        'swung most of the way round to the east.',
    source: 'surv-adb-q1',
  ),
  PlanRound(
    subject: 'a steep one in the third quadrant',
    wanted: Bearing(Quad.sw, 75),
    shots: [
      Shot(bearing: Bearing(Quad.nw, 75), name: 'A'),
      Shot(bearing: Bearing(Quad.sw, 15), name: 'B'),
      Shot(bearing: Bearing(Quad.se, 75), name: 'C'),
      Shot(bearing: Bearing(Quad.sw, 75), name: 'D'),
    ],
    why:
        'D. Both B and D start from south and turn west, and only the angle '
        'separates them: 75 degrees swings almost all the way round to due '
        'west, while 15 barely leaves the meridian. The azimuth of the one '
        'you want is 180 plus 75, which is 255.',
    source: 'surv-adb-q1',
  ),
];

class _FindItOnThePlanGameState extends State<FindItOnThePlanGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'find-it-on-the-plan',
    chapterId: 'surveying',
    total: planRounds.length,
    sourceProblemIdOf: (round) => planRounds[round].source,
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

  PlanRound get _round => planRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Find It on the Plan',
        closing:
            'A bearing is an instruction: face the letter it starts with, '
            'turn that many degrees toward the letter it ends with, and stop. '
            'It never exceeds a right angle, so the quadrant carries half the '
            'meaning and the angle carries the other half. Read both before '
            'reaching for any conversion.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: bearingBrief,
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
            'TAP THE LINE THAT MATCHES',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              r.wanted.plain,
              style: AppTheme.mono(size: 22, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          _Plan(
            shots: r.shots,
            picked: _picked,
            answer: r.answer,
            locked: answered,
            onPick: answered ? null : (i) => setState(() => _picked = i),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE LINE' : 'ANOTHER LINE',
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
    required this.shots,
    required this.picked,
    required this.answer,
    required this.locked,
    required this.onPick,
  });

  final List<Shot> shots;
  final int? picked;
  final int answer;
  final bool locked;
  final void Function(int)? onPick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final size = Size(box.maxWidth, 270);
        return GestureDetector(
          onTapUp: onPick == null
              ? null
              : (details) {
                  final hit = RosePainter.at(size, shots, details.localPosition);
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
                  painter: RosePainter(
                    shots: shots,
                    picked: picked,
                    answer: locked ? answer : null,
                    locked: locked,
                    arcOn: locked ? answer : null,
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
