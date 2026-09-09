import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// What Does It Trigger — the first item for `obligations-to-the-public`.
///
/// The lesson hands over a decision tree and then warns, in its own words,
/// that the whistleblower rule has a trigger: the public has to actually be
/// endangered. An engineer who disagrees with a client about a finish has not
/// found a violation, and treating every disagreement as one is its own kind
/// of failure.
///
/// So the obligations sit in a fixed list, the same five every round, and the
/// question is which one this scenario actually sets off. One round sets off
/// nothing at all, and one round is the same situation as another at a
/// different stage, which changes the answer.
class WhatItTriggersGame extends StatefulWidget {
  const WhatItTriggersGame({super.key});

  @override
  State<WhatItTriggersGame> createState() => _WhatItTriggersGameState();
}

/// The decision tree, in the order the lesson walks it.
const duties = <(String, String)>[
  ('Refuse to seal it', 'and require a design that meets code'),
  ('Notify your employer', 'and the authority if the danger stands'),
  ('Report to the licensing board', 'the chain has already been tried'),
  ('Disclose it and step out', 'of this decision, not of the committee'),
  ('Nothing yet', 'this is a disagreement, not a violation'),
];

@immutable
class TriggerRound {
  const TriggerRound({
    required this.subject,
    required this.scenario,
    required this.answer,
    required this.rule,
    required this.why,
    required this.source,
  });

  final String subject;
  final String scenario;

  /// Which of [duties] the scenario sets off.
  final int answer;

  /// The rule it comes from, shown with the answer.
  final String rule;
  final String why;
  final String source;
}

const triggerRounds = <TriggerRound>[
  TriggerRound(
    subject: 'a parking garage on a tight budget',
    scenario:
        'The client insists on a concrete mix below the minimum compressive '
        'strength the building code requires, to stay within budget. The plans '
        'are on your desk for your seal.',
    answer: 0,
    rule: 'A.1 and A.2',
    why:
        'A seal is a statement that the design meets accepted standards. There '
        'is no version of this where the mix stays and the seal goes on, so '
        'nothing you write in the file changes what has to happen.',
    source: 'eth-otp-q1',
  ),
  TriggerRound(
    subject: 'a footing depth that was overruled',
    scenario:
        'Your recommendation to deepen the footings was overruled by the '
        'project manager on cost grounds. The building will be occupied and '
        'you believe the foundation is unsafe as designed.',
    answer: 1,
    rule: 'A.3',
    why:
        'Your judgment has been overruled and the public is at risk, which is '
        'exactly the trigger the whistleblower rule names. Telling your '
        'employer is the first half of it, and the authority is the second if '
        'the danger stands.',
    source: 'eth-otp-q1',
  ),
  TriggerRound(
    subject: 'a bearing capacity report for a school',
    scenario:
        'A colleague made a material error in a soil bearing capacity report '
        'for a school. You raised it with them and they dismissed it. You took '
        'it to management, and management has not acted.',
    answer: 2,
    rule: 'A.3 and A.8',
    why:
        'The chain has been walked and it stopped. Once the colleague and the '
        'firm have both had their chance, the obligation to report the '
        'violation to the board is what is left.',
    source: 'eth-otp-q2',
  ),
  TriggerRound(
    subject: 'a highway bridge selection committee',
    scenario:
        'You sit on your department\'s consultant selection committee. A firm '
        'owned by a close friend is bidding for the bridge project, and the '
        'firm is technically well qualified.',
    answer: 3,
    rule: 'B.6 and B.8',
    why:
        'Being qualified is not the question. Serving on a government body '
        'while a decision touches somebody you have a relationship with is the '
        'question, and the rules answer it the same way whether or not you '
        'would have been fair.',
    source: 'eth-otp-q3',
  ),
  TriggerRound(
    subject: 'a parapet detail nobody agrees on',
    scenario:
        'The client prefers a different architectural treatment on the parapet. '
        'You think yours looks better. The structure, the drainage and the fire '
        'rating are the same either way.',
    answer: 4,
    rule: 'the trigger for A.3 is not met',
    why:
        'The whistleblower rule turns on the public being endangered, and '
        'nobody is. Reaching for it over a matter of taste spends the rule\'s '
        'credibility on a question that was never yours to win.',
    source: 'eth-otp-q1',
  ),
  TriggerRound(
    subject: 'the same school report, one step earlier',
    scenario:
        'A colleague made a material error in a soil bearing capacity report '
        'for a school. You raised it with them and they dismissed it. Nobody '
        'at the firm has been told.',
    answer: 1,
    rule: 'A.3',
    why:
        'Same error, same school, one step earlier, and a different answer. '
        'The firm has not had its chance yet, and going over its head before '
        'it has is how a correct concern turns into a procedural problem of '
        'your own.',
    source: 'eth-otp-q2',
  ),
];

class _WhatItTriggersGameState extends State<WhatItTriggersGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-it-triggers',
    chapterId: 'ethics',
    total: triggerRounds.length,
    sourceProblemIdOf: (round) => triggerRounds[round].source,
  )..addListener(_onSession);

  int? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  TriggerRound get _round => triggerRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Does It Trigger',
        closing:
            'Work down the same list every time. Is the public at risk? Has '
            'the chain been walked? Is there a relationship in the room? And '
            'sometimes the honest answer is that a disagreement is only a '
            'disagreement.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: publicFirstBrief,
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
            'WHICH OBLIGATION IS THIS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.scenario,
            style: const TextStyle(
              fontSize: 15.5,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < duties.length; i++) ...[
            if (i > 0) const SizedBox(height: 7),
            _DutyRow(
              key: ValueKey('duty-$i'),
              title: duties[i].$1,
              note: duties[i].$2,
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            Text(
              'THE RULE',
              style: AppTheme.overline(color: AppColors.ink3),
            ),
            const SizedBox(height: 4),
            Text(r.rule, style: AppTheme.code(size: 13)),
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'A DIFFERENT RULE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _DutyRow extends StatelessWidget {
  const _DutyRow({
    super.key,
    required this.title,
    required this.note,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String title;

  /// Shown small under the title. It is the condition, not the answer.
  final String note;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
    }

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                note,
                style: AppTheme.mono(size: 10.5, color: AppColors.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
