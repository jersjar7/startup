import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// The three things a retaining wall is checked for, each of which compares
/// a different kind of quantity.
enum Check { overturning, sliding, bearing }

/// A gravity wall and its base, with the stability sums worked out rather
/// than quoted. Moments are about the TOE, which is the corner the wall
/// would tip over.
@immutable
class Gravity {
  const Gravity({
    required this.baseWidth,
    required this.vertical,
    required this.resisting,
    required this.overturning,
    this.height = 12,
  });

  /// Feet, pounds per foot of wall, pound-feet per foot of wall.
  final double baseWidth;
  final double vertical;
  final double resisting;
  final double overturning;

  /// Only for the drawing.
  final double height;

  double get fsOverturning => overturning <= 0 ? 0 : resisting / overturning;

  /// Where the resultant of the vertical forces crosses the base, measured
  /// from the toe.
  double get fromToe => (resisting - overturning) / vertical;

  /// And how far that is from the middle of the base, which is what the
  /// pressure formula wants.
  double get eccentricity => baseWidth / 2 - fromToe;

  double get middleThird => baseWidth / 6;
  bool get inMiddleThird => eccentricity.abs() <= middleThird;

  double get averagePressure => vertical / baseWidth;

  /// The trapezoid under the base: most at the toe, least at the heel. Only
  /// true while the resultant is inside the middle third.
  double get toePressure =>
      averagePressure * (1 + 6 * eccentricity / baseWidth);
  double get heelPressure =>
      averagePressure * (1 - 6 * eccentricity / baseWidth);
}

/// The wall in section: the earth pressure pushing it over, the weight
/// holding it down, and the toe it would turn about. What each force does
/// to the wall is the question in one of the items, so the labels that say
/// which is which wait for the answer.
class StabilityPainter extends CustomPainter {
  const StabilityPainter({
    required this.wall,
    this.which = Check.overturning,
    this.answered = false,
  });

  final Gravity wall;
  final Check which;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final base = size.height - 46;
    final left = size.width * 0.30;
    final perFoot = math.min(
        (base - 40) / wall.height, (size.width * 0.42) / wall.baseWidth);
    final wide = wall.baseWidth * perFoot;
    final top = base - wall.height * perFoot;
    final stem = left + wide * 0.34;

    // The wall: a footing with a stem on it, and soil behind.
    final concrete = Paint()..color = AppColors.charcoal.withValues(alpha: 0.75);
    canvas
      ..drawRect(Rect.fromLTRB(left, base - 14, left + wide, base), concrete)
      ..drawRect(Rect.fromLTRB(stem, top, stem + 14, base - 14), concrete)
      ..drawRect(
          Rect.fromLTRB(stem + 14, top, size.width - 12, base - 14),
          Paint()..color = AppColors.ink2.withValues(alpha: 0.20));
    groundLine(canvas, Offset(stem + 14, top), Offset(size.width - 12, top));
    canvas.drawLine(
        Offset(12, base),
        Offset(size.width - 12, base),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 2);

    // The toe is the corner it would tip about.
    canvas.drawCircle(Offset(left, base), 3.5, Paint()..color = AppColors.ember);
    writeOn(canvas, size, 'the toe', Offset(left - 26, base + 8),
        AppColors.ember, fontSize: 9.5);
    writeOn(canvas, size, 'the heel', Offset(left + wide - 24, base + 8),
        AppColors.ink3, fontSize: 9.5);

    // The earth pressure, a third of the way up the stem.
    final push = base - 14 - (base - 14 - top) / 3;
    _arrow(canvas, Offset(size.width - 34, push), Offset(stem + 18, push),
        AppColors.info);
    // The weight of wall and soil, straight down.
    _arrow(canvas, Offset(stem + 30, top - 18), Offset(stem + 30, top + 22),
        AppColors.forest);

    // Naming the two arrows says nothing about which of them resists, which
    // is what the rounds ask, so the names are always on.
    writeOn(
        canvas,
        size,
        answered ? 'the earth pressure: this tips it' : 'the earth pressure',
        Offset(size.width * 0.36, push - 16),
        AppColors.info,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        answered ? 'the weight: this holds it' : 'the weight',
        Offset(stem + 36, top - 4),
        AppColors.forest,
        fontSize: 9.5);

    if (answered) {
      writeOn(
          canvas,
          size,
          switch (which) {
            Check.overturning =>
              'overturning compares MOMENTS about the toe',
            Check.sliding => 'sliding compares FORCES along the base',
            Check.bearing => 'bearing compares PRESSURES under the base',
          },
          Offset(12, base + 22),
          AppColors.charcoal,
          fontSize: 9.5);
    } else {
      writeOn(canvas, size, 'and the corner the wall would turn about',
          Offset(12, base + 22), AppColors.ink3, fontSize: 9.5);
    }

    viewTag(canvas, size, Looking.section, note: 'the wall');
  }

  void _arrow(Canvas canvas, Offset from, Offset to, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    canvas.drawLine(from, to, paint);
    final d = (to - from);
    final len = d.distance;
    if (len == 0) return;
    final u = Offset(d.dx / len, d.dy / len);
    final n = Offset(-u.dy, u.dx);
    canvas.drawPath(
        Path()
          ..moveTo(to.dx, to.dy)
          ..lineTo(to.dx - u.dx * 8 + n.dx * 4, to.dy - u.dy * 8 + n.dy * 4)
          ..lineTo(to.dx - u.dx * 8 - n.dx * 4, to.dy - u.dy * 8 - n.dy * 4)
          ..close(),
        Paint()..color = color);
  }

  @override
  bool shouldRepaint(StabilityPainter old) =>
      old.wall != wall || old.which != which || old.answered != answered;
}

/// The base seen on its own, with the middle third marked and the resultant
/// standing where it crosses. The pressure under it comes out once the round
/// is answered.
class BasePainter extends CustomPainter {
  const BasePainter({
    required this.wall,
    this.showResultant = true,
    this.withPressure = true,
    this.answered = false,
  });

  final Gravity wall;

  /// Whether to stand the resultant on the base. Where it lands is the
  /// question in one round, so that round leaves it off.
  final bool showResultant;

  /// Whether this item draws the pressure under the base at all. The item
  /// about where the resultant lands never does, so it must not promise it
  /// either.
  final bool withPressure;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 40.0;
    final wide = size.width - left - 40;
    // With no pressure diagram to come, the base sits lower and the figure
    // keeps no room it will not use.
    final y = size.height * (withPressure ? 0.44 : 0.66);
    double at(double ft) => left + ft / wall.baseWidth * wide;

    canvas.drawRect(Rect.fromLTRB(left, y - 10, left + wide, y),
        Paint()..color = AppColors.charcoal.withValues(alpha: 0.75));
    writeOn(canvas, size, 'toe', Offset(left - 24, y - 8), AppColors.ember,
        fontSize: 9.5);
    writeOn(canvas, size, 'heel', Offset(left + wide + 6, y - 8),
        AppColors.ink3, fontSize: 9.5);
    writeOn(
        canvas,
        size,
        '${wall.baseWidth.toStringAsFixed(0)} ft of base',
        Offset(left, y - 30),
        AppColors.ink3,
        fontSize: 9.5);

    // The middle third, which is the band the resultant should stay inside.
    final third = Rect.fromLTRB(
        at(wall.baseWidth / 3), y - 26, at(2 * wall.baseWidth / 3), y - 12);
    canvas
      ..drawRect(third, Paint()..color = AppColors.forest.withValues(alpha: 0.14))
      ..drawRect(
          third,
          Paint()
            ..color = AppColors.forest
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
    writeOn(canvas, size, 'the middle third', Offset(third.left, y - 42),
        AppColors.forest, fontSize: 9.5);

    if (showResultant) {
      final x = at(wall.fromToe);
      canvas.drawLine(
          Offset(x, y - 30),
          Offset(x, y - 2),
          Paint()
            ..color = AppColors.ember
            ..strokeWidth = 2.2);
      writeOn(canvas, size, 'the resultant lands here', Offset(x - 44, y - 58),
          AppColors.ember, fontSize: 9.5);
    }

    if (!withPressure) return;
    if (!answered) {
      writeOn(canvas, size, 'the pressure under the base comes out after the '
          'answer', Offset(left - 28, size.height - 16), AppColors.ink3,
          fontSize: 9.5);
      return;
    }

    // The trapezoid: most at the toe, least at the heel.
    final tall = size.height - y - 26;
    final biggest = math.max(wall.toePressure, wall.heelPressure);
    double deep(double q) => biggest <= 0 ? 0 : q / biggest * tall;
    final shape = Path()
      ..moveTo(left, y)
      ..lineTo(left + wide, y)
      ..lineTo(left + wide, y + deep(wall.heelPressure))
      ..lineTo(left, y + deep(wall.toePressure))
      ..close();
    canvas
      ..drawPath(shape, Paint()..color = AppColors.ember.withValues(alpha: 0.30))
      ..drawPath(
          shape,
          Paint()
            ..color = AppColors.ember
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6);
    writeOn(canvas, size, '${wall.toePressure.toStringAsFixed(0)} psf',
        Offset(left - 4, y + deep(wall.toePressure) + 4), AppColors.ember,
        fontSize: 9.5);
    writeOn(canvas, size, '${wall.heelPressure.toStringAsFixed(0)} psf',
        Offset(left + wide - 30, y + deep(wall.heelPressure) + 4),
        AppColors.ember, fontSize: 9.5);
  }

  @override
  bool shouldRepaint(BasePainter old) =>
      old.wall != wall ||
      old.showResultant != showResultant ||
      old.withPressure != withPressure ||
      old.answered != answered;
}
