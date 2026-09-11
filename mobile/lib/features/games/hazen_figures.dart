import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// A water main, described the way Hazen-Williams describes one: by what it
/// is made of and the single coefficient that stands for it.
@immutable
class Main {
  const Main({required this.material, required this.coefficient});

  final String material;

  /// C. Higher is smoother, which is the opposite of Manning's n.
  final double coefficient;

  /// What it carries, relative to a main of C = 100 with the same diameter,
  /// length and gradient. C enters the equation in the first power, so this
  /// is a plain proportion with no root and no fractional exponent.
  double get carries => coefficient / 100;
}

/// Two mains running between the same two points, with the same hydraulic
/// grade line falling across both. Everything is equal except the pipe
/// wall, so the flow arrows are in the ratio of the two coefficients and
/// nothing else.
class MainsPainter extends CustomPainter {
  const MainsPainter({
    required this.top,
    required this.bottom,
    this.answered = false,
  });

  final Main top;
  final Main bottom;

  /// Whether to write what each one carries. Held back while that is the
  /// question.
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final most = math.max(top.carries, bottom.carries);
    _run(canvas, size, top, 'A', 58, most);
    _run(canvas, size, bottom, 'B', size.height / 2 + 40, most);
    writeOn(canvas, size, 'the same fall in head across both',
        Offset(8, size.height - 44), AppColors.ink3, fontSize: 9);
    viewTag(canvas, size, Looking.elevation, note: 'along the main');
  }

  void _run(
      Canvas canvas, Size size, Main main, String name, double y, double most) {
    const left = 46.0;
    final right = size.width - 26;
    const bore = 15.0;

    // The hydraulic grade line, falling the same amount on both.
    final hgl = Path()
      ..moveTo(left, y - 26)
      ..lineTo(right, y - 8);
    for (var t = 0.0; t < 1; t += 0.05) {
      canvas.drawLine(
          Offset(left + (right - left) * t, y - 26 + 18 * t),
          Offset(left + (right - left) * (t + 0.028),
              y - 26 + 18 * (t + 0.028)),
          Paint()
            ..color = AppColors.ink3
            ..strokeWidth = 1);
    }
    canvas.drawPath(
        hgl,
        Paint()
          ..color = Colors.transparent
          ..style = PaintingStyle.stroke);
    writeOn(canvas, size, 'grade line', Offset(left + 4, y - 39),
        AppColors.ink3, fontSize: 8.5);

    // The pipe itself, as a barrel with a wall.
    final barrel = Path()
      ..addRect(Rect.fromLTRB(left, y, right, y + bore));
    canvas.drawPath(barrel, waterFill);
    for (final edge in [y, y + bore]) {
      canvas.drawLine(
          Offset(left, edge),
          Offset(right, edge),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 1.6);
    }

    // How much it carries, as an arrow inside the barrel.
    final length = (right - left - 30) * main.carries / most;
    final mid = y + bore / 2;
    canvas
      ..drawLine(
          Offset(left + 8, mid),
          Offset(left + 8 + length, mid),
          Paint()
            ..color = AppColors.info
            ..strokeWidth = 3)
      ..drawPath(
          Path()
            ..moveTo(left + 14 + length, mid)
            ..lineTo(left + 6 + length, mid - 4.5)
            ..lineTo(left + 6 + length, mid + 4.5)
            ..close(),
          Paint()..color = AppColors.info);

    writeOn(canvas, size, name, Offset(8, y + 1), AppColors.ink2,
        fontSize: 11);
    writeOn(canvas, size, '${main.material}, C ${_num(main.coefficient)}',
        Offset(left + 4, y + bore + 4), AppColors.charcoal, fontSize: 9.5);
    if (answered) {
      writeOn(canvas, size, 'carries ${main.carries.toStringAsFixed(2)}',
          Offset(right - 84, y - 13), AppColors.forest, fontSize: 9);
    }
  }

  @override
  bool shouldRepaint(MainsPainter old) =>
      old.top != top || old.bottom != bottom || old.answered != answered;
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();
