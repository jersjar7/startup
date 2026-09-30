// The pictures on the Surveying concept sheets.
//
// A sheet is read picture first (owner's call, 2026-09-30): the drawing the
// student just played with, with one thing happening in it, then the idea in
// short steps, then the rule. Built from the same painters the games draw
// with; see mechanics_pictures.dart for the pattern and the shared
// ConceptPicture and ConceptPair tiles.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'alignment_figures.dart';
import 'area_figures.dart';
import 'cogo_figures.dart';
import 'earthwork_figures.dart';
import 'level_figures.dart';
import 'mechanics_pictures.dart' show ConceptPicture, ConceptPair;
import 'profile_figures.dart';
import 'survey_figures.dart';
import 'traverse_figures.dart';

// ---------------------------------------------------------------------------
// Bearings

Widget bearingPicture() => const ConceptPicture(
  painter: RosePainter(
    shots: [
      Shot(bearing: Bearing(Quad.ne, 52), name: 'B'),
      Shot(bearing: Bearing(Quad.se, 52), name: 'C'),
      Shot(bearing: Bearing(Quad.sw, 52), name: 'D'),
      Shot(bearing: Bearing(Quad.nw, 52), name: 'E'),
    ],
    arcOn: 0,
  ),
  caption:
      'the same 52 degrees, drawn in all four quarters. only the two letters '
      'tell them apart',
  height: 230,
);

Widget azimuthPicture() => const ConceptPair(
  left: RosePainter(
    shots: [Shot(bearing: Bearing(Quad.ne, 52), name: 'B')],
    arcOn: 0,
  ),
  right: RosePainter(
    shots: [Shot(bearing: Bearing(Quad.sw, 52), name: 'B')],
    arcOn: 0,
  ),
  leftCaption: 'N 52 E: the turn from north is 52, so the azimuth is 52',
  rightCaption: 'S 52 W: the turn from north has passed 180, so it is 232',
  height: 200,
);

Widget shotPicture() => const ConceptPicture(
  painter: SlopePainter(
    sight: Sight(slope: 100, angle: 18),
    answer: Side3.slope,
    locked: true,
  ),
  caption:
      'one shot up a hill makes a right triangle. the sloping side is the '
      'longest of the three every time',
  height: 210,
);

// ---------------------------------------------------------------------------
// Leveling

Widget sightPicture() => const ConceptPicture(
  painter: LevelPainter(
    level: Level(
      marks: [
        Stake(name: 'A', elevation: 100.0),
        Stake(name: 'B', elevation: 98.4),
      ],
    ),
  ),
  caption:
      'one level line over both rods. B reads more, so B is the lower ground',
  height: 210,
);

Widget runPicture() => const ConceptPicture(
  painter: LevelPainter(
    level: Level(
      marks: [
        Stake(name: 'BM', elevation: 100.0),
        Stake(name: 'TP', elevation: 101.8),
        Stake(name: 'X', elevation: 103.1),
      ],
    ),
    readings: false,
  ),
  caption:
      'the level moved once, so there are three points: a start, a turning '
      'point read twice, and an end',
  height: 220,
);

Widget closurePicture() => const ConceptPair(
  left: LoopPainter(loop: Loop(miles: 1, constant: 0.05), biggest: 4),
  right: LoopPainter(loop: Loop(miles: 4, constant: 0.05), biggest: 4),
  leftCaption: 'one mile round: allowed to be out by 0.05 ft',
  rightCaption: 'four miles round: four times as far, only twice the slack',
  height: 200,
);

// ---------------------------------------------------------------------------
// Traverse

Widget latDepPicture() => const ConceptPair(
  left: LegPainter(
    course: Course(azimuth: 40, length: 100, from: 'A', to: 'B'),
    showSigns: true,
  ),
  right: LegPainter(
    course: Course(azimuth: 220, length: 100, from: 'A', to: 'B'),
    showSigns: true,
  ),
  leftCaption: 'running north and east: both numbers are plus',
  rightCaption: 'running south and west: both numbers are minus',
  height: 210,
);

Widget compassPicture() => const ConceptPicture(
  painter: TripPainter(
    trip: Trip(lengths: [120, 300, 160, 220], driftNorth: 0.4, driftEast: 0.3),
    answer: 1,
    locked: true,
  ),
  caption:
      'the loop came back short of where it started. the longest course takes '
      'the biggest share of the fix',
  height: 230,
);

Widget precisionPicture() => const ConceptPair(
  left: TripPainter(
    trip: Trip(lengths: [60, 70, 55, 65], driftNorth: 0.07, driftEast: 0.05),
  ),
  right: TripPainter(
    trip: Trip(lengths: [700, 850, 640, 810], driftNorth: 0.2, driftEast: 0.2),
  ),
  leftCaption: 'a small lot, out by 9 cm: 1 in 2,800',
  rightCaption: 'a big loop, out by 28 cm: 1 in 10,700, and it is better work',
  height: 210,
);

// ---------------------------------------------------------------------------
// Area

const _parcel = Parcel(
  corners: [
    Corner2('A', 0, 0),
    Corner2('B', 90, 10),
    Corner2('C', 105, 70),
    Corner2('D', 20, 85),
  ],
);

const _wander = Strip(offsets: [8, 14, 19, 22, 20, 15, 9], step: 10);

Widget methodPicture() => const ConceptPair(
  left: ParcelPainter(parcel: _parcel, order: [0, 1, 2, 3]),
  right: OffsetsPainter(strip: _wander),
  leftCaption: 'straight sides and known corners: use the coordinates',
  rightCaption: 'a boundary that wanders: measure offsets off a baseline',
  height: 210,
);

Widget weightsPicture() => const ConceptPicture(
  painter: OffsetsPainter(strip: _wander, marked: 3, locked: true),
  caption:
      'seven offsets, six strips. every offset gets multiplied by something '
      'before the sum',
  height: 210,
);

Widget shoelacePicture() => const ConceptPair(
  left: ParcelPainter(parcel: _parcel, order: [0, 1, 2, 3]),
  right: ParcelPainter(
    parcel: _parcel,
    order: [0, 2, 1, 3],
    tone: AppColors.error,
  ),
  leftCaption: 'the corners in order round the boundary: the real parcel',
  rightCaption: 'the same four corners, listed out of order: a bowtie',
  height: 210,
);

// ---------------------------------------------------------------------------
// Earthwork

const _taper = Haul(
  slabs: [
    Slab(station: 0, area: 120),
    Slab(station: 100, area: 40),
    Slab(station: 200, area: 0),
  ],
);

const _hump = Haul(
  slabs: [
    Slab(station: 0, area: 0),
    Slab(station: 100, area: 150),
    Slab(station: 200, area: 0),
  ],
);

Widget endAreaPicture() => const ConceptPicture(
  painter: HaulPainter(haul: _taper, showEndAverage: true, locked: true),
  caption:
      'the sections along a job. the straight dashed line is what the end '
      'area method assumes happens between them',
  height: 220,
);

Widget stationsPicture() => const ConceptPicture(
  painter: HaulPainter(haul: _hump, skipMiddle: true, locked: true),
  caption:
      'both ends are zero. skip the middle section and the whole hill is '
      'booked as no dirt at all',
  height: 220,
);

Widget solidPicture() {
  Widget one(Solid solid, String caption) => Expanded(
    child: ConceptPicture(
      painter: SolidPainter(solid: solid),
      caption: caption,
      height: 150,
    ),
  );
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      one(Solid.prism, 'all the way: the whole box'),
      const SizedBox(width: 8),
      one(Solid.wedge, 'down to an edge: half'),
      const SizedBox(width: 8),
      one(Solid.point, 'down to a point: a third'),
    ],
  );
}

// ---------------------------------------------------------------------------
// Coordinate geometry

const _forward = Task(
  known: [Peg2('A', 1000, 5000)],
  wanted: Peg2('B', 1180, 5240),
  length: 300,
  azimuth: 36.87,
);

const _inverse = Task(known: [Peg2('A', 1000, 5000), Peg2('B', 1180, 5240)]);

Widget cogoPicture() => const ConceptPair(
  left: CogoPainter(task: _forward),
  right: CogoPainter(task: _inverse, showDeltas: true),
  leftCaption: 'one point and a measured course: find the far point',
  rightCaption: 'two points you hold: find the course between them',
  height: 210,
);

Widget pairPicture() => const ConceptPicture(
  painter: _PairPainter(),
  caption:
      'the same two numbers, read each way round. one of them is not the '
      'point you wanted',
  height: 210,
);

Widget arctanPicture() => const ConceptPair(
  left: CogoPainter(
    task: Task(known: [Peg2('A', 1000, 5000), Peg2('B', 1180, 5240)]),
    showDeltas: true,
  ),
  right: CogoPainter(
    task: Task(known: [Peg2('A', 1000, 5000), Peg2('B', 820, 4760)]),
    showDeltas: true,
  ),
  leftCaption: 'north and east: the calculator gets this one right',
  rightCaption:
      'south and west: both minus signs cancel, so it answers the same. add 180',
  height: 210,
);

// ---------------------------------------------------------------------------
// Horizontal curves

Widget roadCurvePicture() => const ConceptPicture(
  painter: AlignPainter(bend: Bend2(radius: 600, turn: 60), locked: true),
  caption:
      'one curve joining two straight roads. six different lengths live on '
      'this one picture',
  height: 240,
);

Widget degreePicture() => const ConceptPicture(
  painter: AlignPainter(
    bend: Bend2(radius: 400, turn: 50),
    other: Bend2(radius: 1200, turn: 50),
    names: ('sharp', 'gentle'),
    locked: true,
  ),
  caption:
      'two curves turning the same corner. the tighter one has the smaller '
      'radius and the bigger degree',
  height: 240,
);

// ---------------------------------------------------------------------------
// Vertical curves

const _crest = Vert(gradeIn: 4, gradeOut: -2, length: 600);

Widget tangentOffsetPicture() => const ConceptPicture(
  painter: RoadProfilePainter(vert: _crest, markAt: 300, locked: true),
  caption:
      'at one station there are two elevations: the straight grade line, and '
      'the road under it',
  height: 220,
);

Widget highPointPicture() => const ConceptPicture(
  painter: RoadProfilePainter(vert: _crest, showTurning: true, locked: true),
  caption:
      'plus 4 in, minus 2 out. the road stops climbing two thirds along, not '
      'at the middle',
  height: 220,
);

// ---------------------------------------------------------------------------
// The one painter that exists only for a sheet

/// A grid with one pair of numbers plotted both ways round, so the reader
/// can see that reading them backwards lands on the far side of the
/// diagonal and still looks like a perfectly good point.
class _PairPainter extends CustomPainter {
  const _PairPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.22;
    final right = size.width * 0.86;
    final bottom = size.height * 0.80;
    final top = size.height * 0.16;

    final axis = Paint()
      ..color = AppColors.ink2
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(left, bottom), Offset(right, bottom), axis);
    canvas.drawLine(Offset(left, bottom), Offset(left, top), axis);

    void text(
      String s,
      Offset at, {
      double size = 11,
      Color color = AppColors.ink2,
      bool center = false,
    }) {
      final tp = TextPainter(
        text: TextSpan(
          text: s,
          style: AppTheme.mono(size: size, color: color),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, center ? at - Offset(tp.width / 2, 0) : at);
    }

    text('north', Offset(left - 4, top - 16));
    text('east', Offset(right - 26, bottom + 8));

    // The two plotted points. Easting across, northing up.
    Offset spot(double e, double n) =>
        Offset(left + (right - left) * e, bottom - (bottom - top) * n);

    final right_ = spot(0.28, 0.72);
    final wrong = spot(0.72, 0.28);

    // The diagonal the two points sit either side of.
    final dash = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1;
    const step = 7.0;
    final from = Offset(left, bottom);
    final to = spot(1, 1);
    final span = (to - from).distance;
    for (var d = 0.0; d < span; d += step * 2) {
      final a = from + (to - from) / span * d;
      final b = from + (to - from) / span * math.min(d + step, span);
      canvas.drawLine(a, b, dash);
    }

    canvas.drawCircle(right_, 5.5, Paint()..color = AppColors.forest);
    text('(340, 880)', right_ + const Offset(10, -6), color: AppColors.forest);
    canvas.drawCircle(wrong, 5.5, Paint()..color = AppColors.error);
    text('(880, 340)', wrong + const Offset(10, -6), color: AppColors.error);

    text(
      'E first, then N',
      Offset((left + right) / 2, top - 16),
      color: AppColors.forest,
      center: true,
    );
  }

  @override
  bool shouldRepaint(_PairPainter old) => false;
}

/// Every picture on this chapter's sheets, by the contact sheet's card name.
const surveyingPictures = <String, Widget Function()>{
  'bearing': bearingPicture,
  'azimuth': azimuthPicture,
  'shot': shotPicture,
  'sight': sightPicture,
  'run': runPicture,
  'closure': closurePicture,
  'latdep': latDepPicture,
  'compass': compassPicture,
  'precision': precisionPicture,
  'method': methodPicture,
  'weights': weightsPicture,
  'shoelace': shoelacePicture,
  'endarea': endAreaPicture,
  'stations': stationsPicture,
  'solid': solidPicture,
  'cogo': cogoPicture,
  'pair': pairPicture,
  'arctan': arctanPicture,
  'curve': roadCurvePicture,
  'degree': degreePicture,
  'tangent': tangentOffsetPicture,
  'highpoint': highPointPicture,
};
