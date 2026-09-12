import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'effective_stress_figures.dart';

/// Which Stress Is That — the first item for `effective-stress`.
///
/// Three stresses live at every point in the ground and a problem will ask
/// for whichever one it likes. Total is the weight of everything above.
/// Water pressure is the height of water above the point, and only below the
/// water table. Effective is what is left, and it is the one the soil
/// actually responds to, which is why the lesson is named after it.
class WhichStressIsThatGame extends StatefulWidget {
  const WhichStressIsThatGame({super.key});

  @override
  State<WhichStressIsThatGame> createState() =>
      _WhichStressIsThatGameState();
}

/// Which of the three a round is describing.
enum Stress { total, pore, effective }

@immutable
class StressRound {
  const StressRound({
    required this.subject,
    required this.asked,
    required this.deposit,
    required this.at,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Deposit deposit;
  final double at;
  final Stress answer;
  final String why;
  final String source;

  static String label(Stress which) => switch (which) {
        Stress.total => 'The total stress',
        Stress.pore => 'The water pressure in the pores',
        Stress.effective => 'The effective stress',
      };
}

const _oneLayer = Deposit(
  layers: [
    Stratum(name: 'saturated clay', thickness: 10, unitWeight: 115,
        saturated: true),
  ],
  waterDepth: 0,
);

const _twoLayers = Deposit(
  layers: [
    Stratum(name: 'dry sand', thickness: 5, unitWeight: 110),
    Stratum(name: 'saturated clay', thickness: 8, unitWeight: 120,
        saturated: true),
  ],
  waterDepth: 5,
);

const _withSurcharge = Deposit(
  layers: [
    Stratum(name: 'sand', thickness: 6, unitWeight: 105),
    Stratum(name: 'saturated clay', thickness: 10, unitWeight: 118,
        saturated: true),
  ],
  waterDepth: 6,
  surcharge: 100,
);

const stressRounds = <StressRound>[
  StressRound(
    subject: 'the weight of everything above',
    asked:
        'Which stress is the weight of every single thing above the marked '
        'point, soil and its water and anything stacked on the surface '
        'alike?',
    deposit: _oneLayer,
    at: 10,
    answer: Stress.total,
    why:
        'The total stress, and it really is everything: the grains, the water '
        'in their pores, and any load sitting on the ground. It is the '
        'easiest of the three to work out, and on its own it decides nothing '
        'about how the soil will behave.',
    source: 'geo-es-q1',
  ),
  StressRound(
    subject: 'what the grains feel',
    asked:
        'Which one is carried by the soil skeleton itself, grain pressing '
        'against grain?',
    deposit: _oneLayer,
    at: 10,
    answer: Stress.effective,
    why:
        'The effective stress, and it is the one that matters. How strong the '
        'soil is and how much it settles both follow from it and from nothing '
        'else, which is why the whole lesson is built around getting it '
        'right. The water in the pores carries its own share and passes none '
        'of it between the grains.',
    source: 'geo-es-q1',
  ),
  StressRound(
    subject: 'the height of water',
    asked:
        'Which one is the height of water above the point, times the unit '
        'weight of water?',
    deposit: _twoLayers,
    at: 13,
    answer: Stress.pore,
    why:
        'The pore water pressure. Note WHICH height: it is measured from the '
        'water table down to the point, not from the ground surface. Here '
        'that is eight feet of water and not thirteen, and using the depth '
        'below the surface instead is the single commonest arithmetic slip in '
        'the lesson.',
    source: 'geo-es-q2',
  ),
  StressRound(
    subject: 'above the water table',
    asked:
        'At a point in the dry sand, ABOVE the water table, the effective '
        'stress is equal to which one?',
    deposit: _twoLayers,
    at: 3,
    answer: Stress.total,
    why:
        'The total stress, because there is no pore pressure to take off: '
        'above the water table the water pressure is zero and the two are the '
        'same number. Subtracting the unit weight of water from a layer that '
        'sits above the water table is the mistake the lesson warns about in '
        'so many words.',
    source: 'geo-es-q2',
  ),
  StressRound(
    subject: 'what a surcharge misses',
    asked:
        'A hundred pounds a square foot is spread over the whole surface. '
        'Which of the three does it leave completely alone?',
    deposit: _withSurcharge,
    at: 16,
    answer: Stress.pore,
    why:
        'The pore water pressure. A surcharge adds its full weight to the '
        'total stress at every depth, and the water table has not moved, so '
        'the water pressure is exactly what it was. Everything the surcharge '
        'adds therefore lands on the grains, which is why a surcharge is used '
        'on purpose to squeeze a soft clay before anything is built on it.',
    source: 'geo-es-q3',
  ),
  StressRound(
    subject: 'the one that decides things',
    asked:
        'Which stress decides how much this clay will settle and how strong '
        'it is?',
    deposit: _withSurcharge,
    at: 16,
    answer: Stress.effective,
    why:
        'The effective one, again. This is the sentence the rest of the '
        'chapter is built on: consolidation, shear strength, bearing '
        'capacity, earth pressure. All of them are written in terms of what '
        'the grains feel, and none of them care what the total stress is by '
        'itself.',
    source: 'geo-es-q3',
  ),
];

class _WhichStressIsThatGameState extends State<WhichStressIsThatGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-stress-is-that',
    chapterId: 'geotechnical',
    total: stressRounds.length,
    sourceProblemIdOf: (round) => stressRounds[round].source,
  )..addListener(_onSession);

  Stress? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  StressRound get _round => stressRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Stress Is That',
        closing:
            'Total is everything above, weighed. Water pressure is the height '
            'of water above the point, measured from the WATER TABLE and not '
            'the surface, and it is zero above the table. Effective is what '
            'is left over, and it is the only one the soil responds to. A '
            'surcharge adds to the total, leaves the water alone, and so goes '
            'entirely onto the grains.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: threeStressBrief,
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
            'WHICH OF THE THREE',
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
            height: 232,
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
                  painter: DepositPainter(
                    deposit: r.deposit,
                    at: r.at,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r"$\sigma' = \sigma - u$",
              style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Stress.values) ...[
            _Choice(
              label: StressRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Stress.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'NOT THAT ONE',
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
