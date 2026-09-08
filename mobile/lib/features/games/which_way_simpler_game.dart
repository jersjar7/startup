import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Which Way Gets Simpler — the second item for `integral-calculus`.
///
/// LIATE is a memory trick, and a student who only memorizes it cannot tell
/// when it is steering them wrong. The reason behind it is visible instead:
/// the right choice of u leaves an EASIER integral than the one you started
/// with, and the wrong one leaves a harder one. So both branches are worked
/// one step and the student picks the one that got simpler. The rule is then
/// something they have seen do its job rather than a word to recite.
class WhichWaySimplerGame extends StatefulWidget {
  const WhichWaySimplerGame({super.key});

  @override
  State<WhichWaySimplerGame> createState() => _WhichWaySimplerGameState();
}

@immutable
class PartsBranch {
  const PartsBranch({required this.u, required this.dv, required this.left});

  final String u;
  final String dv;

  /// The integral you are left holding after one round of by parts.
  final String left;
}

@immutable
class PartsRound {
  const PartsRound({
    required this.integral,
    required this.branches,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String integral;
  final List<PartsBranch> branches;
  final int answer;
  final String why;
  final String source;
}

const partsRounds = <PartsRound>[
  PartsRound(
    integral: r'\int x\,e^{2x}\,dx',
    branches: [
      PartsBranch(
        u: 'x',
        dv: r'e^{2x}\,dx',
        left: r'\int \frac{e^{2x}}{2}\,dx',
      ),
      PartsBranch(
        u: r'e^{2x}',
        dv: r'x\,dx',
        left: r'\int \frac{x^2}{2}\,2e^{2x}\,dx',
      ),
    ],
    answer: 0,
    why:
        'Differentiating x kills it; differentiating the exponential does '
        'not. LIATE puts Algebraic before Exponential for exactly this '
        'reason, and the second branch has a higher power of x than the '
        'question started with.',
    source: 'math-ic-q2',
  ),
  PartsRound(
    integral: r'\int x\,\sin x\,dx',
    branches: [
      PartsBranch(
        u: r'\sin x',
        dv: r'x\,dx',
        left: r'\int \frac{x^2}{2}\cos x\,dx',
      ),
      PartsBranch(u: 'x', dv: r'\sin x\,dx', left: r'\int -\cos x\,dx'),
    ],
    answer: 1,
    why:
        'Algebraic before Trig. Letting u be the x turns it into a 1 and '
        'leaves a cosine you can integrate on sight. The other way the power '
        'grows and you are further from an answer than when you started.',
    source: 'math-ic-q2',
  ),
  PartsRound(
    integral: r'\int x\,\ln x\,dx',
    branches: [
      PartsBranch(u: 'x', dv: r'\ln x\,dx', left: r'\text{needs } \int \ln x\,dx \text{ first}'),
      PartsBranch(u: r'\ln x', dv: r'x\,dx', left: r'\int \frac{x}{2}\,dx'),
    ],
    answer: 1,
    why:
        'Logs come first in LIATE, and this is why: a log is easy to '
        'differentiate and awkward to integrate. Put it in the u slot and it '
        'turns into 1/x. Put it in dv and you have given yourself a second, '
        'harder problem.',
    source: 'math-ic-q2',
  ),
  PartsRound(
    integral: r'\int x^2\,e^{x}\,dx',
    branches: [
      PartsBranch(u: r'x^2', dv: r'e^{x}\,dx', left: r'\int 2x\,e^{x}\,dx'),
      PartsBranch(
        u: r'e^{x}',
        dv: r'x^2\,dx',
        left: r'\int \frac{x^3}{3}\,e^{x}\,dx',
      ),
    ],
    answer: 0,
    why:
        'The power drops from 2 to 1, so a second round of by parts finishes '
        'it. Going the other way the power climbs and it never ends. Simpler '
        'does not have to mean solved in one move, only closer.',
    source: 'math-ic-q2',
  ),
  PartsRound(
    integral: r'\int x\,\cos 2x\,dx',
    branches: [
      PartsBranch(
        u: r'\cos 2x',
        dv: r'x\,dx',
        left: r'\int \frac{x^2}{2}\,(-2\sin 2x)\,dx',
      ),
      PartsBranch(
        u: 'x',
        dv: r'\cos 2x\,dx',
        left: r'\int \frac{\sin 2x}{2}\,dx',
      ),
    ],
    answer: 1,
    why:
        'Same shape as x sin x, and the inner 2 does not change the decision. '
        'It only changes the factor of one half you pick up integrating the '
        'cosine, which is where the arithmetic mistakes live.',
    source: 'math-ic-q2',
  ),
  PartsRound(
    integral: r'\int x^2\,\sin x\,dx',
    branches: [
      PartsBranch(
        u: r'x^2',
        dv: r'\sin x\,dx',
        left: r'\int 2x\,(-\cos x)\,dx',
      ),
      PartsBranch(
        u: r'\sin x',
        dv: r'x^2\,dx',
        left: r'\int \frac{x^3}{3}\cos x\,dx',
      ),
    ],
    answer: 0,
    why:
        'Algebraic before Trig again, and with a squared term it takes two '
        'passes. Each pass should knock the power down by one; if yours is '
        'going up, you picked the wrong u.',
    source: 'math-ic-q2',
  ),
];

class _WhichWaySimplerGameState extends State<WhichWaySimplerGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-way-simpler',
    chapterId: 'mathematics',
    total: partsRounds.length,
    sourceProblemIdOf: (round) => partsRounds[round].source,
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

  PartsRound get _round => partsRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Way Gets Simpler',
        closing:
            'By parts trades one integral for another. The choice of u is '
            'right when the trade leaves you better off, which is all LIATE '
            'is telling you. Carrying it out belongs on paper.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: byPartsBrief,
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
            'ONE STEP OF BY PARTS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Both choices are legal. Tap the one that leaves you better off '
            'than you started.',
            style: TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: MathBlock(r.integral, fontSize: 19),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < r.branches.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _BranchCard(
              key: ValueKey('branch-$i'),
              branch: r.branches[i],
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'SIMPLER' : 'THAT WAY IS HARDER',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    super.key,
    required this.branch,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final PartsBranch branch;
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
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MathBlock('u = ${branch.u}', fontSize: 15, fit: false),
                  const SizedBox(width: 16),
                  Flexible(
                    child: MathBlock(
                      'dv = ${branch.dv}',
                      fontSize: 15,
                      align: Alignment.centerLeft,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'LEAVES YOU WITH',
                style: AppTheme.overline(color: AppColors.ink3),
              ),
              const SizedBox(height: 6),
              MathBlock(branch.left, fontSize: 17, align: Alignment.centerLeft),
            ],
          ),
        ),
      ),
    );
  }
}
