import 'package:mobile/features/games/add_it_up_game.dart' show splitRounds;
import 'package:mobile/features/games/beam_figures.dart' show BeamPainter;
import 'package:mobile/features/games/buckle_or_squash_game.dart'
    show slenderRounds;
import 'package:mobile/features/games/column_figures.dart'
    show AxisPainter, ColumnCurvePainter, Governs, PostPainter;
import 'package:mobile/features/games/composite_figures.dart'
    show Made, MadeFacts, MadePainter, StressBlockPainter;
import 'package:mobile/features/games/deflection_figures.dart'
    show EntryFacts, PairPainter2, SagPainter;
import 'package:mobile/features/games/diagram_figures.dart'
    show Loading, supportsOf;
import 'package:mobile/features/games/fix_the_bounce_game.dart'
    show bounceRounds;
import 'package:mobile/features/games/how_far_has_it_yielded_game.dart'
    show yieldRounds;
import 'package:mobile/features/games/is_r_the_worst_game.dart'
    show Worst, WorstWords, worstRounds;
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/mohr_figures.dart'
    show ElementPainter, MohrPainter, Spot, SpotNames, Window;
import 'package:mobile/features/games/read_the_circle_game.dart'
    show MohrRound, mohrRounds;
import 'package:mobile/features/games/same_strain_game.dart'
    show Across, joinRounds;
import 'package:mobile/features/games/what_are_the_ends_worth_game.dart'
    show EndsRound, endsRounds;
import 'package:mobile/features/games/which_circle_is_it_game.dart'
    show madeRounds;
import 'package:mobile/features/games/which_line_in_the_table_game.dart'
    show tableRounds;
import 'package:mobile/features/games/which_one_gets_worse_game.dart'
    show Worse, WorseWords, swapRounds;
import 'package:mobile/features/games/which_way_does_it_fold_game.dart'
    show About, AboutWords, foldRounds;
import 'package:mobile/features/games/widen_the_stiff_one_game.dart'
    show transformRounds;

import 'package:mobile/core/theme/app_colors.dart';

import 'package:flutter/material.dart' hide Path, TextPainter;

import 'builder.dart';
import 'fluids.dart' show tapDrawing;
import 'nodes.dart';
import 'pick_one_adapter.dart';
import 'statistics.dart' show perPick;

/// The Mechanics of Materials games, second half: bending and shear, beam
/// deflections, composite sections and plastic bending, Mohr's circle and
/// columns. Most rounds are the problem over a drawing on the grid, then
/// the chapter's plain white answer rows (a ten pixel corner, a border that
/// turns ember, then forest or red, and never a tint). The rest answer with
/// drawings in panels, or by tapping a place on Mohr's circle.

/// Every game here, by id.
final adapters = <String, Map<String, Object?> Function()>{
  'which-one-gets-worse': whichOneGetsWorse,
  'which-line-in-the-table': whichLineInTheTable,
  'fix-the-bounce': fixTheBounce,
  'add-it-up': addItUp,
  'widen-the-stiff-one': widenTheStiffOne,
  'same-strain': sameStrain,
  'how-far-has-it-yielded': howFarHasItYielded,
  'read-the-circle': readTheCircle,
  'which-circle-is-it': whichCircleIsIt,
  'is-r-the-worst': isRTheWorst,
  'what-are-the-ends-worth': whatAreTheEndsWorth,
  'which-way-does-it-fold': whichWayDoesItFold,
  'buckle-or-squash': buckleOrSquash,
};

const _chapter = 'mechanics-materials';

/// The border of an answer in each state, and its width: a pixel more once
/// it is anything but idle.
final _edge = tone('line', 'ember', 'forest', 'error');
final _stroke = tone(1, 2, 2, 2);

/// The chapter's plain answer row: white, a ten pixel corner, the border
/// following the answer, its words laid out by [c] from the left.
Node plainRow(int i, List<Node> c, {required num vertical}) => answer(
  i,
  box(
    w: 'max',
    pad: [14, vertical, 14, vertical],
    radius: 10,
    border: _edge,
    stroke: _stroke,
    c: c,
    cross: 'start',
  ),
  radius: 10,
  fill: 'white',
);

/// A drawing in a white panel that is itself an answer, [h] high, with a
/// twelve pixel corner: drawn at the size each border leaves it, and
/// (with [toned]) in the ink of each state.
Node drawnAnswer(
  int i, {
  required double h,
  double pad = 0,
  required Draw Function(String state) paint,
  required bool toned,
  Node Function(Node drawing)? frame,
  (double, double) range = gameRange,
  required String what,
}) {
  Object at(String state) => record(
    paint(state),
    h - 2 * pad - (state == 'idle' ? 2 : 4),
    range: range,
    what: '$what $state',
  );
  final idle = at('idle');
  final Object drawing;
  if (toned) {
    drawing = tone(idle, at('picked'), at('right'), at('wrong'));
  } else {
    final on = at('on');
    drawing = tone(idle, on, on, on);
  }
  final inner = draw(drawing);
  return answer(
    i,
    box(
      h: h,
      pad: pad == 0 ? null : [pad, pad, pad, pad],
      radius: 12,
      border: _edge,
      stroke: _stroke,
      child: frame == null ? inner : frame(inner),
    ),
    fill: 'white',
  );
}

/// The ink a drawn answer takes in each state.
Color _ink(String state) => switch (state) {
  'right' => AppColors.forest,
  'wrong' => AppColors.error,
  'picked' => AppColors.ember,
  _ => AppColors.info,
};

/// A still drawing [h] high on a grid of [minor] and [major], unclipped,
/// as the chapter sets its problem drawings.
Node onGrid(Object drawing, num h, {num? minor, num? major}) => grid(
  box(h: h, child: draw(drawing)),
  minor: minor,
  major: major,
);

/// A small mono note under a drawing or the answers.
Map<String, Object?> note(String words, {String? when}) => {
  'mono': words,
  'size': 11,
  'color': 'ink3',
  'when': ?when,
};

/// A drawing on the 18 pixel grid that never changes with the answer.
Map<String, Object?> still(Draw paint, double h, String what) {
  final once = record(paint, h, what: what);
  return {
    'figure': {'ask': once, 'done': once},
    'h': h,
    'frame': 'grid',
  };
}

/// The colour key under a composite drawing: a small swatch of each
/// material's tint and its name.
Node keyRow(Made stiffer, Made softer) {
  Node key(Made made) => row([
    box(
      w: 12,
      h: 12,
      fill: '${_token(made)}/0.35',
      border: 'charcoal',
      stroke: 1.2,
      radius: 3,
    ),
    gapW(6),
    t(made.plain, font: 'mono', size: 11, color: 'ink3'),
  ]);
  return row([key(stiffer), gapW(14), key(softer)]);
}

String _token(Made made) {
  final tone = made.tone;
  if (tone == AppColors.info) return 'info';
  if (tone == AppColors.ink3) return 'ink3';
  if (tone == AppColors.sunbeam) return 'sunbeam';
  if (tone == AppColors.forest) return 'forest';
  throw ArgumentError('No token for ${made.name}');
}

Map<String, Object?> whichOneGetsWorse() {
  Node one(String title, String formula) => flex(
    col([
      t(title, font: 'mono', size: 11, color: 'ink3'),
      gapH(6),
      math(formula, 17),
    ]),
  );
  return pickScreen(
    id: 'which-one-gets-worse',
    chapter: _chapter,
    title: 'Which One Gets Worse',
    closing:
        'The span is in the moment and not in the shear. The depth is '
        'squared in the bending and counted once in the area. The material '
        'is in neither. A long beam is a bending problem and a short one '
        'is a shear problem, and that follows from the formulas rather '
        'than from experience.',
    right: 'THAT IS THE ONE',
    wrong: 'THE OTHER WAY',
    brief: briefJson(governsBrief, 'governsBrief'),
    rounds: [
      for (final (i, r) in swapRounds.indexed)
        (
          options: [for (final w in Worse.values) w.plain],
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: [
            ...heading('WHICH STRESS GOES UP', r.subject, r.change),
            gap(12),
            still(
              BeamPainter(
                span: r.before.span,
                supports: supportsOf(r.before),
                spreads: r.before.spreads,
                loads: [for (final p in r.before.points) (p.$1, r.loadLabel)],
              ).paint,
              120,
              'which-one-gets-worse round $i',
            ),
            gap(4),
            note('before the change'),
            gap(12),
            row([
              one('bending', r'$\sigma = \dfrac{Mc}{I}$'),
              box(w: 1, h: 54, fill: 'line'),
              one('shear', r'$\tau = \dfrac{3V}{2A}$'),
            ]),
            gap(14),
            {'choices': true, 'space': 8, 'last': true},
            ...feedbackAfter(8),
          ],
        ),
    ],
  );
}

Map<String, Object?> whichLineInTheTable() => pickScreen(
  id: 'which-line-in-the-table',
  chapter: _chapter,
  title: 'Which Line in the Table',
  closing:
      'Read the supports, then the load. Held at both ends or built in '
      'at one. Gathered at a point or spread along. Those two questions '
      'pick the line, and picking the wrong one is out by ten or sixteen '
      'times rather than by a few percent. A beam with two loads needs '
      'two lines added together.',
  right: 'THAT IS THE LINE',
  wrong: 'A DIFFERENT LINE',
  brief: briefJson(tableBrief2, 'tableBrief2'),
  rounds: [
    for (final (i, r) in tableRounds.indexed)
      () {
        final lines = r.options.length;
        final beam = BeamPainter(
          span: r.beam.span,
          supports: supportsOf(r.beam),
          spreads: r.beam.spreads,
          loads: [for (final p in r.beam.points) (p.$1, 'P')],
        ).paint;
        final shows = r.shows;
        final tall = record(beam, 140, what: 'which-line round $i beam');
        return (
          options: [
            for (final o in r.options) o.plain,
            'None on its own: this beam needs two lines added',
          ],
          notes: null,
          tex: null,
          // "None of them" is the row after the lines.
          answer: r.answer < 0 ? lines : r.answer,
          why: r.why,
          source: r.source,
          screen: [
            ...heading(
              'TAP THE LINE THIS BEAM BELONGS TO',
              r.subject,
              r.setting,
            ),
            gap(12),
            if (shows == null)
              {
                'figure': {'ask': tall, 'done': tall},
                'h': 140,
                'frame': 'grid',
              }
            else ...[
              {
                'figure': {
                  'ask': tall,
                  'done': record(
                    beam,
                    110,
                    what: 'which-line round $i beam answered',
                  ),
                },
                'h': {'ask': 140, 'done': 110},
                'frame': 'grid',
              },
              gap(4, when: 'done'),
              () {
                final sag = record(
                  SagPainter(entry: shows, span: r.beam.span, at: r.at).paint,
                  110,
                  what: 'which-line round $i sag',
                );
                return {
                  'figure': {'ask': sag, 'done': sag},
                  'h': 110,
                  'frame': 'grid',
                  'when': 'done',
                };
              }(),
            ],
            gap(12),
            for (final (k, o) in r.options.indexed) ...[
              plainRow(k, [
                math('\$${o.tex}\$', 17),
                gapH(4),
                t(o.plain, font: 'mono', size: 11, color: 'ink3'),
              ], vertical: 11),
              gap(8),
            ],
            plainRow(lines, [
              t('None on its own: this beam needs two lines added', size: 15),
            ], vertical: 11),
            ...feedbackAfter(16),
          ],
        );
      }(),
  ],
);

/// How much of the sag a change leaves, in words, as Fix the Bounce writes
/// it once answered.
String _share(double ratio) {
  if (ratio > 0.995) return 'leaves it exactly as it was';
  final percent = (ratio * 100).round();
  return 'leaves about $percent percent of the sag';
}

Map<String, Object?> fixTheBounce() => pickScreen(
  id: 'fix-the-bounce',
  chapter: _chapter,
  title: 'Fix the Bounce',
  closing:
      'Span carries a third or a fourth power. Depth carries a third '
      'through I. Width and load carry only a first. The material '
      'carries E, which is nothing between two steels and everything '
      'between timber and steel. Read the powers, then read the sizes.',
  right: 'THAT BUYS THE MOST',
  wrong: 'ANOTHER BUYS MORE',
  brief: briefJson(bounceBrief, 'bounceBrief'),
  rounds: [
    for (final (i, r) in bounceRounds.indexed)
      (
        options: [for (final c in r.cures) c.label],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...heading('WHICH CHANGE BUYS THE MOST', r.subject, r.setting),
          gap(12),
          still(
            SagPainter(entry: r.entry, span: r.span).paint,
            118,
            'fix-the-bounce round $i',
          ),
          gap(4),
          note('${r.entry.plain}, sagging as it stands'),
          gap(14),
          for (final (k, c) in r.cures.indexed) ...[
            plainRow(k, [
              t(c.label, size: 15),
              gapH(3, when: 'done'),
              t(
                _share(r.sagWith(c) / r.sagNow),
                font: 'mono',
                size: 11,
                color: k == r.answer ? 'forest' : 'ink3',
                when: 'done',
              ),
            ], vertical: 12),
            gap(8),
          ],
          ...feedbackAfter(8),
        ],
      ),
  ],
);

Map<String, Object?> addItUp() => pickScreen(
  id: 'add-it-up',
  chapter: _chapter,
  title: 'Add It Up',
  closing:
      'Split the LOAD and never the supports. Every piece has to be the '
      'same beam, held the same way, carrying part of what the real one '
      'carries. Then look each piece up and add the answers. And a beam '
      'that is already in the table needs no splitting at all.',
  right: 'THAT IS THE SPLIT',
  wrong: 'THAT IS A DIFFERENT BEAM',
  brief: briefJson(addBrief, 'addBrief'),
  rounds: [
    for (final (i, r) in splitRounds.indexed)
      () {
        final pairs = r.pairs.length;
        return (
          options: [
            for (var k = 0; k < pairs; k++) 'Split ${k + 1}',
            'No split needed: it is a table entry already',
          ],
          notes: null,
          tex: null,
          // "No split needed" is the row after the pairs.
          answer: r.answer < 0 ? pairs : r.answer,
          why: r.why,
          source: r.source,
          screen: [
            ...heading(
              'TAP THE SPLIT THAT ADDS BACK UP',
              r.subject,
              'This is the beam. Which pair of table beams adds up to it?',
            ),
            gap(10),
            still(
              BeamPainter(
                span: r.whole.span,
                supports: supportsOf(r.whole),
                spreads: r.whole.spreads,
                loads: [for (final p in r.whole.points) (p.$1, '')],
              ).paint,
              120,
              'add-it-up round $i',
            ),
            gap(12),
            for (final (k, (Loading left, Loading right))
                in r.pairs.indexed) ...[
              drawnAnswer(
                k,
                h: 104,
                paint: (_) => PairPainter2(left: left, right: right).paint,
                toned: false,
                what: 'add-it-up round $i pair $k',
              ),
              gap(8),
            ],
            plainRow(pairs, [
              t('No split needed: it is a table entry already', size: 15),
            ], vertical: 13),
            ...feedbackAfter(16),
          ],
        );
      }(),
  ],
);

Map<String, Object?> widenTheStiffOne() => pickScreen(
  id: 'widen-the-stiff-one',
  chapter: _chapter,
  title: 'Widen the Stiff One',
  closing:
      'Write the section as though it were all the softer material: the '
      'stiffer one gets n times wider, where n is the stiffer modulus '
      'over the softer. Never deeper, never narrower, and never the '
      'other material. Then it is an ordinary bending problem again.',
  right: 'THAT IS THE TRANSFORM',
  wrong: 'A DIFFERENT BEAM',
  brief: briefJson(transformBrief, 'transformBrief'),
  rounds: [
    for (final (i, r) in transformRounds.indexed)
      (
        options: [for (final o in r.options) o.name],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...heading('TAP THE TRANSFORMED SECTION', r.subject, r.setting),
          gap(12),
          onGrid(
            record(
              MadePainter(slices: r.beam.slices, label: 'the beam').paint,
              132,
              what: 'widen-the-stiff-one round $i',
            ),
            132,
            minor: 16,
            major: 80,
          ),
          gapH(6),
          keyRow(r.beam.stiffer, r.beam.softer),
          gap(12),
          for (final (k, o) in r.options.indexed) ...[
            drawnAnswer(
              k,
              h: 118,
              pad: 4,
              paint: (_) => MadePainter(slices: r.drawingFor(o)).paint,
              toned: false,
              frame: (d) => clip(grid(d, minor: 14, major: 70), 8),
              what: 'widen-the-stiff-one round $i panel $k',
            ),
            gap(8),
          ],
          note('each drawn to fit its own box: read which material got wider'),
          ...feedbackAfter(16),
        ],
      ),
  ],
);

Map<String, Object?> sameStrain() => pickScreen(
  id: 'same-strain',
  chapter: _chapter,
  title: 'Same Strain, Different Stress',
  closing:
      'Bonded materials stretch together, so the strain matches across '
      'the join and the stress does not. The stiffer one carries n times '
      'the stress at the same height. The transformed section hands you '
      'the soft material\'s stress; multiply by n for the stiff one.',
  right: 'THAT IS IT',
  wrong: 'THE OTHER WAY',
  brief: briefJson(joinBrief, 'joinBrief'),
  rounds: [
    for (final (i, r) in joinRounds.indexed)
      (
        options: [
          for (final a in Across.values)
            switch (a) {
              Across.stiffer => 'The ${r.beam.stiffer.plain}',
              Across.softer => 'The ${r.beam.softer.plain}',
              Across.same => 'Neither: they are equal',
            },
        ],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...heading('AT THE LINE WHERE THEY MEET', r.subject, r.asked),
          gap(12),
          onGrid(
            record(
              MadePainter(
                slices: r.beam.slices,
                join: r.join,
                label: 'the join is marked',
              ).paint,
              150,
              what: 'same-strain round $i',
            ),
            150,
            minor: 16,
            major: 80,
          ),
          gapH(6),
          keyRow(r.beam.stiffer, r.beam.softer),
          gap(10),
          {
            'math':
                r'$\sigma_1 = \dfrac{nMy}{I_T}, \quad \sigma_2 = \dfrac{My}{I_T}$',
            'size': 16,
          },
          gap(14),
          {'choices': true, 'space': 8, 'last': true},
          ...feedbackAfter(8),
        ],
      ),
  ],
);

Map<String, Object?> howFarHasItYielded() => pickScreen(
  id: 'how-far-has-it-yielded',
  chapter: _chapter,
  title: 'How Far Has It Yielded',
  closing:
      'Straight line, then touching yield at the faces, then eating '
      'inward with an elastic core, then square all the way through. '
      'The second picture is F y times S and the last is F y times Z. '
      'The gap between them is the shape factor: about half as much '
      'again for a rectangle, about a tenth for a wide flange.',
  right: 'THAT IS THE ONE',
  wrong: 'A DIFFERENT STAGE',
  brief: briefJson(plasticBrief, 'plasticBrief'),
  rounds: [
    for (final (i, r) in yieldRounds.indexed)
      (
        options: [for (final o in r.options) o.name],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...heading('TAP THE BLOCK THAT MATCHES', r.subject, r.asked),
          gap(12),
          panels(
            [
              for (final o in r.options)
                (canvas, size, state) => StressBlockPainter(
                  profile: r.section,
                  state: o,
                  tone: _ink(state),
                ).paint(canvas, size),
            ],
            h: 120,
            pad: 4,
            toned: true,
            what: 'how-far-has-it-yielded round $i',
          ),
          note('the dotted lines are where yield sits'),
          ...feedbackAfter(16),
        ],
      ),
  ],
);

Map<String, Object?> readTheCircle() => pickScreen(
  id: 'read-the-circle',
  chapter: _chapter,
  title: 'Read the Circle',
  closing:
      'The center is the average of the two normal stresses. The radius '
      'is the worst in-plane shear. The two ends are the principal '
      'stresses, and sigma one is the right hand end whatever the signs '
      'are. Every plane through the point is somewhere on that circle.',
  right: 'THAT IS THE PLACE',
  wrong: 'A DIFFERENT PLACE',
  brief: briefJson(circleBrief, 'circleBrief'),
  rounds: [
    for (final (i, r) in mohrRounds.indexed)
      () {
        const spots = MohrRound.spots;
        final window = Window.over([r.stress]);
        return (
          options: [for (final s in spots) s.plain],
          notes: null,
          tex: null,
          answer: spots.indexOf(r.answer),
          why: r.why,
          source: r.source,
          screen: [
            ...heading('TAP THE PLACE ON THE CIRCLE', r.subject, r.asked),
            gap(12),
            still(
              ElementPainter(
                stress: r.stress,
                label: 'the point, and what it feels',
              ).paint,
              130,
              'read-the-circle round $i element',
            ),
            gap(10),
            // The game picks the nearest mark within 30 pixels.
            grid(
              tapDrawing(
                h: 210,
                hits: [for (var s = 0; s < spots.length; s++) s],
                draw: (pick, answered) => MohrPainter(
                  stress: r.stress,
                  span: window,
                  spots: spots,
                  picked: pick == null ? null : spots[pick],
                  truth: answered ? r.answer : null,
                  locked: answered,
                ).paint,
                targets: (canvas, size) {
                  for (final s in spots) {
                    canvas.drawCircle(
                      MohrPainter.spotAt(r.stress, size, window, s),
                      30,
                      Paint(),
                    );
                  }
                },
                what: 'read-the-circle round $i',
              ),
            ),
            gap(6, when: 'picked'),
            {
              'when': 'picked',
              'pickedLabel': [for (final s in spots) s.plain],
              'size': 12,
              'color': 'ember',
            },
            ...feedbackAfter(12),
          ],
        );
      }(),
  ],
);

Map<String, Object?> whichCircleIsIt() => pickScreen(
  id: 'which-circle-is-it',
  chapter: _chapter,
  title: 'Which Circle Is It',
  closing:
      'Center at the average of the two normal stresses, radius from the '
      'half difference and the shear together. Pure shear sits on the '
      'origin. Equal stress both ways is a single point with no shear '
      'anywhere. And any shear at all pushes the largest principal '
      'stress further out than the normal stress you started with.',
  right: 'THAT IS THE CIRCLE',
  wrong: 'A DIFFERENT POINT',
  brief: briefJson(buildBrief, 'buildBrief'),
  rounds: [
    for (final (i, r) in madeRounds.indexed)
      () {
        // One window for all three, as the game frames them.
        final window = Window.over([for (final o in r.options) r.circleFor(o)]);
        return (
          options: [for (final o in r.options) o.name],
          notes: null,
          tex: null,
          answer: r.answer,
          why: r.why,
          source: r.source,
          screen: [
            ...heading('TAP THE CIRCLE FOR THIS POINT', r.subject, r.setting),
            gap(12),
            still(
              ElementPainter(stress: r.stress).paint,
              128,
              'which-circle-is-it round $i element',
            ),
            gap(12),
            for (final (k, o) in r.options.indexed) ...[
              drawnAnswer(
                k,
                h: 118,
                paint: (state) => MohrPainter(
                  stress: r.circleFor(o),
                  span: window,
                  tone: _ink(state),
                ).paint,
                toned: true,
                what: 'which-circle-is-it round $i circle $k',
              ),
              gap(8),
            ],
            note('all three on one scale, with zero marked'),
            ...feedbackAfter(16),
          ],
        );
      }(),
  ],
);

Map<String, Object?> isRTheWorst() => pickScreen(
  id: 'is-r-the-worst',
  chapter: _chapter,
  title: 'Is R the Worst',
  closing:
      'The third principal stress is zero, and it counts. If the circle '
      'crosses the zero mark, the radius is the worst shear at the '
      'point. If the whole circle sits to one side of zero, the worst '
      'shear is half the gap from zero to the far end, and it is bigger '
      'than the radius. One look at the drawing settles it.',
  right: 'THAT IS THE WORST',
  wrong: 'SOMETHING IS WORSE',
  brief: briefJson(worstBrief, 'worstBrief'),
  rounds: [
    for (final (i, r) in worstRounds.indexed)
      (
        options: [for (final w in Worst.values) w.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...heading(
            'WHAT IS THE WORST SHEAR AT THIS POINT',
            r.subject,
            r.setting,
          ),
          gap(12),
          still(
            MohrPainter(
              stress: r.stress,
              span: Window.over([r.stress]),
              spots: const [Spot.s1, Spot.s2],
            ).paint,
            160,
            'is-r-the-worst round $i',
          ),
          gap(4),
          note('the two marks are the principal stresses. zero is marked too'),
          gap(10),
          {
            'math':
                r'$\tau_{abs} = \dfrac{\sigma_{max} - \sigma_{min}}{2}, \quad \sigma_3 = 0$',
            'size': 15,
          },
          gap(14),
          {'choices': true, 'space': 8, 'last': true},
          ...feedbackAfter(8),
        ],
      ),
  ],
);

Map<String, Object?> whatAreTheEndsWorth() => pickScreen(
  id: 'what-are-the-ends-worth',
  chapter: _chapter,
  title: 'What Are the Ends Worth',
  closing:
      'Four cases and the handbook gives them to you. Both ends pinned '
      'is one. Both fixed is a half. One of each is zero point seven. '
      'Anything with a free end is two, and that is sixteen times weaker '
      'than the fixed pair. Read how each end is held, then look up the '
      'number.',
  right: 'THAT IS THE FACTOR',
  wrong: 'A DIFFERENT CASE',
  brief: briefJson(endsBrief, 'endsBrief'),
  rounds: [
    for (final (i, r) in endsRounds.indexed)
      () {
        // Alone across the width before the answer, then half of it beside
        // the shape it folds into.
        const half = (100.0, 500.0);
        final standing = PostPainter(post: r.post).paint;
        return (
          options: [for (final v in EndsRound.values) v.toString()],
          notes: null,
          tex: null,
          answer: r.answer,
          why: r.why,
          source: r.source,
          screen: [
            ...heading('TAP THE EFFECTIVE LENGTH FACTOR', r.subject, r.setting),
            gap(12),
            row([
              flex(
                onGrid(
                  askDone(
                    record(standing, 210, what: 'ends round $i standing'),
                    record(
                      standing,
                      210,
                      range: half,
                      what: 'ends round $i standing beside',
                    ),
                  ),
                  210,
                ),
              ),
              {...gapW(8), 'when': 'done'},
              {
                ...flex(
                  onGrid(
                    record(
                      PostPainter(post: r.post, bent: true).paint,
                      210,
                      range: half,
                      what: 'ends round $i bent',
                    ),
                    210,
                  ),
                ),
                'when': 'done',
              },
            ]),
            gap(4),
            t(
              askDone(
                'how each end is held',
                'how it stands, and the shape it folds into',
              ),
              font: 'mono',
              size: 11,
              color: 'ink3',
            ),
            gap(14),
            answerRow([
              for (final v in EndsRound.values)
                answer(
                  EndsRound.values.indexOf(v),
                  box(
                    h: 54,
                    align: 'center',
                    radius: 10,
                    border: _edge,
                    stroke: _stroke,
                    child: t(v.toString(), size: 17, bold: true),
                  ),
                  radius: 10,
                  fill: 'white',
                ),
            ]),
            gap(6),
            note('K, the effective length factor'),
            ...feedbackAfter(14),
          ],
        );
      }(),
  ],
);

Map<String, Object?> whichWayDoesItFold() => pickScreen(
  id: 'which-way-does-it-fold',
  chapter: _chapter,
  title: 'Which Way Does It Fold',
  closing:
      'A column folds about the axis it is weakest around, which is the '
      'one with the SMALLER second moment of area. Using the bigger one '
      'tells you the column is stronger than it is. A section that is '
      'the same both ways, a square tube or a round one, has no weak '
      'axis to find, and that is what makes it a good column.',
  right: 'THAT IS THE WEAK ONE',
  wrong: 'THE OTHER WAY',
  brief: briefJson(weakAxisBrief, 'weakAxisBrief'),
  rounds: [
    for (final (i, r) in foldRounds.indexed)
      () {
        // The game's way of saying an axis: true for the horizontal one,
        // false for the upright one, null for neither.
        bool? axis(About? a) => switch (a) {
          About.horizontal => true,
          About.vertical => false,
          _ => null,
        };
        return (
          options: [for (final a in About.values) a.plain],
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: [
            ...heading('WHICH AXIS DOES IT BEND ABOUT', r.subject, r.setting),
            gap(12),
            onGrid(
              perPick(
                (pick, answered) => AxisPainter(
                  profile: r.section,
                  highlight: axis(pick == null ? null : About.values[pick]),
                  locked: answered,
                  truth: answered ? axis(r.answer) : null,
                ).paint,
                About.values.length,
                200,
                what: 'which-way-does-it-fold round $i',
              ),
              200,
            ),
            gap(14),
            {'choices': true, 'space': 8, 'last': true},
            ...feedbackAfter(8),
          ],
        );
      }(),
  ],
);

Map<String, Object?> buckleOrSquash() => pickScreen(
  id: 'buckle-or-squash',
  chapter: _chapter,
  title: 'Buckle or Squash',
  closing:
      'Euler describes a column bowing sideways while the material is '
      'still elastic. A stocky column squashes before it gets the '
      'chance, so the formula is only allowed when the stress it gives '
      'comes out below yield. And Euler has no yield stress in it at '
      'all: a stronger steel does nothing whatever for a slender column.',
  right: 'THAT IS WHAT GIVES',
  wrong: 'THE OTHER ONE',
  brief: briefJson(slenderBrief, 'slenderBrief'),
  rounds: [
    for (final (i, r) in slenderRounds.indexed)
      (
        options: [
          for (final g in Governs.values)
            switch (g) {
              Governs.buckling => 'It buckles: Euler gives the load',
              Governs.yielding => 'It squashes: Euler does not apply',
              Governs.together => 'Neither: it is sitting on the crossing',
            },
        ],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...heading('WHICH FAILURE COMES FIRST', r.subject, r.setting),
          gap(12),
          still(
            ColumnCurvePainter(post: r.post).paint,
            190,
            'buckle-or-squash round $i',
          ),
          gap(4),
          note('the dot is this column. the dashed cap is its yield stress'),
          gap(14),
          {'choices': true, 'space': 8, 'last': true},
          ...feedbackAfter(8),
        ],
      ),
  ],
);
