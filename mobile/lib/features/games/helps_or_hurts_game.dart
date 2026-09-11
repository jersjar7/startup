import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'pump_figures.dart';

/// Helps or Hurts — the second item for `pumps-water-distribution`.
///
/// NPSH available is a margin, not a quantity anyone cares about on its own:
/// it is how much pressure head the water has left above the point where it
/// would boil at the pump inlet. Every term in it either adds to that margin
/// or takes from it, and the lesson's own trap is a sign: the static suction
/// term is NEGATIVE when the pump stands above the water, which is the
/// commonest arrangement and the one that gets a pump into trouble.
class HelpsOrHurtsGame extends StatefulWidget {
  const HelpsOrHurtsGame({super.key});

  @override
  State<HelpsOrHurtsGame> createState() => _HelpsOrHurtsGameState();
}

/// What the thing named does to the margin against cavitation.
enum Helps { helps, hurts, neither }

extension HelpsWords on Helps {
  String get plain => switch (this) {
        Helps.helps => 'It adds to the margin',
        Helps.hurts => 'It eats into the margin',
        Helps.neither => 'It does not come into it at all',
      };
}

@immutable
class MarginRound {
  const MarginRound({
    required this.subject,
    required this.piece,
    required this.above,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// The part of the arrangement the round names, which the drawing picks
  /// out in ember.
  final Piece3 piece;

  /// Whether the pump is drawn above the water it draws from.
  final bool above;
  final Helps answer;
  final String why;
  final String source;
}

const marginRounds = <MarginRound>[
  MarginRound(
    subject: 'the air on the water',
    piece: Piece3.air,
    above: true,
    answer: Helps.helps,
    why:
        'It adds. Atmospheric pressure is what pushes water up the suction '
        'pipe in the first place, and at sea level it is worth about 10.3 '
        'meters of head. It is the only term in NPSH available with a plus '
        'sign in front of it that does not depend on where the pump is, and '
        'everything else in the equation is spending it.',
    source: 'wr-pwd-q2',
  ),
  MarginRound(
    subject: 'a pump standing above the water',
    piece: Piece3.lift,
    above: true,
    answer: Helps.hurts,
    why:
        'It eats into it, and this is the sign the lesson warns about. When '
        'the pump is above the water it draws from, the static suction head '
        'is NEGATIVE: the water has to be lifted before it even reaches the '
        'inlet, and every meter of that lift comes straight off the margin. '
        'Three meters of lift takes three meters of the ten the atmosphere '
        'gave you.',
    source: 'wr-pwd-q2',
  ),
  MarginRound(
    subject: 'a pump standing below the water',
    piece: Piece3.flooded,
    above: false,
    answer: Helps.helps,
    why:
        'It adds. A flooded suction turns the same term positive: the water '
        'standing above the inlet is pressing it in rather than having to be '
        'lifted to reach it. This is why a pump that keeps cavitating gets '
        'lowered, or the sump raised, before anything more expensive is '
        'tried.',
    source: 'wr-pwd-q2',
  ),
  MarginRound(
    subject: 'friction on the way in',
    piece: Piece3.suctionLine,
    above: true,
    answer: Helps.hurts,
    why:
        'It eats into it. Every foot of head lost to friction in the SUCTION '
        'line is pressure the water no longer has when it arrives at the '
        'impeller. It is why suction pipework is drawn short, straight and a '
        'size larger than the discharge: the losses there cost twice, once in '
        'pumping and once in margin.',
    source: 'wr-pwd-q2',
  ),
  MarginRound(
    subject: 'warm water',
    piece: Piece3.warmth,
    above: true,
    answer: Helps.hurts,
    why:
        'It eats into it, and quickly. Warm water boils at a lower pressure, '
        'so its vapor pressure head is higher, and that term is subtracted. '
        'Cold water might be 0.24 meters; water at 60 degrees is nearer 2. A '
        'pump that ran happily all winter can cavitate on the same duty in '
        'summer, and nothing about the pipework changed.',
    source: 'wr-pwd-q2',
  ),
  MarginRound(
    subject: 'a longer run on the far side',
    piece: Piece3.dischargeLine,
    above: true,
    answer: Helps.neither,
    why:
        'It does not come into it. NPSH available is about the SUCTION side '
        'only: what the water has left when it reaches the impeller eye. '
        'Adding pipe after the pump raises the head the pump has to deliver '
        'and so raises the power it draws, which matters, but it does '
        'nothing to the margin against cavitation. Two different questions '
        'about the same pump.',
    source: 'wr-pwd-q2',
  ),
];

class _HelpsOrHurtsGameState extends State<HelpsOrHurtsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'helps-or-hurts',
    chapterId: 'water-resources',
    total: marginRounds.length,
    sourceProblemIdOf: (round) => marginRounds[round].source,
  )..addListener(_onSession);

  Helps? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  MarginRound get _round => marginRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Helps or Hurts',
        closing:
            'NPSH available is the margin the water has left before it '
            'boils at the pump inlet. The atmosphere adds to it and so does '
            'water standing above the pump. A suction lift, friction in the '
            'suction line, and the vapor pressure of the water all take from '
            'it, and warm water takes a great deal. Anything on the '
            'discharge side belongs to a different question entirely.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: npshBrief,
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
            'DOES IT HELP OR HURT THE MARGIN',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            'NPSH available is how much head the water has left above '
            'boiling when it reaches the pump. What does ${r.piece.plain} do '
            'to it?',
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 236,
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
                  painter: PumpSystemPainter(
                    above: r.above,
                    highlight: r.piece,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$NPSH_A = H_{pa} + H_s - \sum h_L - H_{vp}$',
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Helps.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Helps.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHAT IT DOES' : 'THE OTHER WAY',
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
