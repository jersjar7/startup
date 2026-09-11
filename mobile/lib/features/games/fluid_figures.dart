import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// A plate sliding on a film of oil, which is the whole of this lesson's
/// viscosity problem.
@immutable
class Film {
  const Film({
    required this.mu,
    required this.speed,
    required this.millimeters,
    this.fluid = 'oil',
  });

  /// Pascal seconds, meters a second, and the film thickness in millimeters,
  /// because millimeters is how a problem always gives it and converting is
  /// the trap.
  final double mu;
  final double speed;
  final double millimeters;
  final String fluid;

  double get meters => millimeters / 1000;

  /// The velocity gradient across the film, which is constant when the
  /// profile is a straight line.
  double get gradient => speed / meters;

  /// Newton's law of viscosity, in pascals.
  double get shear => mu * gradient;
}

/// The film drawn in section: the moving plate on top, the fixed surface
/// underneath, and the straight-line velocity profile between them.
class FilmPainter extends CustomPainter {
  const FilmPainter({
    required this.film,
    required this.thickest,
    this.tone = AppColors.charcoal,
  });

  final Film film;

  /// The thickest film in the round, so two panels are drawn to one scale.
  final double thickest;

  final Color tone;

  static Rect plateOf(Size size) =>
      Rect.fromLTRB(16, size.height * 0.30, size.width - 16, size.height * 0.38);

  @override
  void paint(Canvas canvas, Size size) {
    final plate = plateOf(size);
    // The film is drawn to scale against the thickest one in the round, with
    // a floor so the thinnest is still something you can see.
    final gap = math.max(14.0, 54 * film.millimeters / thickest);
    final floor = plate.bottom + gap;

    canvas
      ..drawRect(plate, Paint()..color = AppColors.charcoal)
      ..drawRect(
        Rect.fromLTRB(plate.left, plate.bottom, plate.right, floor),
        Paint()..color = AppColors.sunbeam.withValues(alpha: 0.3),
      )
      ..drawLine(
        Offset(plate.left, floor),
        Offset(plate.right, floor),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 2.4,
      );
    for (var h = plate.left; h < plate.right; h += 9) {
      canvas.drawLine(
        Offset(h, floor),
        Offset(h + 5, floor + 6),
        Paint()
          ..color = AppColors.ink3
          ..strokeWidth = 1,
      );
    }

    // The profile: full speed at the plate, nothing at the fixed surface.
    final from = plate.center.dx + 20;
    final long = math.min(74.0, size.width * 0.3);
    final arrows = Paint()
      ..color = AppColors.info
      ..strokeWidth = 1.4;
    for (var i = 0; i <= 4; i++) {
      final y = plate.bottom + gap * i / 4;
      final len = long * (1 - i / 4);
      canvas.drawLine(Offset(from, y), Offset(from + len, y), arrows);
      if (len > 6) {
        canvas
          ..drawLine(Offset(from + len, y), Offset(from + len - 4, y - 3), arrows)
          ..drawLine(Offset(from + len, y), Offset(from + len - 4, y + 3), arrows);
      }
    }
    canvas.drawLine(
      Offset(from + long, plate.bottom),
      Offset(from, floor),
      Paint()
        ..color = AppColors.info
        ..strokeWidth = 1.6,
    );

    // The plate's own speed.
    final tip = Offset(plate.right - 6, plate.center.dy);
    final pull = Paint()
      ..color = AppColors.ember
      ..strokeWidth = 2.4;
    canvas
      ..drawLine(Offset(plate.right - 44, tip.dy), tip, pull)
      ..drawLine(tip, tip + const Offset(-6, -4), pull)
      ..drawLine(tip, tip + const Offset(-6, 4), pull);

    _write(canvas, size, '${_num(film.speed)} m/s',
        Offset(plate.right - 52, plate.top - 16), AppColors.ember);
    _write(canvas, size, '${_num(film.millimeters)} mm',
        Offset(plate.left + 4, plate.bottom + gap / 2 - 6), AppColors.ink3);
    _write(canvas, size, '${film.fluid}, ${_num(film.mu)} Pa s',
        Offset(plate.left, floor + 14), AppColors.ink3);
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toString();

  void _write(Canvas canvas, Size size, String text, Offset at, Color color) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx;
    if (x + painter.width > size.width - 2) x = size.width - 2 - painter.width;
    if (x < 2) x = 2;
    final patch = Rect.fromLTWH(
        x - 2, at.dy - 1, painter.width + 4, painter.height + 2);
    canvas.drawRect(
        patch, Paint()..color = AppColors.cream.withValues(alpha: 0.9));
    painter.paint(canvas, Offset(x, at.dy));
  }

  @override
  bool shouldRepaint(FilmPainter old) =>
      old.film != film || old.thickest != thickest || old.tone != tone;
}

/// A capillary tube standing in a dish of liquid.
@immutable
class Straw {
  const Straw({
    required this.millimeters,
    this.sigma = 0.0728,
    this.angle = 0,
    this.gamma = 9789,
    this.liquid = 'water',
  });

  /// The bore, in millimeters. The formula wants the DIAMETER, which is the
  /// distinction the lesson's problem is built on.
  final double millimeters;

  /// Newtons a meter, degrees, and newtons a cubic meter.
  final double sigma;
  final double angle;
  final double gamma;

  final String liquid;

  /// How far it climbs, in millimeters. Negative means it is pushed down,
  /// which is what a liquid that does not wet the glass does.
  double get rise {
    final d = millimeters / 1000;
    final h = 4 * sigma * math.cos(angle * math.pi / 180) / (gamma * d);
    return h * 1000;
  }
}

/// Two or three tubes standing in one dish, each with its liquid at the
/// height the formula puts it.
class CapillaryPainter extends CustomPainter {
  const CapillaryPainter({
    required this.straws,
    this.picked,
    this.answer,
    this.locked = false,
    this.showLevels = true,
  });

  final List<Straw> straws;
  final int? picked;
  final int? answer;
  final bool locked;

  /// The liquid is drawn at the height the formula puts it only once the
  /// round is over. Drawn while the question is open it IS the answer.
  final bool showLevels;

  /// True when every tube stands in the same liquid, which is the only time
  /// one dish is honest: two different liquids cannot share a dish.
  static bool sharedDish(List<Straw> straws) =>
      straws.every((s) => s.liquid == straws.first.liquid);

  static Rect dishOf(Size size, List<Straw> straws, int i) {
    final top = size.height * 0.62;
    final bottom = size.height * 0.86;
    if (sharedDish(straws)) {
      return Rect.fromLTRB(10, top, size.width - 10, bottom);
    }
    final tube = tubeOf(size, straws, i);
    return Rect.fromLTRB(tube.left - 26, top, tube.right + 26, bottom);
  }

  /// Where each tube stands. A tube is drawn wider than it is so a bore of a
  /// millimeter is something a thumb can find; the caption says so.
  static Rect tubeOf(Size size, List<Straw> straws, int i) {
    final slot = (size.width - 40) / straws.length;
    final middle = 20 + slot * (i + 0.5);
    final wide = math.max(16.0, math.min(30.0, 9 * straws[i].millimeters));
    return Rect.fromLTRB(middle - wide / 2, size.height * 0.10,
        middle + wide / 2, size.height * 0.62 + 14);
  }

  /// Which tube a tap landed on.
  static int? at(Size size, List<Straw> straws, Offset tap) {
    for (var i = 0; i < straws.length; i++) {
      if (tubeOf(size, straws, i).inflate(12).contains(tap)) return i;
    }
    return null;
  }

  /// The height a rise is drawn at, to one scale across the round.
  static double levelOf(Size size, List<Straw> straws, int i) {
    final dish = dishOf(size, straws, i);
    final most = straws
        .map((s) => s.rise.abs())
        .reduce((a, b) => a > b ? a : b);
    final room = dish.top - size.height * 0.14;
    return dish.top - room * (straws[i].rise / (most == 0 ? 1 : most));
  }

  @override
  void paint(Canvas canvas, Size size) {
    // The dishes first, so a column of liquid is drawn over its own dish.
    final drawn = <Rect>{};
    for (var i = 0; i < straws.length; i++) {
      final dish = dishOf(size, straws, i);
      if (!drawn.add(dish)) continue;
      canvas
        ..drawRect(dish, Paint()..color = AppColors.info.withValues(alpha: 0.25))
        ..drawLine(dish.bottomLeft, dish.bottomRight,
            Paint()..color = AppColors.charcoal..strokeWidth = 2)
        ..drawLine(dish.topLeft, dish.topRight,
            Paint()..color = AppColors.info..strokeWidth = 1);
      _write(canvas, size, straws[i].liquid,
          Offset(dish.left + 4, dish.bottom + 4), AppColors.ink3);
    }

    for (var i = 0; i < straws.length; i++) {
      final tube = tubeOf(size, straws, i);
      final dish = dishOf(size, straws, i);
      final Color tone;
      if (locked && answer == i) {
        tone = AppColors.forest;
      } else if (locked && picked == i) {
        tone = AppColors.error;
      } else if (picked == i) {
        tone = AppColors.ember;
      } else {
        tone = AppColors.charcoal;
      }

      // The column of liquid inside the tube, once the answer is in.
      if (showLevels) {
        final level = levelOf(size, straws, i);
        canvas.drawRect(
          Rect.fromLTRB(tube.left + 2, level, tube.right - 2, dish.bottom),
          Paint()..color = AppColors.info.withValues(alpha: 0.45),
        );
      }
      canvas
        ..drawLine(tube.topLeft, tube.bottomLeft,
            Paint()..color = tone..strokeWidth = tone == AppColors.charcoal ? 1.6 : 2.6)
        ..drawLine(tube.topRight, tube.bottomRight,
            Paint()..color = tone..strokeWidth = tone == AppColors.charcoal ? 1.6 : 2.6);

      _write(canvas, size, '${_num(straws[i].millimeters)} mm',
          Offset(tube.center.dx - 16, tube.top - 14), tone);
    }
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toString();

  void _write(Canvas canvas, Size size, String text, Offset at, Color color) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx;
    if (x + painter.width > size.width - 2) x = size.width - 2 - painter.width;
    if (x < 2) x = 2;
    final patch = Rect.fromLTWH(
        x - 2, at.dy - 1, painter.width + 4, painter.height + 2);
    canvas.drawRect(
        patch, Paint()..color = AppColors.cream.withValues(alpha: 0.9));
    painter.paint(canvas, Offset(x, at.dy));
  }

  @override
  bool shouldRepaint(CapillaryPainter old) =>
      old.straws != straws ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked ||
      old.showLevels != showLevels;
}

/// A vessel of some shape, filled to a depth, with the point of interest
/// marked at the bottom of it.
enum Shape4 { straight, flared, tapered, stepped }

@immutable
class Pot {
  const Pot({
    required this.shape,
    required this.depth,
    this.gamma = 9810,
    this.liquid = 'water',
    this.pointDepth,
  });

  final Shape4 shape;

  /// Meters from the free surface to the bottom.
  final double depth;

  /// Newtons a cubic meter, and what the round calls the liquid.
  final double gamma;
  final String liquid;

  /// How deep the marked point is, when it is not at the bottom.
  final double? pointDepth;

  double get at => pointDepth ?? depth;

  /// Gauge pressure at the marked point, in kilopascals. Only the depth and
  /// the liquid appear: the shape of the vessel is not in it anywhere, which
  /// is the whole of this item.
  double get pressure => gamma * at / 1000;
}

/// Two vessels side by side, each filled to its own depth, with the point in
/// each one marked.
class PotPainter extends CustomPainter {
  const PotPainter({
    required this.pots,
    required this.deepest,
    this.picked,
    this.answer,
    this.locked = false,
  });

  final List<Pot> pots;

  /// The deepest fill in the round, so both are drawn to one scale.
  final double deepest;

  final int? picked;
  final int? answer;
  final bool locked;

  static Rect cellOf(Size size, int count, int i) {
    final wide = size.width / count;
    return Rect.fromLTWH(wide * i, 0, wide, size.height);
  }

  /// The marked point in each vessel.
  static Offset spotOf(Size size, List<Pot> pots, double deepest, int i) {
    final cell = cellOf(size, pots.length, i);
    final top = size.height * 0.20;
    final floor = size.height * 0.80;
    final surface = floor - (floor - top) * pots[i].depth / deepest;
    final down = (floor - surface) * pots[i].at / pots[i].depth;
    return Offset(cell.center.dx, surface + down);
  }

  /// Which vessel a tap landed on.
  static int? at(Size size, List<Pot> pots, Offset tap) {
    if (tap.dy < 0 || tap.dy > size.height) return null;
    final i = (tap.dx / (size.width / pots.length)).floor();
    return i.clamp(0, pots.length - 1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final top = size.height * 0.20;
    final floor = size.height * 0.80;

    for (var i = 0; i < pots.length; i++) {
      final pot = pots[i];
      final cell = cellOf(size, pots.length, i);
      final surface = floor - (floor - top) * pot.depth / deepest;
      final Color tone;
      if (locked && answer == i) {
        tone = AppColors.forest;
      } else if (locked && picked == i) {
        tone = AppColors.error;
      } else if (picked == i) {
        tone = AppColors.ember;
      } else {
        tone = AppColors.charcoal;
      }

      // The walls, whose shape is deliberately different every round and
      // deliberately irrelevant to the answer.
      final half = cell.width * 0.30;
      final narrow = half * 0.42;
      final (double topHalf, double bottomHalf) = switch (pot.shape) {
        Shape4.straight => (half * 0.66, half * 0.66),
        Shape4.flared => (half, narrow),
        Shape4.tapered => (narrow, half),
        Shape4.stepped => (narrow, half * 0.9),
      };

      final wall = Path()
        ..moveTo(cell.center.dx - topHalf, surface - 12)
        ..lineTo(cell.center.dx - bottomHalf, floor)
        ..lineTo(cell.center.dx + bottomHalf, floor)
        ..lineTo(cell.center.dx + topHalf, surface - 12);
      if (pot.shape == Shape4.stepped) {
        wall
          ..reset()
          ..moveTo(cell.center.dx - narrow, surface - 12)
          ..lineTo(cell.center.dx - narrow, surface + (floor - surface) * 0.45)
          ..lineTo(cell.center.dx - half * 0.9,
              surface + (floor - surface) * 0.45)
          ..lineTo(cell.center.dx - half * 0.9, floor)
          ..lineTo(cell.center.dx + half * 0.9, floor)
          ..lineTo(cell.center.dx + half * 0.9,
              surface + (floor - surface) * 0.45)
          ..lineTo(cell.center.dx + narrow,
              surface + (floor - surface) * 0.45)
          ..lineTo(cell.center.dx + narrow, surface - 12);
      }

      // The liquid, drawn to the surface line.
      canvas.save();
      final fill = Path.from(wall)..close();
      canvas
        ..clipPath(fill)
        ..drawRect(
          Rect.fromLTRB(cell.left, surface, cell.right, floor),
          Paint()..color = AppColors.info.withValues(alpha: 0.3),
        );
      canvas.restore();

      canvas.drawPath(
        wall,
        Paint()
          ..color = tone
          ..style = PaintingStyle.stroke
          ..strokeWidth = (picked == i || (locked && answer == i)) ? 2.6 : 1.6,
      );

      // The free surface and the point of interest.
      canvas.drawLine(
        Offset(cell.center.dx - topHalf, surface),
        Offset(cell.center.dx + topHalf, surface),
        Paint()
          ..color = AppColors.info
          ..strokeWidth = 1.4,
      );
      final spot = spotOf(size, pots, deepest, i);
      canvas
        ..drawCircle(spot, 6, Paint()..color = AppColors.cream)
        ..drawCircle(spot, 4.5, Paint()..color = tone);

      _write(canvas, size, '${_num(pot.at)} m deep',
          Offset(cell.center.dx - 28, surface - 30), AppColors.ink3);
      _write(canvas, size, pot.liquid,
          Offset(cell.center.dx - 18, floor + 6), AppColors.ink3);
    }
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toString();

  void _write(Canvas canvas, Size size, String text, Offset at, Color color) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx;
    if (x + painter.width > size.width - 2) x = size.width - 2 - painter.width;
    if (x < 2) x = 2;
    final patch = Rect.fromLTWH(
        x - 2, at.dy - 1, painter.width + 4, painter.height + 2);
    canvas.drawRect(
        patch, Paint()..color = AppColors.cream.withValues(alpha: 0.9));
    painter.paint(canvas, Offset(x, at.dy));
  }

  @override
  bool shouldRepaint(PotPainter old) =>
      old.pots != pots ||
      old.deepest != deepest ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked;
}

/// The places a manometer walk can start and end.
enum Stop {
  line,
  leftSurface,
  leftBottom,
  rightBottom,
  rightSurface,
  open,
}

extension StopWords on Stop {
  String get plain => switch (this) {
        Stop.line => 'the air line',
        Stop.leftSurface => 'the mercury surface in the left leg',
        Stop.leftBottom => 'the bottom of the left leg',
        Stop.rightBottom => 'the bottom of the right leg',
        Stop.rightSurface => 'the mercury surface in the right leg',
        Stop.open => 'the open end',
      };
}

/// A U-tube manometer: mercury in the bend, and optionally a lighter liquid
/// standing on top of it in the left leg.
@immutable
class UTube {
  const UTube({
    this.rightHigher = 0.25,
    this.heavy = 133416,
    this.light = 9810,
    this.hasLight = false,
    this.heavyName = 'mercury',
    this.lightName = 'water',
  });

  /// How much higher the right hand mercury surface stands, in meters.
  final double rightHigher;

  /// Newtons a cubic meter for the manometer fluid and for anything standing
  /// on it.
  final double heavy;
  final double light;

  /// Whether a column of the lighter liquid sits on the left hand mercury.
  final bool hasLight;

  final String heavyName;
  final String lightName;

  /// The pressure the height difference is holding, in kilopascals.
  double get held => heavy * rightHigher / 1000;
}

/// The manometer, with the step the round asks about drawn on it.
class UTubePainter extends CustomPainter {
  const UTubePainter({
    required this.tube,
    required this.from,
    required this.to,
  });

  final UTube tube;
  final Stop from;
  final Stop to;

  static double leftX(Size size) => size.width * 0.34;
  static double rightX(Size size) => size.width * 0.66;
  static double topY(Size size) => size.height * 0.14;
  static double bottomY(Size size) => size.height * 0.80;

  /// Where each stop sits on the canvas.
  static Offset spotOf(Size size, UTube tube, Stop stop) {
    final bottom = bottomY(size);
    final top = topY(size);
    final room = bottom - top;
    final rightLevel = bottom - room * 0.58;
    final leftLevel = rightLevel + room * 0.28;
    return switch (stop) {
      Stop.line => Offset(leftX(size), top),
      Stop.leftSurface => Offset(leftX(size), leftLevel),
      Stop.leftBottom => Offset(leftX(size), bottom),
      Stop.rightBottom => Offset(rightX(size), bottom),
      Stop.rightSurface => Offset(rightX(size), rightLevel),
      Stop.open => Offset(rightX(size), top),
    };
  }

  @override
  void paint(Canvas canvas, Size size) {
    final left = leftX(size);
    final right = rightX(size);
    final top = topY(size);
    final bottom = bottomY(size);
    const bore = 16.0;

    final leftSurface = spotOf(size, tube, Stop.leftSurface).dy;
    final rightSurface = spotOf(size, tube, Stop.rightSurface).dy;

    // The mercury, up both legs and round the bend.
    final heavy = Paint()..color = AppColors.charcoal.withValues(alpha: 0.55);
    canvas
      ..drawRect(
          Rect.fromLTRB(left - bore / 2, leftSurface, left + bore / 2, bottom),
          heavy)
      ..drawRect(
          Rect.fromLTRB(right - bore / 2, rightSurface, right + bore / 2, bottom),
          heavy)
      ..drawRect(
          Rect.fromLTRB(left - bore / 2, bottom - bore, right + bore / 2, bottom),
          heavy);

    // The lighter liquid standing on the left hand mercury, when there is any.
    if (tube.hasLight) {
      canvas.drawRect(
        Rect.fromLTRB(left - bore / 2, top + 18, left + bore / 2, leftSurface),
        Paint()..color = AppColors.info.withValues(alpha: 0.35),
      );
      _write(canvas, size, tube.lightName, Offset(left - 48, top + 24),
          AppColors.info);
    }

    // The glass.
    final glass = Paint()
      ..color = AppColors.charcoal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final path = Path()
      ..moveTo(left - bore / 2, top)
      ..lineTo(left - bore / 2, bottom)
      ..lineTo(right + bore / 2, bottom)
      ..lineTo(right + bore / 2, top)
      ..moveTo(left + bore / 2, top)
      ..lineTo(left + bore / 2, bottom - bore)
      ..lineTo(right - bore / 2, bottom - bore)
      ..lineTo(right - bore / 2, top);
    canvas.drawPath(path, glass);

    _write(canvas, size, 'air line', Offset(left - 54, top - 2),
        AppColors.ink3);
    _write(canvas, size, 'open', Offset(right + 10, top - 2), AppColors.ink3);
    // Under the bend, clear of the walk's own labels, which live beside the
    // legs and used to run into this one.
    _write(canvas, size, tube.heavyName, Offset(left - 10, bottom + 6),
        AppColors.ink3);

    // The height between the two mercury surfaces, which is what the
    // manometer is reading.
    final tick = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1;
    canvas
      ..drawLine(Offset(left + bore / 2, leftSurface),
          Offset(right + bore / 2 + 26, leftSurface), tick)
      ..drawLine(Offset(right + bore / 2, rightSurface),
          Offset(right + bore / 2 + 26, rightSurface), tick)
      ..drawLine(Offset(right + bore / 2 + 20, rightSurface),
          Offset(right + bore / 2 + 20, leftSurface),
          Paint()..color = AppColors.ember..strokeWidth = 1.6);
    _write(canvas, size, 'h', Offset(right + bore / 2 + 24,
        (leftSurface + rightSurface) / 2 - 7), AppColors.ember);

    // The step being asked about.
    final a = spotOf(size, tube, from);
    final b = spotOf(size, tube, to);
    final walk = Paint()
      ..color = AppColors.ember
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final route = Path()..moveTo(a.dx, a.dy);
    if (a.dx != b.dx) {
      route
        ..lineTo(a.dx, bottom - bore / 2)
        ..lineTo(b.dx, bottom - bore / 2);
    }
    route.lineTo(b.dx, b.dy);
    canvas.drawPath(route, walk);
    canvas
      ..drawCircle(a, 5, Paint()..color = AppColors.ember)
      ..drawCircle(b, 7, Paint()..color = AppColors.cream)
      ..drawCircle(b, 5.5, Paint()..color = AppColors.forest);
    // A label on the right hand leg goes to the LEFT of its dot, or it lands
    // on the tube's own captions.
    Offset beside(Offset spot, double dy) => spot.dx > size.width / 2
        ? Offset(spot.dx - 36, spot.dy + dy)
        : Offset(spot.dx + 8, spot.dy + dy);
    _write(canvas, size, 'from', beside(a, -14), AppColors.ember);
    _write(canvas, size, 'to', beside(b, 4), AppColors.forest);
  }

  void _write(Canvas canvas, Size size, String text, Offset at, Color color) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx;
    if (x + painter.width > size.width - 2) x = size.width - 2 - painter.width;
    if (x < 2) x = 2;
    final patch = Rect.fromLTWH(
        x - 2, at.dy - 1, painter.width + 4, painter.height + 2);
    canvas.drawRect(
        patch, Paint()..color = AppColors.cream.withValues(alpha: 0.9));
    painter.paint(canvas, Offset(x, at.dy));
  }

  @override
  bool shouldRepaint(UTubePainter old) =>
      old.tube != tube || old.from != from || old.to != to;
}
