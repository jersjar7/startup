// The pictures on the Transportation Engineering concept sheets.
//
// A sheet is read picture first (owner's call, 2026-09-30): the drawing the
// student just played with, with one thing happening in it, then the idea in
// short steps, then the rule. Built from the same painters the games draw
// with; see mechanics_pictures.dart for the pattern and the shared
// ConceptPicture and ConceptPair tiles.

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';
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
  // Two roads, each carrying four rows of labels. At 210 the name of the
  // second road landed on the first road's own numbers.
  height: 280,
);

Widget peakHourPicture() => const ConceptPicture(
  painter: _QuartersPainter(),
  caption:
      'one hour in four quarters. the busiest one, run for a whole hour, is '
      'what the road is designed for',
  height: 215,
);

// ---------------------------------------------------------------------------
// 119 Vertical curves

Widget crestSagPicture() => const Column(
  children: [
    ConceptPicture(
      painter: CriterionPainter(
        criterion: Criterion(breakSize: 8, sight: 500, sag: false),
        answered: true,
      ),
      caption: 'over a hill: the road itself blocks the view',
      height: 170,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: CriterionPainter(
        criterion: Criterion(breakSize: 8, sight: 300, sag: true),
        answered: true,
      ),
      caption: 'into a dip: at night the headlights run out first',
      height: 170,
    ),
  ],
);

Widget gradeBreakPicture() => const ConceptPair(
  left: _GradeBreakPainter(gradeIn: 3, gradeOut: -5),
  right: _GradeBreakPainter(gradeIn: -2, gradeOut: -5),
  leftCaption: 'up 3 then down 5: the break is 8, not 2',
  rightCaption: 'down 2 then down 5: the break is only 3',
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

Widget demandFlowPicture() => const ConceptPicture(
  painter: _DivisionChainPainter(),
  caption:
      'one hourly count through its three divisions. two raise the number, '
      'one lowers it',
  height: 215,
);

Widget levelOfServicePicture() => const ConceptPicture(
  painter: _DensityPainter(),
  caption:
      'density is cars packed into a mile of one lane. the letter is read '
      'off that',
  height: 225,
);

// ---------------------------------------------------------------------------
// 124 Travel demand

Widget fourStepPicture() => const ConceptPicture(
  painter: _TripFlowPainter(),
  caption:
      'the same thousand trips down the page. each step splits what the one '
      'above it made',
  height: 225,
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

// Stacked: this painter writes three lines of numbers against each
// destination, and at half width they ran across each other and across the
// places they belong to.
Widget frictionPicture() => const Column(
  children: [
    ConceptPicture(
      painter: GravityPainter(
        spread: Spread(
          produced: 1000,
          destinations: [
            Destination(name: 'near', attractions: 250, friction: 0.6),
            Destination(name: 'far', attractions: 250, friction: 0.15),
          ],
        ),
        answered: true,
      ),
      caption: 'same size, one further away: the near one wins',
      height: 200,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: GravityPainter(
        spread: Spread(
          produced: 1000,
          destinations: [
            Destination(name: 'near', attractions: 250, friction: 0.6),
            Destination(name: 'far', attractions: 1200, friction: 0.15),
          ],
        ),
        answered: true,
      ),
      caption: 'the far one five times bigger: now it wins anyway',
      height: 200,
    ),
  ],
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
  painter: _CrashTradePainter(),
  caption:
      'what a signal buys and what it costs: fewer crashes from the side, '
      'more from behind',
  height: 225,
);

// ---------------------------------------------------------------------------
// 126 Flexible pavement

const _lessonSection = Pavement(
  courses: [
    Course(name: 'asphalt', coefficient: 0.44, thickness: 3),
    Course(name: 'base', coefficient: 0.14, thickness: 8),
    Course(name: 'subbase', coefficient: 0.11, thickness: 10),
  ],
);

Widget structuralNumberPicture() => const ConceptPicture(
  painter: PavementPainter(pavement: _lessonSection, answered: true),
  caption: 'the road in section, and what each course is worth',
  height: 225,
);

Widget layerThicknessPicture() => const ConceptPicture(
  painter: _GapPainter(),
  caption:
      'the fixed layers stacked against the target. the hatched space is '
      'what the missing layer has to fill',
  height: 230,
);

Widget esalPicture() => const ConceptPicture(
  painter: EsalPainter(
    axles: [
      Axle(name: 'a car axle', kips: 2, factor: 0.0002),
      Axle(name: 'the standard', kips: 18, factor: 1.0),
      Axle(name: 'a loaded truck', kips: 24, factor: 3.03),
    ],
    answered: true,
  ),
  caption: 'three axles, and the damage each one does to the road',
  height: 215,
);

// ---------------------------------------------------------------------------
// 127 Rigid pavement

Widget rigidVsFlexiblePicture() => const ConceptPicture(
  painter: SlabPainter(load: Loaded(kind: Surfacing.rigid), answered: true),
  caption:
      'the same wheel on concrete and on asphalt, and the ground each one '
      'leans on',
  height: 225,
);

Widget jointPicture() => const ConceptPair(
  left: JointPainter(
    joint: Joint(
      name: 'a transverse joint, across the lane',
      steel: Steel.dowel,
      whatItDoes: 'the dowel hands the wheel load to the next slab',
    ),
    answered: true,
  ),
  right: JointPainter(
    joint: Joint(
      name: 'a longitudinal joint, between two lanes',
      steel: Steel.tie,
      whatItDoes: 'the tie bar holds the two lanes together',
    ),
    answered: true,
  ),
  leftCaption: 'a smooth dowel: passes the load, lets the slabs move',
  rightCaption: 'a ribbed tie bar: bonded in, holds the joint shut',
  height: 200,
);

Widget subgradeReactionPicture() => const ConceptPair(
  left: SupportPainter(stiffness: 100, answered: true),
  right: SupportPainter(stiffness: 400, answered: true),
  leftCaption: 'soft ground: the springs squash a long way',
  rightCaption: 'stiff ground: the same push moves it much less',
  height: 200,
);

// ---------------------------------------------------------------------------
// 134 Earthwork quantities

Widget yardsPicture() => const ConceptPicture(
  painter: HaulPainter(
    haul: Haul(
      slabs: [
        Slab(station: 1000, area: 200),
        Slab(station: 1050, area: 240),
        Slab(station: 1100, area: 300),
      ],
    ),
    showEndAverage: true,
    locked: true,
  ),
  caption:
      'three cuts along a road. the dirt between them is what gets paid for',
  height: 220,
);

/// An hour split into four quarter hour counts, with the busiest one picked
/// out and stretched to show what a whole hour at that rate would be.
///
/// The game's own PeakPainter writes three labels along one line, which
/// collide at the width a concept sheet gives it, so this sheet draws the
/// same four quarters with room to breathe.
class _QuartersPainter extends CustomPainter {
  const _QuartersPainter();

  static const counts = [250.0, 400.0, 300.0, 250.0];

  void _write(
    Canvas canvas,
    String text,
    Offset at, {
    Color color = AppColors.ink2,
    double size = 10,
    bool center = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTheme.mono(size: size, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    inkLabel(canvas, tp, center ? Offset(at.dx - tp.width / 2, at.dy) : at);
  }

  @override
  void paint(Canvas canvas, Size size) {
    const busiest = 1;
    final base = size.height - 40;
    final top = 42.0;
    final left = size.width * 0.08;
    final slot = (size.width * 0.52) / counts.length;
    final tallest = counts.reduce((a, b) => a > b ? a : b);

    for (var i = 0; i < counts.length; i++) {
      final h = (base - top) * counts[i] / tallest;
      final rect = Rect.fromLTWH(left + i * slot + 5, base - h, slot - 10, h);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        ),
        Paint()
          ..color = i == busiest
              ? AppColors.ember
              : AppColors.ink3.withValues(alpha: 0.45),
      );
      _write(
        canvas,
        counts[i].toStringAsFixed(0),
        Offset(rect.center.dx, rect.top - 14),
        color: i == busiest ? AppColors.ember : AppColors.ink2,
        center: true,
      );
    }

    canvas.drawLine(
      Offset(left, base),
      Offset(left + counts.length * slot, base),
      Paint()
        ..color = AppColors.ink3
        ..strokeWidth = 1.5,
    );
    _write(
      canvas,
      'four quarter hours\n1,200 in the hour altogether',
      Offset(left, base + 8),
    );

    // The busiest quarter, run for a whole hour.
    final markX = left + counts.length * slot + 22;
    final full = base - (base - top) * 1.0;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(markX, full, size.width - 14, base),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      ),
      Paint()..color = AppColors.ember.withValues(alpha: 0.28),
    );
    _write(
      canvas,
      'x4 = 1,600',
      Offset((markX + size.width - 14) / 2, full - 15),
      color: AppColors.ember,
      center: true,
    );
    _write(
      canvas,
      'the whole hour at\nthe busiest rate',
      Offset(markX, base + 8),
    );
  }

  @override
  bool shouldRepaint(_QuartersPainter old) => false;
}

/// Two grades meeting at a corner, with the size of the change between them.
///
/// The curve painters annotate the curve itself, which is not what this
/// sheet is about: here the whole point is how big the change of slope is,
/// and whether the two grades add or subtract.
class _GradeBreakPainter extends CustomPainter {
  const _GradeBreakPainter({required this.gradeIn, required this.gradeOut});

  final double gradeIn;
  final double gradeOut;

  double get _break => (gradeOut - gradeIn).abs();

  void _write(
    Canvas canvas,
    String text,
    Offset at, {
    Color color = AppColors.ink2,
    double size = 10,
    bool center = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTheme.mono(size: size, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    inkLabel(canvas, tp, center ? Offset(at.dx - tp.width / 2, at.dy) : at);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.1;
    final right = size.width * 0.9;
    final mid = (left + right) / 2;
    final middleY = size.height * 0.52;
    // A per cent of grade is drawn as this many pixels of rise.
    final scale = size.height * 0.035;

    final a = Offset(left, middleY - gradeIn * scale * -1);
    final corner = Offset(mid, middleY);
    final b = Offset(right, middleY + gradeOut * scale * -1);

    final road = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(a, corner, road);
    canvas.drawLine(corner, b, road);

    canvas.drawCircle(corner, 4, Paint()..color = AppColors.ember);

    _write(
      canvas,
      '${gradeIn > 0 ? '+' : ''}${gradeIn.toStringAsFixed(0)}%',
      Offset((left + mid) / 2, (a.dy + corner.dy) / 2 - 22),
      center: true,
      color: AppColors.charcoal,
    );
    _write(
      canvas,
      '${gradeOut > 0 ? '+' : ''}${gradeOut.toStringAsFixed(0)}%',
      Offset((mid + right) / 2, (corner.dy + b.dy) / 2 + 8),
      center: true,
      color: AppColors.charcoal,
    );
    _write(
      canvas,
      'the change is ${_break.toStringAsFixed(0)}',
      Offset(mid, size.height - 22),
      center: true,
      color: AppColors.ember,
      size: 11,
    );
  }

  @override
  bool shouldRepaint(_GradeBreakPainter old) =>
      old.gradeIn != gradeIn || old.gradeOut != gradeOut;
}

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
  'section': structuralNumberPicture,
  'thickness': layerThicknessPicture,
  'esals': esalPicture,
  'slab': rigidVsFlexiblePicture,
  'joints': jointPicture,
  'support': subgradeReactionPicture,
  'yards': yardsPicture,
};

// ---------------------------------------------------------------------------
// The painters written for a sheet, where the game's own drawing could not
// carry the idea (second pass, 2026-09-30).

/// Shared text helper for the sheet-only painters below.
void _say(
  Canvas canvas,
  String text,
  Offset at, {
  Color color = AppColors.ink2,
  double size = 10,
  bool center = false,
  bool right = false,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: AppTheme.mono(size: size, color: color),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  var x = at.dx;
  if (center) x -= tp.width / 2;
  if (right) x -= tp.width;
  inkLabel(canvas, tp, Offset(x, at.dy));
}

/// One hourly count walked through its three divisions, each bar as long as
/// the number it holds, so the two that RAISE it and the one that lowers it
/// are visible rather than asserted.
class _DivisionChainPainter extends CustomPainter {
  const _DivisionChainPainter();

  // 4,500 an hour; peak factor 0.92; 3 lanes; 10 per cent trucks at 2 cars.
  // Each row is (what this step divides by, the number it leaves, which way
  // that moved it). The first row is the count you start with.
  static const _rows = <(String, double, String)>[
    ('the count on the road, one hour', 4500, ''),
    ('divide by the peak factor 0.92', 4891, 'up'),
    ('divide by the 3 lanes', 1630, 'down'),
    ('divide by the truck factor 0.91', 1793, 'up'),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const left = 14.0;
    final right = size.width - 62;
    const top = 30.0;
    final gap = (size.height - top - 24) / _rows.length;
    const widest = 4891.0;

    for (var i = 0; i < _rows.length; i++) {
      final (label, value, way) = _rows[i];
      final y = top + i * gap;
      final w = (right - left) * value / widest;
      final bar = Rect.fromLTWH(left, y, w, 13);
      final last = i == _rows.length - 1;
      canvas.drawRRect(
        RRect.fromRectAndRadius(bar, const Radius.circular(3)),
        Paint()
          ..color = last
              ? AppColors.ember
              : AppColors.ink3.withValues(alpha: 0.45),
      );
      final shown = value
          .toStringAsFixed(0)
          .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
      _say(
        canvas,
        shown,
        Offset(bar.right + 6, y - 1),
        color: last ? AppColors.ember : AppColors.ink2,
        size: 11,
      );

      // What this step did, written above its own bar.
      final tone = way.isEmpty
          ? AppColors.ink2
          : (way == 'up' ? AppColors.ember : AppColors.info);
      _say(
        canvas,
        way.isEmpty
            ? label
            : '$label, ${way == 'up' ? 'raises it' : 'lowers it'}',
        Offset(left, y - 13),
        size: 9,
        color: tone,
      );

      // The step from the bar above to this one.
      if (way.isNotEmpty) {
        final x = left + 5;
        final to = Offset(x, y - 16);
        final paint = Paint()
          ..color = tone
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(x, y - gap + 15), to, paint);
        canvas.drawPath(
          Path()
            ..moveTo(to.dx, to.dy + 2)
            ..lineTo(to.dx - 3.2, to.dy - 3)
            ..lineTo(to.dx + 3.2, to.dy - 3)
            ..close(),
          Paint()..color = tone,
        );
      }
    }

    _say(
      canvas,
      'cars an hour in one lane, at the busiest quarter hour rate',
      Offset(left, size.height - 15),
      size: 9,
      color: AppColors.ember,
    );
  }

  @override
  bool shouldRepaint(_DivisionChainPainter old) => false;
}

/// Density drawn as what it is: cars packed into one mile of one lane. Two
/// strips carrying the same length of road and very different numbers of
/// cars, with the letter each one earns.
class _DensityPainter extends CustomPainter {
  const _DensityPainter();

  void _lane(
    Canvas canvas,
    Rect box,
    int cars,
    String label,
    String letter,
    Color tone,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(4)),
      Paint()..color = AppColors.creamDark,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(4)),
      Paint()
        ..color = AppColors.ink3
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    const carW = 8.0;
    final slot = (box.width - 10) / cars;
    for (var i = 0; i < cars; i++) {
      final x = box.left + 5 + i * slot + (slot - carW) / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, box.center.dy - 4, carW, 8),
          const Radius.circular(1.5),
        ),
        Paint()..color = tone,
      );
    }
    _say(canvas, label, Offset(box.left, box.top - 13), size: 9, color: tone);
    _say(
      canvas,
      letter,
      Offset(box.right + 8, box.center.dy - 7),
      size: 13,
      color: tone,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.06;
    final right = size.width - 32;
    _lane(
      canvas,
      Rect.fromLTRB(left, 28, right, 50),
      10,
      'a mile of one lane, 10 cars in it',
      'A',
      AppColors.forest,
    );
    _lane(
      canvas,
      Rect.fromLTRB(left, 84, right, 106),
      30,
      'the same mile, 30 cars in it',
      'D',
      AppColors.ember,
    );
    _say(
      canvas,
      'same road, same mile. how packed it is, is the question',
      Offset(left, 116),
      size: 9,
    );

    // The bands the count is read against.
    final bandTop = size.height - 52;
    const bands = ['A', 'B', 'C', 'D', 'E', 'F'];
    const edges = [11, 18, 26, 35, 45];
    final w = (right - left) / bands.length;
    for (var i = 0; i < bands.length; i++) {
      final box = Rect.fromLTWH(left + i * w, bandTop, w - 2, 16);
      canvas.drawRect(
        box,
        Paint()
          ..color = i == 3
              ? AppColors.ember.withValues(alpha: 0.3)
              : AppColors.ink3.withValues(alpha: 0.18),
      );
      _say(
        canvas,
        bands[i],
        Offset(box.center.dx, bandTop + 3),
        center: true,
        size: 10,
      );
      if (i < edges.length) {
        _say(
          canvas,
          '${edges[i]}',
          Offset(box.right - 1, bandTop + 19),
          center: true,
          size: 8.5,
        );
      }
    }
    _say(
      canvas,
      'cars to a mile of lane: the letter is read off this',
      Offset(left, bandTop + 31),
      size: 9,
      color: AppColors.ink3,
    );
  }

  @override
  bool shouldRepaint(_DensityPainter old) => false;
}

/// The four steps as the trips themselves, not as four labeled boxes: the
/// same ten dots carried down the page, split differently at each stage, so
/// "each step eats what the one before made" is something you can follow.
class _TripFlowPainter extends CustomPainter {
  const _TripFlowPainter();

  void _dots(Canvas canvas, Offset start, int n, Color tone) {
    for (var i = 0; i < n; i++) {
      canvas.drawCircle(
        Offset(start.dx + i * 10.5, start.dy),
        3.2,
        Paint()..color = tone,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.33;
    final rowGap = (size.height - 30) / 4;
    const names = ['GENERATION', 'DISTRIBUTION', 'MODE CHOICE', 'ASSIGNMENT'];
    const asides = [
      'ten dots: a thousand trips made',
      'six downtown, four to the mall',
      'of those, eight drive and two ride',
      'the drivers pick: five the highway, three through town',
    ];

    for (var r = 0; r < 4; r++) {
      final y = 22 + r * rowGap;
      _say(
        canvas,
        names[r],
        Offset(left - 12, y - 5),
        right: true,
        size: 8.5,
        color: AppColors.charcoal,
      );
      _say(
        canvas,
        asides[r],
        Offset(left + 2, y + 11),
        size: 8.5,
        color: AppColors.ink3,
      );

      switch (r) {
        case 0:
          _dots(canvas, Offset(left + 8, y), 10, AppColors.charcoal);
        case 1:
          _dots(canvas, Offset(left + 8, y), 6, AppColors.ember);
          _dots(canvas, Offset(left + 8 + 6 * 10.5 + 9, y), 4, AppColors.info);
        case 2:
          _dots(canvas, Offset(left + 8, y), 8, AppColors.charcoal);
          _dots(
            canvas,
            Offset(left + 8 + 8 * 10.5 + 9, y),
            2,
            AppColors.forest,
          );
        case 3:
          // Two roads, each carrying the trips routed onto it.
          final road = Paint()
            ..color = AppColors.ink3
            ..strokeWidth = 1.2;
          canvas.drawLine(
            Offset(left + 3, y + 6),
            Offset(left + 8 + 4 * 10.5 + 3, y + 6),
            road,
          );
          canvas.drawLine(
            Offset(left + 8 + 5 * 10.5 + 4, y + 6),
            Offset(left + 8 + 7 * 10.5 + 4, y + 6),
            road,
          );
          _dots(canvas, Offset(left + 8, y), 5, AppColors.ember);
          _dots(canvas, Offset(left + 8 + 5 * 10.5 + 9, y), 3, AppColors.info);
      }

      if (r < 3) {
        final x = left - 24;
        canvas.drawLine(
          Offset(x, y + 4),
          Offset(x, y + rowGap - 13),
          Paint()
            ..color = AppColors.ink3
            ..strokeWidth = 1.4,
        );
        canvas.drawPath(
          Path()
            ..moveTo(x, y + rowGap - 8)
            ..lineTo(x - 3.5, y + rowGap - 14)
            ..lineTo(x + 3.5, y + rowGap - 14)
            ..close(),
          Paint()..color = AppColors.ink3,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_TripFlowPainter old) => false;
}

/// The trade a signal makes, which is the whole reason it needs a warrant:
/// the crashes that hurt people go down, the ones that usually do not go up.
class _CrashTradePainter extends CustomPainter {
  const _CrashTradePainter();

  /// Two cars meeting at right angles, or nose to tail.
  void _cars(
    Canvas canvas,
    Offset at, {
    required bool angle,
    required Color tone,
  }) {
    final body = Paint()..color = AppColors.charcoal;
    final road = Paint()
      ..color = AppColors.ink3.withValues(alpha: 0.5)
      ..strokeWidth = 1.2;
    if (angle) {
      // Two roads crossing, and a car coming along each.
      canvas.drawLine(
        Offset(at.dx - 46, at.dy),
        Offset(at.dx + 46, at.dy),
        road,
      );
      canvas.drawLine(
        Offset(at.dx, at.dy - 26),
        Offset(at.dx, at.dy + 26),
        road,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(at.dx - 32, at.dy - 5, 22, 10),
          const Radius.circular(2),
        ),
        body,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(at.dx - 5, at.dy - 26, 10, 20),
          const Radius.circular(2),
        ),
        body,
      );
    } else {
      // One road, two cars nose to tail.
      canvas.drawLine(
        Offset(at.dx - 46, at.dy),
        Offset(at.dx + 46, at.dy),
        road,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(at.dx - 34, at.dy - 5, 22, 10),
          const Radius.circular(2),
        ),
        body,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(at.dx - 4, at.dy - 5, 22, 10),
          const Radius.circular(2),
        ),
        body,
      );
    }
    canvas.drawCircle(at, 5.5, Paint()..color = tone.withValues(alpha: 0.75));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final midX = size.width / 2;
    final left = size.width * 0.07;
    final right = size.width - left;
    final lc = left + (midX - 12 - left) / 2;
    final rc = midX + 12 + (right - midX - 12) / 2;

    _say(
      canvas,
      'no signal',
      Offset(lc, 14),
      center: true,
      size: 10,
      color: AppColors.charcoal,
    );
    _say(
      canvas,
      'with a signal',
      Offset(rc, 14),
      center: true,
      size: 10,
      color: AppColors.charcoal,
    );

    _cars(canvas, Offset(lc, 62), angle: true, tone: AppColors.error);
    _cars(canvas, Offset(rc, 62), angle: false, tone: AppColors.sunbeam);

    canvas.drawLine(
      Offset(midX, 8),
      Offset(midX, size.height - 22),
      Paint()
        ..color = AppColors.line
        ..strokeWidth = 1,
    );

    // How often each kind happens, before and after.
    final base = size.height - 32;
    const top = 100.0;
    void bar(double cx, double share, Color tone, String label) {
      final h = (base - top) * share;
      final r = Rect.fromLTWH(cx - 12, base - h, 24, h);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          r,
          topLeft: const Radius.circular(2),
          topRight: const Radius.circular(2),
        ),
        Paint()..color = tone,
      );
      _say(canvas, label, Offset(cx, base + 4), center: true, size: 8.5);
    }

    bar(lc - 19, 1.0, AppColors.error, 'side');
    bar(lc + 19, 0.25, AppColors.sunbeam, 'rear');
    bar(rc - 19, 0.3, AppColors.error, 'side');
    bar(rc + 19, 0.75, AppColors.sunbeam, 'rear');

    _say(
      canvas,
      'from the side hurts people. from behind usually does not',
      Offset(10, size.height - 15),
      size: 8.5,
      color: AppColors.ink2,
    );
  }

  @override
  bool shouldRepaint(_CrashTradePainter old) => false;
}

/// The design target as a column, what the fixed layers already give, and
/// the gap left over, which is the thing this sheet is actually about.
class _GapPainter extends CustomPainter {
  const _GapPainter();

  // Target 4.5. Asphalt 0.44 x 3 = 1.32. Subbase 0.11 x 10 x 0.80 = 0.88.
  // Left to find: 2.30, at 0.14 an inch = 16.4 inches of base.
  @override
  void paint(Canvas canvas, Size size) {
    const target = 4.5;
    const asphalt = 1.32;
    const subbase = 0.88;
    const gapValue = target - asphalt - subbase;

    final left = size.width * 0.12;
    const colW = 66.0;
    final base = size.height - 32;
    const top = 32.0;
    double yFor(double v) => base - (base - top) * v / target;

    final whole = Rect.fromLTRB(left, top, left + colW, base);
    canvas.drawRRect(
      RRect.fromRectAndRadius(whole, const Radius.circular(4)),
      Paint()
        ..color = AppColors.charcoal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    _say(
      canvas,
      'the target: 4.5',
      Offset(left, top - 16),
      size: 10,
      color: AppColors.charcoal,
    );

    void slab(double from, double to, Color tone, String label) {
      final r = Rect.fromLTRB(left + 2, yFor(to), left + colW - 2, yFor(from));
      canvas.drawRect(r, Paint()..color = tone);
      _say(
        canvas,
        label,
        Offset(left + colW + 10, r.center.dy - 5),
        size: 9,
        color: tone == AppColors.ink3 ? AppColors.ink2 : tone,
      );
    }

    slab(0, subbase, AppColors.ink3, 'subbase gives 0.88');
    slab(subbase, subbase + asphalt, AppColors.charcoal, 'asphalt gives 1.32');

    // The gap, hatched so it reads as empty rather than as another layer.
    final gapRect = Rect.fromLTRB(
      left + 2,
      yFor(target),
      left + colW - 2,
      yFor(subbase + asphalt),
    );
    canvas.save();
    canvas.clipRect(gapRect);
    final hatch = Paint()
      ..color = AppColors.ember.withValues(alpha: 0.5)
      ..strokeWidth = 1.2;
    for (var x = gapRect.left - gapRect.height; x < gapRect.right; x += 7) {
      canvas.drawLine(
        Offset(x, gapRect.bottom),
        Offset(x + gapRect.height, gapRect.top),
        hatch,
      );
    }
    canvas.restore();
    canvas.drawRect(
      gapRect,
      Paint()
        ..color = AppColors.ember
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    _say(
      canvas,
      'the gap left: ${gapValue.toStringAsFixed(2)}',
      Offset(left + colW + 10, gapRect.center.dy - 20),
      size: 10,
      color: AppColors.ember,
    );
    _say(
      canvas,
      'divide by 0.14 an inch',
      Offset(left + colW + 10, gapRect.center.dy - 6),
      size: 9,
      color: AppColors.ember,
    );
    _say(
      canvas,
      'gives 16.4 in of base',
      Offset(left + colW + 10, gapRect.center.dy + 8),
      size: 10,
      color: AppColors.ember,
    );

    _say(
      canvas,
      'what the fixed layers give, and what is still missing',
      Offset(10, size.height - 20),
      size: 9,
    );
  }

  @override
  bool shouldRepaint(_GapPainter old) => false;
}
