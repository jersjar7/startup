import 'dart:math' as maths;

import 'package:mobile/features/games/alignment_figures.dart';
import 'package:mobile/features/games/can_you_skip_a_section_game.dart';
import 'package:mobile/features/games/cogo_figures.dart';
import 'package:mobile/features/games/earthwork_figures.dart';
import 'package:mobile/features/games/how_much_of_the_box_game.dart';
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/profile_figures.dart';
import 'package:mobile/features/games/road_or_grade_line_game.dart';
import 'package:mobile/features/games/what_do_you_add_game.dart';
import 'package:mobile/features/games/where_does_that_pair_land_game.dart';
import 'package:mobile/features/games/where_it_flattens_out_game.dart';
import 'package:mobile/features/games/which_curve_is_sharper_game.dart';
import 'package:mobile/features/games/which_formula_gives_more_game.dart';
import 'package:mobile/features/games/which_is_longer_game.dart';
import 'package:mobile/features/games/which_piece_is_that_game.dart';
import 'package:mobile/features/games/which_way_are_you_working_game.dart';

import 'package:flutter/material.dart' hide Path, TextPainter;

import 'builder.dart';
import 'fluids.dart' show tapDrawing;
import 'nodes.dart';
import 'pick_one_adapter.dart';

/// The Surveying games, second half: earthwork volumes, coordinate
/// geometry, horizontal and vertical curves. Most rounds are the usual
/// screen: the problem, a drawing in a white panel, a formula under it, the
/// answers as plain rows. The rest are answered on the drawing itself: a
/// point of a coordinate grid, a piece of a curve, one of two curves, a
/// marked point on a road profile.

/// Every game here, by id.
final adapters = <String, Map<String, Object?> Function()>{
  'which-formula-gives-more': whichFormulaGivesMore,
  'can-you-skip-a-section': canYouSkipASection,
  'how-much-of-the-box': howMuchOfTheBox,
  'which-way-are-you-working': whichWayAreYouWorking,
  'where-does-that-pair-land': whereDoesThatPairLand,
  'what-do-you-add': whatDoYouAdd,
  'which-piece-is-that': whichPieceIsThat,
  'which-curve-is-sharper': whichCurveIsSharper,
  'which-is-longer': whichIsLonger,
  'road-or-grade-line': roadOrGradeLine,
  'where-it-flattens-out': whereItFlattensOut,
};

/// One round of the usual screen.
typedef PanelRound = ({
  String subject,
  String setting,
  int answer,
  String why,
  String source,
  Draw Function(bool answered) draw,
});

/// The usual screen: the overline, the subject and the setting, a drawing
/// [h] high in a white panel, a formula under it, then the answer rows
/// [choiceGap] further down, 8 apart, and once answered the feedback.
/// [last] is whether the last row gets its 8 too; [feedbackGap] is the
/// room above the feedback.
Map<String, Object?> panelGame({
  required String id,
  required String title,
  required String closing,
  required String overline,
  required String right,
  required String wrong,
  required BriefSection brief,
  required String briefName,
  required double h,
  required String formula,
  required num formulaSize,
  required List<String> options,
  required List<PanelRound> rounds,
  num choiceGap = 14,
  bool last = true,
  num feedbackGap = 6,
}) => pickScreen(
  id: id,
  chapter: 'surveying',
  title: title,
  closing: closing,
  right: right,
  wrong: wrong,
  brief: briefJson(brief, briefName),
  rounds: [
    for (final (i, r) in rounds.indexed)
      (
        options: options,
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...heading(overline, r.subject, r.setting),
          gap(12),
          figure(r.draw, h, frame: 'panel', what: '$id round $i'),
          gap(10),
          {'math': formula, 'size': formulaSize},
          gap(choiceGap),
          {'choices': true, 'space': 8, 'last': last},
          ...feedbackAfter(feedbackGap),
        ],
      ),
  ],
);

/// A drawing in a white bordered panel, answered by tapping near one of
/// its [marks]. The game hit-tests the whole panel, border and all, so
/// each mark is placed as the game places it on the outer size and moved
/// in by the border; a tap within [reach] of it picks it. With [first] the
/// first mark within reach wins, as the games that check their points in
/// order pick; without, the nearest.
Node framedMarks({
  required double h,
  required int marks,
  required Draw Function(int? pick, bool answered) draw,
  required Offset Function(Size outer, int i) spot,
  required double reach,
  required bool first,
  required String what,
}) => box(
  w: 'max',
  h: h,
  fill: 'white',
  radius: 12,
  border: 'line',
  child: clip(
    grid({
      ...tapDrawing(
        h: h - 2,
        hits: [for (var i = 0; i < marks; i++) i],
        draw: draw,
        targets: (canvas, size) {
          final outer = Size(size.width + 2, size.height + 2);
          for (var i = 0; i < marks; i++) {
            canvas.drawCircle(
              spot(outer, i) - const Offset(1, 1),
              reach,
              Paint(),
            );
          }
        },
        what: what,
      ),
      if (first) 'first': true,
    }),
    11,
  ),
);

/// A number as the coordinate games write one: whole numbers without a
/// decimal point.
String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();

Map<String, Object?> whichFormulaGivesMore() => panelGame(
  id: 'which-formula-gives-more',
  title: 'Which Formula Gives More',
  closing:
      'Compare the middle section with the average of the two ends. '
      'Above it and the prismoidal formula gives more; below it and '
      'the end area method does; level with it and the two agree '
      'exactly, which is what happens on a constant section and on one '
      'that opens out evenly. A fill closing to a point sags well '
      'below, and that is the overestimate the end area method is '
      'known for.',
  overline: 'WHICH ONE COMES OUT BIGGER',
  right: 'THAT IS THE BIGGER ONE',
  wrong: 'THE OTHER WAY',
  brief: endAreaBrief,
  briefName: 'endAreaBrief',
  h: 215,
  formula: r'$\frac{L}{2}(A_1 + A_2) \qquad \frac{L}{6}(A_1 + 4A_m + A_2)$',
  formulaSize: 13,
  options: [for (final o in Fatter.values) o.plain],
  rounds: [
    for (final r in fatterRounds)
      (
        subject: r.subject,
        setting: r.setting,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        draw: (answered) =>
            HaulPainter(haul: r.haul, showEndAverage: true).paint,
      ),
  ],
);

Map<String, Object?> canYouSkipASection() => panelGame(
  id: 'can-you-skip-a-section',
  title: 'Can You Skip a Section',
  closing:
      'The end area formula is exact between two sections when the '
      'section runs straight from one to the other, and blind to '
      'anything in between when it does not. A hump goes unbooked, a '
      'saddle gets paid for twice, and a run that starts and finishes '
      'at nothing reports nothing at all. Work it station by station '
      'and add the segments up.',
  overline: 'WHAT DOES WORKING END TO END DO',
  right: 'THAT IS WHAT IT DOES',
  wrong: 'THE OTHER WAY',
  brief: stationBrief,
  briefName: 'stationBrief',
  h: 200,
  formula: r'$V = \frac{L}{2}(A_1 + A_2)$, segment by segment',
  formulaSize: 14,
  options: [for (final o in Skipped.values) o.plain],
  rounds: [
    for (final r in skipRounds)
      (
        subject: r.subject,
        setting: r.setting,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        draw: (answered) => HaulPainter(haul: r.haul, skipMiddle: true).paint,
      ),
  ],
);

Map<String, Object?> howMuchOfTheBox() => panelGame(
  id: 'how-much-of-the-box',
  title: 'How Much of the Box',
  closing:
      'Carry the section the whole length to make a box, then ask what '
      'the far end does. Nothing changes: all of it. Closes to an '
      'edge: half, which is the end area formula with one section at '
      'zero. Closes to a point: a third, which is the pyramid formula. '
      'The gap between the half and the third is the whole reason the '
      'end area method overestimates a taper.',
  overline: 'HOW MUCH OF ITS BOX DOES IT FILL',
  right: 'THAT IS THE SHARE',
  wrong: 'ANOTHER SHARE',
  brief: solidBrief,
  briefName: 'solidBrief',
  h: 210,
  formula: r'$V = \frac{h A_{base}}{3}$ for a point',
  formulaSize: 14,
  options: [for (final o in Share.values) o.plain],
  rounds: [
    for (final r in shareRounds2)
      (
        subject: r.subject,
        setting: r.setting,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        draw: (answered) => SolidPainter(solid: r.solid).paint,
      ),
  ],
);

Map<String, Object?> whichWayAreYouWorking() => panelGame(
  id: 'which-way-are-you-working',
  title: 'Which Way Are You Working',
  closing:
      'Count the points that already have coordinates. One, with a '
      'course measured off it: forward, and the course turns into a '
      'new point. Two, with nothing measured: inverse, and the '
      'coordinates turn back into a distance and a direction. Most '
      'real jobs are an inverse to find out where something points, '
      'followed by a forward to put something new there.',
  overline: 'WHICH COMPUTATION IS THIS',
  right: 'THAT IS THE ONE',
  wrong: 'THE OTHER WAY',
  brief: cogoBrief,
  briefName: 'cogoBrief',
  h: 215,
  formula: r'$\Delta E = L\sin Az \qquad \Delta N = L\cos Az$',
  formulaSize: 14,
  options: [for (final o in Which2.values) o.plain],
  rounds: [
    for (final r in cogoRounds)
      (
        subject: r.subject,
        setting: r.setting,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        draw: (answered) => CogoPainter(task: r.task).paint,
      ),
  ],
);

Map<String, Object?> whatDoYouAdd() => panelGame(
  id: 'what-do-you-add',
  title: 'What Do You Add',
  closing:
      'The arctangent of one number covers half the compass, so the '
      'signs of the two differences have to supply the rest. A '
      'negative northing difference means the line runs south and the '
      'azimuth is 180 plus whatever came back. North and west takes '
      '360. North and east is the only quarter the calculator gets '
      'right on its own, and a negative answer is never an azimuth.',
  overline: 'WHAT DOES THE CALCULATOR ANSWER NEED',
  right: 'THAT IS THE FIX',
  wrong: 'ANOTHER FIX',
  brief: arctanBrief,
  briefName: 'arctanBrief',
  h: 215,
  formula: r'$Az = \tan^{-1}\left(\dfrac{\Delta E}{\Delta N}\right)$',
  formulaSize: 15,
  options: [for (final o in AddOn.values) o.plain],
  rounds: [
    for (final r in addOnRounds)
      (
        subject: r.subject,
        setting: r.setting,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        draw: (answered) => CogoPainter(task: r.task, showDeltas: true).paint,
      ),
  ],
);

Map<String, Object?> whichIsLonger() => panelGame(
  id: 'which-is-longer',
  title: 'Which Is Longer',
  closing:
      'On a gentle bend the arc is about twice the tangent. At a right '
      'angle the tangent equals the radius and the arc is still half as '
      'long again. Somewhere near 134 degrees the two are equal, and '
      'past that the tangent runs away while the arc cannot exceed half '
      'a circle. Which is why the two get confused, and why the '
      'confusion matters most on exactly the curves that are hardest '
      'to build.',
  overline: 'WHICH MEASUREMENT IS THE LONGER ONE',
  right: 'THAT IS THE LONGER ONE',
  wrong: 'THE OTHER ONE',
  brief: roadCurveBrief,
  briefName: 'roadCurveBrief',
  h: 260,
  formula: r'$T = R\tan\frac{I}{2} \qquad L = \frac{\pi R I}{180}$',
  formulaSize: 14,
  options: [for (final o in Longer.values) o.plain],
  rounds: [
    for (final r in longerRounds)
      (
        subject: r.subject,
        setting: r.setting,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        draw: (answered) => AlignPainter(
          bend: r.bend,
          // Neither is picked out until it is answered.
          answer: answered
              ? (r.answer == Longer.tangent
                    ? Bit.tangent
                    : r.answer == Longer.arc
                    ? Bit.arc
                    : null)
              : null,
          locked: answered,
          label: 'R ${r.bend.radius.round()} ft, I ${r.bend.turn}°',
        ).paint,
      ),
  ],
);

Map<String, Object?> roadOrGradeLine() => panelGame(
  id: 'road-or-grade-line',
  title: 'Road or Grade Line',
  closing:
      'The tangent elevation and the road elevation are two different '
      'numbers at the same station, and the question always means one '
      'of them. The road bends away from the grade it came in on in '
      'whichever direction the grade change points, starting at nothing '
      'at the PVC and growing as the square of the distance. On a crest '
      'the road runs below, on a sag above.',
  overline: 'WHERE IS THE ROAD AT THE MARK',
  right: 'THAT IS WHERE IT SITS',
  wrong: 'THE OTHER WAY',
  brief: tangentOffsetBrief,
  briefName: 'tangentOffsetBrief',
  h: 240,
  formula: r'$Y = Y_{PVC} + g_1 x + \dfrac{g_2 - g_1}{2L}x^2$',
  formulaSize: 15,
  options: [for (final o in Sits3.values) o.plain],
  choiceGap: 12,
  last: false,
  feedbackGap: 14,
  rounds: [
    for (final r in sitsRounds)
      (
        subject: r.subject,
        setting: r.setting,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        draw: (answered) =>
            RoadProfilePainter(vert: r.vert, markAt: r.station).paint,
      ),
  ],
);

Map<String, Object?> whereDoesThatPairLand() => pickScreen(
  id: 'where-does-that-pair-land',
  chapter: 'surveying',
  title: 'Where Does That Pair Land',
  closing:
      'Easting first, northing second: across, then up. A pair read '
      'backwards lands on the far side of the diagonal, and every '
      'number that follows it looks entirely reasonable. When the two '
      'numbers are close together the error is small enough to survive '
      'a glance and big enough to matter, which is why coordinates get '
      'labeled E and N and why the point gets plotted.',
  right: 'THAT IS THE POINT',
  wrong: 'ANOTHER POINT',
  brief: briefJson(pairBrief, 'pairBrief'),
  rounds: [
    for (final (i, r) in landRounds.indexed)
      () {
        final points = [...r.task.known, ?r.task.wanted];
        return (
          options: [for (final p in points) p.name],
          notes: null,
          tex: null,
          answer: r.answer,
          why: r.why,
          source: r.source,
          screen: [
            {'overline': 'TAP THE POINT THAT PAIR NAMES', 'color': 'ember'},
            gap(6),
            {'mono': r.subject, 'size': 11.5, 'color': 'ink3'},
            gap(12),
            center(
              t(
                '(E, N) = (${_num(r.east)}, ${_num(r.north)})',
                font: 'mono',
                size: 19,
              ),
            ),
            gap(12),
            framedMarks(
              h: 250,
              marks: points.length,
              draw: (pick, answered) => CogoPainter(
                task: r.task,
                showLine: false,
                showCoordinates: false,
                picked: pick,
                answer: answered ? r.answer : null,
                locked: answered,
              ).paint,
              spot: (outer, p) => CogoPainter.spotOf(outer, r.task, p),
              reach: 26,
              first: true,
              what: 'where-does-that-pair-land round $i',
            ),
            ...feedbackAfter(14),
          ],
        );
      }(),
  ],
);

Map<String, Object?> whichPieceIsThat() => pickScreen(
  id: 'which-piece-is-that',
  chapter: 'surveying',
  title: 'Which Piece Is That',
  closing:
      'The tangent runs out to the PI, the arc is the road, the chord '
      'cuts across from PC to PT. The external measures from the PI in '
      'to the road, the middle ordinate from the chord out to it, and '
      'the radius from the center to the PC, square to the tangent '
      'there. Six lengths, one drawing, and the drawing is worth more '
      'than the six formulas.',
  right: 'THAT IS IT',
  wrong: 'ANOTHER PIECE',
  brief: briefJson(roadCurveBrief, 'roadCurveBrief'),
  rounds: [
    for (final (i, r) in pieceRounds.indexed)
      (
        options: [for (final b in Bit.values) b.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          {'overline': 'TAP IT ON THE CURVE', 'color': 'ember'},
          gap(6),
          {'mono': r.subject, 'size': 11.5, 'color': 'ink3'},
          gap(12),
          center(t(r.asked.plain, font: 'mono', size: 17)),
          gap(12),
          framedMarks(
            h: 280,
            marks: Bit.values.length,
            draw: (pick, answered) => AlignPainter(
              bend: r.bend,
              picked: pick == null ? null : Bit.values[pick],
              answer: answered ? r.answer : null,
              locked: answered,
            ).paint,
            spot: (outer, p) =>
                AlignPainter.spotOf(outer, r.bend, Bit.values[p]),
            reach: 24,
            first: false,
            what: 'which-piece-is-that round $i',
          ),
          ...feedbackAfter(14),
        ],
      ),
  ],
);

Map<String, Object?> whichCurveIsSharper() => pickScreen(
  id: 'which-curve-is-sharper',
  chapter: 'surveying',
  title: 'Which Curve Is Sharper',
  closing:
      'The radius is a length and the degree of curve is an angle, and '
      'they run opposite ways: a bigger radius is gentler, a bigger '
      'degree is sharper. Their product is always about 5,730, which '
      'is the radius of a one degree curve and the fastest way to '
      'compare a curve quoted one way against one quoted the other.',
  right: 'THAT IS THE TIGHTER ONE',
  wrong: 'THE OTHER ONE',
  brief: briefJson(degreeBrief, 'degreeBrief'),
  rounds: [
    for (final (i, r) in sharpRounds.indexed)
      () {
        // The drawing's curve 0 is the wider one, 1 the one inside it.
        int answerOf(int curve) =>
            ((curve == 0) == r.leftIsWider ? Sharper.left : Sharper.right)
                .index;
        int? curveOf(int? pick) => pick == null || pick == Sharper.same.index
            ? null
            : (pick == Sharper.left.index) == r.leftIsWider
            ? 0
            : 1;
        return (
          options: [for (final o in Sharper.values) o.plain],
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: [
            ...heading('WHICH ONE BENDS HARDER', r.subject, r.setting),
            gap(12),
            box(
              w: 'max',
              h: 250,
              fill: 'white',
              radius: 12,
              border: 'line',
              child: clip(
                grid(
                  tapDrawing(
                    h: 248,
                    hits: [answerOf(0), answerOf(1)],
                    draw: (pick, answered) => AlignPainter(
                      bend: r.wider,
                      other: r.tighter,
                      names: r.namesInOrder,
                      pickedCurve: curveOf(pick),
                      answerCurve: !answered || r.answer == Sharper.same
                          ? null
                          : curveOf(r.answer.index),
                      locked: answered,
                      label: '${r.leftLabel} and ${r.rightLabel}',
                    ).paint,
                    // Each curve as the arc it is drawn on: a tap within
                    // 24 of one picks the nearer.
                    targets: (canvas, size) {
                      for (final which in [0, 1]) {
                        final (centre, radius, half) = AlignPainter.arcOf(
                          size,
                          r.wider,
                          r.tighter,
                          which,
                        );
                        canvas.drawArc(
                          Rect.fromCircle(center: centre, radius: radius),
                          -maths.pi / 2 - half,
                          2 * half,
                          false,
                          Paint()..strokeWidth = 24,
                        );
                      }
                    },
                    other: true,
                    what: 'which-curve-is-sharper round $i',
                  ),
                ),
                11,
              ),
            ),
            gap(8),
            {
              'mono': 'tap the sharper curve, or say they are the same',
              'size': 11,
              'color': 'ink3',
            },
            gap(10),
            {'math': r'$D = \dfrac{5{,}729.58}{R}$', 'size': 16},
            gap(12),
            {
              'choices': [Sharper.same.index],
            },
            ...feedbackAfter(14),
          ],
        );
      }(),
  ],
);

Map<String, Object?> whereItFlattensOut() => pickScreen(
  id: 'where-it-flattens-out',
  chapter: 'surveying',
  title: 'Where It Flattens Out',
  closing:
      'The road turns around where its slope runs out, and that point '
      'leans toward the shallower of the two grades. It is halfway '
      'along only when the grades are equal and opposite, and it is not '
      'on the curve at all when both grades run the same way. The PVI '
      'station is a tempting answer and it is almost never the right '
      'one.',
  right: 'THAT IS WHERE IT TURNS',
  wrong: 'IT TURNS ELSEWHERE',
  brief: briefJson(highPointBrief, 'highPointBrief'),
  rounds: [
    for (final (i, r) in topRounds.indexed)
      (
        options: [for (var s = 0; s < r.spots.length; s++) 'Point ${s + 1}'],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...heading(
            r.wantsHigh
                ? 'TAP THE TOP OF THE ROAD'
                : 'TAP THE BOTTOM OF THE ROAD',
            r.subject,
            r.setting,
          ),
          gap(12),
          framedMarks(
            h: 260,
            marks: r.spots.length,
            draw: (pick, answered) => RoadProfilePainter(
              vert: r.vert,
              spots: r.spots,
              picked: pick,
              answer: answered ? r.answer : null,
              locked: answered,
              showTurning: answered,
            ).paint,
            spot: (outer, p) =>
                RoadProfilePainter.spotOf(outer, r.vert, r.spots, p),
            reach: 26,
            first: true,
            what: 'where-it-flattens-out round $i',
          ),
          gap(10),
          {'math': r'$x_m = \dfrac{-g_1 L}{g_2 - g_1}$', 'size': 16},
          ...feedbackAfter(14),
        ],
      ),
  ],
);
