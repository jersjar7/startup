import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'cpm_figures.dart';
import 'lesson_brief.dart';

/// Which Way the Pass Runs — the only item for `forward-backward-pass`.
///
/// Two sweeps in opposite directions, and the merge rule flips between
/// them: going forward an activity waits for the LATEST thing in front of
/// it, going backward it must be clear for the EARLIEST thing behind it.
class WhichWayThePassRunsGame extends StatefulWidget {
  const WhichWayThePassRunsGame({super.key});

  @override
  State<WhichWayThePassRunsGame> createState() => _WhichWayThePassRunsGameState();
}

@immutable
class PassRound {
  const PassRound({
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

/// The network all three scheduling lessons share: A, then B and C, then D
/// behind B and E behind both B and C. Thirteen days, critical through
/// A, B and D.
const _theNetwork = Network(tasks: [
  Task(name: 'A', days: 3),
  Task(name: 'B', days: 4, after: ['A']),
  Task(name: 'C', days: 2, after: ['A']),
  Task(name: 'D', days: 6, after: ['B']),
  Task(name: 'E', days: 3, after: ['B', 'C']),
]);

const passRounds = <PassRound>[
  PassRound(
    subject: 'which way each pass runs',
    asked:
        'The forward pass and the backward pass go through the network in '
        'which directions?',
    network: _theNetwork,
    highlight: null,
    options: [
      'Both from the start',
      'Forward from the start, then backward from the finish',
      'Both from the finish',
      'Forward from the finish, then backward from the start',
    ],
    answer: 1,
    why:
        'Forward from the beginning, to find the earliest anything can '
        'happen, then backward from the project finish, to find the latest '
        'it can happen without pushing that finish out. Two sweeps, opposite '
        'ways, and they answer two different questions.',
    source: 'const-fb-q1',
  ),
  PassRound(
    subject: 'the forward rule at a merge',
    asked:
        'E waits on both B, which finishes on day seven, and C, which '
        'finishes on day five. What is E\'s early start?',
    network: _theNetwork,
    highlight: 'E',
    options: [
      'Day five, the earlier',
      'Day seven, the later: everything it waits on must be done',
      'Day six, the middle',
      'Day twelve, the two added',
    ],
    answer: 1,
    why:
        'Day seven. Going forward, a merge takes the LATEST of the finishes '
        'in front of it, because nothing can start until all of them are '
        'done. E then runs three days, so it finishes on day ten, with the '
        'project itself finishing on thirteen.',
    source: 'const-fb-q1',
  ),
  PassRound(
    subject: 'the backward rule at a burst',
    asked:
        'B is followed by both D, whose late start is day seven, and E, '
        'whose late start is day ten. What is B\'s late finish?',
    network: _theNetwork,
    highlight: 'B',
    options: [
      'Day ten, the later',
      'Day seven, the earlier: it has to be out of the way for BOTH',
      'Day eight and a half',
      'Day seventeen',
    ],
    answer: 1,
    why:
        'Day seven, the EARLIEST of the late starts behind it. Going '
        'backward the rule flips: an activity has to be finished in time for '
        'every one of its successors, so the most demanding of them governs. '
        'Forward takes the latest, backward takes the earliest.',
    source: 'const-fb-q3',
  ),
  PassRound(
    subject: 'what late start means',
    asked:
        'C has a late start of day eight, though it could start on day '
        'three. What does the eight mean?',
    network: _theNetwork,
    highlight: 'C',
    options: [
      'That C should be scheduled for day eight',
      'That C cannot start before day eight',
      'That starting later than day eight would push the project finish out',
      'That C takes eight days',
    ],
    answer: 2,
    why:
        'It is the last moment C can begin without the whole project '
        'finishing later. It is a limit, not a plan: starting on day three is '
        'perfectly fine and usually wiser. The gap between the two is exactly '
        'what the next lesson calls float.',
    source: 'const-fb-q2',
  ),
  PassRound(
    subject: 'where the backward pass begins',
    asked:
        'What late finish does the backward pass start from, at the last '
        'activity?',
    network: _theNetwork,
    highlight: 'D',
    options: [
      'Zero',
      'The project duration itself, thirteen days here',
      'The activity\'s own duration',
      'Whatever the owner asks for',
    ],
    answer: 1,
    why:
        'The project duration, which the forward pass has just produced. The '
        'backward pass is only meaningful with an end date to work back '
        'from, which is why the two passes always run in that order.',
    source: 'const-fb-q2',
  ),
  PassRound(
    subject: 'the subtraction going back',
    asked:
        'D has a late finish of day thirteen and takes six days. What is its '
        'late start?',
    network: _theNetwork,
    highlight: 'D',
    options: [
      'Day seven: the late finish less the duration',
      'Day nineteen: the two added',
      'Day six',
      'Day thirteen',
    ],
    answer: 0,
    why:
        'Seven. Going forward you ADD the duration to get a finish, going '
        'back you SUBTRACT it to get a start. Same duration, opposite sign, '
        'and that pair of moves is the whole mechanical content of the two '
        'passes.',
    source: 'const-fb-q2',
  ),
];

class _WhichWayThePassRunsGameState extends State<WhichWayThePassRunsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-way-the-pass-runs',
    chapterId: 'construction',
    total: passRounds.length,
    sourceProblemIdOf: (round) => passRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  PassRound get _round => passRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Way the Pass Runs',
        closing:
            'Forward from the start to find the earliest, then backward '
            'from the project finish to find the latest. Add the duration '
            'going forward, subtract it coming back. And the rule at a '
            'junction flips: the latest of what comes before, the earliest '
            'of what comes after.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: passesBrief,
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
            'TWO SWEEPS, OPPOSITE WAYS',
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
