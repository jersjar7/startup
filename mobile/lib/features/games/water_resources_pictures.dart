// The pictures on the Water Resources & Environmental concept sheets.
//
// A sheet is read picture first (owner's call, 2026-09-30): the drawing the
// student just played with, with one thing happening in it, then the idea in
// short steps, then the rule. Built from the same painters the games draw
// with; see mechanics_pictures.dart for the pattern and the shared
// ConceptPicture and ConceptPair tiles. The few painters that exist only here
// draw a comparison the games never needed to draw.

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'channel_figures.dart';
import 'flow_figures.dart';
import 'aquifer_figures.dart';
import 'bod_figures.dart';
import 'chlorine_figures.dart';
import 'clarifier_figures.dart';
import 'filter_figures.dart';
import 'hazen_figures.dart';
import 'hydrograph_figures.dart';
import 'pump_figures.dart';
import 'runoff_figures.dart';
import 'standards_figures.dart';
import 'mechanics_pictures.dart' show ConceptPicture, ConceptPair;
import 'weir_figures.dart';

// ---------------------------------------------------------------------------
// Open channel flow

Widget wettedPicture() => const ConceptPicture(
  painter: SectionPainter(
    channel: Channel(shape: Shaped.rectangle, width: 8, depth: 3, rim: 2),
    traced: [Edge.bed, Edge.leftWet, Edge.rightWet],
    locked: true,
    caption: 'the water is rubbing on the marked edges only',
  ),
  caption:
      'a channel cut across. the top is open to the air and the dry wall '
      'above touches nothing',
  height: 230,
);

Widget manningPicture() => const ConceptPair(
  left: SectionPainter(
    channel: Channel(shape: Shaped.rectangle, width: 4, depth: 4),
    alongside: Channel(shape: Shaped.rectangle, width: 16, depth: 1),
    showDimensions: false,
  ),
  right: SectionPainter(
    channel: Channel(shape: Shaped.rectangle, width: 16, depth: 1),
    alongside: Channel(shape: Shaped.rectangle, width: 4, depth: 4),
    showDimensions: false,
  ),
  leftCaption: 'deep and narrow: 16 of water against 12 of rubbing',
  rightCaption: 'wide and shallow: the same 16, against 18 of rubbing',
  height: 200,
);

Widget kfactorPicture() => const ConceptPicture(
  painter: _RulerPainter(),
  caption: 'one channel, two rulers. each ruler brings its own constant',
  height: 200,
);

// ---------------------------------------------------------------------------
// Specific energy

Widget froudePicture() => const Column(
  children: [
    ConceptPicture(
      painter: RipplePainter(
        flume: Flume(unitFlow: 2.4, depth: 1.6),
        answered: true,
      ),
      caption:
          'deep and slow: the ripple beats the water, so news gets back '
          'upstream',
      height: 170,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: RipplePainter(
        flume: Flume(unitFlow: 2.4, depth: 0.5),
        answered: true,
      ),
      caption:
          'shallow and fast: the water beats the ripple, so nothing gets back',
      height: 170,
    ),
  ],
);

Widget criticalPicture() => const ConceptPicture(
  painter: EnergyCurvePainter(
    flume: Flume(unitFlow: 2.0, depth: 1.2),
    showPoint: true,
    label: 'this flow',
  ),
  caption:
      'energy across, depth up. the nose is the least energy this flow can '
      'get by on',
  height: 250,
);

Widget hydraulicJumpPicture() => const ConceptPicture(
  painter: JumpPainter(
    surge: Surge(beforeDepth: 0.4, froudeBefore: 3.0),
    asked: Carried.energy,
    answered: true,
  ),
  caption:
      'fast shallow water arrives, churns, and leaves deep and slow. the '
      'churning is energy being thrown away',
  height: 230,
);

// ---------------------------------------------------------------------------
// Weirs and pipe roughness

Widget weirPicture() => const ConceptPicture(
  painter: _NotchRowPainter(),
  caption:
      'three plates seen from upstream. the hole in the plate is the whole '
      'of the question',
  height: 210,
);

Widget exponentPicture() => const Column(
  children: [
    ConceptPicture(
      painter: WeirPainter(
        weir: Weir(notch: Notch.fullWidth, head: 1),
        thenHead: 2,
        tag: 'flat crest',
      ),
      caption: 'double the head here and the flow goes up about 2.8 times',
      height: 180,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: WeirPainter(
        weir: Weir(notch: Notch.vee, head: 1),
        thenHead: 2,
        tag: 'v-notch',
      ),
      caption: 'double it here and the flow goes up about 5.7 times',
      height: 180,
    ),
  ],
);

Widget hazenPicture() => const ConceptPicture(
  painter: MainsPainter(
    top: Main(material: 'plastic', coefficient: 150),
    bottom: Main(material: 'old cast iron', coefficient: 100),
    answered: true,
  ),
  caption:
      'two mains between the same two points, alike but for the wall. the '
      'bigger C carries more water',
  height: 210,
);

// ---------------------------------------------------------------------------
// Pumps

Widget pumpPowerPicture() => const ConceptPicture(
  painter: PowerBarPainter(
    duty: Duty(
      flow: 0.05,
      head: 30,
      pumpEfficiency: 0.75,
      motorEfficiency: 0.90,
    ),
    caption: 'ONE DUTY, THREE POWERS',
  ),
  caption:
      'the same pump, measured in three places. each bar is bigger than the '
      'one it feeds',
  height: 200,
);

Widget npshPicture() => const Column(
  children: [
    ConceptPicture(
      painter: PumpSystemPainter(above: true, highlight: Piece3.lift),
      caption:
          'the pump has to lift the water up to itself: the margin shrinks',
      height: 190,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: PumpSystemPainter(above: false, highlight: Piece3.flooded),
      caption:
          'the water stands above the pump and pushes in: the margin grows',
      height: 190,
    ),
  ],
);

// ---------------------------------------------------------------------------
// Runoff

Widget rationalPicture() => const Column(
  children: [
    ConceptPicture(
      painter: CatchmentPainter(
        catchment: Catchment([
          Patch(cover: 'paving', acres: 4, coefficient: 0.9),
        ]),
        intensity: 2,
        scaleTo: 12,
      ),
      caption: 'four acres of paving sheds almost all the rain',
      height: 175,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: CatchmentPainter(
        catchment: Catchment([
          Patch(cover: 'woodland', acres: 12, coefficient: 0.3),
        ]),
        intensity: 2,
        scaleTo: 12,
      ),
      caption:
          'twelve acres of woodland drinks most of it. the same storm, and '
          'nearly the same peak',
      height: 175,
    ),
  ],
);

Widget catchmentBlendPicture() => const ConceptPicture(
  painter: CatchmentPainter(
    catchment: Catchment([
      Patch(cover: 'roofs and roads', acres: 3, coefficient: 0.9),
      Patch(cover: 'grass', acres: 9, coefficient: 0.2),
    ]),
    showWeighted: true,
    tag: 'ONE INLET, TWO COVERS',
  ),
  caption:
      'drawn to scale. there is three times as much grass, so the blend '
      'lands near the grass',
  height: 230,
);

Widget curveNumberPicture() => const ConceptPicture(
  painter: SoakPainter(soak: Soak(curveNumber: 75, rain: 4), answered: true),
  caption:
      'the storm as a column. the ground takes the bottom slice first, and '
      'what is left runs off',
  height: 240,
);

// ---------------------------------------------------------------------------
// Hydrographs

Widget unitHydrographPicture() => const ConceptPicture(
  painter: HydrographPainter(
    waves: [
      Wave(peak: 200, toPeak: 3, base: 9),
      Wave(peak: 600, toPeak: 3, base: 9),
    ],
    names: ['one inch of rain', 'three inches, same duration'],
    note: 'three times as tall, same hour',
  ),
  caption:
      'the watershed always answers at its own speed. a deeper storm only '
      'scales the height',
  height: 230,
);

Widget concentrationPicture() => const ConceptPair(
  left: BasinPainter(basin: Basin(travelTime: 30, stormMinutes: 15)),
  right: BasinPainter(basin: Basin(travelTime: 30, stormMinutes: 30)),
  leftCaption: 'a short storm: it is over before the far ground reports in',
  rightCaption: 'a storm as long as the travel time: the whole basin counts',
  height: 230,
);

Widget routingPicture() => const ConceptPicture(
  painter: PondPainter(pond: Pond(inflow: 9, outflow: 3), answered: true),
  caption:
      'more arriving than leaving, so the pond is filling and the town '
      'downstream never sees the peak',
  height: 230,
);

// ---------------------------------------------------------------------------
// Groundwater

Widget seepagePicture() => const ConceptPicture(
  painter: SoilPainter(
    seep: Seep(conductivity: 1e-4, gradient: 0.02, porosity: 0.3, area: 10),
    answered: true,
  ),
  caption:
      'the grains are in the way, so water has to hurry through the gaps '
      'left between them',
  height: 240,
);

Widget wellsPicture() => const Column(
  children: [
    ConceptPicture(
      painter: AquiferPainter(
        aquifer: Aquifer(
          kind: Ground.unconfined,
          conductivity: 5e-4,
          headAtWell: 40,
          radiusAtWell: 0.5,
          headOut: 60,
          radiusOut: 200,
        ),
      ),
      caption:
          'no lid: the water table itself is drawn down, so the aquifer thins',
      height: 190,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: AquiferPainter(
        aquifer: Aquifer(
          kind: Ground.confined,
          conductivity: 3e-5,
          headAtWell: 25,
          radiusAtWell: 10,
          headOut: 30,
          radiusOut: 100,
        ),
      ),
      caption: 'a clay lid: the aquifer keeps its thickness whatever you do',
      height: 190,
    ),
  ],
);

// ---------------------------------------------------------------------------
// Oxygen demand

Widget bodPicture() => const ConceptPicture(
  painter: BodPainter(demand: Demand(ultimate: 300, rate: 0.23), day: 5),
  caption:
      'the oxygen bacteria take, day by day. the test stops at day five, '
      'part way up',
  height: 230,
);

Widget temperaturePicture() => const ConceptPicture(
  painter: BodPainter(
    demand: Demand(ultimate: 300, rate: 0.23),
    day: 5,
    warmer: Demand(ultimate: 300, rate: 0.40),
    showSplit: false,
  ),
  caption:
      'the same muck, warm and cold. temperature changes the hurry, never '
      'the total',
  height: 230,
);

// ---------------------------------------------------------------------------
// Settling and activated sludge

Widget overflowPicture() => const Column(
  children: [
    ConceptPicture(
      painter: ClarifierPainter(
        clarifier: Clarifier(flowGpd: 2000000, diameter: 60, depth: 12),
        settlingFeetPerHour: 6,
        answered: true,
      ),
      caption:
          'a grain that falls faster than the water rises reaches the floor',
      height: 175,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: ClarifierPainter(
        clarifier: Clarifier(flowGpd: 2000000, diameter: 60, depth: 12),
        settlingFeetPerHour: 1,
        answered: true,
      ),
      caption:
          'a lighter one falls slower than that, so it is carried out over the weir',
      height: 175,
    ),
  ],
);

Widget residencePicture() => const Column(
  children: [
    ConceptPicture(
      painter: PlantPainter(
        highlight: Loop2.water,
        note: 'the water crosses once, in hours',
      ),
      caption: 'the water goes in one end and out the other and is gone',
      height: 185,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: PlantPainter(
        highlight: Loop2.solids,
        note: 'the solids go round and round, for days',
      ),
      caption: 'the solids settle out and are pumped back to go round again',
      height: 185,
    ),
  ],
);

Widget foodRatioPicture() => const ConceptPicture(
  painter: PlantPainter(
    note: 'food arriving each day, over the bugs held to eat it',
  ),
  caption:
      'the load comes in with the water; the biology waiting for it sits in '
      'the basin',
  height: 220,
);

// ---------------------------------------------------------------------------
// Chlorine and filters

Widget dosePicture() => const ConceptPicture(
  painter: DosePainter(
    chlorine: Chlorine(demand: 2.4, residual: 0.6),
    note: 'the pump is set to the whole bar, not to either piece',
  ),
  caption:
      'the water eats the first part. what is left over is what reaches the '
      'customer',
  height: 220,
);

Widget contactPicture() => const ConceptPicture(
  painter: ContactPainter(
    contact: Contact(residual: 1.2, theoretical: 60, baffled: 0.35),
    answered: true,
  ),
  caption:
      'some water short circuits straight to the outlet. the credit is set '
      'by that hurried tenth',
  height: 230,
);

Widget filterRatePicture() => const ConceptPicture(
  painter: FilterPainter(
    bed: FilterBed(length: 20, width: 15, flowGpm: 1350),
    answered: true,
  ),
  caption:
      'the water goes straight down, so what matters is the bed seen from '
      'above',
  height: 230,
);

// ---------------------------------------------------------------------------
// Standards

Widget tiersPicture() => const ConceptPair(
  left: TierPainter(label: 'arsenic 0.010 mg/L', settled: Tier.primary),
  right: TierPainter(label: 'iron 0.3 mg/L', settled: Tier.secondary),
  leftCaption: 'a health limit: breaking it is a violation',
  rightCaption: 'a taste and staining limit: breaking it brings complaints',
  height: 200,
);

Widget hardnessPicture() => const ConceptPicture(
  painter: HardnessPainter(
    ions: [
      Ion(name: 'calcium', concentration: 80, equivalentWeight: 20),
      Ion(name: 'magnesium', concentration: 30, equivalentWeight: 12.15),
    ],
    converted: true,
  ),
  caption:
      'two ions put onto one basis. the lighter one counts for more, '
      'milligram for milligram',
  height: 230,
);

Widget efficiencyPicture() => const ConceptPicture(
  painter: RemovalPainter(
    removal: Removal(influent: 200, limit: 25),
    answered: true,
  ),
  caption:
      'what went in, and what came out. the removal is the gap as a share '
      'of what went in',
  height: 220,
);

// ---------------------------------------------------------------------------
// The painters that exist only for a sheet

TextPainter _text(
  String s, {
  double size = 11,
  Color color = AppColors.ink2,
  FontWeight weight = FontWeight.w500,
}) {
  return TextPainter(
    text: TextSpan(
      text: s,
      style: AppTheme.mono(size: size, color: color, weight: weight),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
}

Paint _stroke(Color color, [double width = 2.5]) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

/// One channel measured twice: in feet, and in meters. The constant in front
/// of Manning's equation is nothing but which ruler was used.
class _RulerPainter extends CustomPainter {
  const _RulerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.18;
    final right = size.width * 0.82;
    final top = size.height * 0.30;
    final bed = size.height * 0.62;

    // the channel: two walls and a bed, with water in it
    final water = Rect.fromLTRB(left, top + 10, right, bed);
    canvas.drawRect(
      water,
      Paint()..color = AppColors.info.withValues(alpha: 0.28),
    );
    final wall = _stroke(AppColors.charcoal, 3);
    canvas.drawLine(Offset(left, top), Offset(left, bed), wall);
    canvas.drawLine(Offset(right, top), Offset(right, bed), wall);
    canvas.drawLine(Offset(left, bed), Offset(right, bed), wall);

    // the same width, written two ways
    final tick = _stroke(AppColors.ink2, 1.5);
    for (final (y, label, tone) in [
      (bed + 20, '10 ft', AppColors.ember),
      (bed + 48, '3.05 m', AppColors.forest),
    ]) {
      canvas.drawLine(Offset(left, y - 5), Offset(left, y + 5), tick);
      canvas.drawLine(Offset(right, y - 5), Offset(right, y + 5), tick);
      canvas.drawLine(Offset(left, y), Offset(right, y), tick);
      final t = _text(label, size: 12, color: tone, weight: FontWeight.w700);
      t.paint(
        canvas,
        Offset((left + right) / 2 - t.width / 2, y - t.height - 4),
      );
    }

    // what each ruler costs you in front of the equation
    for (final (x, label, tone) in [
      (size.width * 0.26, 'K = 1.486', AppColors.ember),
      (size.width * 0.74, 'K = 1.0', AppColors.forest),
    ]) {
      final t = _text(label, size: 12, color: tone, weight: FontWeight.w700);
      t.paint(canvas, Offset(x - t.width / 2, size.height * 0.10));
    }
    final note = _text('the ruler picks the constant', size: 10.5);
    note.paint(
      canvas,
      Offset(size.width / 2 - note.width / 2, size.height * 0.18),
    );
  }

  @override
  bool shouldRepaint(_RulerPainter old) => false;
}

/// The three weir openings side by side, seen from upstream, so the only
/// thing that differs is the hole the water pours through.
class _NotchRowPainter extends CustomPainter {
  const _NotchRowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const notches = [Notch.fullWidth, Notch.contracted, Notch.vee];
    const names = ['wall to wall', 'stops short', 'a v-notch'];
    const powers = ['H to the 3/2', 'H to the 3/2', 'H to the 5/2'];
    final each = size.width / 3;
    for (var i = 0; i < 3; i++) {
      canvas.save();
      canvas.translate(i * each, 0);
      _plate(canvas, Size(each, size.height * 0.62), notches[i]);
      final n = _text(
        names[i],
        size: 11,
        color: AppColors.charcoal,
        weight: FontWeight.w700,
      );
      n.paint(canvas, Offset(each / 2 - n.width / 2, size.height * 0.68));
      final p = _text(powers[i], size: 10.5, color: AppColors.ember);
      p.paint(canvas, Offset(each / 2 - p.width / 2, size.height * 0.80));
      canvas.restore();
    }
  }

  void _plate(Canvas canvas, Size box, Notch notch) {
    final left = box.width * 0.14;
    final right = box.width * 0.86;
    final top = box.height * 0.22;
    final crest = box.height * 0.74;
    final mid = (left + right) / 2;

    // the channel walls
    final wall = _stroke(AppColors.charcoal, 3);
    canvas.drawLine(Offset(left, top - 6), Offset(left, crest + 8), wall);
    canvas.drawLine(Offset(right, top - 6), Offset(right, crest + 8), wall);

    // the plate, with the opening cut out of it
    final plate = Paint()..color = AppColors.charcoal;
    final opening = switch (notch) {
      Notch.fullWidth => Rect.fromLTRB(left, top, right, crest),
      Notch.contracted => Rect.fromLTRB(
        left + (right - left) * 0.22,
        top,
        right - (right - left) * 0.22,
        crest,
      ),
      Notch.vee => Rect.fromLTRB(left, top, right, crest),
    };
    final face = Path()..addRect(Rect.fromLTRB(left, top, right, crest + 8));
    final hole = Path();
    if (notch == Notch.vee) {
      hole
        ..moveTo(mid - (right - left) * 0.30, top)
        ..lineTo(mid, crest)
        ..lineTo(mid + (right - left) * 0.30, top)
        ..close();
    } else {
      hole.addRect(opening);
    }
    canvas.drawPath(Path.combine(PathOperation.difference, face, hole), plate);

    // the water standing above the crest
    final level = top + (crest - top) * 0.34;
    canvas.drawLine(
      Offset(left, level),
      Offset(right, level),
      _stroke(AppColors.info, 2.5),
    );
  }

  @override
  bool shouldRepaint(_NotchRowPainter old) => false;
}

/// Every picture on this chapter's sheets, by the contact sheet's card name.
const waterresourcesPictures = <String, Widget Function()>{
  'wetted': wettedPicture,
  'manning': manningPicture,
  'kfactor': kfactorPicture,
  'froude': froudePicture,
  'critical': criticalPicture,
  'jump': hydraulicJumpPicture,
  'weir': weirPicture,
  'exponent': exponentPicture,
  'hazen': hazenPicture,
  'power': pumpPowerPicture,
  'npsh': npshPicture,
  'rational': rationalPicture,
  'blend': catchmentBlendPicture,
  'curvenumber': curveNumberPicture,
  'unit': unitHydrographPicture,
  'concentration': concentrationPicture,
  'routing': routingPicture,
  'seepage': seepagePicture,
  'wells': wellsPicture,
  'bod': bodPicture,
  'temperature': temperaturePicture,
  'overflow': overflowPicture,
  'residence': residencePicture,
  'foodratio': foodRatioPicture,
  'dose': dosePicture,
  'contact': contactPicture,
  'filter': filterRatePicture,
  'tiers': tiersPicture,
  'hardness': hardnessPicture,
  'efficiency': efficiencyPicture,
};
