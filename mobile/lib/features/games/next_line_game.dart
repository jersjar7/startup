import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Which Line Comes Next — the second item for `lhopitals-rule`.
///
/// The lesson carries a warning callout about one confusion and only one: this
/// is not the quotient rule. The top gets differentiated alone and the bottom
/// gets differentiated alone. A student who has mixed the two up writes a line
/// that looks like real work, so the honest test is to show them the line and
/// ask whether it is the one. Every round offers the quotient-rule version,
/// every round offers a half-done version, and every round offers the truth.
class NextLineGame extends StatefulWidget {
  const NextLineGame({super.key});

  @override
  State<NextLineGame> createState() => _NextLineGameState();
}

@immutable
class NextLineRound {
  const NextLineRound({
    required this.from,
    required this.options,
    required this.answer,
    required this.quotientLine,
    required this.why,
    required this.source,
  });

  /// A limit already known to be one of the two indeterminate forms.
  final String from;
  final List<String> options;
  final int answer;

  /// Which option is the quotient rule worked out in full. Named rather than
  /// guessed at, so a test can insist every round carries one and that it is
  /// never the answer.
  final int quotientLine;
  final String why;
  final String source;
}

const nextLines = <NextLineRound>[
  NextLineRound(
    from: r'\lim_{x \to 0}\frac{\sin x}{x}',
    options: [
      r'\lim_{x \to 0}\frac{x\cos x - \sin x}{x^2}',
      r'\lim_{x \to 0}\frac{\cos x}{1}',
      r'\lim_{x \to 0}\frac{\cos x}{x}',
    ],
    answer: 1,
    quotientLine: 0,
    why:
        'Top alone, bottom alone. The first line is the quotient rule, which '
        'is for differentiating a fraction, not for taking the limit of one. '
        'The third left the bottom untouched.',
    source: 'math-lh-q1',
  ),
  NextLineRound(
    from: r'\lim_{x \to 0}\frac{e^x - 1}{2x}',
    options: [
      r'\lim_{x \to 0}\frac{e^x}{2}',
      r'\lim_{x \to 0}\frac{2x\,e^x - 2(e^x - 1)}{4x^2}',
      r'\lim_{x \to 0}\frac{e^x - 1}{2}',
    ],
    answer: 0,
    quotientLine: 1,
    why:
        'The derivative of the constant is zero, which is what makes the top '
        'collapse to just the exponential. The last line differentiated the '
        'bottom and left the top alone.',
    source: 'math-lh-q2',
  ),
  NextLineRound(
    from: r'\lim_{x \to 2}\frac{x^2 - 4}{x - 2}',
    options: [
      r'\lim_{x \to 2}\frac{2x}{x - 2}',
      r'\lim_{x \to 2}\frac{(x-2)2x - (x^2-4)}{(x-2)^2}',
      r'\lim_{x \to 2}\frac{2x}{1}',
    ],
    answer: 2,
    quotientLine: 1,
    why:
        'Both halves get differentiated, and the derivative of x minus 2 is '
        '1. The middle line is the quotient rule again, and it is a great '
        'deal more work for a wrong answer.',
    source: 'math-lh-q1',
  ),
  NextLineRound(
    from: r'\lim_{x \to \infty}\frac{3x^2 + 2x}{x^2 - 5}',
    options: [
      r'\lim_{x \to \infty}\frac{6x + 2}{x^2 - 5}',
      r'\lim_{x \to \infty}\frac{6x + 2}{2x}',
      r'\lim_{x \to \infty}\frac{(x^2-5)(6x+2) - (3x^2+2x)2x}{(x^2-5)^2}',
    ],
    answer: 1,
    quotientLine: 2,
    why:
        'The minus 5 differentiates to nothing, so the bottom becomes 2x. '
        'This is still infinity over infinity, which means another pass, not '
        'that something went wrong.',
    source: 'math-lh-q2',
  ),
  NextLineRound(
    from: r'\lim_{x \to 0}\frac{1 - \cos x}{x^2}',
    options: [
      r'\lim_{x \to 0}\frac{-\sin x}{2x}',
      r'\lim_{x \to 0}\frac{\sin x}{2x}',
      r'\lim_{x \to 0}\frac{x^2\sin x - (1-\cos x)2x}{x^4}',
    ],
    answer: 1,
    quotientLine: 2,
    why:
        'The derivative of minus cosine is PLUS sine, so the two minus signs '
        'cancel. The first line kept a minus that is not there, and it turns '
        'a positive answer negative.',
    source: 'math-lh-q1',
  ),
  NextLineRound(
    from: r'\lim_{x \to 0}\frac{\ln(1 + x)}{x}',
    options: [
      r'\lim_{x \to 0}\frac{\frac{1}{x}}{1}',
      r'\lim_{x \to 0}\frac{\frac{x}{1+x} - \ln(1+x)}{x^2}',
      r'\lim_{x \to 0}\frac{\frac{1}{1 + x}}{1}',
    ],
    answer: 2,
    quotientLine: 1,
    why:
        'The derivative of the log of one plus x is one over one plus x, not '
        'one over x. The inside of the log carries through to the bottom of '
        'the fraction, which is the chain rule doing its job.',
    source: 'math-lh-q1',
  ),
];

class _NextLineGameState extends State<NextLineGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'next-line',
    chapterId: 'mathematics',
    total: nextLines.length,
    sourceProblemIdOf: (round) => nextLines[round].source,
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

  NextLineRound get _round => nextLines[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Line Comes Next',
        closing:
            'Differentiate the top on its own and the bottom on its own. The '
            'quotient rule is for the derivative of a fraction; this is the '
            'limit of one, and they are not the same job.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: separatelyBrief,
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
            'THE FORM IS INDETERMINATE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'The rule applies. Which line is the one it gives you?',
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
              color: AppColors.creamDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: MathBlock(r.from, fontSize: 19),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < r.options.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _LineRow(
              key: ValueKey('line-$i'),
              latex: r.options[i],
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
              title: _session.correct! ? 'TOP AND BOTTOM' : 'NOT THAT LINE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({
    super.key,
    required this.latex,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String latex;
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
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Center(child: MathBlock(latex, fontSize: 16)),
        ),
      ),
    );
  }
}
