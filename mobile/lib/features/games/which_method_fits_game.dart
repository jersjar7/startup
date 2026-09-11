import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'area_figures.dart';

/// Which Method Fits the Ground — the first item for `area-computations`.
///
/// Three methods, and which one to reach for is decided by the ground, not
/// by taste. Corners with coordinates on them: the coordinate method, and it
/// is exact. A boundary that wanders, measured as offsets off a baseline:
/// one of the two approximations, and which one depends on nothing more than
/// how many offsets got measured. Simpson takes them in pairs, so it needs
/// an odd count. An even count and the trapezoidal rule is what is left.
class WhichMethodFitsGame extends StatefulWidget {
  const WhichMethodFitsGame({super.key});

  @override
  State<WhichMethodFitsGame> createState() => _WhichMethodFitsGameState();
}

@immutable
class AreaMethodRound {
  const AreaMethodRound({
    required this.subject,
    required this.setting,
    required this.why,
    required this.source,
    this.parcel,
    this.strip,
  });

  final String subject;
  final String setting;
  final String why;
  final String source;

  /// A round shows one or the other, never both.
  final Parcel? parcel;
  final Strip? strip;

  /// Worked out from what was measured, never declared: coordinates when
  /// there are corners, and otherwise whichever of the two rules the count
  /// of offsets allows.
  Way3 get answer {
    if (parcel != null) return Way3.coordinates;
    return strip!.simpsonFits ? Way3.simpson : Way3.trapezoid;
  }
}

const areaMethodRounds = <AreaMethodRound>[
  AreaMethodRound(
    subject: 'three pins in the ground',
    setting:
        'A triangular remnant with a monument found at each corner and '
        'coordinates on all three.',
    parcel: Parcel(corners: [
      Corner2('A', 0, 0),
      Corner2('B', 6, 0),
      Corner2('C', 3, 4),
    ]),
    why:
        'By coordinates. Straight sides between known corners is exactly '
        'what the coordinate method is for, and it is EXACT: there is no '
        'approximation in it at all, whatever the shape. This is the '
        'lesson\'s own triangle, and the cross products give 24, so the area '
        'is 12.',
    source: 'surv-ac-q1',
  ),
  AreaMethodRound(
    subject: 'a four sided lot',
    setting:
        'A lot with four corners, all four coordinated off the control on '
        'site.',
    parcel: Parcel(corners: [
      Corner2('A', 0, 0),
      Corner2('B', 10, 0),
      Corner2('C', 8, 6),
      Corner2('D', 2, 5),
    ]),
    why:
        'By coordinates again, and the number of corners never changes that. '
        'Four corners means four cross products rather than three, and the '
        'last one pairs D back to A. The lesson works this one to 44.',
    source: 'surv-ac-q2',
  ),
  AreaMethodRound(
    subject: 'a creek bank, five offsets',
    setting:
        'The boundary is a creek. The crew ran a baseline and measured five '
        'offsets to the water at 20 meter intervals.',
    strip: Strip(offsets: [0, 8, 12, 10, 0], step: 20),
    why:
        'Simpson\'s rule. A wandering boundary cannot be worked off corners, '
        'so it is one of the two approximations, and five offsets is an odd '
        'count, which is what Simpson needs. It fits parabolas through the '
        'offsets in pairs rather than joining them with straight lines, so '
        'it follows a curve better. These are the lesson\'s own numbers: the '
        'trapezoidal rule gives 600 and Simpson gives 640.',
    source: 'surv-ac-q3',
  ),
  AreaMethodRound(
    subject: 'one offset more',
    setting:
        'The same kind of job, but the crew took six offsets along the '
        'baseline at 15 meters.',
    strip: Strip(offsets: [0, 6, 11, 14, 9, 0], step: 15),
    why:
        'The trapezoidal rule, because six is an even count and Simpson '
        'cannot take an even count: it works on pairs of intervals, so it '
        'needs an even number of intervals, which is an odd number of '
        'offsets. Nothing about the ground changed between this round and '
        'the last one. Only the count did.',
    source: 'surv-ac-q3',
  ),
  AreaMethodRound(
    subject: 'a wetland edge',
    setting:
        'A delineated wetland edge, chained off a baseline with seven '
        'offsets at 10 meters.',
    strip: Strip(offsets: [2, 7, 13, 15, 12, 6, 3], step: 10),
    why:
        'Simpson\'s rule. Seven is odd, so it fits, and a wetland edge is '
        'exactly the sort of boundary that curves between the offsets rather '
        'than stepping between them. Notice the end offsets are not zero '
        'here: nothing in either rule requires them to be.',
    source: 'surv-ac-q3',
  ),
  AreaMethodRound(
    subject: 'five corners, all coordinated',
    setting:
        'An awkward five sided parcel, every corner monumented and '
        'coordinated.',
    parcel: Parcel(corners: [
      Corner2('A', 0, 0),
      Corner2('B', 9, 1),
      Corner2('C', 11, 7),
      Corner2('D', 4, 9),
      Corner2('E', -1, 5),
    ]),
    why:
        'By coordinates. Irregular is not the same as curved: every side '
        'here is straight, so the coordinate method handles it exactly and '
        'the offsets rules have nothing to work on. Reach for a baseline and '
        'offsets only when the boundary itself will not sit still.',
    source: 'surv-ac-q2',
  ),
];

class _WhichMethodFitsGameState extends State<WhichMethodFitsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-method-fits',
    chapterId: 'surveying',
    total: areaMethodRounds.length,
    sourceProblemIdOf: (round) => areaMethodRounds[round].source,
  )..addListener(_onSession);

  Way3? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  AreaMethodRound get _round => areaMethodRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Method Fits the Ground',
        closing:
            'Corners with coordinates on them go by the coordinate method, '
            'which is exact for any straight sided figure however awkward. A '
            'boundary that wanders gets a baseline and offsets, and then the '
            'count decides: an odd number of offsets lets Simpson fit '
            'parabolas through them, and an even number leaves the '
            'trapezoidal rule.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: methodBrief,
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
            'WHICH METHOD DOES THIS ASK FOR',
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
            height: 220,
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
                  painter: r.parcel != null
                      ? ParcelPainter(
                          parcel: r.parcel!,
                          order: [
                            for (var i = 0; i < r.parcel!.corners.length; i++) i
                          ],
                        )
                      : OffsetsPainter(strip: r.strip!),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in Way3.values) ...[
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
              title: _session.correct! ? 'THAT IS THE ONE' : 'ANOTHER METHOD',
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
