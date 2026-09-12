import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'los_figures.dart';

/// Three Things to Divide By — the second item for `capacity-los`.
///
/// The demand flow rate is one volume divided by three quite different
/// things: the peak hour factor, the number of lanes, and the heavy vehicle
/// factor. Each of the lesson's wrong answers is one of the three left out.
/// The peak hour factor itself is taught in the sight distance lesson; what
/// is new here is that the three stack.
class ThreeDivisionsGame extends StatefulWidget {
  const ThreeDivisionsGame({super.key});

  @override
  State<ThreeDivisionsGame> createState() => _ThreeDivisionsGameState();
}

@immutable
class DivideRound {
  const DivideRound({
    required this.subject,
    required this.asked,
    required this.road,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Freeway road;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own freeway: three lanes, 4,500 an hour, peak factor 0.92,
/// a tenth trucks on the level. 1,793 cars an hour in a lane.
const _threeLane = Freeway(
  volume: 4500,
  peakHourFactor: 0.92,
  lanes: 3,
  mix: TruckMix(trucks: 0.10, equivalent: 2.0),
);

/// The same traffic in two lanes instead of three.
const _twoLane = Freeway(
  volume: 4500,
  peakHourFactor: 0.92,
  lanes: 2,
  mix: TruckMix(trucks: 0.10, equivalent: 2.0),
);

/// A road where the traffic arrives very unevenly.
const _peaky = Freeway(
  volume: 4500,
  peakHourFactor: 0.78,
  lanes: 3,
  mix: TruckMix(trucks: 0.10, equivalent: 2.0),
);

const divideRounds = <DivideRound>[
  DivideRound(
    subject: 'what the answer is counted in',
    asked:
        'The demand flow rate is not vehicles an hour on the road. What is '
        'it?',
    road: _threeLane,
    options: [
      'Passenger cars an hour in ONE lane, at the rate of the busiest '
          'quarter hour',
      'Vehicles a day across all lanes',
      'Trucks an hour in one lane',
      'Vehicles an hour across all lanes',
    ],
    answer: 0,
    why:
        'Per lane, in cars, at the peak rate. Three separate conversions, and '
        'each one is a division: by the peak hour factor to get the rate '
        'rather than the average, by the lanes to get one lane, and by the '
        'heavy vehicle factor to get cars rather than vehicles.',
    source: 'trans-cl-q2',
  ),
  DivideRound(
    subject: 'the one that is already familiar',
    asked:
        'One of the three divisors is the peak hour factor. What is it doing '
        'here?',
    road: _threeLane,
    options: [
      'Converting trucks to cars',
      'Turning the hour\'s count into the rate of its busiest quarter',
      'Splitting the traffic between lanes',
      'Adjusting for the terrain',
    ],
    answer: 1,
    why:
        'The same job it does anywhere: the road has to survive its worst '
        'fifteen minutes, so the hourly count is divided by the factor to '
        'get the rate that quarter implies. Nothing new here, only a '
        'familiar step in a longer sum.',
    source: 'trans-cl-q2',
  ),
  DivideRound(
    subject: 'a student who stopped at two',
    asked:
        'On this freeway the answer is 1,793. A student reports 1,630. Which '
        'divisor did they leave out?',
    road: _threeLane,
    options: [
      'The lanes',
      'The peak hour factor',
      'The heavy vehicle factor',
      'None: they used the wrong volume',
    ],
    answer: 2,
    why:
        'The trucks. Dividing by only the peak factor and the lanes gives '
        '1,630, which is the lesson\'s wrong answer and is nine per cent '
        'short. Leaving out the peak factor instead gives 1,650, which is a '
        'different wrong answer of almost the same size. Two similar numbers, '
        'two different omissions.',
    source: 'trans-cl-q2',
  ),
  DivideRound(
    subject: 'the same traffic in fewer lanes',
    asked:
        'The same 4,500 an hour, now in two lanes rather than three. What '
        'happens to the flow per lane?',
    road: _twoLane,
    options: [
      'It falls',
      'It is unchanged: the traffic has not changed',
      'It rises by half, since the same traffic is in fewer lanes',
      'It doubles',
    ],
    answer: 2,
    why:
        'Up by half, from about 1,790 to about 2,690, because the same '
        'traffic is spread over two lanes instead of three. This is the '
        'division that does the most work in practice: the number of lanes '
        'is what a designer actually chooses.',
    source: 'trans-cl-q2',
  ),
  DivideRound(
    subject: 'traffic that arrives in a lump',
    asked:
        'This freeway has the same hourly volume but a peak hour factor of '
        '0.78 rather than 0.92. What does that do?',
    road: _peaky,
    options: [
      'Raises the flow rate, since a low factor means a sharper peak',
      'Lowers it',
      'Nothing: the volume is the same',
      'Raises it only if there are trucks',
    ],
    answer: 0,
    why:
        'Raises it, to about 2,110. A low factor means the hour arrived in a '
        'lump, and the lane has to carry that lump. Two roads with identical '
        'hourly counts can need different numbers of lanes for this reason '
        'alone.',
    source: 'trans-cl-q2',
  ),
  DivideRound(
    subject: 'the direction of every step',
    asked:
        'All three divisors are less than or equal to one, except the lanes. '
        'What does that mean for the answer?',
    road: _threeLane,
    options: [
      'The flow per lane is always below the hourly volume',
      'Dividing by the two factors pushes the answer UP, and dividing by the '
          'lanes pulls it down',
      'The three cancel out',
      'The answer is always about the same as the volume',
    ],
    answer: 1,
    why:
        'The two fractions raise it and the lane count lowers it. Knowing the '
        'direction of each step is how a wrong answer gets caught: if the '
        'heavy vehicle adjustment made the number smaller, it was multiplied '
        'somewhere it should have been divided.',
    source: 'trans-cl-q2',
  ),
];

class _ThreeDivisionsGameState extends State<ThreeDivisionsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'three-things-to-divide-by',
    chapterId: 'transportation',
    total: divideRounds.length,
    sourceProblemIdOf: (round) => divideRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  DivideRound get _round => divideRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Three Things to Divide By',
        closing:
            'One volume, three divisions: the peak hour factor for the surge, '
            'the lanes for one lane, and the heavy vehicle factor for cars '
            'rather than vehicles. Leave out the trucks and you get 1,630. '
            'Leave out the peak factor and you get 1,650. Leave out both and '
            'you are quoting the raw volume.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: demandFlowBrief,
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
            'ONE VOLUME, THREE DIVISIONS',
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
            height: 226,
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
                  painter: LosPainter(
                    road: r.road,
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
