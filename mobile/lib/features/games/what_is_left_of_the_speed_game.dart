import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'traffic_flow_figures.dart';
import 'lesson_brief.dart';

/// What Is Left of the Speed — the second item for `traffic-flow`.
///
/// The speed line has two parts and the answer is the difference between
/// them: the free flow speed, less what the traffic already on the road has
/// taken away. Reporting the amount taken away instead of what is left is
/// the wrong answer the lesson prints.
class WhatIsLeftOfTheSpeedGame extends StatefulWidget {
  const WhatIsLeftOfTheSpeedGame({super.key});

  @override
  State<WhatIsLeftOfTheSpeedGame> createState() =>
      _WhatIsLeftOfTheSpeedGameState();
}

@immutable
class SpeedRound {
  const SpeedRound({
    required this.subject,
    required this.asked,
    required this.stream,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Stream stream;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own road at the density it asks about: 60 mph free flow,
/// 120 a mile at a jam, asked at 40 a mile, where the speed is 40 mph.
const _atForty = Stream(freeFlow: 60, jamDensity: 120, density: 40);

/// The same road at its optimum density, which is 60 a mile.
const _atOptimum = Stream(freeFlow: 60, jamDensity: 120, density: 60);

/// And nearly jammed.
const _nearlyJammed = Stream(freeFlow: 60, jamDensity: 120, density: 108);

const speedRounds = <SpeedRound>[
  SpeedRound(
    subject: 'the shape of the speed line',
    asked:
        'Under Greenshields, how does the speed change as the lane fills up?',
    stream: _atForty,
    options: [
      'It holds at the free flow speed until the jam',
      'It falls in a straight line, from the free flow speed down to nothing '
          'at the jam density',
      'It falls, then rises again',
      'It does not change with density at all',
    ],
    answer: 1,
    why:
        'A straight line between two points that are easy to remember: the '
        'free flow speed on an empty road, and zero when the road is jammed. '
        'The whole model is that one assumption, and everything else in the '
        'lesson follows from it.',
    source: 'trans-tf-q2',
  ),
  SpeedRound(
    subject: 'the two pieces of the sum',
    asked:
        'On this road the traffic at 40 a mile has taken 20 mph off the free '
        'flow speed of 60. What is the speed?',
    stream: _atForty,
    options: [
      '20 mph, which is what the traffic took away',
      '60 mph, the free flow speed',
      '40 mph, what is left after the reduction',
      '30 mph',
    ],
    answer: 2,
    why:
        'Forty, which is what remains. The formula has two terms and the '
        'answer is the difference, not either piece: the lesson prints 20, '
        'the reduction on its own, and 60, the free flow speed untouched, as '
        'its two wrong answers.',
    source: 'trans-tf-q2',
  ),
  SpeedRound(
    subject: 'the tempting half',
    asked:
        'A student answers 30 mph, which is half the free flow speed. When '
        'would that be right?',
    stream: _atOptimum,
    options: [
      'At any density',
      'At half the jam density, which is 60 a mile, not 40',
      'At the jam density',
      'On an empty road',
    ],
    answer: 1,
    why:
        'Only at half the jam density. Half the free flow speed is the '
        'optimum speed, and it belongs to the optimum DENSITY, which on this '
        'road is 60 a mile. At 40 a mile the road is not there yet. Knowing '
        'the halves is useful and reaching for them out of turn is not.',
    source: 'trans-tf-q2',
  ),
  SpeedRound(
    subject: 'how much room is left',
    asked:
        'This lane is at 108 a mile against a jam density of 120. What is the '
        'speed doing?',
    stream: _nearlyJammed,
    options: [
      'Still near the free flow speed',
      'Down to a tenth of the free flow speed, about 6 mph',
      'Exactly half',
      'Zero',
    ],
    answer: 1,
    why:
        'Nearly gone. At nine tenths of the jam density only a tenth of the '
        'speed is left, six miles an hour. The flow is low as well, because '
        'even with the road full of vehicles almost nothing is getting past '
        'a point.',
    source: 'trans-tf-q2',
  ),
  SpeedRound(
    subject: 'what the slope of the line is',
    asked:
        'The reduction term is the free flow speed over the jam density, '
        'times the density. What is that first part?',
    stream: _atForty,
    options: [
      'The optimum speed',
      'The maximum flow',
      'The slope of the speed line: how much speed each extra vehicle a mile '
          'costs',
      'The average speed',
    ],
    answer: 2,
    why:
        'The slope, in miles per hour per vehicle per mile. On this road it '
        'is a half, so every two vehicles added to a mile of lane cost one '
        'mile an hour. Reading it that way makes the formula a sentence '
        'rather than a shape to memorize.',
    source: 'trans-tf-q2',
  ),
  SpeedRound(
    subject: 'checking an answer against the picture',
    asked:
        'An answer comes out at 70 mph on this road. How do you know it is '
        'wrong without redoing it?',
    stream: _atForty,
    options: [
      'Because nothing on the road can exceed the free flow speed, which is '
          '60',
      'Because 70 is not a round number',
      'Because the density is too high for that',
      'You cannot tell without the flow',
    ],
    answer: 0,
    why:
        'Because the free flow speed is the ceiling. It is the speed on an '
        'empty road, so any traffic at all puts the answer below it. That one '
        'check catches sign slips and swapped terms, and it costs nothing.',
    source: 'trans-tf-q2',
  ),
];

class _WhatIsLeftOfTheSpeedGameState extends State<WhatIsLeftOfTheSpeedGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-is-left-of-the-speed',
    chapterId: 'transportation',
    total: speedRounds.length,
    sourceProblemIdOf: (round) => speedRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  SpeedRound get _round => speedRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Is Left of the Speed',
        closing:
            'Start at the free flow speed and subtract what the traffic has '
            'taken away. The answer is the difference, never either piece on '
            'its own. Half the free flow speed belongs to half the jam '
            'density and nowhere else. And nothing on the road ever exceeds '
            'the free flow speed, which is a free check on the answer.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: speedDensityBrief,
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
            'READING THE LINE',
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
            height: 234,
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
                  painter: GreenshieldsPainter(
                    stream: r.stream,
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
