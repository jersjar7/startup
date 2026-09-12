import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'demand_figures.dart';
import 'lesson_brief.dart';

/// Farther Means Fewer — the third item for `travel-demand`.
///
/// The friction factor is the part of the gravity model that behaves like
/// distance in gravity itself: it FALLS as the trip gets longer, so distant
/// zones receive fewer trips. The lesson's wrong answer has it rising.
class FartherMeansFewerGame extends StatefulWidget {
  const FartherMeansFewerGame({super.key});

  @override
  State<FartherMeansFewerGame> createState() =>
      _FartherMeansFewerGameState();
}

@immutable
class FrictionRound {
  const FrictionRound({
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

/// A near zone and a far one with the same attractions, so only the
/// friction separates them.
const _nearAndFar = Spread(
  produced: 1000,
  destinations: [
    Destination(name: 'near', attractions: 250, friction: 0.6),
    Destination(name: 'far', attractions: 250, friction: 0.15),
  ],
);

/// The far zone made much bigger, which wins some of the trips back.
const _farButBig = Spread(
  produced: 1000,
  destinations: [
    Destination(name: 'near', attractions: 250, friction: 0.6),
    Destination(name: 'far', attractions: 1200, friction: 0.15),
  ],
);

/// A road improvement that raises the friction factor for the far zone.
const _afterTheRoad = Spread(
  produced: 1000,
  destinations: [
    Destination(name: 'near', attractions: 250, friction: 0.6),
    Destination(name: 'far', attractions: 250, friction: 0.35),
  ],
);

const frictionRounds = <FrictionRound>[
  FrictionRound(
    subject: 'which way the factor moves',
    asked:
        'As the travel time between two zones goes up, what does the friction '
        'factor do?',
    spread: _nearAndFar,
    options: [
      'It rises, since there is more friction to overcome',
      'It falls, so the trips between the two fall with it',
      'It stays the same',
      'It depends on the attractions',
    ],
    answer: 1,
    why:
        'It falls. The name is a little misleading: a high friction FACTOR '
        'means an easy trip, not a hard one. It is written that way so it '
        'can multiply the attractions directly, and the lesson prints the '
        'reversed version as a choice.',
    source: 'trans-td-q3',
  ),
  FrictionRound(
    subject: 'why it is called gravity',
    asked:
        'What does the model have in common with gravity between two masses?',
    spread: _nearAndFar,
    options: [
      'Nothing: the name is arbitrary',
      'Trips grow with the size of the destination and shrink with the '
          'distance to it',
      'Trips are proportional to weight',
      'The trips fall off as the square of the distance, exactly',
    ],
    answer: 1,
    why:
        'Big and near attracts, small and far does not, which is the shape '
        'of gravity. The analogy stops short of the exact inverse square: '
        'the friction factors come from surveys of how people actually '
        'travel, not from a formula.',
    source: 'trans-td-q3',
  ),
  FrictionRound(
    subject: 'two zones alike but for distance',
    asked:
        'These two zones have the same attractions, but one is much further '
        'away. Where do most of the trips go?',
    spread: _nearAndFar,
    options: [
      'To the far zone',
      'Evenly, since the attractions are equal',
      'To the near zone, by a long way',
      'It cannot be told without the productions',
    ],
    answer: 2,
    why:
        'To the near one, four times over: a friction factor of 0.6 against '
        '0.15. With the attractions equal the friction is the only thing '
        'separating them, and it separates them a great deal.',
    source: 'trans-td-q3',
  ),
  FrictionRound(
    subject: 'far, but worth the trip',
    asked:
        'The far zone is now five times the size of the near one. What '
        'happens?',
    spread: _farButBig,
    options: [
      'Nothing: distance always wins',
      'The far zone now takes most of the trips, because size can beat '
          'distance',
      'The two split evenly',
      'The near zone takes everything',
    ],
    answer: 1,
    why:
        'Size wins this one. The weights are 250 times 0.6 against 1,200 '
        'times 0.15, which is 150 against 180. This is why a regional mall '
        'draws from half a county while the shops next door do not: enough '
        'attraction overcomes a long trip.',
    source: 'trans-td-q3',
  ),
  FrictionRound(
    subject: 'a faster road to the far zone',
    asked:
        'A new road cuts the travel time to the far zone, so its friction '
        'factor rises from 0.15 to 0.35. What happens to the trips?',
    spread: _afterTheRoad,
    options: [
      'They move toward the far zone, which now takes about a third of them',
      'They move toward the near zone',
      'Nothing changes: the attractions are the same',
      'The origin produces more trips',
    ],
    answer: 0,
    why:
        'The far zone gains, because the road made it easier to reach and '
        'the factor says so. Note what did NOT change: the origin still '
        'produces the same trips. Distribution moves trips around, it does '
        'not create them, which is a distinction worth holding on to when a '
        'project is being argued about.',
    source: 'trans-td-q3',
  ),
  FrictionRound(
    subject: 'the socioeconomic term',
    asked:
        'The formula also carries a K factor. What is it for?',
    spread: _nearAndFar,
    options: [
      'It converts the units',
      'It is the friction factor under another name',
      'It adjusts for things the attractions and the friction do not '
          'capture, and is one when there is nothing to adjust',
      'It is the number of zones',
    ],
    answer: 2,
    why:
        'It is a correction for the differences between zones that the model '
        'cannot see: income, car ownership, and habits that show up in the '
        'survey data and not in the formula. With nothing to adjust it is '
        'one, which is where most exam problems leave it.',
    source: 'trans-td-q3',
  ),
];

class _FartherMeansFewerGameState extends State<FartherMeansFewerGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'farther-means-fewer',
    chapterId: 'transportation',
    total: frictionRounds.length,
    sourceProblemIdOf: (round) => frictionRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  FrictionRound get _round => frictionRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Farther Means Fewer',
        closing:
            'The friction factor falls as the trip gets longer, so a high '
            'factor means an EASY trip. Big and near attracts, small and far '
            'does not, and a big enough destination can still beat a long '
            'trip. A faster road raises the factor and moves trips toward '
            'that zone, without changing how many trips there are.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: frictionBrief,
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
            'NEAR AGAINST BIG',
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
