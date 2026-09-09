import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// A paired reading. Whole numbers, so a scatter can be drawn on a grid a
/// student can count squares on.
@immutable
class Pair {
  const Pair(this.x, this.y);
  final int x;
  final int y;
}

/// A straight line in the plot's own units, so a candidate regression line can
/// be described the way the lesson describes one.
@immutable
class FitLine {
  const FitLine(this.intercept, this.slope, {this.label});
  final double intercept;
  final double slope;
  final String? label;

  double at(double x) => intercept + slope * x;
}

/// A scatter of paired readings, with whatever the round needs drawn over it.
///
/// Correlation is a picture before it is a formula with four sums in it, and
/// so is a residual: the vertical gap between a reading and the line. Both can
/// be read off a plot without a calculator, which is the only way either gets
/// understood rather than memorised.
class ScatterPainter extends CustomPainter {
  const ScatterPainter({
    required this.points,
    required this.xTo,
    required this.yTo,
    this.lines = const [],
    this.pickedLine,
    this.truthLine,
    this.revealed = false,
    this.meanPoint = false,
    this.residualsFor,
  });

  final List<Pair> points;

  /// Both axes start at zero, because a regression intercept is meaningless
  /// on a plot whose origin has been cropped away.
  final int xTo;
  final int yTo;

  /// Candidate lines, drawn and lettered.
  final List<FitLine> lines;
  final int? pickedLine;
  final int? truthLine;
  final bool revealed;

  /// Marks the point the means meet at, which every regression line has to
  /// pass through.
  final bool meanPoint;

  /// Draws the vertical gap from each reading to this line.
  final FitLine? residualsFor;

  /// Where a line enters and leaves the plotted box, in plot units.
  ///
  /// Clamping the two endpoints' y independently would draw a line with a
  /// different slope than the one it claims to have, which on an item about
  /// slopes is not a cosmetic problem. This walks the x range instead and
  /// stops the line where it actually leaves the box.
  (double, double)? _xSpan(FitLine line) {
    var lo = 0.0;
    var hi = xTo.toDouble();
    if (line.slope != 0) {
      final atZero = -line.intercept / line.slope;
      final atTop = (yTo - line.intercept) / line.slope;
      final enter = atZero < atTop ? atZero : atTop;
      final leave = atZero < atTop ? atTop : atZero;
      if (enter > lo) lo = enter;
      if (leave < hi) hi = leave;
    } else if (line.intercept < 0 || line.intercept > yTo) {
      return null;
    }
    return hi <= lo ? null : (lo, hi);
  }

  static const _padL = 30.0;
  static const _padB = 26.0;
  static const _padT = 12.0;
  static const _padR = 14.0;

  Offset _at(Size size, double x, double y) => Offset(
    _padL + x / xTo * (size.width - _padL - _padR),
    size.height - _padB - y / yTo * (size.height - _padB - _padT),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = AppColors.ink2
      ..strokeWidth = 1.4;
    canvas.drawLine(_at(size, 0, 0), _at(size, xTo.toDouble(), 0), axis);
    canvas.drawLine(_at(size, 0, 0), _at(size, 0, yTo.toDouble()), axis);

    final fine = Paint()..color = AppColors.charcoal.withValues(alpha: 0.06);
    for (var i = 1; i <= xTo; i++) {
      canvas.drawLine(
        _at(size, i.toDouble(), 0),
        _at(size, i.toDouble(), yTo.toDouble()),
        fine,
      );
    }
    for (var i = 1; i <= yTo; i++) {
      canvas.drawLine(
        _at(size, 0, i.toDouble()),
        _at(size, xTo.toDouble(), i.toDouble()),
        fine,
      );
    }
    _label(canvas, 'x', _at(size, xTo.toDouble(), 0) + const Offset(6, 12));
    _label(canvas, 'y', _at(size, 0, yTo.toDouble()) + const Offset(-14, -6));

    final residual = residualsFor;
    if (residual != null) {
      for (final p in points) {
        final onLine = residual.at(p.x.toDouble()).clamp(0.0, yTo.toDouble());
        canvas.drawLine(
          _at(size, p.x.toDouble(), p.y.toDouble()),
          _at(size, p.x.toDouble(), onLine),
          Paint()
            ..color = AppColors.ember.withValues(alpha: 0.55)
            ..strokeWidth = 2,
        );
      }
    }

    for (final (i, line) in lines.indexed) {
      final span = _xSpan(line);
      if (span == null) continue;
      final isTruth = revealed && truthLine == i;
      final isWrong = revealed && pickedLine == i && truthLine != i;
      final color = isTruth
          ? AppColors.forest
          : isWrong
          ? AppColors.error
          : pickedLine == i
          ? AppColors.ember
          : AppColors.ink3;
      final (from, to) = span;
      canvas.drawLine(
        _at(size, from, line.at(from)),
        _at(size, to, line.at(to)),
        Paint()
          ..color = color
          ..strokeWidth = pickedLine == i || isTruth ? 3.2 : 2,
      );
      final label = line.label;
      if (label != null) {
        // At the end of the line, and off to whichever side has room.
        final at = _at(size, to, line.at(to));
        _label(
          canvas,
          label,
          at + Offset(to >= xTo - 0.01 ? 8 : 0, to >= xTo - 0.01 ? 0 : -12),
          color: color,
        );
      }
    }

    if (residual != null) {
      final span = _xSpan(residual);
      if (span != null) {
        final (from, to) = span;
        canvas.drawLine(
          _at(size, from, residual.at(from)),
          _at(size, to, residual.at(to)),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 2.4,
        );
      }
    }

    for (final p in points) {
      canvas.drawCircle(
        _at(size, p.x.toDouble(), p.y.toDouble()),
        5,
        Paint()..color = AppColors.charcoal,
      );
    }

    if (meanPoint && points.isNotEmpty) {
      final mx = points.map((p) => p.x).reduce((a, b) => a + b) / points.length;
      final my = points.map((p) => p.y).reduce((a, b) => a + b) / points.length;
      final at = _at(size, mx, my);
      canvas.drawCircle(at, 9, Paint()..color = AppColors.sunbeamBg);
      canvas.drawCircle(
        at,
        7,
        Paint()
          ..color = AppColors.sunbeam
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      _label(canvas, 'means', at + const Offset(0, -17),
          color: const Color(0xFFB07C0C));
    }
  }

  void _label(
    Canvas canvas,
    String text,
    Offset at, {
    Color color = AppColors.ink3,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(ScatterPainter old) =>
      old.pickedLine != pickedLine ||
      old.revealed != revealed ||
      old.points != points;
}
