import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'cogo_figures.dart';

/// Which Way Are You Working — the first item for `coordinate-geometry`.
///
/// Coordinate work runs in two directions and the formulas are the same two
/// either way round. Forward takes a point you hold and a course you
/// measured and gives you a point you did not have. Inverse takes two points
/// you hold and gives you the course between them, which is what staking
/// out is. Telling them apart is a matter of looking at what is already
/// known: count the points with coordinates on them.
class WhichWayAreYouWorkingGame extends StatefulWidget {
  const WhichWayAreYouWorkingGame({super.key});

  @override
  State<WhichWayAreYouWorkingGame> createState() =>
      _WhichWayAreYouWorkingGameState();
}

/// What a job asks for.
enum Which2 { forward, inverse, both }

extension Which2Words on Which2 {
  String get plain => switch (this) {
        Which2.forward => 'Forward: a course out into new coordinates',
        Which2.inverse => 'Inverse: two coordinates back into a course',
        Which2.both => 'Inverse first, then forward',
      };
}

@immutable
class CogoRound {
  const CogoRound({
    required this.subject,
    required this.setting,
    required this.task,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Task task;
  final Which2 answer;
  final String why;
  final String source;
}

const cogoRounds = <CogoRound>[
  CogoRound(
    subject: 'the lesson\'s own course',
    setting:
        'Point A is held. A course of 200 feet at azimuth 30 was run off it, '
        'and the far end needs coordinates.',
    task: Task(
      known: [Peg2('A', 5000, 5000)],
      wanted: Peg2('B', 5100, 5173),
      length: 200,
      azimuth: 30,
    ),
    answer: Which2.forward,
    why:
        'Forward. One point held, one course measured, one point wanted: the '
        'course goes in and coordinates come out. The length times the sine '
        'of the azimuth is how far east it went and the length times the '
        'cosine is how far north, and both get ADDED to the point you '
        'started from.',
    source: 'surv-cg-q2',
  ),
  CogoRound(
    subject: 'two corners already on file',
    setting:
        'Both A and B are held from an earlier survey, and the crew needs to '
        'know how far apart they are before going out.',
    task: Task(
      known: [Peg2('A', 1000, 1000), Peg2('B', 1300, 1400)],
    ),
    answer: Which2.inverse,
    why:
        'Inverse. Two points held and nothing measured in the field at all: '
        'the differences in easting and northing make a right triangle and '
        'the distance is its hypotenuse. This is the lesson\'s own 300, 400 '
        'and 500. An inverse is a calculation, not a survey.',
    source: 'surv-cg-q1',
  ),
  CogoRound(
    subject: 'a stake beyond the far corner',
    setting:
        'A and B are both held. A stake is wanted 60 feet further on, '
        'straight past B on the same line.',
    task: Task(
      known: [Peg2('A', 2000, 2000), Peg2('B', 2300, 2400)],
      wanted: Peg2('C', 2336, 2448),
    ),
    answer: Which2.both,
    why:
        'Both, in that order. The direction from A to B is not known yet, so '
        'it has to be inversed out of the two coordinates first, and then '
        'that azimuth carried forward 60 feet past B to fix the stake. Most '
        'real coordinate work is this pair of steps: inverse to find out '
        'where something points, forward to put something new there.',
    source: 'surv-cg-q1',
  ),
  CogoRound(
    subject: 'a call off a deed',
    setting:
        'A deed calls the next corner as 415 feet at azimuth 118 from the '
        'corner already found.',
    task: Task(
      known: [Peg2('A', 3000, 3000)],
      wanted: Peg2('B', 3366, 2805),
      length: 415,
      azimuth: 118,
    ),
    answer: Which2.forward,
    why:
        'Forward. A deed call IS a course: a length and a direction off a '
        'point. Turning the whole deed into coordinates one call at a time '
        'is how a boundary gets plotted, and the last call should land back '
        'on the first corner, which is where the closure check of the '
        'traverse lesson comes from.',
    source: 'surv-cg-q2',
  ),
  CogoRound(
    subject: 'a bearing for the plat',
    setting:
        'Both corners are coordinated. The plat has to show the bearing and '
        'the distance of the line between them.',
    task: Task(
      known: [Peg2('A', 4000, 4000), Peg2('B', 3700, 4300)],
    ),
    answer: Which2.inverse,
    why:
        'Inverse, and this one runs north and west, so the arctangent alone '
        'will not give the answer. Every line printed on a plat comes out of '
        'an inverse: the coordinates are what the survey holds, and the '
        'bearings and distances on the drawing are worked back out of them.',
    source: 'surv-cg-q1',
  ),
  CogoRound(
    subject: 'setting two stakes off control',
    setting:
        'One control point is held. Two stakes are to be set, each by a '
        'length and an azimuth off that point.',
    task: Task(
      known: [Peg2('CP', 8000, 8000)],
      wanted: Peg2('S1', 8120, 8090),
      length: 150,
      azimuth: 53,
    ),
    answer: Which2.forward,
    why:
        'Forward, twice over. Every stake set from a course off a known '
        'point is its own forward computation, and they do not depend on '
        'each other: an error in one does not move the other. That '
        'independence is why site work is set out from control rather than '
        'from the last stake.',
    source: 'surv-cg-q2',
  ),
];

class _WhichWayAreYouWorkingGameState extends State<WhichWayAreYouWorkingGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-way-are-you-working',
    chapterId: 'surveying',
    total: cogoRounds.length,
    sourceProblemIdOf: (round) => cogoRounds[round].source,
  )..addListener(_onSession);

  Which2? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  CogoRound get _round => cogoRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Way Are You Working',
        closing:
            'Count the points that already have coordinates. One, with a '
            'course measured off it: forward, and the course turns into a '
            'new point. Two, with nothing measured: inverse, and the '
            'coordinates turn back into a distance and a direction. Most '
            'real jobs are an inverse to find out where something points, '
            'followed by a forward to put something new there.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: cogoBrief,
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
            'WHICH COMPUTATION IS THIS',
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
          Container(
            height: 215,
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
                  painter: CogoPainter(task: r.task),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\Delta E = L\sin Az \qquad \Delta N = L\cos Az$',
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in Which2.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'THE OTHER WAY',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String label;
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
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
