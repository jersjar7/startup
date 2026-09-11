import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// A water sample with organic matter in it, described by how much oxygen
/// its decay will eventually take and how fast the bugs are working.
@immutable
class Demand {
  const Demand({required this.ultimate, required this.rate});

  /// The ultimate BOD in milligrams a liter: all the oxygen this sample
  /// will ever take, given long enough.
  final double ultimate;

  /// k, the decay rate constant, base e, per day.
  final double rate;

  /// How much oxygen has been taken by day t. This is BOD exerted, and it
  /// is what a laboratory BOD test measures.
  double exertedAt(double days) =>
      ultimate * (1 - math.exp(-rate * days));

  /// What is left to take. Exerted plus remaining is always the ultimate.
  double remainingAt(double days) => ultimate * math.exp(-rate * days);

  /// The share of the ultimate that the test has caught by then.
  double fractionAt(double days) => 1 - math.exp(-rate * days);

  /// The same sample at another temperature. Warmer water works faster, so
  /// the RATE changes and the ultimate does not: the same organic matter
  /// still needs the same oxygen in the end.
  Demand atTemperature(double celsius, {double theta = 1.056}) => Demand(
        ultimate: ultimate,
        rate: rate * math.pow(theta, celsius - 20).toDouble(),
      );
}

/// The BOD curve: oxygen taken, climbing toward the ultimate and never
/// quite reaching it. The day the round asks about is marked, and the
/// ultimate is split there into what has been used and what is left.
class BodPainter extends CustomPainter {
  const BodPainter({
    required this.demand,
    required this.day,
    this.warmer,
    this.showSplit = true,
    this.note,
  });

  final Demand demand;

  /// The day the test is read at, usually five.
  final double day;

  /// A second curve for the same sample at another temperature.
  final Demand? warmer;

  /// Whether the bar at the marked day is split into used and left.
  final bool showSplit;
  final String? note;

  static const _left = 44.0;
  static const _bottom = 32.0;
  static const _top = 26.0;
  // Room on the right for the split bar, and only when there is one.
  double get _right => showSplit ? 92.0 : 34.0;

  double get _days => math.max(day * 3, 12);

  Offset _at(Size size, double days, double mg) => Offset(
        _left + (size.width - _left - _right) * days / _days,
        size.height -
            _bottom -
            (size.height - _bottom - _top) * mg / (demand.ultimate * 1.12),
      );

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1.2;
    canvas
      ..drawLine(Offset(_left, _top), Offset(_left, size.height - _bottom),
          axis)
      ..drawLine(Offset(_left, size.height - _bottom),
          Offset(size.width - _right + 30, size.height - _bottom), axis);
    writeOn(canvas, size, 'mg/L', const Offset(6, 12), AppColors.ink3,
        fontSize: 9);
    writeOn(canvas, size, 'days', Offset(size.width - _right - 4,
        size.height - 14), AppColors.ink3, fontSize: 9);

    // The ultimate, which the curve approaches and never reaches.
    final top = _at(size, 0, demand.ultimate).dy;
    for (var x = _left; x < size.width - _right + 30; x += 9) {
      canvas.drawLine(
          Offset(x, top),
          Offset(x + 5, top),
          Paint()
            ..color = AppColors.ink2
            ..strokeWidth = 1.2);
    }
    writeOn(canvas, size, 'ultimate ${_num(demand.ultimate)}',
        Offset(_left + 6, top - 14), AppColors.ink2, fontSize: 9);

    void curve(Demand d, Color tone, double width) {
      final path = Path();
      for (var i = 0; i <= 90; i++) {
        final t = _days * i / 90;
        final p = _at(size, t, d.exertedAt(t));
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = tone
            ..style = PaintingStyle.stroke
            ..strokeWidth = width);
    }

    if (warmer != null) curve(warmer!, AppColors.error, 2.2);
    curve(demand, AppColors.charcoal, 2.6);

    // The day the test is read at.
    final x = _at(size, day, 0).dx;
    for (var y = _top; y < size.height - _bottom; y += 8) {
      canvas.drawLine(
          Offset(x, y),
          Offset(x, y + 4),
          Paint()
            ..color = AppColors.ember
            ..strokeWidth = 1.2);
    }
    writeOn(canvas, size, 'day ${_num(day)}', Offset(x + 3, _top - 14),
        AppColors.ember, fontSize: 9);

    if (showSplit) {
      // The ultimate split at that day into what the bugs have taken and
      // what they have still to take. The two always add to the ultimate.
      final barX = size.width - _right + 42;
      final used = _at(size, 0, demand.exertedAt(day)).dy;
      final base = _at(size, 0, 0).dy;
      canvas
        ..drawRect(Rect.fromLTRB(barX, used, barX + 20, base),
            Paint()..color = AppColors.info.withValues(alpha: 0.55))
        ..drawRect(Rect.fromLTRB(barX, top, barX + 20, used),
            Paint()..color = AppColors.ink3.withValues(alpha: 0.22))
        ..drawRect(
            Rect.fromLTRB(barX, top, barX + 20, base),
            Paint()
              ..color = AppColors.ink2
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2);
      writeOn(canvas, size, 'left', Offset(barX + 24, (top + used) / 2 - 6),
          AppColors.ink2, fontSize: 9);
      writeOn(canvas, size, 'used', Offset(barX + 24, (used + base) / 2 - 6),
          AppColors.info, fontSize: 9);
    }

    writeOn(canvas, size, note ?? 'k ${demand.rate} per day',
        Offset(_left + 6, 4), AppColors.ink3, fontSize: 9);
    writeOn(canvas, size, 'BOD CURVE', Offset(size.width, 4), AppColors.ink3,
        fontSize: 8.5);
  }

  @override
  bool shouldRepaint(BodPainter old) =>
      old.demand != demand ||
      old.day != day ||
      old.warmer != warmer ||
      old.showSplit != showSplit ||
      old.note != note;
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();
