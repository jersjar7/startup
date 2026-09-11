import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// What Happens to the Loss — the second item for `pipe-flow-head-loss`.
///
/// Darcy-Weisbach is four things multiplied together and the arithmetic is a
/// desk job. What is worth knowing by heart is which of them bites: the
/// velocity is SQUARED, so it dominates everything, and the diameter is
/// underneath twice over once continuity is allowed to have its say. Every
/// round changes one thing about a pipe and asks what the friction loss does.
class WhatHappensToTheLossGame extends StatefulWidget {
  const WhatHappensToTheLossGame({super.key});

  @override
  State<WhatHappensToTheLossGame> createState() =>
      _WhatHappensToTheLossGameState();
}

/// What the head loss gets multiplied by.
enum Loss { quarter, half, same, twice, four, thirtyTwo }

extension LossWords on Loss {
  String get plain => switch (this) {
        Loss.quarter => 'a quarter of the loss',
        Loss.half => 'half the loss',
        Loss.same => 'the same loss',
        Loss.twice => 'twice the loss',
        Loss.four => 'four times the loss',
        Loss.thirtyTwo => 'about thirty times the loss',
      };
}

@immutable
class LossRound {
  const LossRound({
    required this.subject,
    required this.change,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String change;
  final List<Loss> options;
  final Loss answer;
  final String why;
  final String source;
}

const lossRounds = <LossRound>[
  LossRound(
    subject: 'twice the speed',
    change:
        'The same pipe, with the pump turned up so the water runs twice as '
        'fast.',
    options: [Loss.twice, Loss.four, Loss.half, Loss.same],
    answer: Loss.four,
    why:
        'Four times, because the velocity is SQUARED. This is the term that '
        'dominates every head loss calculation, and it is why pipes are sized '
        'by velocity: pushing more through the same pipe costs far more '
        'pressure than the extra flow suggests.',
    source: 'fm-pfh-q2',
  ),
  LossRound(
    subject: 'twice the length',
    change:
        'The same pipe and the same flow, run out to twice the distance.',
    options: [Loss.four, Loss.twice, Loss.same, Loss.half],
    answer: Loss.twice,
    why:
        'Twice, in direct proportion: the friction is collected foot by foot '
        'all along the pipe. Length is the one term in Darcy-Weisbach that '
        'behaves exactly as you would guess, which is worth noticing, because '
        'none of the others do.',
    source: 'fm-pfh-q2',
  ),
  LossRound(
    subject: 'twice the bore, same speed',
    change:
        'The pipe is doubled in diameter, and the water still runs at the '
        'same speed through it.',
    options: [Loss.same, Loss.twice, Loss.half, Loss.four],
    answer: Loss.half,
    why:
        'Half. The diameter sits underneath the L over D, so doubling it '
        'halves the loss when the speed is held the same. Note the condition '
        'carefully: this is the same SPEED, not the same flow, and the next '
        'round is what happens when it is the flow that is held.',
    source: 'fm-pfh-q2',
  ),
  LossRound(
    subject: 'twice the bore, same flow',
    change:
        'The same pipe doubled in diameter again, but now the same number of '
        'liters a second goes through it.',
    options: [Loss.half, Loss.quarter, Loss.thirtyTwo, Loss.same],
    answer: Loss.thirtyTwo,
    why:
        'About a thirtieth, which is the answer that matters on a real job. '
        'Doubling the bore cuts the velocity to a quarter by continuity, and '
        'the velocity is squared, so that is a sixteenth. The extra diameter '
        'underneath halves it once more, for a thirty-second. Going up one '
        'pipe size is the cheapest head you will ever buy.',
    source: 'fm-pfh-q2',
  ),
  LossRound(
    subject: 'a rougher pipe',
    change:
        'An old pipe of the same size and flow has a friction factor twice as '
        'large.',
    options: [Loss.four, Loss.same, Loss.twice, Loss.quarter],
    answer: Loss.twice,
    why:
        'Twice, in direct proportion again. The friction factor multiplies '
        'everything else, so roughness costs exactly what it says it does. '
        'That is why an old tuberculated main can halve the delivery of a '
        'system that was sized correctly when it was new.',
    source: 'fm-pfh-q2',
  ),
  LossRound(
    subject: 'a valve, and nothing else',
    change:
        'The same pipe, same flow, with one more elbow fitted into it. The '
        'pipe itself has not changed.',
    options: [Loss.same, Loss.twice, Loss.four, Loss.half],
    answer: Loss.same,
    why:
        'The FRICTION loss does not change at all: the pipe, the flow and the '
        'length are what they were. What the elbow adds is a minor loss, its '
        'own coefficient times the velocity head, on top. Keeping the two '
        'apart is the whole of the next item, and adding them is the last '
        'problem in this lesson.',
    source: 'fm-pfh-q3',
  ),
];

class _WhatHappensToTheLossGameState extends State<WhatHappensToTheLossGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-happens-to-the-loss',
    chapterId: 'fluid-mechanics',
    total: lossRounds.length,
    sourceProblemIdOf: (round) => lossRounds[round].source,
  )..addListener(_onSession);

  Loss? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  LossRound get _round => lossRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Happens to the Loss',
        closing:
            'The velocity is squared, so it dominates: twice the speed is '
            'four times the loss. Length and the friction factor are in '
            'direct proportion. The diameter halves the loss on its own, and '
            'at a fixed FLOW it does far more than that, because a bigger '
            'pipe is also a slower one: one size up can cut the loss thirty '
            'times over.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: darcyBrief,
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
            'WHAT HAPPENS TO THE FRICTION LOSS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.change,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: MathText(
              r'$h_f = f \dfrac{L}{D} \dfrac{v^2}{2g}$',
              style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 16),
          for (final option in r.options) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE FACTOR' : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
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
    if (locked && isTruth) {
      border = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
    } else {
      border = AppColors.line;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
