import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'signal_figures.dart';

/// Feet, Not Miles — the first item for `signal-timing`.
///
/// The yellow interval is a moment to react plus the time to shed the
/// approach speed, and every quantity in it is in feet and seconds. Feeding
/// it miles per hour is the mistake the lesson names twice, and it lands on
/// a printed wrong answer both times.
class FeetNotMilesGame extends StatefulWidget {
  const FeetNotMilesGame({super.key});

  @override
  State<FeetNotMilesGame> createState() => _FeetNotMilesGameState();
}

@immutable
class YellowRound {
  const YellowRound({
    required this.subject,
    required this.asked,
    required this.yellow,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Yellow yellow;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own approach: 50 mph, a second to react, ten feet per
/// second squared.4.7 seconds of yellow.
const _fifty = Yellow(speedMph: 50);

/// A slower approach, where the yellow comes out much shorter.
const _thirty = Yellow(speedMph: 30);

/// The same fifty, running downhill, where it takes longer to stop.
const _downhill = Yellow(speedMph: 50, grade: -0.04);

const yellowRounds = <YellowRound>[
  YellowRound(
    subject: 'what the yellow is made of',
    asked:
        'The yellow interval has to let a driver at the decision point stop '
        'in time. What is it made of?',
    yellow: _fifty,
    options: [
      'The time to stop, and nothing else',
      'A fixed three seconds for every approach',
      'A moment to react, then the time it takes to shed the approach speed',
      'The time to cross the intersection',
    ],
    answer: 2,
    why:
        'Reaction first, then braking. It is the same shape as the stopping '
        'sight distance: nothing happens at all for about a second, and only '
        'then does the car start slowing. Dropping the reaction term on this '
        'approach gives 3.7 seconds instead of 4.7, which is one of the '
        'lesson\'s wrong answers.',
    source: 'trans-st-q1',
  ),
  YellowRound(
    subject: 'the units in the formula',
    asked:
        'The approach speed is 50 mph. What goes into the formula for the '
        'speed?',
    yellow: _fifty,
    options: [
      '50, since that is the speed',
      '73.3, the same speed in feet per second',
      '50 divided by 60',
      '73.3 divided by 3,600',
    ],
    answer: 1,
    why:
        'Feet per second, 73.3 of them. The deceleration is in feet per '
        'second squared, so the speed has to match it, and 1.467 is the '
        'number that makes the swap: 5,280 feet in a mile over 3,600 seconds '
        'in an hour. Put 50 in raw and the yellow comes out 3.5 seconds, '
        'which is the lesson\'s printed trap.',
    source: 'trans-st-q1',
  ),
  YellowRound(
    subject: 'the two in the denominator',
    asked:
        'A student divides the speed by the deceleration alone and gets 8.3 '
        'seconds. What did they miss?',
    yellow: _fifty,
    options: [
      'The reaction time',
      'The conversion to feet per second',
      'The two in front of the deceleration, which comes from averaging the '
          'speed over the stop',
      'The grade',
    ],
    answer: 2,
    why:
        'The two. A car slowing steadily from full speed to nothing averages '
        'half its speed over the stop, so the time is the speed over TWICE '
        'the deceleration. Leaving it out nearly doubles the yellow, and an '
        'eight second yellow would have drivers treating it as a red.',
    source: 'trans-st-q1',
  ),
  YellowRound(
    subject: 'a slower street',
    asked:
        'The same intersection on a 30 mph approach. What happens to the '
        'yellow?',
    yellow: _thirty,
    options: [
      'It is unchanged: yellow is always the same',
      'It gets longer',
      'It gets shorter, since the slowing part falls with the speed',
      'It halves exactly',
    ],
    answer: 2,
    why:
        'Shorter, because the slowing part is proportional to the speed. It '
        'does not halve, though: the reaction second is there whatever the '
        'speed, so the yellow falls from about 4.7 seconds to about 3.2 '
        'rather than to 2.3. That fixed second is why slow approaches still '
        'need a yellow of three seconds or so.',
    source: 'trans-st-q1',
  ),
  YellowRound(
    subject: 'the same speed downhill',
    asked:
        'This approach runs down a four per cent grade. What does the grade '
        'do to the yellow?',
    yellow: _downhill,
    options: [
      'Lengthens it, because stopping downhill takes longer',
      'Shortens it',
      'Nothing: grade is not in the formula',
      'Lengthens it, because the reaction time grows',
    ],
    answer: 0,
    why:
        'Lengthens it, and for the same reason a downgrade lengthens the '
        'stopping sight distance: gravity is fighting the brakes. The 64.4 '
        'in the formula is twice gravity, and it enters with the same sign '
        'convention as everywhere else, plus for up and minus for down.',
    source: 'trans-st-q1',
  ),
  YellowRound(
    subject: 'what a wrong yellow costs',
    asked:
        'Suppose the yellow is set from miles per hour and comes out 3.5 '
        'seconds instead of 4.7. What is the consequence on the street?',
    yellow: _fifty,
    options: [
      'Nothing: drivers adapt',
      'Drivers at the decision point can neither stop comfortably nor clear '
          'the intersection, which is where right-angle crashes come from',
      'The intersection becomes safer, since drivers slow sooner',
      'Only the fuel consumption changes',
    ],
    answer: 1,
    why:
        'It creates a stretch of road where neither choice works: too close '
        'to stop, too far to clear. That zone is exactly what the yellow '
        'interval exists to eliminate, and a yellow more than a second short '
        'is one of the better documented causes of right-angle crashes.',
    source: 'trans-st-q1',
  ),
];

class _FeetNotMilesGameState extends State<FeetNotMilesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'feet-not-miles',
    chapterId: 'transportation',
    total: yellowRounds.length,
    sourceProblemIdOf: (round) => yellowRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  YellowRound get _round => yellowRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Feet, Not Miles',
        closing:
            'A second to react, then the speed over twice the deceleration, '
            'and every quantity in feet and seconds. Miles per hour straight '
            'into the formula gives 3.5 seconds where 4.7 belongs. Drop the '
            'reaction and you get 3.7. Drop the two and you get 8.3. The '
            'lesson prints all three.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: yellowBrief,
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
            'THE YELLOW INTERVAL',
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
                  painter: YellowPainter(
                    yellow: r.yellow,
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
