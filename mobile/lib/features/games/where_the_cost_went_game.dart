import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'depreciation_figures.dart';
import 'lesson_brief.dart';

/// Where the Cost Went — the second item for
/// `depreciation-taxation-inflation`.
///
/// Book value is a subtraction and both of its named traps are other parts of
/// the same subtraction: handing in the accumulated depreciation, which is the
/// opposite end of it, and subtracting only the current year instead of every
/// year so far.
///
/// So the whole cost is drawn as a bar with a slice bitten out for each year,
/// and three stretches of it are bracketed underneath. The brackets are named
/// by the YEARS they cover rather than by what they mean, because knowing
/// which stretch answers the question is the thing being asked. Three rounds
/// want the book value, two want everything written off so far, and one wants
/// a single year.
class WhereTheCostWentGame extends StatefulWidget {
  const WhereTheCostWentGame({super.key});

  @override
  State<WhereTheCostWentGame> createState() => _WhereTheCostWentGameState();
}

/// The three stretches of an asset's cost anybody ever asks about.
enum Part { soFar, thisYear, left }

@immutable
class CostRound {
  const CostRound({
    required this.subject,
    required this.asset,
    required this.cost,
    required this.recovery,
    required this.through,
    required this.ask,
    required this.order,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asset;
  final double cost;

  /// Which MACRS column the asset is on.
  final int recovery;

  /// How many years of depreciation have been taken.
  final int through;

  /// What the round wants.
  final Part ask;

  /// The order the three stretches are drawn in, so that the answer is not
  /// always the same bracket down the board.
  final List<Part> order;

  final String why;
  final String source;

  List<double> get factors => macrsFactors[recovery]!;

  /// Where each stretch starts and ends, worked out from the life rather than
  /// typed in beside it.
  (int, int) rangeOf(Part part) => switch (part) {
        Part.soFar => (1, through),
        Part.thisYear => (through, through),
        Part.left => (through + 1, factors.length),
      };

  List<(int, int)> get spans => [for (final p in order) rangeOf(p)];

  int get answer => order.indexOf(ask);

  String get question => switch (ask) {
        Part.soFar => 'How much of the cost has been written off by the end of '
            'year $through?',
        Part.thisYear => 'What is the deduction for year $through on its own?',
        Part.left => 'What is the book value at the end of year $through?',
      };
}

const costRounds = <CostRound>[
  CostRound(
    subject: 'a concrete batch plant',
    asset:
        'The plant cost 500,000 dollars and went on the books as seven year '
        'property. Three years have been closed out.',
    cost: 500000,
    recovery: 7,
    through: 3,
    ask: Part.left,
    order: [Part.soFar, Part.thisYear, Part.left],
    why:
        'Book value is what has NOT been written off yet, so it is the stretch '
        'to the right of where the schedule has got to. The 281,350 above it '
        'is the accumulated depreciation, which is the same subtraction read '
        'from the wrong end, and it is the answer most people hand in.',
    source: 'econ-dti-q2',
  ),
  CostRound(
    subject: 'survey equipment',
    asset:
        'Sixty thousand dollars of survey equipment, five year property, two '
        'years in.',
    cost: 60000,
    recovery: 5,
    through: 2,
    ask: Part.soFar,
    order: [Part.thisYear, Part.soFar, Part.left],
    why:
        'Everything claimed so far is every year up to now added together, not '
        'the current year on its own. The 19,200 is a big enough slice by '
        'itself to look like an answer, which is exactly why the question is '
        'worth asking twice.',
    source: 'econ-dti-q1',
  ),
  CostRound(
    subject: 'a survey truck',
    asset:
        'A 120,000 dollar truck, five year property, with four years of '
        'depreciation taken.',
    cost: 120000,
    recovery: 5,
    through: 4,
    ask: Part.left,
    order: [Part.left, Part.soFar, Part.thisYear],
    why:
        'A little over twenty thousand, from two years of schedule that have '
        'not happened yet. Four years of MACRS have already taken eighty-two '
        'percent of the cost off the books, which is what front-loading looks '
        'like once it has run a while.',
    source: 'econ-dti-q2',
  ),
  CostRound(
    subject: 'a rough terrain crane',
    asset:
        'The crane cost 200,000 dollars and is seven year property. It is in '
        'its second year.',
    cost: 200000,
    recovery: 7,
    through: 2,
    ask: Part.thisYear,
    order: [Part.soFar, Part.left, Part.thisYear],
    why:
        'One year, on its own, and on a MACRS schedule the second year is the '
        'largest one there is. What goes on this year\'s tax return is this '
        'year\'s slice, and the running total belongs on the balance sheet '
        'instead.',
    source: 'econ-dti-q1',
  ),
  CostRound(
    subject: 'field laptops',
    asset:
        'Forty thousand dollars of laptops, three year property, two years '
        'closed out.',
    cost: 40000,
    recovery: 3,
    through: 2,
    ask: Part.left,
    order: [Part.thisYear, Part.left, Part.soFar],
    why:
        'Under nine thousand left on the books, after two years of a schedule '
        'that runs to four. Three year property is written off over four '
        'years, so the stretch still standing covers years three and four '
        'rather than year three alone.',
    source: 'econ-dti-q2',
  ),
  CostRound(
    subject: 'a wheel loader',
    asset:
        'A 250,000 dollar loader, five year property, with five years taken. '
        'It has years of work left in it and would sell tomorrow.',
    cost: 250000,
    recovery: 5,
    through: 5,
    ask: Part.soFar,
    order: [Part.left, Part.thisYear, Part.soFar],
    why:
        'Ninety-four percent of the cost is gone and one year of schedule is '
        'left. What the loader would fetch has nothing to do with any of these '
        'numbers: MACRS ignores salvage and runs the book value to zero, which '
        'is why book value is not a market value.',
    source: 'econ-dti-q2',
  ),
];

class _WhereTheCostWentGameState extends State<WhereTheCostWentGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'where-the-cost-went',
    chapterId: 'economics',
    total: costRounds.length,
    sourceProblemIdOf: (round) => costRounds[round].source,
  )..addListener(_onSession);

  int? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  CostRound get _round => costRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Where the Cost Went',
        closing:
            'The cost is one bar and the schedule eats it from the left. What '
            'is left standing is the book value, everything behind it added up '
            'is the accumulated depreciation, and one slice is one year\'s '
            'deduction. Three different questions, three different stretches '
            'of the same picture.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final spans = r.spans;

    return BoardShell(
      session: _session,
      brief: bookValueBrief,
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
            'TAP THE STRETCH THAT ANSWERS IT',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.asset,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.emberBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              r.question,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: AppColors.charcoal,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Bar(
            round: r,
            spans: spans,
            picked: _picked,
            locked: answered,
            onTap: answered ? null : (i) => setState(() => _picked = i),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT STRETCH' : 'ANOTHER STRETCH',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.round,
    required this.spans,
    required this.picked,
    required this.locked,
    required this.onTap,
  });

  final CostRound round;
  final List<(int, int)> spans;
  final int? picked;
  final bool locked;
  final void Function(int)? onTap;

  @override
  Widget build(BuildContext context) {
    const barBlock = 40.0;
    const rowHeight = 34.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: SpentBarPainter.heightOf(spans.length) + 12,
        width: double.infinity,
        child: EngineeringGrid(
          minor: 18,
          major: 90,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: SpentBarPainter(
                      cost: round.cost,
                      factors: round.factors,
                      through: round.through,
                      spans: spans,
                      selected: picked,
                      locked: locked,
                      truth: round.answer,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                for (var i = 0; i < spans.length; i++)
                  Positioned(
                    key: ValueKey('stretch-$i'),
                    left: 0,
                    right: 0,
                    top: barBlock + i * rowHeight,
                    height: rowHeight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onTap == null ? null : () => onTap!(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
