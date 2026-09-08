import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Set It Up — the second item for `law-of-sines-cosines`.
///
/// The right law is only half of it: the marks go missing in how it is
/// written. Every wrong option here is one of the lesson's own traps, flipping
/// the sine ratio, adding the cosine term instead of subtracting it, using sin
/// where cos belongs, or the sign slip in the rearranged form. No values are
/// ever put in.
class SetItUpGame extends StatefulWidget {
  const SetItUpGame({super.key});

  @override
  State<SetItUpGame> createState() => _SetItUpGameState();
}

@immutable
class Setup {
  const Setup({
    required this.ask,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String ask;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const setups = <Setup>[
  Setup(
    ask: 'You know a, A and B. Write the expression for side b.',
    options: [
      r'b = a\,\frac{\sin B}{\sin A}',
      r'b = a\,\frac{\sin A}{\sin B}',
      r'b = a\,\frac{\cos B}{\cos A}',
      r'b = \frac{a}{\sin A \sin B}',
    ],
    answer: 0,
    why:
        'Each side sits over the sine of ITS own angle. Flipping the ratio is '
        'the classic slip, and it sends a bigger side out smaller.',
    source: 'math-lsc-q1',
  ),
  Setup(
    ask:
        'You know a, b and the angle C between them. Write the expression for '
        'the third side.',
    options: [
      r'c^2 = a^2 + b^2 + 2ab\cos C',
      r'c^2 = a^2 + b^2 - 2ab\cos C',
      r'c^2 = a^2 + b^2 - 2ab\sin C',
      r'c^2 = a^2 - b^2 - 2ab\cos C',
    ],
    answer: 1,
    why:
        'It is the Pythagorean theorem with a correction term SUBTRACTED. '
        'Adding it instead is the trap the lesson names first.',
    source: 'math-lsc-q2',
  ),
  Setup(
    ask: 'All three sides are known. Write the expression for cos C.',
    options: [
      r'\cos C = \frac{a^2 + b^2 + c^2}{2ab}',
      r'\cos C = \frac{a^2 + b^2 - c^2}{2ab}',
      r'\cos C = \frac{c^2 - a^2 - b^2}{2ab}',
      r'\cos C = \frac{a^2 + b^2 - c^2}{ab}',
    ],
    answer: 1,
    why:
        'The side opposite the angle is the one that gets subtracted, and the '
        'bottom carries the 2. A plus sign there can never give a negative '
        'cosine, so an obtuse angle becomes impossible to find.',
    source: 'math-lsc-q3',
  ),
  Setup(
    ask: 'You know b, B and c. Write the expression for sin C.',
    options: [
      r'\sin C = \frac{c\,\sin B}{b}',
      r'\sin C = \frac{b\,\sin B}{c}',
      r'\sin C = \frac{c}{b\,\sin B}',
      r'\sin C = \frac{c\,\cos B}{b}',
    ],
    answer: 0,
    why:
        'Same relation read the other way: a side over the sine of its own '
        'angle is the same for all three, so sin C = c sin B over b.',
    source: 'math-lsc-q1',
  ),
  Setup(
    ask:
        'Two sides and the included angle A are known. Write the expression '
        'for the side opposite it.',
    options: [
      r'a^2 = b^2 + c^2 - 2bc\cos A',
      r'a^2 = b^2 + c^2 - 2bc\cos B',
      r'a^2 = b^2 + c^2 + 2bc\cos A',
      r'a^2 = b^2 - c^2 + 2bc\cos A',
    ],
    answer: 0,
    why:
        'The angle in the formula is always the one opposite the side you are '
        'solving for, and it is the one between the two you know.',
    source: 'math-lsc-q2',
  ),
  Setup(
    ask:
        'A triangle where c is the longest side. Which statement follows from '
        'the Law of Cosines?',
    options: [
      r'c^2 > a^2 + b^2 \Rightarrow \cos C < 0',
      r'c^2 > a^2 + b^2 \Rightarrow \cos C > 0',
      r'c^2 = a^2 + b^2 \Rightarrow \cos C < 0',
      r'c^2 < a^2 + b^2 \Rightarrow \cos C < 0',
    ],
    answer: 0,
    why:
        'If the square of the longest side beats the other two put together, '
        'the numerator goes negative, so the cosine does too and the angle is '
        'obtuse. That is the whole reason a negative cosine is not a mistake.',
    source: 'math-lsc-q3',
  ),
];

class _SetItUpGameState extends State<SetItUpGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'set-it-up',
    chapterId: 'mathematics',
    total: setups.length,
    sourceProblemIdOf: (round) => setups[round].source,
  )..addListener(_onSession);

  int? _choice;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  Setup get _round => setups[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Set It Up',
        closing:
            'Each side over the sine of its own angle, and the cosine term '
            'subtracted, never added. Written right, the arithmetic is the easy '
            'part, and it belongs at a desk.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: setupBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _choice = null);
              _session.next();
            }
          : (_choice == null
                ? null
                : () => _session.submit(
                    ok: _choice == r.answer,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WRITE IT DOWN RIGHT',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.ask,
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < r.options.length; i++) ...[
            _FormOption(
              key: ValueKey('set-it-up-option-$i'),
              latex: r.options[i],
              selected: _choice == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _choice = i),
            ),
            const SizedBox(height: 10),
          ],
          if (answered) ...[
            const SizedBox(height: 4),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'CORRECT' : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _FormOption extends StatelessWidget {
  const _FormOption({
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 66),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: MathBlock(latex, fontSize: 18, align: Alignment.centerLeft),
        ),
      ),
    );
  }
}
