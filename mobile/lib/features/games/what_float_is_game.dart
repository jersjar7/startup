import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'cpm_figures.dart';
import 'lesson_brief.dart';

/// What Float Is — the first item for `float-critical-path`.
///
/// Total float is the gap between the earliest and latest start, and it
/// belongs to the path rather than to the activity. Free float is the
/// smaller part that belongs to the activity alone.
class WhatFloatIsGame extends StatefulWidget {
  const WhatFloatIsGame({super.key});

  @override
  State<WhatFloatIsGame> createState() => _WhatFloatIsGameState();
}

@immutable
class TotalFloatRound {
  const TotalFloatRound({
    required this.subject,
    required this.asked,
    required this.network,
    this.highlight,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Network network;

  /// The activity the round is about, picked out on the drawing.
  final String? highlight;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The scheduling network these lessons share. C carries five days of
/// total float and two of free float; A, B and D carry none.
const _theNetwork = Network(tasks: [
  Task(name: 'A', days: 3),
  Task(name: 'B', days: 4, after: ['A']),
  Task(name: 'C', days: 2, after: ['A']),
  Task(name: 'D', days: 6, after: ['B']),
  Task(name: 'E', days: 3, after: ['B', 'C']),
]);

const totalFloatRounds = <TotalFloatRound>[
  TotalFloatRound(
    subject: 'the subtraction',
    asked:
        'An activity could start on day three and must start by day eight. '
        'How much total float has it?',
    network: _theNetwork,
    highlight: 'C',
    options: [
      'Two days, which is its duration',
      'Five days: the latest it may start less the earliest it could',
      'Eleven days: the two added',
      'None',
    ],
    answer: 1,
    why:
        'Five days, the gap between the two starts. Subtracting the finishes '
        'gives the same five, which is a useful check. The duration is a '
        'different number that happens to be sitting nearby, and the lesson '
        'prints it as a wrong answer.',
    source: 'const-fl-q1',
  ),
  TotalFloatRound(
    subject: 'what float is for',
    asked: 'What does five days of total float on an activity mean?',
    network: _theNetwork,
    highlight: 'C',
    options: [
      'The activity can be five days longer than planned',
      'The activity can be canceled',
      'Five days have already been lost',
      'The activity can slip up to five days without the PROJECT finishing '
          'later',
    ],
    answer: 3,
    why:
        'Room to slip without moving the end date. It is not spare work and '
        'it is not a reward: it is the amount by which this activity is not '
        'the thing holding the project up. Use more than five and the finish '
        'moves.',
    source: 'const-fl-q1',
  ),
  TotalFloatRound(
    subject: 'the other float',
    asked:
        'C finishes on day five and the earliest thing waiting on it starts '
        'on day seven. How much FREE float has it?',
    network: _theNetwork,
    highlight: 'C',
    options: [
      'Five days, the same as its total float',
      'Two days: it can slip that far without pushing anything at all',
      'Seven days',
      'None',
    ],
    answer: 1,
    why:
        'Two days, which is the room before the NEXT activity is affected. '
        'Total float asks about the project finish and free float asks about '
        'the immediate successor, so free float is never the larger of the '
        'two. Here C has two free and five total.',
    source: 'const-fl-q3',
  ),
  TotalFloatRound(
    subject: 'spending the difference',
    asked:
        'C slips four days: more than its free float, less than its total. '
        'What happens?',
    network: _theNetwork,
    highlight: 'E',
    options: [
      'The project finishes later',
      'Nothing at all',
      'The activity behind it has to start later, but the project still '
          'finishes on time',
      'C becomes critical',
    ],
    answer: 2,
    why:
        'The successor gets pushed and the project does not. That is exactly '
        'the ground between the two floats: the extra three days of total '
        'float belong to the chain, not to C alone, and using them takes them '
        'from somebody else.',
    source: 'const-fl-q3',
  ),
  TotalFloatRound(
    subject: 'whose slack it is',
    asked:
        'Two activities in a row each show four days of total float. Can both '
        'slip four days?',
    network: _theNetwork,
    highlight: null,
    options: [
      'No: they are sharing the same slack, and the first to use it takes it '
          'from the other',
      'Yes: each has its own four days',
      'Yes, if they are not critical',
      'Only if they have free float as well',
    ],
    answer: 0,
    why:
        'They share it. Total float belongs to the path, not to the '
        'activity, and a schedule that treats it as pocket money for every '
        'activity in turn will slip. Free float is the part that truly '
        'belongs to one activity alone.',
    source: 'const-fl-q1',
  ),
  TotalFloatRound(
    subject: 'the number that means critical',
    asked: 'What total float does an activity on the critical path have?',
    network: _theNetwork,
    highlight: 'B',
    options: [
      'The most of any activity',
      'Zero: there is no room at all',
      'Whatever the project duration is',
      'One day',
    ],
    answer: 1,
    why:
        'Zero. Its earliest and latest starts are the same day, so any delay '
        'at all pushes the finish. That is the definition the next item works '
        'with, and it is why the critical path and the longest path are the '
        'same chain seen two ways.',
    source: 'const-fl-q1',
  ),
];

class _WhatFloatIsGameState extends State<WhatFloatIsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-float-is',
    chapterId: 'construction',
    total: totalFloatRounds.length,
    sourceProblemIdOf: (round) => totalFloatRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  TotalFloatRound get _round => totalFloatRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Float Is',
        closing:
            'Total float is the latest start less the earliest, and it '
            'says how far an activity can slip without moving the project '
            'finish. Free float is how far it can slip without moving '
            'anything at all, and it is never the larger of the two. Total '
            'float is shared along a path: the first activity to spend it '
            'takes it from the rest.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: floatBrief,
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
            'ROOM TO SLIP',
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
            height: 216,
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
                  painter: NetworkPainter(
                    network: r.network,
                    highlight: r.highlight,
                    showEarly: true,
                    showLate: true,
                    markCritical: false,
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
