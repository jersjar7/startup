import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'oblique_figures.dart';

/// Which Law — the first item for `law-of-sines-cosines`.
///
/// The lesson's decision tree, made tappable: a side with its opposite angle
/// means Sines, two sides with the angle between them or all three sides means
/// Cosines. The student reads what they were handed off the drawing and picks.
/// Nothing is solved.
class WhichLawGame extends StatefulWidget {
  const WhichLawGame({super.key});

  @override
  State<WhichLawGame> createState() => _WhichLawGameState();
}

@immutable
class LawRound {
  const LawRound({
    required this.pattern,
    required this.context,
    required this.knownSides,
    required this.knownAngles,
    required this.wanted,
    required this.sines,
    required this.why,
    required this.source,
  });

  /// AAS, ASA, SAS, SSS, SSA, as an engineer would say it.
  final String pattern;
  final String context;
  final Set<String> knownSides;
  final Set<String> knownAngles;
  final String wanted;

  /// True when the Law of Sines is the way in.
  final bool sines;
  final String why;
  final String source;
}

const lawRounds = <LawRound>[
  LawRound(
    pattern: 'AAS',
    context:
        'You know two angles and the side opposite one of them. You want '
        'another side.',
    knownSides: {'a'},
    knownAngles: {'A', 'B'},
    wanted: 'b',
    sines: true,
    why:
        'A side with its opposite angle is a complete pair, so the Law of '
        'Sines takes you straight there.',
    source: 'math-lsc-q1',
  ),
  LawRound(
    pattern: 'SAS',
    context:
        'Two sides of a lot are measured, with the angle between them. '
        'You want the third side.',
    knownSides: {'a', 'b'},
    knownAngles: {'C'},
    wanted: 'c',
    sines: false,
    why:
        'Two sides and the angle BETWEEN them is SAS. There is no complete '
        'side-angle pair to work from, so it is the Law of Cosines.',
    source: 'math-lsc-q2',
  ),
  LawRound(
    pattern: 'SSS',
    context:
        'A truss with all three member lengths known. You want one of the '
        'angles.',
    knownSides: {'a', 'b', 'c'},
    knownAngles: {},
    wanted: 'C',
    sines: false,
    why:
        'Three sides and no angles is SSS. Rearrange the Law of Cosines to '
        'get the angle out.',
    source: 'math-lsc-q3',
  ),
  LawRound(
    pattern: 'ASA',
    context:
        'Two angles and the side between them. You want one of the other '
        'sides.',
    knownSides: {'c'},
    knownAngles: {'A', 'B'},
    wanted: 'a',
    sines: true,
    why:
        'The third angle follows from the two you have, which gives you a '
        'complete pair. Law of Sines.',
    source: 'math-lsc-q1',
  ),
  LawRound(
    pattern: 'SAS',
    context:
        'Two members meet at a measured angle. You want the distance '
        'across the opening.',
    knownSides: {'b', 'c'},
    knownAngles: {'A'},
    wanted: 'a',
    sines: false,
    why:
        'The known angle sits between the two known sides, so nothing pairs '
        'up. Law of Cosines.',
    source: 'math-lsc-q2',
  ),
  LawRound(
    pattern: 'AAS',
    context:
        'One angle and its opposite side are known, plus a second angle. '
        'You want the remaining side.',
    knownSides: {'b'},
    knownAngles: {'B', 'C'},
    wanted: 'c',
    sines: true,
    why:
        'b sits opposite B, so the pair is complete and the Law of Sines '
        'applies.',
    source: 'math-lsc-q1',
  ),
  LawRound(
    pattern: 'SSS',
    context:
        'A surveyed triangle with all three boundary lengths. You want the '
        'largest angle.',
    knownSides: {'a', 'b', 'c'},
    knownAngles: {},
    wanted: 'B',
    sines: false,
    why:
        'All three sides, no angles. Only the Law of Cosines gets an angle '
        'out of that.',
    source: 'math-lsc-q3',
  ),
  LawRound(
    pattern: 'SSA',
    context:
        'Two sides and an angle NOT between them. You want the angle '
        'opposite the second side.',
    knownSides: {'a', 'b'},
    knownAngles: {'A'},
    wanted: 'B',
    sines: true,
    why:
        'a and A are a complete pair, so the Law of Sines works. This is also '
        'the ambiguous case: with SSA, check whether a second triangle fits '
        'the same numbers.',
    source: 'math-lsc-q1',
  ),
];

class _WhichLawGameState extends State<WhichLawGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-law',
    chapterId: 'mathematics',
    total: lawRounds.length,
    sourceProblemIdOf: (round) => lawRounds[round].source,
  )..addListener(_onSession);

  bool? _choseSines;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  LawRound get _round => lawRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Law',
        closing:
            'A side with its opposite angle means Sines. Two sides with '
            'the angle between them, or all three sides, means Cosines. '
            'Choosing the way in is the part worth doing on a phone.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: whichLawBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _choseSines = null);
              _session.next();
            }
          : (_choseSines == null
                ? null
                : () => _session.submit(
                    ok: _choseSines == r.sines,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHICH LAW GETS YOU IN',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.context,
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Green is given, ember is wanted.',
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: ObliqueTrianglePainter(
                    knownSides: r.knownSides,
                    knownAngles: r.knownAngles,
                    wanted: r.wanted,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _LawButton(
                  label: 'Law of Sines',
                  selected: _choseSines == true,
                  locked: answered,
                  isTruth: r.sines,
                  onTap: answered
                      ? null
                      : () => setState(() => _choseSines = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LawButton(
                  label: 'Law of Cosines',
                  selected: _choseSines == false,
                  locked: answered,
                  isTruth: !r.sines,
                  onTap: answered
                      ? null
                      : () => setState(() => _choseSines = false),
                ),
              ),
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'CORRECT' : 'THE OTHER ONE',
              body: 'This is ${r.pattern}. ${r.why}',
            ),
          ],
        ],
      ),
    );
  }
}

class _LawButton extends StatelessWidget {
  const _LawButton({
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
    final Color fill;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
    }

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 70,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTheme.heading(size: 15.5, height: 1.2),
          ),
        ),
      ),
    );
  }
}
