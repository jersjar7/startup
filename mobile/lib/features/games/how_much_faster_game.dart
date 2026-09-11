import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// How Much Faster — the first item for `continuity-bernoulli`.
///
/// Continuity is one line and the only thing that goes wrong in it is the
/// SQUARE: the same water has to get through a smaller hole, and the hole
/// shrinks with the square of the diameter, so halving the pipe quadruples
/// the speed. The lesson's problem offers the ratio unsquared, squared twice,
/// and upside down. So the round asks only for the factor, never a number.
class HowMuchFasterGame extends StatefulWidget {
  const HowMuchFasterGame({super.key});

  @override
  State<HowMuchFasterGame> createState() => _HowMuchFasterGameState();
}

/// What the speed gets multiplied by.
enum Factor { quarter, half, same, twice, four, nine }

extension FactorWords on Factor {
  String get plain => switch (this) {
        Factor.quarter => 'a quarter of the speed',
        Factor.half => 'half the speed',
        Factor.same => 'the same speed',
        Factor.twice => 'twice the speed',
        Factor.four => 'four times the speed',
        Factor.nine => 'nine times the speed',
      };

  double get times => switch (this) {
        Factor.quarter => 0.25,
        Factor.half => 0.5,
        Factor.same => 1,
        Factor.twice => 2,
        Factor.four => 4,
        Factor.nine => 9,
      };
}

@immutable
class FasterRound {
  const FasterRound({
    required this.subject,
    required this.change,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What happens to the pipe, in words.
  final String change;
  final List<Factor> options;
  final Factor answer;
  final String why;
  final String source;
}

const fasterRounds = <FasterRound>[
  FasterRound(
    subject: 'the lesson\'s reducer',
    change:
        'A 300 millimeter pipe reduces to 150 millimeters. The same water '
        'goes through both.',
    options: [Factor.twice, Factor.four, Factor.half, Factor.same],
    answer: Factor.four,
    why:
        'Four times. The bore halves, so the AREA quarters, and the same flow '
        'through a quarter of the opening has to move four times as fast. '
        'Two m/s becomes eight. Answering twice is the named trap: that is '
        'the diameter ratio used without squaring it.',
    source: 'fm-cb-q1',
  ),
  FasterRound(
    subject: 'the other way round',
    change:
        'The same pipe, but now the water runs from the 150 into the 300.',
    options: [Factor.four, Factor.half, Factor.quarter, Factor.twice],
    answer: Factor.quarter,
    why:
        'A quarter. Everything runs the other way when the pipe opens out: '
        'four times the area, a quarter of the speed. This is why a pipe '
        'discharging into a chamber slows almost to a stop, and it is what '
        'lets sediment drop out in a settling tank.',
    source: 'fm-cb-q1',
  ),
  FasterRound(
    subject: 'a third of the bore',
    change: 'A 300 millimeter main necks down to a 100 millimeter branch '
        'carrying all of it.',
    options: [Factor.nine, Factor.four, Factor.twice, Factor.same],
    answer: Factor.nine,
    why:
        'Nine times, because three squared is nine. The square makes small '
        'reductions in the bore expensive very quickly, which is the reason '
        'velocity limits drive pipe sizing: the velocity head that comes with '
        'it grows as the SQUARE of that again.',
    source: 'fm-cb-q1',
  ),
  FasterRound(
    subject: 'the area, not the bore',
    change:
        'A duct is replaced by one with half the cross-sectional AREA, '
        'carrying the same flow.',
    options: [Factor.four, Factor.same, Factor.twice, Factor.half],
    answer: Factor.twice,
    why:
        'Twice, and read that carefully: it was the AREA that halved, not the '
        'bore. Continuity is about area all along, and the square only shows '
        'up when a problem hands you a diameter instead. A given area change '
        'is a speed change in direct proportion.',
    source: 'fm-cb-q1',
  ),
  FasterRound(
    subject: 'a longer pipe of the same bore',
    change:
        'The same 300 millimeter pipe runs on for another two hundred meters '
        'without changing size.',
    options: [Factor.same, Factor.twice, Factor.half, Factor.four],
    answer: Factor.same,
    why:
        'The same speed. Length is not in continuity anywhere: the same water '
        'passes every section of a pipe that has not changed size, so it '
        'moves at the same rate all along it. What the length DOES change is '
        'the pressure, through friction, and that is the energy equation '
        'rather than this one.',
    source: 'fm-cb-q1',
  ),
  FasterRound(
    subject: 'a square duct',
    change:
        'A square duct is replaced by one with half the side, still carrying '
        'everything.',
    options: [Factor.twice, Factor.same, Factor.four, Factor.quarter],
    answer: Factor.four,
    why:
        'Four times again. Nothing about continuity is special to round '
        'pipes: the area of a square goes as the side squared just as a '
        'circle goes as the diameter squared, so halving either one quarters '
        'the opening. It is the area that matters and the shape never does.',
    source: 'fm-cb-q1',
  ),
];

class _HowMuchFasterGameState extends State<HowMuchFasterGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-much-faster',
    chapterId: 'fluid-mechanics',
    total: fasterRounds.length,
    sourceProblemIdOf: (round) => fasterRounds[round].source,
  )..addListener(_onSession);

  Factor? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  FasterRound get _round => fasterRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Much Faster',
        closing:
            'The same water has to get through whatever opening you give it, '
            'so the speed goes up in proportion to the AREA it loses. Areas '
            'go as the square of a diameter or a side, which is why halving '
            'the bore quadruples the speed and a third of the bore is nine '
            'times. Length never comes into it.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: continuityBrief,
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
            'WHAT HAPPENS TO THE SPEED',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.change,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: MathText(
              r'$A_1 v_1 = A_2 v_2$',
              style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 16),
          for (final option in r.options) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE FACTOR' : 'NOT THAT ONE',
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
