import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// A settling tank, described by the two numbers that decide what it does:
/// how much water it takes and how much SURFACE it offers that water.
@immutable
class Clarifier {
  const Clarifier({
    required this.flowGpd,
    required this.diameter,
    required this.depth,
  });

  /// Gallons a day arriving.
  final double flowGpd;

  /// Feet across, and feet deep.
  final double diameter;
  final double depth;

  double get area => math.pi * diameter * diameter / 4;

  /// Gallons a day per square foot, which is a VELOCITY: the speed the
  /// water rises through the tank. Anything settling faster than this
  /// reaches the bottom; anything slower is carried over the weir.
  double get overflowRate => flowGpd / area;

  /// The same velocity in feet an hour, so it can be compared with a
  /// settling velocity without a conversion in the way. A gallon is
  /// 0.1337 cubic feet.
  double get riseFeetPerHour => overflowRate * 0.1337 / 24;

  double get volumeGallons => area * depth * 7.481;

  /// Hours the WATER spends in the tank. Depth changes this and does not
  /// change the overflow rate at all.
  double get detentionHours => volumeGallons / flowGpd * 24;
}

/// The tank cut through, with the rise velocity drawn against the settling
/// velocity of one particle. Whether the particle is caught is the whole
/// question, and on this drawing it is a comparison of two arrows.
class ClarifierPainter extends CustomPainter {
  const ClarifierPainter({
    required this.clarifier,
    required this.settlingFeetPerHour,
    this.answered = false,
  });

  final Clarifier clarifier;

  /// How fast the particle falls through still water.
  final double settlingFeetPerHour;
  final bool answered;

  bool get caught => settlingFeetPerHour > clarifier.riseFeetPerHour;

  @override
  void paint(Canvas canvas, Size size) {
    final top = 54.0;
    final bottom = size.height - 46;
    final left = 44.0;
    final right = size.width - 58;

    // The tank: water in it, a weir at the far end, a hopper under it.
    canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), waterFill);
    canvas.drawPath(
        Path()
          ..moveTo(left, top - 14)
          ..lineTo(left, bottom)
          ..lineTo(right, bottom)
          ..lineTo(right, top - 14),
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    waterLevel(canvas, Offset(left, top), Offset(right, top), markAt: left + 24);

    // In at the left, over the weir at the right.
    canvas.drawLine(
        Offset(8, top + 12),
        Offset(left, top + 12),
        Paint()
          ..color = AppColors.info
          ..strokeWidth = 3);
    writeOn(canvas, size, 'in', const Offset(10, 22), AppColors.info,
        fontSize: 9);
    canvas.drawLine(
        Offset(right, top),
        Offset(size.width - 8, top + 6),
        Paint()
          ..color = AppColors.info
          ..strokeWidth = 3);
    writeOn(canvas, size, 'over the weir', Offset(right - 10, top - 16),
        AppColors.info, fontSize: 9);

    // The rise velocity: the overflow rate, drawn as what it is.
    final scale = 26 / math.max(
        math.max(clarifier.riseFeetPerHour, settlingFeetPerHour), 0.01);
    final middle = (left + right) / 2;
    void arrow(double x, double up, Color tone, String text, bool rising) {
      final length = math.max(up * scale, 8).toDouble();
      final from = Offset(x, rising ? bottom - 20 : top + 20);
      final to = Offset(x, rising ? from.dy - length : from.dy + length);
      canvas
        ..drawLine(
            from,
            to,
            Paint()
              ..color = tone
              ..strokeWidth = 2.6)
        ..drawPath(
            Path()
              ..moveTo(to.dx, to.dy + (rising ? -7 : 7))
              ..lineTo(to.dx - 4.5, to.dy)
              ..lineTo(to.dx + 4.5, to.dy)
              ..close(),
            Paint()..color = tone);
      writeOn(canvas, size, text, Offset(x + 8, (from.dy + to.dy) / 2 - 6),
          tone, fontSize: 9.5);
    }

    arrow(middle - 54, clarifier.riseFeetPerHour, AppColors.info,
        'water rises ${clarifier.riseFeetPerHour.toStringAsFixed(1)} ft/hr',
        true);
    arrow(middle + 46, settlingFeetPerHour, AppColors.charcoal,
        'grit falls ${settlingFeetPerHour.toStringAsFixed(1)} ft/hr', false);

    if (answered) {
      writeOn(
          canvas,
          size,
          caught ? 'it reaches the floor' : 'it goes over the weir',
          Offset(left + 6, bottom - 14),
          caught ? AppColors.forest : AppColors.error,
          fontSize: 9.5);
    }

    // The floor the sludge collects on.
    groundLine(canvas, Offset(left, bottom), Offset(right, bottom));

    writeOn(
        canvas,
        size,
        '${_num(clarifier.diameter)} ft across, '
            '${_num(clarifier.depth)} ft deep',
        const Offset(8, 8),
        AppColors.ink2,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'overflow rate ${clarifier.overflowRate.toStringAsFixed(0)} gpd/ft2',
        const Offset(8, 22),
        AppColors.ink3,
        fontSize: 9.5);
    viewTag(canvas, size, Looking.section, note: 'through the clarifier');
  }

  @override
  bool shouldRepaint(ClarifierPainter old) =>
      old.clarifier != clarifier ||
      old.settlingFeetPerHour != settlingFeetPerHour ||
      old.answered != answered;
}

/// Which loop a quantity belongs to: the water going through once, or the
/// solids going round and round.
enum Loop2 { water, solids }

/// An activated sludge plant as a flow diagram: water in at the left,
/// through the aeration basin and the clarifier and out, with the solids
/// recycled underneath and a little wasted. The two paths are what HRT and
/// SRT measure, and they are drawn apart so they can be told apart.
class PlantPainter extends CustomPainter {
  const PlantPainter({this.highlight, this.note});

  /// The loop the round is about, drawn in ember.
  final Loop2? highlight;
  final String? note;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2 - 12;
    final basin = Rect.fromLTRB(58, mid - 30, size.width / 2 - 12, mid + 30);
    final tank = Rect.fromLTRB(
        size.width / 2 + 16, mid - 30, size.width - 52, mid + 30);
    final waterTone =
        highlight == Loop2.water ? AppColors.ember : AppColors.info;
    final solidsTone =
        highlight == Loop2.solids ? AppColors.ember : AppColors.ink2;

    for (final (rect, label) in [
      (basin, 'aeration basin'),
      (tank, 'clarifier'),
    ]) {
      canvas
        ..drawRect(rect, waterFill)
        ..drawRect(
            rect,
            Paint()
              ..color = AppColors.charcoal
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.8);
      writeOn(canvas, size, label, Offset(rect.left + 4, rect.top - 14),
          AppColors.charcoal, fontSize: 9.5);
    }

    void run(Offset from, Offset to, Color tone, {double width = 3}) {
      canvas.drawLine(
          from,
          to,
          Paint()
            ..color = tone
            ..strokeWidth = width);
      final along = to - from;
      if (along.distance < 1) return;
      final unit = along / along.distance;
      final back = to - unit * 8;
      final side = Offset(-unit.dy, unit.dx) * 4.5;
      canvas.drawPath(
          Path()
            ..moveTo(to.dx, to.dy)
            ..lineTo(back.dx + side.dx, back.dy + side.dy)
            ..lineTo(back.dx - side.dx, back.dy - side.dy)
            ..close(),
          Paint()..color = tone);
    }

    // The water: in, across, out. Once through and gone.
    run(Offset(8, mid), Offset(basin.left, mid), waterTone);
    run(Offset(basin.right, mid), Offset(tank.left, mid), waterTone);
    run(Offset(tank.right, mid), Offset(size.width - 8, mid), waterTone);
    writeOn(canvas, size, 'water', Offset(10, mid - 16), waterTone,
        fontSize: 9.5);
    writeOn(canvas, size, 'out', Offset(size.width - 32, mid - 16), waterTone,
        fontSize: 9.5);

    // The solids: down out of the clarifier, back to the basin, round and
    // round, with a little wasted.
    final loopY = mid + 56;
    canvas.drawLine(Offset(tank.center.dx, mid + 30), Offset(tank.center.dx,
        loopY),
        Paint()
          ..color = solidsTone
          ..strokeWidth = 3);
    run(Offset(tank.center.dx, loopY), Offset(basin.center.dx, loopY),
        solidsTone);
    run(Offset(basin.center.dx, loopY), Offset(basin.center.dx, mid + 30),
        solidsTone);
    writeOn(canvas, size, 'returned sludge',
        Offset(basin.center.dx + 6, loopY + 4), solidsTone, fontSize: 9.5);
    run(Offset(tank.center.dx, loopY), Offset(size.width - 8, loopY),
        solidsTone,
        width: 2);
    writeOn(canvas, size, 'wasted', Offset(size.width - 54, loopY - 15),
        solidsTone, fontSize: 9);

    if (note != null) {
      writeOn(canvas, size, note!, const Offset(8, 8), AppColors.ink3,
          fontSize: 9.5);
    }
    writeOn(canvas, size, 'FLOW DIAGRAM', Offset(size.width, size.height - 14),
        AppColors.ink3, fontSize: 8.5);
  }

  @override
  bool shouldRepaint(PlantPainter old) =>
      old.highlight != highlight || old.note != note;
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();
