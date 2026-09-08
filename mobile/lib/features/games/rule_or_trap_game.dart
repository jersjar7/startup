import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Rule or Trap — the first item for `logarithms`.
///
/// One claim at a time, legal or not. It exists for the warning the lesson
/// prints in bold: there is no rule for a sum inside a log, and students who
/// split one lose easy marks. Nothing is evaluated; the student is judging a
/// move, which is what the exam actually rewards.
class RuleOrTrapGame extends StatefulWidget {
  const RuleOrTrapGame({super.key});

  @override
  State<RuleOrTrapGame> createState() => _RuleOrTrapGameState();
}

@immutable
class Claim {
  const Claim({
    required this.latex,
    required this.legal,
    required this.why,
    required this.source,
  });

  final String latex;
  final bool legal;

  /// Said the same way whether they were right or wrong: the rule itself.
  final String why;

  /// The web problem this claim was authored from.
  final String source;
}

const claims = <Claim>[
  Claim(
    latex: r'\log(xy) = \log x + \log y',
    legal: true,
    why: 'The product rule. A product inside becomes a sum outside.',
    source: 'math-log-q3',
  ),
  Claim(
    latex: r'\log(x + y) = \log x + \log y',
    legal: false,
    why:
        'There is no rule for a sum inside a log. Only products, quotients '
        'and powers have rules.',
    source: 'math-log-q3',
  ),
  Claim(
    latex: r'\log\!\left(\frac{x}{y}\right) = \log x - \log y',
    legal: true,
    why: 'The quotient rule. A division inside becomes a subtraction outside.',
    source: 'math-log-q3',
  ),
  Claim(
    latex: r'\log\!\left(\frac{x}{y}\right) = \frac{\log x}{\log y}',
    legal: false,
    why: 'A quotient inside becomes a subtraction, not a division of two logs.',
    source: 'math-log-q3',
  ),
  Claim(
    latex: r'\log(x^{c}) = c\,\log x',
    legal: true,
    why:
        'The power rule, and the one move most FE log problems come down to: '
        'pull the exponent down in front.',
    source: 'math-log-q1',
  ),
  Claim(
    latex: r'\log(x^{c}) = (\log x)^{c}',
    legal: false,
    why:
        'The exponent comes down as a multiplier, it does not stay as a power '
        'of the log.',
    source: 'math-log-q1',
  ),
  Claim(
    latex: r'\log_{b} b = 1',
    legal: true,
    why: 'The base raised to what power gives the base? One.',
    source: 'math-log-q1',
  ),
  Claim(
    latex: r'\log 1 = 0',
    legal: true,
    why: 'Any base raised to the power zero is one.',
    source: 'math-log-q1',
  ),
  Claim(
    latex: r'\log(x - y) = \log x - \log y',
    legal: false,
    why:
        'A subtraction outside comes from a division inside, never from a '
        'subtraction inside.',
    source: 'math-log-q3',
  ),
  Claim(
    latex: r'\ln(e^{x}) = x',
    legal: true,
    why:
        'A log undoes its own base exactly. This is what gets an unknown down '
        'out of an exponent.',
    source: 'math-log-q2',
  ),
];

class _RuleOrTrapGameState extends State<RuleOrTrapGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'rule-or-trap',
    chapterId: 'mathematics',
    total: claims.length,
    sourceProblemIdOf: (round) => claims[round].source,
  )..addListener(_onSession);

  bool? _choice;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  Claim get _claim => claims[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.done) {
      return BoardDone(
        session: _session,
        title: 'Rule or Trap',
        closing:
            'Products, quotients and powers have rules. A sum inside a log '
            'does not, and no amount of algebra will give it one. Using the '
            'rules on a real problem is still desk work.',
      );
    }

    final answered = _session.answered;

    return BoardShell(
      session: _session,
      brief: logRulesBrief,
      buttonLabel: answered ? 'Next' : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _choice = null);
              _session.next();
            }
          : (_choice == null
                ? null
                : () => _session.submit(
                    ok: _choice == _claim.legal,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IS THIS MOVE LEGAL',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Same base throughout. Decide whether the step is allowed, without '
            'working anything out.',
            style: TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
            ),
            child: Center(child: MathBlock(_claim.latex, fontSize: 22)),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _Verdict(
                  label: 'Legal',
                  icon: Icons.check_rounded,
                  selected: _choice == true,
                  locked: answered,
                  isTruth: _claim.legal == true,
                  onTap: answered ? null : () => setState(() => _choice = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Verdict(
                  label: 'No such rule',
                  icon: Icons.close_rounded,
                  selected: _choice == false,
                  locked: answered,
                  isTruth: _claim.legal == false,
                  onTap: answered
                      ? null
                      : () => setState(() => _choice = false),
                ),
              ),
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 18),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'CORRECT' : 'NOT QUITE',
              body: _claim.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Verdict extends StatelessWidget {
  const _Verdict({
    required this.label,
    required this.icon,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String label;
  final IconData icon;
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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: border == AppColors.line ? AppColors.ink3 : border,
              ),
              const SizedBox(height: 6),
              Text(label, style: AppTheme.heading(size: 15)),
            ],
          ),
        ),
      ),
    );
  }
}
