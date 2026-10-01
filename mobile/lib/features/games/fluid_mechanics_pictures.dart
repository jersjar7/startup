// The pictures on the Fluid Mechanics concept sheets.
//
// A sheet is read picture first (owner's call, 2026-09-30): the drawing the
// student just played with, with one thing happening in it, then the idea in
// short steps, then the rule. Built from the same painters the games draw
// with; see mechanics_pictures.dart for the pattern and the shared
// ConceptPicture and ConceptPair tiles. The few painters that exist only here
// draw a comparison the games never needed to draw.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';
import 'fluid_figures.dart';
import 'mechanics_pictures.dart' show ConceptPicture, ConceptPair;
import 'meter_figures.dart';
import 'model_figures.dart';
import 'momentum_figures.dart';
import 'pipe_figures.dart';

// ---------------------------------------------------------------------------
// Fluid properties

Widget threeNumbersPicture() => const ConceptPicture(
  painter: _CubePainter(),
  caption: 'one cubic meter of water, weighed three ways',
  height: 210,
);

Widget viscosityPicture() => const ConceptPair(
  left: FilmPainter(
    film: Film(mu: 0.1, speed: 0.5, millimeters: 6),
    thickest: 6,
  ),
  right: FilmPainter(
    film: Film(mu: 0.1, speed: 0.5, millimeters: 2),
    thickest: 6,
  ),
  leftCaption: 'a thick film of oil: the plate slides easily',
  rightCaption: 'the same oil, a thinner film: it drags three times harder',
  height: 190,
);

Widget capillaryPicture() => const ConceptPicture(
  painter: CapillaryPainter(
    straws: [Straw(millimeters: 3), Straw(millimeters: 1.5)],
    answer: 1,
    locked: true,
  ),
  caption: 'two straws in the same dish. the narrow one climbs twice as high',
  height: 220,
);

// ---------------------------------------------------------------------------
// Hydrostatic pressure

Widget depthPicture() => const ConceptPicture(
  painter: PotPainter(
    pots: [
      Pot(shape: Shape4.tapered, depth: 3),
      Pot(shape: Shape4.flared, depth: 3),
    ],
    deepest: 3,
  ),
  caption:
      'two very different vessels, filled to the same depth. the marked '
      'points press exactly as hard',
  height: 210,
);

Widget gaugePicture() => const ConceptPicture(
  painter: _ZeroPainter(),
  caption: 'one pressure, two rulers. they read different numbers',
  height: 210,
);

// The whole journey in one route, because the steps describe walking the
// tube end to end and a single hop showed only the first move. Drawn open
// end to air line, so the path itself goes down one leg, across the bend
// and up the other. Three separate panels collided with the tube's own
// caption under the bend, which is why this is one picture and not three.
Widget manometerPicture() => const ConceptPicture(
  painter: UTubePainter(
    tube: UTube(hasLight: true),
    from: Stop.open,
    to: Stop.line,
  ),
  caption:
      'one walk, end to end: start at the open end where you know it is zero, DOWN the right leg (add), across the bend (nothing), UP the left leg (subtract)',
  height: 250,
);

// ---------------------------------------------------------------------------
// Gates and buoyancy

Widget gatePicture() => const ConceptPicture(
  painter: GatePainter(
    gate: Gate(wide: 2, tall: 3),
    among: [Mark3.centroid, Mark3.pressure],
    answer: Mark3.pressure,
    locked: true,
  ),
  caption:
      'a gate holding water back. the push grows with depth, so it is '
      'bottom heavy',
  height: 230,
);

Widget buoyancyPicture() => const ConceptPair(
  left: LumpPainter(lump: Lump(volume: 2, weight: 15)),
  right: LumpPainter(lump: Lump(volume: 2, weight: 34)),
  leftCaption: 'the water it shoves aside weighs more than it does: up',
  rightCaption: 'the same tank, heavier: down',
  height: 195,
);

// ---------------------------------------------------------------------------
// Bernoulli

Widget continuityPicture() => const ConceptPicture(
  painter: RunPainter(
    run: Run(bores: [Bore(millimeters: 200), Bore(millimeters: 100)]),
  ),
  caption:
      'the same water through half the bore. the opening quarters, so the '
      'speed goes up four times',
  height: 200,
);

Widget bernoulliPicture() => const ConceptPicture(
  painter: RunPainter(
    run: Run(
      bores: [
        Bore(millimeters: 200, share: 0.9),
        Bore(millimeters: 90, share: 0.6),
        Bore(millimeters: 200, share: 0.9),
      ],
    ),
    answer: 1,
    locked: true,
  ),
  caption:
      'a squeeze in the pipe. the water is fastest here, and pressing least',
  height: 200,
);

Widget torricelliPicture() => const ConceptPair(
  left: SquirtPainter(squirt: Squirt(head: 10), tallest: 10, showJet: true),
  right: SquirtPainter(squirt: Squirt(head: 2.5), tallest: 10, showJet: true),
  leftCaption: 'a deep tank: the jet comes out fast',
  rightCaption: 'a quarter of the head: half the speed, not a quarter',
  height: 210,
);

// ---------------------------------------------------------------------------
// Head loss

Widget reynoldsPicture() => const ConceptPicture(
  painter: _BandsPainter(),
  caption: 'one number, and the band it lands in decides what you do next',
  height: 215,
);

Widget darcyPicture() => const ConceptPicture(
  painter: _LossPainter(),
  caption: 'the same water through two pipes. one size up is a huge saving',
  height: 210,
);

Widget minorPicture() => const ConceptPicture(
  painter: _AddUpPainter(),
  caption: 'the pipe and every fitting on it. all of them cost head',
  height: 210,
);

// ---------------------------------------------------------------------------
// Momentum

Widget deflectionPicture() => const ConceptPicture(
  painter: _ThreeFacesPainter(),
  caption:
      'the same jet at three targets. how far the water is turned is what '
      'sets the push',
  height: 330,
);

Widget thrustPicture() => const ConceptPicture(
  painter: TrunkPainter(
    trunk: Trunk(
      legs: [
        Leg(heading: Heading.east),
        Leg(heading: Heading.east),
        Leg(heading: Heading.east),
        Leg(heading: Heading.north),
      ],
    ),
    locked: true,
  ),
  caption:
      'a buried main from above. only the corner is shoved, the straight '
      'joints are not',
  height: 220,
);

// The game's painter letters four candidate spots and marks the right one,
// which is a quiz rather than an explanation. The sheet draws the reason
// instead: the water came in going one way, leaves going another, and the
// change between them is what gets shoved into the pipe.
Widget blockPicture() => const ConceptPicture(
  painter: _BendThrustPainter(),
  caption:
      'a bend from above. the water turns, and the arrow that closes the two directions is the way the pipe is shoved',
  height: 250,
);

// ---------------------------------------------------------------------------
// Metering

const _venturi = Gauge(
  wall: [(0, 200), (0.3, 200), (0.42, 100), (0.55, 100), (0.72, 200), (1, 200)],
  taps: (0.18, 0.48),
  stations: [
    Sta(at: 0.15),
    Sta(at: 0.33),
    Sta(at: 0.48, meters: true),
    Sta(at: 0.85),
  ],
);

Widget meteringPicture() => const ConceptPicture(
  painter: GaugePainter(gauge: _venturi, locked: true),
  caption:
      'a venturi in section. the two taps say what is being measured, and '
      'the throat is the area that goes in',
  height: 220,
);

// The table of slips is not a thing you can point at, so the sheet now opens
// with the reason a coefficient exists at all: the stream that really leaves
// a hole is narrower than the hole. That is what makes every coefficient
// less than one, which is the slip that matters most.
Widget coefficientPicture() => const Column(
  children: [
    ConceptPicture(
      painter: GaugePainter(
        gauge: Gauge(
          wall: [
            (0, 150),
            (0.43, 150),
            (0.44, 75),
            (0.46, 75),
            (0.47, 150),
            (1, 150),
          ],
          plateAt: 0.45,
          jet: [(0.47, 70), (0.58, 52), (0.72, 66), (1, 130)],
          taps: (0.3, 0.62),
          stations: [Sta(at: 0.45, meters: true)],
        ),
        locked: true,
      ),
      caption:
          'water leaving a hole squeezes narrower than the hole itself. the formula measures the hole, so it always promises more than you get',
      height: 210,
    ),
    SizedBox(height: 14),
    ConceptPicture(
      painter: _SlipPainter(),
      caption: 'four slips, and which way each one moves the flow you report',
      height: 220,
    ),
  ],
);

// ---------------------------------------------------------------------------
// Similitude

Widget similitudePicture() => const Column(
  children: [
    ConceptPicture(
      painter: BenchPainter(
        bench: Bench.openChannel,
        caption: 'a spillway, open to the air',
      ),
      caption: 'a surface you can see: gravity is shaping it, so match Froude',
      height: 175,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: BenchPainter(
        bench: Bench.closedPipe,
        caption: 'a valve in a pipe running full',
      ),
      caption:
          'no surface at all: gravity has nothing to pull against, so match '
          'Reynolds',
      height: 175,
    ),
  ],
);

Widget scalingPicture() => const Column(
  children: [
    ConceptPicture(
      painter: TwinsPainter(twins: Twins(law: Law.froude, model: 1, proto: 25)),
      caption: 'Froude, a model a 25th the size: run it SLOWER, at a fifth',
      height: 165,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: TwinsPainter(
        twins: Twins(law: Law.reynolds, model: 1, proto: 10),
      ),
      caption: 'Reynolds, a model a 10th the size: run it FASTER, ten times',
      height: 165,
    ),
  ],
);

// ---------------------------------------------------------------------------
// The painters that exist only for a sheet

/// A right angle bend seen from above, with the water's direction in, the
/// water's direction out, and the arrow that closes the gap between them.
/// That closing arrow IS the thrust, and it points to the outside of the
/// turn, which is the whole of the item.
class _BendThrustPainter extends CustomPainter {
  const _BendThrustPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final corner = Offset(size.width * 0.44, size.height * 0.42);
    final leg = math.min(size.width, size.height) * 0.30;
    final start = corner - const Offset(1, 0) * leg * 1.3;
    final end = corner - const Offset(0, 1) * leg * 1.25;

    final bent = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(corner.dx, corner.dy)
      ..lineTo(end.dx, end.dy);
    canvas
      ..drawPath(
        bent,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.miter
          ..strokeWidth = 17,
      )
      ..drawPath(
        bent,
        Paint()
          ..color = AppColors.info.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.miter
          ..strokeWidth = 13,
      );

    // Which way the water is going, before and after.
    final flow = _stroke(AppColors.info, 2.6);
    _arrow(
      canvas,
      start + const Offset(4, 0),
      start + Offset(leg * 0.7, 0),
      flow,
    );
    _arrow(canvas, end + Offset(0, leg * 0.7), end + const Offset(0, 4), flow);
    final inLabel = _text('in', color: AppColors.info);
    inkLabel(canvas, inLabel, start + Offset(leg * 0.24, -18));
    final outLabel = _text('out', color: AppColors.info);
    inkLabel(canvas, outLabel, end + const Offset(10, -4));

    // The two directions drawn from one point, and the arrow that closes
    // them. It runs from the way the water LEAVES back to the way it came,
    // which is the direction the pipe is shoved: the reaction, not the
    // water's own change, so it is labeled as the shove and not as it.
    final hub = Offset(size.width * 0.76, size.height * 0.68);
    const arm = 34.0;
    final was = hub + const Offset(arm, 0);
    final now = hub + const Offset(0, -arm);
    final faint = _stroke(AppColors.info, 2.2);
    _arrow(canvas, hub, was, faint);
    _arrow(canvas, hub, now, faint);
    _arrow(canvas, now, was, _stroke(AppColors.ember, 3));
    final change = _text('close the gap', size: 10, color: AppColors.ember);
    inkLabel(canvas, change, hub + const Offset(-20, -54));

    // The same change, put back on the bend: the pipe is shoved this way.
    final push = Offset(1 / math.sqrt2, 1 / math.sqrt2);
    _arrow(
      canvas,
      corner + push * 12,
      corner + push * (leg + 30),
      _stroke(AppColors.ember, 3),
    );
    final shove = _text(
      'the pipe is shoved this way',
      size: 10,
      color: AppColors.ember,
    );
    inkLabel(
      canvas,
      shove,
      Offset(
        math.min(corner.dx + 6, size.width - shove.width - 6),
        corner.dy + leg + 22,
      ),
    );

    final tag = _text(
      'plan, seen from above',
      size: 9.5,
      color: AppColors.ink3,
    );
    inkLabel(canvas, tag, Offset(size.width - tag.width - 8, 8));
  }

  @override
  bool shouldRepaint(_BendThrustPainter old) => false;
}

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

/// One cubic meter of water with the three numbers that describe it.
class _CubePainter extends CustomPainter {
  const _CubePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width * 0.34, size.height * 0.52);
    final left = size.width * 0.12;
    final top = size.height * 0.26;
    final d = side * 0.32;
    final front = Rect.fromLTWH(left, top + d, side, side);

    // the box, drawn as a cube with water in the front face
    final body = Paint()..color = AppColors.info.withValues(alpha: 0.35);
    canvas.drawRect(front, body);
    final topFace = Path()
      ..moveTo(front.left, front.top)
      ..lineTo(front.left + d, front.top - d)
      ..lineTo(front.right + d, front.top - d)
      ..lineTo(front.right, front.top)
      ..close();
    final sideFace = Path()
      ..moveTo(front.right, front.top)
      ..lineTo(front.right + d, front.top - d)
      ..lineTo(front.right + d, front.bottom - d)
      ..lineTo(front.right, front.bottom)
      ..close();
    canvas.drawPath(
      topFace,
      Paint()..color = AppColors.info.withValues(alpha: 0.2),
    );
    canvas.drawPath(
      sideFace,
      Paint()..color = AppColors.info.withValues(alpha: 0.26),
    );
    final edge = _stroke(AppColors.charcoal, 2);
    canvas.drawRect(front, edge);
    canvas.drawPath(topFace, edge);
    canvas.drawPath(sideFace, edge);

    final metre = _text('1 m', size: 10.5, color: AppColors.ink2);
    inkLabel(
      canvas,
      metre,
      Offset(front.center.dx - metre.width / 2, front.bottom + 7),
    );

    // the three readings
    final x = front.right + d + 24;
    final rows = <(String, String, Color)>[
      ('MASS', '1,000 kg', AppColors.charcoal),
      ('WEIGHT', '9,810 N', AppColors.ember),
      ('AGAINST WATER', 'SG 1.0', AppColors.forest),
    ];
    var y = front.top - d + 4;
    for (final (label, value, tone) in rows) {
      final l = _text(label, size: 9.5, color: AppColors.ink3);
      inkLabel(canvas, l, Offset(x, y));
      final v = _text(value, size: 15, color: tone, weight: FontWeight.w700);
      inkLabel(canvas, v, Offset(x, y + l.height + 2));
      y += l.height + v.height + 14;
    }
  }

  @override
  bool shouldRepaint(_CubePainter old) => false;
}

/// One pressure read off two different rulers.
class _ZeroPainter extends CustomPainter {
  const _ZeroPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final vacuum = size.height * 0.84;
    final atmos = size.height * 0.54;
    final point = size.height * 0.24;
    final left = size.width * 0.05;
    final right = size.width * 0.97;

    void level(double y, String label, Color tone, {bool dashed = false}) {
      final p = _stroke(tone, 2);
      if (dashed) {
        for (var x = left; x < right; x += 12) {
          canvas.drawLine(Offset(x, y), Offset(math.min(x + 7, right), y), p);
        }
      } else {
        canvas.drawLine(Offset(left, y), Offset(right, y), p);
      }
      final t = _text(label, size: 10, color: tone);
      inkLabel(canvas, t, Offset(left, y - t.height - 5));
    }

    level(vacuum, 'A PERFECT VACUUM', AppColors.ink3, dashed: true);
    level(atmos, 'THE AIR AROUND US', AppColors.ink2, dashed: true);
    level(point, 'THE POINT IN THE WATER', AppColors.charcoal);

    // both arrows run up the middle, and each label sits beside its own
    // arrow in a band where the other one has nothing drawn
    final gaugeX = size.width * 0.62;
    final absX = size.width * 0.82;

    final gauge = _stroke(AppColors.forest, 2.5);
    _arrow(canvas, Offset(gaugeX, atmos), Offset(gaugeX, point), gauge);
    final g = _text(
      'gauge',
      size: 11,
      color: AppColors.forest,
      weight: FontWeight.w700,
    );
    inkLabel(
      canvas,
      g,
      Offset(gaugeX - g.width - 9, (atmos + point) / 2 - g.height / 2),
    );

    final abs = _stroke(AppColors.ember, 2.5);
    _arrow(canvas, Offset(absX, vacuum), Offset(absX, point), abs);
    final a = _text(
      'absolute',
      size: 11,
      color: AppColors.ember,
      weight: FontWeight.w700,
    );
    // Left of its arrow, the way the gauge label sits: to the right it ran
    // into the panel edge and lost its last letter. The band it sits in is
    // below where the gauge arrow reaches, so nothing else is there.
    inkLabel(
      canvas,
      a,
      Offset(absX - a.width - 9, (vacuum + atmos) / 2 - a.height / 2),
    );

    final gap = _text(
      '101.3 kPa apart, always',
      size: 10,
      color: AppColors.ink2,
    );
    inkLabel(canvas, gap, Offset(left, vacuum + 10));
  }

  @override
  bool shouldRepaint(_ZeroPainter old) => false;
}

/// The Reynolds number as a line with three bands on it.
class _BandsPainter extends CustomPainter {
  const _BandsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.47;
    final left = size.width * 0.07;
    final right = size.width * 0.93;
    final a = left + (right - left) * 0.34;
    final b = left + (right - left) * 0.58;

    void band(double x0, double x1, Color tone, String name) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(x0, y - 15, x1, y + 15),
          const Radius.circular(8),
        ),
        Paint()..color = tone,
      );
      final n = _text(
        name,
        size: 10.5,
        color: AppColors.charcoal,
        weight: FontWeight.w700,
      );
      if (n.width < x1 - x0 - 6) {
        inkLabel(
          canvas,
          n,
          Offset((x0 + x1) / 2 - n.width / 2, y - n.height / 2),
        );
      }
    }

    band(left, a, AppColors.info.withValues(alpha: 0.45), 'LAMINAR');
    band(a + 3, b, AppColors.butter, 'IN BETWEEN');
    band(b + 3, right, AppColors.peach, 'TURBULENT');

    for (final (x, label) in [(a, '2,100'), (b, '10,000')]) {
      canvas.drawLine(
        Offset(x, y - 22),
        Offset(x, y + 18),
        _stroke(AppColors.charcoal, 1.6),
      );
      final t = _text(
        label,
        size: 10.5,
        color: AppColors.charcoal,
        weight: FontWeight.w700,
      );
      inkLabel(canvas, t, Offset(x - t.width / 2, y - 22 - t.height - 3));
    }

    final slow = _text('slow, thick, narrow', size: 9.5, color: AppColors.ink3);
    inkLabel(canvas, slow, Offset(left, y - 62));
    final fast = _text('fast, thin, wide', size: 9.5, color: AppColors.ink3);
    inkLabel(canvas, fast, Offset(right - fast.width, y - 62));

    // what each band means, one to a line so nothing can collide
    final rows = <(String, Color)>[
      ('under 2,100: the factor is just 64 over Re', AppColors.info),
      ('in between: no place to design', AppColors.ink2),
      ('over 10,000: read the Moody chart', AppColors.ember),
    ];
    var ry = y + 28;
    for (final (what, tone) in rows) {
      final w = _text(what, size: 10.5, color: tone);
      inkLabel(canvas, w, Offset(left, ry));
      ry += w.height + 4;
    }
  }

  @override
  bool shouldRepaint(_BandsPainter old) => false;
}

/// The same flow down two pipes, one twice the bore, with what the friction
/// costs drawn as a bar under each.
class _LossPainter extends CustomPainter {
  const _LossPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.16;
    final right = size.width * 0.84;

    void pipe(double y, double bore, double loss, String label, Color tone) {
      final wall = _stroke(AppColors.charcoal, 2);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset((left + right) / 2, y),
          width: right - left,
          height: bore,
        ),
        Paint()..color = AppColors.info.withValues(alpha: 0.28),
      );
      canvas.drawLine(
        Offset(left, y - bore / 2),
        Offset(right, y - bore / 2),
        wall,
      );
      canvas.drawLine(
        Offset(left, y + bore / 2),
        Offset(right, y + bore / 2),
        wall,
      );
      _arrow(
        canvas,
        Offset(left + 12, y),
        Offset(left + 52, y),
        _stroke(AppColors.charcoal, 2),
      );

      // what it costs, as a bar
      final barTop = y + bore / 2 + 8;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, barTop, (right - left) * loss, 11),
          const Radius.circular(5),
        ),
        Paint()..color = tone,
      );
      final t = _text(label, size: 10.5, color: AppColors.ink2);
      inkLabel(canvas, t, Offset(left, barTop + 15));
    }

    pipe(
      size.height * 0.26,
      20,
      1.0,
      'one pipe size down: all of this head',
      AppColors.ember,
    );
    pipe(
      size.height * 0.70,
      40,
      0.031,
      'twice the bore: about a thirtieth of it',
      AppColors.forest,
    );
  }

  @override
  bool shouldRepaint(_LossPainter old) => false;
}

/// A run of pipe with fittings on it, and the total head drawn as the pipe
/// plus each fitting stacked up.
class _AddUpPainter extends CustomPainter {
  const _AddUpPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.30;
    final left = size.width * 0.08;
    final right = size.width * 0.92;
    final bore = 18.0;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset((left + right) / 2, y),
        width: right - left,
        height: bore,
      ),
      Paint()..color = AppColors.info.withValues(alpha: 0.28),
    );
    final wall = _stroke(AppColors.charcoal, 2);
    canvas.drawLine(
      Offset(left, y - bore / 2),
      Offset(right, y - bore / 2),
      wall,
    );
    canvas.drawLine(
      Offset(left, y + bore / 2),
      Offset(right, y + bore / 2),
      wall,
    );

    // three fittings sitting on the run
    final spots = <(double, String)>[
      (0.26, 'bend'),
      (0.52, 'valve'),
      (0.78, 'tee'),
    ];
    for (final (t, name) in spots) {
      final x = left + (right - left) * t;
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: 13, height: bore + 12),
        Paint()..color = AppColors.ember,
      );
      final l = _text(name, size: 9.5, color: AppColors.charcoal);
      inkLabel(
        canvas,
        l,
        Offset(x - l.width / 2, y - bore / 2 - 10 - l.height),
      );
    }

    // the total, stacked
    final barY = size.height * 0.66;
    final full = right - left;
    final parts = <(double, Color, String)>[
      (0.46, AppColors.info, 'the pipe'),
      (0.14, AppColors.ember, 'bend'),
      (0.28, AppColors.ember.withValues(alpha: 0.72), 'valve'),
      (0.12, AppColors.ember.withValues(alpha: 0.46), 'tee'),
    ];
    var x = left;
    for (final (share, tone, name) in parts) {
      final w = full * share;
      canvas.drawRect(Rect.fromLTWH(x, barY, w, 20), Paint()..color = tone);
      final l = _text(name, size: 9.5, color: AppColors.charcoal);
      if (l.width < w - 4) {
        inkLabel(canvas, l, Offset(x + w / 2 - l.width / 2, barY + 24));
      }
      x += w;
    }
    canvas.drawRect(
      Rect.fromLTWH(left, barY, full, 20),
      _stroke(AppColors.charcoal, 1.6),
    );
    final total = _text(
      'the total head: all four added',
      size: 10.5,
      color: AppColors.charcoal,
      weight: FontWeight.w700,
    );
    inkLabel(canvas, total, Offset(left, barY - total.height - 6));
  }

  @override
  bool shouldRepaint(_AddUpPainter old) => false;
}

/// One jet at three targets, with the push it delivers under each.
class _ThreeFacesPainter extends CustomPainter {
  const _ThreeFacesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const faces = <(Face, String)>[
      (Face.through, 'nothing'),
      (Face.plate, 'all of it'),
      (Face.cup, 'twice over'),
    ];
    final row = size.height / faces.length;
    for (final (i, (face, words)) in faces.indexed) {
      canvas.save();
      canvas.translate(0, row * i);
      HitPainter(
        hit: Hit(face: face),
        biggest: 2,
        showPush: true,
      ).paint(canvas, Size(size.width * 0.70, row));
      final t = _text(
        words,
        size: 12,
        color: i == 0 ? AppColors.ink2 : AppColors.ember,
        weight: FontWeight.w700,
      );
      inkLabel(canvas, t, Offset(size.width * 0.745, row / 2 - t.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ThreeFacesPainter old) => false;
}

/// Four common slips, and which way each pushes the flow you report.
class _SlipPainter extends CustomPainter {
  const _SlipPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const rows = <(String, bool, String)>[
      ('left the coefficient out', true, 'too big'),
      ('shrank the bit under the line', true, 'too big'),
      ('lost the 2 in front of g', false, 'a little small'),
      ('left the pressure in kPa', false, 'far too small'),
    ];
    final left = size.width * 0.07;
    final arrowX = size.width * 0.66;
    final gap = size.height / (rows.length + 0.6);
    for (final (i, (what, up, says)) in rows.indexed) {
      final y = gap * (i + 0.8);
      final t = _text(what, size: 11, color: AppColors.charcoal);
      inkLabel(canvas, t, Offset(left, y - t.height / 2));
      final tone = up ? AppColors.ember : AppColors.info;
      _arrow(
        canvas,
        Offset(arrowX, y + (up ? 9 : -9)),
        Offset(arrowX, y + (up ? -9 : 9)),
        _stroke(tone, 2.6),
      );
      final s = _text(says, size: 11, color: tone, weight: FontWeight.w700);
      inkLabel(canvas, s, Offset(arrowX + 14, y - s.height / 2));
    }
  }

  @override
  bool shouldRepaint(_SlipPainter old) => false;
}

/// Every picture on this chapter's sheets, by the contact sheet's card name.
const fluidmechanicsPictures = <String, Widget Function()>{
  'three-numbers': threeNumbersPicture,
  'viscosity': viscosityPicture,
  'capillary': capillaryPicture,
  'depth': depthPicture,
  'gauge': gaugePicture,
  'manometer': manometerPicture,
  'gate': gatePicture,
  'buoyancy': buoyancyPicture,
  'continuity': continuityPicture,
  'bernoulli': bernoulliPicture,
  'torricelli': torricelliPicture,
  'reynolds': reynoldsPicture,
  'darcy': darcyPicture,
  'minor': minorPicture,
  'deflection': deflectionPicture,
  'thrust': thrustPicture,
  'block': blockPicture,
  'metering': meteringPicture,
  'coefficient': coefficientPicture,
  'similitude': similitudePicture,
  'scaling': scalingPicture,
};
