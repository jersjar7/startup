import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'compaction_figures.dart';
import 'lesson_brief.dart';

/// Which Measure Is It — the second item for `compaction-stabilization`.
///
/// Two numbers both report how well packed a soil is and they are not the
/// same measure. Relative compaction compares a field density against a
/// laboratory maximum. Relative density compares an in-place void ratio
/// against the loosest and densest that soil can be got into, and it is for
/// clean sands and gravels. The lesson's warning is not to mix them.
class WhichMeasureIsItGame extends StatefulWidget {
  const WhichMeasureIsItGame({super.key});

  @override
  State<WhichMeasureIsItGame> createState() => _WhichMeasureIsItGameState();
}

@immutable
class PackingRound {
  const PackingRound({
    required this.subject,
    required this.asked,
    required this.soil,
    this.applies = true,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Granular soil;

  /// False on the round whose soil is a clay, which this scale does not
  /// describe.
  final bool applies;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own sand: loosest 0.90, densest 0.40, in place 0.60, which
/// is 60 per cent and medium dense.
const _theSand = Granular(loosest: 0.90, densest: 0.40, inPlace: 0.60);

/// A sand left almost as loose as it will sit.
const _looseSand = Granular(loosest: 0.90, densest: 0.40, inPlace: 0.82);

const packingRounds = <PackingRound>[
  PackingRound(
    subject: 'which soils it is for',
    asked: 'Relative density is the right measure for which soils?',
    soil: _theSand,
    options: [
      'Any soil at all',
      'Clean sands and gravels',
      'High-plasticity clays',
      'Only soils below the water table',
    ],
    answer: 1,
    why:
        'Clean sands and gravels. A clay does not have a meaningful loosest '
        'and densest packing to measure between, and its behavior is about '
        'water and plasticity rather than how the grains sit. Clay fills are '
        'checked with relative compaction against a Proctor instead.',
    source: 'geo-cmp-q2',
  ),
  PackingRound(
    subject: 'the two ends of the scale',
    asked: 'What do the two ends of this scale represent?',
    soil: _theSand,
    options: [
      'The wettest and driest the sand can be',
      'The strongest and weakest sands there are',
      'The loosest and tightest packings this sand can be put into in a '
          'laboratory',
      'Zero and one hundred per cent saturation',
    ],
    answer: 2,
    why:
        'The loosest and tightest that this particular sand can be got into, '
        'both measured in the laboratory as void ratios. Everything in the '
        'field sits somewhere between them, and relative density is just how '
        'far along it is.',
    source: 'geo-cmp-q2',
  ),
  PackingRound(
    subject: 'reading it off the scale',
    asked:
        'This sand sits closer to its tightest packing than to its loosest. '
        'Is its relative density above or below fifty per cent?',
    soil: _theSand,
    options: [
      'Above fifty',
      'Below fifty',
      'Exactly fifty',
      'It depends on the unit weight',
    ],
    answer: 0,
    why:
        'Above. Relative density is measured from the LOOSE end, so a sand '
        'that has been packed most of the way toward its tightest state '
        'scores high. Reading the scale first and the formula second is the '
        'way to catch an answer that came out the wrong way round.',
    source: 'geo-cmp-q2',
  ),
  PackingRound(
    subject: 'which difference goes on top',
    asked:
        'For this sand the formula gives 60 per cent. Another student gets 40 '
        'per cent. Which mistake gives that?',
    soil: _theSand,
    options: [
      'Using the in-place void ratio against the tightest, rather than the '
          'loosest, on top',
      'Forgetting to multiply by a hundred',
      'Swapping the loosest and tightest on the bottom',
      'Using unit weights instead of void ratios',
    ],
    answer: 0,
    why:
        'Measuring from the wrong end. The two answers always add to a '
        'hundred, which is what gives the slip away: 60 and 40 here. The top '
        'of the fraction starts at the LOOSE void ratio, so that a low void '
        'ratio, which means a tightly packed soil, gives a high number.',
    source: 'geo-cmp-q2',
  ),
  PackingRound(
    subject: 'a sand that has hardly been touched',
    asked:
        'This sand is in place at a void ratio close to its loosest. What '
        'does that say about it?',
    soil: _looseSand,
    options: [
      'It is dense and will settle little',
      'It is loose, and liable to settle or to lose strength when shaken',
      'It is at its optimum moisture',
      'It has been over-compacted',
    ],
    answer: 1,
    why:
        'Loose, and that is the state engineers worry about: loose clean '
        'sands settle under load and can lose their strength altogether in an '
        'earthquake. It is exactly the condition ground improvement is meant '
        'to fix, and the reason relative density gets specified at all.',
    source: 'geo-cmp-q2',
  ),
  PackingRound(
    subject: 'two measures, one fill',
    asked:
        'A clay fill is being placed and checked. Which measure does the '
        'inspector use?',
    soil: _theSand,
    applies: false,
    options: [
      'Relative density, against the loosest and tightest packings',
      'Relative compaction, against a Proctor maximum for that clay',
      'Either: they give the same number',
      'Neither: clay fills are not tested',
    ],
    answer: 1,
    why:
        'Relative compaction, against a Proctor run on that same clay. The '
        'two measures answer the same sort of question and are not '
        'interchangeable: they compare against different things and their '
        'formulas share no terms. Mixing them is the lesson\'s own warning.',
    source: 'geo-cmp-q1',
  ),
];

class _WhichMeasureIsItGameState extends State<WhichMeasureIsItGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-measure-is-it',
    chapterId: 'geotechnical',
    total: packingRounds.length,
    sourceProblemIdOf: (round) => packingRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  PackingRound get _round => packingRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Measure Is It',
        closing:
            'Relative compaction is a field density over a laboratory '
            'maximum, and it suits any soil that has a Proctor test. '
            'Relative density is for clean sands and gravels and asks how far '
            'between the loosest and tightest packings the soil sits, '
            'measured from the loose end. Different references, different '
            'formulas, and no terms in common.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: relativeDensityBrief,
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
            'HOW WELL PACKED',
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
            height: 200,
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
                  painter: PackingPainter(
                    soil: r.soil,
                    applies: r.applies,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.options.length; i++) ...[
            _Choice(
              label: r.options[i],
              selected: _picked == i,
              locked: answered,
              isTruth: r.answer == i,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            if (i != r.options.length - 1) const SizedBox(height: 8),
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
