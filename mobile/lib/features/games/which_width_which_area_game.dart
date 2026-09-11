import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'section_figures.dart';
import 'stress_figures.dart';

/// Which Width, Which Area — the second item for `bending-shear-stresses`.
///
/// The hard problem in this lesson is V Q over I b, and both of the things
/// that make it hard come off the drawing rather than out of a calculator. The
/// b is the width AT THE CUT, which on an I-beam at the flange junction is the
/// web and not the flange, and the lesson says that mistake is out by fifteen
/// times. The Q is the first moment of the material BEYOND the cut, not of the
/// whole section.
///
/// So three copies of the same section are drawn with the same cut on each,
/// and they differ only in what is marked.
class WhichWidthWhichAreaGame extends StatefulWidget {
  const WhichWidthWhichAreaGame({super.key});

  @override
  State<WhichWidthWhichAreaGame> createState() =>
      _WhichWidthWhichAreaGameState();
}

/// Which ingredient of the formula a round is after.
enum Asks { width, area }

@immutable
class CutRound {
  const CutRound({
    required this.subject,
    required this.section,
    required this.cut,
    required this.asks,
    required this.marks,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final Profile section;

  /// Where the section is cut.
  final double cut;

  final Asks asks;

  /// The three panels, in the order they are drawn.
  final List<Ingredient> marks;

  /// Which panel is right. Checked against the section by the tests: a width
  /// round's answer must measure what the section really is at the cut, and
  /// an area round's must be everything beyond it.
  final int answer;

  final String why;
  final String source;
}

final _iBeam = iSection(
  depth: 300,
  flangeWidth: 150,
  flangeThickness: 20,
  webThickness: 10,
);

/// A plate girder with unequal flanges: a hundred wide at the bottom, a
/// hundred and fifty at the top, ten of web between them. Three widths, so a
/// round about which one to use has three real answers to choose from.
final _girder = stackSection([(100, 20), (10, 260), (150, 20)]);

/// A stepped column, wide at the base and narrow at the top.
final _stepped = stackSection([(200, 60), (120, 120), (60, 60)]);

final _tee = teeSection(
  depth: 300,
  flangeWidth: 200,
  flangeThickness: 40,
  webThickness: 30,
);

final sliceRounds = <CutRound>[
  CutRound(
    subject: 'a plate girder, cut where the top flange meets the web',
    section: _girder,
    cut: 280,
    asks: Asks.width,
    marks: [
      const Ingredient.width(290),
      const Ingredient.width(200),
      const Ingredient.width(10),
    ],
    answer: 1,
    why:
        'The middle one, the web thickness. The b in the formula is the width '
        'of the section AT THE CUT, and at the underside of the flange the '
        'material the shear has to pass through is ten millimeters of web, not '
        'a hundred and fifty of flange. This lesson names that swap as its own '
        'trap and it is out by fifteen times.',
    source: 'mm-bss-q3',
  ),
  CutRound(
    subject: 'the same girder, cut through the top flange',
    section: _girder,
    cut: 292,
    asks: Asks.width,
    marks: [
      const Ingredient.width(10),
      const Ingredient.width(295),
      const Ingredient.width(200),
    ],
    answer: 1,
    why:
        'The middle one, the full flange width. Move the cut a few '
        'millimeters up into the flange and the answer changes completely, '
        'because b is a property of WHERE YOU CUT and not of the beam. It is '
        'also why the shear stress steps so sharply at the junction: the same '
        'shear flow spread across fifteen times the width.',
    source: 'mm-bss-q3',
  ),
  CutRound(
    subject: 'a stepped column, cut through the middle step',
    section: _stepped,
    cut: 140,
    asks: Asks.width,
    marks: [
      const Ingredient.width(30),
      const Ingredient.width(140),
      const Ingredient.width(210),
    ],
    answer: 1,
    why:
        'The middle one, the width of the step the cut passes through. Not the '
        'base, which is wider, and not the top, which is narrower: b is read '
        'at the cut and nowhere else. On a plain rectangle every one of these '
        'would be the same number, which is exactly why the three V over two A '
        'shortcut exists for rectangles and only for rectangles.',
    source: 'mm-bss-q2',
  ),
  CutRound(
    subject: 'an I-beam, cut where the flange meets the web',
    section: _iBeam,
    cut: 280,
    asks: Asks.area,
    marks: [
      const Ingredient.band(0, 300),
      const Ingredient.band(280, 300),
      const Ingredient.band(140, 300),
    ],
    answer: 1,
    why:
        'The middle one, the flange sitting above the cut. Q is the first '
        'moment of the material BEYOND the cut, taken about the neutral axis: '
        'that area times the distance from its own centroid to the axis. The '
        'first panel is the whole section, whose first moment about its own '
        'centroid is exactly zero. The third starts at the neutral axis, which '
        'is not where the cut is.',
    source: 'mm-bss-q3',
  ),
  CutRound(
    subject: 'the same beam, cut halfway up the web',
    section: _iBeam,
    cut: 150,
    asks: Asks.area,
    marks: [
      const Ingredient.band(280, 300),
      const Ingredient.band(150, 300),
      const Ingredient.band(0, 280),
    ],
    answer: 1,
    why:
        'The middle one: everything above the cut, which now means the flange '
        'AND the piece of web above it, not the flange alone. Taking '
        'everything BELOW the cut instead would have been just as good, since '
        'the two sides of a cut balance about the centroid, but the third '
        'panel stops at the flange rather than at the cut and so is neither '
        'side of it. The first panel is short of the web material.',
    source: 'mm-bss-q3',
  ),
  CutRound(
    subject: 'a tee, cut under the flange',
    section: _tee,
    cut: 260,
    asks: Asks.area,
    marks: [
      const Ingredient.band(260, 300),
      const Ingredient.band(0, 200),
      const Ingredient.band(0, 300),
    ],
    answer: 0,
    why:
        'The first, the flange above the cut. Everything BELOW the cut would '
        'have done just as well, because the two sides balance about the '
        'centroid, but the second panel stops well short of the cut and is '
        'not a side of anything. The third is the whole section, whose first '
        'moment about its own centroid is nothing at all.',
    source: 'mm-bss-q3',
  ),
];

class _WhichWidthWhichAreaGameState extends State<WhichWidthWhichAreaGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-width-which-area',
    chapterId: 'mechanics-materials',
    total: sliceRounds.length,
    sourceProblemIdOf: (round) => sliceRounds[round].source,
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

  CutRound get _round => sliceRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Width, Which Area',
        closing:
            'In V Q over I b, the b is the width where you cut and the Q is '
            'the material beyond the cut. Both change the moment you move the '
            'cut, and neither is a property of the beam. On an I-beam at the '
            'flange junction, b is the web.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: cutBrief,
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
            r.asks == Asks.width
                ? 'TAP THE WIDTH THAT GOES IN AS b'
                : 'TAP THE AREA WHOSE FIRST MOMENT IS Q',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\tau = \dfrac{VQ}{Ib}$',
              style:
                  const TextStyle(fontSize: 18, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < r.marks.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _Panel(
                    section: r.section,
                    cut: r.cut,
                    mark: r.marks[i],
                    selected: _picked == i,
                    locked: answered,
                    isTruth: i == r.answer,
                    onTap: answered ? null : () => setState(() => _picked = i),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'the dashed line is the cut, the same on all three',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct!
                  ? 'THAT IS WHAT GOES IN'
                  : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.section,
    required this.cut,
    required this.mark,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Profile section;
  final double cut;
  final Ingredient mark;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color tone;
    if (locked && isTruth) {
      border = AppColors.forest;
      tone = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
      tone = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
      tone = AppColors.ember;
    } else {
      border = AppColors.line;
      tone = AppColors.info;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: EngineeringGrid(
              minor: 16,
              major: 80,
              child: CustomPaint(
                painter: MarkPainter(
                  profile: section,
                  cut: cut,
                  mark: mark,
                  tone: tone,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
