import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'cpm_figures.dart';
import 'lesson_brief.dart';

/// How Long in All — the second item for `cpm-fundamentals`.
///
/// A project takes as long as its LONGEST path, which is not the sum of its
/// activities and not its longest activity. Work off that path is free in
/// schedule terms, and shortening it buys nothing.
class HowLongInAllGame extends StatefulWidget {
  const HowLongInAllGame({super.key});

  @override
  State<HowLongInAllGame> createState() => _HowLongInAllGameState();
}

@immutable
class LengthRound {
  const LengthRound({
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

/// The lesson's four activity network: A, then B and C side by side, then
/// D waiting on both. Fourteen days through B, eleven through C.
const _fourTask = Network(tasks: [
  Task(name: 'A', days: 4),
  Task(name: 'B', days: 6, after: ['A']),
  Task(name: 'C', days: 3, after: ['A']),
  Task(name: 'D', days: 2, after: ['B', 'C']),
]);

/// The same network with the short branch lengthened until it governs.
const _flipped = Network(tasks: [
  Task(name: 'A', days: 4),
  Task(name: 'B', days: 6, after: ['A']),
  Task(name: 'C', days: 9, after: ['A']),
  Task(name: 'D', days: 2, after: ['B', 'C']),
]);

/// A chain with nothing in parallel at all.
const _chain = Network(tasks: [
  Task(name: 'A', days: 4),
  Task(name: 'B', days: 6, after: ['A']),
  Task(name: 'D', days: 2, after: ['B']),
]);

const lengthRounds = <LengthRound>[
  LengthRound(
    subject: 'how long the whole thing takes',
    asked:
        'A takes four days, then B six and C three side by side, then D two. '
        'How long is the project?',
    network: _fourTask,
    highlight: 'D',
    options: [
      'Fifteen days: every duration added',
      'Twelve days: four, then the longer branch of six, then two',
      'Nine days: the shortest way through',
      'Six days: the longest single activity',
    ],
    answer: 1,
    why:
        'Twelve. Follow the LONGEST path: four, then six, then two. Adding '
        'every duration would be right only if nothing ran in parallel, and '
        'the whole point of a network is that things do. The three day '
        'activity costs the project nothing at all.',
    source: 'const-cpm-q3',
  ),
  LengthRound(
    subject: 'what the parallel branch costs',
    asked:
        'C runs beside B and takes three days against B\'s six. What does C '
        'add to the project?',
    network: _fourTask,
    highlight: 'C',
    options: [
      'Three days',
      'Nothing: it finishes with time to spare while B is still going',
      'Half of three days',
      'It depends on the crew size',
    ],
    answer: 1,
    why:
        'Nothing, as the network stands. C finishes on day seven and D waits '
        'until day ten for B, so C has three days of slack. Work that does '
        'not lie on the longest path is free, in schedule terms, which is why '
        'shortening it does not help.',
    source: 'const-cpm-q3',
  ),
  LengthRound(
    subject: 'shortening the wrong thing',
    asked:
        'A manager takes a day out of C to pull the project in. What happens '
        'to the finish date?',
    network: _fourTask,
    highlight: 'C',
    options: [
      'It comes in by a day',
      'It comes in by half a day',
      'Nothing changes: C was not what the end was waiting on',
      'It slips by a day',
    ],
    answer: 2,
    why:
        'Nothing at all. The project is waiting on B, so money spent '
        'accelerating C buys a longer wait and not an earlier finish. '
        'Knowing which activities the end date actually depends on is the '
        'entire reason for drawing the network.',
    source: 'const-cpm-q3',
  ),
  LengthRound(
    subject: 'when the other branch takes over',
    asked:
        'C is now nine days rather than three. What is the project duration?',
    network: _flipped,
    highlight: 'C',
    options: [
      'Twelve days, as before',
      'Fifteen days: the long way now runs through C',
      'Twenty one days',
      'Nine days',
    ],
    answer: 1,
    why:
        'Fifteen, and the longest path has moved. B is now the branch with '
        'slack. The critical route is a property of the numbers, not of the '
        'drawing, and it can change as soon as a duration does, which is why '
        'schedules are re-run rather than drawn once.',
    source: 'const-cpm-q3',
  ),
  LengthRound(
    subject: 'a chain with no choices',
    asked:
        'This network has nothing running in parallel. What is its duration?',
    network: _chain,
    highlight: 'D',
    options: [
      'The sum of the durations, since there is only one path',
      'The longest single activity',
      'Half the sum',
      'It cannot be worked out',
    ],
    answer: 0,
    why:
        'The sum, because with one path the longest path IS the sum. That is '
        'the special case people generalize from when they add every duration '
        'in a branching network, which is the lesson\'s printed wrong '
        'answer.',
    source: 'const-cpm-q3',
  ),
  LengthRound(
    subject: 'what the duration really is',
    asked:
        'In one sentence, the project duration is:',
    network: _fourTask,
    highlight: null,
    options: [
      'The total of all the work',
      'The average of the paths',
      'The length of the longest path through the network',
      'The duration of the last activity',
    ],
    answer: 2,
    why:
        'The longest path, and nothing else. Everything shorter has slack, '
        'the total of all the work counts parallel activities twice over, and '
        'the last activity is just where the longest path happens to end.',
    source: 'const-cpm-q3',
  ),
];

class _HowLongInAllGameState extends State<HowLongInAllGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-long-in-all',
    chapterId: 'construction',
    total: lengthRounds.length,
    sourceProblemIdOf: (round) => lengthRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  LengthRound get _round => lengthRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Long in All',
        closing:
            'A project takes as long as the longest path through it. '
            'Adding every duration counts the parallel work twice, and the '
            'longest single activity is beside the point. Anything off the '
            'longest path has slack, so shortening it changes nothing, and '
            'the longest path itself moves as soon as a duration does.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: projectDurationBrief,
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
            'THE LONGEST WAY THROUGH',
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
                    showLate: false,
                    markCritical: true,
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
