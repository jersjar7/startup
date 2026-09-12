import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'demand_figures.dart';
import 'lesson_brief.dart';

/// Which Step Is That — the first item for `travel-demand`.
///
/// Four steps, run in order, each answering a different question: how many
/// trips, where they go, how they travel, and which route they take. The
/// gravity model belongs to exactly one of them.
class WhichStepIsThatGame extends StatefulWidget {
  const WhichStepIsThatGame({super.key});

  @override
  State<WhichStepIsThatGame> createState() => _WhichStepIsThatGameState();
}

@immutable
class ForecastStepRound {
  const ForecastStepRound({
    required this.subject,
    required this.asked,
    required this.highlight,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;

  /// The step the figure picks out, which is also the answer.
  final Forecast highlight;
  final Forecast answer;
  final String why;
  final String source;

  static String label(Forecast step) => switch (step) {
        Forecast.generation => 'Trip generation, the first step',
        Forecast.distribution => 'Trip distribution, the second',
        Forecast.mode => 'Mode choice, the third',
        Forecast.assignment => 'Traffic assignment, the fourth',
      };
}

const forecastStepRounds = <ForecastStepRound>[
  ForecastStepRound(
    subject: 'where the gravity model lives',
    asked: 'Which of the four steps uses the gravity model?',
    highlight: Forecast.distribution,
    answer: Forecast.distribution,
    why:
        'Distribution, the second step. The gravity model takes the trips a '
        'zone produces and shares them out among the places they could go. '
        'It says nothing about how many trips there are, which is step one, '
        'nor about how people travel or which road they use.',
    source: 'trans-td-q2',
  ),
  ForecastStepRound(
    subject: 'how many trips there are at all',
    asked:
        'A planner works out how many trips a new shopping center will '
        'attract from its floor area. Which step is that?',
    highlight: Forecast.generation,
    answer: Forecast.generation,
    why:
        'Generation, the first step, which counts trips produced and trips '
        'attracted from land use. It is a question about quantity only: '
        'where those trips come from and go to is the next step\'s problem.',
    source: 'trans-td-q2',
  ),
  ForecastStepRound(
    subject: 'car, bus or on foot',
    asked:
        'Now the model decides what fraction of those trips will be made by '
        'transit. Which step?',
    highlight: Forecast.mode,
    answer: Forecast.mode,
    why:
        'Mode choice, the third step. By this point the model knows how many '
        'trips there are and where each one is going, and it splits them '
        'among the ways of getting there. Change the fares or the parking '
        'price and this is the step that moves.',
    source: 'trans-td-q2',
  ),
  ForecastStepRound(
    subject: 'which road they actually use',
    asked:
        'Finally the trips are loaded onto the street network to see which '
        'roads fill up. Which step?',
    highlight: Forecast.assignment,
    answer: Forecast.assignment,
    why:
        'Assignment, the last step, and the one that produces the volumes a '
        'designer uses. It is also where congestion feeds back: a route that '
        'fills up pushes traffic onto another, which is why assignment is '
        'usually iterated rather than done once.',
    source: 'trans-td-q2',
  ),
  ForecastStepRound(
    subject: 'the same trips, somewhere else',
    asked:
        'A large employer moves from one zone to another. The same number of '
        'trips is made, but they now end up somewhere else. Which step '
        'notices?',
    highlight: Forecast.distribution,
    answer: Forecast.distribution,
    why:
        'Distribution. Generation produced the same count either way, since '
        'the households making the trips have not changed. What moved is '
        'where the attractions are, and that is the term the gravity model '
        'weighs.',
    source: 'trans-td-q2',
  ),
  ForecastStepRound(
    subject: 'why the order matters',
    asked:
        'Which step has to be finished before distribution has anything to '
        'share out?',
    highlight: Forecast.generation,
    answer: Forecast.generation,
    why:
        'Generation. Distribution shares out a number that generation must '
        'produce first, and each step in turn consumes what the one before '
        'it made. That is why the four are always named in the same '
        'sequence and never run out of order.',
    source: 'trans-td-q2',
  ),
];

class _WhichStepIsThatGameState extends State<WhichStepIsThatGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-step-is-that',
    chapterId: 'transportation',
    total: forecastStepRounds.length,
    sourceProblemIdOf: (round) => forecastStepRounds[round].source,
  );

  Forecast? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  ForecastStepRound get _round => forecastStepRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Step Is That',
        closing:
            'Generation counts the trips. Distribution decides where they go, '
            'and that is where the gravity model works. Mode choice picks how '
            'they travel. Assignment puts them on particular roads. Each step '
            'consumes what the one before it made, which is why the order '
            'never changes.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: fourStepBrief,
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
            'THE FOUR STEPS',
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
            height: 190,
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
                  painter: StepsPainter(
                    highlight: answered ? r.highlight : null,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Forecast.values) ...[
            _Choice(
              label: ForecastStepRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Forecast.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS IT' : 'NOT THAT ONE',
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
