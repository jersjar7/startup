import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'filter_figures.dart';
import 'lesson_brief.dart';

/// How Fast Through the Sand — the filter loading rate, taught here.
///
/// It is the same arithmetic as a clarifier overflow rate, which the
/// settling lesson teaches, and that is the reason the last round makes the
/// comparison explicit instead of leaving a student to assume the numbers
/// carry across. This lesson has its own problem behind it, so a student
/// who starts here meets it here.
class HowFastThroughTheSandGame extends StatefulWidget {
  const HowFastThroughTheSandGame({super.key});

  @override
  State<HowFastThroughTheSandGame> createState() => _HowFastThroughTheSandGameState();
}

@immutable
class FilterRound {
  const FilterRound({
    required this.subject,
    required this.asked,
    required this.bed,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final FilterBed bed;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own bed: twenty feet by fifteen, taking 1,350 gallons a
/// minute, which is four and a half gallons to the square foot.
const _theBed = FilterBed(length: 20, width: 15, flowGpm: 1350);

/// The same flow onto a bed twice as large.
const _biggerBed = FilterBed(length: 40, width: 15, flowGpm: 1350);

/// A slow sand bed, which runs at a fraction of the rate.
const _slowBed =
    FilterBed(length: 100, width: 60, flowGpm: 450, rapid: false);

const filterRounds = <FilterRound>[
  FilterRound(
    subject: 'what the rate is a rate of',
    asked:
        'A filter loading rate is quoted in gallons a minute per square foot. '
        'Per square foot of what?',
    bed: _theBed,
    options: [
      'Of the filter building',
      'Of the surface of the bed, looked at from above',
      'Of the pipe carrying the water',
      'Of the sand grains',
    ],
    answer: 1,
    why:
        'The plan area of the bed. The water goes straight down through the '
        'sand, so what matters is how much bed there is to go down through. '
        'Depth of sand matters for other things, and not for this rate.',
    source: 'wr-dwt-q1',
  ),
  FilterRound(
    subject: 'the arithmetic',
    asked:
        'Twenty feet by fifteen, with 1,350 gallons a minute arriving. What '
        'is the loading rate?',
    bed: _theBed,
    options: [
      '67.5 gallons a minute per foot',
      '4.5 gallons a minute per square foot',
      '300 gallons a minute per square foot',
      '90 gallons a minute per square foot',
    ],
    answer: 1,
    why:
        'Four and a half. The bed is 300 square feet, and 1,350 over 300 is '
        '4.5. The 67.5 on the list is the flow divided by one dimension '
        'instead of the area, and the units give it away: a rate per FOOT is '
        'not a rate per square foot.',
    source: 'wr-dwt-q1',
  ),
  FilterRound(
    subject: 'is that a normal number',
    asked:
        'Four and a half gallons a minute to the square foot. Is that '
        'reasonable for a rapid sand filter?',
    bed: _theBed,
    options: [
      'No, far too fast',
      'Yes: rapid sand filters usually run between about two and ten',
      'No, far too slow',
      'It cannot be judged',
    ],
    answer: 1,
    why:
        'Comfortably normal. Rapid sand filters run a few gallons a minute to '
        'the square foot, so 4.5 sits mid range. Knowing the range is what '
        'turns the arithmetic into engineering: it tells you whether the '
        'answer is a design or a mistake.',
    source: 'wr-dwt-q1',
  ),
  FilterRound(
    subject: 'a bigger bed',
    asked:
        'The same 1,350 gallons a minute goes onto a bed twice the size. What '
        'happens to the rate?',
    bed: _biggerBed,
    options: [
      'It halves, to about 2.25',
      'It doubles',
      'It is unchanged: the flow has not changed',
      'It quadruples',
    ],
    answer: 0,
    why:
        'It halves, because the same water is spread over twice the area. '
        'That is the design lever: to run a plant gently you build more bed, '
        'and to push a plant harder you accept a higher rate with shorter '
        'runs between backwashes.',
    source: 'wr-dwt-q1',
  ),
  FilterRound(
    subject: 'the other kind of filter',
    asked:
        'A slow sand filter is enormous by comparison. Why?',
    bed: _slowBed,
    options: [
      'Because the sand is coarser',
      'Because it runs at a small fraction of the rate, so it needs far more '
          'area for the same flow',
      'Because it is always outdoors',
      'Because it has no underdrains',
    ],
    answer: 1,
    why:
        'Because the rate is tiny, nearer a tenth of a gallon a minute to the '
        'square foot, so the same flow wants tens of times the area. It buys '
        'a biological layer that cleans the water with no chemicals, and pays '
        'for it in land.',
    source: 'wr-dwt-q1',
  ),
  FilterRound(
    subject: 'the sum that looks the same',
    asked:
        'A clarifier overflow rate is also a flow divided by a plan area. Is '
        'it the same quantity as this?',
    bed: _theBed,
    options: [
      'Yes: same sum, same number, same limits',
      'No: the same ARITHMETIC, but a different box, different units in '
          'practice, and a completely different acceptable range',
      'No: the clarifier one uses volume',
      'Yes, as long as both are rectangular',
    ],
    answer: 1,
    why:
        'The same shape of sum and nothing else. A clarifier overflow rate is '
        'usually quoted per day and sits near a few hundred gallons a day to '
        'the square foot; a filter runs a few gallons a MINUTE. Recognizing '
        'the pattern is useful, and carrying one range over to the other box '
        'is how a plant gets sized wrong.',
    source: 'wr-dwt-q1',
  ),
];

class _HowFastThroughTheSandGameState extends State<HowFastThroughTheSandGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-fast-through-the-sand',
    chapterId: 'water-resources',
    total: filterRounds.length,
    sourceProblemIdOf: (round) => filterRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  FilterRound get _round => filterRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Fast Through the Sand',
        closing:
            'The loading rate is the flow over the PLAN area of the bed, so '
            'a number per foot rather than per square foot is wrong before '
            'it is checked. Rapid sand runs a few gallons a minute to the '
            'square foot and slow sand a fraction of that. It is the same '
            'sum as a clarifier overflow rate and not the same number.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: filterRateBrief,
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
            'DOWN THROUGH THE BED',
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
            height: 226,
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
                  painter: FilterPainter(
                    bed: r.bed,
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
