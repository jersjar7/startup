import 'package:mobile/features/games/alignment_figures.dart' show AlignPainter;
import 'package:mobile/features/games/all_the_way_across_game.dart'
    show clearanceRounds;
import 'package:mobile/features/games/crest_or_sag_game.dart'
    show criterionRounds;
import 'package:mobile/features/games/feet_not_miles_game.dart'
    show yellowRounds;
import 'package:mobile/features/games/half_of_each_game.dart'
    show peakFlowRounds;
import 'package:mobile/features/games/how_big_is_the_break_game.dart'
    show breakRounds;
import 'package:mobile/features/games/how_far_below_the_corner_game.dart'
    show pviOffsetRounds;
import 'package:mobile/features/games/how_many_cars_is_a_truck_game.dart'
    show mixRounds;
import 'package:mobile/features/games/how_much_bank_game.dart' show tiltRounds;
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/los_figures.dart' show TruckPainter;
import 'package:mobile/features/games/sharper_or_flatter_game.dart'
    show curveQuoteRounds;
import 'package:mobile/features/games/sight_figures.dart'
    show PeakPainter, StoppingPainter;
import 'package:mobile/features/games/signal_figures.dart'
    show CrossingPainter, WalkPainter, YellowPainter;
import 'package:mobile/features/games/superelevation_figures.dart'
    show SuperPainter;
import 'package:mobile/features/games/the_worst_fifteen_minutes_game.dart'
    show surgeRounds;
import 'package:mobile/features/games/think_then_brake_game.dart'
    show stoppingRounds;
import 'package:mobile/features/games/three_parts_of_a_walk_game.dart'
    show greenRounds;
import 'package:mobile/features/games/traffic_flow_figures.dart'
    show GreenshieldsPainter;
import 'package:mobile/features/games/uphill_or_down_game.dart' show hillRounds;
import 'package:mobile/features/games/vertical_curve_figures.dart'
    show CriterionPainter, VerticalCurvePainter;
import 'package:mobile/features/games/what_is_left_of_the_speed_game.dart'
    show speedRounds;

import 'builder.dart';
import 'pick_one_adapter.dart';

/// The Transportation games, first half: stopping sight distance and the
/// peak hour, vertical and horizontal curves, signal timing, traffic flow
/// and heavy vehicles. Every one is the screen Per Million What has had
/// since phase 0: the overline, the subject and the question, one drawing
/// in a white panel on the grid, and the answers in a list.

/// Every game here, by id.
final adapters = <String, Map<String, Object?> Function()>{
  'think-then-brake': thinkThenBrake,
  'uphill-or-down': uphillOrDown,
  'the-worst-fifteen-minutes': theWorstFifteenMinutes,
  'crest-or-sag': crestOrSag,
  'how-big-is-the-break': howBigIsTheBreak,
  'how-far-below-the-corner': howFarBelowTheCorner,
  'sharper-or-flatter': sharperOrFlatter,
  'how-much-bank': howMuchBank,
  'feet-not-miles': feetNotMiles,
  'all-the-way-across': allTheWayAcross,
  'three-parts-of-a-walk': threePartsOfAWalk,
  'half-of-each': halfOfEach,
  'what-is-left-of-the-speed': whatIsLeftOfTheSpeed,
  'how-many-cars-is-a-truck': howManyCarsIsATruck,
};

Map<String, Object?> thinkThenBrake() => pickOne(
  id: 'think-then-brake',
  chapter: 'transportation',
  title: 'Think Then Brake',
  closing:
      'Thinking first, braking second, and the answer is both added. '
      'Thinking grows straight with speed and straight with reaction '
      'time. Braking grows with the square of the speed. Report either '
      'one on its own and you have the lesson\'s wrong answer, which it '
      'prints twice.',
  overline: 'SEEING AND STOPPING',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  figureHeight: 214,
  brief: briefJson(sightDistanceBrief, 'sightDistanceBrief'),
  rounds: [
    for (final r in stoppingRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        draw: (answered) => StoppingPainter(
          stop: r.stop,
          against: r.against,
          answered: answered,
        ).paint,
      ),
  ],
);

Map<String, Object?> uphillOrDown() => pickOne(
  id: 'uphill-or-down',
  chapter: 'transportation',
  title: 'Uphill or Down',
  closing:
      'Uphill is a plus and shortens the distance, because gravity is '
      'helping the brakes. Downhill is a minus and lengthens it. Only '
      'the braking half moves: the thinking half is the same on any '
      'grade. Reverse the sign and the answer comes out short, which is '
      'the unsafe direction.',
  overline: 'THE SIGN ON THE GRADE',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  figureHeight: 214,
  brief: briefJson(gradeSignBrief, 'gradeSignBrief'),
  rounds: [
    for (final r in hillRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        draw: (answered) => StoppingPainter(
          stop: r.stop,
          against: r.against,
          answered: answered,
        ).paint,
      ),
  ],
);

Map<String, Object?> theWorstFifteenMinutes() => pickOne(
  id: 'the-worst-fifteen-minutes',
  chapter: 'transportation',
  title: 'The Worst Fifteen Minutes',
  closing:
      'Four times the busiest quarter is the flow rate, and it is never '
      'below the hourly volume. The peak hour factor is the volume over '
      'that rate, it runs from a quarter to one, and a LOW factor means '
      'a sharp peak and a HIGH design flow. An answer below the hourly '
      'volume is wrong before you check the arithmetic.',
  overline: 'THE PEAK INSIDE THE HOUR',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  figureHeight: 210,
  brief: briefJson(peakHourBrief, 'peakHourBrief'),
  rounds: [
    for (final r in surgeRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        draw: (answered) => PeakPainter(hour: r.hour, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> crestOrSag() => pickOne(
  id: 'crest-or-sag',
  chapter: 'transportation',
  title: 'Crest or Sag',
  closing:
      'A crest is set by what the driver can see over the hill and '
      'divides by 2,158, a constant. A sag is set at night by how far '
      'the headlights reach and divides by 400 plus three and a half '
      'times the sight distance, which moves with it. Assume the sight '
      'distance fits inside the curve, work the length, then check it.',
  overline: 'WHICH RULE APPLIES',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  figureHeight: 210,
  brief: briefJson(crestSagBrief, 'crestSagBrief'),
  rounds: [
    for (final r in criterionRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        draw: (answered) =>
            CriterionPainter(criterion: r.criterion, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> howBigIsTheBreak() => pickOne(
  id: 'how-big-is-the-break',
  chapter: 'transportation',
  title: 'How Big Is the Break',
  closing:
      'The break is the size of the difference between the two grades. '
      'Opposite signs add, the same sign subtracts, and plus three into '
      'minus five is eight. A crest is where the second grade is LESS '
      'than the first, whatever their signs. K is the length over the '
      'break: feet of curve per per cent, and bigger is flatter.',
  overline: 'THE DIFFERENCE IN GRADE',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  figureHeight: 206,
  brief: briefJson(gradeBreakBrief, 'gradeBreakBrief'),
  rounds: [
    for (final r in breakRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        draw: (answered) =>
            VerticalCurvePainter(curve: r.curve, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> howFarBelowTheCorner() => pickOne(
  id: 'how-far-below-the-corner',
  chapter: 'transportation',
  title: 'How Far Below the Corner',
  closing:
      'The road misses the corner where the grades cross by the '
      'break as a DECIMAL times the length, over eight. Below it on a '
      'crest, above it in a sag. The eight comes from the parabola, '
      'the length scales the answer straight, and per cent in place of '
      'a decimal makes it a hundred times too big.',
  overline: 'MISSING THE CORNER',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  figureHeight: 206,
  brief: briefJson(cornerOffsetBrief, 'cornerOffsetBrief'),
  rounds: [
    for (final r in pviOffsetRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        draw: (answered) =>
            VerticalCurvePainter(curve: r.curve, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> sharperOrFlatter() => pickOne(
  id: 'sharper-or-flatter',
  chapter: 'transportation',
  title: 'Sharper or Flatter',
  closing:
      'The constant over the degree of curve is the radius, so a big '
      'degree is a sharp curve and a big radius is a flat one. The '
      'distance out to the corner is the radius times the tangent of '
      'HALF the turn, because the curve is symmetrical about that '
      'corner. Use the whole angle and the answer roughly doubles.',
  overline: 'RADIUS, DEGREE, TANGENT',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  figureHeight: 226,
  brief: briefJson(curveConversionBrief, 'curveConversionBrief'),
  rounds: [
    for (final r in curveQuoteRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        draw: (answered) => AlignPainter(
          bend: r.bend,
          answer: r.piece,
          locked: answered,
          label: r.note,
        ).paint,
      ),
  ],
);

Map<String, Object?> howMuchBank() => pickOne(
  id: 'how-much-bank',
  chapter: 'transportation',
  title: 'How Much Bank',
  closing:
      'The curve asks for the speed squared over fifteen times the '
      'radius. The tires supply what they can and the tilt of the '
      'pavement supplies the rest, quoted in per cent. Forget the '
      'friction and the answer comes out three times too big. Leave it '
      'a decimal and it comes out a hundred times too small.',
  overline: 'THE TILT ON THE CURVE',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  figureHeight: 214,
  brief: briefJson(superelevationBrief, 'superelevationBrief'),
  rounds: [
    for (final r in tiltRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        draw: (answered) =>
            SuperPainter(curve: r.curve, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> feetNotMiles() => pickOne(
  id: 'feet-not-miles',
  chapter: 'transportation',
  title: 'Feet, Not Miles',
  closing:
      'A second to react, then the speed over twice the deceleration, '
      'and every quantity in feet and seconds. Miles per hour straight '
      'into the formula gives 3.5 seconds where 4.7 belongs. Drop the '
      'reaction and you get 3.7. Drop the two and you get 8.3. The '
      'lesson prints all three.',
  overline: 'THE YELLOW INTERVAL',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  figureHeight: 196,
  brief: briefJson(yellowBrief, 'yellowBrief'),
  rounds: [
    for (final r in yellowRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        draw: (answered) =>
            YellowPainter(yellow: r.yellow, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> allTheWayAcross() => pickOne(
  id: 'all-the-way-across',
  chapter: 'transportation',
  title: 'All the Way Across',
  closing:
      'The all-red is for the vehicle that entered on the yellow, and '
      'it is clear when its BACK bumper passes the far curb. So the '
      'distance is the width plus the vehicle length, and the speed '
      'goes in as feet per second. Forget the vehicle and the interval '
      'comes out a third short.',
  overline: 'THE ALL-RED',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  figureHeight: 210,
  brief: briefJson(allRedBrief, 'allRedBrief'),
  rounds: [
    for (final r in clearanceRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        draw: (answered) =>
            CrossingPainter(clearance: r.clearance, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> threePartsOfAWalk() => pickOne(
  id: 'three-parts-of-a-walk',
  chapter: 'transportation',
  title: 'Three Parts of a Walk',
  closing:
      'Three point two seconds to get going, the crosswalk over three '
      'and a half feet a second to walk it, and about a quarter of a '
      'second for each person waiting. The pace is slow on purpose. '
      'Every wrong answer in this problem is one of the three pieces '
      'missing or set too fast.',
  overline: 'THE WALK SIGNAL',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  figureHeight: 206,
  brief: briefJson(pedestrianGreenBrief, 'pedestrianGreenBrief'),
  rounds: [
    for (final r in greenRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        draw: (answered) => WalkPainter(walk: r.walk, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> halfOfEach() => pickOne(
  id: 'half-of-each',
  chapter: 'transportation',
  title: 'Half of Each',
  closing:
      'Speed falls in a straight line as the lane fills, so flow, which '
      'is their product, is a parabola. It peaks at half the free flow '
      'speed and half the jam density, which makes the peak a QUARTER '
      'of their product. And two quite different densities give the '
      'same flow, which is why density, not volume, tells you how a '
      'road is really working.',
  overline: 'SPEED, DENSITY, FLOW',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  figureHeight: 234,
  brief: briefJson(greenshieldsBrief, 'greenshieldsBrief'),
  rounds: [
    for (final r in peakFlowRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        draw: (answered) =>
            GreenshieldsPainter(stream: r.stream, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> whatIsLeftOfTheSpeed() => pickOne(
  id: 'what-is-left-of-the-speed',
  chapter: 'transportation',
  title: 'What Is Left of the Speed',
  closing:
      'Start at the free flow speed and subtract what the traffic has '
      'taken away. The answer is the difference, never either piece on '
      'its own. Half the free flow speed belongs to half the jam '
      'density and nowhere else. And nothing on the road ever exceeds '
      'the free flow speed, which is a free check on the answer.',
  overline: 'READING THE LINE',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  figureHeight: 234,
  brief: briefJson(speedDensityBrief, 'speedDensityBrief'),
  rounds: [
    for (final r in speedRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        draw: (answered) =>
            GreenshieldsPainter(stream: r.stream, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> howManyCarsIsATruck() => pickOne(
  id: 'how-many-cars-is-a-truck',
  chapter: 'transportation',
  title: 'How Many Cars Is a Truck',
  closing:
      'Two cars on the level, three on rolling ground, and only the '
      'EXTRA space counts. The factor is one over one plus that extra, '
      'so it always sits between zero and one, and you divide by it. A '
      'factor above one is the denominator reported by mistake.',
  overline: 'COUNTING IN CARS',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  figureHeight: 196,
  brief: briefJson(heavyVehicleBrief, 'heavyVehicleBrief'),
  rounds: [
    for (final r in mixRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        draw: (answered) => TruckPainter(mix: r.mix, answered: answered).paint,
      ),
  ],
);
