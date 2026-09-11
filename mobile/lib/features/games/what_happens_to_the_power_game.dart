import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'pump_figures.dart';

/// What Happens to the Power — the first item for
/// `pumps-water-distribution`.
///
/// The pump power equation is a product, which makes it one of the few
/// things in this chapter where every sensitivity is plain: double any of
/// the flow, the head or the unit weight and the power doubles. The one
/// term that does not behave that way is the efficiency, because it sits
/// underneath, and the lesson's own tip is about which direction that
/// pushes: the shaft is always working harder than the water is.
class WhatHappensToThePowerGame extends StatefulWidget {
  const WhatHappensToThePowerGame({super.key});

  @override
  State<WhatHappensToThePowerGame> createState() =>
      _WhatHappensToThePowerGameState();
}

/// Which way the number the round names moves.
enum Draws { more, less, same }

extension DrawsWords on Draws {
  String get plain => switch (this) {
        Draws.more => 'A bigger number',
        Draws.less => 'A smaller number',
        Draws.same => 'Exactly the same number',
      };
}

@immutable
class DutyRound {
  const DutyRound({
    required this.subject,
    required this.change,
    required this.before,
    required this.after,
    required this.compare,
    this.against,
    required this.why,
    required this.source,
  });

  final String subject;
  final String change;
  final Duty before;
  final Duty after;

  /// Which of the three powers the round reads BEFORE the change.
  final String compare;

  /// Which one it reads after, when a round compares two different powers
  /// on one duty rather than one power across a change.
  final String? against;
  final String why;
  final String source;

  double _read(Duty d, String which) => switch (which) {
        'fluid' => d.fluidPower,
        'input' => d.inputPower,
        _ => d.shaftPower,
      };

  /// Worked out of the two readings, never declared.
  Draws get answer {
    final was = _read(before, compare);
    final now = _read(after, against ?? compare);
    if ((now - was).abs() / was < 0.001) return Draws.same;
    return now > was ? Draws.more : Draws.less;
  }
}

const dutyRounds = <DutyRound>[
  DutyRound(
    subject: 'a pump that has worn',
    change:
        'The same flow against the same head, but the pump efficiency has '
        'fallen from 80 percent to 60. What happens to the power at the '
        'shaft?',
    before: Duty(flow: 0.05, head: 30, pumpEfficiency: 0.8),
    after: Duty(flow: 0.05, head: 30, pumpEfficiency: 0.6),
    compare: 'shaft',
    why:
        'Bigger. Efficiency sits UNDERNEATH the power equation, so a worse '
        'efficiency divides by a smaller number and the shaft has to work '
        'harder for the same water delivered. Going from 0.8 to 0.6 is a '
        'third more power for nothing extra in the pipe, which is why '
        'efficiency is worth money over the life of a pump station.',
    source: 'wr-pwd-q1',
  ),
  DutyRound(
    subject: 'twice the water',
    change:
        'The same pump is run at twice the flow against the same head, at '
        'the same efficiency. What happens to the power at the shaft?',
    before: Duty(flow: 0.05, head: 30, pumpEfficiency: 0.75),
    after: Duty(flow: 0.1, head: 30, pumpEfficiency: 0.75),
    compare: 'shaft',
    why:
        'Bigger, and exactly twice. Flow is a plain multiplier in the power '
        'equation, so doubling it doubles the power. Note what this round '
        'has quietly assumed: the head stayed put. On a real system it would '
        'not, because the friction part of the head climbs with the square of '
        'the flow, and the power would go up by rather more than twice.',
    source: 'wr-pwd-q3',
  ),
  DutyRound(
    subject: 'what the water actually gets',
    change:
        'The fluid power delivered to the water, compared against the brake '
        'power at the shaft, for one pump on one duty.',
    before: Duty(flow: 0.05, head: 30, pumpEfficiency: 0.75),
    after: Duty(flow: 0.05, head: 30, pumpEfficiency: 0.75),
    compare: 'shaft',
    against: 'fluid',
    why:
        'Smaller, always. The fluid power is what ends up in the water and '
        'the brake power is what the shaft supplies, and the difference is '
        'what the pump loses to friction and turbulence inside itself. On '
        'this duty it is 14.7 kilowatts into the water and 19.6 at the '
        'shaft. Reporting the fluid power when the question asked for the '
        'brake power is the first trap the lesson names.',
    source: 'wr-pwd-q1',
  ),
  DutyRound(
    subject: 'half the water',
    change:
        'The flow is throttled back to half, at the same head and the same '
        'efficiency. What happens to the power at the shaft?',
    before: Duty(flow: 0.06, head: 40, pumpEfficiency: 0.7),
    after: Duty(flow: 0.03, head: 40, pumpEfficiency: 0.7),
    compare: 'shaft',
    why:
        'Smaller, and by half. The same plain proportion running the other '
        'way. Everything in the numerator of the power equation behaves like '
        'this, which makes rough power checks easy: if you know one duty, '
        'you know every duty that is a simple multiple of it.',
    source: 'wr-pwd-q3',
  ),
  DutyRound(
    subject: 'seawater instead of fresh',
    change:
        'The same pump moves seawater, unit weight 10,050 newtons a cubic '
        'meter rather than 9,810, at the same flow and head. What happens to '
        'the power at the shaft?',
    before: Duty(flow: 0.05, head: 30, pumpEfficiency: 0.75),
    after: Duty(
        flow: 0.05, head: 30, weight: 10050, pumpEfficiency: 0.75),
    compare: 'shaft',
    why:
        'Bigger, by about two and a half percent. The unit weight is in the '
        'numerator with everything else, so a heavier liquid takes '
        'proportionally more power to lift the same distance at the same '
        'rate. It is a small change for seawater and a large one for '
        'something like a sludge, which is why wastewater pumps are not '
        'sized off clean water numbers.',
    source: 'wr-pwd-q3',
  ),
  DutyRound(
    subject: 'a bigger motor',
    change:
        'The 20 kilowatt motor is replaced with a 40 kilowatt one. The flow, '
        'the head and both efficiencies are unchanged. What happens to the '
        'power actually drawn?',
    before: Duty(
        flow: 0.05, head: 30, pumpEfficiency: 0.75, motorEfficiency: 0.9),
    after: Duty(
        flow: 0.05, head: 30, pumpEfficiency: 0.75, motorEfficiency: 0.9),
    compare: 'input',
    why:
        'Exactly the same. A motor rating is a ceiling, not a consumption: '
        'it says what the motor can deliver without overheating, and the '
        'power actually drawn is set by the duty at the other end of the '
        'shaft. A bigger motor on the same pump doing the same work draws '
        'the same 21.8 kilowatts off the meter, and mostly it just costs '
        'more to buy.',
    source: 'wr-pwd-q1',
  ),
];

class _WhatHappensToThePowerGameState
    extends State<WhatHappensToThePowerGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-happens-to-the-power',
    chapterId: 'water-resources',
    total: dutyRounds.length,
    sourceProblemIdOf: (round) => dutyRounds[round].source,
  )..addListener(_onSession);

  Draws? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  DutyRound get _round => dutyRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Happens to the Power',
        closing:
            'Flow, head and unit weight all multiply, so doubling any of '
            'them doubles the power. Efficiency divides, so a worse '
            'efficiency means a bigger number, never a smaller one: the '
            'shaft always works harder than the water does, and the meter '
            'harder still. A motor rating is a ceiling and changes nothing '
            'about what gets drawn.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: pumpPowerBrief,
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
            'BIGGER, SMALLER, OR THE SAME',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.change,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 196,
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
                  painter: const PumpSystemPainter(above: false),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // The powers get their own strip. Inside the arrangement they
          // landed on the delivery tank.
          Container(
            height: 74,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: CustomPaint(
                painter: PowerBarPainter(
                  duty: answered ? r.after : r.before,
                  caption: answered
                      ? 'AFTER THE CHANGE'
                      : 'AS IT STANDS NOW',
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\dot W_{brake} = \dfrac{\gamma Q H}{\eta}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Draws.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Draws.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE WAY IT MOVES' : 'THE OTHER WAY',
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
