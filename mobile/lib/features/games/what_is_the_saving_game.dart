import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'liability_row.dart';

/// What Is the Saving — the third item for `cost-types-breakeven`.
///
/// The lesson's hard problem is a payback period and its named trap is one
/// subtraction. A toll system saves 280,000 dollars of labor a year and costs
/// 80,000 to maintain, and the number that pays the investment back is the
/// 200,000 left over. Using the gross saving gives five years instead of
/// seven, which is a different decision at most thresholds.
///
/// So nothing is divided here. Every number in the problem is on screen and
/// the question is which one goes on the bottom of the fraction.
class WhatIsTheSavingGame extends StatefulWidget {
  const WhatIsTheSavingGame({super.key});

  @override
  State<WhatIsTheSavingGame> createState() => _WhatIsTheSavingGameState();
}

@immutable
class SavingRound {
  const SavingRound({
    required this.subject,
    required this.scenario,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String scenario;

  /// Four numbers from the problem, each named for what it is.
  final List<(String, String)> options;
  final int answer;
  final String why;
  final String source;
}

const savingRounds = <SavingRound>[
  SavingRound(
    subject: 'an automated toll system',
    scenario:
        'A 1.4 million dollar system removes six collector posts, saving '
        '280,000 dollars a year in labor, and costs 80,000 a year to '
        'maintain. Which number goes underneath, to pay the 1.4 million back?',
    options: [
      ('280,000', 'the labor saved'),
      ('200,000', 'the labor saved, less the maintenance'),
      ('80,000', 'the new annual cost'),
      ('360,000', 'the labor saved plus the maintenance'),
    ],
    answer: 1,
    why:
        'Only what is left over pays anything back. Two hundred thousand a '
        'year gives seven years and the gross figure gives five, and five and '
        'seven fall on opposite sides of most thresholds anybody sets.',
    source: 'econ-ctb-q3',
  ),
  SavingRound(
    subject: 'a variable frequency drive',
    scenario:
        'A 90,000 dollar drive cuts the power bill by 26,000 dollars a year '
        'and adds 4,000 a year of servicing. Which number pays the 90,000 '
        'back?',
    options: [
      ('30,000', 'the power saved plus the servicing'),
      ('4,000', 'the new annual cost'),
      ('22,000', 'the power saved, less the servicing'),
      ('26,000', 'the power saved'),
    ],
    answer: 2,
    why:
        'The servicing is a real annual cost and it comes off the saving '
        'before anything is paid back. Adding it to the saving is the version '
        'that shows up when somebody subtracts the wrong way round.',
    source: 'econ-ctb-q3',
  ),
  SavingRound(
    subject: 'a plant with nothing to service',
    scenario:
        'A 60,000 dollar culvert liner avoids 15,000 dollars a year of '
        'emergency repairs and needs no maintenance of its own. Which number '
        'pays the 60,000 back?',
    options: [
      ('15,000', 'the repairs avoided'),
      ('60,000', 'the price of the liner'),
      ('75,000', 'the price plus the repairs avoided'),
      ('45,000', 'the price less the repairs avoided'),
    ],
    answer: 0,
    why:
        'No new annual cost, so the net saving is the gross one. It is worth '
        'meeting: the subtraction is not a ritual, it is there because there '
        'is usually something to subtract.',
    source: 'econ-ctb-q3',
  ),
  SavingRound(
    subject: 'a scheme that costs more to run',
    scenario:
        'A 250,000 dollar treatment upgrade saves 40,000 dollars a year in '
        'chemicals and adds 52,000 a year in power. Which number pays the '
        '250,000 back?',
    options: [
      ('40,000', 'the chemicals saved'),
      ('92,000', 'the chemicals saved plus the power'),
      ('52,000', 'the new annual cost'),
      ('Nothing does', 'the new cost is larger than the saving'),
    ],
    answer: 3,
    why:
        'The saving is negative, so there is no payback period at all and the '
        'upgrade never pays for itself on these numbers. A formula will still '
        'hand back a figure if you let it, and the figure will be nonsense.',
    source: 'econ-ctb-q3',
  ),
  SavingRound(
    subject: 'a saving with two parts',
    scenario:
        'A 180,000 dollar system saves 30,000 dollars a year in labor and '
        '12,000 in materials, and costs 9,000 a year to support. Which number '
        'pays the 180,000 back?',
    options: [
      ('42,000', 'both savings, before support'),
      ('30,000', 'the labor saved'),
      ('33,000', 'both savings, less the support'),
      ('51,000', 'both savings plus the support'),
    ],
    answer: 2,
    why:
        'Add up everything coming in, take off everything new going out, and '
        'what is left is the payback. Stopping at the labor saving forgets '
        'half the benefit, and stopping at forty two thousand forgets the '
        'cost.',
    source: 'econ-ctb-q3',
  ),
  SavingRound(
    subject: 'a saving that arrives once',
    scenario:
        'A 120,000 dollar rebuild saves 25,000 dollars a year in maintenance, '
        'adds 5,000 a year of inspection, and earns a one-off 15,000 dollar '
        'grant on completion. Which number pays back the balance?',
    options: [
      ('40,000', 'the maintenance saved plus the grant'),
      ('20,000', 'the maintenance saved, less the inspection'),
      ('25,000', 'the maintenance saved'),
      ('35,000', 'everything coming in, less the inspection'),
    ],
    answer: 1,
    why:
        'The grant is a one-off and belongs against the 120,000 rather than in '
        'the annual figure. Only what repeats every year can pay something '
        'back every year, and mixing the two makes the payback look faster '
        'than it is.',
    source: 'econ-ctb-q3',
  ),
];

class _WhatIsTheSavingGameState extends State<WhatIsTheSavingGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-is-the-saving',
    chapterId: 'economics',
    total: savingRounds.length,
    sourceProblemIdOf: (round) => savingRounds[round].source,
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

  SavingRound get _round => savingRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Is the Saving',
        closing:
            'Everything coming in, less everything new going out, and only the '
            'part that repeats every year. If the new cost is bigger than the '
            'saving there is no payback period, whatever a formula hands back.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: paybackBrief,
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
            'WHAT GOES UNDERNEATH',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.scenario,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < r.options.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            LiabilityRow(
              key: ValueKey('saving-$i'),
              title: r.options[i].$1,
              note: r.options[i].$2,
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT ONE' : 'A DIFFERENT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
