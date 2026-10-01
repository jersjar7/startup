// The pictures on the Mechanics of Materials concept sheets.
//
// A sheet is read picture first (owner's call, 2026-09-30): the drawing the
// student just played with, with one thing happening in it, then the idea in
// short steps, then the rule. So every picture here is built from the same
// painters the games draw with, never a new illustration. The few painters
// that exist only here draw a comparison the games never needed to draw.
//
// Each function is a tear-off used from a `const BriefSection`, so they are
// top-level and take nothing.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';
import '../shared/widgets/engineering_grid.dart';
import 'axial_figures.dart';
import 'column_figures.dart';
import 'beam_figures.dart' show BeamPainter, Spread;
import 'composite_figures.dart';
import 'curve_figures.dart';
import 'deflection_figures.dart';
import 'diagram_figures.dart' hide Held;
import 'mohr_figures.dart';
import 'section_figures.dart' show Profile;
import 'stress_figures.dart';
import 'torsion_figures.dart';

/// One drawing on the sheet: a creamDark tile with the engineering grid, the
/// painter filling it, and a caption in mono under it.
class ConceptPicture extends StatelessWidget {
  const ConceptPicture({
    super.key,
    required this.painter,
    required this.caption,
    this.height = 200,
  });

  final CustomPainter painter;
  final String caption;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            height: height,
            width: double.infinity,
            color: AppColors.creamDark,
            child: EngineeringGrid(
              minor: 18,
              major: 90,
              child: CustomPaint(
                painter: painter,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(caption, style: AppTheme.mono(size: 11.5, color: AppColors.ink2)),
      ],
    );
  }
}

/// Two drawings side by side, sharing one caption line each.
class ConceptPair extends StatelessWidget {
  const ConceptPair({
    super.key,
    required this.left,
    required this.right,
    required this.leftCaption,
    required this.rightCaption,
    this.height = 170,
  });

  final CustomPainter left;
  final CustomPainter right;
  final String leftCaption;
  final String rightCaption;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ConceptPicture(
            painter: left,
            caption: leftCaption,
            height: height,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ConceptPicture(
            painter: right,
            caption: rightCaption,
            height: height,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Axial

Widget deformationPicture() => const ConceptPicture(
  painter: BarPairPainter(
    bars: [
      Bar(length: 1000, area: 400, load: 40000, stuff: Stuff.steel),
      Bar(length: 2000, area: 400, load: 40000, stuff: Stuff.steel),
    ],
    labels: ['A', 'B'],
    truth: 1,
    locked: true,
  ),
  caption:
      'the same pull on two bars. B is twice as long, so it stretches twice as far',
);

Widget unitsPicture() => const ConceptPicture(
  painter: _RulerPainter(),
  caption:
      'one bar, two names for its length. The numbers differ by a thousand',
  height: 150,
);

Widget thermalPicture() => const ConceptPicture(
  painter: RodPainter(
    rod: Rod(length: 1000, stuff: Stuff.steel, held: Held.bothEnds, warmBy: 50),
    showOutcome: true,
  ),
  caption:
      'a bar held at both ends and warmed. It wants to grow and the walls will not let it',
);

// ---------------------------------------------------------------------------
// Torsion

Widget polarJPicture() => const ConceptPicture(
  painter: ShaftPainter(shaft: Shaft(outerD: 80, innerD: 40), markC: true),
  caption:
      'a hollow shaft, end on. c is the outer radius, where the stress is highest',
);

Widget twistPicture() => const ConceptPicture(
  painter: _TwistPainter(),
  caption:
      'a torque turns one end of a shaft past the other. The angle is the twist',
);

Widget thinWallPicture() => const ConceptPicture(
  painter: TubePainter(
    tube: Tube(shape: TubeShape.square, width: 100, height: 70, wall: 6),
    region: Region.median,
  ),
  caption:
      'a thin tube, end on. The shaded area is inside the middle of the wall',
);

// ---------------------------------------------------------------------------
// Stress and strain

const _mildSteel = Specimen(
  label: 'mild steel',
  e: 200000,
  yieldStress: 250,
  ultimate: 400,
  fractureStrain: 0.25,
  plateau: 0.014,
  necksTo: 0.86,
);

const _castIron = Specimen(
  label: 'cast iron',
  e: 110000,
  yieldStress: 200,
  ultimate: 210,
  fractureStrain: 0.006,
  necksTo: 1,
  proportionalShare: 0.9,
);

Widget curvePicture() => ConceptPicture(
  painter: TensilePainter(
    specimen: _mildSteel,
    frame: Frame.over([_mildSteel]),
    labelled: Mark.values,
  ),
  caption: 'pull a steel bar until it breaks and plot how hard against how far',
  height: 220,
);

Widget stiffStrongPicture() => ConceptPicture(
  painter: PairPainter(
    left: _mildSteel,
    right: _castIron,
    frame: Frame.over([_mildSteel, _castIron]),
  ),
  caption:
      'steel and cast iron on the same axes. Steel goes far to the right; iron stops early',
  height: 220,
);

Widget linkedPicture() => const ConceptPicture(
  painter: _PoissonPainter(),
  caption:
      'pull a bar and it gets longer AND thinner. The ratio of the two is nu',
  height: 170,
);

// ---------------------------------------------------------------------------
// Shear and moment diagrams

const _udlBeam = Loading(span: 6, b: 6, spreads: [Spread(0, 6, 10, 10)]);

const _offsetBeam = Loading(span: 6, b: 6, points: [(2, 30)]);

const _coupleBeam = Loading(
  span: 6,
  b: 6,
  points: [(2, 20)],
  couples: [(4, 40)],
);

Widget slopeRulesPicture() => const ConceptPicture(
  painter: _BeamAndDiagramsPainter(_udlBeam),
  caption:
      'a spread load, then its shear (V) and its moment (M). Shear slopes, moment curves',
  height: 260,
);

Widget peakPicture() => const ConceptPicture(
  painter: _BeamAndDiagramsPainter(_offsetBeam),
  caption:
      'one load off center. The moment peaks right under it, where the shear crosses zero',
  height: 260,
);

Widget jumpPicture() => const ConceptPicture(
  painter: _BeamAndDiagramsPainter(_coupleBeam),
  caption:
      'a force and a couple. The force steps the shear; the couple steps the moment',
  height: 260,
);

// ---------------------------------------------------------------------------
// Bending and shear stresses

final _box = boxSection(120, 240);

Widget fiberPicture() => ConceptPair(
  left: LayerPainter(
    profile: _box,
    layers: const [Layer(240, 'top'), Layer(120, 'middle'), Layer(0, 'bottom')],
    show: Runs.bending,
    moment: 20e6,
    shear: 30e3,
    locked: true,
  ),
  right: LayerPainter(
    profile: _box,
    layers: const [Layer(240, 'top'), Layer(120, 'middle'), Layer(0, 'bottom')],
    show: Runs.shear,
    moment: 20e6,
    shear: 30e3,
    locked: true,
  ),
  leftCaption: 'bending: worst at the faces, nothing in the middle',
  rightCaption: 'shear: worst in the middle, nothing at the faces',
  height: 200,
);

final _iBeam = iSection(
  depth: 300,
  flangeWidth: 150,
  flangeThickness: 12,
  webThickness: 8,
);

Widget cutPicture() => ConceptPair(
  left: MarkPainter(
    profile: _iBeam,
    cut: 250,
    mark: const Ingredient.width(250),
    tone: AppColors.ember,
  ),
  right: MarkPainter(
    profile: _iBeam,
    cut: 250,
    mark: const Ingredient.band(250, 300),
    tone: AppColors.info,
  ),
  leftCaption: 'b: how wide the metal is AT the cut, here the thin web',
  rightCaption: 'Q: the material beyond the cut, here the whole flange',
  height: 200,
);

Widget governsPicture() => const ConceptPicture(
  painter: _JoistPainter(),
  caption:
      'the same plank, on edge and flat. Same wood, same load, very different bending',
  height: 190,
);

// ---------------------------------------------------------------------------
// Deflections

Widget tableLinePicture() => const Column(
  children: [
    ConceptPicture(
      painter: SagPainter(entry: Entry.ssPoint, span: 6),
      caption: 'held at both ends, load in the middle',
      height: 130,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: SagPainter(entry: Entry.cantPoint, span: 6),
      caption: 'built in at one end, free at the other',
      height: 130,
    ),
  ],
);

Widget bouncePicture() => const ConceptPicture(
  painter: _DepthPainter(),
  caption: 'same span, same load. The deeper joist barely moves',
  height: 200,
);

Widget addUpPicture() => const ConceptPicture(
  painter: PairPainter2(
    left: Loading(span: 6, b: 6, points: [(3, 20)]),
    right: Loading(span: 6, b: 6, spreads: [Spread(0, 6, 5, 5)]),
  ),
  caption: 'one beam with two loads, taken apart into two beams from the table',
  height: 150,
);

// ---------------------------------------------------------------------------
// Transformed sections and plastic moment

// Steel on aluminum: the ratio is about three, so the widened strip still
// fits beside the original. Timber on steel would be eighteen times wider
// and unreadable at this size; the idea is the same.
const _aluminumAndSteel = Composite([
  Slice(Offset(0, 0), Size(150, 12), Made.steel),
  Slice(Offset(0, 12), Size(150, 200), Made.aluminum),
]);

Widget transformPicture() {
  final n = _aluminumAndSteel.n;
  final frame = _aluminumAndSteel.transformed();
  return ConceptPair(
    left: MadePainter(slices: _aluminumAndSteel.slices, frame: frame),
    right: MadePainter(
      slices: _aluminumAndSteel.slices,
      widths: [150 * n, 150],
      frame: frame,
    ),
    leftCaption: 'aluminum on a steel strip, as built',
    rightCaption:
        'the same beam written as all aluminum: the steel gets n times wider',
    height: 190,
  );
}

Widget joinPicture() => const ConceptPair(
  left: MadePainter(
    slices: [
      Slice(Offset(0, 0), Size(150, 12), Made.steel),
      Slice(Offset(0, 12), Size(150, 200), Made.aluminum),
    ],
    join: 12,
  ),
  right: _StressJumpPainter(),
  leftCaption: 'two materials glued along the marked line',
  rightCaption: 'strain runs straight through; stress jumps at the glue',
  height: 190,
);

Widget plasticPicture() {
  final section = boxSection(100, 200);
  Widget one(Spread3 state, String caption) => Expanded(
    child: ConceptPicture(
      painter: StressBlockPainter(profile: section, state: state),
      caption: caption,
      height: 150,
    ),
  );
  return Column(
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          one(Spread3.elastic, '1. nothing has yielded'),
          const SizedBox(width: 10),
          one(Spread3.firstYield, '2. the faces just yield'),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          one(Spread3.partly, '3. yield eats inward'),
          const SizedBox(width: 10),
          one(Spread3.fully, '4. yielded right through'),
        ],
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Mohr's circle

const _general = Stress(x: 80, y: 20, xy: 40);

Widget circlePicture() => ConceptPair(
  left: const ElementPainter(stress: _general, label: 'the point'),
  right: MohrPainter(
    stress: _general,
    span: Window.over(const [_general]),
    spots: Spot.values,
    locked: true,
  ),
  leftCaption: 'a tiny square of material and the pushes on it',
  rightCaption:
      'the same point as a circle. Every plane through it is a spot on the rim',
  height: 210,
);

Widget buildPicture() {
  const pure = Stress(x: 0, y: 0, xy: 50);
  const uniaxial = Stress(x: 100, y: 0, xy: 0);
  const equal = Stress(x: 60, y: 60, xy: 0);
  final window = Window.over(const [pure, uniaxial, equal]);
  Widget one(Stress s, String caption) => Expanded(
    child: ConceptPicture(
      painter: MohrPainter(
        stress: s,
        span: window,
        spots: const [Spot.s1, Spot.s2],
        locked: true,
      ),
      caption: caption,
      height: 150,
    ),
  );
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      one(pure, 'pure shear: centered on zero'),
      const SizedBox(width: 8),
      one(uniaxial, 'one pull: from zero out'),
      const SizedBox(width: 8),
      one(equal, 'equal both ways: a dot'),
    ],
  );
}

Widget worstPicture() {
  const crossing = Stress(x: 60, y: -20, xy: 30);
  const clear = Stress(x: 100, y: 60, xy: 10);
  final window = Window.over(const [crossing, clear]);
  return ConceptPair(
    left: MohrPainter(
      stress: crossing,
      span: window,
      spots: const [Spot.s1, Spot.s2],
      locked: true,
    ),
    right: MohrPainter(
      stress: clear,
      span: window,
      spots: const [Spot.s1, Spot.s2],
      locked: true,
    ),
    leftCaption: 'the circle crosses zero: the radius is the worst shear',
    rightCaption:
        'the circle sits clear of zero: the real spread runs back to zero',
    height: 190,
  );
}

// ---------------------------------------------------------------------------
// Buckling

Widget endsPicture() => const ConceptPair(
  left: PostPainter(
    post: Post(length: 3000, top: End.pinned, bottom: End.pinned),
    bent: true,
  ),
  right: PostPainter(
    post: Post(length: 3000, top: End.free, bottom: End.fixed),
    bent: true,
  ),
  leftCaption: 'pinned at both ends: it bows once, K = 1',
  rightCaption:
      'built in below, free above: it leans like half a longer column, K = 2',
  height: 220,
);

final Profile _wideFlange = iSection(
  depth: 200,
  flangeWidth: 150,
  flangeThickness: 12,
  webThickness: 8,
);

Widget weakAxisPicture() => ConceptPicture(
  painter: AxisPainter(profile: _wideFlange, highlight: false, locked: true),
  caption:
      'a wide flange with both axes drawn. It folds about the one it is weakest around',
  height: 200,
);

Widget slenderPicture() => const ConceptPicture(
  painter: ColumnCurvePainter(
    post: Post(length: 3200, top: End.pinned, bottom: End.pinned),
  ),
  caption:
      'how much stress a column takes, against how slender it is. Short ones squash at yield; long ones bow first',
  height: 220,
);

// ---------------------------------------------------------------------------
// The painters that exist only for a sheet

TextPainter _text(String s, {double size = 11, Color color = AppColors.ink2}) {
  return TextPainter(
    text: TextSpan(
      text: s,
      style: AppTheme.mono(size: size, color: color),
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

void _arrow(Canvas canvas, Offset from, Offset to, Paint paint) {
  canvas.drawLine(from, to, paint);
  final d = to - from;
  final len = d.distance;
  if (len < 1) return;
  final u = d / len;
  final n = Offset(-u.dy, u.dx);
  final head = Path()
    ..moveTo(to.dx, to.dy)
    ..lineTo(to.dx - u.dx * 9 + n.dx * 5, to.dy - u.dy * 9 + n.dy * 5)
    ..lineTo(to.dx - u.dx * 9 - n.dx * 5, to.dy - u.dy * 9 - n.dy * 5)
    ..close();
  canvas.drawPath(head, Paint()..color = paint.color);
}

/// One bar with its length written two ways.
class _RulerPainter extends CustomPainter {
  const _RulerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.12;
    final right = size.width * 0.88;
    final mid = size.height * 0.5;
    final bar = Rect.fromLTRB(left, mid - 14, right, mid + 14);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bar, const Radius.circular(6)),
      Paint()..color = AppColors.charcoal,
    );
    final tick = _stroke(AppColors.ink2, 1.5);
    for (final y in [mid - 30, mid + 30]) {
      canvas.drawLine(Offset(left, y - 6), Offset(left, y + 6), tick);
      canvas.drawLine(Offset(right, y - 6), Offset(right, y + 6), tick);
      canvas.drawLine(Offset(left, y), Offset(right, y), tick);
    }
    final top = _text('2 m', size: 14, color: AppColors.charcoal);
    inkLabel(
      canvas,
      top,
      Offset(size.width / 2 - top.width / 2, mid - 30 - top.height - 4),
    );
    final bottom = _text('2000 mm', size: 14, color: AppColors.ember);
    inkLabel(
      canvas,
      bottom,
      Offset(size.width / 2 - bottom.width / 2, mid + 34),
    );
  }

  @override
  bool shouldRepaint(_RulerPainter old) => false;
}

/// A shaft seen from the side, one end held, the other turned by a torque.
class _TwistPainter extends CustomPainter {
  const _TwistPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.16;
    final right = size.width * 0.78;
    final mid = size.height * 0.5;
    final r = size.height * 0.18;
    // the wall
    canvas.drawRect(
      Rect.fromLTWH(left - 14, mid - r - 22, 14, 2 * r + 44),
      Paint()..color = AppColors.ink2,
    );
    // the shaft
    final body = Rect.fromLTRB(left, mid - r, right, mid + r);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(r * 0.25)),
      Paint()..color = AppColors.creamDark,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(r * 0.25)),
      _stroke(AppColors.charcoal, 2),
    );
    // the end face
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(right, mid),
        width: r * 0.7,
        height: 2 * r,
      ),
      Paint()..color = AppColors.charcoal,
    );
    // a line along the shaft that was straight and is now a spiral
    final ghost = _stroke(AppColors.ink2, 1.5);
    canvas.drawLine(
      Offset(left, mid - r * 0.55),
      Offset(right, mid - r * 0.55),
      ghost,
    );
    final twist = Path()..moveTo(left, mid - r * 0.55);
    const steps = 24;
    for (var k = 1; k <= steps; k++) {
      final t = k / steps;
      final x = left + (right - left) * t;
      // the line turns with the free end: straight at the wall, a quarter
      // turn round by the far end
      final angle = -math.pi / 2 + t * 2.4;
      twist.lineTo(x, mid + r * 0.55 * math.sin(angle));
    }
    canvas.drawPath(twist, _stroke(AppColors.ember, 3));
    // the torque arrow round the free end
    final arc = Path()
      ..addArc(
        Rect.fromCenter(
          center: Offset(right + 18, mid),
          width: 30,
          height: 2 * r + 24,
        ),
        -math.pi * 0.35,
        math.pi * 0.7,
      );
    canvas.drawPath(arc, _stroke(AppColors.charcoal, 2.5));
    _arrow(
      canvas,
      Offset(
        right + 18 + 15 * math.cos(math.pi * 0.35),
        mid + (r + 12) * math.sin(math.pi * 0.35),
      ),
      Offset(
        right + 18 + 15 * math.cos(math.pi * 0.42),
        mid + (r + 12) * math.sin(math.pi * 0.42),
      ),
      _stroke(AppColors.charcoal, 2.5),
    );
    // the end face itself: a mark that pointed straight up now points
    // part way round, and the angle between the two IS the twist
    final face = Offset(right, mid);
    final ghostTick = _stroke(AppColors.ink2, 1.5);
    canvas.drawLine(face, face + Offset(0, -r * 0.92), ghostTick);
    const turned = -math.pi / 2 + 0.85;
    final tip =
        face + Offset(r * 0.35 * math.cos(turned), r * 0.92 * math.sin(turned));
    canvas.drawLine(face, tip, _stroke(AppColors.spring, 3.5));
    canvas.drawCircle(face, 3, Paint()..color = AppColors.spring);
    final t = _text('T', size: 13, color: AppColors.charcoal);
    inkLabel(canvas, t, Offset(right + 36, mid - t.height / 2));
    final phi = _text('twist', size: 11, color: AppColors.ember);
    inkLabel(canvas, phi, Offset(right - phi.width - 6, mid + r + 8));
  }

  @override
  bool shouldRepaint(_TwistPainter old) => false;
}

/// A bar before and after a pull: longer, and thinner.
class _PoissonPainter extends CustomPainter {
  const _PoissonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height * 0.5;
    final left = size.width * 0.22;
    final before = Rect.fromLTRB(left, mid - 26, size.width * 0.66, mid + 26);
    final after = Rect.fromLTRB(left, mid - 19, size.width * 0.80, mid + 19);
    canvas.drawRRect(
      RRect.fromRectAndRadius(before, const Radius.circular(6)),
      _stroke(AppColors.ink2, 1.5),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(after, const Radius.circular(6)),
      Paint()..color = AppColors.ember.withValues(alpha: 0.85),
    );
    final pull = _stroke(AppColors.charcoal, 2.5);
    _arrow(
      canvas,
      Offset(after.right + 4, mid),
      Offset(size.width * 0.95, mid),
      pull,
    );
    _arrow(
      canvas,
      Offset(after.left - 4, mid),
      Offset(size.width * 0.06, mid),
      pull,
    );
    final a = _text('before', size: 11, color: AppColors.ink2);
    inkLabel(canvas, a, Offset(left, before.top - a.height - 6));
    final b = _text(
      'pulled: longer, thinner',
      size: 11,
      color: AppColors.ember,
    );
    inkLabel(canvas, b, Offset(left, after.bottom + 8));
  }

  @override
  bool shouldRepaint(_PoissonPainter old) => false;
}

/// A beam with its shear and moment diagrams stacked under it, drawn with
/// the same painters the diagram games use.
class _BeamAndDiagramsPainter extends CustomPainter {
  const _BeamAndDiagramsPainter(this.beam);

  final Loading beam;

  @override
  void paint(Canvas canvas, Size size) {
    final beamH = size.height * 0.36;
    final each = (size.height - beamH) / 2;
    BeamPainter(
      span: beam.span,
      supports: supportsOf(beam),
      spreads: beam.spreads,
      loads: [for (final p in beam.points) (p.$1, kn(p.$2))],
      couples: [for (final c in beam.couples) (c.$1, c.$2 > 0, kn(c.$2.abs()))],
    ).paint(canvas, Size(size.width, beamH));
    for (final (i, what) in Diagram.values.indexed) {
      final curve = beam.curve(what);
      var peak = 0.0;
      for (final p in curve) {
        if (p.dy.abs() > peak) peak = p.dy.abs();
      }
      canvas.save();
      canvas.translate(0, beamH + i * each);
      DiagramPainter(
        curve: curve,
        span: beam.span,
        peak: peak,
        tone: what == Diagram.shear ? AppColors.info : AppColors.ember,
        label: what == Diagram.shear ? 'V' : 'M',
      ).paint(canvas, Size(size.width, each - 4));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BeamAndDiagramsPainter old) => old.beam != beam;
}

/// The same plank on edge and flat, with the load on each.
class _JoistPainter extends CustomPainter {
  const _JoistPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final base = size.height * 0.78;
    final fill = Paint()..color = AppColors.charcoal;
    final load = _stroke(AppColors.ember, 3);
    // on edge
    final x1 = size.width * 0.28;
    final tall = Rect.fromCenter(
      center: Offset(x1, base - 50),
      width: 22,
      height: 100,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tall, const Radius.circular(4)),
      fill,
    );
    _arrow(canvas, Offset(x1, tall.top - 38), Offset(x1, tall.top - 4), load);
    // flat
    final x2 = size.width * 0.70;
    final flat = Rect.fromCenter(
      center: Offset(x2, base - 11),
      width: 100,
      height: 22,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(flat, const Radius.circular(4)),
      fill,
    );
    _arrow(canvas, Offset(x2, flat.top - 38), Offset(x2, flat.top - 4), load);
    // ground
    canvas.drawLine(
      Offset(size.width * 0.08, base + 2),
      Offset(size.width * 0.92, base + 2),
      _stroke(AppColors.ink2, 1.5),
    );
    final a = _text('on edge: stiff', size: 11, color: AppColors.charcoal);
    inkLabel(canvas, a, Offset(x1 - a.width / 2, base + 10));
    final b = _text('flat: bends easily', size: 11, color: AppColors.ember);
    inkLabel(canvas, b, Offset(x2 - b.width / 2, base + 10));
  }

  @override
  bool shouldRepaint(_JoistPainter old) => false;
}

/// Two joists of the same span and load, one twice as deep, each sagging.
class _DepthPainter extends CustomPainter {
  const _DepthPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.1;
    final right = size.width * 0.9;
    void joist(
      double y,
      double depth,
      double sag,
      String label,
      Color tone, {
      bool labelAbove = false,
    }) {
      final path = Path()..moveTo(left, y);
      path.quadraticBezierTo((left + right) / 2, y + sag * 2, right, y);
      path.lineTo(right, y + depth);
      path.quadraticBezierTo(
        (left + right) / 2,
        y + depth + sag * 2,
        left,
        y + depth,
      );
      path.close();
      canvas.drawPath(path, Paint()..color = AppColors.charcoal);
      canvas.drawLine(
        Offset(left, y),
        Offset(right, y),
        _stroke(AppColors.ink2, 1)..strokeCap = StrokeCap.butt,
      );
      final load = _stroke(tone, 3);
      _arrow(
        canvas,
        Offset(size.width / 2, y - 34),
        Offset(size.width / 2, y + sag - 3),
        load,
      );
      // Each name stays with its own joist. The shallow one sags so far that
      // anything under it lands in the next joist's load arrow, so it takes
      // the clear ground above its beam, left of the arrow. The deep one
      // barely moves, so under it is clear.
      final t = _text(label, size: 11, color: tone);
      inkLabel(
        canvas,
        t,
        labelAbove
            ? Offset(left, y - 17)
            : Offset(right - t.width, y + depth + sag * 2 + 7),
      );
    }

    joist(
      size.height * 0.22,
      10,
      22,
      'shallow: sags a lot',
      AppColors.ember,
      labelAbove: true,
    );
    joist(
      size.height * 0.64,
      22,
      3,
      'twice as deep: eight times stiffer',
      AppColors.charcoal,
    );
  }

  @override
  bool shouldRepaint(_DepthPainter old) => false;
}

/// Strain and stress through the depth of a two-material beam: one straight
/// line, one line with a jump at the glue.
class _StressJumpPainter extends CustomPainter {
  const _StressJumpPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final top = size.height * 0.14;
    final bottom = size.height * 0.86;
    final join = top + (bottom - top) * 0.12;
    final mid = top + (bottom - top) * 0.55; // the neutral axis
    void column(double x0, double w, String label, {required bool jump}) {
      final axis = _stroke(AppColors.ink2, 1.5);
      canvas.drawLine(Offset(x0, top), Offset(x0, bottom), axis);
      canvas.drawLine(
        Offset(x0 - w * 0.6, mid),
        Offset(x0 + w * 0.6, mid),
        axis,
      );
      double at(double y) => x0 + w * (mid - y) / (mid - top);
      final line = Path()..moveTo(at(bottom), bottom);
      if (jump) {
        line.lineTo(at(join), join);
        line.lineTo(x0 + (at(join) - x0) * 2.6, join);
        line.lineTo(x0 + (at(top) - x0) * 2.6, top);
      } else {
        line.lineTo(at(top), top);
      }
      canvas.drawPath(
        line,
        _stroke(jump ? AppColors.ember : AppColors.charcoal, 3),
      );
      canvas.drawLine(
        Offset(x0 - w * 0.7, join),
        Offset(x0 + w * 1.6, join),
        _stroke(AppColors.ink2, 1)..strokeCap = StrokeCap.butt,
      );
      final t = _text(
        label,
        size: 11,
        color: jump ? AppColors.ember : AppColors.charcoal,
      );
      inkLabel(canvas, t, Offset(x0 - t.width / 2, bottom + 6));
    }

    final w = size.width * 0.13;
    column(size.width * 0.3, w, 'strain', jump: false);
    column(size.width * 0.66, w, 'stress', jump: true);
  }

  @override
  bool shouldRepaint(_StressJumpPainter old) => false;
}

/// Kept so the file's public surface reads as one list.
const mechanicsPictures = <String, Widget Function()>{
  'deformation': deformationPicture,
  'units': unitsPicture,
  'thermal': thermalPicture,
  'polar-j': polarJPicture,
  'twist': twistPicture,
  'thin-wall': thinWallPicture,
  'curve': curvePicture,
  'stiff-strong': stiffStrongPicture,
  'linked': linkedPicture,
  'slope-rules': slopeRulesPicture,
  'peak': peakPicture,
  'jump': jumpPicture,
  'fiber': fiberPicture,
  'cut': cutPicture,
  'governs': governsPicture,
  'table-line': tableLinePicture,
  'bounce': bouncePicture,
  'add-up': addUpPicture,
  'transform': transformPicture,
  'join': joinPicture,
  'plastic': plasticPicture,
  'circle': circlePicture,
  'build': buildPicture,
  'worst': worstPicture,
  'ends': endsPicture,
  'weak-axis': weakAxisPicture,
  'slender': slenderPicture,
};
