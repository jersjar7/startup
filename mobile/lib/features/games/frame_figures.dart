import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'beam_figures.dart' show Prop;

/// One pin of a frame, where members meet and loads are applied.
@immutable
class Pin {
  const Pin(this.name, this.at);

  final String name;

  /// In world units, y upward.
  final Offset at;
}

/// One member. What matters about it is how many places something touches it,
/// because that and nothing else decides whether it is a two-force member.
@immutable
class Limb {
  const Limb({
    required this.from,
    required this.to,
    this.bend,
    this.via = const [],
    this.loads = const [],
    this.cable = false,
  });

  final int from;
  final int to;

  /// A knee: the member is drawn through here instead of straight. It changes
  /// how the member LOOKS and nothing about where its force acts, which is a
  /// distinction the exam is fond of.
  final Offset? bend;

  /// Other pins fastened to it between its ends.
  final List<int> via;

  /// Fractions along it where a load is applied.
  final List<double> loads;

  final bool cable;

  /// How many separate places something acts on this member.
  int get touched => 2 + via.length + loads.length;

  /// Loaded at exactly two points and nowhere else, which is the only thing
  /// that puts a member's force along the line joining its ends.
  bool get twoForce => touched == 2;
}

/// What the assembly is called.
enum Kind { truss, frame, machine }

/// A frame, a truss or a machine: pins, members, and what is done to it.
@immutable
class Assembly {
  const Assembly({
    required this.pins,
    required this.limbs,
    this.supports = const {},
    this.pinLoads = const {},
    this.moves = false,
  });

  final List<Pin> pins;
  final List<Limb> limbs;
  final Map<int, Prop> supports;

  /// Loads hung at a PIN. These never make a member multi-force: the pin
  /// carries them, and every member meeting there is still touched only at
  /// its own two ends.
  final Map<int, String> pinLoads;

  /// Whether parts of it move relative to each other, which is the whole of
  /// what separates a machine from a frame.
  final bool moves;

  String limbName(int i) =>
      '${pins[limbs[i].from].name}${pins[limbs[i].to].name}';

  /// Worked out from the members, never declared beside the assembly.
  Kind get kind {
    if (moves) return Kind.machine;
    if (limbs.any((l) => !l.twoForce)) return Kind.frame;
    return Kind.truss;
  }

  /// The line joining a member's two ends, which is where a two-force
  /// member's force acts whatever shape the member itself is.
  Offset lineOf(int limb) {
    final l = limbs[limb];
    final run = pins[l.to].at - pins[l.from].at;
    return run / run.distance;
  }

  /// The direction the member itself leaves a pin, which for a bent member is
  /// not the same thing at all.
  Offset limbLeaving(int limb, int pin) {
    final l = limbs[limb];
    final next = l.bend ?? (pin == l.from ? pins[l.to].at : pins[l.from].at);
    final run = next - pins[pin].at;
    return run / run.distance;
  }

  Rect get bounds {
    var box = Rect.fromCircle(center: pins.first.at, radius: 0.001);
    void take(Offset p) =>
        box = box.expandToInclude(Rect.fromCircle(center: p, radius: 0.001));
    for (final p in pins) {
      take(p.at);
    }
    for (final l in limbs) {
      if (l.bend != null) take(l.bend!);
    }
    return box;
  }
}

/// One candidate direction for a pin force, named by what it lines up with
/// rather than by an angle, so the drawing works it out from the geometry and
/// a round cannot offer an arrow that means something else.
enum Aim {
  /// Along the straight line joining the member's two ends.
  alongTheLine,

  /// Along the member as drawn, which on a bent member points somewhere else.
  alongTheLimb,

  /// Square to the line joining the ends.
  square,

  /// Neither one thing nor the other.
  oblique,
}

class FramePainter extends CustomPainter {
  const FramePainter({
    required this.rig,
    this.spotlight = -1,
    this.atPin = -1,
    this.aims = const [],
    this.picked,
    this.truth = -1,
    this.locked = false,
  });

  final Assembly rig;

  /// The member the round is asking about.
  final int spotlight;

  /// The pin whose force is in question, and the arrows offered there.
  final int atPin;
  final List<Aim> aims;
  final int? picked;
  final int truth;
  final bool locked;

  /// Room round the drawing for what is hung off it. Never a fixed number
  /// where a measurement belongs: a load hanging under a bottom chord needs
  /// its arrow AND its label below the structure, and without that the label
  /// is cut in half by the edge of the figure.
  static EdgeInsets _roomFor(Assembly rig) {
    var below = 38.0;
    for (final p in rig.pinLoads.keys) {
      if (rig.pins[p].at.dy <= rig.bounds.center.dy) below = 76;
    }
    for (final l in rig.limbs) {
      if (l.loads.isEmpty) continue;
      if (rig.pins[l.from].at.dy <= rig.bounds.center.dy &&
          rig.pins[l.to].at.dy <= rig.bounds.center.dy) {
        below = math.max(below, 62);
      }
    }
    return EdgeInsets.fromLTRB(30, 42, 30, below);
  }

  /// How far a candidate arrow reaches, as a share of the drawing rather than
  /// a pixel count, so it scales with whatever it is drawn on.
  static double _reach(Assembly rig) =>
      0.34 * math.max(rig.bounds.width, rig.bounds.height);

  /// Which way a candidate arrow points, in world terms.
  ///
  /// Worked out from the drawing rather than declared, so an arrow labelled
  /// "along the line" really does lie along it, and on a bent member it lands
  /// somewhere different from the arrow that follows the member.
  static Offset heading(Assembly rig, int limb, int pin, Aim aim) {
    final l = rig.limbs[limb];
    // Every arrow points OUT of the pin, away from the member it belongs to,
    // which is how a force is drawn on a free body and also the only place
    // there is clear paper. Pointed inward, the along-the-line arrow lies
    // down the middle of its own member and cannot be seen.
    final line = rig.lineOf(limb);
    final away = pin == l.to ? line : -line;

    // Which side to turn toward, chosen to be the emptier one: the arrows all
    // leave the pin outward, so their turned versions belong outward too
    // rather than laid back across the structure.
    final outward = rig.pins[pin].at - rig.bounds.center;
    final perp = Offset(-away.dy, away.dx);
    final double sign;
    if (rig.pinLoads.containsKey(pin)) {
      // A load arrow already owns the space straight above this pin, and its
      // own label sits above that. Turn the other way.
      sign = perp.dy > 0 ? -1.0 : 1.0;
    } else {
      sign = perp.dx * outward.dx + perp.dy * outward.dy >= 0 ? 1.0 : -1.0;
    }

    Offset turn(double degrees) {
      final t = sign * degrees * math.pi / 180;
      return Offset(
        away.dx * math.cos(t) - away.dy * math.sin(t),
        away.dx * math.sin(t) + away.dy * math.cos(t),
      );
    }

    switch (aim) {
      case Aim.alongTheLine:
        return away;
      case Aim.alongTheLimb:
        return -rig.limbLeaving(limb, pin);
      case Aim.square:
        return turn(90);
      case Aim.oblique:
        return turn(45);
    }
  }

  /// The world the figure has to hold: the structure, and every arrow drawn
  /// off it. Framed to the structure alone, an arrow at a corner pin runs
  /// straight off the side of the box.
  static Rect _frame(Assembly rig, int limb, int pin, List<Aim> aims) {
    var box = rig.bounds;
    if (limb < 0 || pin < 0) return box;
    final reach = _reach(rig);
    for (final aim in aims) {
      final tip = rig.pins[pin].at + heading(rig, limb, pin, aim) * reach;
      box = box.expandToInclude(Rect.fromCircle(center: tip, radius: 0.001));
    }
    return box;
  }

  static Offset toScreen(Assembly rig, Offset world, Size size,
      {int limb = -1, int pin = -1, List<Aim> aims = const []}) {
    final b = _frame(rig, limb, pin, aims);
    final room = _roomFor(rig);
    final s = math.min(
      (size.width - room.horizontal) / math.max(b.width, 0.001),
      (size.height - room.vertical) / math.max(b.height, 0.001),
    );
    return Offset(
      room.left + (size.width - room.horizontal - b.width * s) / 2 +
          (world.dx - b.left) * s,
      room.top + (size.height - room.vertical - b.height * s) / 2 +
          (b.bottom - world.dy) * s,
    );
  }

  /// Where a candidate arrow finishes, which is where it is tapped.
  static Offset aimTip(Assembly rig, Size size, int limb, int pin,
      List<Aim> aims, int index) {
    final tip = rig.pins[pin].at + heading(rig, limb, pin, aims[index]) * _reach(rig);
    return toScreen(rig, tip, size, limb: limb, pin: pin, aims: aims);
  }

  @override
  void paint(Canvas canvas, Size size) {
    Offset at(Offset w) =>
        toScreen(rig, w, size, limb: spotlight, pin: atPin, aims: aims);

    for (var i = 0; i < rig.limbs.length; i++) {
      final l = rig.limbs[i];
      final lit = i == spotlight;
      final paint = Paint()
        ..color = lit ? AppColors.ember : AppColors.ink2
        ..strokeWidth = lit ? 5 : 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(at(rig.pins[l.from].at).dx, at(rig.pins[l.from].at).dy);
      if (l.bend != null) path.lineTo(at(l.bend!).dx, at(l.bend!).dy);
      path.lineTo(at(rig.pins[l.to].at).dx, at(rig.pins[l.to].at).dy);
      if (l.cable) {
        _dashed(canvas, path, paint);
      } else {
        canvas.drawPath(path, paint);
      }
    }

    // Loads carried between a member's ends, which are the whole reason a
    // member stops being two-force.
    for (var i = 0; i < rig.limbs.length; i++) {
      final l = rig.limbs[i];
      for (final f in l.loads) {
        final spot = _alongLimb(i, f, size);
        _hang(canvas, spot, _low(l.from, l.to));
      }
    }

    final taken = <Rect>[];
    for (var p = 0; p < rig.pins.length; p++) {
      final spot = at(rig.pins[p].at);
      canvas.drawCircle(spot, 5.5, Paint()..color = AppColors.cream);
      canvas.drawCircle(
        spot,
        5.5,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
      final support = rig.supports[p];
      if (support != null) _support(canvas, spot, support);
      final load = rig.pinLoads[p];
      if (load != null) {
        final under = _low(p, p);
        _hang(canvas, spot, under);
        taken.add(_write(canvas, load, spot + Offset(0, under ? 50 : -60),
            AppColors.charcoal, size, taken));
      }
    }

    if (rig.moves) _movingMark(canvas, size);

    for (var i = 0; i < aims.length; i++) {
      final root = at(rig.pins[atPin].at);
      final tip = at(rig.pins[atPin].at +
          heading(rig, spotlight, atPin, aims[i]) * _reach(rig));
      final run = tip - root;
      final head = run / run.distance;
      final chosen = picked == i;
      final isTruth = locked && i == truth;
      final Color colour;
      if (isTruth) {
        colour = AppColors.forest;
      } else if (locked && chosen) {
        colour = AppColors.error;
      } else if (chosen) {
        colour = AppColors.ember;
      } else {
        colour = AppColors.info;
      }
      _arrow(canvas, root + head * 11, tip, colour, heavy: chosen || isTruth);
      taken.add(_write(canvas, '${i + 1}',
          tip + head * 13 - const Offset(0, 6), colour, size, taken));
    }
  }

  /// Whether something hung here belongs UNDER the structure. A load drawn
  /// above a bottom chord sends its shaft down through the middle of the
  /// truss and across whatever it meets on the way.
  bool _low(int a, int b) {
    final middle = rig.bounds.center.dy;
    return rig.pins[a].at.dy <= middle && rig.pins[b].at.dy <= middle;
  }

  void _hang(Canvas canvas, Offset spot, bool under) {
    if (under) {
      _arrow(canvas, spot + const Offset(0, 8), spot + const Offset(0, 44),
          AppColors.charcoal);
    } else {
      _arrow(canvas, spot - const Offset(0, 44), spot - const Offset(0, 8),
          AppColors.charcoal);
    }
  }

  /// A machine is a machine because parts of it move, and that is the whole
  /// of what the third item asks. Said in the drawing as well as in the words.
  void _movingMark(Canvas canvas, Size size) {
    final middle = toScreen(rig, rig.bounds.center, size,
        limb: spotlight, pin: atPin, aims: aims);
    final r = math.min(size.width, size.height) * 0.075;
    final ink = Paint()
      ..color = AppColors.ember
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCircle(center: middle, radius: r), -2.5, 2.1,
        false, ink);
    for (final (angle, way) in [(-2.5, -1.0), (-0.4, 1.0)]) {
      final tip = middle + Offset(math.cos(angle), math.sin(angle)) * r;
      final along =
          Offset(-math.sin(angle), math.cos(angle)) * way;
      final side = Offset(-along.dy, along.dx);
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(tip.dx - along.dx * 9 + side.dx * 4.5,
              tip.dy - along.dy * 9 + side.dy * 4.5)
          ..lineTo(tip.dx - along.dx * 9 - side.dx * 4.5,
              tip.dy - along.dy * 9 - side.dy * 4.5)
          ..close(),
        Paint()..color = AppColors.ember,
      );
    }
  }

  Offset _alongLimb(int limb, double fraction, Size size) {
    final l = rig.limbs[limb];
    Offset at(Offset w) =>
        toScreen(rig, w, size, limb: spotlight, pin: atPin, aims: aims);
    final a = at(rig.pins[l.from].at);
    final b = at(rig.pins[l.to].at);
    if (l.bend == null) return a + (b - a) * fraction;
    final knee = at(l.bend!);
    return fraction < 0.5
        ? a + (knee - a) * (fraction * 2)
        : knee + (b - knee) * ((fraction - 0.5) * 2);
  }

  void _dashed(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 9) {
        canvas.drawPath(
          metric.extractPath(d, math.min(d + 5, metric.length)),
          paint,
        );
      }
    }
  }

  void _support(Canvas canvas, Offset p, Prop kind) {
    final ink = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(p.dx, p.dy + 4)
        ..lineTo(p.dx - 9, p.dy + 17)
        ..lineTo(p.dx + 9, p.dy + 17)
        ..close(),
      ink,
    );
    var base = p.dy + 17;
    if (kind == Prop.roller) {
      canvas.drawCircle(Offset(p.dx - 5, p.dy + 21), 3.5, ink);
      canvas.drawCircle(Offset(p.dx + 5, p.dy + 21), 3.5, ink);
      base = p.dy + 25;
    }
    canvas.drawLine(Offset(p.dx - 15, base), Offset(p.dx + 15, base), ink);
    for (var h = p.dx - 10; h < p.dx + 16; h += 6) {
      canvas.drawLine(Offset(h, base), Offset(h - 4, base + 5), ink);
    }
  }

  void _arrow(Canvas canvas, Offset from, Offset to, Color colour,
      {bool heavy = false}) {
    final paint = Paint()
      ..color = colour
      ..strokeWidth = heavy ? 3.6 : 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);
    final run = to - from;
    if (run.distance < 1) return;
    final unit = run / run.distance;
    final side = Offset(-unit.dy, unit.dx);
    final back = heavy ? 11.0 : 9.0;
    final wide = heavy ? 5.5 : 4.5;
    canvas.drawPath(
      Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo(to.dx - unit.dx * back + side.dx * wide,
            to.dy - unit.dy * back + side.dy * wide)
        ..lineTo(to.dx - unit.dx * back - side.dx * wide,
            to.dy - unit.dy * back - side.dy * wide)
        ..close(),
      Paint()..color = colour,
    );
  }

  Rect _write(Canvas canvas, String text, Offset at, Color colour, Size size,
      List<Rect> avoid) {
    final tp = TextPainter(
      text: TextSpan(
          text: text, style: AppTheme.mono(size: 11.5, color: colour)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx - tp.width / 2;
    var y = at.dy;
    if (x < 2) x = 2;
    if (x + tp.width > size.width - 2) x = size.width - 2 - tp.width;
    Rect box() => Rect.fromLTWH(x - 3, y, tp.width + 6, tp.height);
    for (var tries = 0; tries < 4; tries++) {
      if (!avoid.any((r) => r.overlaps(box()))) break;
      y -= tp.height + 3;
    }
    if (y < 1) y = 1;
    if (y + tp.height > size.height - 1) y = size.height - 1 - tp.height;
    canvas.drawRect(
        box(), Paint()..color = AppColors.cream.withValues(alpha: 0.92));
    tp.paint(canvas, Offset(x, y));
    return box();
  }

  @override
  bool shouldRepaint(FramePainter old) =>
      old.rig != rig ||
      old.picked != picked ||
      old.spotlight != spotlight ||
      old.locked != locked;
}

/// What a machine does to the force you put into it.
enum Pull { multiplies, divides, neither }

/// A lever: a bar, a pivot somewhere along it, your effort at one place and
/// the load at another.
@immutable
class Lever {
  const Lever({
    required this.pivotAt,
    required this.effortAt,
    required this.loadAt,
  });

  /// Fractions along the bar, from nought at the left end to one at the right.
  final double pivotAt;
  final double effortAt;
  final double loadAt;

  double get effortArm => (effortAt - pivotAt).abs();
  double get loadArm => (loadAt - pivotAt).abs();

  /// Moments about the pivot, and nothing else: the output force is the input
  /// scaled by the ratio of the arms.
  double get advantage => effortArm / loadArm;

  /// Effort and load on the same side of the pivot, which is what makes a
  /// wheelbarrow a wheelbarrow. You then have to pull UP rather than push
  /// down, and the lever still works.
  bool get sameSide => (effortAt - pivotAt) * (loadAt - pivotAt) > 0;

  bool get effortUp => sameSide;

  /// Worked out from the two arms, never declared beside the round.
  Pull get pull {
    if ((advantage - 1).abs() < 0.03) return Pull.neither;
    return advantage > 1 ? Pull.multiplies : Pull.divides;
  }
}

class LeverPainter extends CustomPainter {
  const LeverPainter({required this.lever, this.plain = false});

  final Lever lever;

  /// Drawn small, for a button: the bar and the pivot and nothing else.
  final bool plain;

  @override
  void paint(Canvas canvas, Size size) {
    // A button glyph is sixty pixels wide, so a fixed inset of thirty four a
    // side leaves it nothing at all to draw a bar in.
    final room = plain ? 6.0 : 34.0;
    final left = room;
    final right = size.width - room;
    final span = right - left;
    final beam = plain ? size.height / 2 : size.height * 0.40;

    double x(double at) => left + span * at;

    canvas.drawLine(
      Offset(left, beam),
      Offset(right, beam),
      Paint()
        ..color = AppColors.ink2
        ..strokeWidth = plain ? 3.4 : 6
        ..strokeCap = StrokeCap.round,
    );

    // The pivot, drawn under the bar where a pivot lives.
    final pivot = Offset(x(lever.pivotAt), beam);
    final tall = plain ? 9.0 : 15.0;
    final wide = plain ? 7.0 : 12.0;
    canvas.drawPath(
      Path()
        ..moveTo(pivot.dx, pivot.dy + 2)
        ..lineTo(pivot.dx - wide, pivot.dy + 2 + tall)
        ..lineTo(pivot.dx + wide, pivot.dy + 2 + tall)
        ..close(),
      Paint()..color = AppColors.charcoal,
    );

    if (plain) return;

    final effort = Offset(x(lever.effortAt), beam);
    final load = Offset(x(lever.loadAt), beam);
    final taken = <Rect>[];

    if (lever.effortUp) {
      _arrow(canvas, effort + const Offset(0, 46), effort + const Offset(0, 7),
          AppColors.ember);
      taken.add(_write(canvas, 'your pull', effort + const Offset(0, 50),
          AppColors.ember, size, taken));
    } else {
      _arrow(canvas, effort - const Offset(0, 46), effort - const Offset(0, 7),
          AppColors.ember);
      taken.add(_write(canvas, 'your push', effort - const Offset(0, 62),
          AppColors.ember, size, taken));
    }

    _arrow(canvas, load - const Offset(0, 46), load - const Offset(0, 7),
        AppColors.charcoal);
    taken.add(_write(canvas, 'the load', load - const Offset(0, 62),
        AppColors.charcoal, size, taken));

    // The two arms, measured under the bar on their own lines. They are what
    // the question is about, so they are drawn rather than described, and they
    // never run through the bar.
    _dimension(canvas, size, pivot.dx, effort.dx, beam + 40, 'your arm',
        AppColors.ember, taken);
    _dimension(canvas, size, pivot.dx, load.dx, beam + 74, 'its arm',
        AppColors.ink3, taken);
  }

  void _dimension(Canvas canvas, Size size, double from, double to, double y,
      String label, Color colour, List<Rect> taken) {
    final ink = Paint()
      ..color = colour
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (final at in [from, to]) {
      canvas.drawLine(Offset(at, y - 20), Offset(at, y + 5), ink);
    }
    canvas.drawLine(Offset(from, y), Offset(to, y), ink);
    final way = to > from ? 1.0 : -1.0;
    for (final (tip, back) in [(from, way), (to, -way)]) {
      canvas.drawPath(
        Path()
          ..moveTo(tip, y)
          ..lineTo(tip + back * 8, y - 3.4)
          ..lineTo(tip + back * 8, y + 3.4)
          ..close(),
        Paint()..color = colour,
      );
    }
    // Centred under the dimension when it fits there, and off to the far side
    // when it does not. A label wider than the measurement it names, printed
    // in the middle of it, buries both arrowheads.
    final wide = _widthOf(label);
    final room = (to - from).abs();
    final spot = room > wide + 12
        ? Offset((from + to) / 2, y + 7)
        : Offset(to + way * (wide / 2 + 12), y + 7);
    taken.add(_write(canvas, label, spot, colour, size, taken));
  }

  void _arrow(Canvas canvas, Offset from, Offset to, Color colour) {
    final paint = Paint()
      ..color = colour
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);
    final run = to - from;
    final unit = run / run.distance;
    final side = Offset(-unit.dy, unit.dx);
    canvas.drawPath(
      Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo(to.dx - unit.dx * 10 + side.dx * 5,
            to.dy - unit.dy * 10 + side.dy * 5)
        ..lineTo(to.dx - unit.dx * 10 - side.dx * 5,
            to.dy - unit.dy * 10 - side.dy * 5)
        ..close(),
      Paint()..color = colour,
    );
  }

  double _widthOf(String text) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10.5)),
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width;
  }

  Rect _write(Canvas canvas, String text, Offset at, Color colour, Size size,
      List<Rect> avoid) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10.5, color: colour)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx - tp.width / 2;
    var y = at.dy;
    if (x < 2) x = 2;
    if (x + tp.width > size.width - 2) x = size.width - 2 - tp.width;
    Rect box() => Rect.fromLTWH(x - 2, y, tp.width + 4, tp.height);
    for (var tries = 0; tries < 4; tries++) {
      if (!avoid.any((r) => r.overlaps(box()))) break;
      y -= tp.height + 3;
    }
    if (y < 1) y = 1;
    if (y + tp.height > size.height - 1) y = size.height - 1 - tp.height;
    canvas.drawRect(
        box(), Paint()..color = AppColors.cream.withValues(alpha: 0.92));
    tp.paint(canvas, Offset(x, y));
    return box();
  }

  @override
  bool shouldRepaint(LeverPainter old) =>
      old.lever != lever || old.plain != plain;
}
