// The pictures on the Geotechnical Engineering concept sheets.
//
// A sheet is read picture first (owner's call, 2026-09-30): the drawing the
// student just played with, with one thing happening in it, then the idea in
// short steps, then the rule. Built from the same painters the games draw
// with; see mechanics_pictures.dart for the pattern and the shared
// ConceptPicture and ConceptPair tiles.
//
// Every painter in this chapter takes `answered: true` here. In a round it
// hides the answer; on a sheet there is no answer to hide, so the drawing
// shows everything it knows.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';
import 'bearing_figures.dart';
import 'compaction_figures.dart';
import 'consolidation_figures.dart';
import 'earth_pressure_figures.dart';
import 'effective_stress_figures.dart';
import 'mechanics_pictures.dart' show ConceptPicture, ConceptPair;
import 'phase_figures.dart';
import 'pile_figures.dart';
import 'seepage_figures.dart';
import 'shear_strength_figures.dart';
import 'slope_figures.dart';
import 'wall_stability_figures.dart';
import 'soil_class_figures.dart';

/// Two drawings one above the other, full width. The painters in this
/// chapter write long labels across their own width, so a pair of them side
/// by side collides; stacked, each gets the whole column.
Widget _stack(
  CustomPainter top,
  String topCaption,
  CustomPainter bottom,
  String bottomCaption, {
  double height = 200,
}) => Column(
  children: [
    ConceptPicture(painter: top, caption: topCaption, height: height),
    const SizedBox(height: 12),
    ConceptPicture(painter: bottom, caption: bottomCaption, height: height),
  ],
);

// ---------------------------------------------------------------------------
// Phase relationships

const _sample = Soil(gs: 2.70, water: 0.20, voidRatio: 0.54);

Widget phasePicture() => const ConceptPicture(
  painter: PhaseDiagramPainter(
    soil: _sample,
    over: Phase.voids,
    under: Phase.solids,
    answered: true,
  ),
  caption:
      'one scoop of soil as three blocks. Volumes down the left, weights down the right',
  height: 230,
);

Widget masterPicture() => const Column(
  children: [
    ConceptPicture(
      painter: _ScaleAndRulerPainter(),
      caption:
          'the same sample, two habits. space is measured with a ruler, '
          'weight is weighed on a scale, and Gs is the only way across',
      height: 215,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: PhaseDiagramPainter(
        soil: _sample,
        over: Phase.water,
        under: Phase.solids,
        answered: true,
      ),
      caption: 'water content: the water weighed against the grains weighed',
      height: 230,
    ),
  ],
);

Widget gammaPicture() => const ConceptPicture(
  painter: UnitWeightPainter(soil: _sample, answered: true),
  caption: 'one soil, weighed four ways, drawn to one scale',
  height: 210,
);

// ---------------------------------------------------------------------------
// Classification

const _coarse = Graded(
  passing200: 4,
  passing4: 92,
  d10: 0.15,
  d30: 0.50,
  d60: 2.0,
);
const _fine = Graded(
  passing200: 72,
  passing4: 99,
  d10: 0.012,
  d30: 0.03,
  d60: 0.09,
);
const _wellGraded = Graded(
  passing200: 3,
  passing4: 95,
  d10: 0.10,
  d30: 0.45,
  d60: 1.2,
);
const _uniform = Graded(
  passing200: 2,
  passing4: 99,
  d10: 0.30,
  d30: 0.38,
  d60: 0.50,
);

Widget forkPicture() => _stack(
  const SizeCurvePainter(soil: _coarse, answered: true),
  'the curve is still high at the No 200: only 4 percent got through, so coarse',
  const SizeCurvePainter(soil: _fine, answered: true),
  'this one has fallen to 72 percent by then: most got through, so fine',
  height: 195,
);

Widget chartPicture() => _stack(
  const PlasticityPainter(
    fines: Fines(liquidLimit: 45, plasticityIndex: 22),
    answered: true,
  ),
  'above the sloping line and left of 50: CL, a lean clay',
  const PlasticityPainter(
    fines: Fines(liquidLimit: 62, plasticityIndex: 22),
    answered: true,
  ),
  'the same height up, but further right and now under the line: MH, a silt',
  height: 210,
);

Widget gradationPicture() => _stack(
  const SizeCurvePainter(soil: _wellGraded, answered: true),
  'a long gentle curve: the three marked sizes are far apart, every size is there',
  const SizeCurvePainter(soil: _uniform, answered: true),
  'a cliff: all three sizes almost on top of each other, so it is all one size',
  height: 195,
);

// ---------------------------------------------------------------------------
// Effective stress

const _profile = Deposit(
  layers: [
    Stratum(name: 'dry sand', thickness: 5, unitWeight: 110),
    Stratum(
      name: 'saturated clay',
      thickness: 8,
      unitWeight: 120,
      saturated: true,
    ),
  ],
  waterDepth: 5,
);

const _pumpedDown = Deposit(
  layers: [
    Stratum(name: 'dry sand', thickness: 5, unitWeight: 110),
    Stratum(
      name: 'saturated clay',
      thickness: 8,
      unitWeight: 120,
      saturated: true,
    ),
  ],
  waterDepth: 13,
);

const _surcharged = Deposit(
  layers: [
    Stratum(name: 'sand', thickness: 6, unitWeight: 105),
    Stratum(
      name: 'saturated clay',
      thickness: 10,
      unitWeight: 118,
      saturated: true,
    ),
  ],
  waterDepth: 6,
  surcharge: 100,
);

Widget threeStressPicture() => const ConceptPicture(
  painter: DepositPainter(deposit: _profile, at: 11, answered: true),
  caption:
      'a hole down to 11 feet. The three stresses at that depth are written out',
  height: 240,
);

Widget waterTablePicture() => _stack(
  const DepositPainter(deposit: _profile, at: 11, answered: true),
  'water standing at 5 feet: at 11 feet down the grains carry 896',
  const DepositPainter(deposit: _pumpedDown, at: 11, answered: true),
  'pumped down past the clay: nothing else changed, and the grains carry 1270',
  height: 225,
);

Widget shortWayPicture() => const ConceptPicture(
  painter: DepositPainter(deposit: _surcharged, at: 16, answered: true),
  caption:
      'a load on top, then sand, then clay. Walk down adding one layer at a time',
  height: 240,
);

// ---------------------------------------------------------------------------
// Consolidation

const _crossing = Squeeze(now: 1000, remembered: 1500, added: 1000);
const _bothWays = Drainage(thickness: 10, topDrains: true, bottomDrains: true);
const _onRock = Drainage(thickness: 10, topDrains: true, bottomDrains: false);

Widget casePicture() => const ConceptPicture(
  painter: StressLinePainter(squeeze: _crossing, answered: true),
  caption:
      'where the clay is now, what it remembers, and where the load takes it',
  height: 200,
);

Widget memoryPicture() => const ConceptPicture(
  painter: ElogPPainter(squeeze: _crossing, answered: true),
  caption:
      'squeeze a clay and it goes stiffly, then softly. The corner is its memory',
  height: 220,
);

Widget drainagePicture() => const ConceptPair(
  left: DrainagePainter(drain: _bothWays, answered: true),
  right: DrainagePainter(drain: _onRock, answered: true),
  leftCaption: 'sand above and below: water leaves both ways',
  rightCaption: 'rock underneath: every drop has to climb the whole layer',
  height: 210,
);

// ---------------------------------------------------------------------------
// Shear strength

const _cleanSand = Failure(cohesion: 0, friction: 34);
const _fastClay = Failure(cohesion: 1200, friction: 0);

Widget mohrCoulombPicture() => _stack(
  const EnvelopePainter(failure: _cleanSand, answered: true),
  'a clean sand: the line starts at nothing and climbs as the grains are pressed',
  const EnvelopePainter(failure: _fastClay, answered: true),
  'a clay loaded fast: a flat line, the same strength however hard you press',
  height: 190,
);

Widget drainedPicture() => _stack(
  const EnvelopePainter(
    failure: Failure(cohesion: 100, friction: 28),
    answered: true,
  ),
  'the slow set: a small constant and a slope, used with what the grains feel',
  const EnvelopePainter(failure: _fastClay, answered: true),
  'the fast set: one number, no slope, used with the whole weight above',
  height: 190,
);

// A cell of 4000 with 8000 more on top makes a circle centered on 8000 with
// a radius of 4000, which touches a line through the origin at 30 degrees
// exactly. Drawn against any other angle the picture would be a lie.
Widget mohrCirclePicture() => const ConceptPicture(
  painter: EnvelopePainter(
    failure: Failure(cohesion: 0, friction: 30),
    test: Triaxial(cell: 4000, deviator: 8000),
    answered: true,
  ),
  caption:
      'one test drawn as a circle. It touches the line at the plane that gave way',
  height: 230,
);

// ---------------------------------------------------------------------------
// Seepage

const _net = FlowNet(channels: 4, drops: 12, head: 6, k: 2e-5);
const _boiling = Quick(gs: 2.70, voidRatio: 0.85, exitGradient: 0.92);

Widget flowNetPicture() => const ConceptPicture(
  painter: FlowNetPainter(net: _net, answered: true),
  caption:
      'water goes under the wall. Count the lanes across, and the steps along',
  height: 240,
);

Widget quickPicture() => const ConceptPicture(
  painter: BoilPainter(quick: _boiling, answered: true),
  caption:
      'water climbing through sand, and what the grains are left pressing with',
  height: 230,
);

// ---------------------------------------------------------------------------
// Slopes

const _drySlope = Bank(slopeAngle: 20, friction: 34);
const _wetSlope = Bank(slopeAngle: 20, friction: 34, seeping: true);
const _wedge = Wedge2(
  cohesionForce: 120,
  weight: 400,
  slipAngle: 25,
  friction: 20,
);

Widget infiniteSlopePicture() => const ConceptPicture(
  painter: BankPainter(bank: _drySlope, answered: true),
  caption: 'a dry sand slope. Its own angle against the angle it can hold',
  height: 210,
);

Widget seepageSlopePicture() => _stack(
  const BankPainter(bank: _drySlope, answered: true),
  'the same slope dry: it stands, comfortably',
  const BankPainter(bank: _wetSlope, answered: true),
  'the same slope with rain running through it: it goes',
  height: 195,
);

Widget wedgePicture() => const ConceptPicture(
  painter: WedgePainter(wedge: _wedge, answered: true),
  caption:
      'a block on a sloping surface. Its weight both drives it and holds it on',
  height: 230,
);

// ---------------------------------------------------------------------------
// Bearing capacity

const _mixedFooting = Footing(
  width: 5,
  depth: 3,
  cohesion: 500,
  unitWeight: 115,
  nc: 14.83,
  nq: 6.40,
  nGamma: 3.54,
);
const _onSurface = Footing(
  width: 4,
  depth: 0,
  cohesion: 0,
  unitWeight: 120,
  nc: 30.14,
  nq: 18.40,
  nGamma: 15.07,
);
const _buried = Footing(
  width: 4,
  depth: 3,
  cohesion: 0,
  unitWeight: 120,
  nc: 30.14,
  nq: 18.40,
  nGamma: 15.07,
);
const _clayFooting = Footing(
  width: 6,
  depth: 3,
  cohesion: 1500,
  unitWeight: 115,
  nc: 5.14,
  nq: 1,
  nGamma: 0,
);

Widget terzaghiPicture() => const ConceptPicture(
  painter: FootingPainter(footing: _mixedFooting, answered: true),
  caption: 'a footing in the ground, and the three things holding it up',
  height: 240,
);

Widget footingFixPicture() => _stack(
  const FootingPainter(footing: _onSurface, answered: true),
  'a sand footing laid on the surface: the depth term is gone',
  const FootingPainter(footing: _buried, answered: true),
  'the same footing buried 3 feet: soil beside it now has to be shifted too',
  height: 210,
);

Widget allowablePicture() => const Column(
  children: [
    ConceptPicture(
      painter: _DividePainter(),
      caption:
          'the capacity gets divided, never the load. then two pressures are '
          'compared, and the top bar is not one of them',
      height: 215,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: FootingPainter(footing: _clayFooting, answered: true),
      caption: 'where the top bar came from: the pressure this ground fails at',
      height: 240,
    ),
  ],
);

// ---------------------------------------------------------------------------
// Lateral earth pressure

const _backfill = Backfill(height: 15, unitWeight: 120, friction: 30);
const _withSurchargeBehind = Backfill(
  height: 15,
  unitWeight: 120,
  friction: 30,
  surcharge: 300,
);
const _tallWall = Backfill(height: 30, unitWeight: 120, friction: 30);

Widget rankinePicture() => const ConceptPicture(
  painter: CoefficientPainter(backfill: _backfill, answered: true),
  caption:
      'the same soil, the same wall, three answers. What changed is what the wall did',
  height: 230,
);

Widget diagramShapePicture() => _stack(
  const WallPainter(backfill: _backfill, answered: true),
  'soil alone: nothing at the top, most at the bottom, so a triangle',
  const WallPainter(backfill: _withSurchargeBehind, answered: true),
  'add a load on the ground behind: a rectangle on top of the triangle',
  height: 230,
);

// The painter draws both walls in one panel when it is given `against`, so
// a pair of these would be the same picture printed twice.
Widget wallForcePicture() => const ConceptPicture(
  painter: WallPainter(backfill: _backfill, against: _tallWall, answered: true),
  caption: 'two walls to one scale. Twice as tall carries four times the force',
  height: 250,
);

// ---------------------------------------------------------------------------
// Retaining wall stability

const _wall = Gravity(
  baseWidth: 6,
  vertical: 5000,
  resisting: 15000,
  overturning: 5000,
);

Widget threeChecksPicture() => const Column(
  children: [
    ConceptPicture(
      painter: _ThreeFailuresPainter(),
      caption:
          'three ways the same wall can lose. the faint outline is where it '
          'started; the blue arrow is the same push every time',
      height: 215,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: StabilityPainter(
        wall: _wall,
        which: Check.overturning,
        answered: true,
      ),
      caption:
          'the wall itself: the push that tips it, the weight that holds it',
      height: 215,
    ),
  ],
);

Widget middleThirdPicture() => const ConceptPicture(
  painter: BasePainter(wall: _wall, withPressure: false, answered: true),
  caption:
      'the base seen from below, with the middle third marked and the resultant standing in it',
  height: 200,
);

Widget basePressurePicture() => const ConceptPicture(
  painter: BasePainter(wall: _wall, answered: true),
  caption:
      'the resultant sits off center, so the ground is pressed hardest under the toe',
  height: 230,
);

// ---------------------------------------------------------------------------
// Compaction

const _fill = Proctor(
  maxDryUnitWeight: 124,
  optimum: 12,
  fieldDryUnitWeight: 118,
  fieldMoisture: 10.5,
);
const _tooWet = Proctor(
  maxDryUnitWeight: 124,
  optimum: 12,
  fieldDryUnitWeight: 114,
  fieldMoisture: 16,
);
const _sand = Granular(loosest: 0.90, densest: 0.40, inPlace: 0.60);
const _swellingClay = Ground(
  name: 'a swelling clay subgrade',
  plasticityIndex: 34,
);

Widget proctorPicture() => _stack(
  const ProctorPainter(test: _fill, answered: true),
  'drier than the peak: adding water would help, because the grains can slide',
  const ProctorPainter(test: _tooWet, answered: true),
  'wetter than the peak: adding water makes it looser, and rolling will not fix it',
  height: 210,
);

Widget relativeDensityPicture() => const ConceptPicture(
  painter: PackingPainter(soil: _sand, answered: true),
  caption:
      'loosest this sand can sit, tightest it can be packed, and where it actually is',
  height: 200,
);

Widget stabilizerPicture() => const Column(
  children: [
    ConceptPicture(
      painter: _TreatmentPainter(),
      caption: 'what each one actually does to the ground',
      height: 200,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: StabilizerPainter(ground: _swellingClay, answered: true),
      caption:
          'and which soil each one suits: clean gravel at one end, fat clay '
          'at the other',
      height: 210,
    ),
  ],
);

// ---------------------------------------------------------------------------
// Piles

const _pile = Pile(
  tipResistance: 2000,
  tipArea: 0.20,
  skinFriction: 50,
  shaftArea: 12,
);

Widget pileCapacityPicture() => const ConceptPicture(
  painter: PilePainter(pile: _pile, answered: true),
  caption:
      'a pile holds up in two places: grip along the side, and bearing under the tip',
  height: 250,
);

Widget goingDeepPicture() => _stack(
  const DepthPainter(onFooting: true, answered: true),
  'a footing on soft ground: the load presses the layer that settles',
  const DepthPainter(piles: 3, answered: true),
  'piles through it: the load is carried past the soft layer to firm ground',
  height: 210,
);

Widget downdragPicture() => _stack(
  const PilePainter(pile: _pile, answered: true),
  'the pile pushes down through still soil, so the soil rubs UP: that grip holds it',
  const PilePainter(pile: _pile, downdrag: true, answered: true),
  'the ground settles past the pile, so the soil rubs DOWN: the same grip is now a load',
  height: 230,
);

/// Every picture on this chapter's sheets, by the contact sheet's card name.
const geotechnicalPictures = <String, Widget Function()>{
  'diagram': phasePicture,
  'master': masterPicture,
  'weights': gammaPicture,
  'tree': forkPicture,
  'chart': chartPicture,
  'grading': gradationPicture,
  'three': threeStressPicture,
  'table': waterTablePicture,
  'walk': shortWayPicture,
  'cases': casePicture,
  'memory': memoryPicture,
  'time': drainagePicture,
  'terms': mohrCoulombPicture,
  'drained': drainedPicture,
  'circle': mohrCirclePicture,
  'net': flowNetPicture,
  'quick': quickPicture,
  'dry': infiniteSlopePicture,
  'wet': seepageSlopePicture,
  'wedge': wedgePicture,
  'terzaghi': terzaghiPicture,
  'fix': footingFixPicture,
  'allowable': allowablePicture,
  'states': rankinePicture,
  'shapes': diagramShapePicture,
  'force': wallForcePicture,
  'checks': threeChecksPicture,
  'landing': middleThirdPicture,
  'pressure': basePressurePicture,
  'proctor': proctorPicture,
  'packing': relativeDensityPicture,
  'stabilizer': stabilizerPicture,
  'capacity': pileCapacityPicture,
  'deep': goingDeepPicture,
  'downdrag': downdragPicture,
};

// ---------------------------------------------------------------------------
// The painters that exist only for a sheet

TextPainter _text(
  String s, {
  double size = 10,
  Color color = AppColors.ink2,
  bool bold = false,
}) {
  return TextPainter(
    text: TextSpan(
      text: s,
      style: AppTheme.mono(
        size: size,
        color: color,
        weight: bold ? FontWeight.w700 : FontWeight.w500,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
}

Paint _paint(Color c) => Paint()..color = c;

Paint _stroke(Color color, [double width = 2]) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

/// A scale on one side and a ruler on the other, with the bridge between
/// them. The phase diagram alone cannot say which habit belongs to which
/// side, and that is the whole of this sheet.
class _ScaleAndRulerPainter extends CustomPainter {
  const _ScaleAndRulerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.width / 2;
    final top = size.height * 0.30;
    final bottom = size.height * 0.78;

    // the sample: air, water, grains
    final boxLeft = mid - 34;
    final boxRight = mid + 34;
    const parts = [
      (0.00, 0.22, 'air', AppColors.cream),
      (0.22, 0.52, 'water', AppColors.info),
      (0.52, 1.00, 'grains', AppColors.ink2),
    ];
    for (final (a, b, name, tone) in parts) {
      final r = Rect.fromLTRB(
        boxLeft,
        top + (bottom - top) * a,
        boxRight,
        top + (bottom - top) * b,
      );
      canvas
        ..drawRect(r, _paint(tone.withValues(alpha: name == 'air' ? 1 : 0.45)))
        ..drawRect(r, _stroke(AppColors.charcoal, 1.2));
      final t = _text(name, size: 8.5, color: AppColors.charcoal);
      inkLabel(
        canvas,
        t,
        Offset(mid - t.width / 2, r.center.dy - t.height / 2),
      );
    }

    // left: a ruler, because volumes are measured
    final rx = boxLeft - 16;
    canvas.drawLine(
      Offset(rx, top),
      Offset(rx, bottom),
      _stroke(AppColors.forest, 2),
    );
    for (var k = 0; k <= 6; k++) {
      final y = top + (bottom - top) * k / 6;
      canvas.drawLine(
        Offset(rx - (k.isEven ? 7 : 4), y),
        Offset(rx, y),
        _stroke(AppColors.forest, 1.4),
      );
    }
    final vol = _text('VOLUME', size: 9, color: AppColors.forest, bold: true);
    inkLabel(canvas, vol, Offset(rx - vol.width - 6, top - 24));
    final measured = _text('you MEASURE it', size: 9, color: AppColors.forest);
    inkLabel(canvas, measured, Offset(4, top - 12));

    // right: a scale pan, because weights are weighed
    final sx = boxRight + 22;
    final pan = Rect.fromLTWH(sx - 4, bottom - 18, 46, 10);
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(pan, const Radius.circular(3)),
        _paint(AppColors.ember.withValues(alpha: 0.75)),
      )
      ..drawLine(
        Offset(pan.center.dx, pan.top),
        Offset(pan.center.dx, pan.top - 22),
        _stroke(AppColors.ember, 2),
      )
      ..drawLine(
        Offset(pan.center.dx - 14, pan.top - 22),
        Offset(pan.center.dx + 14, pan.top - 22),
        _stroke(AppColors.ember, 2),
      );
    final wt = _text('WEIGHT', size: 9, color: AppColors.ember, bold: true);
    inkLabel(canvas, wt, Offset(sx, top - 24));
    final weighed = _text('you WEIGH it', size: 9, color: AppColors.ember);
    inkLabel(canvas, weighed, Offset(sx, top - 12));

    // the bridge across
    final y = size.height * 0.90;
    canvas.drawLine(
      Offset(rx, y),
      Offset(sx + 40, y),
      _stroke(AppColors.charcoal, 1.6),
    );
    for (final (x, way) in [(rx, -1.0), (sx + 40, 1.0)]) {
      final head = Path()
        ..moveTo(x, y)
        ..lineTo(x - way * 8, y - 4.5)
        ..lineTo(x - way * 8, y + 4.5)
        ..close();
      canvas.drawPath(head, _paint(AppColors.charcoal));
    }
    final bridge = _text(
      'Gs carries you across',
      size: 9.5,
      color: AppColors.charcoal,
      bold: true,
    );
    inkLabel(
      canvas,
      bridge,
      Offset(mid - bridge.width / 2, y - bridge.height - 4),
    );
  }

  @override
  bool shouldRepaint(_ScaleAndRulerPainter old) => false;
}

/// The three ways a wall gives way, drawn as three different failures rather
/// than one wall relabelled. A ghost shows where it started.
class _ThreeFailuresPainter extends CustomPainter {
  const _ThreeFailuresPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final each = size.width / 3;

    void wall(double x0, int mode, String name, String what) {
      final mid = x0 + each / 2;
      final base = size.height * 0.68;
      final w = each * 0.34;
      final h = size.height * 0.36;
      final rect = Rect.fromLTWH(mid - w / 2, base - h, w, h);

      // the ground
      canvas.drawLine(
        Offset(x0 + 8, base),
        Offset(x0 + each - 8, base),
        _stroke(AppColors.charcoal, 1.6),
      );

      // where it started
      canvas.drawRect(rect, _stroke(AppColors.ink3.withValues(alpha: 0.5), 1));

      // where it ended up
      canvas.save();
      switch (mode) {
        case 0: // tipped about the toe
          canvas.translate(rect.left, base);
          canvas.rotate(-0.30);
          canvas.translate(-rect.left, -base);
        case 1: // shoved along the base
          canvas.translate(-each * 0.13, 0);
        case 2: // sunk into the ground at the toe
          canvas.translate(0, 10);
          canvas.rotate(0.06);
      }
      canvas
        ..drawRect(rect, _paint(AppColors.charcoal.withValues(alpha: 0.8)))
        ..restore();

      // the push that did it
      final py = base - h * 0.55;
      canvas.drawLine(
        Offset(rect.right + 22, py),
        Offset(rect.right + 4, py),
        _stroke(AppColors.info, 2.4),
      );
      final head = Path()
        ..moveTo(rect.right + 3, py)
        ..lineTo(rect.right + 11, py - 4.5)
        ..lineTo(rect.right + 11, py + 4.5)
        ..close();
      canvas.drawPath(head, _paint(AppColors.info));

      // the toe, which is what it turns about
      if (mode == 0) {
        canvas.drawCircle(Offset(rect.left, base), 3, _paint(AppColors.ember));
      }
      if (mode == 2) {
        for (var k = 0; k < 3; k++) {
          canvas.drawLine(
            Offset(rect.left + 4 + k * 7, base + 4),
            Offset(rect.left + 4 + k * 7, base + 12),
            _stroke(AppColors.error, 1.8),
          );
        }
      }

      final n = _text(name, size: 10.5, color: AppColors.charcoal, bold: true);
      inkLabel(canvas, n, Offset(mid - n.width / 2, size.height * 0.06));
      final t = _text(what, size: 8.5, color: AppColors.ink3);
      inkLabel(canvas, t, Offset(mid - t.width / 2, size.height * 0.84));
    }

    wall(0, 0, 'it tips', 'moments');
    wall(each, 1, 'it slides', 'forces');
    wall(2 * each, 2, 'it sinks', 'pressures');

    for (final x in [each, 2 * each]) {
      canvas.drawLine(
        Offset(x, size.height * 0.04),
        Offset(x, size.height * 0.94),
        _stroke(AppColors.ink3.withValues(alpha: 0.35), 1),
      );
    }
  }

  @override
  bool shouldRepaint(_ThreeFailuresPainter old) => false;
}

/// What each treatment actually does to the ground, rather than a scale of
/// soil names with one soil standing on it.
class _TreatmentPainter extends CustomPainter {
  const _TreatmentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final each = size.width / 3;
    final rnd = math.Random(7);

    void panel(double x0, int mode, String name, String does) {
      final mid = x0 + each / 2;
      final box = Rect.fromCenter(
        center: Offset(mid, size.height * 0.46),
        width: each * 0.66,
        height: size.height * 0.34,
      );
      canvas
        ..drawRect(box, _paint(AppColors.creamDark))
        ..drawRect(box, _stroke(AppColors.charcoal, 1.4));

      switch (mode) {
        case 0: // lime: flaky clay drawn together into crumbs
          for (var k = 0; k < 7; k++) {
            final c = Offset(
              box.left + 10 + rnd.nextDouble() * (box.width - 20),
              box.top + 8 + rnd.nextDouble() * (box.height - 16),
            );
            canvas.drawCircle(
              c,
              5,
              _paint(AppColors.forest.withValues(alpha: 0.6)),
            );
          }
        case 1: // cement: grains with glue between them
          for (var k = 0; k < 6; k++) {
            final c = Offset(
              box.left + 12 + (k % 3) * (box.width - 24) / 2,
              box.top + 12 + (k ~/ 3) * (box.height - 24),
            );
            canvas.drawCircle(
              c,
              6,
              _paint(AppColors.ink2.withValues(alpha: 0.7)),
            );
          }
          canvas.drawRect(
            box.deflate(8),
            _stroke(AppColors.ember.withValues(alpha: 0.8), 2.4),
          );
        case 2: // drainage: water leaving through the bottom
          canvas.drawRect(
            Rect.fromLTRB(box.left, box.top, box.right, box.center.dy),
            _paint(AppColors.info.withValues(alpha: 0.35)),
          );
          for (var k = 0; k < 4; k++) {
            final x = box.left + 12 + k * (box.width - 24) / 3;
            canvas.drawLine(
              Offset(x, box.center.dy),
              Offset(x, box.bottom + 10),
              _stroke(AppColors.info, 2),
            );
            final head = Path()
              ..moveTo(x, box.bottom + 12)
              ..lineTo(x - 4, box.bottom + 4)
              ..lineTo(x + 4, box.bottom + 4)
              ..close();
            canvas.drawPath(head, _paint(AppColors.info));
          }
      }

      final n = _text(name, size: 10.5, color: AppColors.charcoal, bold: true);
      inkLabel(canvas, n, Offset(mid - n.width / 2, size.height * 0.08));
      final d = _text(does, size: 8.5, color: AppColors.ink3);
      inkLabel(canvas, d, Offset(mid - d.width / 2, size.height * 0.80));
    }

    panel(0, 0, 'lime', 'clay clumps');
    panel(each, 1, 'cement', 'grains glued');
    panel(2 * each, 2, 'drainage', 'water leaves');
  }

  @override
  bool shouldRepaint(_TreatmentPainter old) => false;
}

/// The dividing itself: the pressure the ground fails at, cut by three, with
/// what the footing actually puts down beside it.
class _DividePainter extends CustomPainter {
  const _DividePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.30;
    final room = size.width * 0.56;
    const ultimate = 9000.0;
    const allow = ultimate / 3;
    const applied = 2200.0;

    void bar(double y, double value, String name, Color tone, String note) {
      final w = room * value / ultimate;
      final r = Rect.fromLTWH(left, y, w, 26);
      canvas
        ..drawRect(r, _paint(tone.withValues(alpha: 0.5)))
        ..drawRect(r, _stroke(AppColors.charcoal, 1.4));
      final n = _text(name, size: 9.5, color: AppColors.charcoal, bold: true);
      inkLabel(canvas, n, Offset(size.width * 0.03, y + 1));
      final v = _text('${value.round()} psf', size: 9, color: tone);
      inkLabel(canvas, v, Offset(r.right + 6, y + 8));
      final t = _text(note, size: 8, color: AppColors.ink3);
      inkLabel(canvas, t, Offset(size.width * 0.03, y + 14));
    }

    bar(
      size.height * 0.12,
      ultimate,
      'fails at',
      AppColors.error,
      'from the formula',
    );
    bar(size.height * 0.44, allow, 'allowed', AppColors.forest, 'divided by 3');
    bar(
      size.height * 0.74,
      applied,
      'you put down',
      AppColors.info,
      'load over area',
    );

    // the division, drawn as the cut
    final cutX = left + room / 3;
    canvas.drawLine(
      Offset(cutX, size.height * 0.10),
      Offset(cutX, size.height * 0.44),
      _stroke(AppColors.charcoal, 1.6),
    );
    final by3 = _text(
      'divide by 3',
      size: 9,
      color: AppColors.charcoal,
      bold: true,
    );
    inkLabel(canvas, by3, Offset(cutX + 6, size.height * 0.28));

    // the comparison that matters
    final ok = _text(
      'compare these two, and only these two',
      size: 9,
      color: AppColors.charcoal,
    );
    inkLabel(
      canvas,
      ok,
      Offset(size.width * 0.03, size.height - ok.height - 4),
    );
  }

  @override
  bool shouldRepaint(_DividePainter old) => false;
}
