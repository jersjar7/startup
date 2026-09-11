import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Times or Divided — the first item for `concrete-curing-strength`.
///
/// Every problem in this lesson is one percentage applied to one number, and
/// every wrong answer in all three of them is the SAME percentage applied the
/// wrong way: multiplied when it should have been divided, or taken against
/// the leftover share instead of the one quoted. So the item never asks for
/// an answer. It asks which way the percentage goes, which is the only part
/// of the question a phone is the right place for.
class TimesOrDividedGame extends StatefulWidget {
  const TimesOrDividedGame({super.key});

  @override
  State<TimesOrDividedGame> createState() => _TimesOrDividedGameState();
}

/// The four ways a percentage gets used, one of them right.
enum Doing { times, over, timesRest, overRest }

@immutable
class StepRound {
  const StepRound({
    required this.subject,
    required this.setting,
    required this.share,
    required this.known,
    required this.wanted,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// The situation, in the words the problem uses.
  final String setting;

  /// The percentage in play, as a share, and what it belongs to.
  final double share;

  /// What is in hand and what is being asked for.
  final String known;
  final String wanted;

  final List<Doing> options;
  final Doing answer;
  final String why;
  final String source;

  String labelFor(Doing doing) {
    final rest = 1 - share;
    return switch (doing) {
      Doing.times => 'multiply by ${_num(share)}',
      Doing.over => 'divide by ${_num(share)}',
      Doing.timesRest => 'multiply by ${_num(rest)}',
      Doing.overRest => 'divide by ${_num(rest)}',
    };
  }

  static String _num(double v) => v.toStringAsFixed(2);
}

const stepRounds = <StepRound>[
  StepRound(
    subject: 'the seven day break',
    setting:
        'Cylinders broken at seven days average 2,800 psi, and seven day '
        'strength runs at about seventy percent of the twenty eight day '
        'figure.',
    share: 0.70,
    known: 'the seven day break',
    wanted: 'the twenty eight day strength',
    options: [Doing.times, Doing.over, Doing.overRest, Doing.timesRest],
    answer: Doing.over,
    why:
        'Divide. The seven day number is the SMALLER one, so the twenty eight '
        'day figure it is seventy percent OF has to be bigger: 2,800 over '
        '0.70 is 4,000. Multiplying instead gives 1,960, which is seventy '
        'percent of the seven day break and is a number with no meaning at '
        'all. Before touching the percentage, decide whether the answer '
        'should come out bigger or smaller.',
    source: 'mat-ccs-q1',
  ),
  StepRound(
    subject: 'curing cut short',
    setting:
        'Moist cured the whole time, this mix reaches 5,200 psi. Cured for '
        'only seven days and then left in air, it reaches ninety percent of '
        'that.',
    share: 0.90,
    known: 'the fully cured strength',
    wanted: 'the strength of the one cured badly',
    options: [Doing.over, Doing.times, Doing.timesRest, Doing.overRest],
    answer: Doing.times,
    why:
        'Multiply. Poor curing can only take strength away, so the answer has '
        'to come out below 5,200: ninety percent of it is 4,680. Dividing '
        'gives 5,780, which says the concrete got stronger by being cured '
        'badly. Multiplying by the leftover ten percent gives 520, which is a '
        'tenth of a slab.',
    source: 'mat-ccs-q2',
  ),
  StepRound(
    subject: 'what to expect at seven days',
    setting:
        'The slab is specified at 4,500 psi at twenty eight days, and the '
        'seven day break is due tomorrow. Seven day strength runs at seventy '
        'percent.',
    share: 0.70,
    known: 'the twenty eight day specification',
    wanted: 'the seven day break you should see',
    options: [Doing.timesRest, Doing.over, Doing.times, Doing.overRest],
    answer: Doing.times,
    why:
        'Multiply, because this one runs the other way from the first round. '
        'You have the big number and you want the small one: about 3,150 psi '
        'at seven days. The percentage never changes, only which of the two '
        'numbers you are holding, and that is what decides times or divided.',
    source: 'mat-ccs-q1',
  ),
  StepRound(
    subject: 'working back from a bad break',
    setting:
        'A poorly cured pour broke at 4,680 psi, and the specification says '
        'that curing leaves ninety percent of what the mix can do.',
    share: 0.90,
    known: 'the strength it actually reached',
    wanted: 'what the mix would have reached if cured properly',
    options: [Doing.times, Doing.overRest, Doing.over, Doing.timesRest],
    answer: Doing.over,
    why:
        'Divide, and notice it is the same pair of numbers as the second '
        'round with the question turned around. Going from the reduced figure '
        'back up to the full one undoes the multiplying, so 4,680 over 0.90 '
        'is 5,200. Same percentage, opposite operation, because what you are '
        'holding has changed.',
    source: 'mat-ccs-q2',
  ),
  StepRound(
    subject: 'the field curing factor',
    setting:
        'Mix A broke at 5,400 psi on lab cured cylinders. On site it will be '
        'cured for fourteen days, which the specification rates at a strength '
        'factor of 0.92.',
    share: 0.92,
    known: 'the lab cylinder strength',
    wanted: 'what the slab itself will reach',
    options: [Doing.over, Doing.timesRest, Doing.times, Doing.overRest],
    answer: Doing.times,
    why:
        'Multiply: the factor is a fraction of the lab strength, so the slab '
        'comes out below the cylinder at about 4,970 psi. This is the step '
        'the lesson\'s hardest problem is really testing, and the trap there '
        'is not arithmetic at all. It is comparing the LAB numbers to the '
        'specification and never applying the factor.',
    source: 'mat-ccs-q3',
  ),
  StepRound(
    subject: 'what the cylinder must have been',
    setting:
        'A core taken from a slab came out at 3,910 psi, and that curing is '
        'rated at eighty five percent of lab cured strength.',
    share: 0.85,
    known: 'the strength in the slab',
    wanted: 'the lab strength the mix is capable of',
    options: [Doing.timesRest, Doing.times, Doing.overRest, Doing.over],
    answer: Doing.over,
    why:
        'Divide: 3,910 over 0.85 is 4,600, which is the lab figure that mix '
        'was good for. The rule that survives all six of these rounds is '
        'plain. Going toward the SMALLER number multiplies, going back to the '
        'bigger one divides, and the percentage itself never tells you which.',
    source: 'mat-ccs-q3',
  ),
];

class _TimesOrDividedGameState extends State<TimesOrDividedGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'times-or-divided',
    chapterId: 'materials',
    total: stepRounds.length,
    sourceProblemIdOf: (round) => stepRounds[round].source,
  )..addListener(_onSession);

  Doing? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  StepRound get _round => stepRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Times or Divided',
        closing:
            'One percentage, two directions. Going toward the smaller number '
            'multiplies and coming back to the bigger one divides, so decide '
            'whether the answer should be bigger or smaller before you touch '
            'the number. And the percentage you were given is the one to use: '
            'the leftover share belongs to a different question.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: curingBrief,
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
            'WHICH WAY DOES THE PERCENTAGE GO',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.setting,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOU HAVE',
                  style: AppTheme.overline(color: AppColors.ink3),
                ),
                const SizedBox(height: 4),
                Text(
                  r.known,
                  style: const TextStyle(
                      fontSize: 14.5, color: AppColors.charcoal),
                ),
                const SizedBox(height: 10),
                Text(
                  'YOU WANT',
                  style: AppTheme.overline(color: AppColors.ember),
                ),
                const SizedBox(height: 4),
                Text(
                  r.wanted,
                  style: const TextStyle(
                      fontSize: 14.5, color: AppColors.charcoal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: MathText(
              r'$\text{what you want} = \text{what you have} \; ?$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in r.options) ...[
            _Choice(
              label: r.labelFor(option),
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
              title: _session.correct! ? 'THAT IS THE WAY' : 'THE OTHER WAY',
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
            style: AppTheme.mono(size: 14, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
