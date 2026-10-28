import 'package:mobile/features/games/add_up_the_losses_game.dart';
import 'package:mobile/features/games/does_the_model_run_faster_game.dart';
import 'package:mobile/features/games/float_or_sink_game.dart';
import 'package:mobile/features/games/fluid_figures.dart';
import 'package:mobile/features/games/gauge_or_absolute_game.dart';
import 'package:mobile/features/games/how_fast_the_jet_game.dart';
import 'package:mobile/features/games/how_much_faster_game.dart';
import 'package:mobile/features/games/laminar_or_turbulent_game.dart';
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/meter_figures.dart';
import 'package:mobile/features/games/model_figures.dart';
import 'package:mobile/features/games/momentum_figures.dart';
import 'package:mobile/features/games/pipe_figures.dart';
import 'package:mobile/features/games/same_depth_game.dart';
import 'package:mobile/features/games/too_big_or_too_small_game.dart';
import 'package:mobile/features/games/walk_the_manometer_game.dart';
import 'package:mobile/features/games/what_happens_to_the_loss_game.dart';
import 'package:mobile/features/games/where_it_pushes_game.dart';
import 'package:mobile/features/games/where_the_block_goes_game.dart';
import 'package:mobile/features/games/where_the_pressure_is_game.dart';
import 'package:mobile/features/games/which_area_goes_in_game.dart';
import 'package:mobile/features/games/which_drags_more_game.dart';
import 'package:mobile/features/games/which_one_needs_a_block_game.dart';
import 'package:mobile/features/games/which_one_to_match_game.dart';
import 'package:mobile/features/games/which_property_game.dart';
import 'package:mobile/features/games/which_target_takes_more_game.dart';
import 'package:mobile/features/games/which_tube_climbs_game.dart';

import 'package:flutter/material.dart' hide Path, TextPainter;

import 'builder.dart';
import 'nodes.dart';
import 'pick_one_adapter.dart';
import 'statistics.dart' show feedback, overline, subject;

/// The Fluid Mechanics games. Their answers are the plain white rows the
/// pack draws as `choices`, so most screens are blocks: the problem, a
/// formula, a drawing, the answers. The drawings answered by tapping, and
/// the pictures that are themselves the answers, are screen nodes.

/// The usual top of a round: the overline, the subject and the setting.
List<Map<String, Object?>> top(String heading, String about, String setting) =>
    [
      overline(heading),
      gap(6),
      subject(about),
      gap(10),
      {'text': setting, 'size': 15},
    ];

/// A formula centred on its own line.
Map<String, Object?> formulaLine(String tex, num size) => {
  'math': tex,
  'size': size,
};

/// The answer rows, each with 8 under it, then the feedback 6 further down.
List<Map<String, Object?>> rows({List<int>? only}) => [
  {'choices': only ?? true, 'space': 8, 'last': true},
  ...feedback(6),
];

/// One answer row on its own (the "neither" under two pictures), with the
/// feedback [space] below it.
List<Map<String, Object?>> lone(int i, {num space = 14}) => [
  {
    'choices': [i],
    'space': 8,
  },
  ...feedback(space),
];

/// A picture that is itself an answer: white, its border following the
/// answer, the drawing inset by 4 on a finer grid. The drawing follows the
/// round too, since several show their result once answered, and it is
/// recorded at each size the border leaves it.
Node picturePanel(
  int i,
  double h,
  Draw Function(bool answered) paint, {
  required String what,
}) {
  Object at(bool answered, bool thin) => record(
    paint(answered),
    h - 8 - (thin ? 2 : 4),
    // A panel in a row of two is under half the game's width.
    range: (100, 500),
    what: '$what ${answered ? 'answered' : 'asked'} ${thin ? 'idle' : 'lit'}',
  );
  final lit = at(true, false);
  return answer(
    i,
    box(
      h: h,
      pad: const [4, 4, 4, 4],
      radius: 12,
      border: tone('line', 'ember', 'forest', 'error'),
      stroke: tone(1, 2, 2, 2),
      child: clip(
        grid(
          draw(
            askDone(
              tone(at(false, true), at(false, false), null, null),
              tone(at(true, true), null, lit, lit),
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

/// A drawing answered by tapping on it: drawn with each answer picked (or
/// none), before and after the answer. [hits] lists the answers the
/// targets stand for, in the order [targets] draws them; a later target
/// wins where two overlap, so a game that takes the first match lists them
/// backwards. [other] when an answer off the drawing can be picked, so the
/// drawing is also needed answered with nothing on it picked.
Node tapDrawing({
  required double h,
  required List<int> hits,
  required Draw Function(int? pick, bool answered) draw,
  required Draw targets,
  bool other = false,
  required String what,
}) => {
  'k': 'tapdraw',
  'd': {
    for (final answered in [false, true])
      for (final mark in [null, for (var m = 0; m < hits.length; m++) m])
        if (mark == null || hits.indexOf(hits[mark]) == mark)
          if (!(answered && mark == null) || other)
            '${mark ?? '-'}|${answered ? 1 : 0}': record(
              draw(mark == null ? null : hits[mark], answered),
              h,
              what: '$what ${mark ?? 'none'}${answered ? ' answered' : ''}',
            ),
  },
  'targets': record(targets, h, what: '$what targets'),
  'hits': hits,
  'h': h,
};

/// A tap drawing in a white bordered frame. The game hit-tests the whole
/// frame, border and all, so each target is placed as the game places it
/// on the outer size and moved in by the border.
Node framedTap({
  required double h,
  required int marks,
  required Draw Function(int? pick, bool answered) draw,
  required Offset Function(Size outer, int i) spot,
  required String what,
}) => box(
  w: 'max',
  h: h,
  fill: 'white',
  radius: 12,
  border: 'line',
  child: clip(
    grid(
      tapDrawing(
        h: h - 2,
        hits: [for (var i = 0; i < marks; i++) i],
        draw: draw,
        targets: (canvas, size) {
          final outer = Size(size.width + 2, size.height + 2);
          for (var i = 0; i < marks; i++) {
            canvas.drawCircle(spot(outer, i) - const Offset(1, 1), 26, Paint());
          }
        },
        what: what,
      ),
    ),
    11,
  ),
);

/// Rectangles to tap, listed backwards (see [tapDrawing]).
({List<int> hits, Draw targets}) rects(
  int n,
  Rect Function(Size size, int i) area,
) => (
  hits: [for (var i = n - 1; i >= 0; i--) i],
  targets: (canvas, size) {
    for (var i = n - 1; i >= 0; i--) {
      canvas.drawRect(area(size, i), Paint());
    }
  },
);

Map<String, Object?> addUpTheLosses() => pickScreen(
  id: 'add-up-the-losses',
  chapter: 'fluid-mechanics',
  title: 'Add Up the Losses',
  closing:
      'The total is the pipe friction PLUS every fitting, with each '
      'fitting at its own coefficient times the same velocity head. '
      'Count the fittings off the drawing rather than reaching for a '
      'multiplier, label every number you write down so a total does '
      'not get added twice, and remember that a globe valve can cost '
      'more than the pipe it sits in.',
  right: 'THAT IS IT',
  wrong: 'NOT THAT',
  brief: briefJson(minorBrief, 'minorBrief'),
  rounds: [
    for (final r in tallyRounds)
      (
        options: [for (final o in r.options) o.plain],
        notes: null,
        tex: null,
        answer: r.options.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          overline('WHAT IS WRONG WITH THIS LINE'),
          gap(6),
          subject(r.subject),
          gap(10),
          {'mono': 'The system: ${r.setting}.', 'size': 12, 'color': 'ink3'},
          gap(14),
          box(
            w: 'max',
            pad: [14, 16, 14, 16],
            fill: 'cream',
            radius: 10,
            border: 'line',
            child: center(math(r.written, 16)),
          ),
          gap(14),
          ...rows(),
        ],
      ),
  ],
);

Map<String, Object?> gaugeOrAbsolute() => pickScreen(
  id: 'gauge-or-absolute',
  chapter: 'fluid-mechanics',
  title: 'Gauge or Absolute',
  closing:
      'Gauge counts from the atmosphere and absolute counts from a '
      'vacuum, and they differ by 101.3 kilopascals of air. Anything '
      'open to the sky reads zero gauge at its surface, which is why '
      'the depth formula gives gauge pressure directly and why an open '
      'manometer does too. Absolute is only wanted when the problem '
      'says the word.',
  right: 'THAT IS IT',
  wrong: 'NOT THAT',
  brief: briefJson(gaugeBrief, 'gaugeBrief'),
  rounds: [
    for (final r in gaugeRounds)
      (
        options: [for (final f in Fix.values) f.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          overline('WHAT IS LEFT TO DO'),
          gap(6),
          subject(r.subject),
          gap(12),
          box(
            w: 'max',
            pad: [14, 12, 14, 12],
            fill: 'cream',
            radius: 10,
            border: 'line',
            cross: 'start',
            c: [
              t('YOU HAVE', font: 'overline', color: 'ink3'),
              gapH(4),
              t(r.have, size: 14.5, line: 1.45),
              gapH(10),
              t('THE QUESTION WANTS', font: 'overline', color: 'ember'),
              gapH(4),
              t(r.wanted, size: 14.5, line: 1.45),
            ],
          ),
          gap(14),
          formulaLine(r'$P_{abs} = P_{atm} + P_{gauge}$', 16),
          gap(14),
          ...rows(),
        ],
      ),
  ],
);

/// A round of a problem, a formula and the answer rows, 16 apart.
ScreenRound formulaRound({
  required String heading,
  required String about,
  required String setting,
  required String tex,
  required List<String> options,
  required int answer,
  required String why,
  required String source,
}) => (
  options: options,
  notes: null,
  tex: null,
  answer: answer,
  why: why,
  source: source,
  screen: [
    ...top(heading, about, setting),
    gap(16),
    formulaLine(tex, 17),
    gap(16),
    ...rows(),
  ],
);

Map<String, Object?> laminarOrTurbulent() => pickScreen(
  id: 'laminar-or-turbulent',
  chapter: 'fluid-mechanics',
  title: 'Laminar or Turbulent',
  closing:
      'Under 2,100 is laminar and the friction factor is just 64 over '
      'the Reynolds number. Over 10,000 is fully turbulent and the '
      'factor comes off the Moody diagram. In between is transitional '
      'and nobody designs there on purpose. Water in any pipe you could '
      'crawl through is turbulent, so a small Reynolds number for a '
      'water main is usually a units mistake.',
  right: 'THAT IS THE BAND',
  wrong: 'NOT THAT BAND',
  brief: briefJson(reynoldsBrief, 'reynoldsBrief'),
  rounds: [
    for (final r in reynoldsRounds)
      formulaRound(
        heading: 'WHAT IS THIS FLOW',
        about: r.subject,
        setting: r.setting,
        tex: r'$Re = \dfrac{vD}{\nu}$',
        options: [for (final o in Regime.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
      ),
  ],
);

Map<String, Object?> howMuchFaster() => pickScreen(
  id: 'how-much-faster',
  chapter: 'fluid-mechanics',
  title: 'How Much Faster',
  closing:
      'The same water has to get through whatever opening you give it, '
      'so the speed goes up in proportion to the AREA it loses. Areas '
      'go as the square of a diameter or a side, which is why halving '
      'the bore quadruples the speed and a third of the bore is nine '
      'times. Length never comes into it.',
  right: 'THAT IS THE FACTOR',
  wrong: 'NOT THAT ONE',
  brief: briefJson(continuityBrief, 'continuityBrief'),
  rounds: [
    for (final r in fasterRounds)
      formulaRound(
        heading: 'WHAT HAPPENS TO THE SPEED',
        about: r.subject,
        setting: r.change,
        tex: r'$A_1 v_1 = A_2 v_2$',
        options: [for (final o in r.options) o.plain],
        answer: r.options.indexOf(r.answer),
        why: r.why,
        source: r.source,
      ),
  ],
);

Map<String, Object?> whatHappensToTheLoss() => pickScreen(
  id: 'what-happens-to-the-loss',
  chapter: 'fluid-mechanics',
  title: 'What Happens to the Loss',
  closing:
      'The velocity is squared, so it dominates: twice the speed is '
      'four times the loss. Length and the friction factor are in '
      'direct proportion. The diameter halves the loss on its own, and '
      'at a fixed FLOW it does far more than that, because a bigger '
      'pipe is also a slower one: one size up can cut the loss thirty '
      'times over.',
  right: 'THAT IS THE FACTOR',
  wrong: 'NOT THAT ONE',
  brief: briefJson(darcyBrief, 'darcyBrief'),
  rounds: [
    for (final r in lossRounds)
      formulaRound(
        heading: 'WHAT HAPPENS TO THE FRICTION LOSS',
        about: r.subject,
        setting: r.change,
        tex: r'$h_f = f \dfrac{L}{D} \dfrac{v^2}{2g}$',
        options: [for (final o in r.options) o.plain],
        answer: r.options.indexOf(r.answer),
        why: r.why,
        source: r.source,
      ),
  ],
);

Map<String, Object?> tooBigOrTooSmall() {
  Node side(String label, String color, String tex) => flex(
    col([
      t(label, font: 'mono', size: 10.5, color: color),
      gapH(6),
      math(tex, 15),
    ]),
  );
  return pickScreen(
    id: 'too-big-or-too-small',
    chapter: 'fluid-mechanics',
    title: 'Too Big or Too Small',
    closing:
        'A coefficient left out or set too high sends the answer up, and '
        'so does anything that shrinks the correction underneath, since '
        'it sits under the line. The missing 2 and the pressure left in '
        'kilopascals send it down. The elevation terms do nothing at all '
        'on a level meter, which is why they are so easy to forget on a '
        'sloped one.',
    right: 'THAT IS WHERE IT LANDS',
    wrong: 'THE OTHER WAY',
    brief: briefJson(coefficientBrief, 'coefficientBrief'),
    rounds: [
      for (final r in slipRounds)
        (
          options: [for (final s in Sits.values) s.plain],
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: [
            ...top('WHERE DOES THE ANSWER LAND', r.subject, r.setting),
            gap(14),
            formulaLine(r.formula, 16),
            gap(12),
            box(
              w: 'max',
              pad: [14, 12, 14, 12],
              fill: 'white',
              radius: 12,
              border: 'line',
              child: row([
                side('what belongs', 'ink3', r.belongs),
                box(w: 1, h: 40, fill: 'line'),
                side('what went in', 'error', r.wrote),
              ]),
            ),
            gap(14),
            ...rows(),
          ],
        ),
    ],
  );
}

Map<String, Object?> whichProperty() => pickScreen(
  id: 'which-property',
  chapter: 'fluid-mechanics',
  title: 'Which Property Is That',
  closing:
      'Density is mass in a cubic meter and has kilograms in it. '
      'Specific weight is what that cubic meter weighs and has newtons '
      'in it, which is why the pressure formula wants it. Specific '
      'gravity is the ratio to water and has nothing after it at all. '
      'Multiply a density by g to get a specific weight, and a specific '
      'gravity by water\'s 9,810 to get the same thing.',
  right: 'THAT IS THE ONE',
  wrong: 'NOT THAT ONE',
  brief: briefJson(threeNumbersBrief, 'threeNumbersBrief'),
  rounds: [
    for (final r in propertyRounds)
      (
        options: [for (final p in Property.values) p.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHICH PROPERTY IS IT', r.subject, r.asked),
          gap(18),
          for (final p in Property.values) ...[
            answer(
              p.index,
              box(
                w: 'max',
                pad: [14, 12, 14, 12],
                radius: 10,
                border: tone('line', 'ember', 'forest', 'error'),
                stroke: tone(1, 2, 2, 2),
                child: row([
                  box(w: 34, child: math(p.tex, 17)),
                  flex(t(p.plain, size: 14.5)),
                ]),
              ),
              radius: 10,
              fill: 'white',
            ),
            gap(8),
          ],
          ...feedback(6),
        ],
      ),
  ],
);

Map<String, Object?> doesTheModelRunFaster() => pickScreen(
  id: 'does-the-model-run-faster',
  chapter: 'fluid-mechanics',
  title: 'Does the Model Run Faster',
  closing:
      'Froude carries the speed over the root of the length, so the '
      'speed follows the size by its square root. Reynolds carries the '
      'speed times the length, so the speed goes the other way, by the '
      'full ratio. Neither law means faster or slower on its own: it '
      'depends which way the size went, and a small Reynolds model '
      'asking for ten times the speed is often the end of the idea.',
  right: 'THAT IS WHERE IT SITS',
  wrong: 'THE OTHER WAY',
  brief: briefJson(scalingBrief, 'scalingBrief'),
  rounds: [
    for (final (i, r) in twinRounds.indexed)
      (
        options: [for (final o in Runs2.values) o.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHERE DOES THE MODEL SPEED SIT', r.subject, r.setting),
          gap(12),
          figure(
            (_) =>
                (canvas, size) =>
                    TwinsPainter(twins: r.twins).paint(canvas, size),
            130,
            frame: 'panel',
            what: 'does-the-model-run-faster round $i',
          ),
          gap(12),
          formulaLine(
            r.twins.law == Law.froude
                ? r'$\frac{v_m}{\sqrt{g l_m}} = \frac{v_p}{\sqrt{g l_p}}$'
                : r'$\frac{v_m l_m}{\nu} = \frac{v_p l_p}{\nu}$',
            16,
          ),
          gap(14),
          ...rows(),
        ],
      ),
  ],
);

Map<String, Object?> floatOrSink() => pickScreen(
  id: 'float-or-sink',
  chapter: 'fluid-mechanics',
  title: 'Float or Sink',
  closing:
      'Two numbers: what the body weighs, and what the water it shoves '
      'aside weighs. Bigger push and it rises, bigger weight and it '
      'sinks, equal and it hangs. Only the DISPLACED volume counts, so '
      'a hollow box and a solid block of the same steel behave nothing '
      'alike, and an empty buried tank will lift itself out of wet '
      'ground.',
  right: 'THAT IS THE WAY',
  wrong: 'THE OTHER WAY',
  brief: briefJson(buoyancyBrief, 'buoyancyBrief'),
  rounds: [
    for (final (i, r) in floatRounds.indexed)
      (
        options: [for (final o in Goes2.values) o.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHICH WAY DOES IT GO', r.subject, r.setting),
          gap(12),
          figure(
            (answered) =>
                (canvas, size) => LumpPainter(
                  lump: r.lump,
                  showForces: answered,
                ).paint(canvas, size),
            210,
            frame: 'grid',
            what: 'float-or-sink round $i',
          ),
          gap(8),
          t(
            askDone(
              'the arrows go on once you answer: their lengths are the '
                  'answer',
              'the two arrows are drawn to one scale',
            ),
            font: 'mono',
            size: 11,
            color: 'ink3',
          ),
          gap(10),
          formulaLine(r'$F_B = \gamma V_{displaced}$', 16),
          gap(12),
          ...rows(),
        ],
      ),
  ],
);

Map<String, Object?> howFastTheJet() => pickScreen(
  id: 'how-fast-the-jet',
  chapter: 'fluid-mechanics',
  title: 'How Fast the Jet',
  closing:
      'The jet leaves at the root of twice g times the HEAD, and '
      'nothing else is in it: not the size of the hole, not the width '
      'of the tank, not how much water is behind it. The hole decides '
      'how much comes out, not how fast. And the square root softens '
      'the head, so four times the depth is only twice the speed.',
  right: 'THAT IS THE ONE',
  wrong: 'THE OTHER WAY',
  brief: briefJson(torricelliBrief, 'torricelliBrief'),
  rounds: [
    for (final (i, r) in jetRounds.indexed)
      (
        options: [for (final o in Quicker2.values) o.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHICH JET IS FASTER', r.subject, r.setting),
          gap(12),
          answerRow([
            for (final (k, s) in [r.left, r.right].indexed)
              picturePanel(
                k,
                210,
                (answered) =>
                    (canvas, size) => SquirtPainter(
                      squirt: s,
                      tallest: r.tallest,
                      showJet: answered,
                    ).paint(canvas, size),
                what: 'how-fast-the-jet round $i jet $k',
              ),
          ]),
          gap(10),
          formulaLine(r'$v = \sqrt{2gh}$', 17),
          gap(12),
          ...lone(Quicker2.tie.index),
        ],
      ),
  ],
);

Map<String, Object?> whichDragsMore() => pickScreen(
  id: 'which-drags-more',
  chapter: 'fluid-mechanics',
  title: 'Which One Drags More',
  closing:
      'The oil and the speed multiply and the film thickness divides, '
      'so a thinner film drags harder: that is the one that reads '
      'backwards. What the fluid actually feels is the velocity '
      'gradient, the speed over the gap, which is why halving both '
      'changes nothing. And the viscosity in this formula is always the '
      'dynamic one, in pascal seconds.',
  right: 'THAT IS THE ONE',
  wrong: 'THE OTHER WAY',
  brief: briefJson(viscosityBrief, 'viscosityBrief'),
  rounds: [
    for (final (i, r) in dragRounds.indexed)
      (
        options: [for (final o in Drags.values) o.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHICH PLATE IS HARDER TO SLIDE', r.subject, r.setting),
          gap(12),
          answerRow([
            for (final (k, f) in [r.left, r.right].indexed)
              picturePanel(
                k,
                190,
                (_) =>
                    (canvas, size) => FilmPainter(
                      film: f,
                      thickest: r.thickest,
                    ).paint(canvas, size),
                what: 'which-drags-more round $i plate $k',
              ),
          ]),
          gap(10),
          formulaLine(r'$\tau = \mu \dfrac{v}{\delta}$', 17),
          gap(12),
          ...lone(Drags.same.index),
        ],
      ),
  ],
);

Map<String, Object?> whichTargetTakesMore() => pickScreen(
  id: 'which-target-takes-more',
  chapter: 'fluid-mechanics',
  title: 'Which Target Takes More',
  closing:
      'A jet pushes by being turned. Straight through is no push at '
      'all, a flat plate takes all the momentum the water had along '
      'the jet, and a face that sends it back takes twice that. Speed '
      'and bore both count twice over, so they outrun anything the '
      'shape can do.',
  right: 'THAT IS THE ONE',
  wrong: 'ANOTHER FACE',
  brief: briefJson(deflectionBrief, 'deflectionBrief'),
  rounds: [
    for (final (i, r) in hitRounds.indexed)
      (
        options: [for (var k = 0; k < r.faces.length; k++) 'face ${k + 1}'],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHICH ONE IS PUSHED HARDEST', r.subject, r.setting),
          gap(12),
          for (var line = 0; line < 2; line++) ...[
            if (line > 0) gap(8),
            answerRow([
              for (var c = 0; c < 2; c++)
                picturePanel(
                  line * 2 + c,
                  150,
                  (answered) =>
                      (canvas, size) => HitPainter(
                        hit: r.faces[line * 2 + c],
                        biggest: r.biggest,
                        showPush: answered,
                      ).paint(canvas, size),
                  what: 'which-target-takes-more round $i face ${line * 2 + c}',
                ),
            ]),
          ],
          ...feedback(14),
        ],
      ),
  ],
);

Map<String, Object?> walkTheManometer() => pickScreen(
  id: 'walk-the-manometer',
  chapter: 'fluid-mechanics',
  title: 'Walk the Manometer',
  closing:
      'Start where the pressure is known and walk. Down a column adds, '
      'up a column subtracts, sideways in the same fluid changes '
      'nothing, and a stretch of air changes nothing either. Each fluid '
      'carries its own weight, so a column of water adds about a '
      'thirteenth of what the same drop in mercury would.',
  right: 'THAT IS THE WAY',
  wrong: 'THE OTHER WAY',
  brief: briefJson(manometerBrief, 'manometerBrief'),
  rounds: [
    for (final (i, r) in walkRounds.indexed)
      (
        options: [for (final o in Step2.values) o.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('ONE STEP OF THE WALK', r.subject, r.asked),
          gap(12),
          figure(
            (_) =>
                (canvas, size) => UTubePainter(
                  tube: r.tube,
                  from: r.from,
                  to: r.to,
                ).paint(canvas, size),
            250,
            frame: 'grid',
            what: 'walk-the-manometer round $i',
          ),
          gap(12),
          ...rows(),
        ],
      ),
  ],
);

Map<String, Object?> whichOneToMatch() => pickScreen(
  id: 'which-one-to-match',
  chapter: 'fluid-mechanics',
  title: 'Which One to Match',
  closing:
      'Look for the free surface. If the water has one and the thing '
      'you care about happens at it, gravity is shaping the flow and '
      'Froude has to match: spillways, weirs, rivers, hulls. If there '
      'is no surface in it, viscosity is what is left and Reynolds has '
      'to match: pipe fittings, valves, submerged bodies, wind '
      'tunnels. At full size the question does not arise.',
  right: 'THAT IS THE ONE',
  wrong: 'THE OTHER ONE',
  brief: briefJson(similitudeBrief, 'similitudeBrief'),
  rounds: [
    for (final (i, r) in benchRounds.indexed)
      (
        options: [for (final o in Law.values) o.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHICH NUMBER HAS TO MATCH', r.subject, r.setting),
          gap(12),
          figure(
            (_) =>
                (canvas, size) => BenchPainter(
                  bench: r.bench,
                  caption: r.caption,
                ).paint(canvas, size),
            150,
            frame: 'panel',
            what: 'which-one-to-match round $i',
          ),
          gap(12),
          row([
            math(r'$Re = \frac{\rho v l}{\mu}$', 15, color: 'ink2'),
            math(r'$Fr = \frac{v}{\sqrt{gl}}$', 15, color: 'ink2'),
          ], main: 'evenly'),
          gap(14),
          ...rows(),
        ],
      ),
  ],
);

Map<String, Object?> sameDepth() {
  int? side(Harder h) => h == Harder.alike ? null : h.index;
  return pickScreen(
    id: 'same-depth',
    chapter: 'fluid-mechanics',
    title: 'Same Depth, Same Pressure',
    closing:
        'Two things decide it: how deep the point is below the free '
        'surface, and what the liquid weighs. Nothing else. Not the shape '
        'of the vessel, not how much liquid there is, not how wide the '
        'surface is. A narrow pipe of water and a lake of it, at the same '
        'depth, press equally hard.',
    right: 'THAT IS RIGHT',
    wrong: 'NOT QUITE',
    brief: briefJson(depthBrief, 'depthBrief'),
    rounds: [
      for (final (i, r) in depthRounds.indexed)
        () {
          const h = 230.0;
          // The game takes the half of the drawing the tap is in.
          final halves = rects(
            2,
            (size, k) =>
                Rect.fromLTWH(size.width / 2 * k, 0, size.width / 2, h),
          );
          return (
            options: [for (final o in Harder.values) o.plain],
            notes: null,
            tex: null,
            answer: r.answer.index,
            why: r.why,
            source: r.source,
            screen: <Map<String, Object?>>[
              ...top('TAP THE POINT UNDER MORE PRESSURE', r.subject, r.setting),
              gap(12),
              grid(
                tapDrawing(
                  h: h,
                  hits: halves.hits,
                  targets: halves.targets,
                  other: true,
                  draw: (pick, answered) =>
                      (canvas, size) => PotPainter(
                        pots: r.both,
                        deepest: r.deepest,
                        picked: pick,
                        answer: answered ? side(r.answer) : null,
                        locked: answered,
                      ).paint(canvas, size),
                  what: 'same-depth round $i',
                ),
              ),
              gap(10),
              formulaLine(r'$p = \gamma h$', 17),
              gap(12),
              ...lone(Harder.alike.index),
            ],
          );
        }(),
    ],
  );
}

Map<String, Object?> whichTubeClimbs() {
  int? side(Climbs c) => c == Climbs.level ? null : c.index;
  return pickScreen(
    id: 'which-tube-climbs',
    chapter: 'fluid-mechanics',
    title: 'Which Tube Climbs Higher',
    closing:
        'The bore is underneath, so a narrower tube climbs higher, in '
        'direct proportion: half the bore is twice the rise. Surface '
        'tension is on top and the liquid\'s weight is underneath, so a '
        'heavier or less sticky liquid climbs less. And a liquid that '
        'does not wet the glass has a contact angle past ninety, which '
        'turns the cosine negative and pushes it down the tube instead.',
    right: 'THAT IS THE HIGHER ONE',
    wrong: 'THE OTHER WAY',
    brief: briefJson(capillaryBrief, 'capillaryBrief'),
    rounds: [
      for (final (i, r) in tubeRounds.indexed)
        () {
          final tubes = rects(
            2,
            (size, k) => CapillaryPainter.tubeOf(size, r.both, k).inflate(12),
          );
          return (
            options: [for (final o in Climbs.values) o.plain],
            notes: null,
            tex: null,
            answer: r.answer.index,
            why: r.why,
            source: r.source,
            screen: <Map<String, Object?>>[
              ...top('TAP THE TUBE THAT CLIMBS HIGHER', r.subject, r.setting),
              gap(12),
              grid(
                tapDrawing(
                  h: 240,
                  hits: tubes.hits,
                  targets: tubes.targets,
                  other: true,
                  draw: (pick, answered) =>
                      (canvas, size) => CapillaryPainter(
                        straws: r.both,
                        picked: pick,
                        answer: answered ? side(r.answer) : null,
                        locked: answered,
                        showLevels: answered,
                      ).paint(canvas, size),
                  what: 'which-tube-climbs round $i',
                ),
              ),
              gap(8),
              t(
                askDone(
                  'bores drawn far wider than they are. the liquid is drawn '
                      'once you answer',
                  'the columns are drawn to one scale',
                ),
                font: 'mono',
                size: 11,
                color: 'ink3',
              ),
              gap(10),
              formulaLine(r'$h = \dfrac{4\sigma \cos\beta}{\gamma d}$', 17),
              gap(12),
              ...lone(Climbs.level.index),
            ],
          );
        }(),
    ],
  );
}

Map<String, Object?> whereItPushes() => pickScreen(
  id: 'where-it-pushes',
  chapter: 'fluid-mechanics',
  title: 'Where It Pushes',
  closing:
      'The force comes from the pressure at the CENTROID times the '
      'area, and it acts lower, at the center of pressure, because the '
      'push is bottom heavy. For a gate with its top at the surface '
      'that is two thirds of the way down. The deeper the gate, the '
      'smaller the gap between the two, until on a deep gate they are '
      'centimeters apart.',
  right: 'THAT IS THE POINT',
  wrong: 'NOT THAT ONE',
  brief: briefJson(gateBrief, 'gateBrief'),
  rounds: [
    for (final (i, r) in pushRounds2.indexed)
      (
        options: [for (final m in r.among) m.name],
        notes: null,
        tex: null,
        answer: r.among.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          ...top('TAP THE POINT ON THE GATE', r.subject, r.asked),
          gap(12),
          grid(
            tapDrawing(
              h: 260,
              hits: [for (var k = 0; k < r.among.length; k++) k],
              targets: (canvas, size) {
                for (final m in r.among) {
                  canvas.drawCircle(
                    GatePainter.spotOf(size, r.gate, m),
                    34,
                    Paint(),
                  );
                }
              },
              draw: (pick, answered) =>
                  (canvas, size) => GatePainter(
                    gate: r.gate,
                    among: r.among,
                    picked: pick == null ? null : r.among[pick],
                    answer: r.answer,
                    locked: answered,
                  ).paint(canvas, size),
              what: 'where-it-pushes round $i',
            ),
          ),
          gap(8),
          {
            'mono': 'the arrows are the water pressure, growing with depth',
            'size': 11,
            'color': 'ink3',
          },
          ...feedback(),
        ],
      ),
  ],
);

Map<String, Object?> whereThePressureIs() => pickScreen(
  id: 'where-the-pressure-is',
  chapter: 'fluid-mechanics',
  title: 'Where the Pressure Is',
  closing:
      'Along a level pipe the heads trade: where the water speeds up, '
      'the pressure falls, and where it slows down again the pressure '
      'comes back. So the narrowest section is both the fastest and the '
      'one at the lowest pressure, which feels backwards and is the '
      'whole of Bernoulli. A venturi is that drop, sold as an '
      'instrument.',
  right: 'THAT IS THE ONE',
  wrong: 'THE OTHER WAY',
  brief: briefJson(bernoulliBrief, 'bernoulliBrief'),
  rounds: [
    for (final (i, r) in pressureRounds.indexed)
      () {
        final n = r.run.bores.length;
        final sections = rects(
          n,
          (size, k) => RunPainter.sectionOf(size, r.run, k).inflate(14),
        );
        return (
          options: [for (var k = 0; k < n; k++) 'section ${k + 1}'],
          notes: null,
          tex: null,
          answer: r.answer,
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            ...top('TAP THE SECTION', r.subject, r.asked),
            gap(12),
            grid(
              tapDrawing(
                h: 210,
                hits: sections.hits,
                targets: sections.targets,
                draw: (pick, answered) =>
                    (canvas, size) => RunPainter(
                      run: r.run,
                      picked: pick,
                      answer: answered ? r.answer : null,
                      locked: answered,
                    ).paint(canvas, size),
                what: 'where-the-pressure-is round $i',
              ),
            ),
            gap(8),
            t(
              askDone(
                'one flow, drawn to scale across every section',
                'speeds: ${[for (var k = 0; k < n; k++) '${k + 1} at ${r.run.speedAt(k).toStringAsFixed(1)}'].join(', ')} m/s',
              ),
              font: 'mono',
              size: 11,
              color: 'ink3',
            ),
            gap(10),
            formulaLine(
              r'$\dfrac{P}{\gamma} + \dfrac{v^2}{2g} + z = \text{constant}$',
              16,
            ),
            ...feedback(),
          ],
        );
      }(),
  ],
);

Map<String, Object?> whereTheBlockGoes() => pickScreen(
  id: 'where-the-block-goes',
  chapter: 'fluid-mechanics',
  title: 'Where the Block Goes',
  closing:
      'The push on a bend runs along the inlet direction minus the '
      'outlet direction, which lands it out on the outside of the turn '
      'every time, on the bisector. Sharper turns push harder. The '
      'inside of the elbow never needs holding, because nothing is '
      'trying to go there.',
  right: 'THAT IS THE ONE',
  wrong: 'THE OTHER FACE',
  brief: briefJson(blockBrief, 'blockBrief'),
  rounds: [
    for (final (i, r) in blockRounds.indexed)
      (
        options: [for (var k = 0; k < 4; k++) 'face ${k + 1}'],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...top('TAP THE BLOCK THAT TAKES THE PUSH', r.subject, r.setting),
          gap(12),
          framedTap(
            h: 250,
            marks: 4,
            spot: (outer, k) => ElbowPainter.spotOf(outer, r.elbow, k),
            draw: (pick, answered) =>
                (canvas, size) => ElbowPainter(
                  elbow: r.elbow,
                  picked: pick,
                  locked: answered,
                ).paint(canvas, size),
            what: 'where-the-block-goes round $i',
          ),
          gap(10),
          formulaLine(
            r'$F_{on\ bend} \propto \hat{u}_{in} - \hat{u}_{out}$',
            16,
          ),
          ...feedback(14),
        ],
      ),
  ],
);

Map<String, Object?> whichAreaGoesIn() => pickScreen(
  id: 'which-area-goes-in',
  chapter: 'fluid-mechanics',
  title: 'Which Area Goes In',
  closing:
      'The area in a meter formula is the throat or the hole, and the '
      'way to find it is the pair of tappings: the meter is what sits '
      'between them. The narrowest pipe on the drawing may be a reducer '
      'or a valve, and the squeezed jet past a plate is already paid '
      'for by the coefficient. The upstream pipe only ever turns up in '
      'the ratio underneath.',
  right: 'THAT IS THE ONE',
  wrong: 'ANOTHER OPENING',
  brief: briefJson(meteringBrief, 'meteringBrief'),
  rounds: [
    for (final (i, r) in meterRounds.indexed)
      (
        options: [
          for (var k = 0; k < r.gauge.stations.length; k++) 'opening ${k + 1}',
        ],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...top('TAP THE OPENING THE FLOW GOES ON', r.subject, r.setting),
          gap(12),
          framedTap(
            h: 190,
            marks: r.gauge.stations.length,
            spot: (outer, k) => GaugePainter.spotOf(outer, r.gauge, k),
            draw: (pick, answered) =>
                (canvas, size) => GaugePainter(
                  gauge: r.gauge,
                  picked: pick,
                  locked: answered,
                ).paint(canvas, size),
            what: 'which-area-goes-in round $i',
          ),
          ...feedback(14),
        ],
      ),
  ],
);

Map<String, Object?> whichOneNeedsABlock() => pickScreen(
  id: 'which-one-needs-a-block',
  chapter: 'fluid-mechanics',
  title: 'Which One Needs a Block',
  closing:
      'Pressure on its own moves nothing: it presses every way at once '
      'and cancels along a straight pipe. A net force turns up only '
      'where the water changes direction, changes speed, or stops. '
      'Bends, reducers and dead ends get held. Plain joints in a '
      'straight length do not, at any pressure.',
  right: 'THAT IS THE ONE',
  wrong: 'SOMEWHERE ELSE',
  brief: briefJson(thrustBrief, 'thrustBrief'),
  rounds: [
    for (final (i, r) in anchorRounds.indexed)
      (
        options: [for (var k = 0; k < r.trunk.spots; k++) 'place ${k + 1}'],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...top('TAP THE PLACE THAT NEEDS HOLDING', r.subject, r.setting),
          gap(12),
          framedTap(
            h: 230,
            marks: r.trunk.spots,
            spot: (outer, k) => TrunkPainter.spotOf(outer, r.trunk, k),
            draw: (pick, answered) =>
                (canvas, size) => TrunkPainter(
                  trunk: r.trunk,
                  picked: pick,
                  locked: answered,
                ).paint(canvas, size),
            what: 'which-one-needs-a-block round $i',
          ),
          ...feedback(14),
        ],
      ),
  ],
);

final adapters = <String, Map<String, Object?> Function()>{
  'add-up-the-losses': addUpTheLosses,
  'gauge-or-absolute': gaugeOrAbsolute,
  'laminar-or-turbulent': laminarOrTurbulent,
  'how-much-faster': howMuchFaster,
  'what-happens-to-the-loss': whatHappensToTheLoss,
  'too-big-or-too-small': tooBigOrTooSmall,
  'which-property': whichProperty,
  'does-the-model-run-faster': doesTheModelRunFaster,
  'float-or-sink': floatOrSink,
  'how-fast-the-jet': howFastTheJet,
  'which-drags-more': whichDragsMore,
  'which-target-takes-more': whichTargetTakesMore,
  'walk-the-manometer': walkTheManometer,
  'which-one-to-match': whichOneToMatch,
  'same-depth': sameDepth,
  'which-tube-climbs': whichTubeClimbs,
  'where-it-pushes': whereItPushes,
  'where-the-pressure-is': whereThePressureIs,
  'where-the-block-goes': whereTheBlockGoes,
  'which-area-goes-in': whichAreaGoesIn,
  'which-one-needs-a-block': whichOneNeedsABlock,
};
