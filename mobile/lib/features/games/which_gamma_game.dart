import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'phase_figures.dart';

/// Which Gamma — the third item for `phase-relations`.
///
/// One soil carries four unit weights and a problem will name whichever one
/// it feels like. They are not interchangeable and they come in a fixed
/// order: dry is lightest because the water has been taken off the weight
/// side, saturated is heaviest because every void is full, the sample as it
/// stands is somewhere between, and submerged is smallest of all because the
/// water outside is holding some of the weight up.
class WhichGammaGame extends StatefulWidget {
  const WhichGammaGame({super.key});

  @override
  State<WhichGammaGame> createState() => _WhichGammaGameState();
}

/// Which of the four unit weights a round is asking for.
enum Gamma { dry, total, saturated, submerged }

@immutable
class GammaRound {
  const GammaRound({
    required this.subject,
    required this.asked,
    required this.soil,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Soil soil;
  final Gamma answer;
  final String why;
  final String source;

  static String label(Gamma which) => switch (which) {
        Gamma.dry => 'The dry unit weight',
        Gamma.total => 'The unit weight as the sample stands',
        Gamma.saturated => 'The saturated unit weight',
        Gamma.submerged => 'The submerged unit weight',
      };
}

const gammaRounds = <GammaRound>[
  GammaRound(
    subject: 'the heaviest of them',
    asked:
        'For one soil at one void ratio, which of the four is the largest '
        'number?',
    soil: Soil(gs: 2.65, water: 0.15, voidRatio: 0.586),
    answer: Gamma.saturated,
    why:
        'Saturated. Same solids, same volume, but every void now holds water '
        'instead of air, and water weighs something while air does not. '
        'Nothing about the soil skeleton has changed: the sample has simply '
        'had its empty spaces filled.',
    source: 'geo-pr-q3',
  ),
  GammaRound(
    subject: 'the lightest of them',
    asked: 'And which is the smallest?',
    soil: Soil(gs: 2.65, water: 0.15, voidRatio: 0.586),
    answer: Gamma.submerged,
    why:
        'Submerged, and by a long way: it is the saturated weight less the '
        'weight of water, which knocks about 62 pounds a cubic foot off. It '
        'is what the soil is worth once buoyancy has taken its share, and it '
        'is the one to use below the water table. Using the total weight down '
        'there overstates the stress badly.',
    source: 'geo-pr-q3',
  ),
  GammaRound(
    subject: 'weighed, then dried, then weighed again',
    asked:
        'A sample is weighed as it comes out of the ground, dried in an oven, '
        'and weighed again. The second weight, divided by the ORIGINAL '
        'volume, gives which one?',
    soil: Soil(gs: 2.70, water: 0.20, voidRatio: 0.54),
    answer: Gamma.dry,
    why:
        'The dry unit weight. Note the volume: it is the volume the sample '
        'had in the ground, not whatever it shrank to in the oven. Dry unit '
        'weight is a way of describing how tightly the solids are packed, '
        'which is why compaction is specified in terms of it and never in '
        'terms of the wet weight.',
    source: 'geo-pr-q2',
  ),
  GammaRound(
    subject: 'what the lab actually hands you',
    asked:
        'A sample is weighed as it comes out of the ground and its volume '
        'measured, with nothing dried and nothing soaked. That gives which '
        'one?',
    soil: Soil(gs: 2.70, water: 0.20, voidRatio: 0.54),
    answer: Gamma.total,
    why:
        'The total unit weight, the soil as it stands with whatever water '
        'happened to be in it. It is the easiest to measure and the least '
        'useful to compare, because it moves with the weather. Dividing it by '
        'one plus the water content is the usual first step of a phase '
        'problem, and it lands you on the dry weight.',
    source: 'geo-pr-q2',
  ),
  GammaRound(
    subject: 'below the water table',
    asked:
        'Working out the effective stress at a depth well below the water '
        'table, which unit weight multiplies the depth of soil under it?',
    soil: Soil(gs: 2.72, water: 0.263, voidRatio: 0.714),
    answer: Gamma.submerged,
    why:
        'The submerged one. Below the water table the grains are floating in '
        'their own pore water, so the stress they actually pass to each other '
        'grows at the submerged rate, roughly half the saturated one. This is '
        'the single most useful thing on this card, and the next lesson is '
        'built on it.',
    source: 'geo-pr-q3',
  ),
  GammaRound(
    subject: 'a sample with no air left',
    asked:
        'A sample is already fully saturated when it is weighed as it comes '
        'out of the ground. Its weight as it stands is equal to which other '
        'one?',
    soil: Soil(gs: 2.72, water: 0.263, voidRatio: 0.714),
    answer: Gamma.saturated,
    why:
        'The saturated weight and the weight as it stands are the same, '
        'because standing is saturated for this sample. Worth seeing once: '
        'the four are not four different soils, they are four questions about '
        'one, and two of them collide whenever the voids are already full.',
    source: 'geo-pr-q3',
  ),
];

class _WhichGammaGameState extends State<WhichGammaGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-gamma',
    chapterId: 'geotechnical',
    total: gammaRounds.length,
    sourceProblemIdOf: (round) => gammaRounds[round].source,
  )..addListener(_onSession);

  Gamma? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  GammaRound get _round => gammaRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Gamma',
        closing:
            'One soil, four unit weights, in a fixed order. Dry is the solids '
            'alone over the volume they occupy in the ground. Saturated is '
            'the heaviest, with every void full. The sample as it stands sits '
            'between them, and moves with the weather. Submerged is smallest, '
            'the saturated weight less the weight of water, and it is the one '
            'the ground works with below the water table.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: gammaBrief,
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
            'WHICH UNIT WEIGHT',
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
            height: 148,
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
                  painter: UnitWeightPainter(soil: r.soil, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r"$\gamma_d = \frac{\gamma}{1+\omega}, \quad "
              r"\gamma' = \gamma_{sat} - \gamma_w$",
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Gamma.values) ...[
            _Choice(
              label: GammaRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Gamma.values.last) const SizedBox(height: 8),
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
