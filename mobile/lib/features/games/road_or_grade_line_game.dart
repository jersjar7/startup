import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'profile_figures.dart';

/// Road or Grade Line — the first item for `vertical-curves`.
///
/// The lesson asks the same curve twice in a row, once for the elevation on
/// the tangent and once for the elevation on the road, and the two answers
/// are 4.5 feet apart. Every wrong answer in that pair comes from reading one
/// line when the question wanted the other. What settles it is not a formula
/// but a direction: a road that is bending downward runs BELOW the grade it
/// came in on, and one bending upward runs above it, and the two only touch
/// at the PVC where the curve begins.
class RoadOrGradeLineGame extends StatefulWidget {
  const RoadOrGradeLineGame({super.key});

  @override
  State<RoadOrGradeLineGame> createState() => _RoadOrGradeLineGameState();
}

/// Where the road sits against the grade line it came in on.
enum Sits3 { above, below, onIt }

extension Sits3Words on Sits3 {
  String get plain => switch (this) {
        Sits3.above => 'Above the grade line',
        Sits3.below => 'Below the grade line',
        Sits3.onIt => 'Right on it',
      };
}

@immutable
class SitsRound {
  const SitsRound({
    required this.subject,
    required this.setting,
    required this.vert,
    required this.station,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Vert vert;

  /// Feet from the PVC to the point the round marks.
  final double station;
  final String why;
  final String source;

  /// Read off the drawing rather than declared: the road minus the tangent.
  /// The sign of that gap is the sign of the grade change, and it is zero
  /// only where the curve leaves the tangent.
  Sits3 get answer {
    final gap = vert.roadAt(station) - vert.tangentAt(station);
    if (gap.abs() < 0.01) return Sits3.onIt;
    return gap > 0 ? Sits3.above : Sits3.below;
  }
}

const sitsRounds = <SitsRound>[
  SitsRound(
    subject: 'the lesson\'s own curve, at the middle',
    setting:
        'A crest curve rises at 4 percent and leaves at minus 2. The mark is '
        'halfway along, directly under the PVI.',
    vert: Vert(gradeIn: 4, gradeOut: -2, length: 600),
    station: 300,
    why:
        'Below. This is the pair of questions the lesson asks back to back. '
        'The grade line produced from the PVC reaches 112 feet here, and that '
        'is the PVI elevation, because the PVI is where the two straight '
        'grades meet. The road is at 107.5. The 4.5 feet between them is the '
        'whole of what the curve does, and on a crest the road is always the '
        'lower of the two.',
    source: 'surv-vc-q2',
  ),
  SitsRound(
    subject: 'the same curve, right at the start',
    setting: 'The mark is at the PVC, where the curve begins.',
    vert: Vert(gradeIn: 4, gradeOut: -2, length: 600),
    station: 0,
    why:
        'Right on it. The curve leaves the tangent at the PVC, so there is no '
        'gap at all to start with. The gap then grows as the SQUARE of the '
        'distance, which is why it is still small a short way in and reaches '
        'its largest at the PVI. That is also why the PVC elevation is the '
        'number every other elevation on the curve is measured from.',
    source: 'surv-vc-q1',
  ),
  SitsRound(
    subject: 'a sag curve',
    setting:
        'The road falls at 3 percent and leaves climbing at 2. The mark is '
        'halfway along.',
    vert: Vert(gradeIn: -3, gradeOut: 2, length: 500),
    station: 250,
    why:
        'Above. A sag bends the other way, so the road lifts off the falling '
        'grade line and runs above it. Everything else is the same as a '
        'crest: the gap starts at nothing at the PVC, grows as the square of '
        'the distance, and is largest under the PVI. Only the sign of the '
        'grade change is different.',
    source: 'surv-vc-q2',
  ),
  SitsRound(
    subject: 'a crest, early on',
    setting:
        'The road climbs at 3 percent and leaves at minus 1, over 400 feet. '
        'The mark is 100 feet in.',
    vert: Vert(gradeIn: 3, gradeOut: -1, length: 400),
    station: 100,
    why:
        'Below, but barely. A quarter of the way along, the gap is only a '
        'sixteenth of what it will be at the PVI, because it grows as the '
        'square of the distance from the PVC. That is why the road and the '
        'grade line are hard to tell apart near the start of a long curve, '
        'and why a station near the PVC is a poor place to check your work.',
    source: 'surv-vc-q3',
  ),
  SitsRound(
    subject: 'a sag, late on',
    setting:
        'The road falls at 2 percent and leaves climbing at 4, over 800 feet. '
        'The mark is 600 feet in.',
    vert: Vert(gradeIn: -2, gradeOut: 4, length: 800),
    station: 600,
    why:
        'Above. By three quarters of the way along, the road has left the '
        'falling grade line well behind and is climbing hard. Note that the '
        'grade line here is still the one produced from the PVC, falling at 2 '
        'percent: the formula measures from the back tangent the whole way '
        'across, not from the tangent nearest the point.',
    source: 'surv-vc-q2',
  ),
  SitsRound(
    subject: 'two grades that both climb',
    setting:
        'The road climbs at 1 percent and leaves climbing at 4, over 600 '
        'feet. The mark is halfway along.',
    vert: Vert(gradeIn: 1, gradeOut: 4, length: 600),
    station: 300,
    why:
        'Above. Nothing here crests or sags: the road climbs the whole way '
        'and only climbs harder. What decides the direction is the sign of '
        'the grade CHANGE, from 1 up to 4, which is positive and bends the '
        'road upward off its incoming grade. Reaching for the words crest and '
        'sag rather than the sign of the change is what gets this one wrong.',
    source: 'surv-vc-q2',
  ),
];

class _RoadOrGradeLineGameState extends State<RoadOrGradeLineGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'road-or-grade-line',
    chapterId: 'surveying',
    total: sitsRounds.length,
    sourceProblemIdOf: (round) => sitsRounds[round].source,
  )..addListener(_onSession);

  Sits3? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SitsRound get _round => sitsRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Road or Grade Line',
        closing:
            'The tangent elevation and the road elevation are two different '
            'numbers at the same station, and the question always means one '
            'of them. The road bends away from the grade it came in on in '
            'whichever direction the grade change points, starting at nothing '
            'at the PVC and growing as the square of the distance. On a crest '
            'the road runs below, on a sag above.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: tangentOffsetBrief,
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
            'WHERE IS THE ROAD AT THE MARK',
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
          // The drawing marks both points at the station and leaves the gap
          // between them showing. It is the answer in picture form once you
          // can read a profile, which is exactly the skill being taught.
          Container(
            height: 240,
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
                  painter: RoadProfilePainter(
                    vert: r.vert,
                    markAt: r.station,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$Y = Y_{PVC} + g_1 x + \dfrac{g_2 - g_1}{2L}x^2$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Sits3.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Sits3.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHERE IT SITS' : 'THE OTHER WAY',
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
