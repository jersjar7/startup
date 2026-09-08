import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Find the Slip — the second item for `derivatives-rules`.
///
/// A worked solution with one wrong line in it. Tap the line, then say what
/// went wrong. It is the closest a phone gets to real problem solving without
/// pretending to be a desk: to see a wrong line you have to be holding the
/// right one in your head, which is generation rather than recognition.
///
/// Every slip here is one the lesson names, and the lesson calls the quotient
/// rule the biggest sign-error generator on the exam.
class FindTheSlipGame extends StatefulWidget {
  const FindTheSlipGame({super.key});

  @override
  State<FindTheSlipGame> createState() => _FindTheSlipGameState();
}

@immutable
class Slip {
  const Slip({
    required this.problem,
    required this.lines,
    required this.badLine,
    required this.reasons,
    required this.reason,
    required this.why,
    required this.source,
  });

  final String problem;

  /// The worked solution, one entry per line.
  final List<String> lines;

  /// Which line is wrong.
  final int badLine;

  /// Offered explanations, one of them right.
  final List<String> reasons;
  final int reason;

  final String why;
  final String source;
}

const slips = <Slip>[
  Slip(
    problem: r'f(x) = (3x+5)^4',
    lines: [
      r'\text{Outer power rule: } 4(3x+5)^3',
      r'\text{Inner derivative: } \frac{d}{dx}(3x+5) = 3',
      r"\text{Multiply: } f'(x) = 4(3x+5)^3",
      r"\text{So } f'(x) = 4(3x+5)^3",
    ],
    badLine: 2,
    reasons: [
      'The inner derivative was never multiplied in',
      'The power should stay at 4',
      'The inner derivative is 5, not 3',
    ],
    reason: 0,
    why:
        'The line before it found the 3 and then the multiplication dropped '
        'it. The answer is 12(3x+5) cubed. This is the single most common '
        'chain rule failure.',
    source: 'math-dr-q1',
  ),
  Slip(
    problem: r'f(x) = x^2 e^{3x}',
    lines: [
      r'u = x^2,\quad v = e^{3x}',
      r'\frac{du}{dx} = 2x, \quad \frac{dv}{dx} = e^{3x}',
      r"f'(x) = x^2 e^{3x} + e^{3x}\,2x",
      r"f'(x) = e^{3x}(x^2 + 2x)",
    ],
    badLine: 1,
    reasons: [
      'The derivative of the exponential is missing its factor of 3',
      'The derivative of x squared should be x',
      'The product rule needs a minus sign',
    ],
    reason: 0,
    why:
        'The derivative of e to the 3x is 3e to the 3x, because the argument '
        'is not plain x. Everything after that line inherits the mistake.',
    source: 'math-dr-q2',
  ),
  Slip(
    problem: r'f(x) = \frac{\sin x}{x^2+1}',
    lines: [
      r'u = \sin x, \quad v = x^2 + 1',
      r'\frac{du}{dx} = \cos x, \quad \frac{dv}{dx} = 2x',
      r"f'(x) = \frac{\sin x \cdot 2x - (x^2+1)\cos x}{(x^2+1)^2}",
      r'\text{Leave the denominator squared}',
    ],
    badLine: 2,
    reasons: [
      'The two products in the numerator are the wrong way round',
      'The denominator should not be squared',
      'The derivative of the sine is wrong',
    ],
    reason: 0,
    why:
        'Lo d-hi minus hi d-lo. The bottom function goes FIRST, multiplying '
        'the derivative of the top. Swapping them flips the sign of the whole '
        'answer.',
    source: 'math-dr-q3',
  ),
  Slip(
    problem: r'f(x) = \frac{\sin x}{x^2+1}',
    lines: [
      r'u = \sin x, \quad v = x^2 + 1',
      r"f'(x) = \frac{(x^2+1)\cos x - \sin x \cdot 2x}{x^2+1}",
      r'\text{Numerator is lo d-hi minus hi d-lo}',
      r'\text{Denominator taken from } v',
    ],
    badLine: 1,
    reasons: [
      'The denominator was not squared',
      'The numerator terms are swapped',
      'The derivative of the bottom is wrong',
    ],
    reason: 0,
    why:
        'The quotient rule puts v SQUARED underneath. The numerator here is '
        'right, which is what makes the missing square easy to miss.',
    source: 'math-dr-q3',
  ),
  Slip(
    problem: r'f(x) = x^2 e^{3x}',
    lines: [
      r'\text{Product rule with } u = x^2,\; v = e^{3x}',
      r"f'(x) = 2x \cdot 3e^{3x}",
      r"f'(x) = 6xe^{3x}",
      r'\text{Both factors differentiated}',
    ],
    badLine: 1,
    reasons: [
      'The product rule was not applied: the two derivatives were multiplied',
      'The chain rule factor is missing',
      'The derivative of x squared is wrong',
    ],
    reason: 0,
    why:
        'The derivative of a product is not the product of the derivatives. '
        'It is u dv plus v du, which is two terms, not one.',
    source: 'math-dr-q2',
  ),
  Slip(
    problem: r'f(x) = \sin(3x^2)',
    lines: [
      r'\text{Outer: } \frac{d}{dx}\sin u = \cos u',
      r'\text{Inner: } u = 3x^2,\; \frac{du}{dx} = 6x',
      r"f'(x) = \cos(6x)",
      r'\text{Chain rule applied}',
    ],
    badLine: 2,
    reasons: [
      'The inner derivative multiplies the outside, it does not replace the '
          'argument',
      'The derivative of the sine should be minus cosine',
      'The inner derivative should be 3x',
    ],
    reason: 0,
    why:
        'The argument stays as it was. The answer is 6x cos(3x squared): the '
        'inner derivative multiplies from outside, it never moves inside.',
    source: 'math-dr-q1',
  ),
];

class _FindTheSlipGameState extends State<FindTheSlipGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'find-the-slip',
    chapterId: 'mathematics',
    total: slips.length,
    sourceProblemIdOf: (round) => slips[round].source,
  )..addListener(_onSession);

  int? _line;
  int? _reason;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  Slip get _round => slips[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Find the Slip',
        closing:
            'Seeing a wrong line means holding the right one in your '
            'head. Dropped chain factors, swapped quotient terms and '
            'unsquared denominators are where the marks actually go.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final ready = _line != null && _reason != null;

    return BoardShell(
      session: _session,
      brief: quotientOrderBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() {
                _line = null;
                _reason = null;
              });
              _session.next();
            }
          : (!ready
                ? null
                : () => _session.submit(
                    ok: _line == r.badLine && _reason == r.reason,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ONE LINE IS WRONG',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the line that does not follow, then say what went wrong.',
            style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.ink2),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Center(child: MathBlock(r.problem, fontSize: 19)),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.lines.length; i++) ...[
            _Line(
              index: i,
              latex: r.lines[i],
              picked: _line == i,
              truth: answered && i == r.badLine,
              wrong: answered && _line == i && i != r.badLine,
              onTap: answered ? null : () => setState(() => _line = i),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 10),
          Text('AND WHAT WENT WRONG', style: AppTheme.overline()),
          const SizedBox(height: 10),
          for (var i = 0; i < r.reasons.length; i++) ...[
            _Reason(
              text: r.reasons[i],
              picked: _reason == i,
              truth: answered && i == r.reason,
              wrong: answered && _reason == i && i != r.reason,
              onTap: answered ? null : () => setState(() => _reason = i),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 12),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'CORRECT' : 'NOT QUITE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.index,
    required this.latex,
    required this.picked,
    required this.truth,
    required this.wrong,
    required this.onTap,
  });

  final int index;
  final String latex;
  final bool picked;
  final bool truth;
  final bool wrong;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border = truth
        ? AppColors.forest
        : wrong
        ? AppColors.error
        : picked
        ? AppColors.ember
        : AppColors.line;
    final Color fill = truth
        ? AppColors.forestBg
        : wrong
        ? AppColors.errorBg
        : picked
        ? AppColors.emberBg
        : AppColors.white;

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              Text(
                '${index + 1}',
                style: AppTheme.mono(size: 13, color: AppColors.ink3),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MathBlock(
                  latex,
                  fontSize: 16,
                  align: Alignment.centerLeft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Reason extends StatelessWidget {
  const _Reason({
    required this.text,
    required this.picked,
    required this.truth,
    required this.wrong,
    required this.onTap,
  });

  final String text;
  final bool picked;
  final bool truth;
  final bool wrong;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border = truth
        ? AppColors.forest
        : wrong
        ? AppColors.error
        : picked
        ? AppColors.ember
        : AppColors.line;
    final Color fill = truth
        ? AppColors.forestBg
        : wrong
        ? AppColors.errorBg
        : picked
        ? AppColors.emberBg
        : AppColors.white;

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppColors.charcoal,
            ),
          ),
        ),
      ),
    );
  }
}
