import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'earthwork_figures.dart';
import 'lesson_brief.dart';

/// How Many Yards — the first item for `earthwork`.
///
/// The surveying chapter asks which formula gives more and why. This
/// lesson asks the question a highway estimator asks: how many cubic YARDS
/// of cut and fill, which means both formulas and then the conversion the
/// lesson warns about.
class HowManyYardsGame extends StatefulWidget {
  const HowManyYardsGame({super.key});

  @override
  State<HowManyYardsGame> createState() => _HowManyYardsGameState();
}

@immutable
class YardRound {
  const YardRound({
    required this.subject,
    required this.asked,
    required this.haul,
    this.compareMiddle = false,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Haul haul;

  /// Whether to draw the line the middle section is compared against.
  final bool compareMiddle;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own pair of sections: two hundred and three hundred square
/// feet, a hundred feet apart, with a middle section of two hundred and
/// forty.
const _theRun = Haul(slabs: [
  Slab(station: 1000, area: 200),
  Slab(station: 1050, area: 240),
  Slab(station: 1100, area: 300),
]);

/// Its deeper cut: a hundred and fifty to three hundred and fifty over two
/// hundred feet, with two hundred and thirty in the middle.
const _theCut = Haul(slabs: [
  Slab(station: 1200, area: 150),
  Slab(station: 1300, area: 230),
  Slab(station: 1400, area: 350),
]);

const yardRounds = <YardRound>[
  YardRound(
    subject: 'what the quantity is paid in',
    asked:
        'The sections are in square feet and the stations in feet, so the '
        'volume comes out in cubic feet. What does the estimate want?',
    haul: _theRun,
    options: [
      'Cubic feet, as calculated',
      'Cubic yards: divide by twenty seven',
      'Cubic yards: divide by three',
      'Tons',
    ],
    answer: 1,
    why:
        'Cubic yards, and a cubic yard is three feet each way, so twenty '
        'seven cubic feet. Dividing by three instead is the commonest slip '
        'and leaves the answer nine times too big. Earthwork is bid, hauled '
        'and paid for in yards, so the conversion is not optional bookwork.',
    source: 'trans-ew-q1',
  ),
  YardRound(
    subject: 'the simple way, in yards',
    asked:
        'Two hundred and three hundred square feet, a hundred feet apart, '
        'by the average end area method. How many cubic yards?',
    haul: _theRun,
    options: [
      '25,000, which is the figure in cubic feet',
      '1,852 cubic yards',
      '926 cubic yards',
      '250 cubic yards',
    ],
    answer: 2,
    why:
        'About 926. The average of the two ends is 250 square feet, times a '
        'hundred feet is 25,000 cubic feet, over twenty seven is 926 yards. '
        'The 25,000 on the list is the same answer left in feet, and the '
        '1,852 is what you get by forgetting to average the two ends.',
    source: 'trans-ew-q1',
  ),
  YardRound(
    subject: 'the more careful way',
    asked:
        'The middle section is 240 square feet. What does the prismoidal '
        'formula give for the same run?',
    haul: _theRun,
    compareMiddle: true,
    options: [
      '926 cubic yards, the same',
      '901 cubic yards: a little less, because the middle sags below the '
          'average of the ends',
      '5,407 cubic yards',
      '1,852 cubic yards',
    ],
    answer: 1,
    why:
        'About 901, a shade under the simpler answer. The average of the two '
        'ends is 250 and the real middle is 240, so the run is slightly '
        'thinner in the middle than a straight taper would be, and the '
        'prismoidal formula notices.',
    source: 'trans-ew-q2',
  ),
  YardRound(
    subject: 'which one a contractor would rather use',
    asked:
        'On this run the end area method gives more than the prismoidal. '
        'Who does that favor?',
    haul: _theRun,
    compareMiddle: true,
    options: [
      'Whoever gets paid by the yard hauled',
      'The owner',
      'Neither: the difference is never large enough to matter',
      'It depends on the weather',
    ],
    answer: 0,
    why:
        'Whoever is paid by the yard. The difference here is only about three '
        'per cent, but on a corridor with millions of yards in it, three per '
        'cent is real money, which is why the contract says which method '
        'measures the work rather than leaving it to whoever holds the '
        'pencil.',
    source: 'trans-ew-q2',
  ),
  YardRound(
    subject: 'a deeper cut',
    asked:
        'This cut runs 150 to 350 square feet over two hundred feet, with 230 '
        'in the middle. Prismoidally, in yards?',
    haul: _theCut,
    compareMiddle: true,
    options: [
      '1,852 cubic yards',
      '1,753 cubic yards',
      '47,333 cubic yards',
      '500 cubic yards',
    ],
    answer: 1,
    why:
        'About 1,753. The 1,852 is the end area answer for the same cut, '
        'which is higher because the real middle, 230, sags well below the '
        'average of the ends, 250. The 47,333 is the volume in cubic feet '
        'with the conversion forgotten.',
    source: 'trans-ew-q3',
  ),
  YardRound(
    subject: 'why a highway needs the numbers at all',
    asked:
        'What are these volumes actually for, on a highway job?',
    haul: _theCut,
    options: [
      'Setting the speed limit',
      'Pricing the cut and the fill, and deciding where the cut material can '
          'be hauled to',
      'Choosing the pavement thickness',
      'Checking the sight distance',
    ],
    answer: 1,
    why:
        'Money and haulage. Every station pair gives a cut or a fill '
        'quantity, and the whole corridor of them decides what is excavated, '
        'what is imported, and how far the material travels. A grade line '
        'that balances cut against fill is cheaper than one that does not, '
        'and these volumes are how that is judged.',
    source: 'trans-ew-q3',
  ),
];

class _HowManyYardsGameState extends State<HowManyYardsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-many-yards',
    chapterId: 'transportation',
    total: yardRounds.length,
    sourceProblemIdOf: (round) => yardRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  YardRound get _round => yardRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Many Yards',
        closing:
            'Both formulas work in whatever units go in, so feet and '
            'square feet give cubic FEET, and a quantity is paid in cubic '
            'yards: divide by twenty seven, not by three. The end area '
            'method gives the larger number whenever the real middle '
            'section sags below the average of the two ends, and on a long '
            'corridor that difference is money.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: yardsBrief,
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
            'CUT AND FILL, IN YARDS',
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
            height: 216,
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
                  painter: HaulPainter(
                    haul: r.haul,
                    showEndAverage: r.compareMiddle,
                    locked: answered,
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
