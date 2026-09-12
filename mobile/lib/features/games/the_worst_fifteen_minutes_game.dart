import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'sight_figures.dart';

/// The Worst Fifteen Minutes — the third item for `stopping-sight-distance`.
///
/// A road is not designed for the hour it carries, it is designed for the
/// rate the busiest quarter of that hour implies. So the flow rate is always
/// at least the hourly volume, and an answer below the volume is impossible
/// on its face.
class TheWorstFifteenMinutesGame extends StatefulWidget {
  const TheWorstFifteenMinutesGame({super.key});

  @override
  State<TheWorstFifteenMinutesGame> createState() =>
      _TheWorstFifteenMinutesGameState();
}

@immutable
class SurgeRound {
  const SurgeRound({
    required this.subject,
    required this.asked,
    required this.hour,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Hour hour;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own hour: 1,200 vehicles, 400 of them in the worst quarter,
/// so a peak hour factor of 0.75 and a flow rate of 1,600 an hour.
const _lessonHour = Hour(counts: [250, 400, 300, 250]);

/// An hour that arrives evenly: the factor is one and the flow rate is the
/// volume.
const _evenHour = Hour(counts: [300, 300, 300, 300]);

/// An hour that all arrives at once: the lowest factor there is.
const _allAtOnce = Hour(counts: [0, 1200, 0, 0]);

const surgeRounds = <SurgeRound>[
  SurgeRound(
    subject: 'the hour and its worst quarter',
    asked:
        'This road carried 1,200 vehicles in the hour, 400 of them in the '
        'busiest quarter. What is the peak flow rate?',
    hour: _lessonHour,
    options: [
      '1,200 an hour: that is what it carried',
      '400 an hour',
      '1,600 an hour: the busiest quarter, stretched to an hour',
      '900 an hour',
    ],
    answer: 2,
    why:
        'Sixteen hundred. The flow rate asks what the whole hour would come '
        'to if it ran at the rate of its busiest fifteen minutes, so it is '
        'four times that quarter. The road has to cope with the surge, not '
        'with the average of the hour that contains it.',
    source: 'trans-ssd-q3',
  ),
  SurgeRound(
    subject: 'a number that cannot be right',
    asked:
        'Another student reports 900 an hour for the same road. What is wrong '
        'with that answer on its face?',
    hour: _lessonHour,
    options: [
      'It is below the volume the road actually carried, and a peak rate '
          'never can be',
      'It is not a round number',
      'It is more than four times the worst quarter',
      'Nothing: 900 is plausible',
    ],
    answer: 0,
    why:
        'It is less than the 1,200 that actually came through, which is '
        'impossible: the peak rate is the busiest part of the hour, so it can '
        'never be below the hour\'s own average. That student multiplied by '
        'the peak hour factor instead of dividing by it.',
    source: 'trans-ssd-q3',
  ),
  SurgeRound(
    subject: 'an hour that arrives evenly',
    asked:
        'Here the four quarters are equal. What is the peak hour factor?',
    hour: _evenHour,
    options: [
      'Zero',
      'One: the flow rate and the hourly volume are the same',
      'Four',
      'It cannot be worked out',
    ],
    answer: 1,
    why:
        'One, which is the best it can be. If every quarter is the same then '
        'the busiest quarter IS the average, four times it is the hour, and '
        'there is no surge to design for. Real roads run somewhere between '
        '0.85 and 0.95.',
    source: 'trans-ssd-q3',
  ),
  SurgeRound(
    subject: 'and one that arrives all at once',
    asked:
        'Suppose an entire hour of traffic came through in one quarter, as '
        'here. What is the peak hour factor then?',
    hour: _allAtOnce,
    options: [
      'Zero',
      'One',
      'A quarter, which is the lowest it can go',
      'Four',
    ],
    answer: 2,
    why:
        'A quarter, and that is the floor. The factor runs from 0.25, '
        'everything in one fifteen minutes, up to 1.00, perfectly even. A '
        'low factor means a sharp peak, and it is the sharp peak, not the '
        'hour, that the design has to survive.',
    source: 'trans-ssd-q3',
  ),
  SurgeRound(
    subject: 'why the rate and not the count',
    asked:
        'Why is the flow rate used for design rather than the hourly volume?',
    hour: _lessonHour,
    options: [
      'Because it is the larger number, and larger is safer',
      'Because the volume is hard to measure',
      'Because the road either works during the worst fifteen minutes or it '
          'does not, and the rest of the hour cannot fix it',
      'Because the volume only applies to freeways',
    ],
    answer: 2,
    why:
        'Because congestion happens in the surge. A road that is fine for '
        'three quarters of the hour and gridlocked for the other quarter is a '
        'road that fails, and the queue it grows in those fifteen minutes '
        'takes far longer than fifteen minutes to clear.',
    source: 'trans-ssd-q3',
  ),
  SurgeRound(
    subject: 'reading the factor backwards',
    asked:
        'Two roads carry the same hourly volume, one with a factor of 0.95 '
        'and the other 0.75. Which needs more capacity?',
    hour: _lessonHour,
    options: [
      'The one at 0.95, since the number is higher',
      'The one at 0.75, because its traffic is bunched into a sharper peak',
      'Both the same: the volume decides it',
      'Neither can be judged without the speed',
    ],
    answer: 1,
    why:
        'The one at 0.75. A lower factor means a peakier hour, which means a '
        'higher flow rate from the same count, which means more lanes. It is '
        'worth fixing the direction in mind: LOW factor, HIGH design flow.',
    source: 'trans-ssd-q3',
  ),
];

class _TheWorstFifteenMinutesGameState
    extends State<TheWorstFifteenMinutesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'the-worst-fifteen-minutes',
    chapterId: 'transportation',
    total: surgeRounds.length,
    sourceProblemIdOf: (round) => surgeRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  SurgeRound get _round => surgeRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'The Worst Fifteen Minutes',
        closing:
            'Four times the busiest quarter is the flow rate, and it is never '
            'below the hourly volume. The peak hour factor is the volume over '
            'that rate, it runs from a quarter to one, and a LOW factor means '
            'a sharp peak and a HIGH design flow. An answer below the hourly '
            'volume is wrong before you check the arithmetic.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: peakHourBrief,
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
            'THE PEAK INSIDE THE HOUR',
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
            height: 210,
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
                  painter: PeakPainter(
                    hour: r.hour,
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
