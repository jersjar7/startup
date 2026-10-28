import 'dart:math' as maths;

import 'package:mobile/features/games/above_the_point_game.dart'
    show moistureRounds, Wets, DoesWords;
import 'package:mobile/features/games/aggregate_figures.dart'
    show Grading, GradingPainter, SamplePainter;
import 'package:mobile/features/games/along_or_across_game.dart'
    show layRounds, MixesParts;
import 'package:mobile/features/games/check_every_box_game.dart'
    show boxRounds, table;
import 'package:mobile/features/games/coarse_or_fine_game.dart'
    show sieveRounds, Coarser, CoarserWords;
import 'package:mobile/features/games/concrete_figures.dart' show PourPainter;
import 'package:mobile/features/games/corrosion_figures.dart'
    show CouplePainter;
import 'package:mobile/features/games/does_it_go_up_game.dart'
    show ndsRounds, Moves2, PushWords;
import 'package:mobile/features/games/does_it_make_the_number_game.dart'
    show slabRounds, Passes, PassesWords;
import 'package:mobile/features/games/fiber_figures.dart' show BlendPainter;
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/same_stretch_game.dart'
    show phaseRounds, Phase2, PhaseWords;
import 'package:mobile/features/games/something_is_wrong_game.dart'
    show reportRounds;
import 'package:mobile/features/games/which_mortar_game.dart' show mortarRounds;
import 'package:mobile/features/games/which_one_goes_game.dart'
    show coupleRounds, Eaten;
import 'package:mobile/features/games/which_weighing_game.dart'
    show weighRounds, RecipeParts;
import 'package:mobile/features/games/wood_figures.dart'
    show DryingPainter, Mortar, MortarWords;

import 'package:flutter/material.dart' hide Path, TextPainter;

import 'builder.dart';
import 'fluids.dart' show formulaLine, lone, rects, rows, tapDrawing, top;
import 'nodes.dart';
import 'pick_one_adapter.dart';
import 'statistics.dart' show feedback, perPick, withRounds;

/// The Materials games, second half. Most are the problem, a drawing and
/// the plain white answer rows; the rest answer on rows of their own (a
/// formula, a line of a report, a type in mono) written as screen nodes.

/// An answer row as these games draw their own: white, a 10 pixel corner,
/// its border following the answer, holding [child].
Node framedRow(int i, Node child, {required List<num> pad}) => answer(
  i,
  box(
    w: 'max',
    pad: pad,
    radius: 10,
    border: tone('line', 'ember', 'forest', 'error'),
    stroke: tone(1, 2, 2, 2),
    child: child,
  ),
  radius: 10,
  fill: 'white',
);

/// Answer rows one under another, each with 8 under it.
List<Map<String, Object?>> framedRows(List<Node> rows) => [
  for (final r in rows) ...[r, gap(8)],
];

/// A drawing on the grid the full width, [h] high, that may follow the
/// round.
Node gridDrawing(Object d, num h) => grid(box(w: 'max', h: h, child: draw(d)));

Map<String, Object?> doesItMakeTheNumber() {
  List<bool>? flags(Passes? which) => switch (which) {
    null => null,
    Passes.left => [true, false],
    Passes.right => [false, true],
    Passes.both => [true, true],
    Passes.neither => [false, false],
  };
  return pickScreen(
    id: 'does-it-make-the-number',
    chapter: 'materials',
    title: 'Does It Make the Number',
    closing:
        'The cylinder is cured in a laboratory and the structure is not, '
        'so the lab figure is never the one to compare against the '
        'specification. Take the curing off first. Concrete left to dry '
        'early can lose a third of what it was capable of, which is more '
        'than any sensible change to the mix would ever buy back.',
    right: 'THAT IS RIGHT',
    wrong: 'NOT QUITE',
    brief: briefJson(fieldBrief, 'fieldBrief'),
    rounds: [
      for (final (i, r) in slabRounds.indexed)
        (
          options: [for (final o in Passes.values) o.plain],
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: [
            ...top('WHICH ONE MAKES THE SPECIFICATION', r.subject, r.setting),
            gap(12),
            gridDrawing(
              perPick(
                (pick, answered) =>
                    (canvas, size) => PourPainter(
                      pours: [r.left, r.right],
                      needs: r.needs,
                      picked: flags(pick == null ? null : Passes.values[pick]),
                      answer: answered ? flags(r.answer) : null,
                      locked: answered,
                    ).paint(canvas, size),
                Passes.values.length,
                250,
                what: 'does-it-make-the-number round $i',
              ),
              250,
            ),
            gap(8),
            {
              'mono':
                  'the hatched piece is what the curing takes off the lab '
                  'break',
              'size': 11,
              'color': 'ink3',
            },
            gap(12),
            ...rows(),
          ],
        ),
    ],
  );
}

/// The verdicts of a game that names what was picked: the right answer's
/// name, or the name of the one picked instead.
Map<String, Object?> Function(int) namedVerdicts(
  List<(String, List<String>)> rounds,
) => (i) {
  final (answer, options) = rounds[i];
  return {
    'right': 'THAT IS ${answer.toUpperCase()}',
    'wrong': [for (final o in options) 'THAT IS ${o.toUpperCase()}'],
  };
};

Map<String, Object?> whichWeighing() => withRounds(
  pickScreen(
    id: 'which-weighing',
    chapter: 'materials',
    title: 'Which Weighing',
    closing:
        'Three weighings, four numbers. B minus C is the whole particle, '
        'pores and all, which is what makes a gravity BULK. A minus C '
        'leaves the pores out, which makes it apparent, and it always '
        'comes out the largest. Absorption is the water the pores hold '
        'over the DRY mass, never over the wet one.',
    // Every round names its own verdicts (below).
    right: 'THAT IS IT',
    wrong: 'NOT THAT ONE',
    brief: briefJson(weighingBrief, 'weighingBrief'),
    rounds: [
      for (final (i, r) in weighRounds.indexed)
        (
          options: [for (final o in r.options) o.plain],
          notes: null,
          tex: null,
          answer: r.options.indexOf(r.answer),
          why: r.why,
          source: r.source,
          screen: [
            ...top('WHICH ONE IS IT', r.subject, r.asked),
            gap(12),
            figure(
              (_) =>
                  (canvas, size) =>
                      SamplePainter(sample: r.sample).paint(canvas, size),
              190,
              frame: 'grid',
              what: 'which-weighing round $i',
            ),
            gap(8),
            {
              'mono':
                  'the same stone three times: pores empty, pores full, and '
                  'in water',
              'size': 11,
              'color': 'ink3',
            },
            gap(12),
            ...framedRows([
              for (final (k, o) in r.options.indexed)
                framedRow(k, math(o.tex, 17), pad: const [16, 12, 16, 12]),
            ]),
            ...feedback(6),
          ],
        ),
    ],
  ),
  namedVerdicts([
    for (final r in weighRounds)
      (r.answer.plain, [for (final o in r.options) o.plain]),
  ]),
);

Map<String, Object?> coarseOrFine() {
  int? index(Coarser which) => switch (which) {
    Coarser.first => 0,
    Coarser.second => 1,
    _ => null,
  };
  return pickScreen(
    id: 'coarse-or-fine',
    chapter: 'materials',
    title: 'Coarse or Fine',
    closing:
        'The modulus adds up what each sieve held back, so a higher one '
        'means COARSER, which reads backwards off its name. On the chart '
        'the lower curve is the coarser sand. A concrete sand is normally '
        'asked to sit between 2.3 and 3.1, and two sands can share a '
        'modulus and still be nothing alike, because one number cannot '
        'carry the shape of a curve.',
    right: 'THAT IS THE COARSER ONE',
    wrong: 'THE OTHER WAY',
    brief: briefJson(gradingBrief, 'gradingBrief'),
    rounds: [
      for (final (i, r) in sieveRounds.indexed)
        () {
          final gradings = [r.left, r.right];
          // The game takes the curve with a point nearest the tap, within
          // 30, the first curve's points looked at first.
          final hits = [
            for (final (k, g) in gradings.indexed)
              for (final _ in g.passing) k,
          ];
          // Within a curve the order of its points changes nothing (any of
          // them picks that curve), so each starts at the sieve where the
          // two curves sit furthest apart: the mark a tap is aimed at is
          // then that curve's own, not a point the two share.
          final apart = [
            for (var s = 0; s < r.left.passing.length; s++)
              (r.left.passing[s] - r.right.passing[s]).abs(),
          ];
          final first = apart.indexOf(apart.reduce(maths.max));
          List<Offset> pointsOf(Size size, Grading g) {
            final all = GradingPainter.pointsOf(size, g);
            return [...all.skip(first), ...all.take(first)];
          }

          return (
            options: [for (final o in Coarser.values) o.plain],
            notes: null,
            tex: null,
            answer: r.answer.index,
            why: r.why,
            source: r.source,
            screen: <Map<String, Object?>>[
              ...top('TAP THE COARSER SAND', r.subject, r.asked),
              gap(12),
              grid(
                tapDrawing(
                  h: 240,
                  hits: hits,
                  targets: (canvas, size) {
                    for (final g in gradings) {
                      for (final p in pointsOf(size, g)) {
                        canvas.drawCircle(p, 30, Paint());
                      }
                    }
                  },
                  other: true,
                  draw: (pick, answered) =>
                      (canvas, size) => GradingPainter(
                        gradings: gradings,
                        picked: pick,
                        answer: answered ? index(r.answer) : null,
                        locked: answered,
                      ).paint(canvas, size),
                  what: 'coarse-or-fine round $i',
                ),
              ),
              gap(8),
              t(
                askDone(
                  'percent passing each sieve, coarse sieves on the left',
                  'modulus: blue ${r.left.fm.toStringAsFixed(2)}, '
                      'orange ${r.right.fm.toStringAsFixed(2)}',
                ),
                font: 'mono',
                size: 11,
                color: 'ink3',
              ),
              gap(12),
              ...lone(Coarser.alike.index),
            ],
          );
        }(),
    ],
  );
}

Map<String, Object?> somethingIsWrong() => pickScreen(
  id: 'something-is-wrong',
  chapter: 'materials',
  title: 'Something Is Wrong Here',
  closing:
      'Four checks catch nearly everything. The theoretical maximum is '
      'always bigger than the bulk gravity. The VMA is always bigger '
      'than the air voids. The VFA is a share of the VMA, so it stops '
      'at a hundred. And a VMA near eighty is the stone volume, not the '
      'void space. None of that needs a calculator, and all of it '
      'catches a swapped pair.',
  right: 'THAT ONE CANNOT BE RIGHT',
  wrong: 'THAT LINE IS FINE',
  brief: briefJson(checkBrief, 'checkBrief'),
  rounds: [
    for (final r in reportRounds)
      (
        options: [for (final l in r.lines) l.$1],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...top(
            'TAP THE LINE THAT CANNOT BE RIGHT',
            r.subject,
            'A page from a mix report. One number on it cannot be right.',
          ),
          gap(14),
          ...framedRows([
            for (final (k, (label, value)) in r.lines.indexed)
              framedRow(
                k,
                row([
                  flex(t(label, font: 'mono', size: 12.5, color: 'ink3')),
                  gapW(10),
                  t(value, font: 'mono', size: 13.5, weight: 700),
                ]),
                pad: const [14, 12, 14, 12],
              ),
          ]),
          ...feedback(6),
        ],
      ),
  ],
);

Map<String, Object?> aboveThePoint() => pickScreen(
  id: 'above-the-point',
  chapter: 'materials',
  title: 'Above the Point',
  closing:
      'One threshold decides everything: about thirty percent, the '
      'fiber saturation point. Above it the cell walls are already full '
      'and water comes and goes without changing the timber. Below it '
      'the walls give the water up and the wood shrinks and stiffens, '
      'or takes it back and swells and softens. And the moisture '
      'content is always against the DRY weight, so green timber can '
      'sit well over a hundred percent.',
  right: 'THAT IS WHAT IT DOES',
  wrong: 'NOT QUITE',
  brief: briefJson(moistureBrief, 'moistureBrief'),
  rounds: [
    for (final (i, r) in moistureRounds.indexed)
      (
        options: [for (final o in Wets.values) o.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHAT DOES THE TIMBER DO', r.subject, r.setting),
          gap(12),
          figure(
            (_) =>
                (canvas, size) =>
                    DryingPainter(move: r.move).paint(canvas, size),
            210,
            frame: 'grid',
            what: 'above-the-point round $i',
          ),
          gap(12),
          ...rows(),
        ],
      ),
  ],
);

Map<String, Object?> whichMortar() => pickScreen(
  id: 'which-mortar',
  chapter: 'materials',
  title: 'Which Mortar',
  closing:
      'M, S, N, O: strongest to weakest, and the every-other letter of '
      'MaSoN wOrK. Strength trades against workability and against '
      'forgiveness, so the strongest is not the best: a joint harder '
      'than the brick it joins moves the cracking into the brick. M '
      'below grade, S where there is lateral load, N for general work, '
      'O for soft old masonry indoors.',
  right: 'THAT IS THE ONE',
  wrong: 'NOT THAT ONE',
  brief: briefJson(mortarBrief, 'mortarBrief'),
  rounds: [
    for (final r in mortarRounds)
      (
        options: [for (final o in Mortar.values) o.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('PICK THE TYPE', r.subject, r.asked),
          gap(16),
          ...framedRows([
            for (final o in Mortar.values)
              framedRow(
                o.index,
                t(o.plain, font: 'mono', size: 15),
                pad: const [14, 14, 14, 14],
              ),
          ]),
          ...feedback(6),
        ],
      ),
  ],
);

Map<String, Object?> doesItGoUp() => withRounds(
  pickScreen(
    id: 'does-it-go-up',
    chapter: 'materials',
    title: 'Does It Go Up',
    closing:
        'Wood design is a reference value times a string of factors, and '
        'nearly all of them are penalties: wet service, heat, size. The '
        'load duration factor is the exception and the one worth knowing '
        'cold. The quicker the load comes and goes, the more wood will '
        'carry: 1.6 for wind, 1.25 for a week, 1.0 for normal occupancy, '
        'and 0.9 for a load that never comes off.',
    // Every round names its own (below).
    right: 'THAT IS THE WAY',
    wrong: 'THE OTHER WAY',
    brief: briefJson(factorBrief, 'factorBrief'),
    rounds: [
      for (final r in ndsRounds)
        (
          options: [for (final o in Moves2.values) o.plain],
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: [
            ...top('WHICH WAY DOES THIS FACTOR PUSH', r.subject, r.setting),
            gap(16),
            formulaLine(
              r'$F\prime = F \times C_D \times C_M \times C_t \times \dots$',
              16,
            ),
            gap(10),
            center(
              row([
                t(
                  'the factor here is ',
                  font: 'mono',
                  size: 12.5,
                  color: 'ink3',
                ),
                math(r.factor, 16),
              ], main: 'center'),
            ),
            gap(16),
            ...rows(),
          ],
        ),
    ],
  ),
  (i) => {'right': 'THAT IS THE WAY, ${ndsRounds[i].value.toUpperCase()}'},
);

Map<String, Object?> alongOrAcross() => withRounds(
  pickScreen(
    id: 'along-or-across',
    chapter: 'materials',
    title: 'Along or Across',
    closing:
        'Along the fibers, both materials stretch together and the moduli '
        'add up by volume: a stiff composite. Across them, both carry the '
        'same stress and the soft matrix gives way, so the reciprocals '
        'add and the answer is always the smaller one. Density takes the '
        'additive rule whatever the direction, because weight has no '
        'direction in it.',
    // Every round names its own verdicts (below).
    right: 'THAT IS IT',
    wrong: 'NOT THAT ONE',
    brief: briefJson(blendBrief, 'blendBrief'),
    rounds: [
      for (final (i, r) in layRounds.indexed)
        (
          options: [for (final o in r.options) o.plain],
          notes: null,
          tex: null,
          answer: r.options.indexOf(r.answer),
          why: r.why,
          source: r.source,
          screen: [
            ...top('WHICH RULE APPLIES', r.subject, r.setting),
            gap(12),
            figure(
              (_) =>
                  (canvas, size) => BlendPainter(
                    blend: r.blend,
                    lay: r.lay,
                  ).paint(canvas, size),
              210,
              frame: 'grid',
              what: 'along-or-across round $i',
            ),
            gap(12),
            ...framedRows([
              for (final (k, o) in r.options.indexed)
                framedRow(k, math(o.tex, 17), pad: const [16, 12, 16, 12]),
            ]),
            ...feedback(6),
          ],
        ),
    ],
  ),
  namedVerdicts([
    for (final r in layRounds)
      (r.answer.plain, [for (final o in r.options) o.plain]),
  ]),
);

Map<String, Object?> sameStretch() {
  int? index(Phase2? which) => switch (which) {
    Phase2.fiber => 0,
    Phase2.matrix => 1,
    _ => null,
  };
  return pickScreen(
    id: 'same-stretch',
    chapter: 'materials',
    title: 'Same Stretch, Different Stress',
    closing:
        'Along the fibers the STRAIN is shared, so the stiff phase takes '
        'the stress: the fibers can sit at several times the composite '
        'stress while the matrix barely feels it. Across the fibers the '
        'STRESS is shared instead, and the soft matrix does all the '
        'moving. Whichever one is equal, the other one is not.',
    right: 'THAT IS THE ONE',
    wrong: 'NOT THAT ONE',
    brief: briefJson(isostrainBrief, 'isostrainBrief'),
    rounds: [
      for (final (i, r) in phaseRounds.indexed)
        (
          options: [for (final o in Phase2.values) o.plain],
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: [
            ...top('WHICH PHASE', r.subject, r.asked),
            gap(12),
            gridDrawing(
              perPick(
                (pick, answered) =>
                    (canvas, size) => BlendPainter(
                      blend: r.blend,
                      lay: r.lay,
                      picked: index(pick == null ? null : Phase2.values[pick]),
                      answer: answered ? index(r.answer) : null,
                      locked: answered,
                      stretched: answered,
                    ).paint(canvas, size),
                Phase2.values.length,
                220,
                what: 'same-stretch round $i',
              ),
              220,
            ),
            gap(12),
            ...rows(),
          ],
        ),
    ],
  );
}

Map<String, Object?> whichOneGoes() {
  int? index(Eaten which) => switch (which) {
    Eaten.left => 0,
    Eaten.right => 1,
    _ => null,
  };
  return pickScreen(
    id: 'which-one-goes',
    chapter: 'materials',
    title: 'Which One Goes',
    closing:
        'The more active metal of a pair corrodes and the nobler one is '
        'protected, so no metal is safe or unsafe on its own: steel is '
        'protected next to aluminum and eaten next to copper. A cell '
        'needs two different metals, water, and a path between them. Take '
        'any one of those away, with a gasket or with drainage, and '
        'nothing happens.',
    right: 'THAT IS THE ONE',
    wrong: 'NOT THAT ONE',
    brief: briefJson(galvanicBrief, 'galvanicBrief'),
    rounds: [
      for (final (i, r) in coupleRounds.indexed)
        () {
          // The game takes the first plate whose box, 10 larger, holds the
          // tap.
          final plates = rects(
            2,
            (size, k) => CouplePainter.plateOf(size, k).inflate(10),
          );
          return (
            options: [for (final o in Eaten.values) r.labelFor(o)],
            notes: null,
            tex: null,
            answer: r.answer.index,
            why: r.why,
            source: r.source,
            screen: <Map<String, Object?>>[
              ...top('WHICH ONE CORRODES', r.subject, r.setting),
              gap(12),
              grid(
                tapDrawing(
                  h: 200,
                  hits: plates.hits,
                  targets: plates.targets,
                  other: true,
                  draw: (pick, answered) =>
                      (canvas, size) => CouplePainter(
                        couple: r.couple,
                        picked: pick,
                        answer: answered ? index(r.answer) : null,
                        locked: answered,
                      ).paint(canvas, size),
                  what: 'which-one-goes round $i',
                ),
              ),
              gap(12),
              ...rows(),
            ],
          );
        }(),
    ],
  );
}

Map<String, Object?> checkEveryBox() => pickScreen(
  id: 'check-every-box',
  chapter: 'materials',
  title: 'Check Every Box',
  closing:
      'Take the requirements one at a time and cross candidates off. '
      'The metal that wins a column is rarely the one that passes them '
      'all: copper conducts best and is far too heavy, titanium '
      'survives anything and hardly conducts. And notice when a '
      'requirement rules nothing out, or when nothing passes at all. '
      'Both mean the specification needs another look.',
  right: 'THAT IS THE ONE',
  wrong: 'READ THE REST',
  brief: briefJson(pickingBrief, 'pickingBrief'),
  rounds: [
    for (final r in boxRounds)
      (
        options: [for (final l in table) l.line, 'None of them passes'],
        notes: null,
        tex: null,
        answer: r.answer == null
            ? table.length
            : table.indexWhere((l) => l.metal == r.answer),
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHICH ONE PASSES EVERY TEST', r.subject, r.job),
          gap(12),
          box(
            w: 'max',
            pad: const [14, 12, 14, 12],
            fill: 'cream',
            radius: 10,
            border: 'line',
            cross: 'start',
            c: [
              t('IT MUST', font: 'overline', color: 'ink3'),
              gapH(6),
              for (final need in r.needs)
                box(
                  pad: const [0, 0, 0, 3],
                  child: t('- $need', font: 'mono', size: 12.5),
                ),
            ],
          ),
          gap(12),
          ...framedRows([
            for (final (k, l) in table.indexed)
              framedRow(
                k,
                t(l.line, font: 'mono', size: 12.5),
                pad: const [14, 12, 14, 12],
              ),
          ]),
          framedRow(
            table.length,
            t('None of them passes', font: 'mono', size: 12.5),
            pad: const [14, 12, 14, 12],
          ),
          ...feedback(14),
        ],
      ),
  ],
);

final adapters = <String, Map<String, Object?> Function()>{
  'does-it-make-the-number': doesItMakeTheNumber,
  'which-weighing': whichWeighing,
  'coarse-or-fine': coarseOrFine,
  'something-is-wrong': somethingIsWrong,
  'above-the-point': aboveThePoint,
  'which-mortar': whichMortar,
  'does-it-go-up': doesItGoUp,
  'along-or-across': alongOrAcross,
  'same-stretch': sameStretch,
  'which-one-goes': whichOneGoes,
  'check-every-box': checkEveryBox,
};
