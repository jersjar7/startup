import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'profile_figures.dart';

/// Where It Flattens Out — the second item for `vertical-curves`.
///
/// The lesson's hardest problem asks how far from the PVC the high point of a
/// crest is, and its named trap is assuming the answer is the midpoint. It is
/// the midpoint only when the two grades are equal and opposite. On a drawing
/// to scale none of this needs a formula: the high point is where the road
/// stops climbing, and the eye can find it. What the eye also shows, and the
/// formula hides, is that the point is not under the PVI, and that when both
/// grades run the same way it is not on the curve at all.
class WhereItFlattensOutGame extends StatefulWidget {
  const WhereItFlattensOutGame({super.key});

  @override
  State<WhereItFlattensOutGame> createState() =>
      _WhereItFlattensOutGameState();
}

@immutable
class TopRound {
  const TopRound({
    required this.subject,
    required this.setting,
    required this.vert,
    required this.spots,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Vert vert;

  /// The marked points, as feet from the PVC. They sit on the road itself.
  final List<double> spots;
  final String why;
  final String source;

  /// A curve that bends downward tops out; one that bends upward bottoms
  /// out. That is the sign of the grade change and nothing else, which is
  /// why a road climbing at 1 percent and leaving at 4 is looking for a LOW
  /// point even though it never falls.
  bool get wantsHigh => vert.isCrest;

  /// Worked off the drawing, never declared: of the marked points, the one
  /// the road carries highest, or lowest.
  int get answer {
    var best = 0;
    for (var i = 1; i < spots.length; i++) {
      final here = vert.roadAt(spots[i]);
      final champ = vert.roadAt(spots[best]);
      if (wantsHigh ? here > champ : here < champ) best = i;
    }
    return best;
  }
}

const topRounds = <TopRound>[
  TopRound(
    subject: 'the lesson\'s own crest',
    setting:
        'The road climbs at 3 percent and leaves at minus 1, over 400 feet. '
        'Tap the marked point where it stops climbing.',
    vert: Vert(gradeIn: 3, gradeOut: -1, length: 400),
    spots: [100, 200, 300, 400],
    why:
        'Three quarters of the way along, at 300 feet. It is not the midpoint '
        'and it is not under the PVI: the road spends longer shedding the '
        'steeper climb than it does on the gentler fall, so the top sits well '
        'past halfway, on the side of the SHALLOWER grade. The formula agrees '
        'and gives 300 feet, but the drawing shows it without one. The 100 '
        'foot mark is worth naming: that is this curve\'s K value, 400 over '
        '4, and K is a rate rather than a distance along the road.',
    source: 'surv-vc-q3',
  ),
  TopRound(
    subject: 'a crest with a mark at each end',
    setting:
        'The road climbs at 4 percent and leaves at minus 2, over 600 feet. '
        'Tap the highest point of the road.',
    vert: Vert(gradeIn: 4, gradeOut: -2, length: 600),
    spots: [0, 300, 400, 600],
    why:
        'At 400 feet, two thirds along. Again the top leans toward the '
        'shallower grade, and in the same proportion the grades are in: 4 and '
        '2 put it two thirds of the way. The 300 foot mark is the midpoint '
        'and the station under the PVI, which is where most people put it.',
    source: 'surv-vc-q2',
  ),
  TopRound(
    subject: 'grades that match',
    setting:
        'The road climbs at 3 percent and leaves at minus 3, over 600 feet. '
        'Tap the highest point of the road.',
    vert: Vert(gradeIn: 3, gradeOut: -3, length: 600),
    spots: [150, 300, 450, 600],
    why:
        'The midpoint, 300 feet. When the two grades are equal and opposite '
        'the curve is symmetric and the top really is halfway along, directly '
        'under the PVI. This is the one case where the guess everybody makes '
        'happens to be right, which is exactly why it survives: it works often '
        'enough to feel like a rule.',
    source: 'surv-vc-q3',
  ),
  TopRound(
    subject: 'a sag, where the water collects',
    setting:
        'The road falls at 4 percent and leaves climbing at 2, over 600 feet. '
        'Tap the lowest point of the road.',
    vert: Vert(gradeIn: -4, gradeOut: 2, length: 600),
    spots: [0, 300, 400, 600],
    why:
        'At 400 feet. A sag works exactly like a crest with the sign turned '
        'over, and the low point leans toward the shallower grade in the same '
        'way. This is the point drainage cares about: water runs to it from '
        'both directions, so that is where the inlet goes, and putting it at '
        'the PVI station would leave it 100 feet off.',
    source: 'surv-vc-q3',
  ),
  TopRound(
    subject: 'a steep recovery',
    setting:
        'The road falls at 2 percent and leaves climbing at 6, over 800 feet. '
        'Tap the lowest point of the road.',
    vert: Vert(gradeIn: -2, gradeOut: 6, length: 800),
    spots: [200, 400, 600, 800],
    why:
        'At 200 feet, only a quarter of the way in. The outgoing grade is '
        'three times the incoming one, so the road turns around early and '
        'spends most of the curve climbing. The larger the grade change, the '
        'shorter the distance the road needs to shed the grade it arrived '
        'with.',
    source: 'surv-vc-q3',
  ),
  TopRound(
    subject: 'two grades running the same way',
    setting:
        'The road climbs at 1 percent and leaves climbing at 4, over 600 '
        'feet. Tap the lowest point of the road.',
    vert: Vert(gradeIn: 1, gradeOut: 4, length: 600),
    spots: [0, 200, 400, 600],
    why:
        'The PVC. The road climbs the whole way and never turns around, so '
        'the lowest point on the curve is simply where it begins. Run the '
        'formula anyway and it returns a NEGATIVE distance, 200 feet behind '
        'the PVC, which is its way of saying the turning point is off this '
        'curve. An answer outside 0 to L means there is no high or low point '
        'on the road at all.',
    source: 'surv-vc-q3',
  ),
];

class _WhereItFlattensOutGameState extends State<WhereItFlattensOutGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'where-it-flattens-out',
    chapterId: 'surveying',
    total: topRounds.length,
    sourceProblemIdOf: (round) => topRounds[round].source,
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

  TopRound get _round => topRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Where It Flattens Out',
        closing:
            'The road turns around where its slope runs out, and that point '
            'leans toward the shallower of the two grades. It is halfway '
            'along only when the grades are equal and opposite, and it is not '
            'on the curve at all when both grades run the same way. The PVI '
            'station is a tempting answer and it is almost never the right '
            'one.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: highPointBrief,
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
            r.wantsHigh ? 'TAP THE TOP OF THE ROAD' : 'TAP THE BOTTOM OF THE ROAD',
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
          // The profile is drawn to scale, so the turning point is there to
          // be seen. That is the point of the item: the eye finds it without
          // the formula, and the formula only confirms what the eye found.
          _Profile(
            vert: r.vert,
            spots: r.spots,
            picked: _picked,
            answer: r.answer,
            locked: answered,
            onPick: answered ? null : (i) => setState(() => _picked = i),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$x_m = \dfrac{-g_1 L}{g_2 - g_1}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct!
                  ? 'THAT IS WHERE IT TURNS'
                  : 'IT TURNS ELSEWHERE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({
    required this.vert,
    required this.spots,
    required this.picked,
    required this.answer,
    required this.locked,
    required this.onPick,
  });

  final Vert vert;
  final List<double> spots;
  final int? picked;
  final int answer;
  final bool locked;
  final void Function(int)? onPick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final size = Size(box.maxWidth, 260);
        return GestureDetector(
          onTapUp: onPick == null
              ? null
              : (details) {
                  final hit = RoadProfilePainter.at(
                      size, vert, spots, details.localPosition);
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
                  painter: RoadProfilePainter(
                    vert: vert,
                    spots: spots,
                    picked: picked,
                    answer: locked ? answer : null,
                    locked: locked,
                    showTurning: locked,
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
