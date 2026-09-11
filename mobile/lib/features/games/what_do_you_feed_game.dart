import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'chlorine_figures.dart';

/// What Do You Feed — the first item for `drinking-water-treatment`.
///
/// Three numbers, one equation, and the lesson names the confusion between
/// two of them as its trap. The DEMAND is what the water consumes before
/// anything is left. The RESIDUAL is what has to survive to the far end of
/// the distribution system. The DOSE is what goes in the pipe, and it is the
/// sum of the other two, never either one on its own.
class WhatDoYouFeedGame extends StatefulWidget {
  const WhatDoYouFeedGame({super.key});

  @override
  State<WhatDoYouFeedGame> createState() => _WhatDoYouFeedGameState();
}

/// Which of the three numbers is being described.
enum Portion { demand, residual, dose }

extension PortionWords on Portion {
  String get plain => switch (this) {
        Portion.demand => 'The demand: what the water consumes',
        Portion.residual => 'The residual: what is left afterward',
        Portion.dose => 'The dose: what goes into the pipe',
      };

  String get key => switch (this) {
        Portion.demand => 'demand',
        Portion.residual => 'residual',
        Portion.dose => 'dose',
      };
}

@immutable
class FeedRound {
  const FeedRound({
    required this.subject,
    required this.asked,
    required this.answer,
    required this.chlorine,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Portion answer;
  final Chlorine chlorine;
  final String why;
  final String source;
}

const feedRounds = <FeedRound>[
  FeedRound(
    subject: 'the lesson\'s own plant',
    asked:
        'The water exerts 2.4 mg/L and the plant must keep 0.6 mg/L at the '
        'far end. The operator sets the feed pump to 3.0 mg/L. What is that '
        '3.0?',
    answer: Portion.dose,
    chlorine: Chlorine(demand: 2.4, residual: 0.6),
    why:
        'The dose: the demand plus the residual, and the number the feed pump '
        'is set to. It is also the number that goes into the mass balance, so '
        'at 4,000 cubic meters a day the plant buys 12 kilograms of chlorine a '
        'day rather than the 9.6 the demand alone would suggest. Feeding only '
        'the demand leaves nothing in the system at all.',
    source: 'wr-dwt-q2',
  ),
  FeedRound(
    subject: 'what the water takes first',
    asked:
        'Organic matter, ammonia and iron in the raw water consume chlorine '
        'before any is left over. What is the amount they consume called?',
    answer: Portion.demand,
    chlorine: Chlorine(demand: 2.4, residual: 0.6),
    why:
        'The demand. It is a property of the WATER rather than of the plant: '
        'a dirty raw water has a high demand and a clean one has a low one, '
        'and it has to be satisfied in full before a single milligram is left '
        'to disinfect with. It is the bottom of the column and nothing is '
        'above it until it is filled.',
    source: 'wr-dwt-q2',
  ),
  FeedRound(
    subject: 'a sample from a customer\'s tap',
    asked:
        'An inspector samples at a house at the end of the main and measures '
        '0.4 mg/L of free chlorine. Which of the three is that?',
    answer: Portion.residual,
    chlorine: Chlorine(demand: 2.4, residual: 0.4),
    why:
        'The residual, which is the only one of the three you can measure '
        'out in the system. It is what the regulation is written on, because '
        'it is the evidence that the water is still protected all the way to '
        'the tap. The dose was set at the works and the demand was consumed '
        'somewhere in between.',
    source: 'wr-dwt-q2',
  ),
  FeedRound(
    subject: 'a spring runoff',
    asked:
        'Snowmelt brings organic matter down the river and the same feed '
        'setting now leaves nothing at the far end. Which of the three went '
        'up?',
    answer: Portion.demand,
    chlorine: Chlorine(demand: 3.4, residual: 0.6),
    why:
        'The demand. The water is dirtier, so it eats more before anything '
        'is left, and a feed rate that was adequate last week is not now. The '
        'operator\'s answer is to raise the DOSE by the same amount the '
        'demand rose, which keeps the residual where it was.',
    source: 'wr-dwt-q2',
  ),
  FeedRound(
    subject: 'buying chlorine',
    asked:
        'The plant works out how many kilograms a day to order. Which of the '
        'three does it multiply by the flow?',
    answer: Portion.dose,
    chlorine: Chlorine(demand: 2.4, residual: 0.6),
    why:
        'The dose, because that is what actually gets fed. A milligram a '
        'liter is a gram a cubic meter, so the sum times the flow gives grams '
        'a day directly. Ordering on the demand alone is the same mistake as '
        'feeding it: it under-buys by whatever the residual costs.',
    source: 'wr-dwt-q2',
  ),
  FeedRound(
    subject: 'what the regulation asks for',
    asked:
        'A rule says a detectable free chlorine level must be maintained '
        'throughout the distribution system. Which of the three is it '
        'setting?',
    answer: Portion.residual,
    chlorine: Chlorine(demand: 2.4, residual: 0.2),
    why:
        'The residual. Regulations set what must be LEFT, not what must be '
        'fed, because what must be fed depends on the water and changes from '
        'day to day. The operator works backward from the required residual, '
        'adds the demand the raw water is exerting today, and sets the pump '
        'to the sum.',
    source: 'wr-dwt-q2',
  ),
];

class _WhatDoYouFeedGameState extends State<WhatDoYouFeedGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-do-you-feed',
    chapterId: 'water-resources',
    total: feedRounds.length,
    sourceProblemIdOf: (round) => feedRounds[round].source,
  )..addListener(_onSession);

  Portion? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  FeedRound get _round => feedRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Do You Feed',
        closing:
            'The demand belongs to the water and is consumed first. The '
            'residual is what has to survive to the tap, and it is the only '
            'one anybody can measure out in the system. The dose is what the '
            'pump is set to and it is the sum of the other two. Feed only the '
            'demand and nothing reaches the customer; feed only the residual '
            'and the water eats it before it leaves the works.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: doseBrief,
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
            'WHICH OF THE THREE IS THAT',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.asked,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 214,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: DosePainter(
                    chlorine: r.chlorine,
                    highlight: answered ? r.answer.key : null,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\text{dose} = \text{demand} + \text{residual}$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Portion.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Portion.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'A DIFFERENT ONE',
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
