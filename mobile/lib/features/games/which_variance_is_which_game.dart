import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'earned_value_figures.dart';
import 'lesson_brief.dart';

/// Which Variance Is Which — the only item for `earned-value-analysis`.
///
/// Three numbers on one date, and two subtractions that both start from
/// the earned value: less what was spent for the money, less what was
/// planned for the calendar. Negative is bad in both.
class WhichVarianceIsWhichGame extends StatefulWidget {
  const WhichVarianceIsWhichGame({super.key});

  @override
  State<WhichVarianceIsWhichGame> createState() => _WhichVarianceIsWhichGameState();
}

@immutable
class ValueRound {
  const ValueRound({
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

/// The lesson's own month six: 400k of work done, 450k spent.
const _monthSix = Progress(planned: 420000, earned: 400000, actual: 450000);

/// Its week ten: 500k planned, 420k earned, 480k spent.
const _weekTen = Progress(planned: 500000, earned: 420000, actual: 480000);

/// And the case that comes out behind but cheap.
const _slowButThrifty =
    Progress(planned: 300000, earned: 270000, actual: 250000);

const valueRounds = <ValueRound>[
  ValueRound(
    subject: 'the three numbers',
    asked:
        'Earned value management keeps three numbers on any given date. What '
        'is the middle one, the earned value?',
    progress: _monthSix,
    options: [
      'What the plan said would be spent by now',
      'What has actually been spent',
      'What the work actually finished is worth, at budgeted rates',
      'What is left in the budget',
    ],
    answer: 2,
    why:
        'The budgeted value of the work that is genuinely done. That is the '
        'number everything else is measured against, because it is the only '
        'one that reflects progress rather than intentions or invoices.',
    source: 'const-ev-q1',
  ),
  ValueRound(
    subject: 'money against work',
    asked:
        'Four hundred thousand of work has been done and four hundred and '
        'fifty spent. What does that say?',
    progress: _monthSix,
    options: [
      'Fifty thousand over budget: more spent than the work is worth',
      'Fifty thousand under budget',
      'Nothing, without the schedule',
      'The project is behind schedule',
    ],
    answer: 0,
    why:
        'Over budget by fifty thousand. Earned less spent is the cost '
        'variance, and it is negative here. Subtracting the other way round '
        'gives the same number with the wrong sign, which is the lesson\'s '
        'printed trap: the answer is not fifty thousand to the good.',
    source: 'const-ev-q1',
  ),
  ValueRound(
    subject: 'work against the calendar',
    asked:
        'Five hundred thousand was planned by now and four hundred and '
        'twenty earned. What is the schedule variance?',
    progress: _weekTen,
    options: [
      'Minus sixty thousand',
      'Plus eighty thousand',
      'Minus eighty thousand: less work done than the plan called for',
      'Plus twenty thousand',
    ],
    answer: 2,
    why:
        'Minus eighty thousand, earned less planned. The minus sixty on the '
        'list is the COST variance for the same project, earned less spent, '
        'and it is the wrong answer the lesson prints: two variances, two '
        'different subtractions, both starting from earned value.',
    source: 'const-ev-q2',
  ),
  ValueRound(
    subject: 'the number both start from',
    asked: 'What do the cost variance and the schedule variance have in '
        'common?',
    progress: _weekTen,
    options: [
      'Both are measured in days',
      'Both start from the earned value and subtract something else',
      'Both use the actual cost',
      'Both are always negative',
    ],
    answer: 1,
    why:
        'Both begin at earned value. Take away what was spent and you have '
        'the cost picture; take away what was planned and you have the '
        'schedule picture. Getting the two subtractions the right way round '
        'is most of what this lesson asks.',
    source: 'const-ev-q2',
  ),
  ValueRound(
    subject: 'what a minus means',
    asked: 'A variance comes out negative. What does that mean?',
    progress: _weekTen,
    options: [
      'Something good: less was used',
      'Something bad: over budget, or behind schedule',
      'Nothing: the sign is arbitrary',
      'That the project is finished',
    ],
    answer: 1,
    why:
        'Bad news, in both cases. The convention is worth fixing once: '
        'negative is over budget on the cost side and behind schedule on the '
        'time side. Getting the sign right and then reading it backwards is a '
        'separate mistake the lesson also prints.',
    source: 'const-ev-q1',
  ),
  ValueRound(
    subject: 'slow but thrifty',
    asked:
        'Two hundred and seventy thousand earned against three hundred '
        'planned and two hundred and fifty spent. Where does this project '
        'stand?',
    progress: _slowButThrifty,
    options: [
      'Ahead of schedule and under budget',
      'Behind schedule and over budget',
      'Behind schedule but under budget',
      'Ahead of schedule but over budget',
    ],
    answer: 2,
    why:
        'Behind and cheap. Less work done than planned, but what was done '
        'cost less than it was worth. It is a common combination, an '
        'efficient crew that is short handed, and it is the reason the two '
        'variances are reported separately rather than netted off.',
    source: 'const-ev-q3',
  ),
];

class _WhichVarianceIsWhichGameState extends State<WhichVarianceIsWhichGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-variance-is-which',
    chapterId: 'construction',
    total: valueRounds.length,
    sourceProblemIdOf: (round) => valueRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  ValueRound get _round => valueRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Variance Is Which',
        closing:
            'Earned value is what the finished work is worth at budgeted '
            'rates, and both variances start there. Less what was spent is '
            'the cost variance, less what was planned is the schedule '
            'variance, and negative means over budget or behind. A project '
            'can easily be behind and under budget at the same time.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: earnedValueBrief,
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
            'THREE NUMBERS, ONE DATE',
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
            height: 196,
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
                  painter: ValuePainter(
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
