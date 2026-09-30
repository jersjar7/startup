// The pictures on the Statics concept sheets.
//
// A sheet is read picture first (owner's call, 2026-09-30): the drawing the
// student just played with, with one thing happening in it, then the idea in
// short steps, then the rule. Built from the same painters the games draw
// with; see mechanics_pictures.dart for the pattern and the shared
// ConceptPicture and ConceptPair tiles.

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'beam_figures.dart';
import 'frame_figures.dart';
import 'friction_figures.dart';
import 'mechanics_pictures.dart' show ConceptPicture, ConceptPair;
import 'section_figures.dart';
import 'stress_figures.dart' show iSection;
import 'statics_figures.dart';
import 'truss_figures.dart';

// ---------------------------------------------------------------------------
// Force systems

Widget resolvePicture() => const ConceptPicture(
  painter: ForceTrianglePainter(
    dx: 8,
    dy: 6,
    angleFrom: AngleFrom.horizontal,
    angleLabel: '37',
    xLabel: 'F cos 37',
    yLabel: 'F sin 37',
    selected: null,
    locked: true,
    truth: 0,
  ),
  caption:
      'one pull, drawn as the long side of a right triangle. the two short '
      'sides are what it does sideways and upward',
  height: 210,
);

const _crane = Scene(
  members: [
    [Offset(0, 0), Offset(7.66, 6.43)],
  ],
  pivot: Offset(0, 0),
  forces: [StaticForce(Offset(7.66, 6.43), Offset(0, -1), '5,000 N')],
  marks: [
    Mark(Offset(0, 0), Offset(7.66, 6.43), '10 m'),
    Mark(Offset(0, 0), Offset(7.66, 0), '7.66 m'),
    Mark(Offset(0, 0), Offset(0, 6.43), '6.43 m'),
  ],
);

Widget momentPicture() => const ConceptPicture(
  painter: MomentPainter(
    scene: _crane,
    mode: SceneMode.marks,
    selected: null,
    chosen: {},
    locked: true,
    truth: 1,
    truths: {},
  ),
  caption:
      'a load hanging off a boom. three real distances are drawn. only the '
      'green one is the arm',
  height: 220,
);

const _seesaw = Scene(
  members: [
    [Offset(-4, 0), Offset(4, 0)],
  ],
  pivot: Offset(0, 0),
  forces: [
    StaticForce(Offset(-3, 0), Offset(0, -1), 'A', lineOfAction: false),
    StaticForce(Offset(3, 0), Offset(0, -1), 'B', lineOfAction: false),
  ],
);

Widget sensePicture() => const ConceptPicture(
  painter: MomentPainter(
    scene: _seesaw,
    mode: SceneMode.forces,
    selected: null,
    chosen: {},
    locked: true,
    truth: -1,
    truths: {1},
  ),
  caption:
      'two pushes, both downward, one each side of the pin. they turn the bar '
      'opposite ways',
  height: 200,
);

// ---------------------------------------------------------------------------
// Equilibrium

Widget supportsPicture() => Column(
  children: [
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: ConceptPicture(
            painter: ReactionGlyphPainter(
              vertical: true,
              horizontal: false,
              moment: false,
              colour: AppColors.ember,
            ),
            caption: 'roller: one arrow',
            height: 140,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: ConceptPicture(
            painter: ReactionGlyphPainter(
              vertical: true,
              horizontal: true,
              moment: false,
              colour: AppColors.ember,
            ),
            caption: 'pin: two arrows',
            height: 140,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: ConceptPicture(
            painter: ReactionGlyphPainter(
              vertical: true,
              horizontal: true,
              moment: true,
              colour: AppColors.ember,
            ),
            caption: 'fixed: two and a turn',
            height: 140,
          ),
        ),
      ],
    ),
  ],
);

Widget resultantPicture() => const ConceptPair(
  left: BeamPainter(
    span: 6,
    supports: [
      Support(Offset.zero, Prop.pin),
      Support(Offset(6, 0), Prop.roller),
    ],
    spreads: [Spread(0, 6, 4, 4, label: 'even')],
    markResultant: true,
  ),
  right: BeamPainter(
    span: 6,
    supports: [
      Support(Offset.zero, Prop.pin),
      Support(Offset(6, 0), Prop.roller),
    ],
    spreads: [Spread(0, 6, 0, 8, label: 'heavier to the right')],
    markResultant: true,
  ),
  leftCaption: 'an even load acts at the middle of what it covers',
  rightCaption: 'a triangle acts a third of the way in from the heavy end',
  height: 180,
);

Widget determinacyPicture() => const ConceptPair(
  left: BeamPainter(
    span: 6,
    supports: [
      Support(Offset.zero, Prop.pin),
      Support(Offset(6, 0), Prop.roller),
    ],
    loads: [(3, '')],
  ),
  right: BeamPainter(
    span: 6,
    supports: [
      Support(Offset.zero, Prop.pin),
      Support(Offset(3, 0), Prop.roller),
      Support(Offset(6, 0), Prop.roller),
    ],
    loads: [(1.5, '')],
  ),
  leftCaption:
      'pin and roller: 2 plus 1 is three unknowns, and three '
      'equations find them',
  rightCaption: 'add a prop: four unknowns, and statics runs out of equations',
  height: 170,
);

// ---------------------------------------------------------------------------
// Trusses

const _idleTruss = Truss(
  joints: [
    Joint('A', Offset(0, 0)),
    Joint('C', Offset(3, 0)),
    Joint('E', Offset(6, 0)),
    Joint('D', Offset(3, 2)),
  ],
  members: [(0, 1), (1, 2), (1, 3), (0, 3), (3, 2)],
  supports: {0: Prop.pin, 2: Prop.roller},
  loads: {3: '12 kN'},
);

Widget zeroForcePicture() => const ConceptPicture(
  painter: TrussPainter(
    truss: _idleTruss,
    mode: TrussMode.members,
    chosen: {},
    truths: {2},
    locked: true,
  ),
  caption:
      'nothing hangs at the bottom middle joint, and the two bars there run in '
      'one straight line. the upright carries nothing',
  height: 210,
);

const _loadedTruss = Truss(
  joints: [
    Joint('A', Offset(0, 0)),
    Joint('B', Offset(3, 0)),
    Joint('C', Offset(6, 0)),
    Joint('D', Offset(1.5, 2)),
    Joint('E', Offset(4.5, 2)),
  ],
  members: [(0, 1), (1, 2), (0, 3), (3, 4), (4, 2), (1, 3), (1, 4)],
  supports: {0: Prop.pin, 2: Prop.roller},
  loads: {1: '20 kN'},
);

Widget senseOfForcePicture() => const ConceptPicture(
  painter: TrussPainter(
    truss: _loadedTruss,
    mode: TrussMode.members,
    chosen: {},
    truths: {0, 1},
    locked: true,
  ),
  caption:
      'push down in the middle. the truss sags, so the bottom bars are pulled '
      'longer and the top ones are squeezed',
  height: 210,
);

Widget sectionPicture() => const ConceptPicture(
  painter: TrussPainter(
    truss: _loadedTruss,
    mode: TrussMode.cuts,
    cuts: [
      Cut('cut 1', Offset(2.2, -0.45), Offset(2.2, 2.45)),
      Cut('cut 2', Offset(3.8, -0.45), Offset(3.8, 2.45)),
    ],
    selected: null,
    truth: 1,
    locked: true,
  ),
  caption:
      'slice right through, throw one half away. a cut that crosses three bars '
      'can be solved; one that crosses more cannot',
  height: 210,
);

// ---------------------------------------------------------------------------
// Friction

Widget ceilingPicture() => const ConceptPair(
  left: BlockPainter(
    rig: Rig(weight: 500, mu: 0.4),
    showPush: true,
    pushLabel: 'a small shove',
    grip: Grip.matching,
  ),
  right: BlockPainter(
    rig: Rig(weight: 500, mu: 0.4),
    showPush: true,
    pushLabel: 'a hard shove',
    grip: Grip.atTheLimit,
  ),
  leftCaption: 'push gently: friction pushes back exactly as hard, no more',
  rightCaption:
      'push at the limit: friction is maxed out and the box is about '
      'to go',
  height: 190,
);

Widget beltPicture() => const ConceptPicture(
  painter: DrumPainter(
    lap: Lap(
      startDeg: 180,
      sweepDeg: 180,
      creep: Creep.counter,
      startLabel: 'you hold this end',
      endLabel: 'the load pulls here',
    ),
    locked: true,
  ),
  caption:
      'a rope over a post. friction adds to the pull the whole way round, so '
      'one end holds far more than the other',
  height: 210,
);

Widget normalForcePicture() => const ConceptPair(
  left: BlockPainter(rig: Rig(weight: 500, mu: 0.4)),
  right: BlockPainter(rig: Rig(weight: 500, mu: 0.4, rampDeg: 30)),
  leftCaption: 'on the flat: the floor carries the whole weight',
  rightCaption: 'on a slope: the surface only feels part of it',
  height: 190,
);

Widget screwPicture() => const ConceptPair(
  left: ScrewPainter(
    screw: Screw(pitchDeg: 4, mu: 0.2, raising: false),
    showWinner: true,
  ),
  right: ScrewPainter(
    screw: Screw(pitchDeg: 16, mu: 0.1, raising: false),
    showWinner: true,
  ),
  leftCaption: 'a shallow thread on a rough surface: it stays put by itself',
  rightCaption: 'a steep thread on a slippery one: it runs back down',
  height: 200,
);

// ---------------------------------------------------------------------------
// Frames and machines

const _bracket = Assembly(
  pins: [
    Pin('A', Offset(0, 0)),
    Pin('B', Offset(0, 2.6)),
    Pin('M', Offset(1.9, 2.6)),
    Pin('C', Offset(3.3, 2.6)),
  ],
  limbs: [
    Limb(from: 1, to: 3, via: [2]),
    Limb(from: 0, to: 2),
  ],
  supports: {0: Prop.pin, 1: Prop.pin},
  pinLoads: {3: '5 kN'},
);

Widget twoForcePicture() => const ConceptPicture(
  painter: FramePainter(
    rig: _bracket,
    spotlight: 1,
    atPin: 2,
    aims: [Aim.alongTheLine, Aim.square],
    picked: null,
    truth: 0,
    locked: true,
  ),
  caption:
      'the strut is touched in exactly two places, so its push runs straight '
      'down the line joining them',
  height: 210,
);

Widget leverPicture() => const ConceptPair(
  left: LeverPainter(lever: Lever(pivotAt: 0.2, effortAt: 1, loadAt: 0.35)),
  right: LeverPainter(lever: Lever(pivotAt: 0.8, effortAt: 0, loadAt: 0.65)),
  leftCaption: 'your end is far from the pivot: a small push lifts a lot',
  rightCaption:
      'your end is close: you push harder, and the load moves '
      'further and faster',
  height: 180,
);

const _roof = Assembly(
  pins: [
    Pin('A', Offset(0, 0)),
    Pin('B', Offset(2, 0)),
    Pin('C', Offset(4, 0)),
    Pin('D', Offset(2, 1.6)),
  ],
  limbs: [
    Limb(from: 0, to: 1),
    Limb(from: 1, to: 2),
    Limb(from: 0, to: 3),
    Limb(from: 2, to: 3),
    Limb(from: 1, to: 3),
  ],
  supports: {0: Prop.pin, 2: Prop.roller},
  pinLoads: {3: '10 kN'},
);

Widget whatItIsPicture() => const ConceptPair(
  left: FramePainter(rig: _roof, locked: true),
  right: FramePainter(rig: _bracket, spotlight: 0, locked: true),
  leftCaption: 'every bar touched at just its two ends: a truss',
  rightCaption:
      'the marked arm is touched in three places, so it bends: a '
      'frame',
  height: 200,
);

// ---------------------------------------------------------------------------
// Centroids

final Profile _tee = Profile([
  const Piece(Slab.box, Offset(0, 4), Size(6, 1.4)),
  const Piece(Slab.box, Offset(2.3, 0), Size(1.4, 4)),
]);

Widget areaWeightedPicture() => ConceptPicture(
  painter: ProfilePainter(
    profile: _tee,
    showMiddle: true,
    markCentroid: true,
    locked: true,
  ),
  caption:
      'a tee. most of the material is up in the flange, so the balance point '
      'sits above the halfway line',
  height: 210,
);

Widget tablePicture() => ConceptPair(
  left: ProfilePainter(
    profile: Profile([const Piece(Slab.rightTri, Offset.zero, Size(6, 4))]),
    showMiddle: true,
    markCentroid: true,
    locked: true,
  ),
  right: ProfilePainter(
    profile: Profile([const Piece(Slab.halfDisc, Offset.zero, Size(6, 3))]),
    showMiddle: true,
    markCentroid: true,
    locked: true,
  ),
  leftCaption: 'a triangle balances a third of the way up from its base',
  rightCaption:
      'a half circle balances a little over four tenths of the '
      'radius up',
  height: 190,
);

Widget referencePicture() => ConceptPicture(
  painter: ProfilePainter(
    profile: _tee,
    markCentroid: true,
    drops: const [Drop(0, 2, 'to the web'), Drop(0, 4.7, 'to the flange')],
    locked: true,
  ),
  caption:
      'one line at the bottom, and every piece measured from it to its own '
      'middle',
  height: 210,
);

// ---------------------------------------------------------------------------
// Moment of inertia

final Profile _onEdge = Profile([
  const Piece(Slab.box, Offset.zero, Size(2, 6)),
]);
final Profile _flat = Profile([const Piece(Slab.box, Offset.zero, Size(6, 2))]);

Widget farFromAxisPicture() => ConceptPicture(
  painter: LineUpPainter(
    shapes: [_onEdge, _flat],
    truth: const [0, 1],
    locked: true,
  ),
  caption:
      'the same plank both ways up. standing tall, its material sits far from '
      'the middle, and that is what stiffness counts',
  height: 200,
);

Widget transferPicture() => ConceptPicture(
  painter: ProfilePainter(
    profile: _flat,
    markCentroid: true,
    axes: const [Datum(1, 'its own middle'), Datum(0, 'the base')],
    drops: const [Drop(0, 1, 'd')],
    locked: true,
  ),
  caption:
      'a shape is least stiff about its own middle. move to any other line and '
      'you add area times d squared',
  height: 210,
);

final Profile _iBeam = iSection(
  depth: 8,
  flangeWidth: 6,
  flangeThickness: 1,
  webThickness: 0.8,
);

Widget compositeIPicture() => ConceptPicture(
  painter: ProfilePainter(
    profile: _iBeam,
    markCentroid: true,
    spotlight: 0,
    locked: true,
  ),
  caption:
      'an I beam: fat flanges far out, a thin web in the middle. the flanges '
      'do nearly all the work',
  height: 210,
);

Widget polarPicture() => ConceptPair(
  left: JobPainter(
    profile: _iBeam,
    job: const Job(load: Offset(0, -1)),
    showAxis: true,
  ),
  right: JobPainter(
    profile: _iBeam,
    job: const Job(load: Offset.zero, twists: true),
    showAxis: true,
  ),
  leftCaption: 'pushed down: it bends about the flat axis, so use that I',
  rightCaption: 'twisted about its own length: use J, the two I values added',
  height: 200,
);

// ---------------------------------------------------------------------------

/// Every picture on this chapter's sheets, by the contact sheet's card name.
const staticsPictures = <String, Widget Function()>{
  'resolve': resolvePicture,
  'moment': momentPicture,
  'sense': sensePicture,
  'supports': supportsPicture,
  'resultant': resultantPicture,
  'determinacy': determinacyPicture,
  'zero-force': zeroForcePicture,
  'sense-of-force': senseOfForcePicture,
  'section': sectionPicture,
  'ceiling': ceilingPicture,
  'belt': beltPicture,
  'normal-force': normalForcePicture,
  'screw': screwPicture,
  'two-force': twoForcePicture,
  'lever': leverPicture,
  'what-it-is': whatItIsPicture,
  'area-weighted': areaWeightedPicture,
  'table': tablePicture,
  'reference': referencePicture,
  'far-from-axis': farFromAxisPicture,
  'transfer': transferPicture,
  'composite-i': compositeIPicture,
  'polar': polarPicture,
};
