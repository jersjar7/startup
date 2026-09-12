import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'demand_figures.dart';
import 'lesson_brief.dart';

/// Who Gets the Trips — the second item for `travel-demand`.
///
/// The gravity model gives every destination a weight, attractions times
/// friction, and then shares the origin's trips out in proportion to those
/// weights. Forgetting to divide by the SUM of the weights is the mistake
/// the lesson names, and using the attractions alone is the wrong answer it
/// prints.
class WhoGetsTheTripsGame extends StatefulWidget {
  const WhoGetsTheTripsGame({super.key});

  @override
  State<WhoGetsTheTripsGame> createState() => _WhoGetsTheTripsGameState();
}

@immutable
class TripShareRound {
  const TripShareRound({
    required this.subject,
    required this.asked,
    required this.spread,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Spread spread;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own pair of destinations: 200 attractions at a friction of
/// 0.5, against 300 at 0.2. Weights of 100 and 60, so 625 trips and 375.
const _lessonPair = Spread(
  produced: 1000,
  destinations: [
    Destination(name: 'zone 1', attractions: 200, friction: 0.5),
    Destination(name: 'zone 2', attractions: 300, friction: 0.2),
  ],
);

/// A pair where the two weights come out equal.
const _evenPair = Spread(
  produced: 1000,
  destinations: [
    Destination(name: 'zone 1', attractions: 200, friction: 0.4),
    Destination(name: 'zone 2', attractions: 400, friction: 0.2),
  ],
);

/// Three destinations rather than two.
const _three = Spread(
  produced: 1200,
  destinations: [
    Destination(name: 'zone 1', attractions: 200, friction: 0.5),
    Destination(name: 'zone 2', attractions: 300, friction: 0.2),
    Destination(name: 'zone 3', attractions: 100, friction: 0.4),
  ],
);

const tripShareRounds = <TripShareRound>[
  TripShareRound(
    subject: 'what gives a zone its pull',
    asked:
        'In the gravity model, what decides how attractive a destination is '
        'to a particular origin?',
    spread: _lessonPair,
    options: [
      'Its attractions alone',
      'How far away it is alone',
      'Its attractions multiplied by the friction factor for that trip',
      'The trips produced at the origin',
    ],
    answer: 2,
    why:
        'Both together, multiplied. A big destination a long way off and a '
        'small one close by can pull equally hard. That product is the '
        'zone\'s weight, and everything else in the calculation is just '
        'sharing out in proportion to it.',
    source: 'trans-td-q1',
  ),
  TripShareRound(
    subject: 'the step people forget',
    asked:
        'Zone 1 has a weight of 100 and zone 2 a weight of 60. What is zone '
        '1\'s share of the trips?',
    spread: _lessonPair,
    options: [
      'A hundred trips, its weight',
      'Its weight over the SUM of the weights, so 100 over 160',
      'Its weight over the trips produced',
      'A half, since there are two zones',
    ],
    answer: 1,
    why:
        'The weight over the total weight, 100 of 160, which is 0.625. '
        'Dividing by the sum is the step the lesson warns about: without it '
        'the shares do not add to one and the model sends out more or fewer '
        'trips than the origin made.',
    source: 'trans-td-q1',
  ),
  TripShareRound(
    subject: 'attractions on their own',
    asked:
        'A student ignores the friction factors and splits the thousand trips '
        'by attractions alone, 200 against 300. What do they report for zone '
        '1?',
    spread: _lessonPair,
    options: [
      '625 trips',
      '400 trips',
      '500 trips',
      '375 trips',
    ],
    answer: 1,
    why:
        'Four hundred, and it is wrong in an interesting direction: zone 2 '
        'has more attractions but is much harder to reach, so ignoring '
        'friction hands it trips it will not get. The right answer, 625, '
        'gives the majority to the nearer zone.',
    source: 'trans-td-q1',
  ),
  TripShareRound(
    subject: 'a tie',
    asked:
        'Here zone 2 has twice the attractions but half the friction factor '
        'of zone 1. How do the trips split?',
    spread: _evenPair,
    options: [
      'Evenly, because the two weights come out the same',
      'Two to one in favor of zone 2',
      'Two to one in favor of zone 1',
      'It cannot be worked out',
    ],
    answer: 0,
    why:
        'Evenly, because 400 times 0.2 and 200 times 0.4 are both 80. Twice '
        'as big and half as easy to reach cancel exactly. That is the model '
        'working as intended: size and reach trade against each other.',
    source: 'trans-td-q1',
  ),
  TripShareRound(
    subject: 'a third destination arrives',
    asked:
        'A third zone is added to the same origin. What happens to the shares '
        'of the first two?',
    spread: _three,
    options: [
      'They are unchanged',
      'They both rise',
      'Only the nearer one changes',
      'They both fall, because the sum underneath has grown',
    ],
    answer: 3,
    why:
        'Both fall. The new zone adds its weight to the denominator, so every '
        'existing share is divided by a bigger number. The trips produced '
        'have not changed, so a new destination can only take trips from the '
        'others.',
    source: 'trans-td-q1',
  ),
  TripShareRound(
    subject: 'checking the answer',
    asked:
        'You work out the trips to every destination. What should they add '
        'up to?',
    spread: _lessonPair,
    options: [
      'The sum of the attractions',
      'The sum of the weights',
      'The trips the origin produced, exactly',
      'A thousand, whatever the origin produced',
    ],
    answer: 2,
    why:
        'The origin\'s own productions, exactly, because the shares add to '
        'one by construction. It is a free check on the whole calculation, '
        'and it is the check that catches a forgotten denominator: if the '
        'trips do not add up, the normalizing step went missing.',
    source: 'trans-td-q1',
  ),
];

class _WhoGetsTheTripsGameState extends State<WhoGetsTheTripsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'who-gets-the-trips',
    chapterId: 'transportation',
    total: tripShareRounds.length,
    sourceProblemIdOf: (round) => tripShareRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  TripShareRound get _round => tripShareRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Who Gets the Trips',
        closing:
            'Every destination gets a weight, its attractions times the '
            'friction factor for that trip. Then the origin\'s trips are '
            'shared out in proportion to those weights, which means dividing '
            'by their SUM. The shares add to one and the trips add to what '
            'the origin produced, which is the check that catches the '
            'forgotten denominator.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: gravityBrief,
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
            'SHARING OUT THE TRIPS',
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
                  painter: GravityPainter(
                    spread: r.spread,
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
