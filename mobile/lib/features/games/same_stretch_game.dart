import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'fiber_figures.dart';
import 'lesson_brief.dart';

/// Same Stretch, Different Stress — the second item for
/// `composite-materials`.
///
/// The lesson's hardest problem asks for the stress in the fibers and the
/// arithmetic is three lines of it, but the idea underneath is one sentence:
/// pulled along the fibers, everything stretches together, so the stiff part
/// takes the stress and the soft part hardly feels it. Turn the load
/// sideways and it is the other way about: the same stress everywhere and the
/// soft part doing all the moving. Every round asks which phase, and none of
/// them asks for a number.
class SameStretchGame extends StatefulWidget {
  const SameStretchGame({super.key});

  @override
  State<SameStretchGame> createState() => _SameStretchGameState();
}

/// Which phase a round is about.
enum Phase2 { fiber, matrix, equal }

extension PhaseWords on Phase2 {
  String get plain => switch (this) {
        Phase2.fiber => 'The fibers',
        Phase2.matrix => 'The matrix',
        Phase2.equal => 'Neither: the two are equal',
      };
}

@immutable
class ShareRound {
  const ShareRound({
    required this.subject,
    required this.asked,
    required this.blend,
    required this.lay,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Blend blend;
  final Lay lay;
  final Phase2 answer;
  final String why;
  final String source;
}

/// The lesson's steel fiber composite: 200 against 3, a quarter fiber.
const _steel = Blend(
  fiberE: 200,
  matrixE: 3,
  fiberShare: 0.25,
  fiberName: 'steel fiber',
  matrixName: 'matrix',
);

/// Its carbon and epoxy.
const _carbon = Blend(
  fiberE: 230,
  matrixE: 3.5,
  fiberShare: 0.40,
  fiberName: 'carbon fiber',
  matrixName: 'epoxy',
);

const phaseRounds = <ShareRound>[
  ShareRound(
    subject: 'pulled along the fibers',
    asked: 'Which of the two stretches more?',
    blend: _steel,
    lay: Lay.along,
    answer: Phase2.equal,
    why:
        'Neither: they stretch by exactly the same amount, and that is the '
        'whole of the isostrain idea. They are stuck to each other and the '
        'load runs along both, so neither can move without the other. Every '
        'other answer on this page follows from that one sentence.',
    source: 'mat-com-q2',
  ),
  ShareRound(
    subject: 'the same pull',
    asked: 'Which of the two carries the higher stress?',
    blend: _steel,
    lay: Lay.along,
    answer: Phase2.fiber,
    why:
        'The fibers, and by the ratio of the moduli: sixty seven times the '
        'stress in the matrix, because stress is modulus times strain and the '
        'strain is shared. This is why the lesson\'s hardest problem gets 383 '
        'megapascals in the fibers when the composite as a whole is only '
        'carrying a hundred.',
    source: 'mat-com-q3',
  ),
  ShareRound(
    subject: 'a quarter of the volume',
    asked:
        'The fibers are a quarter of the volume. Which phase carries more of '
        'the total LOAD?',
    blend: _steel,
    lay: Lay.along,
    answer: Phase2.fiber,
    why:
        'The fibers still, and it is not close: a quarter of the volume at '
        'sixty seven times the stress carries about ninety six percent of the '
        'load. The matrix is not there to carry the load. It is there to hold '
        'the fibers in place, keep them apart and pass load into them.',
    source: 'mat-com-q3',
  ),
  ShareRound(
    subject: 'pushed across the fibers',
    asked: 'Now the load runs across them. Which carries the higher stress?',
    blend: _carbon,
    lay: Lay.across,
    answer: Phase2.equal,
    why:
        'Neither: across the fibers the two are in line one behind the other, '
        'so the same stress passes through both. That is the isostress case, '
        'and it is the exact mirror of the first round. Whichever quantity is '
        'shared, the other one is not.',
    source: 'mat-com-q2',
  ),
  ShareRound(
    subject: 'the same sideways push',
    asked: 'Across the fibers, which of the two stretches more?',
    blend: _carbon,
    lay: Lay.across,
    answer: Phase2.matrix,
    why:
        'The matrix, by a mile. Under the same stress the softer material '
        'strains far more, so nearly all the movement across a composite '
        'happens in the epoxy. That is why the composite comes out barely '
        'stiffer than the matrix in that direction, and why the reciprocal '
        'rule gives such a small number.',
    source: 'mat-com-q2',
  ),
  ShareRound(
    subject: 'against the composite as a whole',
    asked:
        'Pulled along the fibers again. Which phase is at a stress above the '
        'composite average?',
    blend: _steel,
    lay: Lay.along,
    answer: Phase2.fiber,
    why:
        'The fibers, always. The composite stress is the average of the two '
        'weighted by volume, so the stiff phase sits above it and the soft '
        'phase below: 383 in the fibers, under 6 in the matrix, and 100 for '
        'the composite. A fiber stress that comes out BELOW the composite '
        'stress means the strain and the stress got swapped somewhere.',
    source: 'mat-com-q3',
  ),
];

class _SameStretchGameState extends State<SameStretchGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'same-stretch',
    chapterId: 'materials',
    total: phaseRounds.length,
    sourceProblemIdOf: (round) => phaseRounds[round].source,
  )..addListener(_onSession);

  Phase2? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ShareRound get _round => phaseRounds[_session.round];

  int? _index(Phase2? which) => switch (which) {
        Phase2.fiber => 0,
        Phase2.matrix => 1,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Same Stretch, Different Stress',
        closing:
            'Along the fibers the STRAIN is shared, so the stiff phase takes '
            'the stress: the fibers can sit at several times the composite '
            'stress while the matrix barely feels it. Across the fibers the '
            'STRESS is shared instead, and the soft matrix does all the '
            'moving. Whichever one is equal, the other one is not.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: isostrainBrief,
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
            'WHICH PHASE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.asked,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          EngineeringGrid(
            minor: 18,
            major: 90,
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: CustomPaint(
                painter: BlendPainter(
                  blend: r.blend,
                  lay: r.lay,
                  picked: _index(_picked),
                  answer: answered ? _index(r.answer) : null,
                  locked: answered,
                  stretched: answered,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Phase2.values) ...[
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
              title: _session.correct! ? 'THAT IS THE ONE' : 'NOT THAT ONE',
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
