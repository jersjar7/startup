import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'cpm_figures.dart';
import 'lesson_brief.dart';

/// When Can It Start — the first item for `cpm-fundamentals`.
///
/// Two rules and no more: an activity finishes its own duration after it
/// starts, and it starts when the LAST of the things it waits on has
/// finished. Everything else in a forward pass is those two applied in
/// order.
class WhenCanItStartGame extends StatefulWidget {
  const WhenCanItStartGame({super.key});

  @override
  State<WhenCanItStartGame> createState() => _WhenCanItStartGameState();
}

@immutable
class StartRound {
  const StartRound({
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

/// The four activity network the lesson builds: A first, then B and C in
/// parallel, then D waiting on both.
const _fourTask = Network(tasks: [
  Task(name: 'A', days: 4),
  Task(name: 'B', days: 6, after: ['A']),
  Task(name: 'C', days: 3, after: ['A']),
  Task(name: 'D', days: 2, after: ['B', 'C']),
]);

/// Two activities end to end, which is where the lesson starts.
const _twoTask = Network(tasks: [
  Task(name: 'A', days: 5),
  Task(name: 'B', days: 3, after: ['A']),
]);

/// A merge with two predecessors finishing at different times.
const _merge = Network(tasks: [
  Task(name: 'A', days: 6),
  Task(name: 'B', days: 9),
  Task(name: 'C', days: 4, after: ['A', 'B']),
]);

const startRounds = <StartRound>[
  StartRound(
    subject: 'one after another',
    asked:
        'A takes five days from day zero, and B cannot start until A is '
        'finished. When does B finish?',
    network: _twoTask,
    highlight: 'B',
    options: [
      'Day five, when A finishes',
      'Day three, which is how long B takes',
      'Day eight: B starts when A finishes and takes three more days',
      'Day fifteen',
    ],
    answer: 2,
    why:
        'Day eight. Finish to start means B begins the moment A ends, on day '
        'five, and runs its own three days from there. The two commonest '
        'slips are reporting A\'s finish, which is day five, or B\'s '
        'duration, which is three: both are numbers in the problem and '
        'neither is the answer.',
    source: 'const-cpm-q1',
  ),
  StartRound(
    subject: 'the one rule the forward pass has',
    asked:
        'C waits on both A and B. A finishes on day six and B on day nine. '
        'When can C start?',
    network: _merge,
    highlight: 'C',
    options: [
      'Day six, as soon as the first one is done',
      'Day nine, because everything it waits on must be finished',
      'Day seven and a half, the average',
      'Day fifteen, the two added',
    ],
    answer: 1,
    why:
        'Day nine. An activity waits for the LAST of its predecessors, not '
        'the first, because all of them have to be done before it can begin. '
        'That one rule is the whole of the forward pass at a merge, and it '
        'is where the project duration comes from.',
    source: 'const-cpm-q2',
  ),
  StartRound(
    subject: 'what the early start means',
    asked:
        'The early start of an activity is the earliest it COULD begin. What '
        'decides it?',
    network: _fourTask,
    highlight: 'D',
    options: [
      'The calendar the crew prefers',
      'Its own duration',
      'When the last thing it waits on is finished, and nothing else',
      'The late start minus the float',
    ],
    answer: 2,
    why:
        'The work in front of it. Early start has nothing to do with what '
        'the activity itself takes, only with what has to happen first. The '
        'duration comes in afterward, to give the early finish.',
    source: 'const-cpm-q2',
  ),
  StartRound(
    subject: 'two at once',
    asked:
        'B and C both wait only on A, which finishes on day four. When does '
        'each of them start?',
    network: _fourTask,
    highlight: 'C',
    options: [
      'Both on day four: nothing is stopping either of them',
      'B on day four and C after B',
      'C first, since it is shorter',
      'Whichever has the crew available',
    ],
    answer: 0,
    why:
        'Both on day four. Nothing in the network says they take turns, so '
        'the schedule assumes they run side by side. Crews and equipment may '
        'say otherwise in real life, and that is a resource question the '
        'network does not answer.',
    source: 'const-cpm-q3',
  ),
  StartRound(
    subject: 'the finish of the branch',
    asked:
        'B takes six days from day four and C takes three. When is D, which '
        'waits on both, able to start?',
    network: _fourTask,
    highlight: 'D',
    options: [
      'Day seven, when C is done',
      'Day ten, when B is done: the later of the two',
      'Day thirteen, the two branches added',
      'Day four, with the others',
    ],
    answer: 1,
    why:
        'Day ten, when the slower branch finishes. C was done on day seven '
        'and then waited. That wait is float, and it is the thing the rest '
        'of this chapter is about.',
    source: 'const-cpm-q3',
  ),
  StartRound(
    subject: 'the arithmetic that is not addition',
    asked:
        'A student answers the two activity question with fifteen days. What '
        'did they do?',
    network: _twoTask,
    highlight: 'B',
    options: [
      'Added the durations twice',
      'Multiplied the two durations instead of running one after the other',
      'Used the wrong start day',
      'Added a day for the weekend',
    ],
    answer: 1,
    why:
        'Multiplied five by three. It is the wrong answer the lesson prints, '
        'and it is worth a moment: durations in series ADD. Nothing in '
        'scheduling ever multiplies two durations together.',
    source: 'const-cpm-q1',
  ),
];

class _WhenCanItStartGameState extends State<WhenCanItStartGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'when-can-it-start',
    chapterId: 'construction',
    total: startRounds.length,
    sourceProblemIdOf: (round) => startRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  StartRound get _round => startRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'When Can It Start',
        closing:
            'Early finish is early start plus the duration, and early start '
            'is when the LAST predecessor finishes. Two activities that wait '
            'on the same thing both start the moment it ends. Durations in '
            'series add, they never multiply, and the numbers already in the '
            'problem are rarely the answer to it.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: forwardPassBrief,
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
            'THE FORWARD PASS',
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
