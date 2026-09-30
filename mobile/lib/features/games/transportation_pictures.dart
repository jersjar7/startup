// The pictures on the Transportation Engineering concept sheets.
//
// A sheet is read picture first (owner's call, 2026-09-30): the drawing the
// student just played with, with one thing happening in it, then the idea in
// short steps, then the rule. Built from the same painters the games draw
// with; see mechanics_pictures.dart for the pattern and the shared
// ConceptPicture and ConceptPair tiles.

import 'package:flutter/material.dart';

import 'alignment_figures.dart';
import 'demand_figures.dart';
import 'earthwork_figures.dart';
import 'los_figures.dart';
import 'mechanics_pictures.dart' show ConceptPicture, ConceptPair;
import 'pavement_figures.dart';
import 'rigid_figures.dart';
import 'sight_figures.dart';
import 'sign_figures.dart';
import 'signal_figures.dart';
import 'superelevation_figures.dart';
import 'traffic_flow_figures.dart';
import 'vertical_curve_figures.dart';

// ---------------------------------------------------------------------------
// 118 Stopping sight distance

Widget sightDistancePicture() => const ConceptPicture(
  painter: StoppingPainter(stop: Braking(speed: 60), answered: true),
  caption:
      'a driver at 60 mph. the first stretch is spent noticing, the second '
      'braking',
  height: 200,
);

Widget gradeSignPicture() => const ConceptPicture(
  painter: StoppingPainter(
    stop: Braking(speed: 60, grade: -0.04),
    against: Braking(speed: 60, grade: 0.04),
    answered: true,
  ),
  caption: 'the same car and speed, going downhill and going uphill',
  height: 210,
);

Widget peakHourPicture() => const ConceptPicture(
  painter: PeakPainter(
    hour: Hour(counts: [250, 400, 300, 250]),
    answered: true,
  ),
  caption: 'one hour counted in four quarters. one quarter is much busier',
  height: 210,
);

// ---------------------------------------------------------------------------
// 119 Vertical curves

Widget crestSagPicture() => const ConceptPair(
  left: CriterionPainter(
    criterion: Criterion(breakSize: 8, sight: 500, sag: false),
    answered: true,
  ),
  right: CriterionPainter(
    criterion: Criterion(breakSize: 8, sight: 300, sag: true),
    answered: true,
  ),
  leftCaption: 'over a hill: the road itself blocks the view',
  rightCaption: 'into a dip: at night the headlights run out first',
  height: 200,
);

Widget gradeBreakPicture() => const ConceptPair(
  left: VerticalCurvePainter(
    curve: Vertical(gradeIn: 3, gradeOut: -5),
    answered: true,
  ),
  right: VerticalCurvePainter(
    curve: Vertical(gradeIn: -2, gradeOut: -5),
    answered: true,
  ),
  leftCaption: 'up 3 then down 5: the break is 8',
  rightCaption: 'down 2 then down 5: the break is 3',
  height: 195,
);

Widget cornerOffsetPicture() => const ConceptPicture(
  painter: VerticalCurvePainter(
    curve: Vertical(gradeIn: 3, gradeOut: -5),
    answered: true,
  ),
  caption:
      'the two grades meet at a corner no car could drive. the road passes '
      'below it',
  height: 210,
);

// ---------------------------------------------------------------------------
// 120 Horizontal curves

Widget curveConversionPicture() => const ConceptPicture(
  painter: AlignPainter(
    bend: Bend2(radius: 1200, turn: 30),
    answer: Bit.tangent,
    locked: true,
    label: 'the tangent runs from the start of the curve out to the corner',
  ),
  caption: 'a road turning through 30 degrees, seen from above',
  height: 215,
);

Widget superelevationPicture() => const ConceptPicture(
  painter: SuperPainter(
    curve: Superelevation(speed: 45, radius: 600, friction: 0.15),
    answered: true,
  ),
  caption:
      'the road tilted into the bend. the bar splits what the turn asks for',
  height: 210,
);

// ---------------------------------------------------------------------------
// 121 Signals

Widget yellowPicture() => const ConceptPicture(
  painter: YellowPainter(yellow: Yellow(speedMph: 50), answered: true),
  caption: 'the yellow as a strip of time: a moment to react, then the stop',
  height: 190,
);

Widget allRedPicture() => const ConceptPicture(
  painter: CrossingPainter(
    clearance: Clearance(width: 60, vehicleLength: 20, speedMph: 50),
    answered: true,
  ),
  caption: 'a car still inside the crossing. it is clear when its back end is',
  height: 200,
);

Widget pedestrianGreenPicture() => const ConceptPicture(
  painter: WalkPainter(walk: Walk(crosswalk: 56, people: 15), answered: true),
  caption: 'the walk signal as three pieces of time laid end to end',
  height: 195,
);

// ---------------------------------------------------------------------------
// 122 Traffic flow

Widget greenshieldsPicture() => const ConceptPicture(
  painter: GreenshieldsPainter(
    stream: Stream(freeFlow: 70, jamDensity: 180),
    showPoint: false,
    answered: true,
  ),
  caption: 'speed falling as the lane fills, and the flow that comes out of it',
  height: 240,
);

Widget speedDensityPicture() => const ConceptPicture(
  painter: GreenshieldsPainter(
    stream: Stream(freeFlow: 70, jamDensity: 180, density: 60),
    answered: true,
  ),
  caption: 'at 60 cars a mile, how much of the free flow speed is left',
  height: 240,
);

Widget crashRatePicture() => const ConceptPair(
  left: ExposurePainter(
    rate: CrashRate(crashes: 12, dailyTraffic: 8000),
    answered: true,
  ),
  right: ExposurePainter(
    rate: CrashRate(crashes: 20, dailyTraffic: 30000),
    answered: true,
  ),
  leftCaption: 'twelve crashes, a quiet junction',
  rightCaption: 'twenty crashes, but far more traffic passed through',
  height: 200,
);

// ---------------------------------------------------------------------------
// 123 Capacity

Widget heavyVehiclePicture() => const ConceptPair(
  left: TruckPainter(
    mix: TruckMix(trucks: 0.10, equivalent: 2.0),
    answered: true,
  ),
  right: TruckPainter(
    mix: TruckMix(trucks: 0.10, equivalent: 3.0),
    answered: true,
  ),
  leftCaption: 'on the level a truck takes the room of two cars',
  rightCaption: 'on rolling ground it takes three',
  height: 200,
);

const _lessonFreeway = Freeway(
  volume: 4500,
  peakHourFactor: 0.92,
  lanes: 3,
  mix: TruckMix(trucks: 0.10, equivalent: 2.0),
);

Widget demandFlowPicture() => const ConceptPicture(
  painter: LosPainter(road: _lessonFreeway, answered: true),
  caption:
      'one hourly count, divided three times to reach cars per hour per lane',
  height: 240,
);

Widget levelOfServicePicture() => const ConceptPicture(
  painter: LosPainter(road: _lessonFreeway, showSteps: false, answered: true),
  caption: 'the six bands, and where this freeway lands on them',
  height: 230,
);

// ---------------------------------------------------------------------------
// 124 Travel demand

Widget fourStepPicture() => const ConceptPicture(
  painter: StepsPainter(highlight: Forecast.distribution, answered: true),
  caption: 'the four models, each one fed by the one before it',
  height: 210,
);

const _twoZones = Spread(
  produced: 1000,
  destinations: [
    Destination(name: 'zone 1', attractions: 200, friction: 0.5),
    Destination(name: 'zone 2', attractions: 300, friction: 0.2),
  ],
);

Widget gravityPicture() => const ConceptPicture(
  painter: GravityPainter(spread: _twoZones, answered: true),
  caption: 'a thousand trips shared between two places, in proportion',
  height: 215,
);

Widget frictionPicture() => const ConceptPair(
  left: GravityPainter(
    spread: Spread(
      produced: 1000,
      destinations: [
        Destination(name: 'near', attractions: 250, friction: 0.6),
        Destination(name: 'far', attractions: 250, friction: 0.15),
      ],
    ),
    answered: true,
  ),
  right: GravityPainter(
    spread: Spread(
      produced: 1000,
      destinations: [
        Destination(name: 'near', attractions: 250, friction: 0.6),
        Destination(name: 'far', attractions: 1200, friction: 0.15),
      ],
    ),
    answered: true,
  ),
  leftCaption: 'same size, one further away: the near one wins',
  rightCaption: 'the far one five times bigger: now it wins anyway',
  height: 210,
);

// ---------------------------------------------------------------------------
// 125 Signs and signals

Widget signCategoryPicture() => const ConceptPair(
  left: SignPainter(
    sign: RoadSign(
      shape: SignShape.octagon,
      color: 'red',
      legend: 'STOP',
      kind: SignKind.regulatory,
    ),
    answered: true,
  ),
  right: SignPainter(
    sign: RoadSign(
      shape: SignShape.diamond,
      color: 'yellow',
      legend: 'curve',
      kind: SignKind.warning,
    ),
    answered: true,
  ),
  leftCaption: 'a shape and color that mean a rule',
  rightCaption: 'a shape and color that mean a warning',
  height: 215,
);

Widget warrantPicture() => const ConceptPicture(
  painter: WarrantPainter(
    crossing: Junction(
      description: 'a quiet crossroads, a few dozen vehicles an hour',
      warrantMet: null,
      note: 'a signal here would add delay and rear-end crashes',
    ),
    answered: true,
  ),
  caption: 'the list a crossing has to meet before it earns a signal',
  height: 225,
);

/// Every picture on this chapter's sheets, by the contact sheet's card name.
const transportationPictures = <String, Widget Function()>{
  'distance': sightDistancePicture,
  'grade': gradeSignPicture,
  'peak': peakHourPicture,
  'criterion': crestSagPicture,
  'break': gradeBreakPicture,
  'corner': cornerOffsetPicture,
  'curves': curveConversionPicture,
  'bank': superelevationPicture,
  'yellow': yellowPicture,
  'allred': allRedPicture,
  'walk': pedestrianGreenPicture,
  'peakflow': greenshieldsPicture,
  'line': speedDensityPicture,
  'rate': crashRatePicture,
  'trucks': heavyVehiclePicture,
  'flow': demandFlowPicture,
  'letter': levelOfServicePicture,
  'steps': fourStepPicture,
  'gravity': gravityPicture,
  'friction': frictionPicture,
  'signs': signCategoryPicture,
  'warrants': warrantPicture,
};
