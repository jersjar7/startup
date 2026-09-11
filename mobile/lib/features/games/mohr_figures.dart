import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// The state of stress at a point, in two dimensions.
///
/// Everything the items ask comes out of these three numbers, so a round
/// declares the stresses and the circle, the principal values and the worst
/// shear are all worked out rather than written down beside it.
@immutable
class Stress {
  const Stress({required this.x, required this.y, required this.xy});

  /// Normal stresses on the two faces, tension positive.
  final double x;
  final double y;

  /// Shear on those faces.
  final double xy;

  /// The middle of the circle: the average of the two normal stresses.
  double get center => (x + y) / 2;

  /// The radius: the half difference and the shear, combined the way the
  /// sides of a right triangle are.
  double get radius =>
      math.sqrt(math.pow((x - y) / 2, 2) + xy * xy).toDouble();

  /// Algebraically largest and smallest, which is not the same as biggest and
  /// smallest in size.
  double get s1 => center + radius;
  double get s2 => center - radius;

  /// The worst shear on any plane through the axis you are looking down.
  double get inPlaneShear => radius;

  /// The third principal stress, which is zero for a point on a free surface
  /// and is the one everybody forgets.
  static const s3 = 0.0;

  /// The worst shear on ANY plane, including the ones out of the page. It is
  /// half the spread between the largest and smallest of the three principal
  /// stresses, and the third one is zero.
  double get absoluteShear {
    final all = [s1, s2, s3];
    return (all.reduce(math.max) - all.reduce(math.min)) / 2;
  }

  /// Whether the circle keeps clear of the origin, which is exactly when the
  /// worst shear is NOT the in-plane radius.
  bool get clearOfZero => s1 * s2 > 0;

  /// Where the face the stresses were given on sits on the circle.
  Offset get xFace => Offset(x, xy);
  Offset get yFace => Offset(y, -xy);
}

/// The piece of the stress plane a drawing covers.
///
/// Framed to the circles it has to hold AND to the origin, which has to stay
/// on the page: whether the circle reaches zero is the whole question in one
/// of the items. Symmetric axes would push a circle that sits far out in
/// tension into a corner and shrink it to nothing.
@immutable
class Window {
  const Window({required this.lo, required this.hi, required this.tall});

  factory Window.over(List<Stress> all) {
    var lo = 0.0;
    var hi = 0.0;
    var tall = 0.0;
    for (final s in all) {
      lo = math.min(lo, s.s2);
      hi = math.max(hi, s.s1);
      tall = math.max(tall, s.radius);
    }
    final pad = math.max((hi - lo) * 0.12, tall * 0.12);
    return Window(lo: lo - pad, hi: hi + pad, tall: math.max(tall, 1) * 1.25);
  }

  /// The normal stresses the drawing runs between, and the biggest shear it
  /// has to fit above and below the axis.
  final double lo;
  final double hi;
  final double tall;
}

/// A named place on Mohr's circle.
enum Spot { s1, s2, center, topShear, xFace }

extension SpotNames on Spot {
  String get plain => switch (this) {
        Spot.s1 => 'the largest principal stress',
        Spot.s2 => 'the smallest principal stress',
        Spot.center => 'the center of the circle',
        Spot.topShear => 'the largest in-plane shear',
        Spot.xFace => 'the face the stresses were given on',
      };
}

/// Mohr's circle, drawn on its axes.
class MohrPainter extends CustomPainter {
  const MohrPainter({
    required this.stress,
    required this.span,
    this.spots = const <Spot>[],
    this.picked,
    this.truth,
    this.locked = false,
    this.tone = AppColors.info,
    this.showZero = true,
    this.label = '',
  });

  final Stress stress;

  /// What the axes cover. Several circles drawn side by side share one of
  /// these, so their sizes and positions can be compared.
  final Window span;

  /// Places marked on the circle for tapping.
  final List<Spot> spots;

  final Spot? picked;
  final Spot? truth;
  final bool locked;
  final Color tone;

  /// Mark the origin, which is where the third principal stress sits.
  final bool showZero;

  final String label;

  static const _padX = 16.0;

  /// Where a stress pair lands on the canvas. ONE scale for both axes, so a
  /// circle is drawn as a circle and never as an ellipse.
  static Offset at(Size size, Window span, Offset point) {
    final scale = _scaleFor(size, span);
    return Offset(
      _padX + (point.dx - span.lo) * scale,
      size.height / 2 - point.dy * scale,
    );
  }

  static double _scaleFor(Size size, Window span) => math.min(
        (size.width - _padX * 2) / (span.hi - span.lo),
        (size.height - 30) / (2 * span.tall),
      );

  /// Where a named place is drawn, so tap targets sit on the marks.
  static Offset spotAt(Stress s, Size size, Window span, Spot spot) {
    final point = switch (spot) {
      Spot.s1 => Offset(s.s1, 0),
      Spot.s2 => Offset(s.s2, 0),
      Spot.center => Offset(s.center, 0),
      Spot.topShear => Offset(s.center, s.radius),
      Spot.xFace => s.xFace,
    };
    return at(size, span, point);
  }

  /// The marked place nearest a tap, if the tap is near one at all.
  static Spot? nearest(
    Stress s,
    Size size,
    Window span,
    List<Spot> spots,
    Offset tap, {
    double within = 30,
  }) {
    Spot? best;
    var gap = within;
    for (final spot in spots) {
      final d = (spotAt(s, size, span, spot) - tap).distance;
      if (d < gap) {
        gap = d;
        best = spot;
      }
    }
    return best;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1;
    final mid = at(size, span, Offset.zero);
    canvas
      ..drawLine(Offset(_padX, mid.dy), Offset(size.width - _padX, mid.dy), axis)
      ..drawLine(Offset(mid.dx, 8), Offset(mid.dx, size.height - 18), axis);

    // Above the axis line rather than below it: a circle sitting far out in
    // tension runs right along the bottom of the axis and the label was
    // landing inside it.
    _write(canvas, 'normal stress',
        Offset(size.width - 74, size.height - 14), AppColors.ink3);
    _write(canvas, 'shear', Offset(mid.dx + 4, 6), AppColors.ink3);

    if (showZero) {
      canvas.drawCircle(mid, 2.5, Paint()..color = AppColors.ink2);
      _write(canvas, '0', Offset(mid.dx - 10, mid.dy + 4), AppColors.ink2);
    }

    final middle = at(size, span, Offset(stress.center, 0));
    final r = stress.radius * _scaleFor(size, span);
    if (r > 1) {
      canvas.drawCircle(
        middle,
        r,
        Paint()
          ..color = tone
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    } else {
      // A state with no shear on any plane is a single point, and drawing it
      // as a dot is the honest picture rather than a tiny circle.
      canvas.drawCircle(middle, 4.5, Paint()..color = tone);
    }

    for (final spot in spots) {
      final p = spotAt(stress, size, span, spot);
      final isTruth = locked && spot == truth;
      final chosen = picked == spot;
      final color = isTruth
          ? AppColors.forest
          : (locked && chosen)
              ? AppColors.error
              : chosen
                  ? AppColors.ember
                  : AppColors.ink2;
      canvas
        ..drawCircle(p, 6, Paint()..color = AppColors.cream)
        ..drawCircle(p, chosen || isTruth ? 5.5 : 4, Paint()..color = color);
    }

    if (label.isNotEmpty) {
      _write(canvas, label, const Offset(4, 2), AppColors.ink3);
    }
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
  bool shouldRepaint(MohrPainter old) =>
      old.stress != stress ||
      old.picked != picked ||
      old.locked != locked ||
      old.spots != spots;
}

/// The little square of material the stresses act on.
class ElementPainter extends CustomPainter {
  const ElementPainter({required this.stress, this.label = ''});

  final Stress stress;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = Offset(size.width / 2, size.height / 2);
    final half = math.min(size.width, size.height) * 0.22;
    final box = Rect.fromCenter(
        center: mid, width: half * 2, height: half * 2);
    canvas
      ..drawRect(box, Paint()..color = AppColors.cream)
      ..drawRect(
        box,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );

    // Normal stresses: arrows pointing out for tension, in for compression.
    _pair(canvas, box, stress.x, horizontal: true);
    _pair(canvas, box, stress.y, horizontal: false);
    if (stress.xy.abs() > 0) _shear(canvas, box, stress.xy);

    if (label.isNotEmpty) {
      TextPainter(
        text: TextSpan(
          text: label,
          style: AppTheme.mono(size: 10, color: AppColors.ink3),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(canvas, const Offset(4, 2));
    }
  }

  void _pair(Canvas canvas, Rect box, double value, {required bool horizontal}) {
    if (value == 0) return;
    final out = value > 0;
    const reach = 26.0;
    for (final side in [1.0, -1.0]) {
      final from = horizontal
          ? Offset(box.center.dx + side * box.width / 2, box.center.dy)
          : Offset(box.center.dx, box.center.dy + side * box.height / 2);
      final away = horizontal
          ? Offset(side * reach, 0)
          : Offset(0, side * reach);
      final tip = out ? from + away : from + away;
      out
          ? _arrow(canvas, from, tip)
          : _arrow(canvas, tip, from);
    }
    final text = '${value > 0 ? '' : '-'}${value.abs().round()}';
    _label(
      canvas,
      text,
      horizontal
          ? Offset(box.right + reach + 4, box.center.dy - 6)
          // Beside the tip of the top arrow rather than above it: above it
          // runs off the top of a short panel.
          : Offset(box.center.dx + 10, box.top - reach - 2),
    );
  }

  void _shear(Canvas canvas, Rect box, double value) {
    const reach = 18.0;
    // Four arrows that make a SHEAR and not a rotation. The top and bottom
    // pair turn the block one way and the two side arrows have to turn it
    // back, or the element would be spinning: that is what complementary
    // shear means, and drawing all four circulating the same way was wrong.
    _arrow(canvas, Offset(box.left, box.top - 6),
        Offset(box.left + reach * 1.6, box.top - 6));
    _arrow(canvas, Offset(box.right, box.bottom + 6),
        Offset(box.right - reach * 1.6, box.bottom + 6));
    _arrow(canvas, Offset(box.right + 6, box.bottom),
        Offset(box.right + 6, box.bottom - reach * 1.6));
    _arrow(canvas, Offset(box.left - 6, box.top),
        Offset(box.left - 6, box.top + reach * 1.6));
    _label(canvas, value.abs().round().toString(),
        Offset(box.right + 10, box.center.dy + 6));
  }

  void _arrow(Canvas canvas, Offset from, Offset to) {
    final paint = Paint()
      ..color = AppColors.ember
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(from, to, paint);
    final along = (to - from) / (to - from).distance;
    final side = Offset(-along.dy, along.dx);
    canvas.drawPath(
      Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo(to.dx - along.dx * 7 + side.dx * 3.5,
            to.dy - along.dy * 7 + side.dy * 3.5)
        ..lineTo(to.dx - along.dx * 7 - side.dx * 3.5,
            to.dy - along.dy * 7 - side.dy * 3.5)
        ..close(),
      Paint()..color = AppColors.ember,
    );
  }

  void _label(Canvas canvas, String text, Offset at) {
    TextPainter(
      text: TextSpan(
        text: text,
        style: AppTheme.mono(size: 10, color: AppColors.charcoal),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, at);
  }

  @override
  bool shouldRepaint(ElementPainter old) => old.stress != stress;
}
