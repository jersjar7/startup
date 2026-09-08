import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// What's Missing — the third item for `integral-calculus`.
///
/// Every finishing mistake this lesson warns about survives a correct
/// antiderivative: the plus C that is not there, the plus C that should not
/// be, the lower limit nobody subtracted, the limits still written in x after
/// a substitution. So the integration is right in every round and the same
/// four faults are on the screen every time, in the same order. That is
/// deliberate. It is a checklist, and the point is to run it every time
/// rather than to be surprised by it.
class WhatsMissingGame extends StatefulWidget {
  const WhatsMissingGame({super.key});

  @override
  State<WhatsMissingGame> createState() => _WhatsMissingGameState();
}

/// The same five verdicts in every round.
const missingVerdicts = <String>[
  'Nothing. It is finished.',
  'The plus C is missing.',
  'The lower limit was never subtracted.',
  'The limits are still in x, not u.',
  'A definite integral does not take a plus C.',
];

@immutable
class MissingRound {
  const MissingRound({
    required this.problem,
    required this.work,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String problem;

  /// The answer as somebody wrote it down, with the integration itself right.
  final String work;

  /// Index into [missingVerdicts].
  final int answer;
  final String why;
  final String source;
}

const missingRounds = <MissingRound>[
  MissingRound(
    problem: r'\int 3x^2\,dx',
    work: r'= x^3',
    answer: 1,
    why:
        'The antiderivative is right. With no limits on the integral sign the '
        'answer is a whole family of functions, and the plus C is what says '
        'so. Wrong answer choices on this exam are built out of leaving it '
        'off.',
    source: 'math-ic-q1',
  ),
  MissingRound(
    problem: r'\int_1^2 3x^2\,dx',
    work: r'= x^3 \Big|_1^2 = 8',
    answer: 2,
    why:
        'Only the top limit went in. It should be 8 minus 1, which is 7. This '
        'hides easily when the lower limit is zero, and it is the reason to '
        'write both terms out even when one of them is nothing.',
    source: 'math-ic-q1',
  ),
  MissingRound(
    problem: r'\int_0^2 3x^2\,dx',
    work: r'= x^3 \Big|_0^2 = 8 - 0 = 8',
    answer: 0,
    why:
        'Both limits used, no stray constant, and the total force under that '
        'pressure curve is 8 kilonewtons per meter of width.',
    source: 'math-ic-q1',
  ),
  MissingRound(
    problem: r'\int_0^{\pi/2} \sin^3 x\,\cos x\,dx,\quad u = \sin x',
    work: r'= \frac{u^4}{4} \Big|_0^{\pi/2}',
    answer: 3,
    why:
        'The variable changed and the limits did not. In u the range runs '
        'from 0 to 1, not from 0 to pi over 2. Either change them or put the '
        'sine back before you evaluate.',
    source: 'math-ic-q3',
  ),
  MissingRound(
    problem: r'\int_0^1 x\,e^{2x}\,dx',
    work: r'= \frac{e^2 + 1}{4} + C',
    answer: 4,
    why:
        'A definite integral is a number. The constant cancels when you '
        'subtract the two ends, so carrying it to the answer says the reader '
        'has not understood what the limits did.',
    source: 'math-ic-q2',
  ),
  MissingRound(
    problem: r'\int e^{2x}\,dx',
    work: r'= \frac{e^{2x}}{2} + C',
    answer: 0,
    why:
        'Finished, and note the half. Integrating e to the 2x divides by the '
        '2 from the exponent, and dropping that factor is the most common '
        'slip on this whole page.',
    source: 'math-ic-q2',
  ),
];

class _WhatsMissingGameState extends State<WhatsMissingGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'whats-missing',
    chapterId: 'mathematics',
    total: missingRounds.length,
    sourceProblemIdOf: (round) => missingRounds[round].source,
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

  MissingRound get _round => missingRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: "What's Missing",
        closing:
            'Getting the antiderivative right is most of the work and none of '
            'the marks. Plus C on an indefinite one, both limits on a '
            'definite one, and limits in whatever variable you ended up in.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: finishingBrief,
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
            'THE INTEGRATION IS CORRECT',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Run the checklist. What, if anything, is wrong with how this was '
            'written down?',
            style: TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MathBlock(r.problem, fontSize: 17),
                const SizedBox(height: 10),
                MathBlock(r.work, fontSize: 17),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < missingVerdicts.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _VerdictRow(
              key: ValueKey('verdict-$i'),
              label: missingVerdicts[i],
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
              title: _session.correct!
                  ? (r.answer == 0 ? 'NOTHING WRONG WITH IT' : 'CAUGHT IT')
                  : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _VerdictRow extends StatelessWidget {
  const _VerdictRow({
    super.key,
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.4,
              color: AppColors.charcoal,
            ),
          ),
        ),
      ),
    );
  }
}
