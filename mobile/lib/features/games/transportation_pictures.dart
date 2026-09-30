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
  painter: PavementPainter(
    pavement: Pavement(
      courses: [
        Course(name: 'asphalt', coefficient: 0.44, thickness: 3),
        Course(name: 'base', coefficient: 0.14, thickness: 8),
        Course(
          name: 'subbase',
          coefficient: 0.11,
          thickness: 10,
          drainage: 0.80,
        ),
      ],
      required_: 4.5,
    ),
    answered: true,
  ),
  caption: 'the same road with a subbase that drains badly, and the gap left',
  height: 225,
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
    tp.paint(canvas, center ? Offset(at.dx - tp.width / 2, at.dy) : at);
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
    tp.paint(canvas, center ? Offset(at.dx - tp.width / 2, at.dy) : at);
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
