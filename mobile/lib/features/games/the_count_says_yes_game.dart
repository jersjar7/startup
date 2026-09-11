import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'determinacy_figures.dart';

/// The Count Says Yes — the third item for `determinacy-stability`.
///
/// The determinacy equation is a necessary condition and not a sufficient
/// one, which is the lesson's hardest problem and the one worth the most.
/// A structure can have exactly the right number of everything and still
/// fall over, because the count sees quantities and never arrangement. Two
/// arrangements give it away: reactions all parallel cannot resist a load
/// across them, and reactions all passing through one point cannot resist a
/// turn about it.
class TheCountSaysYesGame extends StatefulWidget {
  const TheCountSaysYesGame({super.key});

  @override
  State<TheCountSaysYesGame> createState() => _TheCountSaysYesGameState();
}

/// What the structure actually is, once the arrangement has been looked at.
enum WillItStand { determinate, indeterminate, unstable }

extension VerdictWords on WillItStand {
  String get plain => switch (this) {
        WillItStand.determinate => 'Stable and determinate',
        WillItStand.indeterminate => 'Stable and indeterminate',
        WillItStand.unstable => 'Unstable, whatever the count says',
      };
}

@immutable
class VerdictRound {
  const VerdictRound({
    required this.subject,
    required this.setting,
    required this.skeleton,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Skeleton skeleton;
  final String why;
  final String source;

  /// The arrangement is checked FIRST, because it can overrule the count
  /// and the count can never overrule it.
  WillItStand get answer {
    if (skeleton.geometricallyUnstable || skeleton.countsShort) {
      return WillItStand.unstable;
    }
    return skeleton.countsExact
        ? WillItStand.determinate
        : WillItStand.indeterminate;
  }
}

const standRounds = <VerdictRound>[
  VerdictRound(
    subject: 'the lesson\'s own trap',
    setting:
        'Nine members, six joints, three reactions, and every one of them '
        'vertical: three rollers on level ground.',
    skeleton: Skeleton(
      joints: [
        Offset(0, 0),
        Offset(2, 0),
        Offset(4, 0),
        Offset(0.5, 1.2),
        Offset(2, 1.2),
        Offset(3.5, 1.2),
      ],
      members: [
        (0, 1),
        (1, 2),
        (3, 4),
        (4, 5),
        (0, 3),
        (3, 1),
        (1, 4),
        (1, 5),
        (2, 5),
      ],
      holds: {0: Hold.roller, 1: Hold.roller, 2: Hold.roller},
      parallelReactions: true,
    ),
    why:
        'Unstable, and the count is no help at all: nine and three is twelve '
        'and two times six is twelve, so the arithmetic says determinate. '
        'Push it sideways and it slides. Three vertical reactions cannot sum '
        'to anything horizontal, so the equilibrium equation across the page '
        'has no way to be satisfied. The count is necessary and it is not '
        'sufficient.',
    source: 'str-ds-q3',
  ),
  VerdictRound(
    subject: 'the same truss, properly held',
    setting:
        'The same nine members and six joints, but one of the three '
        'supports is a pin rather than a roller.',
    skeleton: Skeleton(
      joints: [
        Offset(0, 0),
        Offset(2, 0),
        Offset(4, 0),
        Offset(0.5, 1.2),
        Offset(2, 1.2),
        Offset(3.5, 1.2),
      ],
      members: [
        (0, 1),
        (1, 2),
        (3, 4),
        (4, 5),
        (0, 3),
        (3, 1),
        (1, 4),
        (1, 5),
        (2, 5),
      ],
      holds: {0: Hold.pin, 1: Hold.roller, 2: Hold.roller},
    ),
    why:
        'Stable, and one degree indeterminate. Swapping one roller for a pin '
        'added a horizontal reaction, so a sideways push now has something to '
        'react against, and the count went from twelve to thirteen at the '
        'same time. One small change fixed the arrangement and the '
        'arithmetic together, which is the usual way out of the last round.',
    source: 'str-ds-q3',
  ),
  VerdictRound(
    subject: 'an ordinary simply supported truss',
    setting: 'Eleven members, seven joints, a pin at one end and a roller at '
        'the other.',
    skeleton: Skeleton(
      joints: [
        Offset(0, 0),
        Offset(1, 1),
        Offset(2, 0),
        Offset(3, 1),
        Offset(4, 0),
        Offset(5, 1),
        Offset(6, 0),
      ],
      members: [
        (0, 2),
        (2, 4),
        (4, 6),
        (1, 3),
        (3, 5),
        (0, 1),
        (1, 2),
        (2, 3),
        (3, 4),
        (4, 5),
        (5, 6),
      ],
      holds: {0: Hold.pin, 6: Hold.roller},
    ),
    why:
        'Stable and determinate, which is what a pin and a roller are for. '
        'The pin takes the horizontal and one vertical, the roller takes the '
        'other vertical, and the three of them are neither parallel nor '
        'concurrent. Most of the trusses anybody analyzes by hand are exactly '
        'this arrangement, and it passes both tests.',
    source: 'str-ds-q1',
  ),
  VerdictRound(
    subject: 'a bracing member taken out',
    setting:
        'The same truss with one diagonal missing: ten members, seven '
        'joints, a pin and a roller.',
    skeleton: Skeleton(
      joints: [
        Offset(0, 0),
        Offset(1, 1),
        Offset(2, 0),
        Offset(3, 1),
        Offset(4, 0),
        Offset(5, 1),
        Offset(6, 0),
      ],
      members: [
        (0, 2),
        (2, 4),
        (4, 6),
        (1, 3),
        (3, 5),
        (0, 1),
        (1, 2),
        (2, 3),
        (4, 5),
        (5, 6),
      ],
      holds: {0: Hold.pin, 6: Hold.roller},
    ),
    why:
        'Unstable, and here the count catches it on its own: thirteen '
        'against fourteen, one short. The supports are arranged perfectly '
        'well and it still will not stand, because the instability is '
        'INSIDE: an unbraced panel folds into a parallelogram. A structure '
        'has to pass the count and the arrangement both.',
    source: 'str-ds-q1',
  ),
  VerdictRound(
    subject: 'an indeterminate structure on parallel supports',
    setting:
        'The eleven member truss, but propped by FOUR rollers along the '
        'bottom chord, every one of them vertical. The count now says '
        'indeterminate.',
    skeleton: Skeleton(
      joints: [
        Offset(0, 0),
        Offset(1, 1),
        Offset(2, 0),
        Offset(3, 1),
        Offset(4, 0),
        Offset(5, 1),
        Offset(6, 0),
      ],
      members: [
        (0, 2),
        (2, 4),
        (4, 6),
        (1, 3),
        (3, 5),
        (0, 1),
        (1, 2),
        (2, 3),
        (3, 4),
        (4, 5),
        (5, 6),
      ],
      holds: {
        0: Hold.roller,
        2: Hold.roller,
        4: Hold.roller,
        6: Hold.roller,
      },
      parallelReactions: true,
    ),
    why:
        'Still unstable, and this is the round that kills the idea that '
        'extra restraint buys safety. Fifteen against fourteen says one '
        'degree indeterminate, and every one of the four reactions is '
        'vertical, so the truss still slides sideways. Spare vertical '
        'reactions do nothing whatever about a horizontal load.',
    source: 'str-ds-q3',
  ),
  VerdictRound(
    subject: 'reactions that all pass through one point',
    setting:
        'A rigid frame pinned at the left base, with the right base bearing '
        'on a vertical face so that its single reaction is HORIZONTAL and at '
        'the same level as the pin.',
    skeleton: Skeleton(
      joints: [Offset(0, 0), Offset(0, 2), Offset(3, 2), Offset(3, 0)],
      members: [(0, 1), (1, 2), (2, 3)],
      holds: {0: Hold.pin, 3: Hold.wallRoller},
      rigid: true,
      concurrentReactions: true,
    ),
    why:
        'Unstable, by the other arrangement. The roller pushes horizontally '
        'and the pin sits at the same height, so all three reaction lines run '
        'through the pin and none of them has a lever arm about it. Sum the '
        'moments there and every reaction drops out: any load trying to turn '
        'the frame about that point meets nothing at all. Concurrent is the '
        'quieter of the two failures and the count is just as blind to it.',
    source: 'str-ds-q3',
  ),
];

class _TheCountSaysYesGameState extends State<TheCountSaysYesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'the-count-says-yes',
    chapterId: 'structural',
    total: standRounds.length,
    sourceProblemIdOf: (round) => standRounds[round].source,
  )..addListener(_onSession);

  WillItStand? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  VerdictRound get _round => standRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'The Count Says Yes',
        closing:
            'The count is necessary and never sufficient. It sees how many '
            'members, joints and reactions there are and it cannot see where '
            'they point. Reactions all parallel leave nothing to resist a '
            'load across them; reactions all through one point leave nothing '
            'to resist a turn about it. Extra restraint does not help either '
            'case, so an indeterminate structure can be just as unstable as a '
            'determinate one.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: stabilityBrief,
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
            'WILL IT ACTUALLY STAND UP',
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
                  painter: SkeletonPainter(
                    skeleton: r.skeleton,
                    showCount: answered,
                    showWhy: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$m + r = 2j \text{ is necessary, not sufficient}$',
              style: const TextStyle(fontSize: 13, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in WillItStand.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != WillItStand.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE VERDICT' : 'LOOK AGAIN',
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
