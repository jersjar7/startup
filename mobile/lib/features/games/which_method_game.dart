import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Which Method — the third item for `numerical-methods`.
///
/// Two of the lesson's three problems are judgment rather than arithmetic:
/// what bisection requires, and what makes Newton fall over. Both come down to
/// the same trade the tip names. Newton is fast and wants a derivative and a
/// decent guess; bisection is slow and wants nothing but a sign change. So the
/// rounds are situations rather than equations, and the third option is the
/// one that matters, because a method being available is not the same as it
/// working.
class WhichMethodGame extends StatefulWidget {
  const WhichMethodGame({super.key});

  @override
  State<WhichMethodGame> createState() => _WhichMethodGameState();
}

enum MethodPick { newton, bisection, newtonStruggles }

@immutable
class MethodRound {
  const MethodRound({
    required this.situation,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String situation;
  final MethodPick answer;
  final String why;
  final String source;
}

const methodRounds = <MethodRound>[
  MethodRound(
    situation:
        'You have the derivative, and a starting guess you know sits close to '
        'the root. You want an answer in as few steps as possible.',
    answer: MethodPick.newton,
    why:
        'This is exactly what Newton is for. Near a root every curve is '
        'nearly straight, which is why following the tangent gets so close so '
        'fast.',
    source: 'math-num-q3',
  ),
  MethodRound(
    situation:
        'All you know is that the function is above the axis at x = 1 and '
        'below it at x = 4. You do not have the derivative.',
    answer: MethodPick.bisection,
    why:
        'A sign change is the whole of what bisection asks for, and it does '
        'not want a derivative. It is slower, and it will get there.',
    source: 'math-num-q2',
  ),
  MethodRound(
    situation:
        'You have the derivative, but the guess you were handed sits where '
        'the curve is almost flat.',
    answer: MethodPick.newtonStruggles,
    why:
        'An almost flat tangent takes an enormous walk to reach the axis, so '
        'the step is huge and lands nowhere useful. A derivative near zero is '
        'the named cause of Newton diverging.',
    source: 'math-num-q3',
  ),
  MethodRound(
    situation:
        'The function is a straight line and you know its slope.',
    answer: MethodPick.newton,
    why:
        'The tangent to a line is the line, so one iteration lands exactly on '
        'the root. This is the best Newton ever does, and it is the reason it '
        'behaves so well once it gets close.',
    source: 'math-num-q3',
  ),
  MethodRound(
    situation:
        'You have the derivative, but the only guess you have is a long way '
        'from the root, on a curve that bends about a good deal in between.',
    answer: MethodPick.newtonStruggles,
    why:
        'A far guess is the other named cause. The tangent out there points '
        'somewhere unrelated to the root, so the method can wander off or '
        'swing back and forth without settling.',
    source: 'math-num-q3',
  ),
  MethodRound(
    situation:
        'It has to converge. You can afford to wait, and you would rather not '
        'find out afterwards that it ran away.',
    answer: MethodPick.bisection,
    why:
        'Bisection is the one with a guarantee. As long as the interval '
        'brackets a sign change it cannot fail, and the price of that is '
        'halving the interval instead of leaping at the answer.',
    source: 'math-num-q2',
  ),
];

class _WhichMethodGameState extends State<WhichMethodGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-method',
    chapterId: 'mathematics',
    total: methodRounds.length,
    sourceProblemIdOf: (round) => methodRounds[round].source,
  )..addListener(_onSession);

  MethodPick? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  MethodRound get _round => methodRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Method',
        closing:
            'Newton is fast and wants a derivative and a decent guess. '
            'Bisection is slow and wants nothing but a sign change. Knowing '
            'which one the situation allows is most of what this topic asks.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: methodChoiceBrief,
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
            'WHAT THE SITUATION ALLOWS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: Text(
              r.situation,
              style: const TextStyle(
                fontSize: 15.5,
                height: 1.55,
                color: AppColors.charcoal,
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in MethodPick.values) ...[
            if (option != MethodPick.values.first) const SizedBox(height: 8),
            _MethodRow(
              key: ValueKey('method-${option.name}'),
              option: option,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
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

class _MethodRow extends StatelessWidget {
  const _MethodRow({
    super.key,
    required this.option,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final MethodPick option;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  static const _labels = {
    MethodPick.newton: (
      "Newton's method",
      'fast, wants the derivative',
    ),
    MethodPick.bisection: (
      'Bisection',
      'slow, wants a sign change',
    ),
    MethodPick.newtonStruggles: (
      "Newton, but it may not converge",
      'the tangent will not help here',
    ),
  };

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

    final (label, detail) = _labels[option]!;
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.heading(size: 15)),
              const SizedBox(height: 3),
              Text(
                detail,
                style: AppTheme.mono(size: 10.5, color: AppColors.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
