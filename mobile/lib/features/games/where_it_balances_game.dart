import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'expectation_figures.dart';
import 'lesson_brief.dart';

/// Where It Balances — the first item for `expected-value-weighted-averages`.
///
/// The lesson's easy problem names two traps and both of them are answers to a
/// different question: the most likely outcome, and the plain average of the
/// outcomes with the probabilities thrown away. Multiplying three numbers by
/// three probabilities is not what goes wrong. Knowing what the answer IS is.
///
/// An expected value is a balance point, so the outcomes are loaded onto a
/// beam with their probabilities as weights and the question is which fulcrum
/// holds it level. Get it wrong and the beam tips, in the direction the
/// arithmetic would have gone.
class WhereItBalancesGame extends StatefulWidget {
  const WhereItBalancesGame({super.key});

  @override
  State<WhereItBalancesGame> createState() => _WhereItBalancesGameState();
}

@immutable
class BalanceRound {
  const BalanceRound({
    required this.subject,
    required this.unit,
    required this.outcomes,
    required this.fulcrums,
    required this.to,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What one step along the beam is called.
  final String unit;
  final List<Outcome> outcomes;

  /// Three candidates, left to right, lettered A B C on the picture.
  final List<double> fulcrums;
  final double to;
  final int answer;
  final String why;
  final String source;
}

const balanceRounds = <BalanceRound>[
  BalanceRound(
    subject: 'trucks arriving per minute at a toll plaza',
    unit: 'trucks',
    outcomes: [Outcome(2, 10), Outcome(6, 20), Outcome(10, 70)],
    fulcrums: [6, 8.4, 10],
    to: 12,
    answer: 1,
    why:
        'Most of the weight is out at ten, so the balance point sits well to '
        'the right of the middle. It does not reach ten, though: the lighter '
        'blocks on the left still pull, and every one of them counts.',
    source: 'stat-ev-q1',
  ),
  BalanceRound(
    subject: 'lanes closed during a night shift',
    unit: 'lanes',
    outcomes: [Outcome(1, 45), Outcome(5, 50), Outcome(9, 5)],
    fulcrums: [3.4, 5, 9],
    to: 11,
    answer: 0,
    why:
        'Five is the most likely single outcome and it is not the balance '
        'point. Nearly as much weight sits at one, and the pair of them '
        'together pull the fulcrum well to the left of the tallest block.',
    source: 'stat-ev-q1',
  ),
  BalanceRound(
    subject: 'days of delay on a utility relocation',
    unit: 'days',
    outcomes: [Outcome(2, 60), Outcome(6, 20), Outcome(10, 20)],
    fulcrums: [2, 4.4, 6],
    to: 12,
    answer: 1,
    why:
        'Six is the plain average of two, six and ten, which is the answer you '
        'get by ignoring the probabilities entirely. Sixty percent of the '
        'weight is down at two, and the beam knows it.',
    source: 'stat-ev-q1',
  ),
  BalanceRound(
    subject: 'a coin-flip choice between two repair strategies',
    unit: 'units',
    outcomes: [Outcome(1, 50), Outcome(9, 50)],
    fulcrums: [1, 5, 9],
    to: 11,
    answer: 1,
    why:
        'Two equal weights balance halfway between them, and there is no block '
        'at five at all. An expected value is a long-run average, and it is '
        'under no obligation to be an outcome that can happen.',
    source: 'stat-ev-q1',
  ),
  BalanceRound(
    subject: 'cylinders below strength in a day of testing',
    unit: 'cylinders',
    outcomes: [Outcome(2, 20), Outcome(6, 60), Outcome(10, 20)],
    fulcrums: [2, 4, 6],
    to: 12,
    answer: 2,
    why:
        'Here the tallest block IS the balance point, because the picture is '
        'symmetric about it. That is exactly why reaching for the most likely '
        'outcome works often enough to feel like a rule.',
    source: 'stat-ev-q1',
  ),
  BalanceRound(
    subject: 'claims filed against a contract, in hundreds of thousands',
    unit: 'claims',
    outcomes: [Outcome(1, 70), Outcome(3, 20), Outcome(11, 10)],
    fulcrums: [2.4, 5, 11],
    to: 13,
    answer: 0,
    why:
        'One rare, distant outcome drags the balance point off the crowd, but '
        'only as far as its weight can carry it. Ten percent out at eleven '
        'moves the fulcrum a little; it does not move it to the middle.',
    source: 'stat-ev-q1',
  ),
];

class _WhereItBalancesGameState extends State<WhereItBalancesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'where-it-balances',
    chapterId: 'statistics',
    total: balanceRounds.length,
    sourceProblemIdOf: (round) => balanceRounds[round].source,
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

  BalanceRound get _round => balanceRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Where It Balances',
        closing:
            'An expected value is the balance point of the whole picture. It '
            'is not the most likely outcome, it is not the middle of the '
            'range, and it does not have to be a value that can actually '
            'happen.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: expectedValueBrief,
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
            'WHICH FULCRUM HOLDS IT LEVEL',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Each block is an outcome, and its height is how likely it is.',
            style: TextStyle(
              fontSize: 15.5,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 250,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: BeamPainter(
                    outcomes: r.outcomes,
                    fulcrums: r.fulcrums,
                    from: 0,
                    to: r.to,
                    unit: r.unit,
                    picked: _picked,
                    truth: answered ? r.answer : null,
                    revealed: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < r.fulcrums.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _FulcrumButton(
                    key: ValueKey('fulcrum-$i'),
                    label: String.fromCharCode(65 + i),
                    selected: _picked == i,
                    locked: answered,
                    isTruth: i == r.answer,
                    onTap: answered
                        ? null
                        : () => setState(() => _picked = i),
                  ),
                ),
              ],
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'IT SITS LEVEL' : 'IT TIPS',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _FulcrumButton extends StatelessWidget {
  const _FulcrumButton({
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
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(label, style: AppTheme.heading(size: 17)),
        ),
      ),
    );
  }
}
