import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'liability_row.dart';

/// Which Way It Pushes — the first item for `pw-fw-aw-analysis`.
///
/// The lesson's medium problem names one trap and it is a sign: salvage
/// REDUCES the annual cost of owning something and gets added instead. Every
/// item in a cash flow pushes the annual cost one way or the other, and
/// getting the direction wrong is worth more marks than getting the factor
/// wrong, because it looks right all the way to the end.
///
/// One answer is neither. Money already spent before the decision was made
/// does not belong in the comparison at all, and a student who has never been
/// asked about a sunk cost will happily put it in.
class WhichWayItPushesGame extends StatefulWidget {
  const WhichWayItPushesGame({super.key});

  @override
  State<WhichWayItPushesGame> createState() => _WhichWayItPushesGameState();
}

enum Push { up, down, neither }

@immutable
class PushRound {
  const PushRound({
    required this.subject,
    required this.item,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// The line of the cash flow being judged.
  final String item;
  final Push answer;
  final String why;
  final String source;
}

const pushRounds = <PushRound>[
  PushRound(
    subject: 'the price of the machine',
    item:
        'An excavator is bought for 280,000 dollars today, and the firm is '
        'working out what it costs them a year to own it.',
    answer: Push.up,
    why:
        'The purchase is spread across the life by capital recovery, and it is '
        'usually the largest single piece of the annual cost. Dividing it by '
        'the number of years instead is the shortcut that ignores interest.',
    source: 'econ-pfa-q2',
  ),
  PushRound(
    subject: 'what it sells for at the end',
    item:
        'The same excavator is expected to sell for 50,000 dollars at the end '
        'of its tenth year.',
    answer: Push.down,
    why:
        'Money coming back reduces what the machine costs you. It is the trap '
        'the lesson names by name, because the salvage sits at the end of the '
        'problem next to a row of costs and gets added to them.',
    source: 'econ-pfa-q2',
  ),
  PushRound(
    subject: 'a study already paid for',
    item:
        'The firm spent 15,000 dollars last year on a feasibility study, '
        'whichever machine they end up choosing.',
    answer: Push.neither,
    why:
        'Already spent, and spent the same way whatever is decided now. A sunk '
        'cost belongs in the accounts and not in the comparison, and putting '
        'it into both alternatives changes neither of them.',
    source: 'econ-pfa-q1',
  ),
  PushRound(
    subject: 'fuel and operators',
    item: 'The machine costs 40,000 dollars a year to run and crew.',
    answer: Push.up,
    why:
        'An annual cost is already annual and goes straight in, which is the '
        'one line of these problems that needs no factor at all.',
    source: 'econ-pfa-q2',
  ),
  PushRound(
    subject: 'a grant against the purchase',
    item:
        'A state grant pays 30,000 dollars towards the purchase, received on '
        'the day the machine is bought.',
    answer: Push.down,
    why:
        'It arrives at time zero and points the other way, so it reduces the '
        'amount capital recovery is applied to. Money in and money out sit on '
        'the same diagram; only the direction of the arrow differs.',
    source: 'econ-pfa-q2',
  ),
  PushRound(
    subject: 'a rebuild halfway through',
    item:
        'The machine needs a major rebuild at the end of year five, on top of '
        'the usual running costs.',
    answer: Push.up,
    why:
        'A single amount partway through, brought back and then spread like '
        'everything else. It is a cost, it lands inside the life, and nothing '
        'about being a one-off keeps it out of the annual figure.',
    source: 'econ-pfa-q2',
  ),
];

class _WhichWayItPushesGameState extends State<WhichWayItPushesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-way-it-pushes',
    chapterId: 'economics',
    total: pushRounds.length,
    sourceProblemIdOf: (round) => pushRounds[round].source,
  )..addListener(_onSession);

  Push? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  PushRound get _round => pushRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Way It Pushes',
        closing:
            'Costs push the annual figure up and money coming back pushes it '
            'down, salvage included. And anything already spent, whichever way '
            'the decision goes, does not belong in the comparison at all.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: annualCostBrief,
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
            'WHICH WAY DOES THE ANNUAL COST MOVE',
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
                fontSize: 15.5,
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
          for (final p in Push.values) ...[
            if (p != Push.values.first) const SizedBox(height: 8),
            LiabilityRow(
              key: ValueKey('push-${p.name}'),
              title: switch (p) {
                Push.up => 'Up',
                Push.down => 'Down',
                Push.neither => 'Neither. It stays out.',
              },
              note: switch (p) {
                Push.up => 'a cost inside the life',
                Push.down => 'money coming back',
                Push.neither => 'already spent, whatever is decided',
              },
              selected: _picked == p,
              locked: answered,
              isTruth: p == r.answer,
              onTap: answered ? null : () => setState(() => _picked = p),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT WAY' : 'THE OTHER WAY',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
