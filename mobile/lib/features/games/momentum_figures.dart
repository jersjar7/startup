import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// What a jet runs into, named by how far around it turns the water.
///
/// The force a jet delivers is not about hitting something. It is about
/// TURNING: the face takes away the momentum the water had along the jet and
/// gives back whatever the water still has going that way when it leaves.
/// Straight through takes nothing. A flat plate takes all of it. A cup that
/// sends the water back where it came from takes it twice over.
enum Face { through, vane, plate, scoop, cup }

extension FaceWords on Face {
  /// Degrees the stream is turned through.
  double get turn => switch (this) {
        Face.through => 0,
        Face.vane => 45,
        Face.plate => 90,
        Face.scoop => 135,
        Face.cup => 180,
      };

  String get plain => switch (this) {
        Face.through => 'a sleeve, straight through',
        Face.vane => 'a vane, turned 45 degrees',
        Face.plate => 'a flat plate',
        Face.scoop => 'a scoop, turned 135 degrees',
        Face.cup => 'a cup, turned right back',
      };

  String get short => switch (this) {
        Face.through => 'sleeve',
        Face.vane => 'vane',
        Face.plate => 'plate',
        Face.scoop => 'scoop',
        Face.cup => 'cup',
      };

  /// What the panel calls it, short enough to sit inside one.
  String get label => switch (this) {
        Face.through => 'sleeve',
        Face.vane => 'vane, 45',
        Face.plate => 'flat plate',
        Face.scoop => 'scoop, 135',
        Face.cup => 'cup, 180',
      };
}

/// One jet meeting one face.
@immutable
class Hit {
  const Hit({required this.face, this.speed = 1, this.bore = 1});

  final Face face;

  /// Both are relative to the plain jet in the same round: 2 means twice as
  /// fast, or twice the bore.
  final double speed;
  final double bore;

  /// How much of the jet's momentum the face takes, which is
  /// `1 - cos(turn)`: nothing straight through, all of it at a flat plate,
  /// twice that turned right back.
  double get taken => 1 - math.cos(face.turn * math.pi / 180);

  /// The push, in units of one plain jet on a flat plate. The area carries
  /// the bore squared and the momentum carries the speed squared.
  double get push => bore * bore * speed * speed * taken;

  /// How the panel is named to itself, so two panels in a round never read
  /// as the same option.
  String get tag {
    final parts = <String>[face.short];
    if (speed != 1) parts.add('v$speed');
    if (bore != 1) parts.add('d$bore');
    return parts.join('-');
  }
}

/// One jet and what it runs into, drawn side on. The push it delivers is
/// drawn only once the round is over.
class HitPainter extends CustomPainter {
  const HitPainter({
    required this.hit,
    required this.biggest,
    this.showPush = false,
  });

  final Hit hit;

  /// The biggest push in the round, so every panel shares one arrow scale.
  final double biggest;
  final bool showPush;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height * 0.44;
    final faceX = size.width * 0.56;
    final water = Paint()
      ..color = AppColors.info
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // The nozzle, then the jet running at the face. A faster jet is drawn
    // with a longer arrowhead and a wider stream: the picture says quick,
    // the caption says how much.
    final thick = 5.0 * hit.bore * (hit.speed > 1 ? 1.15 : 1);
    final wall = Paint()
      ..color = AppColors.charcoal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final nozzle = Path()
      ..addRect(Rect.fromLTRB(6, cy - thick - 7, 18, cy - thick - 2))
      ..addRect(Rect.fromLTRB(6, cy + thick + 2, 18, cy + thick + 7));
    canvas.drawPath(nozzle, Paint()..color = AppColors.cream);
    hatchIn(canvas, nozzle, step: 4);
    canvas
      ..drawPath(nozzle, wall)
      ..drawLine(
        Offset(18, cy),
        Offset(faceX - 2, cy),
        water..strokeWidth = thick * 2,
      );
    final head = hit.speed > 1 ? 13.0 : 9.0;
    canvas
      ..drawLine(Offset(faceX - 4, cy), Offset(faceX - 4 - head, cy - 6),
          water..strokeWidth = 1.8)
      ..drawLine(
          Offset(faceX - 4, cy), Offset(faceX - 4 - head, cy + 6), water);

    // The face itself, and where the water goes after it.
    final face = Paint()
      ..color = AppColors.charcoal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final leaving = Paint()
      ..color = AppColors.info.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final here = Offset(faceX, cy);
    // Each face is drawn as a piece of solid steel, hatched, so that none of
    // them can be read as a stray line on the drawing.
    void solid(Path shape) {
      canvas.drawPath(shape, Paint()..color = AppColors.cream);
      hatchIn(canvas, shape, step: 5);
      canvas.drawPath(shape, face);
    }

    switch (hit.face) {
      case Face.through:
        final sleeve = Path()
          ..addRect(Rect.fromLTRB(faceX, cy - thick - 9, size.width - 10,
              cy - thick - 4))
          ..addRect(Rect.fromLTRB(faceX, cy + thick + 4, size.width - 10,
              cy + thick + 9));
        solid(sleeve);
        canvas.drawLine(here, Offset(size.width - 12, cy), leaving);
      case Face.vane:
        solid(Path()
          ..moveTo(faceX - 12, cy + 16)
          ..lineTo(faceX + 16, cy - 20)
          ..lineTo(faceX + 21, cy - 16)
          ..lineTo(faceX - 7, cy + 20)
          ..close());
        canvas.drawLine(here, here + const Offset(26, -26), leaving);
      case Face.plate:
        solid(Path()
          ..addRect(Rect.fromLTRB(faceX, cy - 26, faceX + 6, cy + 26)));
        canvas
          ..drawLine(here, here + const Offset(-7, -30), leaving)
          ..drawLine(here, here + const Offset(-7, 30), leaving);
      case Face.scoop:
        solid(Path()
          ..addArc(Rect.fromCircle(center: here, radius: 24), -1.15, 2.3)
          ..arcTo(Rect.fromCircle(center: here, radius: 30), 1.15, -2.3, false)
          ..close());
        canvas
          ..drawLine(here + const Offset(-4, -14),
              here + const Offset(-26, -30), leaving)
          ..drawLine(
              here + const Offset(-4, 14), here + const Offset(-26, 30), leaving);
      case Face.cup:
        solid(Path()
          ..addArc(Rect.fromCircle(center: here, radius: 26), -1.6, 3.2)
          ..arcTo(Rect.fromCircle(center: here, radius: 32), 1.6, -3.2, false)
          ..close());
        canvas
          ..drawLine(Offset(faceX - 6, cy - 22), Offset(faceX - 30, cy - 22),
              leaving)
          ..drawLine(Offset(faceX - 6, cy + 22), Offset(faceX - 30, cy + 22),
              leaving);
    }

    // The push, never before it is answered.
    if (showPush) {
      final tone = AppColors.ember;
      final arrow = Paint()
        ..color = tone
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;
      final reach = biggest <= 0 ? 0.0 : 40 * hit.push / biggest;
      final from = Offset(faceX + 4, size.height - 30);
      if (reach < 1) {
        writeOn(canvas, size, 'no push', from + const Offset(-8, -7), tone);
      } else {
        final to = from + Offset(reach, 0);
        canvas
          ..drawLine(from, to, arrow)
          ..drawLine(to, to + const Offset(-7, -5), arrow)
          ..drawLine(to, to + const Offset(-7, 5), arrow);
      }
    }

    final notes = <String>[
      if (hit.speed > 1) 'jet x${_num(hit.speed)}',
      if (hit.speed < 1) 'jet at half',
      if (hit.bore != 1) 'bore x${_num(hit.bore)}',
    ];
    if (notes.isNotEmpty) {
      writeOn(canvas, size, notes.join(', '), Offset(6, size.height - 27),
          AppColors.ember);
    }
    writeOn(canvas, size, hit.face.label, Offset(6, size.height - 15),
        AppColors.ink2);
    viewTag(canvas, size, Looking.elevation);
  }

  @override
  bool shouldRepaint(HitPainter old) =>
      old.hit != hit || old.biggest != biggest || old.showPush != showPush;
}

/// Which way a length of buried main heads, seen from above.
enum Heading { east, north, south }

/// One straight length of the run.
@immutable
class Leg {
  const Leg({required this.heading, this.long = 2, this.bore = 300});

  final Heading heading;
  final double long;

  /// Bore in millimeters.
  final double bore;
}

/// What sits at a place where the run is interrupted.
enum Fitting { coupling, bend, reducer, cap }

extension FittingWords on Fitting {
  String get plain => switch (this) {
        Fitting.coupling => 'a plain joint in a straight length',
        Fitting.bend => 'a bend',
        Fitting.reducer => 'a change of bore',
        Fitting.cap => 'a capped end',
      };
}

/// A run of main seen in plan, with a marked spot everywhere two lengths
/// meet and at the far end if it is capped off.
@immutable
class Trunk {
  const Trunk({required this.legs, this.capped = false});

  final List<Leg> legs;

  /// Whether the far end is stopped off rather than carrying on past the
  /// drawing.
  final bool capped;

  /// How many marked spots the drawing carries.
  int get spots => legs.length - 1 + (capped ? 1 : 0);

  /// What sits at spot `i`, read off the two lengths that meet there rather
  /// than declared beside it.
  Fitting jointAt(int i) {
    if (i >= legs.length - 1) return Fitting.cap;
    if (legs[i].heading != legs[i + 1].heading) return Fitting.bend;
    if (legs[i].bore != legs[i + 1].bore) return Fitting.reducer;
    return Fitting.coupling;
  }

  /// A thrust appears wherever the water is made to change direction or
  /// speed, or is stopped: everywhere except a plain joint in a straight
  /// length of the same bore.
  bool thrustsAt(int i) => jointAt(i) != Fitting.coupling;

  /// The one spot that has to be held, which is an error if a round ever
  /// draws two of them.
  int get culprit =>
      [for (var i = 0; i < spots; i++) if (thrustsAt(i)) i].single;

  /// Where the corners of the run fall, in plan units with y running up.
  List<Offset> get vertices {
    final out = <Offset>[Offset.zero];
    for (final leg in legs) {
      final last = out.last;
      out.add(switch (leg.heading) {
        Heading.east => last + Offset(leg.long, 0),
        Heading.north => last + Offset(0, leg.long),
        Heading.south => last + Offset(0, -leg.long),
      });
    }
    return out;
  }

  bool get mixedBores => legs.any((l) => l.bore != legs.first.bore);
}

/// The run drawn in plan with every spot marked and numbered.
class TrunkPainter extends CustomPainter {
  const TrunkPainter({
    required this.trunk,
    this.picked,
    this.locked = false,
  });

  final Trunk trunk;
  final int? picked;
  final bool locked;

  /// Plan units to panel pixels, with room left for the labels.
  static (double, Offset) _fit(Size size, Trunk trunk) {
    final pts = trunk.vertices;
    var minX = pts.first.dx, maxX = pts.first.dx;
    var minY = pts.first.dy, maxY = pts.first.dy;
    for (final p in pts) {
      minX = math.min(minX, p.dx);
      maxX = math.max(maxX, p.dx);
      minY = math.min(minY, p.dy);
      maxY = math.max(maxY, p.dy);
    }
    const pad = 30.0;
    final wide = math.max(maxX - minX, 0.001);
    final tall = math.max(maxY - minY, 0.001);
    final scale = math.min(
      (size.width - 2 * pad) / wide,
      (size.height - 2 * pad - 16) / tall,
    );
    final left = (size.width - wide * scale) / 2 - minX * scale;
    final top = (size.height - 16 - tall * scale) / 2 + maxY * scale;
    return (scale, Offset(left, top));
  }

  static Offset _screen(Size size, Trunk trunk, Offset plan) {
    final (scale, origin) = _fit(size, trunk);
    return Offset(origin.dx + plan.dx * scale, origin.dy - plan.dy * scale);
  }

  /// Where spot `i` sits on the panel.
  static Offset spotOf(Size size, Trunk trunk, int i) {
    final pts = trunk.vertices;
    return _screen(size, trunk, pts[i + 1]);
  }

  static int? at(Size size, Trunk trunk, Offset tap) {
    for (var i = 0; i < trunk.spots; i++) {
      if ((spotOf(size, trunk, i) - tap).distance < 26) return i;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final pts = trunk.vertices;
    final widest = trunk.legs.map((l) => l.bore).reduce(math.max);

    for (var i = 0; i < trunk.legs.length; i++) {
      final a = _screen(size, trunk, pts[i]);
      final b = _screen(size, trunk, pts[i + 1]);
      final thick = 14 * trunk.legs[i].bore / widest;
      // Square off the inside of a corner, which two butted lines leave
      // notched.
      if (i > 0) {
        canvas.drawCircle(
            a, (thick + 3) / 2, Paint()..color = AppColors.charcoal);
      }
      canvas
        ..drawLine(
            a,
            b,
            Paint()
              ..color = AppColors.charcoal
              ..strokeWidth = thick + 3
              ..strokeCap = StrokeCap.butt)
        ..drawLine(
            a,
            b,
            Paint()
              ..color = AppColors.info.withValues(alpha: 0.45)
              ..strokeWidth = thick
              ..strokeCap = StrokeCap.butt);
      // The bore is worth saying once where it starts and once where it
      // changes, not on every length of the same pipe.
      if (trunk.mixedBores &&
          (i == 0 || trunk.legs[i].bore != trunk.legs[i - 1].bore)) {
        final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
        writeOn(canvas, size, '${_num(trunk.legs[i].bore)} mm',
            mid + const Offset(-16, 14), AppColors.ink3);
      }
    }

    // Which way the water is going, once, at the head of the run.
    final first = _screen(size, trunk, pts[0]);
    final second = _screen(size, trunk, pts[1]);
    final along = (second - first) / (second - first).distance;
    final tip = first + along * 24;
    final flow = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 1.6;
    final side = Offset(-along.dy, along.dx) * 5;
    canvas
      ..drawLine(tip, tip - along * 9 + side, flow)
      ..drawLine(tip, tip - along * 9 - side, flow);

    if (trunk.capped) {
      final end = _screen(size, trunk, pts.last);
      final last = _screen(size, trunk, pts[pts.length - 2]);
      final dir = (end - last) / (end - last).distance;
      final across = Offset(-dir.dy, dir.dx) * 19;
      canvas.drawLine(
          end + across,
          end - across,
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 4);
    }

    for (var i = 0; i < trunk.spots; i++) {
      final spot = spotOf(size, trunk, i);
      final Color tone;
      if (locked && i == trunk.culprit) {
        tone = AppColors.forest;
      } else if (locked && picked == i) {
        tone = AppColors.error;
      } else if (picked == i) {
        tone = AppColors.ember;
      } else {
        tone = AppColors.charcoal;
      }
      canvas
        ..drawCircle(spot, 11, Paint()..color = AppColors.cream)
        ..drawCircle(
            spot,
            10,
            Paint()
              ..color = tone
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.2);
      writeOn(canvas, size, '${i + 1}', spot + const Offset(-3, -6), tone);
    }
    viewTag(canvas, size, Looking.plan, note: 'seen from above');
  }

  @override
  bool shouldRepaint(TrunkPainter old) =>
      old.trunk != trunk || old.picked != picked || old.locked != locked;
}

/// A bend in plan, with four places a block could go behind it.
@immutable
class Elbow {
  const Elbow({
    required this.comesFrom,
    required this.goesTo,
    this.order = const [0, 1, 2, 3],
  });

  /// Compass headings in degrees for the way the water is TRAVELING: 0 is to
  /// the right, 90 is up the panel.
  final double comesFrom;
  final double goesTo;

  /// Which quarter turn off the thrust each drawn spot sits at, in the order
  /// they are drawn. The right one is the quarter turn of nothing.
  final List<int> order;

  /// A heading in degrees as a direction on the panel, y running down.
  static Offset unit(double degrees) {
    final r = degrees * math.pi / 180;
    return Offset(math.cos(r), -math.sin(r));
  }

  /// How far around the water is turned.
  double get turn {
    final d = (goesTo - comesFrom) % 360;
    return d > 180 ? 360 - d : d;
  }

  /// Which way the water shoves the bend. The pressure force and the
  /// momentum change both run along `in minus out`, so the push is out
  /// along the OUTSIDE of the turn, on the bisector.
  Offset get push {
    final v = unit(comesFrom) - unit(goesTo);
    return v / v.distance;
  }

  /// Where drawn spot `i` sits, as a direction off the corner.
  Offset directionOf(int i) {
    final quarter = order[i] * math.pi / 2;
    final p = push;
    return Offset(
      p.dx * math.cos(quarter) - p.dy * math.sin(quarter),
      p.dx * math.sin(quarter) + p.dy * math.cos(quarter),
    );
  }

  /// The drawn spot that is actually in the way of the push.
  int get answer => order.indexOf(0);
}

/// The bend drawn in plan with four candidate blocks around it. The thrust
/// arrow appears only once the round is over.
class ElbowPainter extends CustomPainter {
  const ElbowPainter({
    required this.elbow,
    this.picked,
    this.locked = false,
  });

  final Elbow elbow;
  final int? picked;
  final bool locked;

  static Offset _corner(Size size) =>
      Offset(size.width / 2, size.height / 2 - 4);

  static double _radius(Size size) =>
      math.min(size.width, size.height) * 0.30;

  /// Where candidate block `i` is drawn.
  static Offset spotOf(Size size, Elbow elbow, int i) =>
      _corner(size) + elbow.directionOf(i) * _radius(size);

  static int? at(Size size, Elbow elbow, Offset tap) {
    for (var i = 0; i < 4; i++) {
      if ((spotOf(size, elbow, i) - tap).distance < 26) return i;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final corner = _corner(size);
    final legLong = _radius(size) * 1.25;
    final into = Elbow.unit(elbow.comesFrom);
    final outOf = Elbow.unit(elbow.goesTo);
    final start = corner - into * legLong;
    final end = corner + outOf * legLong;

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
            ..strokeWidth = 17)
      ..drawPath(
          bent,
          Paint()
            ..color = AppColors.info.withValues(alpha: 0.45)
            ..style = PaintingStyle.stroke
            ..strokeJoin = StrokeJoin.miter
            ..strokeWidth = 13);

    // Which way the water runs, marked at both ends.
    final flow = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 1.8;
    for (final pair in [(start + into * 26, into), (end, outOf)]) {
      final tip = pair.$1;
      final dir = pair.$2;
      final side = Offset(-dir.dy, dir.dx) * 5;
      canvas
        ..drawLine(tip, tip - dir * 10 + side, flow)
        ..drawLine(tip, tip - dir * 10 - side, flow);
    }

    if (locked) {
      final to = corner + elbow.push * (_radius(size) + 18);
      final arrow = Paint()
        ..color = AppColors.ember
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;
      final dir = elbow.push;
      final side = Offset(-dir.dy, dir.dx) * 5;
      canvas
        ..drawLine(corner, to, arrow)
        ..drawLine(to, to - dir * 10 + side, arrow)
        ..drawLine(to, to - dir * 10 - side, arrow);
    }

    const letters = ['A', 'B', 'C', 'D'];
    for (var i = 0; i < 4; i++) {
      final spot = spotOf(size, elbow, i);
      final Color tone;
      if (locked && i == elbow.answer) {
        tone = AppColors.forest;
      } else if (locked && picked == i) {
        tone = AppColors.error;
      } else if (picked == i) {
        tone = AppColors.ember;
      } else {
        tone = AppColors.ink2;
      }
      final box = Rect.fromCenter(center: spot, width: 26, height: 20);
      canvas
        ..drawRRect(
            RRect.fromRectAndRadius(box, const Radius.circular(3)),
            Paint()..color = AppColors.cream)
        ..drawRRect(
            RRect.fromRectAndRadius(box, const Radius.circular(3)),
            Paint()
              ..color = tone
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2);
      writeOn(canvas, size, letters[i], spot + const Offset(-4, -6), tone);
    }
    viewTag(canvas, size, Looking.plan, note: 'seen from above');
  }

  @override
  bool shouldRepaint(ElbowPainter old) =>
      old.elbow != elbow || old.picked != picked || old.locked != locked;
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();

