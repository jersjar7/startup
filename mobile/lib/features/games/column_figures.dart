import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'section_figures.dart';

/// How one end of a column is held.
enum End { pinned, fixed, free }

extension EndWords on End {
  String get plain => switch (this) {
        End.pinned => 'pinned',
        End.fixed => 'fixed',
        End.free => 'free',
      };
}

/// A column, what holds each end, and what it is made of.
///
/// The effective length factor is worked out from the two ends rather than
/// declared, so a round cannot draw one arrangement and score another.
@immutable
class Post {
  const Post({
    required this.length,
    required this.top,
    required this.bottom,
    this.e = 200000,
    this.i = 20e6,
    this.area = 5000,
    this.radius = 40,
    this.yieldStress = 250,
  });

  /// In millimeters.
  final double length;

  final End top;
  final End bottom;

  /// Megapascals, and the minimum second moment of area in mm to the fourth.
  final double e;
  final double i;
  final double area;

  /// Minimum radius of gyration, in millimeters.
  final double radius;

  final double yieldStress;

  /// The four cases the handbook lists, read off the two ends.
  double get k {
    final ends = {top, bottom};
    if (ends.contains(End.free)) return 2;
    if (ends.length == 1) return top == End.fixed ? 0.5 : 1;
    return 0.7;
  }

  /// The distance between the points the buckled shape passes straight
  /// through, which is what the factor is really measuring.
  double get effectiveLength => k * length;

  /// Euler's load. Note what is NOT in it: the strength of the steel.
  double get criticalLoad => math.pi * math.pi * e * i / math.pow(effectiveLength, 2);

  double get slenderness => effectiveLength / radius;

  double get criticalStress =>
      math.pi * math.pi * e / math.pow(slenderness, 2);

  /// Where buckling and yielding meet, for this material.
  double get transition => math.pi * math.sqrt(e / yieldStress);

  /// What actually happens first. Within a few percent of each other, neither
  /// governs cleanly and the codes have a curve for it.
  Governs get governs {
    final ratio = criticalStress / yieldStress;
    if (ratio > 0.95 && ratio < 1.05) return Governs.together;
    return ratio < 1 ? Governs.buckling : Governs.yielding;
  }
}

/// Which failure arrives first.
enum Governs { buckling, yielding, together }

/// The shape a column buckles into, which is where its effective length comes
/// from: it is the distance between the points the curve passes straight
/// through.
List<Offset> buckledShape(Post post) {
  final out = <Offset>[];
  const steps = 60;
  // The shapes below are written with the STIFFER end at the bottom, which is
  // how a cantilever column is normally drawn. When a round holds it the
  // other way up the curve has to be turned over with it, or the drawing
  // shows a free end that cannot move.
  final flip = post.bottom == End.free ||
      (post.bottom == End.pinned && post.top == End.fixed);
  for (var k = 0; k <= steps; k++) {
    final x = flip ? 1 - k / steps : k / steps;
    final y = switch (post.k) {
      1.0 => math.sin(math.pi * x),
      0.5 => (1 - math.cos(2 * math.pi * x)) / 2,
      0.7 => x * x * (1 - x),
      _ => 1 - math.cos(math.pi * x / 2),
    };
    out.add(Offset(k / steps, y));
  }
  var peak = 0.0;
  for (final p in out) {
    peak = math.max(peak, p.dy.abs());
  }
  return [for (final p in out) Offset(p.dx, p.dy / peak)];
}

/// A column drawn upright with its two ends shown, and optionally the shape
/// it buckles into.
class PostPainter extends CustomPainter {
  const PostPainter({
    required this.post,
    this.bent = false,
    this.tone = AppColors.ember,
  });

  final Post post;

  /// Draw the buckled shape rather than the straight column.
  final bool bent;

  final Color tone;

  /// More room above than below: the load arrow sits over the top end, and
  /// with the same padding both ways it landed on the support drawing.
  static const _padTop = 42.0;
  static const _padBottom = 26.0;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final top = _padTop;
    final bottom = size.height - _padBottom;
    final ink = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    if (bent) {
      final swing = math.min(size.width / 2 - 30, 34.0);
      final path = Path();
      final shape = buckledShape(post);
      for (var k = 0; k < shape.length; k++) {
        final p = Offset(
          x + shape[k].dy * swing,
          bottom - (bottom - top) * shape[k].dx,
        );
        k == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas
        ..drawLine(
          Offset(x, top),
          Offset(x, bottom),
          Paint()
            ..color = AppColors.ink3
            ..strokeWidth = 1,
        )
        ..drawPath(
          path,
          Paint()
            ..color = tone
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
    } else {
      canvas.drawLine(
        Offset(x, top),
        Offset(x, bottom),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    }

    _drawEnd(canvas, size, Offset(x, top), post.top, up: true, ink: ink);
    _drawEnd(canvas, size, Offset(x, bottom), post.bottom, up: false, ink: ink);

    // The load, pressing down on the top.
    final headY = top - 18;
    canvas
      ..drawLine(
        Offset(x, headY - 12),
        Offset(x, headY),
        Paint()
          ..color = AppColors.info
          ..strokeWidth = 2,
      )
      ..drawPath(
        Path()
          ..moveTo(x, headY + 6)
          ..lineTo(x - 4, headY - 2)
          ..lineTo(x + 4, headY - 2)
          ..close(),
        Paint()..color = AppColors.info,
      );
    _write(canvas, 'P', Offset(x + 7, headY - 12), AppColors.info);
  }

  void _drawEnd(Canvas canvas, Size size, Offset at, End end,
      {required bool up, required Paint ink}) {
    final sign = up ? -1.0 : 1.0;
    switch (end) {
      case End.pinned:
        canvas.drawPath(
          Path()
            ..moveTo(at.dx, at.dy)
            ..lineTo(at.dx - 10, at.dy + sign * 14)
            ..lineTo(at.dx + 10, at.dy + sign * 14)
            ..close(),
          ink,
        );
        canvas.drawLine(
          Offset(at.dx - 16, at.dy + sign * 14),
          Offset(at.dx + 16, at.dy + sign * 14),
          ink,
        );
        _hatch(canvas, at.dx, at.dy + sign * 14, sign, ink);
      case End.fixed:
        canvas.drawLine(
          Offset(at.dx - 18, at.dy),
          Offset(at.dx + 18, at.dy),
          ink,
        );
        _hatch(canvas, at.dx, at.dy, sign, ink);
      case End.free:
        // Nothing holds it, and drawing nothing is the honest picture.
        break;
    }
  }

  void _hatch(Canvas canvas, double x, double y, double sign, Paint ink) {
    for (var h = -14.0; h <= 14; h += 7) {
      canvas.drawLine(
        Offset(x + h, y),
        Offset(x + h - 5, y + sign * 6),
        ink,
      );
    }
  }

  void _write(Canvas canvas, String text, Offset at, Color color) {
    TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 11, color: color)),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, at);
  }

  @override
  bool shouldRepaint(PostPainter old) =>
      old.post != post || old.bent != bent || old.tone != tone;
}

/// The column curve: the stress a column fails at, against how slender it is.
///
/// Euler's hyperbola falls away as the column gets longer, and the yield
/// stress caps it off at the short end. Where they cross is the slenderness
/// that separates a column that buckles from one that squashes.
class ColumnCurvePainter extends CustomPainter {
  const ColumnCurvePainter({
    required this.post,
    this.maxSlenderness = 220,
    this.mark = true,
  });

  final Post post;
  final double maxSlenderness;

  /// Put a dot where this column sits.
  final bool mark;

  static const _padL = 30.0;
  static const _padB = 22.0;
  static const _padT = 12.0;

  /// The top of the stress axis, the SAME on every drawing in the item.
  ///
  /// Scaling it to each column's yield stress redrew Euler's curve every
  /// round, which hid the one thing worth seeing: a stronger steel moves the
  /// cap and leaves the curve exactly where it was.
  static const _ceiling = 620.0;

  Offset _at(Size size, double slenderness, double stress) => Offset(
        _padL + slenderness / maxSlenderness * (size.width - _padL - 10),
        size.height - _padB - stress / _ceiling * (size.height - _padB - _padT),
      );

  /// Where the column being asked about is drawn, so a tap target could sit
  /// on it.
  Offset markAt(Size size) => _at(
        size,
        math.min(post.slenderness, maxSlenderness),
        math.min(post.criticalStress, _ceiling),
      );

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1;
    canvas
      ..drawLine(_at(size, 0, 0), _at(size, maxSlenderness, 0), axis)
      ..drawLine(_at(size, 0, 0), _at(size, 0, _ceiling), axis);

    // The yield cap.
    final capPaint = Paint()
      ..color = AppColors.error
      ..strokeWidth = 1.6;
    final capFrom = _at(size, 0, post.yieldStress);
    final capTo = _at(size, maxSlenderness, post.yieldStress);
    for (var x = capFrom.dx; x < capTo.dx; x += 8) {
      canvas.drawLine(Offset(x, capFrom.dy), Offset(x + 4, capFrom.dy), capPaint);
    }

    // Euler's hyperbola.
    final path = Path();
    var started = false;
    for (var s = 1.0; s <= maxSlenderness; s += 1) {
      final stress = math.pi * math.pi * post.e / (s * s);
      if (stress > _ceiling) continue;
      final p = _at(size, s, stress);
      started ? path.lineTo(p.dx, p.dy) : path.moveTo(p.dx, p.dy);
      started = true;
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.info
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    // Where the two meet, which is the slenderness that divides long from
    // short for this material.
    final cross = _at(size, post.transition, post.yieldStress);
    canvas.drawLine(
      Offset(cross.dx, cross.dy),
      Offset(cross.dx, size.height - _padB),
      Paint()
        ..color = AppColors.ink3
        ..strokeWidth = 0.8,
    );

    if (mark) {
      final p = markAt(size);
      canvas
        ..drawCircle(p, 7, Paint()..color = AppColors.cream)
        ..drawCircle(p, 5, Paint()..color = AppColors.ember);
    }

    _write(canvas, 'stress', const Offset(2, 2), AppColors.ink3);
    _write(canvas, 'slenderness KL/r',
        Offset(size.width - 96, size.height - 13), AppColors.ink3);
    _write(canvas, 'yield', Offset(_padL + 2, capFrom.dy - 12),
        AppColors.error);
    _write(canvas, 'short', Offset(_padL + 4, size.height - 13),
        AppColors.ink3);
    _write(canvas, 'long', Offset(cross.dx + 6, size.height - 13),
        AppColors.ink3);
  }

  void _write(Canvas canvas, String text, Offset at, Color color) {
    TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 9.5, color: color)),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, at);
  }

  @override
  bool shouldRepaint(ColumnCurvePainter old) => old.post != post;
}

/// A cross section with both of its centroidal axes drawn on it, for asking
/// which one a column would fold about.
class AxisPainter extends CustomPainter {
  const AxisPainter({
    required this.profile,
    this.highlight,
    this.locked = false,
    this.truth,
  });

  final Profile profile;

  /// Which axis the reader has chosen: true for the horizontal one.
  final bool? highlight;

  final bool locked;
  final bool? truth;

  @override
  void paint(Canvas canvas, Size size) {
    ProfilePainter(profile: profile).paint(canvas, size);

    final box = profile.bounds;
    final centroid = profile.centroid;
    final left = ProfilePainter.toScreen(
        profile, Offset(box.left, centroid.dy), size);
    final right = ProfilePainter.toScreen(
        profile, Offset(box.right, centroid.dy), size);
    final bottom = ProfilePainter.toScreen(
        profile, Offset(centroid.dx, box.top), size);
    final top = ProfilePainter.toScreen(
        profile, Offset(centroid.dx, box.top + box.height), size);

    Color toneFor(bool horizontal) {
      if (locked && truth == horizontal) return AppColors.forest;
      if (locked && highlight == horizontal) return AppColors.error;
      if (highlight == horizontal) return AppColors.ember;
      return AppColors.ink3;
    }

    for (final (horizontal, a, b) in [
      (true, Offset(left.dx - 14, left.dy), Offset(right.dx + 14, right.dy)),
      (false, Offset(bottom.dx, bottom.dy + 14), Offset(top.dx, top.dy - 14)),
    ]) {
      final tone = toneFor(horizontal);
      final heavy = highlight == horizontal || (locked && truth == horizontal);
      final paint = Paint()
        ..color = tone
        ..strokeWidth = heavy ? 2.6 : 1.2;
      // Drawn as a chain line, which is how an axis is drawn on a section.
      final along = (b - a) / (b - a).distance;
      for (var d = 0.0; d < (b - a).distance; d += 9) {
        canvas.drawLine(a + along * d, a + along * math.min(d + 5, (b - a).distance), paint);
      }
      final label = horizontal ? 'x' : 'y';
      final at = horizontal
          ? Offset(b.dx + 2, b.dy - 6)
          : Offset(b.dx + 4, b.dy - 2);
      TextPainter(
        text: TextSpan(text: label, style: AppTheme.mono(size: 11, color: tone)),
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(canvas, at);
    }
  }

  @override
  bool shouldRepaint(AxisPainter old) =>
      old.highlight != highlight ||
      old.locked != locked ||
      old.profile != profile;
}
