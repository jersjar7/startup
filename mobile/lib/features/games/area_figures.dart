import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';

/// One corner of a parcel, as it comes off a survey: a name and a pair of
/// coordinates.
@immutable
class Corner2 {
  const Corner2(this.name, this.x, this.y);

  final String name;
  final double x;
  final double y;
}

/// A parcel with straight sides and a monument at every corner, which is
/// what the coordinate method is for.
@immutable
class Parcel {
  const Parcel({required this.corners});

  final List<Corner2> corners;

  /// The shoelace sum, taken round the corners in the order given. Listed
  /// the wrong way round it comes out negative, which is why the formula
  /// takes the size of it and not the sign.
  double sumFor(List<int> order) {
    var total = 0.0;
    for (var k = 0; k < order.length; k++) {
      final a = corners[order[k]];
      final b = corners[order[(k + 1) % order.length]];
      total += a.x * b.y - b.x * a.y;
    }
    return total;
  }

  double get area => sumFor([for (var i = 0; i < corners.length; i++) i]).abs() / 2;

  /// Whether a listing of the corners walks the boundary without crossing
  /// itself. A bowtie has the same corners and is not the same parcel.
  bool walksTheBoundary(List<int> order) {
    for (var i = 0; i < order.length; i++) {
      final a1 = corners[order[i]];
      final a2 = corners[order[(i + 1) % order.length]];
      for (var j = i + 1; j < order.length; j++) {
        if (j == i) continue;
        final shareEnd = (j + 1) % order.length == i || j == (i + 1) % order.length;
        if (shareEnd) continue;
        final b1 = corners[order[j]];
        final b2 = corners[order[(j + 1) % order.length]];
        if (_crosses(a1, a2, b1, b2)) return false;
      }
    }
    return true;
  }

  static double _side(Corner2 a, Corner2 b, Corner2 p) =>
      (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x);

  static bool _crosses(Corner2 a1, Corner2 a2, Corner2 b1, Corner2 b2) {
    final d1 = _side(a1, a2, b1);
    final d2 = _side(a1, a2, b2);
    final d3 = _side(b1, b2, a1);
    final d4 = _side(b1, b2, a2);
    return ((d1 > 0) != (d2 > 0)) && ((d3 > 0) != (d4 > 0));
  }
}

/// A parcel drawn in plan on its grid, with a monument at every corner and
/// the coordinates written beside them. The order the corners are joined in
/// is the round's business, so it is handed in.
class ParcelPainter extends CustomPainter {
  const ParcelPainter({
    required this.parcel,
    required this.order,
    this.tone = AppColors.charcoal,
    this.showCoordinates = true,
    this.fill = true,
  });

  final Parcel parcel;
  final List<int> order;
  final Color tone;
  final bool showCoordinates;
  final bool fill;

  static (double, Offset) _fit(Size size, Parcel parcel) {
    var minX = parcel.corners.first.x, maxX = minX;
    var minY = parcel.corners.first.y, maxY = minY;
    for (final c in parcel.corners) {
      minX = math.min(minX, c.x);
      maxX = math.max(maxX, c.x);
      minY = math.min(minY, c.y);
      maxY = math.max(maxY, c.y);
    }
    const pad = 30.0;
    final scale = math.min((size.width - 2 * pad) / math.max(maxX - minX, 0.01),
        (size.height - 2 * pad - 10) / math.max(maxY - minY, 0.01));
    final left = (size.width - (maxX - minX) * scale) / 2 - minX * scale;
    final bottom =
        (size.height - 10 + (maxY - minY) * scale) / 2 + minY * scale;
    return (scale, Offset(left, bottom));
  }

  static Offset _at(Size size, Parcel parcel, Corner2 c) {
    final (scale, origin) = _fit(size, parcel);
    return Offset(origin.dx + c.x * scale, origin.dy - c.y * scale);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (var k = 0; k < order.length; k++) {
      final p = _at(size, parcel, parcel.corners[order[k]]);
      if (k == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();

    if (fill) {
      canvas.drawPath(
          path, Paint()..color = AppColors.sunbeam.withValues(alpha: 0.22));
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = tone
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    for (final c in parcel.corners) {
      final p = _at(size, parcel, c);
      // The monument at a corner, drawn the way a found pin is drawn.
      canvas
        ..drawCircle(p, 4.5, Paint()..color = AppColors.cream)
        ..drawCircle(
            p,
            4.5,
            Paint()
              ..color = AppColors.charcoal
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6)
        ..drawCircle(p, 1.6, Paint()..color = AppColors.charcoal);
      _write(
          canvas,
          size,
          showCoordinates
              ? '${c.name} (${_num(c.x)}, ${_num(c.y)})'
              : c.name,
          p + const Offset(7, -16),
          AppColors.ink2);
    }
    viewTag(canvas, size, Looking.plan);
  }

  @override
  bool shouldRepaint(ParcelPainter old) =>
      old.parcel != parcel ||
      old.order != order ||
      old.tone != tone ||
      old.showCoordinates != showCoordinates ||
      old.fill != fill;
}

/// Which rule an area can be worked out by.
enum Way3 { coordinates, trapezoid, simpson }

extension Way3Words on Way3 {
  String get plain => switch (this) {
        Way3.coordinates => 'By coordinates, off the corners',
        Way3.trapezoid => 'The trapezoidal rule',
        Way3.simpson => 'Simpson\'s one third rule',
      };
}

/// A strip of ground measured as offsets from a baseline: the picture the
/// two approximate rules are built on.
@immutable
class Strip {
  const Strip({required this.offsets, required this.step});

  /// The offsets in order along the baseline, in meters.
  final List<double> offsets;

  /// The interval between them, which the rules require to be constant.
  final double step;

  int get intervals => offsets.length - 1;

  double get baseline => step * intervals;

  /// Simpson's rule needs an odd count of offsets, which is an even count of
  /// intervals, because it takes them in pairs.
  bool get simpsonFits => offsets.length.isOdd;

  /// What the trapezoidal rule multiplies offset `i` by: the two ends are
  /// halved and everything between is taken whole.
  double trapezoidWeight(int i) =>
      (i == 0 || i == offsets.length - 1) ? 0.5 : 1;

  /// What Simpson's rule multiplies offset `i` by: the ends once, then four
  /// and two alternating in between.
  double simpsonWeight(int i) {
    if (i == 0 || i == offsets.length - 1) return 1;
    return i.isOdd ? 4 : 2;
  }

  double get byTrapezoid {
    var total = 0.0;
    for (var i = 0; i < offsets.length; i++) {
      total += trapezoidWeight(i) * offsets[i];
    }
    return step * total;
  }

  double get bySimpson {
    if (!simpsonFits) return double.nan;
    var total = 0.0;
    for (var i = 0; i < offsets.length; i++) {
      total += simpsonWeight(i) * offsets[i];
    }
    return step / 3 * total;
  }
}

/// The strip drawn in plan: the baseline chained along the bottom, an offset
/// measured off it at every interval, and the boundary running through the
/// far end of each one.
class OffsetsPainter extends CustomPainter {
  const OffsetsPainter({
    required this.strip,
    this.marked,
    this.picked,
    this.locked = false,
  });

  final Strip strip;

  /// The offset the round is asking about, drawn so it cannot be mistaken.
  final int? marked;
  final int? picked;
  final bool locked;

  static double _base(Size size) => size.height - 40;

  static double _x(Size size, Strip strip, int i) {
    final room = size.width - 40;
    return 20 + room * i / math.max(1, strip.intervals);
  }

  static double _y(Size size, Strip strip, double offset) {
    final tallest = strip.offsets.reduce(math.max);
    final room = _base(size) - 28;
    return _base(size) - room * offset / math.max(tallest, 0.01);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final base = _base(size);

    // The boundary: a line through the end of every offset.
    final edge = Path();
    for (var i = 0; i < strip.offsets.length; i++) {
      final p = Offset(_x(size, strip, i), _y(size, strip, strip.offsets[i]));
      if (i == 0) {
        edge.moveTo(p.dx, p.dy);
      } else {
        edge.lineTo(p.dx, p.dy);
      }
    }
    final ground = Path.from(edge)
      ..lineTo(_x(size, strip, strip.offsets.length - 1), base)
      ..lineTo(_x(size, strip, 0), base)
      ..close();
    canvas
      ..drawPath(ground, Paint()..color = AppColors.sunbeam.withValues(alpha: 0.2))
      ..drawPath(
          edge,
          Paint()
            ..color = AppColors.ink2
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8);

    // The baseline, chained along the bottom.
    canvas.drawLine(
        Offset(_x(size, strip, 0) - 10, base),
        Offset(_x(size, strip, strip.offsets.length - 1) + 10, base),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 2);

    for (var i = 0; i < strip.offsets.length; i++) {
      final x = _x(size, strip, i);
      final top = _y(size, strip, strip.offsets[i]);
      final Color tone;
      if (locked && marked == i) {
        tone = AppColors.forest;
      } else if (marked == i) {
        tone = AppColors.ember;
      } else {
        tone = AppColors.ink3;
      }
      canvas.drawLine(
          Offset(x, base),
          Offset(x, top),
          Paint()
            ..color = tone
            ..strokeWidth = marked == i ? 3 : 1.4);
      canvas
        ..drawCircle(Offset(x, base), 3, Paint()..color = AppColors.charcoal)
        ..drawCircle(Offset(x, top), 2.6, Paint()..color = tone);
      _write(canvas, size, _num(strip.offsets[i]), Offset(x - 6, top - 15),
          tone);
    }

    // How many offsets there are, which is what decides whether Simpson can
    // be used at all, and how far apart they were chained.
    _write(canvas, size, '${strip.offsets.length} offsets at ${_num(strip.step)} m',
        Offset(10, size.height - 28), AppColors.ink3);
    _write(canvas, size, 'baseline', Offset(size.width - 74, base + 6),
        AppColors.charcoal);
    viewTag(canvas, size, Looking.plan);
  }

  @override
  bool shouldRepaint(OffsetsPainter old) =>
      old.strip != strip ||
      old.marked != marked ||
      old.picked != picked ||
      old.locked != locked;
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();

void _write(Canvas canvas, Size size, String text, Offset at, Color color) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
    textDirection: TextDirection.ltr,
  )..layout();
  var x = at.dx;
  if (x + painter.width > size.width - 2) x = size.width - 2 - painter.width;
  if (x < 2) x = 2;
  final patch =
      Rect.fromLTWH(x - 2, at.dy - 1, painter.width + 4, painter.height + 2);
  canvas.drawRect(
      patch, Paint()..color = AppColors.cream.withValues(alpha: 0.92));
  painter.paint(canvas, Offset(x, at.dy));
}
