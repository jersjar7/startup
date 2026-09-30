// The pictures on the Statics concept sheets.
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
  painter: _SledPainter(),
  caption:
      'a rope slanting up off a sled. the two short sides of the triangle are '
      'the two jobs the pull is doing at once',
  height: 215,
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

Widget sensePicture() => const ConceptPicture(
  painter: _TurnPairPainter(),
  caption:
      'the same downward push, one each side of the pin. the curved arrows are '
      'the turns, and they go opposite ways',
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
      sweepDeg: 900,
      creep: Creep.counter,
      startLabel: 'you hold this end',
      endLabel: 'the load pulls here',
    ),
    locked: true,
  ),
  caption:
      'two and a half turns round a post. friction grips a little more at '
      'every point of the wrap, and it all multiplies up',
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
    axes: const [Datum(0, 'the line you chose')],
    spots: const [Offset(3, 2), Offset(3, 4.7)],
    markCentroid: true,
  ),
  caption:
      'one line at the bottom. 1 and 2 are the two pieces, each measured from '
      'that line to its own middle',
  height: 210,
);

// ---------------------------------------------------------------------------
// Moment of inertia

final Profile _onEdge = Profile([
  const Piece(Slab.box, Offset.zero, Size(2, 6)),
]);
final Profile _flat = Profile([const Piece(Slab.box, Offset.zero, Size(6, 2))]);

Widget farFromAxisPicture() => ConceptPicture(
  painter: LineUpPainter(shapes: [_onEdge, _flat]),
  caption:
      'the same plank both ways up, drawn to one scale. standing tall, its '
      'material sits far from the middle, and that is what counts',
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
    // Both flanges, marked where they sit against the balance line.
    // Spotlighting one of them made the picture look like it was about that
    // one flange, when the point is that the pair of them, the same distance
    // out on either side, carry the section between them.
    axes: const [
      Datum(7.5, 'top flange, far out'),
      Datum(0.5, 'bottom flange, just as far'),
    ],
    locked: true,
  ),
  caption:
      'both flanges sit the same distance out from the balance line in the '
      'middle. that distance is squared, so the pair of them carry the '
      'section and the thin web adds almost nothing',
  height: 215,
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

// ---------------------------------------------------------------------------
// The two painters that exist only for a sheet

TextPainter _say(
  String s, {
  double size = 11,
  Color color = AppColors.ink2,
  FontWeight weight = FontWeight.w500,
}) => TextPainter(
  text: TextSpan(
    text: s,
    style: AppTheme.mono(size: size, color: color, weight: weight),
  ),
  textDirection: TextDirection.ltr,
)..layout();

void _write(
  Canvas canvas,
  String s,
  Offset at, {
  double size = 11,
  Color color = AppColors.ink2,
  bool center = false,
  FontWeight weight = FontWeight.w500,
}) {
  final tp = _say(s, size: size, color: color, weight: weight);
  tp.paint(
    canvas,
    center ? Offset(at.dx - tp.width / 2, at.dy - tp.height / 2) : at,
  );
}

Paint _pen(Color color, [double width = 2.4]) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

void _head(Canvas canvas, Offset at, Offset dir, Color color, [double s = 8]) {
  final len = dir.distance;
  if (len < 0.001) return;
  final u = dir / len;
  final n = Offset(-u.dy, u.dx);
  canvas.drawPath(
    Path()
      ..moveTo(at.dx, at.dy)
      ..lineTo(
        at.dx - u.dx * s + n.dx * s * 0.55,
        at.dy - u.dy * s + n.dy * s * 0.55,
      )
      ..lineTo(
        at.dx - u.dx * s - n.dx * s * 0.55,
        at.dy - u.dy * s - n.dy * s * 0.55,
      )
      ..close(),
    Paint()..color = color,
  );
}

void _shaft(
  Canvas canvas,
  Offset from,
  Offset to,
  Color color, [
  double w = 2.4,
]) {
  canvas.drawLine(from, to, _pen(color, w));
  _head(canvas, to, to - from, color);
}

/// A sled with a rope slanting up off it, and the right triangle that rope
/// makes.
///
/// The sheet opens by asking the reader to picture dragging a sled, and the
/// old drawing was a bare triangle with no sled anywhere in it. Drawing the
/// thing being pulled, with the triangle laid over it, means the everyday
/// image and the geometry are one picture rather than two.
class _SledPainter extends CustomPainter {
  const _SledPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final ground = size.height * 0.72;
    final corner = Offset(size.width * 0.27, ground);
    // 37 degrees: 3 up for every 4 along, the shape the sheet works in.
    const run = 128.0;
    const rise = 96.0;
    final tip = Offset(corner.dx + run, corner.dy - rise);

    canvas.drawLine(
      Offset(10, ground),
      Offset(size.width - 10, ground),
      _pen(AppColors.ink3.withValues(alpha: 0.5), 1.4),
    );

    // the thing being pulled
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(corner.dx - 72, ground - 26, corner.dx, ground),
        const Radius.circular(5),
      ),
      Paint()..color = AppColors.charcoal,
    );
    _write(
      canvas,
      'the sled',
      Offset(corner.dx - 36, ground - 13),
      size: 10,
      color: AppColors.cream,
      center: true,
    );

    // the two jobs, as the two short sides
    canvas.drawLine(
      corner,
      Offset(tip.dx, corner.dy),
      _pen(AppColors.forest, 3),
    );
    canvas.drawLine(Offset(tip.dx, corner.dy), tip, _pen(AppColors.info, 3));

    // the rope, and the pull running along it
    _shaft(canvas, corner, tip, AppColors.ember, 3.2);

    // the angle, opening from the flat
    canvas.drawArc(
      Rect.fromCircle(center: corner, radius: 36),
      -0.6435,
      0.6435,
      false,
      _pen(AppColors.charcoal, 1.6),
    );
    _write(
      canvas,
      '37',
      Offset(corner.dx + 44, corner.dy - 15),
      color: AppColors.charcoal,
      weight: FontWeight.w700,
    );

    _write(
      canvas,
      'the pull',
      Offset(tip.dx + 8, tip.dy - 5),
      size: 11.5,
      color: AppColors.ember,
      weight: FontWeight.w700,
    );
    _write(
      canvas,
      'drags it forward',
      Offset((corner.dx + tip.dx) / 2, ground + 15),
      size: 10.5,
      color: AppColors.forest,
      center: true,
      weight: FontWeight.w700,
    );
    _write(
      canvas,
      'and lifts',
      Offset(tip.dx + 8, (corner.dy + tip.dy) / 2 - 8),
      size: 10.5,
      color: AppColors.info,
      weight: FontWeight.w700,
    );
    _write(
      canvas,
      'a little',
      Offset(tip.dx + 8, (corner.dy + tip.dy) / 2 + 6),
      size: 10.5,
      color: AppColors.info,
      weight: FontWeight.w700,
    );
  }

  @override
  bool shouldRepaint(_SledPainter old) => false;
}

/// The same push, either side of the pin, with the turn it causes drawn.
///
/// The old picture showed two downward arrows and left the reader to take the
/// caption's word that they turn the bar opposite ways. The turn is the whole
/// subject of the sheet, so it is now the thing that is drawn: a curved arrow
/// round the pin, one way in the left scene and the other way in the right.
class _TurnPairPainter extends CustomPainter {
  const _TurnPairPainter();

  void _scene(Canvas canvas, Rect area, bool pushLeft) {
    final pin = Offset(area.center.dx, area.top + 66);
    const half = 54.0;
    final barL = Offset(pin.dx - half, pin.dy);
    final barR = Offset(pin.dx + half, pin.dy);

    canvas.drawLine(barL, barR, _pen(AppColors.charcoal, 5));

    canvas.drawPath(
      Path()
        ..moveTo(pin.dx, pin.dy + 2)
        ..lineTo(pin.dx - 11, pin.dy + 19)
        ..lineTo(pin.dx + 11, pin.dy + 19)
        ..close(),
      Paint()..color = AppColors.ink2,
    );
    canvas.drawLine(
      Offset(pin.dx - 20, pin.dy + 20),
      Offset(pin.dx + 20, pin.dy + 20),
      _pen(AppColors.ink3, 1.6),
    );

    // the push, downward in both scenes
    final at = pushLeft ? barL : barR;
    _shaft(
      canvas,
      Offset(at.dx, at.dy - 44),
      Offset(at.dx, at.dy - 5),
      AppColors.ember,
      3,
    );
    _write(
      canvas,
      'push',
      Offset(at.dx, at.dy - 54),
      size: 10.5,
      color: AppColors.ember,
      center: true,
      weight: FontWeight.w700,
    );

    // The turn, drawn over the top of the bar so both arcs are visible.
    //
    // Pushing the left end drops that end: on screen the nine o'clock point
    // travels toward six o'clock, which is counterclockwise. Pushing the
    // right end drops the right: three o'clock travels toward six, which is
    // clockwise. Canvas angles grow clockwise, so the sweep is signed.
    const r = 38.0;
    final box = Rect.fromCircle(center: pin, radius: r);
    final from = pushLeft ? -0.3 : 3.45;
    final sweep = pushLeft ? -2.1 : 2.1;
    canvas.drawArc(box, from, sweep, false, _pen(AppColors.forest, 2.6));
    final endAngle = from + sweep;
    final endAt = Offset(
      pin.dx + r * math.cos(endAngle),
      pin.dy + r * math.sin(endAngle),
    );
    // Tangent in the direction of travel, which reverses with the sweep.
    final way = sweep.isNegative ? -1.0 : 1.0;
    _head(
      canvas,
      endAt,
      Offset(-math.sin(endAngle) * way, math.cos(endAngle) * way),
      AppColors.forest,
      9,
    );

    _write(
      canvas,
      pushLeft ? 'turns this way' : 'turns the other',
      Offset(area.center.dx, area.bottom - 10),
      size: 10.5,
      color: AppColors.forest,
      center: true,
      weight: FontWeight.w700,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width / 2;
    _scene(canvas, Rect.fromLTWH(0, 4, w, size.height - 8), true);
    _scene(canvas, Rect.fromLTWH(w, 4, w, size.height - 8), false);
    canvas.drawLine(
      Offset(w, 16),
      Offset(w, size.height - 28),
      _pen(AppColors.ink3.withValues(alpha: 0.3), 1),
    );
  }

  @override
  bool shouldRepaint(_TurnPairPainter old) => false;
}
