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

import 'package:flutter/material.dart';

import 'bearing_figures.dart';
import 'consolidation_figures.dart';
import 'effective_stress_figures.dart';
import 'mechanics_pictures.dart' show ConceptPicture, ConceptPair;
import 'phase_figures.dart';
import 'seepage_figures.dart';
import 'shear_strength_figures.dart';
import 'slope_figures.dart';
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

Widget masterPicture() => const ConceptPicture(
  painter: PhaseDiagramPainter(
    soil: _sample,
    over: Phase.water,
    under: Phase.solids,
    answered: true,
  ),
  caption:
      'water content is weighed, on the right. Void ratio is measured, on the left',
  height: 230,
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

Widget allowablePicture() => const ConceptPicture(
  painter: FootingPainter(footing: _clayFooting, answered: true),
  caption: 'the pressure this ground FAILS at. Nobody builds to that number',
  height: 240,
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
};
