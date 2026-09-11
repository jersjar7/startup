import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'aggregate_figures.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Which Weighing — the first item for `aggregate-properties`.
///
/// Three weighings come off one aggregate sample and four different numbers
/// are built from them, all of which look alike on the page and none of which
/// mean the same thing. Both of this lesson's specific gravity and absorption
/// problems are lost in exactly that: the right subtraction under the wrong
/// weight. So the three states are drawn, with the pores empty, full, and
/// under water, and the round asks which expression belongs to the number
/// being asked for.
class WhichWeighingGame extends StatefulWidget {
  const WhichWeighingGame({super.key});

  @override
  State<WhichWeighingGame> createState() => _WhichWeighingGameState();
}

/// The four numbers this lesson builds out of three weighings.
enum Recipe { bulkDry, bulkSsd, apparent, absorption }

extension RecipeParts on Recipe {
  String get tex => switch (this) {
        Recipe.bulkDry => r'$\dfrac{A}{B - C}$',
        Recipe.bulkSsd => r'$\dfrac{B}{B - C}$',
        Recipe.apparent => r'$\dfrac{A}{A - C}$',
        Recipe.absorption => r'$\dfrac{B - A}{A} \times 100$',
      };

  String get plain => switch (this) {
        Recipe.bulkDry => 'bulk oven dry specific gravity',
        Recipe.bulkSsd => 'bulk SSD specific gravity',
        Recipe.apparent => 'apparent specific gravity',
        Recipe.absorption => 'absorption',
      };
}

@immutable
class WeighRound {
  const WeighRound({
    required this.subject,
    required this.asked,
    required this.sample,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What is wanted, said in words rather than by its name where possible.
  final String asked;
  final Sample sample;
  final List<Recipe> options;
  final Recipe answer;
  final String why;
  final String source;
}

/// The lesson's own coarse aggregate: 480 dry, 500 saturated, 300 submerged.
const _lesson = Sample(dry: 480, ssd: 500, submerged: 300);

/// Its absorption sample, which is the other problem's numbers.
const _sand = Sample(dry: 500, ssd: 510, submerged: 310);

const weighRounds = <WeighRound>[
  WeighRound(
    subject: 'the lesson\'s coarse aggregate',
    asked:
        'You want the bulk specific gravity on an oven dry basis. Which one '
        'is it?',
    sample: _lesson,
    options: [
      Recipe.bulkDry,
      Recipe.bulkSsd,
      Recipe.apparent,
      Recipe.absorption
    ],
    answer: Recipe.bulkDry,
    why:
        'Dry weight on top, and underneath the SSD weight less the submerged '
        'weight. That subtraction is the water the whole particle pushed out '
        'of the way, pores included, which is why it is called BULK. Here it '
        'is 480 over 200, so 2.40.',
    source: 'mat-agg-q3',
  ),
  WeighRound(
    subject: 'water the pores will steal',
    asked:
        'The mix designer needs to know how much mix water this aggregate '
        'will soak up. Which one is that?',
    sample: _sand,
    options: [
      Recipe.apparent,
      Recipe.absorption,
      Recipe.bulkDry,
      Recipe.bulkSsd
    ],
    answer: Recipe.absorption,
    why:
        'Absorption: the water that fits in the pores, as a share of the DRY '
        'mass. Dividing by B instead, which is the sample with the water '
        'already in it, is this problem\'s named trap and gives 1.96 where '
        'the answer is 2.0. Batch this aggregate dry and it takes that much '
        'water back out of the mix.',
    source: 'mat-agg-q1',
  ),
  WeighRound(
    subject: 'the same sample, saturated',
    asked:
        'Now you want the bulk specific gravity on a saturated surface dry '
        'basis. Which one is it?',
    sample: _lesson,
    options: [
      Recipe.absorption,
      Recipe.apparent,
      Recipe.bulkSsd,
      Recipe.bulkDry
    ],
    answer: Recipe.bulkSsd,
    why:
        'The same volume underneath, since the particle has not changed size, '
        'and the SSD weight on top instead of the dry one. That is all that '
        'separates the two bulk gravities: which state you weighed the solid '
        'in. This one is 500 over 200, so 2.50.',
    source: 'mat-agg-q3',
  ),
  WeighRound(
    subject: 'leaving the pores out',
    asked:
        'You want the specific gravity of the solid part only, with the water '
        'filled pores left out of the volume. Which one is it?',
    sample: _lesson,
    options: [
      Recipe.bulkSsd,
      Recipe.bulkDry,
      Recipe.absorption,
      Recipe.apparent
    ],
    answer: Recipe.apparent,
    why:
        'The apparent one, which subtracts C from A rather than from B. Using '
        'the dry weight at both ends leaves out the water sitting in the '
        'pores, so the volume it measures is only the solid. It comes to 2.67 '
        'here, and picking it when the question asked for bulk is the lesson '
        'problem\'s other named wrong answer.',
    source: 'mat-agg-q3',
  ),
  WeighRound(
    subject: 'a lab report to check',
    asked:
        'A technician has written the absorption as the water divided by the '
        'saturated weight. Tap what it should have been.',
    sample: _sand,
    options: [
      Recipe.bulkDry,
      Recipe.absorption,
      Recipe.bulkSsd,
      Recipe.apparent
    ],
    answer: Recipe.absorption,
    why:
        'Over A, the dry mass, not over B. Every property on this page is '
        'quoted against the DRY aggregate, because that is the one state you '
        'can reproduce exactly: a sample can be more or less wet in a '
        'thousand ways, and there is only one way to be oven dry.',
    source: 'mat-agg-q1',
  ),
  WeighRound(
    subject: 'which of them is biggest',
    asked:
        'For any real aggregate with pores in it, one of these always comes '
        'out the largest. Which?',
    sample: _lesson,
    options: [
      Recipe.absorption,
      Recipe.bulkDry,
      Recipe.apparent,
      Recipe.bulkSsd
    ],
    answer: Recipe.apparent,
    why:
        'The apparent one, because it divides by the smallest volume: the '
        'solid alone, with the pores excluded. Bulk oven dry is the smallest '
        'of the three gravities and apparent the largest, with bulk SSD in '
        'between. That ordering is worth knowing as a check: an answer out of '
        'that order means the wrong subtraction went underneath.',
    source: 'mat-agg-q3',
  ),
];

class _WhichWeighingGameState extends State<WhichWeighingGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-weighing',
    chapterId: 'materials',
    total: weighRounds.length,
    sourceProblemIdOf: (round) => weighRounds[round].source,
  )..addListener(_onSession);

  Recipe? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  WeighRound get _round => weighRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Weighing',
        closing:
            'Three weighings, four numbers. B minus C is the whole particle, '
            'pores and all, which is what makes a gravity BULK. A minus C '
            'leaves the pores out, which makes it apparent, and it always '
            'comes out the largest. Absorption is the water the pores hold '
            'over the DRY mass, never over the wet one.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: weighingBrief,
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
            'WHICH ONE IS IT',
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
          EngineeringGrid(
            minor: 18,
            major: 90,
            child: SizedBox(
              height: 190,
              width: double.infinity,
              child: CustomPaint(
                painter: SamplePainter(sample: r.sample),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'the same stone three times: pores empty, pores full, and in water',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          for (final option in r.options) ...[
            _Choice(
              tex: option.tex,
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
              title: _session.correct!
                  ? 'THAT IS ${r.answer.plain.toUpperCase()}'
                  : 'THAT IS ${_picked!.plain.toUpperCase()}',
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
    required this.tex,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String tex;
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: MathText(
            tex,
            style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
