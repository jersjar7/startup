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
};
