import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'phase_figures.dart';

/// Over What — the first item for `phase-relations`.
///
/// Every index property in the lesson is one part of the sample divided by
/// another, and the arithmetic is trivial once you know WHICH two. The
/// trouble is that they do not all use the same side of the phase diagram or
/// the same denominator: water content is a ratio of WEIGHTS while void
/// ratio, porosity and saturation are ratios of VOLUMES, and void ratio
/// divides by the solids while porosity divides by the whole sample.
class OverWhatGame extends StatefulWidget {
  const OverWhatGame({super.key});

  @override
  State<OverWhatGame> createState() => _OverWhatGameState();
}

/// What the bottom of the ratio is.
enum Under { solids, voids, whole, water }

@immutable
class RatioRound2 {
  const RatioRound2({
    required this.subject,
    required this.asked,
    required this.soil,
    required this.over,
    required this.under,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Soil soil;

  /// What the drawing marks once the round is over.
  final Phase over;
  final Phase under;
  final Under answer;
  final String why;
  final String source;

  static String label(Under which) => switch (which) {
        Under.solids => 'Over the solids',
        Under.voids => 'Over the voids',
        Under.whole => 'Over the whole sample',
        Under.water => 'Over the water',
      };
}

const overRounds = <RatioRound2>[
  RatioRound2(
    subject: 'the void ratio',
    asked:
        'The void ratio is the volume of the voids divided by what?',
    soil: Soil(gs: 2.70, water: 0.20, voidRatio: 0.54),
    over: Phase.voids,
    under: Phase.solids,
    answer: Under.solids,
    why:
        'Over the SOLIDS, and that is the one worth carrying: the void ratio '
        'is the odd one out because its denominator is not the whole sample. '
        'It is written that way on purpose. Squeeze a soil and the voids '
        'shrink while the solids do not, so dividing by the solids gives a '
        'number whose bottom half never moves.',
    source: 'geo-pr-q1',
  ),
  RatioRound2(
    subject: 'the porosity',
    asked:
        'Porosity is the same volume of voids divided by what?',
    soil: Soil(gs: 2.70, water: 0.20, voidRatio: 0.54),
    over: Phase.voids,
    under: Phase.whole,
    answer: Under.whole,
    why:
        'Over the WHOLE sample, which is what makes it different from the '
        'void ratio even though the top of the fraction is identical. '
        'Porosity can therefore never reach one, while a void ratio happily '
        'passes it: a soft clay can have more void than solid. If a number '
        'over one turns up, it is a void ratio.',
    source: 'geo-pr-q1',
  ),
  RatioRound2(
    subject: 'the water content',
    asked:
        'Water content is the weight of the water divided by what?',
    soil: Soil(gs: 2.70, water: 0.20, voidRatio: 0.54),
    over: Phase.water,
    under: Phase.solids,
    answer: Under.solids,
    why:
        'Over the weight of the SOLIDS, not the weight of the whole sample. '
        'Two things are going on here and both catch people: it is the only '
        'index property in the lesson taken from the WEIGHT side of the '
        'diagram, and its denominator is the solids, which is why water '
        'content can be well over 100 per cent in a soft clay.',
    source: 'geo-pr-q2',
  ),
  RatioRound2(
    subject: 'the degree of saturation',
    asked:
        'Saturation is the volume of the water divided by what?',
    soil: Soil(gs: 2.70, water: 0.15, voidRatio: 0.586),
    over: Phase.water,
    under: Phase.voids,
    answer: Under.voids,
    why:
        'Over the VOIDS: saturation asks how much of the space available to '
        'water has water in it. That is why it stops at 100 per cent, and why '
        'full saturation means the air block has been squeezed out of the '
        'diagram altogether rather than the sample having become heavier.',
    source: 'geo-pr-q2',
  ),
  RatioRound2(
    subject: 'which side of the diagram',
    asked:
        'Three of the four properties so far are ratios of volumes. Which one '
        'is not?',
    soil: Soil(gs: 2.65, water: 0.15, voidRatio: 0.586),
    over: Phase.water,
    under: Phase.solids,
    answer: Under.solids,
    why:
        'Water content, the odd one out, taken from the weights. This is why '
        'the master relationship exists at all: Se equals w times Gs is the '
        'bridge between the volume side and the weight side, and the specific '
        'gravity is what carries you across. Every phase problem is a walk '
        'between those two columns.',
    source: 'geo-pr-q2',
  ),
  RatioRound2(
    subject: 'the dry unit weight',
    asked:
        'Dry unit weight is the weight of the SOLIDS divided by what?',
    soil: Soil(gs: 2.72, water: 0.263, voidRatio: 0.714),
    over: Phase.solids,
    under: Phase.whole,
    answer: Under.whole,
    why:
        'Over the whole volume, voids included. Dry unit weight does not mean '
        'the soil has been dried out and shrunk: it means the water has been '
        'taken off the weight side while the sample keeps the volume it '
        'actually has in the ground. Dividing by the volume of solids instead '
        'would give something quite different and quite useless.',
    source: 'geo-pr-q3',
  ),
];

class _OverWhatGameState extends State<OverWhatGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'over-what',
    chapterId: 'geotechnical',
    total: overRounds.length,
    sourceProblemIdOf: (round) => overRounds[round].source,
  )..addListener(_onSession);

  Under? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  RatioRound2 get _round => overRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Over What',
        closing:
            'Every index property is one part of the sample over another, and '
            'the denominators differ on purpose. Void ratio is over the '
            'solids, so it can pass one. Porosity is the same voids over the '
            'whole sample, so it cannot. Saturation is water over the voids. '
            'And water content is the odd one out, a ratio of WEIGHTS over '
            'the solids, which is why the specific gravity has to carry you '
            'between the two sides of the diagram.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: phaseBrief,
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
            'WHAT IS ON THE BOTTOM',
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
            height: 224,
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
                  painter: PhaseDiagramPainter(
                    soil: r.soil,
                    over: r.over,
                    under: r.under,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // The definitions are the answers, so they only appear once the
          // round is over.
          if (answered)
            Center(
              child: MathText(
                r'$e = \frac{V_v}{V_s}, \quad n = \frac{V_v}{V}, \quad '
                r'\omega = \frac{W_w}{W_s}$',
                style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
              ),
            ),
          const SizedBox(height: 12),
          for (final option in Under.values) ...[
            _Choice(
              label: RatioRound2.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Under.values.last) const SizedBox(height: 8),
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
