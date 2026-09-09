import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Where It Stops — the third item for `structured-programming`.
///
/// A WHILE loop checks its condition BEFORE the body, so the value that breaks
/// the condition is the one still sitting in the variable when the loop lets
/// go. Both of the lesson's named mistakes come from not believing that: one
/// stops at the last value that satisfied the condition, the other assumes the
/// answer is capped at the limit. Both are cured by seeing the whole run laid
/// out with the limit drawn across it, so the value that overshoots is on the
/// screen rather than in someone's head. One round never enters the loop at
/// all, which is the same rule from the other side.
class WhereItStopsGame extends StatefulWidget {
  const WhereItStopsGame({super.key});

  @override
  State<WhereItStopsGame> createState() => _WhereItStopsGameState();
}

@immutable
class WhileRound {
  const WhileRound({
    required this.start,
    required this.condition,
    required this.step,
    required this.run,
    required this.answer,
    required this.why,
    required this.source,
  });

  /// The line that sets the variable up, as written.
  final String start;

  /// The loop condition, as written.
  final String condition;

  /// The body, as written.
  final String step;

  /// Every value the variable takes, in order, ending with the one that
  /// breaks the condition.
  final List<int> run;

  /// The value left in the variable when the loop stops.
  final int answer;
  final String why;
  final String source;
}

const whileRounds = <WhileRound>[
  WhileRound(
    start: 'x = 1',
    condition: 'x < 100',
    step: 'x = x * 2',
    run: [1, 2, 4, 8, 16, 32, 64, 128],
    answer: 128,
    why:
        'At 64 the condition still holds, so the body runs once more and '
        'doubles it to 128. Only then does the check fail. Sixty four is the '
        'last value that passed the test, not the value left behind.',
    source: 'math-prg-q3',
  ),
  WhileRound(
    start: 'x = 1',
    condition: 'x < 50',
    step: 'x = x * 3',
    run: [1, 3, 9, 27, 81],
    answer: 81,
    why:
        'Tripling overshoots harder, and 81 is well past the fifty in the '
        'condition. Nothing caps a loop at its limit; the limit only decides '
        'when to stop going round.',
    source: 'math-prg-q3',
  ),
  WhileRound(
    start: 'x = 64',
    condition: 'x > 5',
    step: 'x = x / 2',
    run: [64, 32, 16, 8, 4],
    answer: 4,
    why:
        'Running down instead of up, and it undershoots for the same reason: '
        'at 8 the condition holds, so it halves once more to 4 and only then '
        'gives up.',
    source: 'math-prg-q3',
  ),
  WhileRound(
    start: 'x = 0',
    condition: 'x < 20',
    step: 'x = x + 6',
    run: [0, 6, 12, 18, 24],
    answer: 24,
    why:
        'Adding rather than multiplying changes nothing about the rule. '
        'Eighteen passes the test, so six more go on, and 24 is what is left '
        'when the loop stops.',
    source: 'math-prg-q3',
  ),
  WhileRound(
    start: 'x = 2',
    condition: 'x <= 40',
    step: 'x = x * 2',
    run: [2, 4, 8, 16, 32, 64],
    answer: 64,
    why:
        'This condition allows the limit itself, but 32 is the last value '
        'under it either way and doubling takes you to 64. An "or equal to" '
        'changes which values pass, never what is left at the end.',
    source: 'math-prg-q3',
  ),
  WhileRound(
    start: 'x = 5',
    condition: 'x < 5',
    step: 'x = x * 2',
    run: [5],
    answer: 5,
    why:
        'The condition is checked BEFORE the body, and it fails on the very '
        'first look, so the body never runs once. The variable is left '
        'exactly as it started. A loop is allowed to do nothing.',
    source: 'math-prg-q3',
  ),
];

class _WhereItStopsGameState extends State<WhereItStopsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'where-it-stops',
    chapterId: 'mathematics',
    total: whileRounds.length,
    sourceProblemIdOf: (round) => whileRounds[round].source,
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

  WhileRound get _round => whileRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Where It Stops',
        closing:
            'The condition is checked before the body, so the value left in '
            'the variable is the one that broke it. Nothing is capped at the '
            'limit, and a loop whose condition fails at the first look never '
            'runs at all.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: iterationBrief,
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
            'THE VALUE THAT BREAKS IT',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the value left in the variable when the loop stops.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.charcoal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.start,
                  style: AppTheme.code(size: 13.5, color: AppColors.cream),
                ),
                Text(
                  'WHILE ${r.condition}',
                  style: AppTheme.code(size: 13.5, color: AppColors.cream),
                ),
                Text(
                  '    ${r.step}',
                  style: AppTheme.code(size: 13.5, color: AppColors.cream),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'EVERY VALUE IT TAKES',
            style: AppTheme.overline(color: AppColors.ink2),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in r.run)
                _RunChip(
                  key: ValueKey('run-$value'),
                  label: '$value',
                  selected: _picked == value,
                  locked: answered,
                  isTruth: value == r.answer,
                  onTap: answered
                      ? null
                      : () => setState(() => _picked = value),
                ),
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHAT IS LEFT' : 'NOT THAT',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _RunChip extends StatelessWidget {
  const _RunChip({
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
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          // No `alignment` here: a Container that is asked to align its child
          // grows to fill whatever it is given, and inside a Wrap that means
          // one chip per line instead of a strip.
          constraints: const BoxConstraints(minWidth: 62),
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: AppTheme.mono(size: 15, color: AppColors.charcoal),
            ),
          ),
        ),
      ),
    );
  }
}
