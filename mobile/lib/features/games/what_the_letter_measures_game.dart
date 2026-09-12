import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'los_figures.dart';

/// What the Letter Measures — the third item for `capacity-los`.
///
/// Level of service is read off DENSITY, not off volume and not off speed.
/// The lesson's wrong answers are all letters that come from getting the
/// density wrong by one step, which is why the last step of the sum is
/// worth as much attention as the first.
class WhatTheLetterMeasuresGame extends StatefulWidget {
  const WhatTheLetterMeasuresGame({super.key});

  @override
  State<WhatTheLetterMeasuresGame> createState() =>
      _WhatTheLetterMeasuresGameState();
}

@immutable
class LetterRound {
  const LetterRound({
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

/// The lesson's own case: two lanes, 3,600 an hour, peak factor 0.90, a
/// tenth trucks on the level, 60 mph. Density 36.7, which is service E.
const _theCase = Freeway(
  volume: 3600,
  peakHourFactor: 0.90,
  lanes: 2,
  mix: TruckMix(trucks: 0.10, equivalent: 2.0),
);

/// The same road with a third lane, which drops the density a long way.
const _threeLanes = Freeway(
  volume: 3600,
  peakHourFactor: 0.90,
  lanes: 3,
  mix: TruckMix(trucks: 0.10, equivalent: 2.0),
);

/// The same traffic moving more slowly, which RAISES the density.
const _slower = Freeway(
  volume: 3600,
  peakHourFactor: 0.90,
  lanes: 2,
  mix: TruckMix(trucks: 0.10, equivalent: 2.0),
  speed: 45,
);

const letterRounds = <LetterRound>[
  LetterRound(
    subject: 'what the table is read on',
    asked: 'The level of service letter is looked up against what?',
    road: _theCase,
    options: [
      'The hourly volume',
      'The mean speed',
      'The density, in vehicles to a mile of lane',
      'The number of lanes',
    ],
    answer: 2,
    why:
        'Density, always. Two roads can carry the same volume at quite '
        'different densities, and speed stays near the free flow value until '
        'a road is almost full, so neither of those sorts the letters out. '
        'How close together the vehicles are is what a driver actually '
        'experiences.',
    source: 'trans-cl-q3',
  ),
  LetterRound(
    subject: 'the last step of the sum',
    asked:
        'The flow rate here works out at 2,200 cars an hour in a lane at 60 '
        'mph. How is the density found?',
    road: _theCase,
    options: [
      'Multiply the two',
      'Divide the flow by the speed',
      'Divide the speed by the flow',
      'Subtract the speed from the flow',
    ],
    answer: 1,
    why:
        'Flow over speed, which follows from flow being speed times density. '
        'Here that is 2,200 over 60, about 37 vehicles to a mile of lane. The '
        'units answer it too: cars an hour over miles an hour leaves cars a '
        'mile.',
    source: 'trans-cl-q3',
  ),
  LetterRound(
    subject: 'reading the ladder',
    asked:
        'A density of about 37 to the mile. Which letter is that, on a table '
        'running A up to 11, B to 18, C to 26, D to 35, E to 45?',
    road: _theCase,
    options: [
      'C',
      'D',
      'E',
      'F',
    ],
    answer: 2,
    why:
        'E, which is the band above 35 and up to 45. It is the last band '
        'before breakdown: the road is at capacity, and any disturbance turns '
        'it into F. Note how close 37 is to the D boundary, which is why the '
        'wrong answers in this problem are all a single letter away.',
    source: 'trans-cl-q3',
  ),
  LetterRound(
    subject: 'one missing step, one wrong letter',
    asked:
        'A student who forgets the heavy vehicle factor gets a density of 33 '
        'instead of 37. What do they report?',
    road: _theCase,
    options: [
      'D instead of E: one band too good',
      'The same letter',
      'F instead of E',
      'A instead of E',
    ],
    answer: 0,
    why:
        'D, one band too good, which is the lesson\'s own wrong answer. A '
        'nine per cent slip in the flow rate is enough to move the letter '
        'because the bands are narrow near capacity. That is the practical '
        'reason to work these problems carefully rather than approximately.',
    source: 'trans-cl-q3',
  ),
  LetterRound(
    subject: 'what another lane buys',
    asked:
        'The same traffic is given a third lane. What happens to the letter?',
    road: _threeLanes,
    options: [
      'It stays at E',
      'It improves, because the same traffic in more lanes is less dense',
      'It gets worse',
      'The letter does not depend on lanes',
    ],
    answer: 1,
    why:
        'It improves several bands: the flow per lane falls by a third and '
        'the density with it, to about 24 a mile, which is service C. '
        'Widening is the crudest fix in traffic engineering and it is '
        'reliable for exactly this reason.',
    source: 'trans-cl-q3',
  ),
  LetterRound(
    subject: 'slower traffic, worse service',
    asked:
        'Same volume, same two lanes, but the traffic is moving at 45 mph '
        'rather than 60. What does that do to the density?',
    road: _slower,
    options: [
      'Lowers it, since slower traffic is calmer',
      'Raises it: the same flow at a lower speed means the vehicles are '
          'packed closer together',
      'Nothing: density does not depend on speed',
      'It cannot be worked out',
    ],
    answer: 1,
    why:
        'Raises it, to about 49 a mile, which is service F. Same number of '
        'vehicles past a point, but they are going more slowly, so there are '
        'more of them in every mile. Density and speed move opposite ways at '
        'a given flow, which is the whole idea behind the letter grades.',
    source: 'trans-cl-q3',
  ),
];

class _WhatTheLetterMeasuresGameState
    extends State<WhatTheLetterMeasuresGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-the-letter-measures',
    chapterId: 'transportation',
    total: letterRounds.length,
    sourceProblemIdOf: (round) => letterRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  LetterRound get _round => letterRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What the Letter Measures',
        closing:
            'Work the flow per lane, divide by the speed to get the density, '
            'then read the letter off that. Not off the volume, not off the '
            'speed. The bands are narrow near capacity, so a single missing '
            'adjustment moves the letter, and a lane added or a speed lost '
            'moves it further still.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: levelOfServiceBrief,
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
            'THE LETTER ON THE ROAD',
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
