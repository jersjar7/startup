import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'sight_figures.dart';

/// Think Then Brake — the first item for `stopping-sight-distance`.
///
/// Stopping sight distance is two distances laid end to end, and the
/// lesson's two wrong answers are each one of them reported alone. They
/// also behave differently: thinking grows straight with speed, braking
/// grows with its square.
class ThinkThenBrakeGame extends StatefulWidget {
  const ThinkThenBrakeGame({super.key});

  @override
  State<ThinkThenBrakeGame> createState() => _ThinkThenBrakeGameState();
}

@immutable
class StoppingRound {
  const StoppingRound({
    required this.subject,
    required this.asked,
    required this.stop,
    this.against,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Braking stop;

  /// A second road to lay beside it, for the rounds that compare.
  final Braking? against;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own road: 60 mph on the level, 220 ft thinking and 345
/// braking, 566 in all.
const _sixty = Braking(speed: 60);

/// Half the speed: 110 thinking and only 86 braking.
const _thirty = Braking(speed: 30);

/// A driver who takes twice as long to react.
const _slowToReact = Braking(speed: 60, reactionTime: 5);

const stoppingRounds = <StoppingRound>[
  StoppingRound(
    subject: 'what the distance is made of',
    asked:
        'Stopping sight distance is the distance a driver needs to see ahead '
        'in order to stop. What is it made of?',
    stop: _sixty,
    options: [
      'The braking distance alone',
      'The distance covered while reacting alone',
      'The length of the car plus the braking distance',
      'The distance covered while the driver reacts, plus the distance '
          'covered while braking',
    ],
    answer: 3,
    why:
        'Two stretches, end to end. The driver spends the first one going at '
        'full speed and doing nothing at all, because they have not noticed '
        'yet, and the second one slowing down. Both have to fit inside what '
        'the driver can see.',
    source: 'trans-ssd-q1',
  ),
  StoppingRound(
    subject: 'a student who stopped early',
    asked:
        'On this road the answer is 566 ft. A student reports 345 ft. What '
        'did they leave out?',
    stop: _sixty,
    options: [
      'The braking distance',
      'The grade correction',
      'The thinking distance, the stretch covered before the brakes come on',
      'The length of the vehicle',
    ],
    answer: 2,
    why:
        'The thinking part, which on this road is 220 ft: about fifteen car '
        'lengths covered at full speed before anything happens. The lesson '
        'offers both halves as wrong answers, 345 for braking alone and 221 '
        'for reacting alone.',
    source: 'trans-ssd-q1',
  ),
  StoppingRound(
    subject: 'the same road at half the speed',
    asked:
        'At 30 mph rather than 60, which of the two stretches is now the '
        'bigger one?',
    stop: _thirty,
    against: _sixty,
    options: [
      'Thinking, because braking has fallen away much faster',
      'Braking, as always',
      'They are equal at every speed',
      'Neither: both halve',
    ],
    answer: 0,
    why:
        'Thinking. Halving the speed halves the thinking distance but quarters '
        'the braking distance, because braking goes as the SQUARE of the '
        'speed. At 30 mph the driver spends more of the distance not yet '
        'reacting than actually stopping.',
    source: 'trans-ssd-q1',
  ),
  StoppingRound(
    subject: 'the number in front',
    asked:
        'The thinking distance is 1.47 times the speed times the reaction '
        'time. What is the 1.47 for?',
    stop: _sixty,
    options: [
      'It is a factor of safety',
      'It allows for wet pavement',
      'It turns miles per hour into feet per second',
      'It is the driver reaction time',
    ],
    answer: 2,
    why:
        'It is a unit conversion and nothing more: 5,280 feet in a mile over '
        '3,600 seconds in an hour. If a problem gives the speed in feet per '
        'second already, the 1.47 is not wanted at all, which is worth '
        'noticing before it gets applied twice.',
    source: 'trans-ssd-q1',
  ),
  StoppingRound(
    subject: 'a driver slow to notice',
    asked:
        'This driver takes five seconds to react instead of two and a half. '
        'Which part of the distance changes?',
    stop: _slowToReact,
    against: _sixty,
    options: [
      'Both parts, in proportion',
      'Only the braking distance',
      'Only the thinking distance, and it doubles',
      'Neither: the design speed has not changed',
    ],
    answer: 2,
    why:
        'Only the thinking, and it doubles with the time, straight. The car '
        'brakes exactly as well as before. This is why the assumed reaction '
        'time matters so much in design: every extra second is another '
        'ninety feet at 60 mph, before anything has started to slow.',
    source: 'trans-ssd-q1',
  ),
  StoppingRound(
    subject: 'twice the speed',
    asked:
        'A road is designed for twice the speed. What happens to the stopping '
        'sight distance?',
    stop: _sixty,
    against: _thirty,
    options: [
      'It doubles',
      'It more than doubles: thinking doubles but braking quadruples',
      'It quadruples exactly',
      'It stays the same, since faster cars brake harder',
    ],
    answer: 1,
    why:
        'More than double, and less than four times, because the two halves '
        'grow at different rates. That is why sight distance requirements '
        'climb so steeply with design speed, and why a high design speed is '
        'expensive in earthwork long before anybody drives on it.',
    source: 'trans-ssd-q1',
  ),
];

class _ThinkThenBrakeGameState extends State<ThinkThenBrakeGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'think-then-brake',
    chapterId: 'transportation',
    total: stoppingRounds.length,
    sourceProblemIdOf: (round) => stoppingRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  StoppingRound get _round => stoppingRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Think Then Brake',
        closing:
            'Thinking first, braking second, and the answer is both added. '
            'Thinking grows straight with speed and straight with reaction '
            'time. Braking grows with the square of the speed. Report either '
            'one on its own and you have the lesson\'s wrong answer, which it '
            'prints twice.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: sightDistanceBrief,
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
            'SEEING AND STOPPING',
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
                  painter: StoppingPainter(
                    stop: r.stop,
                    against: r.against,
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
