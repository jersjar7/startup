import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// In What Order — the second item for `obligations-to-the-public`.
///
/// The lesson's medium problem is an escalation question and its own worked
/// steps spell the ladder out: the colleague, then the firm, then the board.
/// Every wrong answer on that problem is a real action taken at the wrong
/// moment, which is what makes it hard. Nobody fails it by not caring.
///
/// So four actions are on the board and three of them get taken, in order.
/// The fourth is one nobody should take at all, and leaving it alone is half
/// the answer. One round inverts the ladder, because imminent danger does not
/// wait for a chain of command.
class InWhatOrderGame extends StatefulWidget {
  const InWhatOrderGame({super.key});

  @override
  State<InWhatOrderGame> createState() => _InWhatOrderGameState();
}

@immutable
class LadderRound {
  const LadderRound({
    required this.subject,
    required this.scenario,
    required this.actions,
    required this.order,
    required this.never,
    required this.why,
    required this.source,
  });

  final String subject;
  final String scenario;

  /// Four actions, in the order they sit on the board.
  final List<String> actions;

  /// Indices into [actions], first to last.
  final List<int> order;

  /// The one that is never taken, and why not.
  final String never;
  final String why;
  final String source;
}

const ladderRounds = <LadderRound>[
  LadderRound(
    subject: 'a colleague\'s error in a school report',
    scenario:
        'A colleague made a material error in a soil bearing capacity report '
        'for a school building, and it has already gone to the client.',
    actions: [
      'Report it to the licensing board',
      'Raise it with the colleague directly',
      'Post an anonymous warning on a public forum',
      'Take it to the firm\'s management',
    ],
    order: [1, 3, 0],
    never:
        'A public forum reaches everyone except the people who can fix it, and '
        'it is not a channel the rules recognise.',
    why:
        'The colleague first, because they may simply not have seen it. Then '
        'the firm, which has both the standing and the obligation to correct '
        'its own work. The board is what is left when neither acts.',
    source: 'eth-otp-q2',
  ),
  LadderRound(
    subject: 'a concrete mix below the code minimum',
    scenario:
        'The client wants a cheaper mix than the code allows for a parking '
        'garage, and the plans are with you for your seal.',
    actions: [
      'Refuse to seal the plans',
      'Seal the plans with a disclaimer limiting your liability',
      'Notify the building authority if the client proceeds anyway',
      'Tell the client the design has to meet code',
    ],
    order: [3, 0, 2],
    never:
        'A disclaimer moves paperwork around. It does not move concrete, and '
        'the garage is no safer for having one.',
    why:
        'Say it before you refuse, because the client may not know. Refuse '
        'when they insist, because a seal is a statement you would be making. '
        'And the authority hears about it only if the work goes ahead.',
    source: 'eth-otp-q1',
  ),
  LadderRound(
    subject: 'a friend\'s firm bidding for a bridge',
    scenario:
        'You are on the selection committee for a highway bridge, and a firm '
        'owned by a close friend has bid for it.',
    actions: [
      'Tell the committee about the friendship',
      'Let the remaining members score the bids',
      'Step out of this selection',
      'Recommend the firm, since it is well qualified',
    ],
    order: [0, 2, 1],
    never:
        'Recommending them is the thing the rule exists to prevent, and the '
        'firm being good at its job is not a defence.',
    why:
        'Disclose before you recuse, or the recusal is a gap in the record '
        'that nobody can read. Then step out of this decision only, and let '
        'the committee get on with it without you.',
    source: 'eth-otp-q3',
  ),
  LadderRound(
    subject: 'an unbraced scaffold on an occupied site',
    scenario:
        'You are on site and the scaffold on the east elevation is visibly '
        'unbraced. Crews go up at seven tomorrow morning.',
    actions: [
      'Raise it at the weekly safety meeting',
      'Stop the work on that elevation now',
      'Notify the authority if it is not corrected',
      'Tell the site superintendent',
    ],
    order: [1, 3, 2],
    never:
        'The weekly meeting is after the crews go up. A schedule is not a '
        'reason and a calendar is not a channel.',
    why:
        'Imminent danger inverts the ladder. You stop it first and explain '
        'afterwards, because the chain of command is a way of getting things '
        'fixed and not a reason to let somebody fall.',
    source: 'eth-otp-q1',
  ),
  LadderRound(
    subject: 'an error in a drawing you sealed yourself',
    scenario:
        'You find an error in a drawing you sealed. The building is already '
        'under construction.',
    actions: [
      'Issue a corrected drawing',
      'Notify the building authority if the work has passed that stage',
      'Tell your employer immediately',
      'Correct it quietly on the next revision',
    ],
    order: [2, 0, 1],
    never:
        'A quiet correction is a bet that nobody built to the old sheet, and '
        'it is not yours to make on somebody else\'s behalf.',
    why:
        'The ladder does not change because the error is yours. Your employer '
        'first, then the corrected sheet so there is something to build to, '
        'then the authority if the wrong thing is already standing.',
    source: 'eth-otp-q2',
  ),
  LadderRound(
    subject: 'a retaining wall the client has overruled you on',
    scenario:
        'The client has overruled your judgment on a retaining wall and you '
        'believe the design as instructed endangers the public.',
    actions: [
      'Notify the building authority',
      'Resign from the job and say nothing',
      'Put your objection to the client in writing',
      'Notify your employer',
    ],
    order: [2, 3, 0],
    never:
        'Walking away leaves the wall exactly where it was and takes the one '
        'person who understood the problem off the project.',
    why:
        'In writing first, so the objection exists somewhere other than a '
        'conversation. Then your employer, who carries the firm\'s share of '
        'this. Then the authority, which is the point of the rule.',
    source: 'eth-otp-q1',
  ),
];

class _InWhatOrderGameState extends State<InWhatOrderGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'in-what-order',
    chapterId: 'ethics',
    total: ladderRounds.length,
    sourceProblemIdOf: (round) => ladderRounds[round].source,
  )..addListener(_onSession);

  /// The actions taken, in the order they were tapped.
  final _taken = <int>[];

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  LadderRound get _round => ladderRounds[_session.round];

  void _tap(int i) {
    setState(() {
      if (_taken.contains(i)) {
        _taken.remove(i);
      } else if (_taken.length < 3) {
        _taken.add(i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'In What Order',
        closing:
            'Closest party first, then up the chain, and the authority when '
            'the chain runs out. The exception is imminent danger, which stops '
            'the work before anything else happens. And one action on every '
            'board is one nobody should take.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final ok = _taken.length == r.order.length &&
        List.generate(r.order.length, (i) => _taken[i] == r.order[i])
            .every((x) => x);

    return BoardShell(
      session: _session,
      brief: escalationBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(_taken.clear);
              _session.next();
            }
          : (_taken.length != 3
                ? null
                : () => _session.submit(ok: ok, context: context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TAP THE THREE, IN ORDER',
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
            'one of the four is not taken at all',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < r.actions.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _StepRow(
              key: ValueKey('step-$i'),
              text: r.actions[i],
              step: _taken.indexOf(i),
              rightStep: answered ? r.order.indexOf(i) : -1,
              locked: answered,
              onTap: answered ? null : () => _tap(i),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            Text(
              'THE ONE NOBODY TAKES',
              style: AppTheme.overline(color: AppColors.ink3),
            ),
            const SizedBox(height: 4),
            Text(
              r.never,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'IN THAT ORDER' : 'NOT THAT ORDER',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    super.key,
    required this.text,
    required this.step,
    required this.rightStep,
    required this.locked,
    required this.onTap,
  });

  final String text;

  /// Where the student put this one, or minus one if they left it alone.
  final int step;

  /// Where it actually belongs, once the answer is in. Minus one for the
  /// action nobody takes.
  final int rightStep;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    if (locked && rightStep >= 0) {
      // Once it is answered the rows show the RIGHT sequence, numbered, in
      // green. Marking a row red for being in the wrong place would leave the
      // student staring at the correct answer in the colour of a mistake.
      border = AppColors.forest;
      fill = AppColors.forestBg;
    } else if (locked && step >= 0) {
      // Taken, and it was the one nobody takes.
      border = AppColors.error;
      fill = AppColors.errorBg;
    } else if (step >= 0) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
    }

    final badge = locked
        ? (rightStep >= 0 ? '${rightStep + 1}' : (step >= 0 ? 'x' : ''))
        : (step >= 0 ? '${step + 1}' : '');

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badge.isEmpty ? null : border,
                  border: Border.all(
                    color: badge.isEmpty ? AppColors.line : border,
                  ),
                ),
                child: Text(
                  badge,
                  style: AppTheme.mono(size: 12, color: AppColors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.35,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
