import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'earned_value_figures.dart';
import 'lesson_brief.dart';

/// What It Will Cost by the End — the only item for `project-forecasting`.
///
/// One index, earned over spent, and two forecasts built on it: what the
/// remaining work will cost at the rate the crew is really going, and what
/// the whole job will come to when that is added to what is already gone.
class WhatItWillCostGame extends StatefulWidget {
  const WhatItWillCostGame({super.key});

  @override
  State<WhatItWillCostGame> createState() => _WhatItWillCostGameState();
}

@immutable
class ForecastRound {
  const ForecastRound({
    required this.subject,
    required this.asked,
    required this.progress,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Progress progress;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own forecast case: a two million job, 600k earned, 750k
/// spent. Earning eighty cents of value for every dollar.
const _overspending = Progress(
  planned: 700000,
  earned: 600000,
  actual: 750000,
  budget: 2000000,
);

/// The same job running exactly to budget.
const _onBudget = Progress(
  planned: 700000,
  earned: 700000,
  actual: 700000,
  budget: 2000000,
);

/// And one doing better than planned.
const _underspending = Progress(
  planned: 700000,
  earned: 700000,
  actual: 560000,
  budget: 2000000,
);

const forecastRounds = <ForecastRound>[
  ForecastRound(
    subject: 'value for a dollar',
    asked:
        'Six hundred thousand of work has been earned for seven hundred and '
        'fifty thousand spent. What is the cost performance index?',
    progress: _overspending,
    options: [
      '1.25, the spending over the earning',
      '0.80: eighty cents of value for every dollar spent',
      '150,000, the difference between them',
      '0.75',
    ],
    answer: 1,
    why:
        'Earned over spent, which is 0.80. Below one means the money is not '
        'buying its worth. Turning the ratio over gives 1.25, which looks '
        'healthy and is the wrong answer the lesson prints: the index that '
        'matters always has the EARNED value on top.',
    source: 'const-pf-q1',
  ),
  ForecastRound(
    subject: 'what an index below one says',
    asked: 'A cost index of 0.80 on a job a third of the way through means:',
    progress: _overspending,
    options: [
      'The job is twenty per cent complete',
      'Every dollar is buying eighty cents of work, so the rest will '
          'probably cost more than budgeted too',
      'The job will finish twenty per cent late',
      'Nothing until the job is finished',
    ],
    answer: 1,
    why:
        'It is a rate, and rates persist. The assumption behind every '
        'forecast in this lesson is that a crew earning eighty cents on the '
        'dollar today will go on doing so, which is why the remaining work '
        'gets divided by the index rather than taken at face value.',
    source: 'const-pf-q1',
  ),
  ForecastRound(
    subject: 'what is left to do',
    asked:
        'The budget is two million and six hundred thousand has been earned. '
        'What will the rest cost at this rate?',
    progress: _overspending,
    options: [
      '1.4 million, the budget for the work remaining',
      '1.75 million: the remaining budget divided by the index',
      '1.0 million',
      '2.5 million',
    ],
    answer: 1,
    why:
        'One and three quarter million. There is 1.4 million of budgeted work '
        'left, and at eighty cents on the dollar it will take 1.75 million to '
        'buy it. Reporting the 1.4 assumes the crew suddenly starts hitting '
        'budget, which is the wrong answer the lesson prints.',
    source: 'const-pf-q2',
  ),
  ForecastRound(
    subject: 'what the whole job will cost',
    asked:
        'Seven hundred and fifty thousand is already spent and the rest will '
        'cost 1.75 million. What is the estimate at completion?',
    progress: _overspending,
    options: [
      'Two million, the original budget',
      '1.75 million, the cost of the rest',
      '2.5 million: what is spent plus what is left to spend',
      '2.15 million',
    ],
    answer: 2,
    why:
        'Two and a half million, which is a quarter over budget. The estimate '
        'at completion is money already gone plus money still to go, and the '
        'two wrong answers here are each of those halves reported on its own.',
    source: 'const-pf-q3',
  ),
  ForecastRound(
    subject: 'a job running to plan',
    asked:
        'This job has earned exactly what it has spent. What does the '
        'forecast say?',
    progress: _onBudget,
    options: [
      'It will finish on budget, since the index is one',
      'It will finish over budget',
      'It will finish under budget',
      'The forecast cannot be made',
    ],
    answer: 0,
    why:
        'On budget. With an index of one the division does nothing, so the '
        'remaining work costs what it was budgeted to cost and the estimate '
        'at completion lands on the original budget. That is the case '
        'everything else is measured against.',
    source: 'const-pf-q2',
  ),
  ForecastRound(
    subject: 'a job doing better',
    asked:
        'Here the index is above one. What happens to the forecast?',
    progress: _underspending,
    options: [
      'It stays at the budget: you cannot forecast a saving',
      'It comes in under the budget, since dividing by a number above one '
          'makes the remaining work cheaper',
      'It goes over',
      'It doubles',
    ],
    answer: 1,
    why:
        'Under, and the arithmetic is the same in both directions. Dividing '
        'the remaining budgeted work by an index above one makes it cheaper. '
        'Forecasts of savings are treated more cautiously than forecasts of '
        'overruns in practice, but the formula does not know that.',
    source: 'const-pf-q3',
  ),
];

class _WhatItWillCostGameState extends State<WhatItWillCostGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-it-will-cost',
    chapterId: 'construction',
    total: forecastRounds.length,
    sourceProblemIdOf: (round) => forecastRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  ForecastRound get _round => forecastRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What It Will Cost by the End',
        closing:
            'The cost index is earned over spent, earned value on top, '
            'and below one means the money is not buying its worth. The '
            'remaining budgeted work divided by that index is what the rest '
            'will really cost, and adding what is already spent gives the '
            'estimate at completion. Each half of that sum is a wrong answer '
            'on its own.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: forecastBrief,
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
            'WHERE IT WILL END UP',
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
            height: 216,
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
                  painter: ForecastPainter(
                    progress: r.progress,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.options.length; i++) ...[
            _Choice(
              label: r.options[i],
              selected: _picked == i,
              locked: answered,
              isTruth: r.answer == i,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            if (i != r.options.length - 1) const SizedBox(height: 8),
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
