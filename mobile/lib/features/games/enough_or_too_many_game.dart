import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'determinacy_figures.dart';

/// Enough or Too Many — the second item for `determinacy-stability`.
///
/// Once the right count is chosen, the comparison is the whole of the
/// classification, and the three outcomes mean three quite different things.
/// Short of the requirement is a mechanism: it moves. Exactly the
/// requirement is determinate: equilibrium alone will solve it. Over the
/// requirement is indeterminate, and the excess is the number of extra
/// unknowns you have to find compatibility equations for.
class EnoughOrTooManyGame extends StatefulWidget {
  const EnoughOrTooManyGame({super.key});

  @override
  State<EnoughOrTooManyGame> createState() => _EnoughOrTooManyGameState();
}

/// How the count comes out.
enum Tally { short, exact, over }

extension TallyWords on Tally {
  String get plain => switch (this) {
        Tally.short => 'Short of it: a mechanism, and it moves',
        Tally.exact => 'Exactly it: stable and determinate',
        Tally.over => 'More than it: stable and indeterminate',
      };
}

@immutable
class TallyRound2 {
  const TallyRound2({
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

  /// Worked out of the skeleton itself, so the drawing and the answer
  /// cannot disagree.
  Tally get answer {
    if (skeleton.countsShort) return Tally.short;
    return skeleton.countsExact ? Tally.exact : Tally.over;
  }
}

const tallyRounds2 = <TallyRound2>[
  TallyRound2(
    subject: 'the lesson\'s own truss',
    setting: 'Eleven members, seven joints, a pin and a roller.',
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
        'Exactly. Eleven members and three reactions is fourteen, and two '
        'equations at each of seven joints is fourteen as well. Determinate: '
        'every member force and every reaction comes out of equilibrium '
        'alone, with nothing left over and nothing missing. This is the '
        'arrangement most hand-analyzed trusses are in.',
    source: 'str-ds-q1',
  ),
  TallyRound2(
    subject: 'the lesson\'s own portal frame',
    setting: 'Three members, four joints, a pin at one base and a fixed '
        'support at the other.',
    skeleton: Skeleton(
      joints: [Offset(0, 0), Offset(0, 2), Offset(3, 2), Offset(3, 0)],
      members: [(0, 1), (1, 2), (2, 3)],
      holds: {0: Hold.pin, 3: Hold.fixed},
      rigid: true,
    ),
    why:
        'More than enough, by two. Nine from the members and five from the '
        'supports is fourteen against the twelve that three joints worth of '
        'equilibrium can use. Two degrees indeterminate: equilibrium gets you '
        'most of the way and two compatibility conditions finish it. Note '
        'where the five came from, because a fixed support gives THREE and '
        'counting it as two is the trap.',
    source: 'str-ds-q2',
  ),
  TallyRound2(
    subject: 'a member taken out',
    setting:
        'The same truss with one diagonal removed: ten members, seven '
        'joints, still a pin and a roller.',
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
        'Short, by one, and the structure is a mechanism: the panel the '
        'diagonal used to brace can rack into a parallelogram and the whole '
        'thing folds. A count one short is not a slightly weak structure, it '
        'is one that MOVES, and the analysis will simply fail to have a '
        'solution rather than give you a small answer.',
    source: 'str-ds-q1',
  ),
  TallyRound2(
    subject: 'both bases fixed',
    setting: 'The same portal frame, but with a fixed support at each base.',
    skeleton: Skeleton(
      joints: [Offset(0, 0), Offset(0, 2), Offset(3, 2), Offset(3, 0)],
      members: [(0, 1), (1, 2), (2, 3)],
      holds: {0: Hold.fixed, 3: Hold.fixed},
      rigid: true,
    ),
    why:
        'More than enough, by three now. The second fixed support added one '
        'more reaction than the pin it replaced, and the degree went up with '
        'it. This is the everyday portal frame of a real building, and it is '
        'why real frames are analyzed by computer: three redundants is '
        'already past comfortable hand work.',
    source: 'str-ds-q2',
  ),
  TallyRound2(
    subject: 'a truss on a roller only',
    setting: 'The eleven member truss, but with rollers at both ends.',
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
      holds: {0: Hold.roller, 6: Hold.roller},
    ),
    why:
        'Short, by one. Two rollers give two reactions where three are '
        'needed, so the truss is free to slide sideways: it is a mechanism, '
        'and the count says so honestly this time. Compare it with the round '
        'to come, where the count is satisfied and the structure slides '
        'anyway.',
    source: 'str-ds-q1',
  ),
  TallyRound2(
    subject: 'a hinge in the beam',
    setting:
        'The portal frame fixed at both bases, but with an internal hinge at '
        'midspan: four members, five joints, and one release.',
    skeleton: Skeleton(
      joints: [
        Offset(0, 0),
        Offset(0, 2),
        Offset(1.5, 2),
        Offset(3, 2),
        Offset(3, 0),
      ],
      members: [(0, 1), (1, 2), (2, 3), (3, 4)],
      holds: {0: Hold.fixed, 4: Hold.fixed},
      rigid: true,
      hinges: [2],
    ),
    why:
        'More than enough, by two. Twelve from the members and six from the '
        'supports is eighteen, against fifteen for five joints plus ONE for '
        'the hinge, which is sixteen. The hinge is the whole point of this '
        'round: it says the moment there is zero, which is an equation you '
        'are handed, and forgetting to add it to c would have made this frame '
        'look three degrees indeterminate instead of two.',
    source: 'str-ds-q2',
  ),
];

class _EnoughOrTooManyGameState extends State<EnoughOrTooManyGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'enough-or-too-many',
    chapterId: 'structural',
    total: tallyRounds2.length,
    sourceProblemIdOf: (round) => tallyRounds2[round].source,
  )..addListener(_onSession);

  Tally? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  TallyRound2 get _round => tallyRounds2[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Enough or Too Many',
        closing:
            'Short of the requirement is a mechanism: it moves, and there is '
            'no solution to find. Exactly the requirement is determinate, and '
            'equilibrium alone finishes the job. Over it is indeterminate, '
            'and the excess is how many extra unknowns you have. Adding a '
            'support or a member raises the count; removing one lowers it, '
            'and one short is not a weak structure but a moving one.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: countBrief,
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
            'HOW DOES THE COUNT COME OUT',
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
            height: 228,
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
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$m + r \text{ vs } 2j \quad\quad 3m + r \text{ vs } 3j + c$',
              style: const TextStyle(fontSize: 13, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Tally.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Tally.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS HOW IT COMES OUT' : 'NOT QUITE',
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
