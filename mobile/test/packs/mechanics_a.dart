import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/games/axial_figures.dart'
    show BarPairPainter, Gives, Outcome, RodPainter;
import 'package:mobile/features/games/beam_figures.dart'
    show BeamPainter, Station;
import 'package:mobile/features/games/can_you_get_there_game.dart'
    show Quantity, QuantityWords, Road, roadRounds;
import 'package:mobile/features/games/curve_figures.dart'
    show Frame, Mark, PairPainter, TensilePainter;
import 'package:mobile/features/games/diagram_figures.dart'
    show Diagram, DiagramPainter, Loading, kn, supportsOf;
import 'package:mobile/features/games/does_it_build_stress_game.dart'
    show heatRounds;
import 'package:mobile/features/games/jump_bend_or_neither_game.dart'
    show Does, DoesWords, markRounds;
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/stiff_strong_or_stretchy_game.dart'
    show AskWords, Which, pairRounds;
import 'package:mobile/features/games/stress_figures.dart'
    show LayerPainter, MarkPainter;
import 'package:mobile/features/games/stress_or_twist_game.dart'
    show Moves, shaftRounds;
import 'package:mobile/features/games/torsion_figures.dart'
    show ShaftPainter, TubePainter;
import 'package:mobile/features/games/what_comes_out_game.dart' show sumRounds;
import 'package:mobile/features/games/where_it_peaks_game.dart' show peakRounds;
import 'package:mobile/features/games/where_on_the_curve_game.dart'
    show curveRounds;
import 'package:mobile/features/games/which_area_twists_it_game.dart'
    show areaRounds;
import 'package:mobile/features/games/which_diagram_belongs_game.dart'
    show shapeRounds, variant;
import 'package:mobile/features/games/which_fiber_is_worst_game.dart'
    show FiberRound, WantedWords, fiberRounds;
import 'package:mobile/features/games/which_j_is_it_game.dart'
    show SquareBarPainter, jRounds;
import 'package:mobile/features/games/which_stretches_more_game.dart'
    show moveMoreRounds;
import 'package:mobile/features/games/which_width_which_area_game.dart'
    show Asks, sliceRounds;

import 'package:flutter/material.dart' hide Path, TextPainter;

import 'builder.dart';
import 'fluids.dart' show tapDrawing, top;
import 'nodes.dart';
import 'pick_one_adapter.dart';
import 'statistics.dart' show feedback, overline, subject;

/// The Mechanics of Materials games, first half: axial members, torsion,
/// stress-strain curves, shear and moment diagrams, and bending stress.
/// Most answer with the games' tinted rows (a bold title over a mono note,
/// or a formula), some with drawings that are answers themselves, and some
/// by tapping the drawing.

/// A tinted answer row 58 high: a bold title over a mono note.
Node titled(int i, String title, String note) => tinted(
  i,
  col(
    [
      t(title, size: 15, bold: true),
      gapH(2),
      t(note, font: 'mono', size: 10.5, color: 'ink3'),
    ],
    main: 'center',
    cross: 'start',
  ),
  h: 58,
  pad: const [14, 0, 14, 0],
  align: 'left',
);

/// A tinted answer row 54 high holding one bold line.
Node oneLine(int i, String words) => tinted(
  i,
  t(words, size: 15, bold: true),
  h: 54,
  pad: const [14, 0, 14, 0],
  align: 'left',
);

/// Rows stacked [space] apart, none after the last.
List<Node> stacked(List<Node> rows, {num space = 8}) => [
  for (final (i, r) in rows.indexed) ...[if (i > 0) gapH(space), r],
];

/// A drawing that is itself an answer: white, its border following the
/// answer and a pixel thicker once it is anything but idle, the drawing
/// inset by [pad] on a finer grid and tinted with the answer. Recorded at
/// each size the border leaves it, in each state's ink.
Node tonedPanel(
  int i, {
  required double h,
  required double pad,
  required Draw Function(Color tone) paint,
  required String what,
}) {
  Object at(Color ink, String state) => record(
    paint(ink),
    h - 2 * pad - (state == 'idle' ? 2 : 4),
    // A panel in a row of three is under a third of the game's width.
    range: (60, 500),
    what: '$what $state',
  );
  return answer(
    i,
    box(
      h: h,
      pad: [pad, pad, pad, pad],
      radius: 12,
      border: tone('line', 'ember', 'forest', 'error'),
      stroke: tone(1, 2, 2, 2),
      child: clip(
        grid(
          draw(
            tone(
              at(AppColors.info, 'idle'),
              at(AppColors.ember, 'picked'),
              at(AppColors.forest, 'right'),
              at(AppColors.error, 'wrong'),
            ),
          ),
          minor: 16,
          major: 80,
        ),
        8,
      ),
    ),
    fill: 'white',
  );
}

/// A drawing on the bare grid, [h] high, the full width.
Node onGrid(Object d, num h) => grid(box(h: h, child: draw(d)));

Map<String, Object?> whichStretchesMore() => pickScreen(
  id: 'which-stretches-more',
  chapter: 'mechanics-materials',
  title: 'Which Stretches More',
  closing:
      'Load and length are on the top, area and modulus underneath. Put '
      'more of the first two in and it moves further; more of the last '
      'two and it moves less. Read the formula that way once and you '
      'never have to remember which is which again.',
  right: 'THAT IS THE ONE',
  wrong: 'THE OTHER WAY',
  brief: briefJson(deformationBrief, 'deformationBrief'),
  rounds: [
    for (final (n, r) in moveMoreRounds.indexed)
      (
        options: [...r.labels, 'Nothing between them'],
        notes: null,
        tex: null,
        answer: r.answer == -1 ? 2 : r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHICH ONE MOVES FURTHER', r.subject, r.setting),
          gap(10),
          // Each bar's row is a tap area, stacked as the game stacks them.
          clip(
            box(
              w: 'max',
              h: 230,
              child: grid(
                tapDrawing(
                  h: 230,
                  hits: [0, 1],
                  other: true,
                  draw: (pick, answered) => BarPairPainter(
                    bars: r.bars,
                    labels: r.labels,
                    picked: pick,
                    truth: r.answer,
                    locked: answered,
                  ).paint,
                  targets: (canvas, size) {
                    for (var i = 0; i < r.bars.length; i++) {
                      canvas.drawRect(
                        BarPairPainter.rowFor(r.bars, size, i),
                        Paint(),
                      );
                    }
                  },
                  what: 'which-stretches-more round $n',
                ),
              ),
            ),
            16,
          ),
          gap(8),
          oneLine(2, 'Nothing between them'),
          ...feedback(16),
        ],
      ),
  ],
);

Map<String, Object?> whatComesOut() => pickScreen(
  id: 'what-comes-out',
  chapter: 'mechanics-materials',
  title: 'What Comes Out',
  closing:
      'Put newtons, millimeters and megapascals in and the answer comes '
      'out in millimeters or megapascals with nothing to convert. Put a '
      'meter in beside a millimeter and the units still cancel and the '
      'answer is still wrong by a thousand. Checking the dimensions will '
      'not save you from that one. Converting before you start will.',
  right: 'THAT IS WHAT COMES OUT',
  wrong: 'SOMETHING ELSE',
  brief: briefJson(unitsBrief, 'unitsBrief'),
  rounds: [
    for (final r in sumRounds)
      (
        options: [for (final g in Gives.values) _gives[g]!.$1],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHAT FALLS OUT OF THIS', r.subject, r.setting),
          gap(14),
          box(
            w: 'max',
            pad: const [16, 22, 16, 22],
            fill: 'white',
            radius: 16,
            border: 'line',
            child: center(math('\$${r.sum.latex}\$', 19)),
          ),
          gap(14),
          ...stacked([
            for (final g in Gives.values)
              titled(g.index, _gives[g]!.$1, _gives[g]!.$2),
          ]),
          ...feedback(16),
        ],
      ),
  ],
);

const _gives = {
  Gives.stress: ('A stress', 'newtons over an area'),
  Gives.length: ('A distance', 'something you could measure with a rule'),
  Gives.pureNumber: (
    'A bare number',
    'the units cancel away, which is a strain',
  ),
  Gives.mixedUnits: (
    'Nothing you can trust',
    'two different lengths went into one sum',
  ),
};

Map<String, Object?> doesItBuildStress() => pickScreen(
  id: 'does-it-build-stress',
  chapter: 'mechanics-materials',
  title: 'Does It Build Stress',
  closing:
      'Heat does not make stress. Being stopped from moving makes '
      'stress. Warm a restrained bar and it is squeezed, cool one and it '
      'is stretched, and give it room to grow into and it may never '
      'touch at all. When it does build stress, the length and the '
      'cross-section cancel out of the answer.',
  right: 'THAT IS WHAT IT CARRIES',
  wrong: 'SOMETHING ELSE',
  brief: briefJson(thermalBrief, 'thermalBrief'),
  rounds: [
    for (final (n, r) in heatRounds.indexed)
      (
        options: [for (final o in Outcome.values) _outcomes[o]!.$1],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHAT IS THE BAR LEFT CARRYING', r.subject, r.setting),
          gap(10),
          pictured(
            askDone(
              record(
                RodPainter(rod: r.rod).paint,
                190,
                what: 'does-it-build-stress round $n asked',
              ),
              record(
                RodPainter(rod: r.rod, showOutcome: true).paint,
                190,
                what: 'does-it-build-stress round $n answered',
              ),
            ),
            190,
          ),
          gap(12),
          ...stacked([
            for (final o in Outcome.values)
              titled(o.index, _outcomes[o]!.$1, _outcomes[o]!.$2),
          ]),
          ...feedback(16),
        ],
      ),
  ],
);

const _outcomes = {
  Outcome.nothing: (
    'No stress at all',
    'it was free to move, or never reached the wall',
  ),
  Outcome.squeezed: (
    'Squeezed, in compression',
    'it wanted to grow and was not allowed to',
  ),
  Outcome.stretched: (
    'Stretched, in tension',
    'it wanted to shrink and was held out',
  ),
};

Map<String, Object?> whichJIsIt() => pickScreen(
  id: 'which-j-is-it',
  chapter: 'mechanics-materials',
  title: 'Which J Is It',
  closing:
      'J is the POLAR moment and it is twice the area moment, so pi d to '
      'the fourth over thirty two and never over sixty four. A bore '
      'comes off as its own fourth power, not by subtracting diameters '
      'first. And none of it applies to a section that is not round: a '
      'square bar warps, and needs a table.',
  right: 'THAT IS THE ONE',
  wrong: 'A DIFFERENT ONE',
  brief: briefJson(polarJBrief, 'polarJBrief'),
  rounds: [
    for (final (n, r) in jRounds.indexed)
      (
        options: [...r.options, 'None of them fits this section'],
        notes: null,
        tex: null,
        answer: r.answer == -1 ? r.options.length : r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHICH ONE GOES UNDER Tc', r.subject, r.setting),
          gap(10),
          pictured(
            r.circular
                ? askDone(
                    record(
                      ShaftPainter(shaft: r.shaft).paint,
                      175,
                      what: 'which-j-is-it round $n asked',
                    ),
                    record(
                      ShaftPainter(shaft: r.shaft, markC: true).paint,
                      175,
                      what: 'which-j-is-it round $n answered',
                    ),
                  )
                : record(
                    const SquareBarPainter().paint,
                    175,
                    what: 'which-j-is-it round $n',
                  ),
            175,
          ),
          gap(12),
          for (final (i, o) in r.options.indexed) ...[
            tinted(i, math('\$$o\$', 17), h: 66, align: 'center'),
            gap(8),
          ],
          oneLine(r.options.length, 'None of them fits this section'),
          ...feedback(16),
        ],
      ),
  ],
);

Map<String, Object?> stressOrTwist() => pickScreen(
  id: 'stress-or-twist',
  chapter: 'mechanics-materials',
  title: 'Stress or Twist',
  closing:
      'The stress carries T, c and J. The twist carries T, L, G and J. '
      'So length and shear modulus move the twist and leave the stress '
      'alone, and nothing moves the stress by itself, because c and J '
      'are locked together on a round shaft. Read which letters are in '
      'which formula once and the rest follows.',
  right: 'THAT IS WHAT MOVES',
  wrong: 'SOMETHING ELSE',
  brief: briefJson(twistBrief, 'twistBrief'),
  rounds: [
    for (final r in shaftRounds)
      (
        options: [for (final m in Moves.values) _moves[m]!.$1],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHAT DOES THIS CHANGE MOVE', r.subject, r.change),
          gap(12),
          // The two formulas side by side on the grid, a hairline between.
          clip(
            box(
              w: 'max',
              h: 96,
              child: grid(
                row([
                  flex(_formula('stress', r'\tau = \dfrac{Tc}{J}')),
                  box(w: 1, fill: 'line'),
                  flex(_formula('twist', r'\phi = \dfrac{TL}{GJ}')),
                ]),
              ),
            ),
            16,
          ),
          gap(12),
          ...stacked([
            for (final m in Moves.values)
              titled(m.index, _moves[m]!.$1, _moves[m]!.$2),
          ]),
          ...feedback(16),
        ],
      ),
  ],
);

Node _formula(String top, String latex) => col([
  t(top, font: 'mono', size: 10.5, color: 'ink3'),
  gapH(6),
  math('\$$latex\$', 17),
], main: 'center');

const _moves = {
  Moves.twistOnly: (
    'The twist, and not the stress',
    'what changed is in one formula and not the other',
  ),
  Moves.both: ('Both of them', 'what changed is in both'),
  Moves.neither: ('Neither of them', 'what changed is in neither'),
};

Map<String, Object?> whichAreaTwistsIt() => pickScreen(
  id: 'which-area-twists-it',
  chapter: 'mechanics-materials',
  title: 'Which Area Twists It',
  closing:
      'A sub m is the area enclosed by the MIDDLE of the wall. Not the '
      'metal, not the bore, not the outside. It is a line that is not on '
      'the object and it encloses space that is not metal, and it is the '
      'only one of the four that belongs in the formula.',
  right: 'THAT IS THE AREA',
  wrong: 'A DIFFERENT AREA',
  brief: briefJson(thinWallBrief, 'thinWallBrief'),
  rounds: [
    for (final (n, r) in areaRounds.indexed)
      (
        options: [for (final p in r.panels) p.name],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...top('TAP THE AREA THE FORMULA WANTS', r.subject, r.setting),
          gap(12),
          {'math': r'$\tau = \dfrac{T}{2\,t\,A_m}$', 'size': 18},
          gap(12),
          answerRow([
            for (final (i, region) in r.panels.indexed)
              tonedPanel(
                i,
                h: 118,
                pad: 6,
                paint: (ink) =>
                    TubePainter(tube: r.tube, region: region, tone: ink).paint,
                what: 'which-area-twists-it round $n panel $i',
              ),
          ]),
          gap(8),
          {
            'mono':
                'dashed line: the middle of the wall, drawn thicker than '
                'scale',
            'size': 11,
            'color': 'ink3',
          },
          ...feedback(16),
        ],
      ),
  ],
);

Map<String, Object?> whereOnTheCurve() => pickScreen(
  id: 'where-on-the-curve',
  chapter: 'mechanics-materials',
  title: 'Where On the Curve',
  closing:
      'Straight run, then the knee, then yield, then the top, then the '
      'break. The top is the ultimate and the break is lower than it, '
      'because engineering stress keeps dividing by the area the bar '
      'started with. Every property in this lesson is one of these '
      'points or the slope between two of them.',
  right: 'THAT IS THE POINT',
  wrong: 'NOT THAT POINT',
  brief: briefJson(curveBrief, 'curveBrief'),
  rounds: [
    for (final (n, r) in curveRounds.indexed)
      () {
        final frame = Frame.over([r.specimen]);
        return (
          options: [for (final m in Mark.values) m.name],
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            ...top('TAP THE POINT ON THE CURVE', r.subject, r.asked),
            gap(12),
            grid(
              tapDrawing(
                h: 210,
                hits: [for (final m in Mark.values) m.index],
                draw: (pick, answered) => TensilePainter(
                  specimen: r.specimen,
                  frame: frame,
                  labelled: answered ? [r.answer] : const [],
                  dotted: answered || pick == null
                      ? const []
                      : [Mark.values[pick]],
                  wrong: answered && pick != r.answer.index
                      ? Mark.values[pick!]
                      : null,
                ).paint,
                targets: (canvas, size) {
                  for (final m in Mark.values) {
                    canvas.drawCircle(
                      TensilePainter.markAt(r.specimen, frame, size, m),
                      30,
                      Paint(),
                    );
                  }
                },
                what: 'where-on-the-curve round $n',
              ),
            ),
            gap(8),
            {
              'mono':
                  'a schematic. each part of the curve is drawn wide enough '
                  'to see',
              'size': 11,
              'color': 'ink3',
            },
            ...feedback(16),
          ],
        );
      }(),
  ],
);

Map<String, Object?> stiffStrongOrStretchy() => pickScreen(
  id: 'stiff-strong-or-stretchy',
  chapter: 'mechanics-materials',
  title: 'Stiff, Strong or Stretchy',
  closing:
      'Slope for stiff, height for strong, length for stretchy. All '
      'steels share the same slope whatever they cost. The strongest '
      'material on a page can be the one that gives you no warning at '
      'all. Read the feature the question actually asks about.',
  right: 'READ RIGHT',
  wrong: 'A DIFFERENT FEATURE',
  brief: briefJson(stiffStrongBrief, 'stiffStrongBrief'),
  rounds: [
    for (final (n, r) in pairRounds.indexed)
      (
        options: [
          for (final v in Which.values)
            switch (v) {
              Which.first => r.first.label,
              Which.second => r.second.label,
              Which.alike => 'no real difference',
            },
        ],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          overline('READ IT OFF THE TWO CURVES'),
          gap(6),
          subject(r.ask.reads),
          gap(10),
          {'text': r.setting, 'size': 15},
          gap(12),
          onGrid(
            record(
              PairPainter(
                left: r.first,
                right: r.second,
                frame: Frame.comparing([r.first, r.second]),
              ).paint,
              200,
              what: 'stiff-strong-or-stretchy round $n',
            ),
            200,
          ),
          gap(8),
          row([
            _key('info', r.first.label),
            gapW(14),
            _key('ember', r.second.label),
          ]),
          gap(4),
          {
            'mono':
                'one set of axes. the elastic part is drawn wider than '
                'scale',
            'size': 11,
            'color': 'ink3',
          },
          gap(14),
          {'text': r.ask.question, 'size': 15, 'bold': true},
          gap(10),
          {'choices': true, 'space': 8, 'last': true},
          ...feedback(8),
        ],
      ),
  ],
);

/// One curve's key: a short bar of its color and its name.
Node _key(String color, String label) => row([
  box(w: 16, h: 3, fill: color, radius: 2),
  gapW(6),
  t(label, font: 'mono', size: 11, color: 'ink3'),
]);

Map<String, Object?> canYouGetThere() => pickScreen(
  id: 'can-you-get-there',
  chapter: 'mechanics-materials',
  title: 'Can You Get There',
  closing:
      'E comes from a stress and its strain. G comes from E and nu, in '
      'either direction. Elongation comes from two lengths. Nothing in '
      'this lesson turns a strength into a ductility. Everything else '
      'on the page is there to be left alone.',
  right: 'THAT IS THE ROAD',
  wrong: 'LOOK AGAIN',
  brief: briefJson(linkedBrief, 'linkedBrief'),
  rounds: [
    for (final r in roadRounds)
      (
        options: [
          for (final road in Road.values)
            switch (road) {
              Road.oneStep => 'Yes, one formula does it',
              Road.further => 'Yes, but it takes more than one',
              Road.cannot => 'No, something is missing',
            },
        ],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          overline('CAN YOU GET THERE FROM HERE'),
          gap(10),
          {'text': r.setting, 'size': 15},
          gap(14),
          _have('YOU HAVE', 'info', [
            for (final q in r.have) _line(q),
            for (final s in r.spare)
              box(
                pad: const [0, 6, 0, 0],
                child: t(s, font: 'mono', size: 12, color: 'ink3'),
              ),
          ]),
          gap(10),
          _have('YOU WANT', 'ember', [_line(r.want)]),
          gap(14),
          {'choices': true, 'space': 8, 'last': true},
          ...feedback(8),
        ],
      ),
  ],
);

/// A white box of quantities under a colored overline.
Node _have(String title, String color, List<Node> lines) => box(
  w: 'max',
  pad: const [14, 11, 14, 13],
  fill: 'white',
  radius: 12,
  border: 'line',
  cross: 'start',
  c: [
    t(title, font: 'overline', color: color),
    gapH(8),
    ...lines,
  ],
);

/// A quantity: its symbol in a column 34 wide, then its name.
Node _line(Quantity q) => box(
  pad: const [0, 0, 0, 2],
  child: row([
    box(w: 34, child: math('\$${q.tex}\$', 15)),
    flex(t(q.plain, size: 14, line: 1.4)),
  ]),
);

/// The beam as the Mechanics diagrams draw it, its loads labelled.
BeamPainter _beam(
  Loading beam,
  List<String> loadLabels, {
  List<(double, bool, String)> couples = const [],
  List<Station> stations = const [],
  int? selected,
  bool locked = false,
  int truth = -1,
}) => BeamPainter(
  span: beam.span,
  supports: supportsOf(beam),
  spreads: beam.spreads,
  loads: [
    for (final (i, p) in beam.points.indexed)
      (p.$1, i < loadLabels.length ? loadLabels[i] : kn(p.$2)),
  ],
  couples: couples,
  stations: stations,
  selected: selected,
  locked: locked,
  truth: truth,
);

Map<String, Object?> whichDiagramBelongs() => pickScreen(
  id: 'which-diagram-belongs',
  chapter: 'mechanics-materials',
  title: 'Which Diagram Belongs',
  closing:
      'The slope of the shear is minus the load. The slope of the '
      'moment is the shear. Nothing spread on the beam means flat '
      'shear and straight moment; a uniform load means sloping shear '
      'and a curved moment. Read the beam and the shapes are decided '
      'before you compute anything.',
  right: 'THAT IS THE ONE',
  wrong: 'A DIFFERENT BEAM',
  brief: briefJson(slopeRulesBrief, 'slopeRulesBrief'),
  rounds: [
    for (final (n, r) in shapeRounds.indexed)
      (
        options: [for (final o in r.options) o.name],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          overline(
            r.asked == Diagram.shear
                ? 'TAP THE SHEAR DIAGRAM FOR THIS BEAM'
                : 'TAP THE MOMENT DIAGRAM FOR THIS BEAM',
          ),
          gap(6),
          subject(r.subject),
          gap(10),
          onGrid(
            record(
              _beam(r.beam, r.loadLabels).paint,
              140,
              what: 'which-diagram-belongs round $n beam',
            ),
            140,
          ),
          gap(12),
          for (final (i, o) in r.options.indexed) ...[
            _diagramPanel(
              i,
              variant(r.beam, r.asked, o),
              r.beam.span,
              'which-diagram-belongs round $n panel $i',
            ),
            gap(8),
          ],
          {
            'mono': 'shape only. each one is drawn to its own height',
            'size': 11,
            'color': 'ink3',
          },
          ...feedback(16),
        ],
      ),
  ],
);

/// A diagram that is an answer: drawn straight onto the white panel to its
/// own tallest value, its line tinted with the answer.
Node _diagramPanel(int i, List<Offset> curve, double span, String what) {
  var peak = 0.0;
  for (final p in curve) {
    if (p.dy.abs() > peak) peak = p.dy.abs();
  }
  Object at(Color ink, String state) => record(
    DiagramPainter(curve: curve, span: span, peak: peak, tone: ink).paint,
    92.0 - (state == 'idle' ? 2 : 4),
    what: '$what $state',
  );
  return answer(
    i,
    box(
      h: 92,
      radius: 12,
      border: tone('line', 'ember', 'forest', 'error'),
      stroke: tone(1, 2, 2, 2),
      child: draw(
        tone(
          at(AppColors.info, 'idle'),
          at(AppColors.ember, 'picked'),
          at(AppColors.forest, 'right'),
          at(AppColors.error, 'wrong'),
        ),
      ),
    ),
    fill: 'white',
  );
}

Map<String, Object?> whereItPeaks() => pickScreen(
  id: 'where-it-peaks',
  chapter: 'mechanics-materials',
  title: 'Where It Peaks',
  closing:
      'The moment peaks where the shear passes through zero. Under the '
      'load when there is one load, at the middle when the load is '
      'spread evenly, at the wall on a cantilever, and over the support '
      'when something hangs past it. Find the place first. The size of '
      'it is arithmetic, and arithmetic belongs on paper.',
  right: 'THAT IS THE PLACE',
  wrong: 'SOMEWHERE ELSE',
  brief: briefJson(peakBrief, 'peakBrief'),
  rounds: [
    for (final (n, r) in peakRounds.indexed)
      (
        options: [for (final x in r.spots) '${_meters(x)} m'],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...top(
            'TAP WHERE THE BENDING IS WORST',
            r.subject,
            'Sagging or hogging, whichever is bigger.',
          ),
          gap(12),
          grid(
            tapDrawing(
              h: 190,
              hits: [for (var i = 0; i < r.spots.length; i++) i],
              draw: (pick, answered) => _beam(
                r.beam,
                r.loadLabels,
                stations: [
                  for (final x in r.spots) Station(x, '${_meters(x)} m'),
                ],
                selected: pick,
                locked: answered,
                truth: answered ? r.answer : -1,
              ).paint,
              targets: (canvas, size) {
                for (final x in r.spots) {
                  canvas.drawCircle(
                    BeamPainter.stationAt(size, r.beam.span, x),
                    34,
                    Paint(),
                  );
                }
              },
              what: 'where-it-peaks round $n',
            ),
          ),
          ...feedback(16),
        ],
      ),
  ],
);

String _meters(double x) =>
    x == x.roundToDouble() ? x.round().toString() : x.toString();

Map<String, Object?> jumpBendOrNeither() => pickScreen(
  id: 'jump-bend-or-neither',
  chapter: 'mechanics-materials',
  title: 'Jump, Bend or Neither',
  closing:
      'A vertical force steps the shear by its own size and bends the '
      'moment. A couple steps the moment and leaves the shear alone. '
      'The start or end of a spread load steps nothing and bends the '
      'shear. Everywhere else both lines carry straight on.',
  right: 'THAT IS WHAT IT DOES',
  wrong: 'NOT QUITE',
  brief: briefJson(jumpBrief, 'jumpBrief'),
  rounds: [
    for (final (n, r) in markRounds.indexed)
      (
        options: [for (final d in Does.values) d.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top(
            r.asked == Diagram.shear
                ? 'WHAT THE SHEAR DIAGRAM DOES HERE'
                : 'WHAT THE MOMENT DIAGRAM DOES HERE',
            r.subject,
            'Walking from left to right, what happens to the '
            '${r.asked == Diagram.shear ? 'shear' : 'moment'} at the '
            'marked point?',
          ),
          gap(12),
          onGrid(
            record(
              _beam(
                r.beam,
                r.loadLabels,
                couples: [
                  for (final (pos, m) in r.beam.couples)
                    (pos, m < 0, '${m.abs().round()} kN·m'),
                ],
                stations: [Station(r.at, 'here')],
                selected: 0,
              ).paint,
              175,
              what: 'jump-bend-or-neither round $n',
            ),
            175,
          ),
          gap(14),
          {'choices': true, 'space': 8, 'last': true},
          ...feedback(8),
        ],
      ),
  ],
);

Map<String, Object?> whichFiberIsWorst() => pickScreen(
  id: 'which-fiber-is-worst',
  chapter: 'mechanics-materials',
  title: 'Which Fiber Is Worst',
  closing:
      'Bending is nothing at the neutral axis and worst at the faces. '
      'Shear is nothing at the faces and worst at the neutral axis. The '
      'neutral axis is the centroid, which is halfway up only when the '
      'section is symmetric. Sagging stretches the bottom; hogging '
      'stretches the top.',
  right: 'THAT IS THE LAYER',
  wrong: 'A DIFFERENT LAYER',
  brief: briefJson(fiberBrief, 'fiberBrief'),
  rounds: [
    for (final (n, r) in fiberRounds.indexed)
      () {
        final layers = r.layers;
        final names = [for (final l in layers) l.label];
        return (
          options: names,
          notes: null,
          tex: null,
          answer: r.answer,
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            ...top(
              r.sagging ? 'THE BEAM IS SAGGING' : 'THE BEAM IS HOGGING',
              r.subject,
              r.wanted.asked,
            ),
            gap(12),
            grid({
              ...tapDrawing(
                h: 230,
                hits: [for (var i = 0; i < layers.length; i++) i],
                draw: (pick, answered) => LayerPainter(
                  profile: r.section,
                  layers: layers,
                  picked: pick,
                  truth: answered ? r.answer : -1,
                  locked: answered,
                  show: answered ? r.wanted.shows : null,
                  moment: r.moment,
                  shear: FiberRound.shear,
                ).paint,
                targets: (canvas, size) {
                  for (final l in layers) {
                    canvas.drawCircle(
                      LayerPainter.layerAt(r.section, size, l.y),
                      26,
                      Paint(),
                    );
                  }
                },
                what: 'which-fiber-is-worst round $n',
              ),
              // The game measures a tap up and down only.
              'axis': 'y',
            }),
            gap(8, when: 'picked'),
            {
              'pickedLabel': names,
              'size': 12,
              'color': 'ember',
              'when': 'picked',
            },
            gap(8, when: 'done'),
            {
              'mono':
                  'the line beside it is how that stress runs through the '
                  'depth',
              'size': 11,
              'color': 'ink3',
              'when': 'done',
            },
            ...feedback(12),
          ],
        );
      }(),
  ],
);

Map<String, Object?> whichWidthWhichArea() => pickScreen(
  id: 'which-width-which-area',
  chapter: 'mechanics-materials',
  title: 'Which Width, Which Area',
  closing:
      'In V Q over I b, the b is the width where you cut and the Q is '
      'the material beyond the cut. Both change the moment you move the '
      'cut, and neither is a property of the beam. On an I-beam at the '
      'flange junction, b is the web.',
  right: 'THAT IS WHAT GOES IN',
  wrong: 'NOT THAT ONE',
  brief: briefJson(cutBrief, 'cutBrief'),
  rounds: [
    for (final (n, r) in sliceRounds.indexed)
      (
        options: [for (var i = 0; i < r.marks.length; i++) 'panel $i'],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          overline(
            r.asks == Asks.width
                ? 'TAP THE WIDTH THAT GOES IN AS b'
                : 'TAP THE AREA WHOSE FIRST MOMENT IS Q',
          ),
          gap(6),
          subject(r.subject),
          gap(10),
          {'math': r'$\tau = \dfrac{VQ}{Ib}$', 'size': 18},
          gap(12),
          answerRow([
            for (final (i, mark) in r.marks.indexed)
              tonedPanel(
                i,
                h: 150,
                pad: 4,
                paint: (ink) => MarkPainter(
                  profile: r.section,
                  cut: r.cut,
                  mark: mark,
                  tone: ink,
                ).paint,
                what: 'which-width-which-area round $n panel $i',
              ),
          ]),
          gap(8),
          {
            'mono': 'the dashed line is the cut, the same on all three',
            'size': 11,
            'color': 'ink3',
          },
          ...feedback(16),
        ],
      ),
  ],
);

final adapters = <String, Map<String, Object?> Function()>{
  'which-stretches-more': whichStretchesMore,
  'what-comes-out': whatComesOut,
  'does-it-build-stress': doesItBuildStress,
  'which-j-is-it': whichJIsIt,
  'stress-or-twist': stressOrTwist,
  'which-area-twists-it': whichAreaTwistsIt,
  'where-on-the-curve': whereOnTheCurve,
  'stiff-strong-or-stretchy': stiffStrongOrStretchy,
  'can-you-get-there': canYouGetThere,
  'which-diagram-belongs': whichDiagramBelongs,
  'where-it-peaks': whereItPeaks,
  'jump-bend-or-neither': jumpBendOrNeither,
  'which-fiber-is-worst': whichFiberIsWorst,
  'which-width-which-area': whichWidthWhichArea,
};
