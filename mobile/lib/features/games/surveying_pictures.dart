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
import 'figure_ink.dart';
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

// The game marks the three sides with bare circles, because naming them
// would be the answer. On a sheet the names ARE the lesson, so they are
// written on: which line is the slope, which is the flat distance, which is
// the height.
Widget shotPicture() => const ConceptPicture(
  painter: _NamedShotPainter(),
  caption:
      'one shot up a hill makes a right triangle. the sloping side is the longest of the three every time',
  height: 220,
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

// Two loops side by side could not carry this: the game's painter
// deliberately grows a longer loop only a little, so that the drawing never
// becomes the answer. So the loop is drawn once, and the thing the sheet is
// actually about, an allowance that grows by the ROOT of the distance, is
// drawn as its own curve with both cases marked on it.
Widget closurePicture() => const Column(
  children: [
    ConceptPicture(
      painter: LoopPainter(loop: Loop(miles: 1, constant: 0.05), biggest: 1),
      caption:
          'a level loop: leave the benchmark, go round, come back to it. whatever you come back with should be the height you left with',
      height: 200,
    ),
    SizedBox(height: 14),
    ConceptPicture(
      painter: _RootCurvePainter(),
      caption:
          'what it is allowed to be out by, against how far it ran. four times as far buys only twice the allowance, because of the square root',
      height: 210,
    ),
  ],
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

// Two drawings the painters label along their own bottom edge, so they are
// stacked at full width rather than set side by side: at half width the
// painter's own labels land on each other.
Widget methodPicture() => const _Stacked(
  top: ParcelPainter(parcel: _parcel, order: [0, 1, 2, 3]),
  bottom: OffsetsPainter(strip: _wander),
  topCaption: 'straight sides and known corners: use the coordinates',
  bottomCaption: 'a boundary that wanders: measure offsets off a baseline',
);

// The offsets alone show the ground but not the pattern, and the pattern is
// the whole rule. The second panel writes the two weight lists under the
// same seven positions, so the halved ends and the alternating four and two
// can be seen rather than recited.
Widget weightsPicture() => const Column(
  children: [
    ConceptPicture(
      painter: OffsetsPainter(strip: _wander, marked: 3, locked: true),
      caption:
          'seven offsets, six strips. every offset gets multiplied by something before the sum',
      height: 210,
    ),
    SizedBox(height: 14),
    ConceptPicture(
      painter: _WeightsPainter(),
      caption:
          'the same seven, with what each one is multiplied by. the ends are the only place the two rules disagree about halves',
      height: 200,
    ),
  ],
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

Widget stationsPicture() => const _Stacked(
  top: HaulPainter(haul: _hump, locked: true),
  bottom: HaulPainter(haul: _hump, skipMiddle: true, locked: true),
  topCaption: 'every pair of stations worked and added: the real hill',
  bottomCaption:
      'the two ends only. both are zero, so the whole hill is booked as no '
      'dirt at all',
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

// The two pieces the lesson says get mixed up, each marked on its own copy
// of the same curve: the painter marks one at a time.
Widget roadCurvePicture() => const _Stacked(
  top: AlignPainter(
    bend: Bend2(radius: 600, turn: 60),
    answer: Bit.tangent,
    locked: true,
  ),
  bottom: AlignPainter(
    bend: Bend2(radius: 600, turn: 60),
    answer: Bit.arc,
    locked: true,
  ),
  topCaption: 'the tangent: out along the old straight, to the corner',
  bottomCaption:
      'the curve length: the arc, which is the road the car actually drives',
  height: 175,
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
// Two drawings one above the other, each at full width

class _Stacked extends StatelessWidget {
  const _Stacked({
    required this.top,
    required this.bottom,
    required this.topCaption,
    required this.bottomCaption,
    this.height = 155,
  });

  final CustomPainter top;
  final CustomPainter bottom;
  final String topCaption;
  final String bottomCaption;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConceptPicture(painter: top, caption: topCaption, height: height),
        const SizedBox(height: 14),
        ConceptPicture(painter: bottom, caption: bottomCaption, height: height),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// The painters that exist only for a sheet

TextPainter _tp(String s, {double size = 10.5, Color color = AppColors.ink2}) {
  return TextPainter(
    text: TextSpan(
      text: s,
      style: AppTheme.mono(size: size, color: color),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
}

/// The game's shot, with the three sides named. The game draws bare circles
/// on purpose, since naming them would hand over the answer; a sheet has
/// the opposite job.
class _NamedShotPainter extends CustomPainter {
  const _NamedShotPainter();

  static const _sight = Sight(slope: 100, angle: 18);

  @override
  void paint(Canvas canvas, Size size) {
    const SlopePainter(
      sight: _sight,
      answer: Side3.slope,
      locked: true,
    ).paint(canvas, size);

    for (final (side, words, tone) in [
      (Side3.slope, 'slope: the longest', AppColors.forest),
      (Side3.flat, 'flat distance', AppColors.charcoal),
      (Side3.rise, 'height', AppColors.charcoal),
    ]) {
      final spot = SlopePainter.spotOf(size, _sight, side);
      final t = _tp(words, color: tone);
      final dy = switch (side) {
        Side3.slope => -26.0,
        Side3.flat => 14.0,
        Side3.rise => -6.0,
      };
      var x = switch (side) {
        Side3.rise => spot.dx + 12,
        _ => spot.dx - t.width / 2,
      };
      x = x.clamp(4.0, size.width - t.width - 4);
      inkLabel(canvas, t, Offset(x, spot.dy + dy));
    }
  }

  @override
  bool shouldRepaint(_NamedShotPainter old) => false;
}

/// How big an allowance a loop earns, against how far it ran. The curve
/// bends over because the allowance grows by the square root, which is the
/// whole of the sheet: four times the distance buys twice the allowance,
/// not four times.
class _RootCurvePainter extends CustomPainter {
  const _RootCurvePainter();

  static const _c = 0.05;
  static const _maxMiles = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.20;
    final right = size.width * 0.88;
    final bottom = size.height * 0.74;
    final top = size.height * 0.16;
    final maxAllow = _c * math.sqrt(_maxMiles);

    double x(double miles) => left + (right - left) * miles / _maxMiles;
    double y(double feet) => bottom - (bottom - top) * feet / maxAllow;

    final axis = Paint()
      ..color = AppColors.ink2
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(Offset(left, bottom), Offset(right, bottom), axis)
      ..drawLine(Offset(left, bottom), Offset(left, top), axis);

    final curve = Path()..moveTo(x(0), y(0));
    for (var m = 0.05; m <= _maxMiles; m += 0.05) {
      curve.lineTo(x(m), y(_c * math.sqrt(m)));
    }
    canvas.drawPath(
      curve,
      Paint()
        ..color = AppColors.info
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );

    // The two cases the caption talks about, marked on the curve with
    // dropped guides so the doubling can be read off the side.
    final guide = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1;
    for (final (miles, label) in [(1.0, '1 mile'), (4.0, '4 miles')]) {
      final feet = _c * math.sqrt(miles);
      final at = Offset(x(miles), y(feet));
      for (var g = left; g < at.dx; g += 7) {
        canvas.drawLine(Offset(g, at.dy), Offset(g + 3.5, at.dy), guide);
      }
      for (var g = at.dy; g < bottom; g += 7) {
        canvas.drawLine(Offset(at.dx, g), Offset(at.dx, g + 3.5), guide);
      }
      canvas
        ..drawCircle(at, 6, Paint()..color = AppColors.cream)
        ..drawCircle(at, 4.5, Paint()..color = AppColors.ember);
      final m = _tp(label, size: 10, color: AppColors.charcoal);
      inkLabel(canvas, m, Offset(at.dx - m.width / 2, bottom + 6));
      final f = _tp(
        '${feet.toStringAsFixed(2)} ft',
        size: 10,
        color: AppColors.ember,
      );
      inkLabel(canvas, f, Offset(left - f.width - 6, at.dy - 7));
    }

    final side = _tp('allowed to be out by', size: 9.5, color: AppColors.ink3);
    inkLabel(canvas, side, Offset(left - 4, top - 14));
    final along = _tp('miles run', size: 9.5, color: AppColors.ink3);
    inkLabel(canvas, along, Offset(right - along.width, bottom + 6));
  }

  @override
  bool shouldRepaint(_RootCurvePainter old) => false;
}

/// The two weight lists written under the same seven offsets, so the halved
/// ends and the alternating four and two are something you look at rather
/// than something you are told.
class _WeightsPainter extends CustomPainter {
  const _WeightsPainter();

  static const _trap = ['1/2', '1', '1', '1', '1', '1', '1/2'];
  static const _simpson = ['1', '4', '2', '4', '2', '4', '1'];

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.14;
    final right = size.width * 0.92;
    final step = (right - left) / (_trap.length - 1);
    final markY = size.height * 0.22;

    // The seven positions, as ticks on one baseline.
    canvas.drawLine(
      Offset(left - 10, markY),
      Offset(right + 10, markY),
      Paint()
        ..color = AppColors.ink2
        ..strokeWidth = 1.4,
    );
    for (var i = 0; i < _trap.length; i++) {
      final px = left + step * i;
      canvas.drawCircle(
        Offset(px, markY),
        3.5,
        Paint()..color = AppColors.charcoal,
      );
    }
    final head = _tp('the seven offsets', size: 9.5, color: AppColors.ink3);
    inkLabel(canvas, head, Offset(left - 10, markY - 18));

    for (final (row, (name, weights, tone)) in [
      ('trapezoidal', _trap, AppColors.charcoal),
      ('Simpson', _simpson, AppColors.ember),
    ].indexed) {
      final y = size.height * (row == 0 ? 0.50 : 0.76);
      final n = _tp(name, size: 10, color: tone);
      inkLabel(canvas, n, Offset(left - 10, y - 22));
      for (var i = 0; i < weights.length; i++) {
        final px = left + step * i;
        final ends = i == 0 || i == weights.length - 1;
        final t = _tp(
          weights[i],
          size: ends ? 12 : 11,
          color: ends ? tone : AppColors.ink2,
        );
        inkLabel(canvas, t, Offset(px - t.width / 2, y - 6));
      }
    }
  }

  @override
  bool shouldRepaint(_WeightsPainter old) => false;
}

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
      inkLabel(canvas, tp, center ? at - Offset(tp.width / 2, 0) : at);
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
