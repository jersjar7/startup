import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// More In Than Out — the third item for `work-energy-power`.
///
/// The lesson's middle problem is a power calculation with one extra step at
/// the end, and its named trap is stopping before that step or taking it the
/// wrong way round. A machine always takes in more than it gives out, so the
/// input is the output DIVIDED by the efficiency, and the two are never the
/// same number.
///
/// The arithmetic is one multiply and one divide. Which way round they go, and
/// which of the two numbers a question is asking for, is the part worth a
/// phone.
class MoreInThanOutGame extends StatefulWidget {
  const MoreInThanOutGame({super.key});

  @override
  State<MoreInThanOutGame> createState() => _MoreInThanOutGameState();
}

/// What to do with the number you have.
enum Step { divideByEta, multiplyByEta, forceTimesSpeed, workOverTime }

extension StepWords on Step {
  String get plain => switch (this) {
        Step.divideByEta => 'Divide it by the efficiency',
        Step.multiplyByEta => 'Multiply it by the efficiency',
        Step.forceTimesSpeed => 'Multiply the force by the speed',
        Step.workOverTime => 'Divide the energy by the time',
      };
}

@immutable
class PowerRound {
  const PowerRound({
    required this.subject,
    required this.setting,
    required this.asked,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final String asked;

  /// The steps on offer for this round, in the order they are shown.
  final List<Step> options;

  final Step answer;
  final String why;
  final String source;
}

const powerRounds = <PowerRound>[
  PowerRound(
    subject: 'the pump in this lesson',
    setting:
        'A pump is lifting water at a useful rate of 9.81 kilowatts and is '
        'eighty percent efficient.',
    asked: 'What do you do to get the power the MOTOR has to supply?',
    options: [Step.multiplyByEta, Step.divideByEta, Step.forceTimesSpeed],
    answer: Step.divideByEta,
    why:
        'Divide, which makes the answer BIGGER: twelve point three kilowatts '
        'to deliver nine point eight one. A machine is never a hundred percent '
        'efficient, so the motor always has to put in more than the water '
        'gets, and the losses are the difference. Multiplying instead gives '
        'seven point eight five, which is less than the useful power, and that '
        'is the named trap in this problem.',
    source: 'dyn-wep-q2',
  ),
  PowerRound(
    subject: 'the same pump, the other way round',
    setting:
        'A twelve kilowatt motor drives a pump that is eighty percent '
        'efficient.',
    asked: 'What do you do to get the useful power reaching the WATER?',
    options: [Step.divideByEta, Step.multiplyByEta, Step.workOverTime],
    answer: Step.multiplyByEta,
    why:
        'Multiply, which makes it smaller: about nine point six kilowatts of '
        'the twelve reach the water. Same machine and same efficiency as the '
        'last round, and the operation flipped because the question flipped. '
        'The useful power is always the smaller of the two numbers, and that '
        'is the check worth making on whichever answer you get.',
    source: 'dyn-wep-q2',
  ),
  PowerRound(
    subject: 'a truck at a steady speed',
    setting:
        'A truck holds twenty five meters a second against four thousand '
        'newtons of drag and rolling resistance. It is neither speeding up nor '
        'climbing.',
    asked: 'What do you do to get the power it needs?',
    options: [Step.forceTimesSpeed, Step.workOverTime, Step.divideByEta],
    answer: Step.forceTimesSpeed,
    why:
        'Force times speed, a hundred kilowatts, and no calculus in sight. '
        'This is the one line version of power the lesson points at: when '
        'something moves steadily against a force, the rate it is doing work '
        'at is just that force times how fast it is going.',
    source: 'dyn-wep-q2',
  ),
  PowerRound(
    subject: 'a crane lifting a load',
    setting:
        'A crane raises a two tonne load twelve meters, and it takes forty '
        'seconds.',
    asked: 'What do you do to get the average power?',
    options: [Step.workOverTime, Step.forceTimesSpeed, Step.multiplyByEta],
    answer: Step.workOverTime,
    why:
        'The energy it gave the load, its weight times the height, divided by '
        'how long it took. Force times speed would get you there too, since '
        'the speed is the height over the time, and the two are the same '
        'statement: power is work per second either way you write it.',
    source: 'dyn-wep-q2',
  ),
  PowerRound(
    subject: 'a motor rated at its input',
    setting:
        'A catalogue lists a motor as fifteen kilowatts, which is what it '
        'draws, and ninety percent efficient.',
    asked: 'What do you do to get the power it can actually deliver?',
    options: [Step.multiplyByEta, Step.divideByEta, Step.workOverTime],
    answer: Step.multiplyByEta,
    why:
        'Multiply: thirteen and a half kilowatts out of the fifteen it draws. '
        'The habit worth building is reading which of the two a number IS '
        'before deciding what to do with it. Rated input means multiply to get '
        'out; a required output means divide to get in.',
    source: 'dyn-wep-q2',
  ),
  PowerRound(
    subject: 'a winch pulling at a steady speed',
    setting:
        'A winch pulls a sled along the ground at half a meter a second '
        'against a steady drag of six thousand newtons. The winch itself is '
        'seventy percent efficient, and you want the power at the input.',
    asked: 'What is the FIRST thing to do?',
    options: [Step.forceTimesSpeed, Step.divideByEta, Step.multiplyByEta],
    answer: Step.forceTimesSpeed,
    why:
        'Work out the useful power first: force times speed, three kilowatts '
        'at the sled. THEN divide by the efficiency for the input, which comes '
        'to about four point three. Two steps and they have an order, and '
        'doing the efficiency first to a number that is not yet a power is how '
        'this gets muddled.',
    source: 'dyn-wep-q2',
  ),
];

class _MoreInThanOutGameState extends State<MoreInThanOutGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'more-in-than-out',
    chapterId: 'dynamics',
    total: powerRounds.length,
    sourceProblemIdOf: (round) => powerRounds[round].source,
  )..addListener(_onSession);

  Step? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  PowerRound get _round => powerRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'More In Than Out',
        closing:
            'A machine always takes in more than it gives out, so the input is '
            'the output divided by the efficiency and the output is the input '
            'times it. Read which of the two you were handed before you pick '
            'the operation. And power itself is force times speed, or work '
            'over time, which are the same sentence twice.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: powerBrief,
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
            'WHICH STEP DOES THIS NEED',
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
          const SizedBox(height: 10),
          Text(
            r.asked,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: MathText(
              r'$P = Fv, \quad \eta = \dfrac{P_{out}}{P_{in}}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 14),
          for (final step in r.options) ...[
            _Choice(
              label: step.plain,
              selected: _picked == step,
              locked: answered,
              isTruth: step == r.answer,
              onTap: answered ? null : () => setState(() => _picked = step),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 8),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE STEP' : 'THE OTHER WAY',
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
