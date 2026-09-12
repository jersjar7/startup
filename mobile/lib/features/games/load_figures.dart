import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// The three LRFD combinations the lesson names, in its own order.
enum Combo { one, two, three }

/// The service loads on one member, before any factor touches them. Every
/// number an item shows is worked out from here rather than written down
/// beside it, so a round cannot claim a total the combinations do not give.
@immutable
class Bundle {
  const Bundle({
    required this.dead,
    required this.live,
    this.snow = 0,
    this.roofLive = 0,
  });

  final double dead;
  final double live;
  final double snow;
  final double roofLive;

  /// Whichever of snow and roof live load is the larger, since the
  /// combinations take one of them and not both.
  double get roof => math.max(snow, roofLive);

  double get combo1 => 1.4 * dead;
  double get combo2 => 1.2 * dead + 1.6 * live + 0.5 * roof;

  /// With no wind in the picture, the companion term is the floor live load.
  double get combo3 => 1.2 * dead + 1.6 * roof + live;

  double totalOf(Combo which) => switch (which) {
        Combo.one => combo1,
        Combo.two => combo2,
        Combo.three => combo3,
      };

  double get worst => math.max(combo1, math.max(combo2, combo3));

  /// The combination that produces the largest factored load, which is the
  /// one the member has to be designed for.
  Combo get controls {
    for (final c in Combo.values) {
      if (totalOf(c) == worst) return c;
    }
    return Combo.two;
  }
}

/// The service loads drawn as bars to one scale, and once the round is over
/// the three combination totals beneath them, also to one scale, with the
/// controlling one picked out. Sizes are the whole argument here, so nothing
/// is drawn to its own scale.
class LoadBarPainter extends CustomPainter {
  const LoadBarPainter({
    required this.bundle,
    required this.unit,
    this.answered = false,
  });

  final Bundle bundle;

  /// What the numbers are in, written once at the top.
  final String unit;
  final bool answered;

  static const _left = 74.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rows = <(String, double)>[
      ('dead D', bundle.dead),
      ('live L', bundle.live),
      if (bundle.snow > 0) ('snow S', bundle.snow),
      if (bundle.roofLive > 0) ('roof live', bundle.roofLive),
    ];

    writeOn(canvas, size, 'what is on it, in $unit', const Offset(8, 4),
        AppColors.ink3, fontSize: 9.5);

    // One scale for the service loads and the totals alike, because the
    // whole question is how they compare. No combination can come out
    // smaller than the largest load in it, so the worst total sets the scale
    // whether or not it has been shown yet.
    final wide = size.width - _left - 54;
    final top = bundle.worst;
    var y = 22.0;
    for (final (name, value) in rows) {
      _bar(canvas, size, y, name, value, top, wide, AppColors.charcoal, false);
      y += 20;
    }

    if (!answered) return;

    y += 8;
    writeOn(canvas, size, 'what the combinations make of it', Offset(8, y),
        AppColors.forest, fontSize: 9.5);
    y += 16;
    for (final c in Combo.values) {
      final lit = c == bundle.controls;
      _bar(canvas, size, y, _name(c), bundle.totalOf(c), top, wide,
          lit ? AppColors.forest : AppColors.ink2, lit);
      y += 20;
    }
  }

  static String _name(Combo c) => switch (c) {
        Combo.one => 'combo 1',
        Combo.two => 'combo 2',
        Combo.three => 'combo 3',
      };

  void _bar(Canvas canvas, Size size, double y, String name, double value,
      double top, double wide, Color tone, bool lit) {
    writeOn(canvas, size, name, Offset(8, y - 1), AppColors.ink3,
        fontSize: 9.5);
    final length = top <= 0 ? 0.0 : value / top * wide;
    canvas.drawRect(
        Rect.fromLTWH(_left, y, math.max(length, 1), 11),
        Paint()..color = tone.withValues(alpha: lit ? 0.95 : 0.55));
    writeOn(canvas, size, _num(value), Offset(_left + length + 5, y - 1), tone,
        fontSize: 9.5);
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  bool shouldRepaint(LoadBarPainter old) =>
      old.bundle != bundle || old.answered != answered || old.unit != unit;
}

/// A member and the floor area that leans on it, seen from above. The
/// reduction rule is entirely about how big this area is and how much of it
/// one member is holding up.
@immutable
class Tributary {
  const Tributary({
    required this.area,
    required this.column,
    this.unreduced = 50,
  });

  /// The tributary area in square feet.
  final double area;

  /// A column carries four, a beam two, which is the whole of K sub LL.
  final bool column;

  /// The unreduced live load in pounds per square foot.
  final double unreduced;

  int get kll => column ? 4 : 2;

  /// What the rule multiplies the unreduced load by, before the floors.
  double get factor => 0.25 + 15 / math.sqrt(kll * area);

  /// The reduction is never allowed to become an increase, and for a single
  /// floor it may not take the load below half.
  double get reduced {
    final raw = unreduced * factor;
    return math.min(unreduced, math.max(raw, 0.5 * unreduced));
  }

  bool get allowed => kll * area > 400;
}

/// Two members seen from above with the floor area each one carries hatched,
/// drawn to one scale so the comparison is the drawing rather than the label.
class TributaryPainter extends CustomPainter {
  const TributaryPainter({
    required this.left,
    this.right,
    this.answered = false,
  });

  final Tributary left;

  /// The second member, when the round is comparing two.
  final Tributary? right;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final other = right;
    // With two panels the larger of the pair sets the scale; with one, a
    // fixed reference does, so a small bay looks small in its own round and
    // not merely small beside itself.
    final biggest =
        other == null ? math.max(left.area, 2000.0) : math.max(left.area, other.area);
    if (other == null) {
      _plan(canvas, size, Rect.fromLTWH(0, 18, size.width, size.height - 34),
          left, biggest);
    } else {
      final w = size.width / 2;
      _plan(canvas, size, Rect.fromLTWH(0, 18, w, size.height - 34), left,
          biggest);
      _plan(canvas, size, Rect.fromLTWH(w, 18, w, size.height - 34), other,
          biggest);
      canvas.drawLine(
          Offset(w, 22),
          Offset(w, size.height - 22),
          Paint()
            ..color = AppColors.line
            ..strokeWidth = 1);
    }
    viewTag(canvas, size, Looking.plan, note: 'the floor above');
  }

  void _plan(Canvas canvas, Size size, Rect box, Tributary t, double biggest) {
    // Area is drawn as area: the square root of the ratio sets the side, so
    // twice the area looks like twice the ink and not twice the width.
    final scale = math.sqrt(t.area / biggest);
    final side = math.min(box.width - 40, box.height - 44) * scale;
    final center = Offset(box.center.dx, box.top + (box.height - 18) / 2);
    final rect = Rect.fromCenter(center: center, width: side, height: side);
    canvas.drawRect(
        rect,
        Paint()
          ..color = AppColors.ember
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);
    hatchIn(canvas, Path()..addRect(rect), step: 8, color: AppColors.ember);

    // The member itself, at the middle of what it carries.
    if (t.column) {
      canvas.drawRect(
          Rect.fromCenter(center: center, width: 11, height: 11),
          Paint()..color = AppColors.charcoal);
    } else {
      canvas.drawRect(
          Rect.fromLTRB(rect.left, center.dy - 3, rect.right, center.dy + 3),
          Paint()..color = AppColors.charcoal);
    }

    writeOn(canvas, size, t.column ? 'a column' : 'a beam',
        Offset(box.left + 8, box.top - 12), AppColors.ink3, fontSize: 9.5);
    writeOn(
        canvas,
        size,
        '${_num(t.area)} sq ft, K = ${t.kll}',
        Offset(box.left + 8, box.bottom - 10),
        AppColors.ink3,
        fontSize: 9.5);
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  bool shouldRepaint(TributaryPainter old) =>
      old.left != left || old.right != right || old.answered != answered;
}
