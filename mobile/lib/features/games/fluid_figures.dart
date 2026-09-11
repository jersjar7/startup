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
