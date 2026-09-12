import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'signal_figures.dart';

/// Three Parts of a Walk — the third item for `signal-timing`.
///
/// The pedestrian green is three separate things added: a few seconds to
/// get going, the walk itself at a fixed pace, and a little more when a
/// crowd has to leave the curb. Each of the lesson's wrong answers is one
/// of the three left out or mis-set.
class ThreePartsOfAWalkGame extends StatefulWidget {
  const ThreePartsOfAWalkGame({super.key});

  @override
  State<ThreePartsOfAWalkGame> createState() =>
      _ThreePartsOfAWalkGameState();
}

@immutable
class GreenRound {
  const GreenRound({
    required this.subject,
    required this.asked,
    required this.walk,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Walk walk;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own crossing: 56 ft at 3.5 ft a second with 15 people
/// waiting, which comes to 23.3 seconds.
const _theCrosswalk = Walk(crosswalk: 56, people: 15);

/// The same crossing with almost nobody on it.
const _quiet = Walk(crosswalk: 56, people: 2);

/// A much wider crossing.
const _wide = Walk(crosswalk: 90, people: 15);

const greenRounds = <GreenRound>[
  GreenRound(
    subject: 'the three pieces',
    asked: 'A pedestrian green is made of how many separate pieces?',
    walk: _theCrosswalk,
    options: [
      'One: the walking time',
      'Two: walking, and a safety factor',
      'Three: a few seconds to get going, the walk itself, and an allowance '
          'for the number of people waiting',
      'Four, one for each leg of the crossing',
    ],
    answer: 2,
    why:
        'Three, added straight. Getting going is a fixed 3.2 seconds, the '
        'walk is the crosswalk length over the walking pace, and the last '
        'piece grows with the crowd. Every wrong answer the lesson prints is '
        'one of these three missing or mis-set.',
    source: 'trans-st-q3',
  ),
  GreenRound(
    subject: 'the piece that is always there',
    asked: 'What is the 3.2 seconds at the front of the formula for?',
    walk: _theCrosswalk,
    options: [
      'The time it takes people to notice the signal and step off the curb',
      'A rounding allowance',
      'The time for the signal to change',
      'The width of the curb ramp',
    ],
    answer: 0,
    why:
        'Starting up. Nobody steps off the instant the walk signal appears: '
        'they look, they decide, they move. It is a fixed amount that does '
        'not depend on the width of the road, and dropping it takes three '
        'seconds off the green for the slowest people on the street.',
    source: 'trans-st-q3',
  ),
  GreenRound(
    subject: 'the pace that is used',
    asked:
        'A student works this crossing with a walking pace of 4.0 ft a second '
        'and gets a shorter green. What is wrong with that?',
    walk: _theCrosswalk,
    options: [
      'Nothing: 4.0 is a reasonable walking speed',
      'The standard pace is slower, 3.5 ft a second, because the green has to '
          'suit the slowest people crossing',
      'The pace should be faster still',
      'The pace is not used at all',
    ],
    answer: 1,
    why:
        'The pace is deliberately slow. A brisk adult walks faster than 3.5 '
        'ft a second, and that is the point: the timing is set for people '
        'with a cane, a stroller, or a bad knee. Using 4.0 gives 21.3 seconds '
        'here instead of 23.3, and the lesson prints it as a wrong answer.',
    source: 'trans-st-q3',
  ),
  GreenRound(
    subject: 'a crossing with nobody on it',
    asked:
        'The same crosswalk with two people waiting rather than fifteen. What '
        'changes?',
    walk: _quiet,
    options: [
      'Nothing: the green is fixed',
      'Only the crowd allowance, which nearly disappears',
      'The walking time falls',
      'The start-up time falls',
    ],
    answer: 1,
    why:
        'Only the last piece. Fifteen people take about four seconds to get '
        'off the curb and two take well under one, so the green comes down by '
        'about three seconds. The walk itself and the start-up are untouched: '
        'the road is the same width and people start just as slowly.',
    source: 'trans-st-q3',
  ),
  GreenRound(
    subject: 'a wider road',
    asked:
        'This crossing is 90 ft rather than 56. Which piece grows?',
    walk: _wide,
    options: [
      'The start-up',
      'The crowd allowance',
      'The walking time, which is the length over the pace',
      'All three, in proportion',
    ],
    answer: 2,
    why:
        'Only the walking time, and it grows straight with the width: about '
        '26 seconds of walking instead of 16. It is why wide arterials end up '
        'with pedestrian greens of forty seconds or more, and why a median '
        'refuge that lets people cross in two stages is worth so much.',
    source: 'trans-st-q3',
  ),
  GreenRound(
    subject: 'the piece most often dropped',
    asked:
        'The right answer here is 23.3 seconds. A student reports 19.2. Which '
        'piece did they leave out?',
    walk: _theCrosswalk,
    options: [
      'The start-up',
      'The walking time',
      'The crowd allowance for the fifteen people waiting',
      'None: they used the wrong pace',
    ],
    answer: 2,
    why:
        'The crowd. 3.2 plus 16 is 19.2, which is the answer with the last '
        'term forgotten, and it is the lesson\'s own printed trap. It is the '
        'easiest piece to forget because it is the only one that depends on '
        'something other than the road itself.',
    source: 'trans-st-q3',
  ),
];

class _ThreePartsOfAWalkGameState extends State<ThreePartsOfAWalkGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'three-parts-of-a-walk',
    chapterId: 'transportation',
    total: greenRounds.length,
    sourceProblemIdOf: (round) => greenRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  GreenRound get _round => greenRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Three Parts of a Walk',
        closing:
            'Three point two seconds to get going, the crosswalk over three '
            'and a half feet a second to walk it, and about a quarter of a '
            'second for each person waiting. The pace is slow on purpose. '
            'Every wrong answer in this problem is one of the three pieces '
            'missing or set too fast.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: pedestrianGreenBrief,
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
            'THE WALK SIGNAL',
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
            height: 206,
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
                  painter: WalkPainter(
                    walk: r.walk,
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
