import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'los_figures.dart';

/// How Many Cars Is a Truck — the first item for `capacity-los`.
///
/// Capacity analysis counts everything in passenger cars, so a truck has to
/// be converted into the cars it displaces: two on the level, three on
/// rolling ground. The factor that does it is always less than one, and it
/// is DIVIDED by, not multiplied.
class HowManyCarsIsATruckGame extends StatefulWidget {
  const HowManyCarsIsATruckGame({super.key});

  @override
  State<HowManyCarsIsATruckGame> createState() =>
      _HowManyCarsIsATruckGameState();
}

@immutable
class MixRound {
  const MixRound({
    required this.subject,
    required this.asked,
    required this.mix,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final TruckMix mix;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own stream: a tenth trucks on level ground, so a factor of
/// 0.909.
const _level = TruckMix(trucks: 0.10, equivalent: 2.0);

/// The same stream on rolling ground, where a truck counts for three.
const _rolling = TruckMix(trucks: 0.10, equivalent: 3.0);

/// A stream with far more trucks.
const _heavy = TruckMix(trucks: 0.30, equivalent: 2.0);

const mixRounds = <MixRound>[
  MixRound(
    subject: 'why trucks are converted at all',
    asked:
        'Capacity analysis counts everything in passenger cars. Why not just '
        'count vehicles?',
    mix: _level,
    options: [
      'Because trucks are heavier',
      'Because a truck takes up the road space of several cars, and space is '
          'what capacity is about',
      'Because trucks pay a different toll',
      'Because trucks are counted separately by law',
    ],
    answer: 1,
    why:
        'Room, not weight. A truck is longer, accelerates slowly and needs a '
        'bigger gap in front of it, so it occupies the road like two cars on '
        'the level and three on rolling ground. Capacity is a question about '
        'space and time, so everything is converted into the same unit.',
    source: 'trans-cl-q1',
  ),
  MixRound(
    subject: 'what a tenth of trucks costs',
    asked:
        'A tenth of this traffic is trucks, each worth two cars on level '
        'ground. What do a hundred vehicles come to?',
    mix: _level,
    options: [
      '100 car spaces: the count is the count',
      '200 car spaces',
      '120 car spaces',
      '110 car spaces: the ten trucks take twenty',
    ],
    answer: 3,
    why:
        'A hundred and ten. Ninety cars stay ninety, and the ten trucks take '
        'twenty between them. Only the EXTRA space counts, which is why the '
        'formula has the equivalent less one in it rather than the '
        'equivalent itself.',
    source: 'trans-cl-q1',
  ),
  MixRound(
    subject: 'which way the factor goes',
    asked:
        'The adjustment factor for that stream is 0.909. How does it enter '
        'the flow calculation?',
    mix: _level,
    options: [
      'You multiply by it, which makes the flow smaller',
      'You divide by it, which makes the flow bigger',
      'You subtract it',
      'You add it to the peak hour factor',
    ],
    answer: 1,
    why:
        'Divide. The traffic is worse than the raw count suggests, so the '
        'number that goes into the capacity comparison has to be LARGER than '
        'the count, not smaller. Dividing by something under one does that. '
        'Multiplying instead flatters the road twice over.',
    source: 'trans-cl-q1',
  ),
  MixRound(
    subject: 'the same trucks on a hill',
    asked:
        'The same ten per cent of trucks, now on rolling ground where each '
        'counts for three cars. What happens to the factor?',
    mix: _rolling,
    options: [
      'It rises toward one',
      'It is unchanged: the truck proportion has not changed',
      'It falls, to about 0.83, so the flow it produces is larger',
      'It goes above one',
    ],
    answer: 2,
    why:
        'It falls to 0.833, because the same trucks now displace twice as '
        'much. The lesson prints 0.833 as a wrong answer to a LEVEL terrain '
        'question for exactly this reason: the two terrains are a line apart '
        'in the problem statement and a long way apart in the answer.',
    source: 'trans-cl-q1',
  ),
  MixRound(
    subject: 'a stream full of trucks',
    asked:
        'Now three in ten are trucks, still two cars each. Where does the '
        'factor go?',
    mix: _heavy,
    options: [
      'Down further, to about 0.77',
      'Up, since there are fewer cars',
      'To exactly 0.70',
      'Above one',
    ],
    answer: 0,
    why:
        'Down to about 0.77: a hundred vehicles now fill 130 car spaces. On a '
        'rural interstate with a third trucks, the effective capacity is a '
        'quarter less than the lane would otherwise carry, which is why truck '
        'climbing lanes are worth building.',
    source: 'trans-cl-q1',
  ),
  MixRound(
    subject: 'a factor that came out wrong',
    asked:
        'A student reports a heavy vehicle factor of 1.10. What has gone '
        'wrong, without checking the arithmetic?',
    mix: _level,
    options: [
      'Nothing: 1.10 is possible with few trucks',
      'The factor can never exceed one, so they have reported the '
          'denominator instead of the fraction',
      'They used rolling terrain',
      'They used the wrong truck proportion',
    ],
    answer: 1,
    why:
        'The factor is one over something bigger than one, so it always lands '
        'between zero and one. A value above one is the denominator reported '
        'on its own, which the lesson prints as a choice. Knowing the range '
        'of an answer is often faster than checking the work.',
    source: 'trans-cl-q1',
  ),
];

class _HowManyCarsIsATruckGameState extends State<HowManyCarsIsATruckGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-many-cars-is-a-truck',
    chapterId: 'transportation',
    total: mixRounds.length,
    sourceProblemIdOf: (round) => mixRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  MixRound get _round => mixRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Many Cars Is a Truck',
        closing:
            'Two cars on the level, three on rolling ground, and only the '
            'EXTRA space counts. The factor is one over one plus that extra, '
            'so it always sits between zero and one, and you divide by it. A '
            'factor above one is the denominator reported by mistake.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: heavyVehicleBrief,
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
            'COUNTING IN CARS',
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
                  painter: TruckPainter(
                    mix: r.mix,
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
