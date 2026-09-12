import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'cpm_figures.dart';
import 'lesson_brief.dart';

/// The Chain With No Slack — the second item for `float-critical-path`.
///
/// The critical path is the longest path and the zero float chain, which
/// are the same set of activities seen two ways. It is where a lost day
/// costs the project a day, and the only place acceleration buys time.
class TheChainWithNoSlackGame extends StatefulWidget {
  const TheChainWithNoSlackGame({super.key});

  @override
  State<TheChainWithNoSlackGame> createState() => _TheChainWithNoSlackGameState();
}

@immutable
class CriticalRound {
  const CriticalRound({
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

/// The lesson's own three path network: fifteen days through B and D,
/// twelve through C and D, ten through C and E.
const _threePaths = Network(tasks: [
  Task(name: 'A', days: 4),
  Task(name: 'B', days: 6, after: ['A']),
  Task(name: 'C', days: 3, after: ['A']),
  Task(name: 'D', days: 5, after: ['B', 'C']),
  Task(name: 'E', days: 3, after: ['C']),
]);

const criticalRounds = <CriticalRound>[
  CriticalRound(
    subject: 'which path is critical',
    asked:
        'Three paths run through this network: fifteen days through B and D, '
        'twelve through C and D, ten through C and E. Which is critical?',
    network: _threePaths,
    highlight: null,
    options: [
      'The ten day path, the quickest way through',
      'The twelve day path, in the middle',
      'The fifteen day path, the longest',
      'All of them added, thirty seven days',
    ],
    answer: 2,
    why:
        'The longest, fifteen days, which is also the project duration: it is '
        'the chain nothing can be done about without changing the finish '
        'date. Adding the paths is meaningless, since they run at the same '
        'time and share activities.',
    source: 'const-fl-q2',
  ),
  CriticalRound(
    subject: 'the same chain, two names',
    asked:
        'The critical path is the longest path. What is it in terms of '
        'float?',
    network: _theNetwork,
    highlight: 'D',
    options: [
      'The chain of activities with zero total float',
      'The chain with the most float',
      'The chain with the longest activities',
      'The chain with the most activities',
    ],
    answer: 0,
    why:
        'The zero float chain, which is the same chain by another route. '
        'There is no room on the longest path by definition, since any slack '
        'there would mean a longer path existed. Two definitions, one set of '
        'activities.',
    source: 'const-fl-q2',
  ),
  CriticalRound(
    subject: 'a day lost on the path',
    asked:
        'A critical activity runs a day late. What happens to the project?',
    network: _theNetwork,
    highlight: 'B',
    options: [
      'Nothing, if the others catch up',
      'It finishes a day late, unless something on the path is shortened',
      'It finishes a day early',
      'Only the next activity is affected',
    ],
    answer: 1,
    why:
        'A day late, straight through. That is what critical means: there is '
        'no cushion anywhere along the chain to absorb it. Making the time '
        'back means shortening something else ON the path, which usually '
        'costs money.',
    source: 'const-fl-q2',
  ),
  CriticalRound(
    subject: 'a day lost off the path',
    asked:
        'A non critical activity with five days of total float runs a day '
        'late. What happens?',
    network: _theNetwork,
    highlight: 'C',
    options: [
      'The project finishes a day late',
      'Nothing to the finish date: it has spent one of its five days',
      'The critical path moves immediately',
      'The activity becomes critical',
    ],
    answer: 1,
    why:
        'Nothing to the finish, and four days of float left. Slip it far '
        'enough and the float runs out, and at that moment this path becomes '
        'critical too. Float is a warning light, not a promise.',
    source: 'const-fl-q2',
  ),
  CriticalRound(
    subject: 'more than one',
    asked: 'Can a network have two critical paths?',
    network: _threePaths,
    highlight: null,
    options: [
      'No: only one path can be longest',
      'Yes: if two paths are the same length, both have zero float and both '
          'are critical',
      'Only if the project is late',
      'Only in networks with more than ten activities',
    ],
    answer: 1,
    why:
        'Yes, and it happens often on real jobs. Two equally long paths both '
        'have zero float, and the schedule then has two ways to go wrong at '
        'once. Shortening only one of them buys nothing, which surprises '
        'people.',
    source: 'const-fl-q2',
  ),
  CriticalRound(
    subject: 'why anybody cares',
    asked:
        'A manager has money to accelerate one activity. Where should it go?',
    network: _theNetwork,
    highlight: 'D',
    options: [
      'The longest activity in the project',
      'The most expensive one',
      'An activity on the critical path, since nothing else moves the finish',
      'The one furthest behind',
    ],
    answer: 2,
    why:
        'On the critical path, because nothing off it changes the end date. '
        'That is the practical payoff of the whole method: it says exactly '
        'where effort buys time and where it buys nothing at all.',
    source: 'const-fl-q2',
  ),
];

class _TheChainWithNoSlackGameState extends State<TheChainWithNoSlackGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'the-chain-with-no-slack',
    chapterId: 'construction',
    total: criticalRounds.length,
    sourceProblemIdOf: (round) => criticalRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  CriticalRound get _round => criticalRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'The Chain With No Slack',
        closing:
            'The critical path is the longest path, which is the same as '
            'the chain with no float on it. A day lost there is a day lost to '
            'the project, a day lost off it only spends float, and money '
            'spent accelerating anything else buys nothing. Two paths can be '
            'critical at once.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: criticalPathBrief,
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
            'THE CHAIN THAT DECIDES',
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
