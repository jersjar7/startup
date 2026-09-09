import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'cross_figures.dart';
import 'lesson_brief.dart';
import 'vector_figures.dart';

/// Which Region — the second item for `cross-product-applications`.
///
/// The hard problem in this lesson is a triangular plot and its named trap is
/// handing in the parallelogram, because the cross product's magnitude is the
/// parallelogram and a triangle is half of it. That factor of two is not a
/// fact anybody forgets on purpose; it is a fact nobody pictures. So the
/// question arrives as three little drawings of the same two edges with
/// different parts shaded, and the answer is the shape rather than the
/// number. The third card is the box around the whole thing, which is what
/// multiplying the two lengths without the sine would give you.
class WhichRegionGame extends StatefulWidget {
  const WhichRegionGame({super.key});

  @override
  State<WhichRegionGame> createState() => _WhichRegionGameState();
}

@immutable
class RegionRound {
  const RegionRound({
    required this.ask,
    required this.formula,
    required this.u,
    required this.v,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String ask;

  /// The quantity being asked about, written the way the handbook writes it.
  final String formula;
  final Vec u;
  final Vec v;
  final Region answer;
  final String why;
  final String source;
}

const regionRounds = <RegionRound>[
  RegionRound(
    ask: 'The magnitude of the cross product is the area of which region?',
    formula: r'|\vec{u} \times \vec{v}|',
    u: Vec(4, 0),
    v: Vec(2, 3),
    answer: Region.parallelogram,
    why:
        'The parallelogram, always. The two edges and their two copies close '
        'it up, and the cross product measures exactly that much ground.',
    source: 'math-cpa-q3',
  ),
  RegionRound(
    ask: 'A plot is bounded by these two edges and the line joining them. '
        'Which region do you hand in?',
    formula: r'\tfrac{1}{2}|\vec{u} \times \vec{v}|',
    u: Vec(4, 0),
    v: Vec(2, 3),
    answer: Region.triangle,
    why:
        'Half the parallelogram, which is the triangle. This is the whole '
        'trap on the surveying problem: the cross product hands you twice the '
        'plot and it is on you to halve it.',
    source: 'math-cpa-q3',
  ),
  RegionRound(
    ask: 'Which region has area equal to the two lengths times the sine of '
        'the angle between them?',
    formula: r'|\vec{u}||\vec{v}|\sin\theta',
    u: Vec(5, 1),
    v: Vec(1, 4),
    answer: Region.parallelogram,
    why:
        'That expression IS the magnitude of the cross product, written the '
        'other way round, so it is the parallelogram again. The sine is what '
        'takes the lean into account.',
    source: 'math-cpa-q3',
  ),
  RegionRound(
    ask: 'Which region would the two lengths multiplied together give, with '
        'no sine anywhere?',
    formula: r'|\vec{u}||\vec{v}|',
    u: Vec(5, 1),
    v: Vec(1, 4),
    answer: Region.rectangle,
    why:
        'A box, and only a box. Dropping the sine pretends the two edges meet '
        'at a right angle, and it overstates the area of every plot that is '
        'not actually square.',
    source: 'math-cpa-q3',
  ),
  RegionRound(
    ask: 'These edges span 12 square meters between them. Which region is '
        'that?',
    formula: r'|\vec{u} \times \vec{v}| = 12',
    u: Vec(4, 0),
    v: Vec(2, 3),
    answer: Region.parallelogram,
    why:
        'Four across crossed with two across and three up gives twelve, and '
        'twelve is the parallelogram. The plot on the exam paper was six.',
    source: 'math-cpa-q3',
  ),
  RegionRound(
    ask: 'Same two edges. Which region is 6 square meters?',
    formula: r'\tfrac{1}{2}|\vec{u} \times \vec{v}| = 6',
    u: Vec(4, 0),
    v: Vec(2, 3),
    answer: Region.triangle,
    why:
        'The triangle, and the number the question actually wanted. Twelve is '
        'sitting right there in the working, which is why it is the wrong '
        'answer people pick.',
    source: 'math-cpa-q3',
  ),
];

class _WhichRegionGameState extends State<WhichRegionGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-region',
    chapterId: 'mathematics',
    total: regionRounds.length,
    sourceProblemIdOf: (round) => regionRounds[round].source,
  )..addListener(_onSession);

  Region? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  RegionRound get _round => regionRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Region',
        closing:
            'The cross product measures the parallelogram. A triangle is half '
            'of it, and the two lengths multiplied without the sine are a box '
            'that is too big. Which one you hand in is decided by the '
            'question, not the formula.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: areaBrief,
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
            'THE SAME TWO EDGES, THREE WAYS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.ask,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: MathBlock(r.formula, fontSize: 18),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final region in Region.values) ...[
                if (region != Region.values.first) const SizedBox(width: 8),
                Expanded(
                  child: _RegionCard(
                    key: ValueKey('region-${region.name}'),
                    region: region,
                    u: r.u,
                    v: r.v,
                    selected: _picked == region,
                    locked: answered,
                    isTruth: r.answer == region,
                    onTap: answered
                        ? null
                        : () => setState(() => _picked = region),
                  ),
                ),
              ],
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT SHAPE' : 'NOT THAT SHAPE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _RegionCard extends StatelessWidget {
  const _RegionCard({
    super.key,
    required this.region,
    required this.u,
    required this.v,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Region region;
  final Vec u;
  final Vec v;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  static const _names = {
    Region.triangle: 'Triangle',
    Region.parallelogram: 'Parallelogram',
    Region.rectangle: 'Box around it',
  };

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
    }

    final shade = (locked && isTruth)
        ? AppColors.forest
        : (locked && selected)
        ? AppColors.error
        : selected
        ? AppColors.ember
        : AppColors.ink2;

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 82,
                width: double.infinity,
                child: CustomPaint(
                  painter: RegionPainter(
                    u: u,
                    v: v,
                    region: region,
                    color: shade,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _names[region]!,
                textAlign: TextAlign.center,
                style: AppTheme.heading(size: 12, height: 1.15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
