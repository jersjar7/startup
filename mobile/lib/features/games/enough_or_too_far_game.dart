import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Enough, or Too Far — the third item for `obligations-to-the-public`.
///
/// The lesson's hard problem has three wrong answers and every one of them is
/// a reasonable-sounding thing a decent engineer might do. Voting objectively
/// is not enough. Resigning from the committee is more than anybody asked. The
/// rules ask for a specific amount of action, and both under-doing it and
/// over-doing it are ways of getting the question wrong.
///
/// So one response is put on screen at a time and the only question is whether
/// it is the right size. Three rounds share a single scenario and differ only
/// in the response, which is the fastest way to show that the facts were never
/// the difficulty.
class EnoughOrTooFarGame extends StatefulWidget {
  const EnoughOrTooFarGame({super.key});

  @override
  State<EnoughOrTooFarGame> createState() => _EnoughOrTooFarGameState();
}

enum Size3 { tooLittle, right, tooMuch }

@immutable
class ProportionRound {
  const ProportionRound({
    required this.subject,
    required this.scenario,
    required this.response,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String scenario;

  /// The one response being judged.
  final String response;
  final Size3 answer;
  final String why;
  final String source;
}

const proportionRounds = <ProportionRound>[
  ProportionRound(
    subject: 'a friend\'s firm bidding for a bridge',
    scenario:
        'You sit on a state selection committee. A firm owned by a close '
        'friend has bid for a highway bridge project, and it is well '
        'qualified.',
    response: 'Evaluate every firm objectively and vote for the best one.',
    answer: Size3.tooLittle,
    why:
        'Good intentions are not a procedure. The rule is about the appearance '
        'of influence as much as the fact of it, and nobody reading the minutes '
        'afterwards can see how objective you were being.',
    source: 'eth-otp-q3',
  ),
  ProportionRound(
    subject: 'the same bridge committee',
    scenario:
        'You sit on a state selection committee. A firm owned by a close '
        'friend has bid for a highway bridge project, and it is well '
        'qualified.',
    response:
        'Tell the committee about the friendship and step out of this '
        'selection.',
    answer: Size3.right,
    why:
        'Disclose it and step out of the one decision. That is the whole of '
        'what the rules ask for, and it leaves the committee able to work and '
        'the record able to be read.',
    source: 'eth-otp-q3',
  ),
  ProportionRound(
    subject: 'the same bridge committee',
    scenario:
        'You sit on a state selection committee. A firm owned by a close '
        'friend has bid for a highway bridge project, and it is well '
        'qualified.',
    response: 'Resign from the selection committee altogether.',
    answer: Size3.tooMuch,
    why:
        'Nothing asks for that. The conflict is with one project, not with the '
        'committee, and quitting costs the department somebody willing to '
        'notice a conflict in the first place.',
    source: 'eth-otp-q3',
  ),
  ProportionRound(
    subject: 'a concrete mix below the code minimum',
    scenario:
        'A client insists on a concrete mix below the code minimum for a '
        'parking garage, and the plans are with you for your seal.',
    response: 'Seal the plans and record the deviation in the project file.',
    answer: Size3.tooLittle,
    why:
        'The file does not carry the load. Recording a deviation is a record '
        'of the thing you should not have done, and the seal on the drawing '
        'says the design meets accepted standards when it does not.',
    source: 'eth-otp-q1',
  ),
  ProportionRound(
    subject: 'a colleague\'s error in a school report',
    scenario:
        'A colleague made a material error in a bearing capacity report for a '
        'school. You raised it with them and they dismissed it.',
    response:
        'Take it to firm management, and report to the board if they do not '
        'act.',
    answer: Size3.right,
    why:
        'The colleague has had their chance, so the firm gets the next one, '
        'and the board is what happens if the firm does not take it. Each step '
        'earns the next one.',
    source: 'eth-otp-q2',
  ),
  ProportionRound(
    subject: 'the same school report',
    scenario:
        'A colleague made a material error in a bearing capacity report for a '
        'school. You raised it with them and they dismissed it.',
    response: 'Call the school district directly, before telling management.',
    answer: Size3.tooMuch,
    why:
        'Right instinct, wrong moment. The firm has not been told and is the '
        'party that can actually reissue the report, and going over it first '
        'turns a correctable error into a fight about you.',
    source: 'eth-otp-q2',
  ),
];

class _EnoughOrTooFarGameState extends State<EnoughOrTooFarGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'enough-or-too-far',
    chapterId: 'ethics',
    total: proportionRounds.length,
    sourceProblemIdOf: (round) => proportionRounds[round].source,
  )..addListener(_onSession);

  Size3? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ProportionRound get _round => proportionRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Enough, or Too Far',
        closing:
            'The rules ask for a particular amount of action. Meaning well is '
            'not enough, and doing more than was asked is its own answer to a '
            'question nobody put. Read what the rule actually requires, and do '
            'that.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: proportionBrief,
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
            'IS THAT THE RIGHT SIZE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.scenario,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.5,
              color: AppColors.ink2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.creamDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THE PROPOSED RESPONSE',
                  style: AppTheme.overline(color: AppColors.ink3),
                ),
                const SizedBox(height: 8),
                Text(
                  r.response,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.45,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final (i, size) in Size3.values.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _SizeButton(
                    key: ValueKey('size-${size.name}'),
                    label: switch (size) {
                      Size3.tooLittle => 'Not enough',
                      Size3.right => 'What the rules ask',
                      Size3.tooMuch => 'More than this asks for',
                    },
                    selected: _picked == size,
                    locked: answered,
                    isTruth: size == r.answer,
                    onTap: answered
                        ? null
                        : () => setState(() => _picked = size),
                  ),
                ),
              ],
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THE RIGHT SIZE' : 'NOT THAT SIZE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _SizeButton extends StatelessWidget {
  const _SizeButton({
    super.key,
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
          height: 64,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.25,
              color: AppColors.charcoal,
            ),
          ),
        ),
      ),
    );
  }
}
