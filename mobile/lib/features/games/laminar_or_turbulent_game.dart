import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Laminar or Turbulent — the first item for `pipe-flow-head-loss`.
///
/// The Reynolds number is one division, and the lesson's problem shows what
/// actually goes wrong with it: three of its four choices are the right
/// formula with the diameter in the wrong units, and the fourth is the right
/// number read against the wrong threshold. So the rounds hand over a
/// Reynolds number and ask what it means, which is the part that decides
/// whether the next step is a formula or the Moody diagram.
class LaminarOrTurbulentGame extends StatefulWidget {
  const LaminarOrTurbulentGame({super.key});

  @override
  State<LaminarOrTurbulentGame> createState() =>
      _LaminarOrTurbulentGameState();
}

/// What a Reynolds number means for the flow.
enum Regime { laminar, between, turbulent }

extension RegimeWords on Regime {
  String get plain => switch (this) {
        Regime.laminar => 'Laminar: under 2,100',
        Regime.between => 'In between: 2,100 to 10,000',
        Regime.turbulent => 'Fully turbulent: over 10,000',
      };

  /// The regime a Reynolds number falls in, from the lesson's own
  /// thresholds.
  static Regime of(double re) {
    if (re < 2100) return Regime.laminar;
    if (re > 10000) return Regime.turbulent;
    return Regime.between;
  }
}

@immutable
class ReynoldsRound {
  const ReynoldsRound({
    required this.subject,
    required this.setting,
    required this.reynolds,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;

  /// The number itself, which the round hands over rather than asking for.
  final double reynolds;
  final String why;
  final String source;

  Regime get answer => RegimeWords.of(reynolds);
}

const reynoldsRounds = <ReynoldsRound>[
  ReynoldsRound(
    subject: 'the lesson\'s water main',
    setting:
        'Water at two meters a second in a hundred millimeter pipe works out '
        'at a Reynolds number of about 199,000.',
    reynolds: 199400,
    why:
        'Fully turbulent, by a factor of twenty over the threshold. Nearly '
        'every water pipe a civil engineer meets is here, which is worth '
        'knowing as a sense check: a Reynolds number in the hundreds or the '
        'low thousands for a water main usually means the diameter went in '
        'with the wrong units.',
    source: 'fm-pfh-q1',
  ),
  ReynoldsRound(
    subject: 'oil creeping through a narrow line',
    setting:
        'A heavy oil in a small bore line comes out at a Reynolds number of '
        '1,200.',
    reynolds: 1200,
    why:
        'Laminar, comfortably under 2,100. This matters for what comes next: '
        'the friction factor is simply 64 over the Reynolds number, so there '
        'is nothing to look up. Reaching for the Moody diagram here is the '
        'lesson\'s own warning, and it is the harder way to get the same '
        'answer.',
    source: 'fm-pfh-q1',
  ),
  ReynoldsRound(
    subject: 'somewhere in the middle',
    setting: 'A flow works out at a Reynolds number of 5,000.',
    reynolds: 5000,
    why:
        'In between, in the transitional band, where the flow cannot be '
        'relied on to be either one thing or the other. It is the least '
        'useful place to design in: the friction factor is uncertain and the '
        'flow can flip. Real systems are sized to sit well clear of it.',
    source: 'fm-pfh-q1',
  ),
  ReynoldsRound(
    subject: 'the same pipe, a tenth of the speed',
    setting:
        'The lesson\'s main again, but throttled right down. The Reynolds '
        'number falls to about 1,990.',
    reynolds: 1990,
    why:
        'Laminar, just. The Reynolds number runs in direct proportion to the '
        'speed, so cutting the flow by a hundred takes 199,000 to 1,990 and '
        'crosses both thresholds on the way. That is also the number the '
        'lesson problem offers as a wrong answer, from putting the diameter '
        'in as a millimeter.',
    source: 'fm-pfh-q1',
  ),
  ReynoldsRound(
    subject: 'a sewer running part full',
    setting:
        'A sewer flowing at half a meter a second in a 300 millimeter pipe: '
        'Reynolds about 150,000.',
    reynolds: 150000,
    why:
        'Turbulent again, and note how hard it is to get out of that band '
        'with water: the kinematic viscosity is so small that anything moving '
        'at a sensible speed in a pipe you could crawl through is deeply '
        'turbulent. Laminar flow in civil work means oil, groundwater or very '
        'fine bores.',
    source: 'fm-pfh-q1',
  ),
  ReynoldsRound(
    subject: 'right on the line',
    setting: 'A flow is computed at a Reynolds number of 2,050.',
    reynolds: 2050,
    why:
        'Laminar, by fifty. Thresholds are thresholds: this one is under '
        '2,100 and the laminar rule applies, though nobody would design '
        'anything to sit this close to a boundary. The value of knowing the '
        'two numbers is that they decide which METHOD comes next, not just '
        'what the flow is called.',
    source: 'fm-pfh-q1',
  ),
];

class _LaminarOrTurbulentGameState extends State<LaminarOrTurbulentGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'laminar-or-turbulent',
    chapterId: 'fluid-mechanics',
    total: reynoldsRounds.length,
    sourceProblemIdOf: (round) => reynoldsRounds[round].source,
  )..addListener(_onSession);

  Regime? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ReynoldsRound get _round => reynoldsRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Laminar or Turbulent',
        closing:
            'Under 2,100 is laminar and the friction factor is just 64 over '
            'the Reynolds number. Over 10,000 is fully turbulent and the '
            'factor comes off the Moody diagram. In between is transitional '
            'and nobody designs there on purpose. Water in any pipe you could '
            'crawl through is turbulent, so a small Reynolds number for a '
            'water main is usually a units mistake.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: reynoldsBrief,
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
            'WHAT IS THIS FLOW',
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
          const SizedBox(height: 16),
          Center(
            child: MathText(
              r'$Re = \dfrac{vD}{\nu}$',
              style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 16),
          for (final option in Regime.values) ...[
            _Choice(
              label: option.plain,
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
              title: _session.correct! ? 'THAT IS THE BAND' : 'NOT THAT BAND',
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
