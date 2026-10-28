import 'package:mobile/features/games/area_figures.dart';
import 'package:mobile/features/games/does_the_listing_close_game.dart';
import 'package:mobile/features/games/find_it_on_the_plan_game.dart';
import 'package:mobile/features/games/higher_or_lower_game.dart';
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/level_figures.dart';
import 'package:mobile/features/games/plus_or_minus_game.dart';
import 'package:mobile/features/games/survey_figures.dart';
import 'package:mobile/features/games/traverse_figures.dart';
import 'package:mobile/features/games/what_is_that_point_game.dart';
import 'package:mobile/features/games/what_weight_does_it_get_game.dart';
import 'package:mobile/features/games/which_course_takes_the_most_game.dart';
import 'package:mobile/features/games/which_length_is_which_game.dart';
import 'package:mobile/features/games/which_method_fits_game.dart';
import 'package:mobile/features/games/which_rule_turns_it_game.dart';
import 'package:mobile/features/games/which_run_is_allowed_more_game.dart';
import 'package:mobile/features/games/which_traverse_closed_better_game.dart';

import 'package:mobile/core/theme/app_colors.dart';

import 'package:flutter/material.dart' hide Path, TextPainter;

import 'builder.dart';
import 'fluids.dart' show rows, tapDrawing, top;
import 'nodes.dart';
import 'pick_one_adapter.dart';
import 'statistics.dart' show feedback, overline, subject;

/// The Surveying games, first half: bearings, leveling, traverses and
/// areas. Every round is the problem over one drawing in the games' white
/// bordered panel, then either the plain white answer rows, a drawing that
/// is tapped near a mark, or two drawings side by side that are answers
/// themselves with a "neither" row under them.

/// The games' white panel with a one pixel border round a drawing on the
/// grid. The painter gets two less each way for the border.
Node panel(Object d, num h) => box(
  h: h,
  fill: 'white',
  radius: 12,
  border: 'line',
  child: clip(grid(draw(d)), 11),
);

/// A drawing in the panel that never changes.
Node stillPanel(Draw paint, double h, String what) =>
    panel(record(paint, h - 2, what: what), h);

/// A drawing in the panel, before and after the answer.
Node askDonePanel(Draw Function(bool answered) paint, double h, String what) =>
    panel(
      askDone(
        record(paint(false), h - 2, what: '$what asked'),
        record(paint(true), h - 2, what: '$what answered'),
      ),
      h,
    );

/// A drawing in the panel answered by tapping within [within] of a mark.
/// The games hit-test the whole panel, border and all, so each mark is
/// placed as the game places it on the outer size and moved in by the
/// border.
Node tapPanel({
  required double h,
  required int marks,
  required double within,
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
            canvas.drawCircle(
              spot(outer, i) - const Offset(1, 1),
              within,
              Paint(),
            );
          }
        },
        what: what,
      ),
    ),
    11,
  ),
);

/// A drawing that is itself an answer: white, its border following the
/// answer and a pixel thicker once it is anything but idle, the drawing
/// inset by 4 on a finer grid. The drawing never changes, only the room
/// the border leaves it.
Node loopPanel(int i, double h, Draw paint, {required String what}) {
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

/// The overline, the subject, and [space] under it.
List<Map<String, Object?>> surveyHead(String words, String about, num space) =>
    [overline(words), gap(6), subject(about), gap(space)];

Map<String, Object?> findItOnThePlan() => pickScreen(
  id: 'find-it-on-the-plan',
  chapter: 'surveying',
  title: 'Find It on the Plan',
  closing:
      'A bearing is an instruction: face the letter it starts with, '
      'turn that many degrees toward the letter it ends with, and stop. '
      'It never exceeds a right angle, so the quadrant carries half the '
      'meaning and the angle carries the other half. Read both before '
      'reaching for any conversion.',
  right: 'THAT IS THE LINE',
  wrong: 'ANOTHER LINE',
  brief: briefJson(bearingBrief, 'bearingBrief'),
  rounds: [
    for (final (n, r) in planRounds.indexed)
      (
        options: [for (final s in r.shots) 'line ${s.name}'],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...surveyHead('TAP THE LINE THAT MATCHES', r.subject, 12),
          center(t(r.wanted.plain, font: 'mono', size: 22, color: 'charcoal')),
          gap(12),
          tapPanel(
            h: 270,
            marks: r.shots.length,
            within: 26,
            spot: (outer, i) => RosePainter.spotOf(outer, r.shots, i),
            draw: (pick, answered) => RosePainter(
              shots: r.shots,
              picked: pick,
              answer: answered ? r.answer : null,
              locked: answered,
              arcOn: answered ? r.answer : null,
            ).paint,
            what: 'find-it-on-the-plan round $n',
          ),
          ...feedback(14),
        ],
      ),
  ],
);

Map<String, Object?> whichRuleTurnsIt() => pickScreen(
  id: 'which-rule-turns-it',
  chapter: 'surveying',
  title: 'Which Rule Turns It',
  closing:
      'Azimuths run clockwise from north, so where a line sits in that '
      'turn settles the conversion. North-east is the azimuth already. '
      'South-east stops short of 180, so take it off 180. South-west '
      'has gone past 180, so add it on. North-west is nearly a full '
      'turn, so take it off 360. Picture the clock face and you will '
      'never need the list.',
  right: 'THAT IS THE RULE',
  wrong: 'ANOTHER RULE',
  brief: briefJson(azimuthBrief, 'azimuthBrief'),
  rounds: [
    for (final (n, r) in azimuthRounds.indexed)
      (
        options: [for (final o in Rule.values) o.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHICH RULE MAKES IT AN AZIMUTH', r.subject, r.setting),
          gap(12),
          stillPanel(
            RosePainter(
              shots: [Shot(bearing: r.bearing, name: 'B')],
              arcOn: 0,
            ).paint,
            230,
            'which-rule-turns-it round $n',
          ),
          gap(14),
          ...rows(),
        ],
      ),
  ],
);

Map<String, Object?> whichLengthIsWhich() => pickScreen(
  id: 'which-length-is-which',
  chapter: 'surveying',
  title: 'Which Length Is Which',
  closing:
      'One shot, three lengths. The instrument and the tape both read '
      'the sloping one, the plan wants the flat one, and the upright '
      'one is the difference in elevation. The sloping one is the '
      'longest of the three every time, which catches the mistake of '
      'dividing by the cosine instead of multiplying by it.',
  right: 'THAT IS THE ONE',
  wrong: 'ANOTHER SIDE',
  brief: briefJson(shotBrief, 'shotBrief'),
  rounds: [
    for (final (n, r) in shotRounds.indexed)
      (
        options: [for (final s in Side3.values) s.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('TAP THE LENGTH IT NAMES', r.subject, r.setting),
          gap(12),
          tapPanel(
            h: 220,
            marks: Side3.values.length,
            within: 25,
            spot: (outer, i) =>
                SlopePainter.spotOf(outer, r.sight, Side3.values[i]),
            draw: (pick, answered) => SlopePainter(
              sight: r.sight,
              picked: pick == null ? null : Side3.values[pick],
              answer: answered ? r.answer : null,
              locked: answered,
            ).paint,
            what: 'which-length-is-which round $n',
          ),
          gap(10),
          {'math': r'$HD = SD\cos\alpha \qquad VD = SD\sin\alpha$', 'size': 15},
          ...feedback(14),
        ],
      ),
  ],
);

Map<String, Object?> higherOrLower() => pickScreen(
  id: 'higher-or-lower',
  chapter: 'surveying',
  title: 'Higher or Lower',
  closing:
      'The line of sight is one level plane, so the rod reading is how '
      'far the ground is below it. The bigger reading is the lower '
      'point, every time. Equal readings mean equal elevations. Read '
      'the two numbers that way before any arithmetic and a swapped '
      'backsight has nowhere to hide.',
  right: 'THAT IS THE ONE',
  wrong: 'THE OTHER WAY',
  brief: briefJson(sightBrief, 'sightBrief'),
  rounds: [
    for (final (n, r) in sightRounds.indexed)
      (
        options: [for (final o in Perch.values) o.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHICH POINT IS HIGHER', r.subject, r.setting),
          gap(12),
          askDonePanel(
            (answered) =>
                LevelPainter(level: r.level, showGround: answered).paint,
            210,
            'higher-or-lower round $n',
          ),
          gap(10),
          {
            'math': r'$HI = \text{Elev} + BS \qquad \text{Elev} = HI - FS$',
            'size': 14,
          },
          gap(14),
          ...rows(),
        ],
      ),
  ],
);

Map<String, Object?> whatIsThatPoint() => pickScreen(
  id: 'what-is-that-point',
  chapter: 'surveying',
  title: 'What Is That Point',
  closing:
      'Count the instruments that can see the rod. One, at the start '
      'of the run, and it is a backsight to be added. One, at the end, '
      'and it is a foresight to be taken off. Two, and it is a turning '
      'point read both ways, which means a fresh height of instrument '
      'after the level moves.',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: briefJson(runBrief, 'runBrief'),
  rounds: [
    for (final (n, r) in runRounds.indexed)
      (
        options: [for (final o in Peg.values) o.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top(
            'WHAT IS IT IN THE BOOK',
            r.subject,
            'What is the reading on ${r.name}?',
          ),
          gap(12),
          stillPanel(
            LevelPainter(
              level: r.level,
              picked: r.asking,
              readings: false,
            ).paint,
            220,
            'what-is-that-point round $n',
          ),
          gap(14),
          ...rows(),
        ],
      ),
  ],
);

Map<String, Object?> whichRunIsAllowedMore() => pickScreen(
  id: 'which-run-is-allowed-more',
  chapter: 'surveying',
  title: 'Which Run Is Allowed More',
  closing:
      'What a loop may be out by is the constant times the square root '
      'of the distance, and both halves matter. Four times the length '
      'is only twice the allowance, under a mile the root tightens it '
      'instead, and the constant can hand a short run more room than a '
      'long one. If the misclosure beats that number the run stands. '
      'If not, it gets run again.',
  right: 'THAT IS THE ONE',
  wrong: 'THE OTHER ONE',
  brief: briefJson(closureBrief, 'closureBrief'),
  rounds: [
    for (final (n, r) in slackRounds.indexed)
      (
        options: [for (final o in Roomier.values) o.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHICH RUN MAY BE OUT BY MORE', r.subject, r.setting),
          gap(12),
          answerRow([
            for (final (i, loop) in [r.left, r.right].indexed)
              loopPanel(
                i,
                175,
                LoopPainter(loop: loop, biggest: r.biggest).paint,
                what: 'which-run-is-allowed-more round $n panel $i',
              ),
          ]),
          gap(10),
          {'math': r'$\text{allowable} = C\sqrt{M}$', 'size': 16},
          gap(12),
          {
            'choices': [Roomier.same.index],
          },
          ...feedback(14),
        ],
      ),
  ],
);

Map<String, Object?> plusOrMinus() => pickScreen(
  id: 'plus-or-minus',
  chapter: 'surveying',
  title: 'Plus or Minus',
  closing:
      'Latitude is how far north, departure is how far east, and both '
      'go negative when the course goes the other way. The quadrant '
      'settles both signs before a single trigonometric function is '
      'touched: north-east both plus, south-east latitude minus, '
      'south-west both minus, north-west departure minus. A closed '
      'traverse has to visit more than one quarter or it can never '
      'come back.',
  right: 'THAT IS THE PAIR',
  wrong: 'ANOTHER PAIR',
  brief: briefJson(latDepBrief, 'latDepBrief'),
  rounds: [
    for (final (n, r) in signPairRounds.indexed)
      (
        options: [for (final o in Quad.values) o.signs],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...surveyHead('WHAT SIGNS DO ITS TWO PARTS TAKE', r.subject, 12),
          askDonePanel(
            (answered) =>
                LegPainter(course: r.course, showSigns: answered).paint,
            230,
            'plus-or-minus round $n',
          ),
          gap(10),
          {
            'math':
                r'$\text{Lat} = L\cos\theta \qquad \text{Dep} = L\sin\theta$',
            'size': 14,
          },
          gap(14),
          ...rows(),
        ],
      ),
  ],
);

Map<String, Object?> whichCourseTakesTheMost() => pickScreen(
  id: 'which-course-takes-the-most',
  chapter: 'surveying',
  title: 'Which Course Takes the Most',
  closing:
      'The compass rule assumes the error crept in evenly along the '
      'way, so each course takes the total times its own length over '
      'the perimeter. The longest course takes the most. Not the '
      'course that went furthest north, not an equal share each, and '
      'never the whole error on the one course that felt wrong. And '
      'the correction always pushes back against the drift.',
  right: 'THAT IS THE ONE',
  wrong: 'ANOTHER COURSE',
  brief: briefJson(compassBrief, 'compassBrief'),
  rounds: [
    for (final (n, r) in courseRounds.indexed)
      (
        options: [
          for (final (i, l) in r.trip.lengths.indexed)
            'course ${i + 1}, ${_num(l)} m',
        ],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...top('TAP THE COURSE WITH THE BIGGEST SHARE', r.subject, r.setting),
          gap(12),
          tapPanel(
            h: 250,
            marks: r.trip.lengths.length,
            within: 26,
            spot: (outer, i) => TripPainter.spotOf(outer, r.trip, i),
            draw: (pick, answered) => TripPainter(
              trip: r.trip,
              picked: pick,
              answer: answered ? r.answer : null,
              locked: answered,
            ).paint,
            what: 'which-course-takes-the-most round $n',
          ),
          gap(10),
          {
            'math': r'$\text{Corr}_i = -E \times \dfrac{L_i}{\Sigma L}$',
            'size': 15,
          },
          ...feedback(14),
        ],
      ),
  ],
);

Map<String, Object?> whichTraverseClosedBetter() => pickScreen(
  id: 'which-traverse-closed-better',
  chapter: 'surveying',
  title: 'Which Traverse Closed Better',
  closing:
      'Precision is the gap over the distance it accumulated across, '
      'written as one over something. The gap alone says nothing: a '
      'centimeter around a small lot can be worse work than thirty '
      'centimeters around three kilometers. Double both and nothing '
      'changes. The shape of the figure never comes into it.',
  right: 'THAT IS THE ONE',
  wrong: 'THE OTHER ONE',
  brief: briefJson(precisionBrief, 'precisionBrief'),
  rounds: [
    for (final (n, r) in closedRounds.indexed)
      (
        options: [for (final o in Better.values) o.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHICH ONE IS THE BETTER TRAVERSE', r.subject, r.setting),
          gap(12),
          answerRow([
            for (final (i, trip) in [r.left, r.right].indexed)
              loopPanel(
                i,
                190,
                TripPainter(trip: trip).paint,
                what: 'which-traverse-closed-better round $n panel $i',
              ),
          ]),
          gap(10),
          {
            'math':
                r'$\text{precision} = \dfrac{\text{closure}}{\text{perimeter}}$',
            'size': 15,
          },
          gap(12),
          {
            'choices': [Better.same.index],
          },
          ...feedback(14),
        ],
      ),
  ],
);

Map<String, Object?> whichMethodFits() => pickScreen(
  id: 'which-method-fits',
  chapter: 'surveying',
  title: 'Which Method Fits the Ground',
  closing:
      'Corners with coordinates on them go by the coordinate method, '
      'which is exact for any straight sided figure however awkward. A '
      'boundary that wanders gets a baseline and offsets, and then the '
      'count decides: an odd number of offsets lets Simpson fit '
      'parabolas through them, and an even number leaves the '
      'trapezoidal rule.',
  right: 'THAT IS THE ONE',
  wrong: 'ANOTHER METHOD',
  brief: briefJson(methodBrief, 'methodBrief'),
  rounds: [
    for (final (n, r) in areaMethodRounds.indexed)
      (
        options: [for (final o in Way3.values) o.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHICH METHOD DOES THIS ASK FOR', r.subject, r.setting),
          gap(12),
          stillPanel(
            r.parcel != null
                ? ParcelPainter(
                    parcel: r.parcel!,
                    order: [
                      for (var i = 0; i < r.parcel!.corners.length; i++) i,
                    ],
                  ).paint
                : OffsetsPainter(strip: r.strip!).paint,
            220,
            'which-method-fits round $n',
          ),
          gap(14),
          ...rows(),
        ],
      ),
  ],
);

Map<String, Object?> whatWeightDoesItGet() => pickScreen(
  id: 'what-weight-does-it-get',
  chapter: 'surveying',
  title: 'What Weight Does It Get',
  closing:
      'The trapezoidal rule halves the two ends and takes everything '
      'between them whole, because the middle offsets are shared by '
      'the strips either side. Simpson takes the ends once and '
      'alternates four and two, because the middle of each parabola '
      'carries it and the joins are shared. One, four, two, four, one. '
      'Then multiply by the interval, and for Simpson divide by three.',
  right: 'THAT IS THE WEIGHT',
  wrong: 'ANOTHER WEIGHT',
  brief: briefJson(weightsBrief, 'weightsBrief'),
  rounds: [
    for (final (n, r) in offsetWeightRounds.indexed)
      (
        options: [for (final o in Weight.values) o.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...surveyHead(
            'WHAT DOES THE MARKED OFFSET GET MULTIPLIED BY',
            r.subject,
            12,
          ),
          askDonePanel(
            (answered) => OffsetsPainter(
              strip: r.strip,
              marked: r.at,
              locked: answered,
            ).paint,
            220,
            'what-weight-does-it-get round $n',
          ),
          gap(10),
          {
            'math': r.rule == Way3.simpson
                ? r'$A = \frac{w}{3}(h_1 + 4h_2 + 2h_3 + \cdots + h_n)$'
                : r'$A = w\left(\frac{h_1 + h_n}{2} + h_2 + \cdots\right)$',
            'size': 14,
          },
          gap(14),
          ...rows(),
        ],
      ),
  ],
);

Map<String, Object?> doesTheListingClose() => pickScreen(
  id: 'does-the-listing-close',
  chapter: 'surveying',
  title: 'Does the Listing Close',
  closing:
      'The formula runs on any list of coordinates and returns a tidy '
      'number, whether or not that list is the parcel. Corners out of '
      'order draw a bowtie and give back the difference of two loops. '
      'A corner left out draws a smaller figure that closes perfectly '
      'well. Neither shows up in the arithmetic, and both show up in a '
      'two second plot.',
  right: 'THAT IS IT',
  wrong: 'LOOK AGAIN',
  brief: briefJson(shoelaceBrief, 'shoelaceBrief'),
  rounds: [
    for (final (n, r) in listingRounds.indexed)
      (
        options: [for (final o in Listed.values) o.plain],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...top(
            'IS THIS LISTING THE PARCEL',
            r.subject,
            'The field book lists the corners ${r.listing}, and back.',
          ),
          gap(12),
          askDonePanel(
            (answered) => ParcelPainter(
              parcel: r.parcel,
              order: r.order,
              showCoordinates: false,
              fill: answered && r.answer == Listed.boundary,
              tone: answered && r.answer != Listed.boundary
                  ? AppColors.error
                  : AppColors.charcoal,
            ).paint,
            230,
            'does-the-listing-close round $n',
          ),
          gap(14),
          ...rows(),
        ],
      ),
  ],
);

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();

final adapters = <String, Map<String, Object?> Function()>{
  'find-it-on-the-plan': findItOnThePlan,
  'which-rule-turns-it': whichRuleTurnsIt,
  'which-length-is-which': whichLengthIsWhich,
  'higher-or-lower': higherOrLower,
  'what-is-that-point': whatIsThatPoint,
  'which-run-is-allowed-more': whichRunIsAllowedMore,
  'plus-or-minus': plusOrMinus,
  'which-course-takes-the-most': whichCourseTakesTheMost,
  'which-traverse-closed-better': whichTraverseClosedBetter,
  'which-method-fits': whichMethodFits,
  'what-weight-does-it-get': whatWeightDoesItGet,
  'does-the-listing-close': doesTheListingClose,
};
