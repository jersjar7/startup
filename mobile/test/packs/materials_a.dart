import 'package:mobile/features/games/before_or_during_game.dart';
import 'package:mobile/features/games/concrete_figures.dart';
import 'package:mobile/features/games/coupon_figures.dart';
import 'package:mobile/features/games/crack_figures.dart';
import 'package:mobile/features/games/curve_figures.dart';
import 'package:mobile/features/games/edge_or_inside_game.dart';
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/out_of_the_furnace_game.dart';
import 'package:mobile/features/games/stiff_is_not_strong_game.dart';
import 'package:mobile/features/games/stronger_or_weaker_game.dart';
import 'package:mobile/features/games/thermal_figures.dart';
import 'package:mobile/features/games/times_or_divided_game.dart';
import 'package:mobile/features/games/true_or_engineering_game.dart';
import 'package:mobile/features/games/what_this_job_needs_game.dart';
import 'package:mobile/features/games/which_arm_game.dart';
import 'package:mobile/features/games/which_cracks_first_game.dart';
import 'package:mobile/features/games/which_one_moves_most_game.dart';

import 'package:flutter/material.dart' hide Path, TextPainter;

import 'builder.dart';
import 'fluids.dart' show formulaLine, lone, rects, rows, tapDrawing, top;
import 'nodes.dart';
import 'pick_one_adapter.dart';
import 'statistics.dart' show feedback, overline, perPick, subject;

/// The Materials games, first half. Most are the problem, a drawing and the
/// plain white answer rows the pack draws as `choices`; the drawings
/// answered by tapping, the plates that are themselves answers, and the
/// answer rows set in mono are screen nodes.

/// An answer row with its words in mono, as the games that answer with a
/// number or a step write them: white, its border following the answer.
Node monoRow(int i, String label, num size) => answer(
  i,
  box(
    w: 'max',
    pad: const [14, 13, 14, 13],
    radius: 10,
    border: tone('line', 'ember', 'forest', 'error'),
    stroke: tone(1, 2, 2, 2),
    child: t(label, font: 'mono', size: size),
  ),
  radius: 10,
  fill: 'white',
);

/// Mono answer rows, each with 8 under it, then the feedback 6 further down.
List<Map<String, Object?>> monoRows(List<String> labels, num size) => [
  for (final (i, l) in labels.indexed) ...[monoRow(i, l, size), gap(8)],
  ...feedback(6),
];

/// A drawing that is itself an answer and never changes: white, its border
/// following the answer, inset by 4 on a finer grid, recorded at each size
/// the border leaves it.
Node platePanel(int i, double h, Draw paint, {required String what}) {
  Object at(bool thin) => record(
    paint,
    h - 8 - (thin ? 2 : 4),
    // A panel in a row of two is under half the game's width.
    range: (100, 500),
    what: '$what ${thin ? 'idle' : 'lit'}',
  );
  final lit = at(false);
  return answer(
    i,
    box(
      h: h,
      pad: const [4, 4, 4, 4],
      radius: 12,
      border: tone('line', 'ember', 'forest', 'error'),
      stroke: tone(1, 2, 2, 2),
      child: clip(
        grid(draw(tone(at(true), lit, lit, lit)), minor: 16, major: 80),
        8,
      ),
    ),
    fill: 'white',
  );
}

Map<String, Object?> beforeOrDuring() => pickScreen(
  id: 'before-or-during',
  chapter: 'materials',
  title: 'Before or During',
  closing:
      'Engineering values divide by the bar you started with, every '
      'time, however thin it gets. True values divide by the bar you '
      'have at that instant. And a strain is always a length over a '
      'length, so if yours has millimeters after it, it is a stretch '
      'and not a strain yet.',
  right: 'THAT IS WHAT GOES UNDERNEATH',
  wrong: 'NOT THAT ONE',
  brief: briefJson(underneathBrief, 'underneathBrief'),
  rounds: [
    for (final (i, r) in dimRounds.indexed)
      (
        options: [for (final d in Dim.values) d.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('TAP THE MEASUREMENT', r.subject, r.asked),
          if (r.formula != null) ...[gap(12), formulaLine(r.formula!, 18)],
          gap(12),
          grid(
            tapDrawing(
              h: 250,
              hits: [for (final d in Dim.values) d.index],
              targets: (canvas, size) {
                for (final d in Dim.values) {
                  canvas.drawCircle(CouponPainter.tagAt(size, d), 46, Paint());
                }
              },
              draw: (pick, answered) =>
                  (canvas, size) => CouponPainter(
                    coupon: r.coupon,
                    picked: pick == null ? null : Dim.values[pick],
                    answer: r.answer,
                    locked: answered,
                  ).paint(canvas, size),
              what: 'before-or-during round $i',
            ),
          ),
          gap(8),
          {
            'mono':
                'the stretch is drawn far bigger than it is, so it can be seen',
            'size': 11,
            'color': 'ink3',
          },
          ...feedback(),
        ],
      ),
  ],
);

Map<String, Object?> stiffIsNotStrong() => pickOne(
  id: 'stiff-is-not-strong',
  chapter: 'materials',
  title: 'Stiff Is Not Strong',
  closing:
      'Stress over strain is the slope of the straight part, which '
      'is stiffness: how much the thing stretches. Strength is how '
      'HIGH the curve goes and ductility is how far along it goes. A '
      'material can be stiff and weak, and a floor that bounces needs '
      'stiffness rather than strength.',
  overline: 'SLOPE, NOT HEIGHT',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  figureHeight: 226,
  brief: briefJson(stiffnessBrief, 'stiffnessBrief'),
  rounds: [
    for (final r in stiffRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        draw: (_) => PairPainter(left: r.stiffer, right: r.stronger).paint,
      ),
  ],
);

Map<String, Object?> trueOrEngineering() => pickScreen(
  id: 'true-or-engineering',
  chapter: 'materials',
  title: 'True or Engineering',
  closing:
      'One test, two ways of dividing. Engineering keeps the area the '
      'bar started with, so its curve turns over and comes down once '
      'the waist forms, and its peak is the ultimate strength everybody '
      'quotes. True divides by the waist that is there, so it climbs to '
      'the break and is always the bigger of the two. Below yield they '
      'are the same line.',
  right: 'THAT IS THE ONE',
  wrong: 'THE OTHER ONE',
  brief: briefJson(trueStressBrief, 'trueStressBrief'),
  rounds: [
    for (final (i, r) in readingRounds.indexed)
      () {
        final frame = Frame.over([r.specimen], headroom: 1.85);
        // The game takes the nearest point of either curve, the
        // engineering curve's first where two are as near. Each curve is
        // listed from its far end, so its first mark is one only it has.
        final curves = [BothPainter.engineering, BothPainter.truth];
        final counts = [
          for (final c in curves)
            BothPainter.pointsOf(
              r.specimen,
              frame,
              const Size(400, 230),
              c,
            ).length,
        ];
        final reading = [Reading.machine.index, Reading.real.index];
        int? glow(int? pick, bool answered) {
          final which = answered ? r.answer.index : pick;
          return which == Reading.machine.index
              ? BothPainter.engineering
              : which == Reading.real.index
              ? BothPainter.truth
              : null;
        }

        int? wrong(int? pick, bool answered) {
          if (!answered || pick == r.answer.index) return null;
          return pick == Reading.machine.index
              ? BothPainter.engineering
              : pick == Reading.real.index
              ? BothPainter.truth
              : null;
        }

        return (
          options: [for (final o in Reading.values) o.plain],
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            ...top('TAP THE CURVE', r.subject, r.asked),
            gap(12),
            grid(
              tapDrawing(
                h: 230,
                hits: [
                  for (final (k, n) in counts.indexed)
                    for (var p = 0; p < n; p++) reading[k],
                ],
                targets: (canvas, size) {
                  for (final c in curves) {
                    final points = BothPainter.pointsOf(
                      r.specimen,
                      frame,
                      size,
                      c,
                    );
                    for (final p in points.reversed) {
                      canvas.drawCircle(p, 26, Paint());
                    }
                  }
                },
                other: true,
                draw: (pick, answered) =>
                    (canvas, size) => BothPainter(
                      specimen: r.specimen,
                      frame: frame,
                      glow: glow(pick, answered),
                      wrong: wrong(pick, answered),
                      named: answered,
                      waistLine: r.waistLine,
                      elasticBand: r.elasticBand,
                    ).paint(canvas, size),
                what: 'true-or-engineering round $i',
              ),
            ),
            gap(8),
            {
              'mono': 'both drawn against the stretch the machine reports',
              'size': 11,
              'color': 'ink3',
            },
            gap(10),
            formulaLine(r'$\sigma_T = \sigma(1 + \varepsilon)$', 17),
            gap(12),
            ...lone(Reading.same.index),
          ],
        );
      }(),
  ],
);

Map<String, Object?> edgeOrInside() => pickScreen(
  id: 'edge-or-inside',
  chapter: 'materials',
  title: 'Edge or Inside',
  closing:
      'Where the crack is decides both numbers. From an edge: the '
      'factor is 1.1 and the a is the whole depth. Inside the plate: '
      'the factor is 1.0 and the a is half the length, because an '
      'internal crack is described as 2a. Then convert to meters before '
      'anything else happens.',
  right: 'BOTH NUMBERS RIGHT',
  wrong: 'ONE OF THE TWO IS WRONG',
  brief: briefJson(crackBrief, 'crackBrief'),
  rounds: [
    for (final (i, r) in crackRounds.indexed)
      (
        options: [for (final o in r.options) r.labelFor(o)],
        notes: null,
        tex: null,
        answer: r.options.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          overline('WHAT GOES INTO THE FORMULA'),
          gap(6),
          subject(r.subject),
          gap(10),
          formulaLine(r'$K_{IC} = Y\sigma\sqrt{\pi a}$', 18),
          gap(12),
          figure(
            (_) => PlatePainter(plate: r.plate).paint,
            180,
            frame: 'grid',
            what: 'edge-or-inside round $i',
          ),
          gap(12),
          ...monoRows([for (final o in r.options) r.labelFor(o)], 14),
        ],
      ),
  ],
);

Map<String, Object?> whichCracksFirst() => pickScreen(
  id: 'which-cracks-first',
  chapter: 'materials',
  title: 'Which One Cracks First',
  closing:
      'A crack length on its own says nothing. What matters is the '
      'stress times the root of the crack, held against what the '
      'material can take. The root is why a crack that has doubled is '
      'not twice as dangerous, the stress is the part you can do '
      'something about, and where the crack sits decides what length '
      'even goes in.',
  right: 'THAT IS THE ONE',
  wrong: 'THE OTHER WAY',
  brief: briefJson(toughnessBrief, 'toughnessBrief'),
  rounds: [
    for (final (i, r) in firstRounds.indexed)
      (
        options: [for (final o in Goes.values) o.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHICH ONE GOES FIRST', r.subject, r.setting),
          gap(12),
          answerRow([
            for (final (k, p) in [r.left, r.right].indexed)
              platePanel(
                k,
                190,
                PlatePainter(plate: p).paint,
                what: 'which-cracks-first round $i plate $k',
              ),
          ]),
          gap(10),
          formulaLine(r'$K = Y\sigma\sqrt{\pi a}$', 17),
          gap(12),
          ...lone(Goes.together.index),
        ],
      ),
  ],
);

Map<String, Object?> whichOneMovesMost() => pickScreen(
  id: 'which-one-moves-most',
  chapter: 'materials',
  title: 'Which One Biggest Most',
  closing:
      'Three things multiply: what it is made of, how long it is, and '
      'how much the temperature changes. Aluminum moves about twice as '
      'readily as steel or concrete, length counts in direct '
      'proportion, and the temperature change is a difference, never a '
      'sum. How thick it is does not come into it at all.',
  right: 'THAT IS THE ONE',
  wrong: 'NOT THAT ONE',
  brief: briefJson(expandBrief, 'expandBrief'),
  rounds: [
    for (final (i, r) in growRounds.indexed)
      () {
        const h = 270.0;
        // The game takes the third of the drawing the tap is in.
        final thirds = rects(
          3,
          (size, k) => Rect.fromLTWH(
            0,
            size.height / 3 * k,
            size.width,
            size.height / 3,
          ),
        );
        final row = r.answer == Biggest.same ? null : r.answer.index;
        return (
          options: [for (final o in Biggest.values) o.plain],
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            ...top('TAP THE ONE THAT MOVES MOST', r.subject, r.asked),
            gap(12),
            grid(
              tapDrawing(
                h: h,
                hits: thirds.hits,
                targets: thirds.targets,
                other: true,
                draw: (pick, answered) =>
                    (canvas, size) => MemberPainter(
                      members: r.members,
                      longest: r.longest,
                      biggest: r.biggest,
                      picked: pick,
                      answer: row,
                      locked: answered,
                    ).paint(canvas, size),
                what: 'which-one-moves-most round $i',
              ),
            ),
            gap(8),
            {
              'mono':
                  'bars drawn to length. the movement is shown once you answer',
              'size': 11,
              'color': 'ink3',
            },
            gap(10),
            formulaLine(r'$\Delta L = \alpha L \Delta T$', 17),
            gap(12),
            ...lone(Biggest.same.index),
          ],
        );
      }(),
  ],
);

Map<String, Object?> outOfTheFurnace() => pickScreen(
  id: 'out-of-the-furnace',
  chapter: 'materials',
  title: 'Out of the Furnace',
  closing:
      'Two questions read any heat treatment. Did it get up into the '
      'austenite band, and how fast did it come down through the '
      'change? Fast from up there is martensite, hard and brittle. Slow '
      'is ferrite and cementite, soft and ductile. A reheat afterwards '
      'is tempering, which keeps the hardness and takes away the worst '
      'of the brittleness.',
  right: 'THAT IS WHAT COMES OUT',
  wrong: 'NOT FROM THIS ONE',
  brief: briefJson(furnaceBrief, 'furnaceBrief'),
  rounds: [
    for (final (i, r) in furnaceRounds.indexed)
      (
        options: [for (final o in r.options) o.plain],
        notes: null,
        tex: null,
        answer: r.options.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHAT COMES OUT OF THIS', r.subject, r.setting),
          gap(12),
          figure(
            (_) => CoolPainter(cool: r.cool).paint,
            200,
            frame: 'grid',
            what: 'out-of-the-furnace round $i',
          ),
          gap(8),
          {
            'mono':
                'time is not to scale between rounds. read the slope, not '
                'the width',
            'size': 11,
            'color': 'ink3',
          },
          gap(12),
          ...rows(),
        ],
      ),
  ],
);

Map<String, Object?> whichArm() => pickScreen(
  id: 'which-arm',
  chapter: 'materials',
  title: 'Which Arm',
  closing:
      'The fraction of a phase is the arm on the FAR side from it, over '
      'the whole tie line. Liquid fraction takes the arm back to the '
      'solid boundary; solid fraction takes the arm out to the liquid '
      'one. The two must add to one, and an alloy sitting near a '
      'boundary is mostly that phase, which catches the swap before the '
      'arithmetic does.',
  right: 'THAT IS THE PIECE',
  wrong: 'THE OTHER ONE',
  brief: briefJson(tieLineBrief, 'tieLineBrief'),
  rounds: [
    for (final (i, r) in tieRounds.indexed)
      () {
        // The game takes the first bar holding the tap.
        final bars = rects(
          Arm.values.length,
          (size, k) => TiePainter.barOf(size, r.tie, Arm.values[k]).inflate(8),
        );
        return (
          options: [for (final a in Arm.values) a.plain],
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            ...top('TAP THE PIECE OF THE TIE LINE', r.subject, r.asked),
            gap(12),
            grid(
              tapDrawing(
                h: 255,
                hits: bars.hits,
                targets: bars.targets,
                draw: (pick, answered) =>
                    (canvas, size) => TiePainter(
                      tie: r.tie,
                      picked: pick == null ? null : Arm.values[pick],
                      answer: r.answer,
                      locked: answered,
                    ).paint(canvas, size),
                what: 'which-arm round $i',
              ),
            ),
            gap(8),
            {
              'mono':
                  'the two bars above the line are the arms, the one below '
                  'is all of it',
              'size': 11,
              'color': 'ink3',
            },
            gap(10),
            formulaLine(
              r'$f = \dfrac{\text{one arm}}{\text{the whole tie line}}$',
              16,
            ),
            ...feedback(),
          ],
        );
      }(),
  ],
);

Map<String, Object?> strongerOrWeaker() => pickScreen(
  id: 'stronger-or-weaker',
  chapter: 'materials',
  title: 'Stronger or Weaker',
  closing:
      'Water over cement decides it, and the direction is the one that '
      'feels wrong: more water is WEAKER. More cement under the same '
      'water is a smaller ratio and a stronger concrete. A water '
      'reducer buys workability for nothing. Air entrainment costs '
      'strength and buys freeze and thaw durability. Aggregate is not '
      'in the ratio at all.',
  right: 'THAT IS THE WAY',
  wrong: 'THE OTHER WAY',
  brief: briefJson(mixBrief, 'mixBrief'),
  rounds: [
    for (final (i, r) in batchRounds.indexed)
      (
        options: [for (final w in Way.values) w.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          overline('WHICH WAY DOES THE STRENGTH GO'),
          gap(6),
          subject(r.subject),
          gap(10),
          {
            'mono': 'As batched: ${r.before.plain}',
            'size': 12.5,
            'color': 'charcoal',
          },
          gap(8),
          {'text': r.change, 'size': 15},
          gap(12),
          figure(
            (answered) => MixPainter(
              marks: answered ? [r.before, r.after] : const [],
              picked: null,
              answer: answered ? 1 : null,
              locked: answered,
              showMarks: answered,
            ).paint,
            240,
            frame: 'grid',
            what: 'stronger-or-weaker round $i',
          ),
          gap(8),
          t(
            askDone(
              'the handbook curve. your mix goes on it once you answer',
              'one is the mix as batched, two is the mix after the change',
            ),
            font: 'mono',
            size: 11,
            color: 'ink3',
          ),
          gap(10),
          formulaLine(r'$W/C = \dfrac{\text{water}}{\text{cement}}$', 17),
          gap(12),
          ...rows(),
        ],
      ),
  ],
);

Map<String, Object?> whatThisJobNeeds() => pickScreen(
  id: 'what-this-job-needs',
  chapter: 'materials',
  title: 'What This Job Needs',
  closing:
      'Two questions, answered separately. How strong, which sets the '
      'ratio, and does this piece of concrete freeze, which decides the '
      'air. Air costs about a fifth of the strength, so a job that '
      'needs both pushes the ratio down further. And when the only '
      'complaint is that it will not pour, the answer is a water '
      'reducer, never water.',
  right: 'THAT IS THE MIX',
  wrong: 'THAT ONE FAILS A TEST',
  brief: briefJson(exposureBrief, 'exposureBrief'),
  rounds: [
    for (final (i, r) in siteRounds.indexed)
      () {
        final labels = [
          for (var k = 0; k < r.mixes.length; k++)
            '${k + 1}.  ${r.mixes[k].plain}',
        ];
        return (
          options: labels,
          notes: null,
          tex: null,
          answer: r.answer,
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            ...top('WHICH MIX SUITS THE JOB', r.subject, r.job),
            gap(12),
            grid(
              box(
                w: 'max',
                h: 240,
                child: draw(
                  perPick(
                    (pick, answered) =>
                        (canvas, size) => MixPainter(
                          marks: r.mixes,
                          target: r.needs,
                          picked: pick,
                          answer: answered ? r.answer : null,
                          locked: answered,
                        ).paint(canvas, size),
                    r.mixes.length,
                    240,
                    what: 'what-this-job-needs round $i',
                  ),
                ),
              ),
            ),
            gap(8),
            {
              'mono':
                  'the chart answers the strength half. the exposure is yours',
              'size': 11,
              'color': 'ink3',
            },
            gap(12),
            ...monoRows(labels, 13.5),
          ],
        );
      }(),
  ],
);

Map<String, Object?> timesOrDivided() => pickScreen(
  id: 'times-or-divided',
  chapter: 'materials',
  title: 'Times or Divided',
  closing:
      'One percentage, two directions. Going toward the smaller number '
      'multiplies and coming back to the bigger one divides, so decide '
      'whether the answer should be bigger or smaller before you touch '
      'the number. And the percentage you were given is the one to use: '
      'the leftover share belongs to a different question.',
  right: 'THAT IS THE WAY',
  wrong: 'THE OTHER WAY',
  brief: briefJson(curingBrief, 'curingBrief'),
  rounds: [
    for (final r in stepRounds)
      () {
        final labels = [for (final o in r.options) r.labelFor(o)];
        return (
          options: labels,
          notes: null,
          tex: null,
          answer: r.options.indexOf(r.answer),
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            ...top('WHICH WAY DOES THE PERCENTAGE GO', r.subject, r.setting),
            gap(14),
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
                t(r.known, size: 14.5),
                gapH(10),
                t('YOU WANT', font: 'overline', color: 'ember'),
                gapH(4),
                t(r.wanted, size: 14.5),
              ],
            ),
            gap(14),
            formulaLine(
              r'$\text{what you want} = \text{what you have} \; ?$',
              15,
            ),
            gap(14),
            ...monoRows(labels, 14),
          ],
        );
      }(),
  ],
);

final adapters = <String, Map<String, Object?> Function()>{
  'before-or-during': beforeOrDuring,
  'stiff-is-not-strong': stiffIsNotStrong,
  'true-or-engineering': trueOrEngineering,
  'edge-or-inside': edgeOrInside,
  'which-cracks-first': whichCracksFirst,
  'which-one-moves-most': whichOneMovesMost,
  'out-of-the-furnace': outOfTheFurnace,
  'which-arm': whichArm,
  'stronger-or-weaker': strongerOrWeaker,
  'what-this-job-needs': whatThisJobNeeds,
  'times-or-divided': timesOrDivided,
};
