// The pictures on the Dynamics concept sheets.
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
import 'collision_figures.dart';
import 'energy_figures.dart';
import 'kinematics_figures.dart';
import 'kinetics_figures.dart';
import 'mechanics_pictures.dart' show ConceptPicture, ConceptPair;
import 'rotation_figures.dart';
import 'vibration_figures.dart';

// ---------------------------------------------------------------------------
// Particle kinematics

Widget missingPicture() => const ConceptPicture(
  painter: _FiveThingsPainter(),
  caption:
      'five things describe the trip. This problem never mentions time, so use the equation without it',
  height: 180,
);

Widget flightPicture() => const ConceptPicture(
  painter: FlightPainter(
    flight: Flight(speed: 30, degrees: 55),
    moments: Moment.values,
    locked: true,
    showVelocities: true,
  ),
  caption:
      'a thrown ball. The across arrow never changes; the up and down arrow shrinks to nothing at the top',
  height: 230,
);

Widget bendPicture() => const ConceptPicture(
  painter: BendPainter(
    bend: Bend(speed: 20, radius: 60, alongRoad: 2),
    show: Piece.values,
    locked: true,
  ),
  caption:
      'a car on a bend, seen from above. One arrow speeds it up, the other turns it',
  height: 230,
);

// ---------------------------------------------------------------------------
// Rigid body kinematics and mass moment of inertia

Widget spinPicture() => const ConceptPicture(
  painter: SpinnerPainter(
    spinner: Spinner(
      rpm: 600,
      radius: 0.3,
      marks: [(0.3, 20), (0.2, 150), (0.1, 265)],
    ),
    locked: true,
    arm: true,
  ),
  caption:
      'one spinning wheel, three dots on it. They all go round together, and the outer one travels furthest',
  height: 230,
);

Widget spinInertiaPicture() => const ConceptPair(
  left: BodyPainter(
    body: Body(kind: Shape3.hoop, mass: 2, radius: 0.3),
    frame: 0.33,
    label: 'hoop',
  ),
  right: BodyPainter(
    body: Body(kind: Shape3.disc, mass: 2, radius: 0.3),
    frame: 0.33,
    label: 'disc',
  ),
  leftCaption: 'same weight, all of it at the rim: hardest to spin up',
  rightCaption: 'same weight, spread in toward the middle: half as hard',
  height: 200,
);

// ---------------------------------------------------------------------------
// Force and acceleration

Widget weightPicture() => const ConceptPicture(
  painter: _MassOrWeightPainter(),
  caption:
      'one block. How much stuff it is made of, and how hard gravity pulls on it, are two different numbers',
  height: 190,
);

Widget slopePicture() => const ConceptPicture(
  painter: SlopePainter2(
    slope: Slope2(degrees: 30, weight: 500),
    arrows: [Arrow.weight, Arrow.along, Arrow.square],
    locked: true,
  ),
  caption:
      'a block on a ramp. Its weight points straight down and splits into a piece along the ramp and a piece into it',
  height: 220,
);

Widget twoEquationsPicture() => const ConceptPair(
  left: PushPainter(
    pushed: Pushed(round: true, held: Held2.axle, lands: Lands.rim),
  ),
  right: PushPainter(
    pushed: Pushed(round: false, held: Held2.free, lands: Lands.middle),
  ),
  leftCaption: 'pinned on an axle: it can only spin',
  rightCaption: 'pushed through its middle: it can only slide',
  height: 200,
);

// ---------------------------------------------------------------------------
// Work, energy and power

Widget ledgerPicture() => const ConceptPicture(
  painter: LedgerPainter(
    ledger: Ledger(heightStart: 100, movingEnd: 70, gone: 30),
    tallest: 100,
  ),
  caption:
      'before and after, as two stacks. Height turned into movement, and a rough patch took the rest',
  height: 210,
);

Widget cancelPicture() => const ConceptPicture(
  painter: _SameSpeedPainter(),
  caption:
      'a heavy block and a light one down the same smooth ramp. They reach the bottom at the same speed',
  height: 200,
);

Widget powerPicture() => const ConceptPicture(
  painter: _EfficiencyPainter(),
  caption: 'a motor always takes in more than it gives out',
  height: 190,
);

// ---------------------------------------------------------------------------
// Impulse and momentum

Widget impactPicture() => const ConceptPair(
  left: CrashPainter(
    crash: Crash(massA: 2, massB: 3, speedA: 6, e: 0),
    showAfter: true,
  ),
  right: CrashPainter(
    crash: Crash(massA: 2, massB: 3, speedA: 6, e: 1),
    showAfter: true,
  ),
  leftCaption: 'they stick and travel on as one lump',
  rightCaption: 'they bounce apart, each with its own speed',
  height: 200,
);

Widget survivesPicture() => const ConceptPicture(
  painter: CrashPainter(
    crash: Crash(massA: 2, massB: 3, speedA: 6, e: 0),
    showAfter: true,
  ),
  caption:
      'before and after a crash where they stick. Add the two momentums and the total has not changed',
  height: 200,
);

Widget impulsePicture() => const ConceptPair(
  left: PulsePainter(
    pulse: Pulse(force: 300, seconds: 0.1, label: 'rigid'),
    tallest: 300,
    longest: 0.3,
  ),
  right: PulsePainter(
    pulse: Pulse(force: 100, seconds: 0.3, label: 'crumple'),
    tallest: 300,
    longest: 0.3,
    tone: AppColors.ember,
  ),
  leftCaption: 'stopped fast: a huge force for a moment',
  rightCaption: 'stopped slowly: the same shaded area, a third of the force',
  height: 200,
);

// ---------------------------------------------------------------------------
// Vibrations

Widget naturalPicture() => const ConceptPair(
  left: SpringPainter(
    bouncer: Bouncer(mass: 2, stiffness: 800),
    frame: (8, 800),
    label: 'light block',
  ),
  right: SpringPainter(
    bouncer: Bouncer(mass: 8, stiffness: 800),
    frame: (8, 800),
    label: 'heavy block',
  ),
  leftCaption: 'same spring, light block: it bounces quickly',
  rightCaption: 'same spring, four times the weight: half the rate',
  height: 220,
);

Widget resonancePicture() => const ConceptPicture(
  painter: _ResonancePainter(),
  caption:
      'how big the swing gets, against how fast you shake it. Only one rate blows up',
  height: 210,
);

Widget dampingPicture() {
  Widget one(Damped d, String caption) => Expanded(
    child: ConceptPicture(
      painter: SettlePainter(damped: d),
      caption: caption,
      height: 140,
    ),
  );
  return Column(
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          one(Damped.none, '1. none: swings for ever'),
          const SizedBox(width: 10),
          one(Damped.under, '2. a little: swings, dies away'),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          one(Damped.critical, '3. just enough: straight back'),
          const SizedBox(width: 10),
          one(Damped.over, '4. too much: back, but slower'),
        ],
      ),
    ],
  );
}

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

/// The five quantities of straight line motion, with the absent one struck
/// out. The whole skill of the item is spotting which one is missing.
class _FiveThingsPainter extends CustomPainter {
  const _FiveThingsPainter();

  static const _labels = [
    ('v0', 'start'),
    ('v', 'end'),
    ('s', 'distance'),
    ('t', 'time'),
    ('a', 'speeding up'),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const absent = 3; // time
    final gap = 8.0;
    final w = math.min(58.0, (size.width - 24 - gap * 4) / 5);
    final total = w * 5 + gap * 4;
    final left = (size.width - total) / 2;
    final top = size.height * 0.30;
    for (var i = 0; i < 5; i++) {
      final box = Rect.fromLTWH(left + i * (w + gap), top, w, w);
      final out = i == absent;
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, const Radius.circular(12)),
        Paint()..color = out ? AppColors.creamDark : AppColors.charcoal,
      );
      if (out) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(box, const Radius.circular(12)),
          _stroke(AppColors.ember, 2),
        );
      }
      final sym = _text(
        _labels[i].$1,
        size: 17,
        color: out ? AppColors.ember : AppColors.cream,
      );
      sym.paint(
        canvas,
        Offset(
          box.center.dx - sym.width / 2,
          box.center.dy - sym.height / 2 - 1,
        ),
      );
      final name = _text(_labels[i].$2, size: 9.5);
      name.paint(
        canvas,
        Offset(box.center.dx - name.width / 2, box.bottom + 7),
      );
      if (out) {
        final cross = _stroke(AppColors.ember, 2.5);
        canvas.drawLine(
          Offset(box.left + 10, box.top + 10),
          Offset(box.right - 10, box.bottom - 10),
          cross,
        );
        canvas.drawLine(
          Offset(box.right - 10, box.top + 10),
          Offset(box.left + 10, box.bottom - 10),
          cross,
        );
      }
    }
    final head = _text('the problem gives you four of these', size: 11);
    head.paint(canvas, Offset(size.width / 2 - head.width / 2, top - 26));
    final foot = _text(
      'this one is never mentioned',
      size: 11,
      color: AppColors.ember,
    );
    foot.paint(canvas, Offset(size.width / 2 - foot.width / 2, top + w + 30));
  }

  @override
  bool shouldRepaint(_FiveThingsPainter old) => false;
}

/// One block, labelled with its mass and with its weight.
class _MassOrWeightPainter extends CustomPainter {
  const _MassOrWeightPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final ground = size.height * 0.62;
    final box = Rect.fromCenter(
      center: Offset(size.width * 0.42, ground - 32),
      width: 96,
      height: 64,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(8)),
      Paint()..color = AppColors.charcoal,
    );
    final mass = _text('50 kg', size: 16, color: AppColors.cream);
    mass.paint(
      canvas,
      Offset(box.center.dx - mass.width / 2, box.center.dy - mass.height / 2),
    );
    canvas.drawLine(
      Offset(size.width * 0.08, ground),
      Offset(size.width * 0.72, ground),
      _stroke(AppColors.ink2, 1.5),
    );
    final note = _text('how much stuff it is made of', size: 10.5);
    note.paint(canvas, Offset(box.left - 14, ground + 10));

    // the pull of gravity on it
    final pull = _stroke(AppColors.ember, 3);
    _arrow(
      canvas,
      Offset(box.center.dx, box.bottom + 2),
      Offset(box.center.dx, ground + 52),
      pull,
    );
    final w = _text('490 N', size: 16, color: AppColors.ember);
    w.paint(canvas, Offset(box.center.dx + 12, ground + 26));
    final note2 = _text(
      'how hard gravity pulls it down',
      size: 10.5,
      color: AppColors.ember,
    );
    note2.paint(canvas, Offset(box.center.dx + 12, ground + 46));
  }

  @override
  bool shouldRepaint(_MassOrWeightPainter old) => false;
}

/// A heavy block and a light one on the same ramp, arriving together.
class _SameSpeedPainter extends CustomPainter {
  const _SameSpeedPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final base = size.height * 0.74;
    final left = size.width * 0.10;
    final right = size.width * 0.92;
    final top = size.height * 0.20;
    final ramp = Path()
      ..moveTo(left, top)
      ..lineTo(right, base)
      ..lineTo(left, base)
      ..close();
    canvas.drawPath(ramp, Paint()..color = AppColors.creamDark);
    canvas.drawLine(
      Offset(left, top),
      Offset(right, base),
      _stroke(AppColors.charcoal, 2),
    );
    canvas.drawLine(
      Offset(left, base),
      Offset(right, base),
      _stroke(AppColors.ink2, 1.5),
    );

    // two blocks partway down, on the slope, one twice the other
    final dx = right - left;
    final dy = base - top;
    final len = math.sqrt(dx * dx + dy * dy);
    final along = Offset(dx / len, dy / len);
    final up = Offset(-along.dy, along.dx) * -1;
    void block(double t, double side, String label) {
      final on = Offset(left, top) + along * (len * t);
      final c = on + up * (side / 2 + 1);
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(math.atan2(dy, dx));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: side, height: side),
          const Radius.circular(5),
        ),
        Paint()..color = AppColors.charcoal,
      );
      canvas.restore();
      final t2 = _text(label, size: 10.5);
      t2.paint(canvas, Offset(c.dx - t2.width / 2, c.dy - side / 2 - 18));
    }

    block(0.20, 38, 'heavy');
    block(0.52, 22, 'light');

    // the same speed at the bottom
    final speed = _stroke(AppColors.ember, 3);
    for (final y in [base + 12.0, base + 30.0]) {
      _arrow(canvas, Offset(right - 74, y), Offset(right - 6, y), speed);
    }
    final same = _text(
      'same speed at the bottom',
      size: 11,
      color: AppColors.ember,
    );
    same.paint(canvas, Offset(right - 74 - same.width - 10, base + 12));
  }

  @override
  bool shouldRepaint(_SameSpeedPainter old) => false;
}

/// What goes into a machine, what comes out, and what is lost on the way.
class _EfficiencyPainter extends CustomPainter {
  const _EfficiencyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height * 0.56;
    final box = Rect.fromCenter(
      center: Offset(size.width * 0.5, mid),
      width: 92,
      height: 62,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(10)),
      Paint()..color = AppColors.charcoal,
    );
    final name = _text('motor', size: 13, color: AppColors.cream);
    name.paint(
      canvas,
      Offset(box.center.dx - name.width / 2, box.center.dy - name.height / 2),
    );

    // in: a wide band
    void band(Offset from, Offset to, double thick, Color color) {
      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = color
          ..strokeWidth = thick
          ..strokeCap = StrokeCap.butt,
      );
      _arrow(canvas, to - Offset(10, 0), to, _stroke(color, 3));
    }

    band(
      Offset(size.width * 0.06, mid),
      Offset(box.left - 6, mid),
      26,
      AppColors.ember,
    );
    band(
      Offset(box.right + 6, mid),
      Offset(size.width * 0.94, mid),
      18,
      AppColors.forest,
    );

    final inLabel = _text('10 kW in', size: 11.5, color: AppColors.ember);
    inLabel.paint(canvas, Offset(size.width * 0.06, mid - 32));
    final outLabel = _text('7 kW out', size: 11.5, color: AppColors.forest);
    outLabel.paint(
      canvas,
      Offset(size.width * 0.94 - outLabel.width, mid - 30),
    );

    // lost, out of the top
    final lost = _stroke(AppColors.ink2, 3);
    _arrow(
      canvas,
      Offset(box.center.dx, box.top - 4),
      Offset(box.center.dx, box.top - 34),
      lost,
    );
    final lostLabel = _text('3 kW lost as heat', size: 10.5);
    lostLabel.paint(
      canvas,
      Offset(box.center.dx - lostLabel.width / 2, box.top - 54),
    );
  }

  @override
  bool shouldRepaint(_EfficiencyPainter old) => false;
}

/// How big a swing gets, against how fast the thing is being shaken.
class _ResonancePainter extends CustomPainter {
  const _ResonancePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.13;
    final right = size.width * 0.93;
    final base = size.height * 0.80;
    final top = size.height * 0.16;
    final axis = _stroke(AppColors.ink2, 1.5);
    canvas.drawLine(Offset(left, base), Offset(right, base), axis);
    canvas.drawLine(Offset(left, base), Offset(left, top), axis);

    // the peak sits at the system's own rate
    final peakX = left + (right - left) * 0.46;
    canvas.drawLine(
      Offset(peakX, base),
      Offset(peakX, top - 2),
      Paint()
        ..color = AppColors.ink3
        ..strokeWidth = 1.5,
    );

    final path = Path();
    const damping = 0.10;
    for (var i = 0; i <= 120; i++) {
      final t = i / 120;
      final x = left + (right - left) * t;
      // one over the distance from the peak, softened, so it rises to a
      // spike at the natural rate and falls away on both sides
      final r = t / 0.46;
      final denom = math.sqrt(
        math.pow(1 - r * r, 2) + math.pow(2 * damping * r, 2),
      );
      final amp = (1 / denom).clamp(0.0, 5.2) / 5.2;
      final y = base - (base - top) * amp;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, _stroke(AppColors.ember, 3));

    final own = _text('its own rate', size: 11, color: AppColors.charcoal);
    own.paint(canvas, Offset(peakX - own.width / 2, top - 20));
    final xa = _text('how fast you shake it', size: 10.5);
    xa.paint(canvas, Offset(right - xa.width, base + 8));
    final ya = _text('how big the swing', size: 10.5);
    ya.paint(canvas, Offset(left - 4, top - 18));
    final safeL = _text('safe', size: 10.5);
    safeL.paint(canvas, Offset(left + 12, base - 24));
    final safeR = _text('safe', size: 10.5);
    safeR.paint(canvas, Offset(right - safeR.width - 14, base - 24));
  }

  @override
  bool shouldRepaint(_ResonancePainter old) => false;
}

/// Every picture on this chapter's sheets, by the contact sheet's card name.
const dynamicsPictures = <String, Widget Function()>{
  'missing': missingPicture,
  'flight': flightPicture,
  'bend': bendPicture,
  'spin': spinPicture,
  'spin-inertia': spinInertiaPicture,
  'weight': weightPicture,
  'slope': slopePicture,
  'two-equations': twoEquationsPicture,
  'ledger': ledgerPicture,
  'cancel': cancelPicture,
  'power': powerPicture,
  'impact': impactPicture,
  'survives': survivesPicture,
  'impulse': impulsePicture,
  'natural': naturalPicture,
  'resonance': resonancePicture,
  'damping': dampingPicture,
};
