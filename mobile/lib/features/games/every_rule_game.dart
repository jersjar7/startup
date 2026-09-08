import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Every Rule It Needs — the first item for `derivatives-rules`.
///
/// The first item in the app where the answer is a SET rather than one thing.
/// That is not a variation for its own sake: the lesson's own worked example
/// needs the product rule AND the chain rule, and any question that lets you
/// name a single rule lets you get it half right and feel finished. Here,
/// naming product and stopping is wrong.
class EveryRuleGame extends StatefulWidget {
  const EveryRuleGame({super.key});

  @override
  State<EveryRuleGame> createState() => _EveryRuleGameState();
}

/// The structural rules. Looking a derivative up in the handbook table is not
/// one of them, which is what "just the table" means.
enum DerivRule { product, quotient, chain }

extension DerivRuleName on DerivRule {
  String get label => switch (this) {
    DerivRule.product => 'Product rule',
    DerivRule.quotient => 'Quotient rule',
    DerivRule.chain => 'Chain rule',
  };
}

@immutable
class RuleRound {
  const RuleRound({
    required this.function,
    required this.rules,
    required this.why,
    required this.source,
  });

  final String function;

  /// Empty means the handbook table alone does it.
  final Set<DerivRule> rules;
  final String why;
  final String source;
}

const ruleRounds = <RuleRound>[
  RuleRound(
    function: r'f(x) = (3x + 5)^4',
    rules: {DerivRule.chain},
    why:
        'The argument is not plain x, so it is a chain rule. Bring the power '
        'down, then multiply by the derivative of the inside, which is the 3 '
        'most people drop.',
    source: 'math-dr-q1',
  ),
  RuleRound(
    function: r'f(x) = x^2 e^{3x}',
    rules: {DerivRule.product, DerivRule.chain},
    why:
        'Two functions multiplied, so the product rule, and the exponential '
        'has 3x inside it, so a chain rule as well. Naming only the product '
        'rule is how the factor of three goes missing.',
    source: 'math-dr-q2',
  ),
  RuleRound(
    function: r'f(x) = \frac{\sin x}{x^2 + 1}',
    rules: {DerivRule.quotient},
    why:
        'One function over another is the quotient rule. Both pieces come '
        'straight off the table, and the argument of the sine is plain x, so '
        'no chain rule.',
    source: 'math-dr-q3',
  ),
  RuleRound(
    function: r'f(x) = \sin(3x^2)',
    rules: {DerivRule.chain},
    why:
        'Nothing is multiplied or divided, but the sine has 3x squared '
        'inside, so it is a chain rule and nothing else.',
    source: 'math-dr-q1',
  ),
  RuleRound(
    function: r'f(x) = x^3 + 2x - 7',
    rules: {},
    why:
        'Term by term off the table. No product, no quotient, and every '
        'argument is plain x, so no chain either.',
    source: 'math-dr-q1',
  ),
  RuleRound(
    function: r'f(x) = e^{2x}\ln x',
    rules: {DerivRule.product, DerivRule.chain},
    why:
        'A product, and the exponential carries 2x inside it. The log is of '
        'plain x, so that half needs no chain.',
    source: 'math-dr-q2',
  ),
  RuleRound(
    function: r'f(x) = \frac{\cos(4x)}{x}',
    rules: {DerivRule.quotient, DerivRule.chain},
    why:
        'A quotient, and the cosine has 4x inside it. Two rules, and the one '
        'people miss is the chain hiding in the numerator.',
    source: 'math-dr-q3',
  ),
  RuleRound(
    function: r'f(x) = x\sin(4x)',
    rules: {DerivRule.product, DerivRule.chain},
    why:
        'A product with a composite in it. The derivative of sin(4x) is '
        '4cos(4x), not cos(4x).',
    source: 'math-dr-q2',
  ),
];

class _EveryRuleGameState extends State<EveryRuleGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'every-rule',
    chapterId: 'mathematics',
    total: ruleRounds.length,
    sourceProblemIdOf: (round) => ruleRounds[round].source,
  )..addListener(_onSession);

  final Set<DerivRule> _picked = {};
  bool _tableOnly = false;
  bool _touched = false;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  RuleRound get _round => ruleRounds[_session.round];

  void _toggle(DerivRule rule) {
    setState(() {
      _touched = true;
      _tableOnly = false;
      if (!_picked.remove(rule)) _picked.add(rule);
    });
  }

  void _pickTableOnly() {
    setState(() {
      _touched = true;
      _tableOnly = true;
      _picked.clear();
    });
  }

  bool get _isRight {
    if (_round.rules.isEmpty) return _tableOnly;
    if (_tableOnly) return false;
    return _picked.length == _round.rules.length &&
        _picked.containsAll(_round.rules);
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Every Rule It Needs',
        closing:
            'Ask two questions of any derivative: is anything multiplied '
            'or divided, and is any argument something other than plain x. '
            'Most FE problems answer yes to the second one.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: whichRuleBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() {
                _picked.clear();
                _tableOnly = false;
                _touched = false;
              });
              _session.next();
            }
          : (!_touched
                ? null
                : () => _session.submit(ok: _isRight, context: context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TAP EVERY RULE YOU NEED',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'More than one can apply. Tap all of them, or say it comes '
            'straight off the table.',
            style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.ink2),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Center(child: MathBlock(r.function, fontSize: 21)),
          ),
          const SizedBox(height: 16),
          for (final rule in DerivRule.values) ...[
            _RuleToggle(
              label: rule.label,
              on: _picked.contains(rule),
              locked: answered,
              belongs: r.rules.contains(rule),
              onTap: answered ? null : () => _toggle(rule),
            ),
            const SizedBox(height: 10),
          ],
          _RuleToggle(
            label: 'Just the table',
            on: _tableOnly,
            locked: answered,
            belongs: r.rules.isEmpty,
            onTap: answered ? null : _pickTableOnly,
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'CORRECT' : 'NOT THE FULL SET',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _RuleToggle extends StatelessWidget {
  const _RuleToggle({
    required this.label,
    required this.on,
    required this.locked,
    required this.belongs,
    required this.onTap,
  });

  final String label;
  final bool on;
  final bool locked;

  /// Whether this rule is part of the answer, revealed once locked in.
  final bool belongs;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    if (locked && belongs) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
    } else if (locked && on) {
      border = AppColors.error;
      fill = AppColors.errorBg;
    } else if (on) {
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
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: on ? AppColors.ember : Colors.transparent,
                  border: Border.all(
                    color: on ? AppColors.ember : AppColors.line,
                    width: 1.5,
                  ),
                ),
                child: on
                    ? const Icon(
                        Icons.check_rounded,
                        size: 17,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Text(label, style: AppTheme.heading(size: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
