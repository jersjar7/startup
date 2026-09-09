import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'liability_row.dart';

/// Where Does It Go — the first item for `benefit-cost-decision-trees`.
///
/// A benefit-cost ratio is one division and three places a number can land.
/// Both of the lesson's named traps are placement rather than arithmetic: the
/// annual operating cost belongs in the DENOMINATOR because it is money the
/// government spends, and a disbenefit comes off the numerator rather than
/// being added to the costs.
///
/// That distinction matters because the two are not the same division. Ten
/// thousand of harm to the public taken off the benefits gives a different
/// ratio from ten thousand added to the costs, and only one of them is right.
class WhereDoesItGoGame extends StatefulWidget {
  const WhereDoesItGoGame({super.key});

  @override
  State<WhereDoesItGoGame> createState() => _WhereDoesItGoGameState();
}

enum Slot { benefit, disbenefit, cost }

@immutable
class SlotRound {
  const SlotRound({
    required this.subject,
    required this.item,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String item;
  final Slot answer;
  final String why;
  final String source;
}

const slotRounds = <SlotRound>[
  SlotRound(
    subject: 'building the thing',
    item:
        'Four and a half million dollars to construct a flood control scheme, '
        'paid by the agency.',
    answer: Slot.cost,
    why:
        'Money the government spends, which is the denominator. It is the '
        'obvious one and it is worth doing first, because the next one looks '
        'different and is not.',
    source: 'econ-bcd-q1',
  ),
  SlotRound(
    subject: 'keeping it running',
    item:
        'Sixty thousand dollars a year to operate and maintain the same '
        'scheme, also paid by the agency.',
    answer: Slot.cost,
    why:
        'Still the government spending money, so still the denominator. This '
        'is the trap the lesson names: leaving the annual cost out entirely, '
        'because the construction figure feels like the cost of the project.',
    source: 'econ-bcd-q1',
  ),
  SlotRound(
    subject: 'damage that never happens',
    item:
        'Four hundred and twenty thousand dollars a year of flood damage to '
        'homes and businesses that the scheme prevents.',
    answer: Slot.benefit,
    why:
        'Value to the public, so the numerator. Nobody writes a check for '
        'damage that did not happen, and it is the whole reason the project is '
        'being considered.',
    source: 'econ-bcd-q1',
  ),
  SlotRound(
    subject: 'noise the neighbors did not ask for',
    item:
        'Residents along the new alignment will live with materially more '
        'traffic noise once it opens.',
    answer: Slot.disbenefit,
    why:
        'Harm to the public, so it comes OFF the numerator rather than being '
        'added to the government\'s costs. Those are different divisions and '
        'they give different ratios; only one of them is the one asked for.',
    source: 'econ-bcd-q1',
  ),
  SlotRound(
    subject: 'time nobody spends queueing',
    item:
        'Commuters will collectively save an estimated 180,000 dollars a year '
        'in travel time once the corridor is widened.',
    answer: Slot.benefit,
    why:
        'Value to the public again, and the largest single benefit on most '
        'road schemes. It never appears in anybody\'s accounts, which is '
        'precisely why public projects are judged this way and not on revenue.',
    source: 'econ-bcd-q2',
  ),
  SlotRound(
    subject: 'people who have to move',
    item:
        'Fourteen households will be displaced by the alignment and rehoused '
        'elsewhere in the county.',
    answer: Slot.disbenefit,
    why:
        'The rehousing bill is a cost to the agency, and the displacement '
        'itself is harm done to the public and belongs off the benefits. Two '
        'different numbers out of one sentence, and they go in two different '
        'places.',
    source: 'econ-bcd-q1',
  ),
];

class _WhereDoesItGoGameState extends State<WhereDoesItGoGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'where-does-it-go',
    chapterId: 'economics',
    total: slotRounds.length,
    sourceProblemIdOf: (round) => slotRounds[round].source,
  )..addListener(_onSession);

  Slot? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SlotRound get _round => slotRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Where Does It Go',
        closing:
            'Benefits and disbenefits are what happens to the public and live '
            'on top; costs are what the agency spends and live underneath, '
            'operating costs included. A disbenefit comes off the benefits '
            'rather than joining the costs, and the two are different '
            'divisions.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: ratioBrief,
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
            'WHERE IN THE RATIO',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.creamDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              r.item,
              style: const TextStyle(
                fontSize: 15,
                height: 1.45,
                color: AppColors.charcoal,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 16),
          for (final slot in Slot.values) ...[
            if (slot != Slot.values.first) const SizedBox(height: 8),
            LiabilityRow(
              key: ValueKey('slot-${slot.name}'),
              title: switch (slot) {
                Slot.benefit => 'A benefit, on top',
                Slot.disbenefit => 'A disbenefit, taken off the top',
                Slot.cost => 'A cost, underneath',
              },
              note: switch (slot) {
                Slot.benefit => 'value to the public',
                Slot.disbenefit => 'harm to the public',
                Slot.cost => 'money the agency spends',
              },
              selected: _picked == slot,
              locked: answered,
              isTruth: slot == r.answer,
              onTap: answered ? null : () => setState(() => _picked = slot),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHERE' : 'SOMEWHERE ELSE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
