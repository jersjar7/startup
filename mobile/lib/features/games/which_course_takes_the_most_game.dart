import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'traverse_figures.dart';

/// Which Course Takes the Most — the second item for
/// `traverse-computations`.
///
/// The compass rule has one idea in it: the error is assumed to have crept
/// in evenly along the way, so each course is handed a share in proportion
/// to its LENGTH. Not to how far north it went, not to how many courses
/// there are, and not all of it to the one where the mistake feels like it
/// happened. Both of the lesson's named traps are the other ways of
/// splitting it up, and the drawing settles it without any arithmetic: find
/// the longest course.
class WhichCourseTakesTheMostGame extends StatefulWidget {
  const WhichCourseTakesTheMostGame({super.key});

  @override
  State<WhichCourseTakesTheMostGame> createState() =>
      _WhichCourseTakesTheMostGameState();
}

@immutable
class CourseRound {
  const CourseRound({
    required this.subject,
    required this.setting,
    required this.trip,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Trip trip;
  final String why;
  final String source;

  /// Read off the lengths rather than declared beside them.
  int get answer => trip.longest;
}

const courseRounds = <CourseRound>[
  CourseRound(
    subject: 'four courses, one long one',
    setting:
        'The traverse finished 0.10 meters out. Which course gets the '
        'biggest share of the correction?',
    trip: Trip(
      lengths: [250, 180, 420, 150],
      driftNorth: 0.08,
      driftEast: -0.06,
    ),
    why:
        'The 420 meter course. The compass rule hands each course the total '
        'error times its own length over the whole perimeter, so the longest '
        'course takes the largest share, every time and for no other reason. '
        'The lesson\'s own sum is this: a 250 meter course in a 1,000 meter '
        'traverse takes a quarter of the error.',
    source: 'surv-tc-q3',
  ),
  CourseRound(
    subject: 'where the blunder feels like it happened',
    setting:
        'The crew remembers the sight down the second course being awkward. '
        'Which course still gets the biggest correction?',
    trip: Trip(
      lengths: [200, 140, 160, 380, 220],
      driftNorth: -0.05,
      driftEast: 0.12,
    ),
    why:
        'The 380 meter course, not the awkward one. The compass rule is not '
        'a search for the mistake: it assumes the error crept in a little at '
        'a time all the way round, so it spreads it by length. If you '
        'actually know which course is wrong, the answer is to go back and '
        'measure it again, not to dump the whole closure onto it. Dumping it '
        'on one course is the lesson\'s own wrong answer of 0.080.',
    source: 'surv-tc-q3',
  ),
  CourseRound(
    subject: 'the course that runs furthest north',
    setting:
        'Course B runs almost due north and covers more latitude than any '
        'other. Which course takes the biggest correction?',
    trip: Trip(
      lengths: [160, 300, 340, 190],
      driftNorth: 0.09,
      driftEast: 0.02,
    ),
    why:
        'The 340 meter course, not the northerly one at 300. It is easy to '
        'think a latitude correction should follow the latitudes, and it '
        'does not: the share is set by the LENGTH of the course. The same '
        'proportion is then used for the latitude correction and the '
        'departure correction alike.',
    source: 'surv-tc-q3',
  ),
  CourseRound(
    subject: 'three courses of a size',
    setting:
        'Three of these are within twenty meters of each other. Read them '
        'off rather than eyeing the drawing, which is not to scale.',
    trip: Trip(
      lengths: [210, 225, 205, 260],
      driftNorth: 0.04,
      driftEast: 0.03,
    ),
    why:
        'The 260 meter course. A field sketch is drawn to shape, not to '
        'scale, so the lengths written on the courses are the only thing '
        'worth reading. Its share is 260 over 900, a little under a third, '
        'and the other three split the rest.',
    source: 'surv-tc-q3',
  ),
  CourseRound(
    subject: 'a five sided traverse',
    setting:
        'Five courses this time, and the closure is 0.14 meters. Which one '
        'takes the biggest share?',
    trip: Trip(
      lengths: [120, 480, 170, 200, 130],
      driftNorth: -0.10,
      driftEast: -0.10,
    ),
    why:
        'The 480 meter course, which is nearly half the traverse on its own '
        'and so takes nearly half the correction. The number of courses '
        'never enters the rule: splitting the error five equal ways is the '
        'other trap the lesson names, and it would hand this course the same '
        'as the 120 meter one.',
    source: 'surv-tc-q3',
  ),
  CourseRound(
    subject: 'the short course at the end',
    setting:
        'The traverse closed back onto its start down a short tie line. '
        'Which course takes the biggest share?',
    trip: Trip(
      lengths: [310, 95, 275, 360, 110],
      driftNorth: 0.06,
      driftEast: 0.05,
    ),
    why:
        'The 360 meter course. The short tie line at 95 meters takes the '
        'smallest share of all, which is the rule behaving sensibly: there '
        'was less opportunity to go wrong over 95 meters than over 360, so '
        'less of the blame lands there.',
    source: 'surv-tc-q3',
  ),
];

class _WhichCourseTakesTheMostGameState
    extends State<WhichCourseTakesTheMostGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-course-takes-the-most',
    chapterId: 'surveying',
    total: courseRounds.length,
    sourceProblemIdOf: (round) => courseRounds[round].source,
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

  CourseRound get _round => courseRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Course Takes the Most',
        closing:
            'The compass rule assumes the error crept in evenly along the '
            'way, so each course takes the total times its own length over '
            'the perimeter. The longest course takes the most. Not the '
            'course that went furthest north, not an equal share each, and '
            'never the whole error on the one course that felt wrong. And '
            'the correction always pushes back against the drift.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: compassBrief,
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
            'TAP THE COURSE WITH THE BIGGEST SHARE',
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
          _Sketch(
            trip: r.trip,
            picked: _picked,
            answer: r.answer,
            locked: answered,
            onPick: answered ? null : (i) => setState(() => _picked = i),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\text{Corr}_i = -E \times \dfrac{L_i}{\Sigma L}$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title:
                  _session.correct! ? 'THAT IS THE ONE' : 'ANOTHER COURSE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Sketch extends StatelessWidget {
  const _Sketch({
    required this.trip,
    required this.picked,
    required this.answer,
    required this.locked,
    required this.onPick,
  });

  final Trip trip;
  final int? picked;
  final int answer;
  final bool locked;
  final void Function(int)? onPick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final size = Size(box.maxWidth, 250);
        return GestureDetector(
          onTapUp: onPick == null
              ? null
              : (details) {
                  final hit = TripPainter.at(size, trip, details.localPosition);
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
                  painter: TripPainter(
                    trip: trip,
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
