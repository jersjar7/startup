import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// One Log — the third item for `logarithms`.
///
/// Several terms in one base collapse into a single log. The student picks the
/// form, never the value: added terms multiply inside, subtracted terms divide
/// inside, a coefficient becomes an exponent. Every wrong option is a mistake
/// the lesson's own traps name, including multiplying the separate log values
/// together.
class OneLogGame extends StatefulWidget {
  const OneLogGame({super.key});

  @override
  State<OneLogGame> createState() => _OneLogGameState();
}

@immutable
class Collapse {
  const Collapse({
    required this.expression,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String expression;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const collapses = <Collapse>[
  Collapse(
    expression: r'\log x + \log y',
    options: [
      r'\log(x + y)',
      r'\log(xy)',
      r'(\log x)(\log y)',
      r'\log\!\left(\frac{x}{y}\right)',
    ],
    answer: 1,
    why:
        'Added logs multiply inside. A sum inside the log would need a rule '
        'that does not exist.',
    source: 'math-log-q3',
  ),
  Collapse(
    expression: r'\log x - \log y',
    options: [
      r'\log(x - y)',
      r'\frac{\log x}{\log y}',
      r'\log\!\left(\frac{x}{y}\right)',
      r'\log(xy)',
    ],
    answer: 2,
    why:
        'Subtracted logs divide inside. Dividing the two logs themselves is a '
        'different thing entirely, and it is the base change formula.',
    source: 'math-log-q3',
  ),
  Collapse(
    expression: r'3\log x',
    options: [r'\log(3x)', r'(\log x)^{3}', r'\log(x^{3})', r'3^{\log x}'],
    answer: 2,
    why:
        'The power rule runs both ways: a coefficient out front goes back in '
        'as an exponent.',
    source: 'math-log-q1',
  ),
  Collapse(
    expression: r'\log_2(32) - \log_2(4) + \log_2(8)',
    options: [
      r'\log_2(32 - 4 + 8)',
      r'\log_2\!\left(\frac{32 \cdot 8}{4}\right)',
      r'\log_2(32 \cdot 4 \cdot 8)',
      r'\log_2\!\left(\frac{32}{4 \cdot 8}\right)',
    ],
    answer: 1,
    why:
        'Subtraction divides, addition multiplies. This is the lesson\'s own '
        'problem: it collapses to a single log before anything is evaluated.',
    source: 'math-log-q3',
  ),
  Collapse(
    expression: r'\log a + 2\log b',
    options: [r'\log(a + b^{2})', r'2\log(ab)', r'\log(ab^{2})', r'\log(2ab)'],
    answer: 2,
    why:
        'The coefficient goes in as an exponent first, then the sum becomes a '
        'product. The two moves compose.',
    source: 'math-log-q3',
  ),
  Collapse(
    expression: r'\ln x - \ln y + \ln z',
    options: [
      r'\ln\!\left(\frac{xz}{y}\right)',
      r'\ln(x - y + z)',
      r'\ln(xyz)',
      r'\ln\!\left(\frac{x}{yz}\right)',
    ],
    answer: 0,
    why:
        'Only the subtracted term goes underneath. Natural logs obey exactly '
        'the same rules as base ten.',
    source: 'math-log-q3',
  ),
];

class _OneLogGameState extends State<OneLogGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'one-log',
    chapterId: 'mathematics',
    total: collapses.length,
    sourceProblemIdOf: (round) => collapses[round].source,
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

  Collapse get _round => collapses[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.done) {
      return BoardDone(
        session: _session,
        title: 'One Log',
        closing:
            'Added terms multiply inside, subtracted terms divide inside, '
            'a coefficient becomes an exponent. Collapse first, evaluate later, '
            'and evaluating is desk work.',
      );
    }

    final answered = _session.answered;

    return BoardShell(
      session: _session,
      brief: combineLogsBrief,
      buttonLabel: answered ? 'Next' : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _choice = null);
              _session.next();
            }
          : (_choice == null
                ? null
                : () => _session.submit(
                    ok: _choice == _round.answer,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WRITE IT AS ONE LOG',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Same base throughout. Pick the single log this is equal to, '
            'without working out any values.',
            style: TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
            ),
            child: Center(child: MathBlock(_round.expression, fontSize: 21)),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _round.options.length; i++) ...[
            _OptionCard(
              key: ValueKey('one-log-option-$i'),
              latex: _round.options[i],
              selected: _choice == i,
              locked: answered,
              isTruth: i == _round.answer,
              onTap: answered ? null : () => setState(() => _choice = i),
            ),
            const SizedBox(height: 10),
          ],
          if (answered) ...[
            const SizedBox(height: 4),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'CORRECT' : 'NOT THAT ONE',
              body: _round.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
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
          constraints: const BoxConstraints(minHeight: 62),
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
