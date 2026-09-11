import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';

/// The four measurements a tensile test has on the table at any moment: the
/// two the bar started with and the two it has right now.
///
/// Every definition in this lesson is a force or a stretch divided by one of
/// these, and picking the wrong one is the whole of its trap list.
enum Dim { areaBefore, lengthBefore, areaNow, lengthNow }

extension DimWords on Dim {
  /// What the drawing writes beside the arrow.
  String get tag => switch (this) {
        Dim.areaBefore => 'A0',
        Dim.lengthBefore => 'L0',
        Dim.areaNow => 'A now',
        Dim.lengthNow => 'L now',
      };

  String get plain => switch (this) {
        Dim.areaBefore => 'the area it started with',
        Dim.lengthBefore => 'the gauge length it started with',
        Dim.areaNow => 'the area it has right now',
        Dim.lengthNow => 'the length it has right now',
      };

  bool get isArea => this == Dim.areaBefore || this == Dim.areaNow;
}

/// One tensile test coupon, before and during.
///
/// The numbers are the ones a test report carries. The drawing is a side
/// view: the bar thins as it stretches, which is the only reason true and
/// engineering ever differ.
@immutable
class Coupon {
  const Coupon({
    required this.areaBefore,
    required this.lengthBefore,
    required this.stretch,
    required this.thinnedTo,
  });

  /// Square millimeters and millimeters.
  final double areaBefore;
  final double lengthBefore;

  /// How much longer it is now, in millimeters.
  final double stretch;

  /// What is left of the original area at the narrowest point, as a share.
  /// One means it has not thinned at all.
  final double thinnedTo;

  double get lengthNow => lengthBefore + stretch;
  double get areaNow => areaBefore * thinnedTo;

  /// True once the bar has a waist rather than thinning evenly.
  bool get necked => thinnedTo < 0.92;

  double valueOf(Dim dim) => switch (dim) {
        Dim.areaBefore => areaBefore,
        Dim.lengthBefore => lengthBefore,
        Dim.areaNow => areaNow,
        Dim.lengthNow => lengthNow,
      };

  /// What the drawing writes under the tag.
  String readingOf(Dim dim) {
    final v = valueOf(dim);
    final unit = dim.isArea ? 'mm2' : 'mm';
    final shown = v >= 100 ? v.round().toString() : v.toStringAsFixed(3);
    return '$shown $unit';
  }
}

/// The coupon drawn twice, before the test and during it, with the four
/// measurements called out on arrows.
///
/// Tap targets come out of [tagAt], which is the same geometry the painter
/// draws with, so a label can never be somewhere the finger is not.
class CouponPainter extends CustomPainter {
  const CouponPainter({
    required this.coupon,
    this.picked,
    this.answer,
    this.locked = false,
  });

  final Coupon coupon;

  /// What the reader tapped, and what was right, once the round is over.
  final Dim? picked;
  final Dim? answer;
  final bool locked;

  static const _padL = 12.0;
  static const _padR = 12.0;

  /// The middle of each bar and how thick it is drawn.
  static double _beforeY(Size size) => size.height * 0.27;
  static double _nowY(Size size) => size.height * 0.72;

  /// The bar is drawn long enough to stretch visibly and short enough to keep
  /// both ends on the panel.
  static Rect _beforeBar(Size size) {
    final wide = (size.width - _padL - _padR) * 0.74;
    const thick = 26.0;
    return Rect.fromLTWH(_padL, _beforeY(size) - thick / 2, wide, thick);
  }

  static Rect _nowBar(Size size) {
    final before = _beforeBar(size);
    // The stretch is drawn exaggerated on purpose: a tenth of a millimeter on
    // fifty is nothing a drawing can show, and the caption says so.
    final wide = before.width * 1.16;
    const thick = 26.0;
    return Rect.fromLTWH(_padL, _nowY(size) - thick / 2, wide, thick);
  }

  /// Where each measurement's label sits. Tap targets, and the painter's own
  /// drawing positions.
  static Offset tagAt(Size size, Dim dim) {
    final before = _beforeBar(size);
    final now = _nowBar(size);
    return switch (dim) {
      Dim.areaBefore => Offset(before.left + 26, before.top - 16),
      Dim.lengthBefore => Offset(before.center.dx, before.bottom + 16),
      Dim.areaNow => Offset(now.center.dx, now.top - 16),
      Dim.lengthNow => Offset(now.center.dx, now.bottom + 16),
    };
  }

  /// The measurement nearest a tap, or nothing if the tap was not near one.
  static Dim? nearest(Size size, Offset tap, {double within = 46}) {
    Dim? best;
    var bestGap = within;
    for (final d in Dim.values) {
      final gap = (tagAt(size, d) - tap).distance;
      if (gap < bestGap) {
        bestGap = gap;
        best = d;
      }
    }
    return best;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _bar(canvas, size, _beforeBar(size), necked: false);
    _bar(canvas, size, _nowBar(size), necked: coupon.necked);

    _write(canvas, 'before the test', Offset(_padL, _beforeY(size) - 52),
        AppColors.ink3);
    _write(canvas, 'while it is being pulled', Offset(_padL, _nowY(size) - 52),
        AppColors.ink3);

    for (final dim in Dim.values) {
      _callout(canvas, size, dim);
    }
    viewTag(canvas, size, Looking.elevation);
  }

  /// A bar, with a waist in it once it has started to neck.
  void _bar(Canvas canvas, Size size, Rect box, {required bool necked}) {
    final path = Path()..moveTo(box.left, box.top);
    if (necked) {
      final waist = box.height * coupon.thinnedTo;
      final pinch = (box.height - waist) / 2;
      path
        ..lineTo(box.center.dx - 26, box.top)
        ..quadraticBezierTo(
            box.center.dx, box.top + pinch, box.center.dx + 26, box.top)
        ..lineTo(box.right, box.top)
        ..lineTo(box.right, box.bottom)
        ..lineTo(box.center.dx + 26, box.bottom)
        ..quadraticBezierTo(
            box.center.dx, box.bottom - pinch, box.center.dx - 26, box.bottom)
        ..lineTo(box.left, box.bottom);
    } else {
      path
        ..lineTo(box.right, box.top)
        ..lineTo(box.right, box.bottom)
        ..lineTo(box.left, box.bottom);
    }
    path.close();
    canvas
      ..drawPath(path, Paint()..color = AppColors.sunbeam.withValues(alpha: 0.3))
      ..drawPath(
        path,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );

    // The pull, so the two drawings read as one test rather than two bars.
    _pull(canvas, Offset(box.right + 4, box.center.dy), 1);
    _pull(canvas, Offset(box.left - 4, box.center.dy), -1);
  }

  void _pull(Canvas canvas, Offset from, double way) {
    final tip = from + Offset(10 * way, 0);
    final paint = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1.6;
    canvas
      ..drawLine(from, tip, paint)
      ..drawLine(tip, tip + Offset(-4 * way, -3), paint)
      ..drawLine(tip, tip + Offset(-4 * way, 3), paint);
  }

  /// One measurement: an arrow across what it measures, and its name.
  void _callout(Canvas canvas, Size size, Dim dim) {
    final before = _beforeBar(size);
    final now = _nowBar(size);
    final chosen = picked == dim;
    final truth = locked && answer == dim;
    final Color tone;
    if (truth) {
      tone = AppColors.forest;
    } else if (locked && chosen) {
      tone = AppColors.error;
    } else if (chosen) {
      tone = AppColors.ember;
    } else {
      tone = AppColors.ink3;
    }
    final paint = Paint()
      ..color = tone
      ..strokeWidth = truth || chosen ? 2.2 : 1.4;

    switch (dim) {
      // An area is the end face, so its arrow goes across the thickness.
      case Dim.areaBefore:
        _span(canvas, Offset(before.left + 26, before.top),
            Offset(before.left + 26, before.bottom), paint, upright: true);
      case Dim.areaNow:
        final waist = now.height * coupon.thinnedTo;
        _span(canvas, Offset(now.center.dx, now.center.dy - waist / 2),
            Offset(now.center.dx, now.center.dy + waist / 2), paint,
            upright: true);
      // A length runs the whole gauge, so its arrow goes under the bar.
      case Dim.lengthBefore:
        _span(canvas, Offset(before.left, before.bottom + 8),
            Offset(before.right, before.bottom + 8), paint, upright: false);
      case Dim.lengthNow:
        _span(canvas, Offset(now.left, now.bottom + 8),
            Offset(now.right, now.bottom + 8), paint, upright: false);
    }

    final at = tagAt(size, dim);
    final text = '${dim.tag}  ${coupon.readingOf(dim)}';
    _label(canvas, size, text, at, tone, bold: truth || chosen);
  }

  /// A dimension arrow between two points, with ticks at the ends.
  void _span(Canvas canvas, Offset a, Offset b, Paint paint,
      {required bool upright}) {
    canvas.drawLine(a, b, paint);
    final across = upright ? const Offset(5, 0) : const Offset(0, 5);
    canvas
      ..drawLine(a - across, a + across, paint)
      ..drawLine(b - across, b + across, paint);
  }

  /// A name on a cream patch, kept inside the panel.
  void _label(Canvas canvas, Size size, String text, Offset at, Color tone,
      {required bool bold}) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTheme.mono(size: 10.5, color: tone).copyWith(
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx - painter.width / 2;
    var y = at.dy - painter.height / 2;
    if (x < 2) x = 2;
    if (x + painter.width > size.width - 2) x = size.width - 2 - painter.width;
    if (y < 1) y = 1;
    final patch =
        Rect.fromLTWH(x - 3, y - 2, painter.width + 6, painter.height + 4);
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(patch, const Radius.circular(4)),
        Paint()..color = AppColors.cream.withValues(alpha: 0.95),
      )
      ..drawRRect(
        RRect.fromRectAndRadius(patch, const Radius.circular(4)),
        Paint()
          ..color = tone.withValues(alpha: bold ? 1 : 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    painter.paint(canvas, Offset(x, y));
  }

  void _write(Canvas canvas, String text, Offset at, Color color) {
    TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, at);
  }

  @override
  bool shouldRepaint(CouponPainter old) =>
      old.coupon != coupon ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked;
}
