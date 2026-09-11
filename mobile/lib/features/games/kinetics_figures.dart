import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// A block on a frictionless slope.
///
/// The numbers a round quotes come out of here, so the drawing and the
/// arithmetic cannot disagree about which component does what.
@immutable
class Slope2 {
  const Slope2({
    required this.degrees,
    required this.weight,
    this.g = 9.81,
  });

  /// The slope, and the block's WEIGHT in newtons, which is what a problem
  /// usually gives and is not its mass.
  final double degrees;
  final double weight;
  final double g;

  double get _radians => degrees * math.pi / 180;

  double get mass => weight / g;

  /// The piece of the weight that runs down the slope, which is the only one
  /// that accelerates the block.
  double get along => weight * math.sin(_radians);

  /// The piece square to the slope, which the surface pushes back against
  /// exactly and which moves nothing.
  double get square => weight * math.cos(_radians);

  double get accel => g * math.sin(_radians);

  /// What the block would do if you used the wrong component.
  double get wrongAccel => g * math.cos(_radians);
}

/// The arrows a round can put on the block.
enum Arrow { weight, along, square, normal }

extension ArrowWords on Arrow {
  String get plain => switch (this) {
        Arrow.weight => 'the whole weight, straight down',
        Arrow.along => 'the piece running down the slope',
        Arrow.square => 'the piece pressing into the slope',
        Arrow.normal => 'the push back from the surface',
      };
}

/// A block on a slope with its weight taken apart.
class SlopePainter2 extends CustomPainter {
  const SlopePainter2({
    required this.slope,
    this.arrows = const <Arrow>[],
    this.picked,
    this.truth,
    this.locked = false,
  });

  final Slope2 slope;
  final List<Arrow> arrows;
  final Arrow? picked;
  final Arrow? truth;
  final bool locked;

  static const _pad = 26.0;

  /// Where the block sits and which way the slope runs, so the arrows and
  /// their tap targets are placed off the drawing rather than guessed.
  static (Offset, Offset, Offset) layout(Slope2 slope, Size size) {
    final tilt = slope.degrees * math.pi / 180;
    final run = size.width - _pad * 2;
    final rise = run * math.tan(tilt);
    final foot = Offset(_pad, size.height - _pad);
    final scale = rise > size.height - _pad * 2
        ? (size.height - _pad * 2) / rise
        : 1.0;
    final base = Offset(_pad, size.height - _pad);
    final peak = base + Offset(run * scale, -rise * scale);
    // The block sits a little over halfway up.
    final seat = base + (peak - base) * 0.55;
    final along = (peak - base) / (peak - base).distance;
    return (seat, along, foot);
  }

  /// Where an arrow's head lands.
  static Offset headOf(Slope2 slope, Size size, Arrow arrow) {
    final (seat, along, _) = layout(slope, size);
    final up = Offset(-along.dy, along.dx) * -1;
    final scale = math.min(size.height * 0.3, 64.0) / slope.weight;
    return switch (arrow) {
      Arrow.weight => seat + Offset(0, slope.weight * scale),
      Arrow.along => seat - along * (slope.along * scale),
      Arrow.square => seat - up * (slope.square * scale),
      Arrow.normal => seat + up * (slope.square * scale),
    };
  }

  static Arrow? nearest(
      Slope2 slope, Size size, List<Arrow> arrows, Offset tap,
      {double within = 32}) {
    Arrow? best;
    var gap = within;
    for (final a in arrows) {
      final d = (headOf(slope, size, a) - tap).distance;
      if (d < gap) {
        gap = d;
        best = a;
      }
    }
    return best;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final (seat, along, foot) = layout(slope, size);
    final tilt = slope.degrees * math.pi / 180;
    final run = size.width - _pad * 2;
    final rise = run * math.tan(tilt);
    final scale =
        rise > size.height - _pad * 2 ? (size.height - _pad * 2) / rise : 1.0;
    final peak = foot + Offset(run * scale, -rise * scale);

    final ink = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(foot.dx, foot.dy)
        ..lineTo(peak.dx, peak.dy)
        ..lineTo(peak.dx, foot.dy)
        ..close(),
      ink,
    );
    for (var h = foot.dx; h < peak.dx; h += 8) {
      canvas.drawLine(
        Offset(h, foot.dy),
        Offset(h - 5, foot.dy + 6),
        Paint()
          ..color = AppColors.ink3
          ..strokeWidth = 1,
      );
    }

    // The block, sitting square on the surface.
    final up = Offset(-along.dy, along.dx) * -1;
    const half = 15.0;
    const high = 20.0;
    final corners = [
      seat - along * half,
      seat + along * half,
      seat + along * half + up * high,
      seat - along * half + up * high,
    ];
    final box = Path()..moveTo(corners[0].dx, corners[0].dy);
    for (final c in corners.skip(1)) {
      box.lineTo(c.dx, c.dy);
    }
    box.close();
    canvas
      ..drawPath(box, Paint()..color = AppColors.sunbeam.withValues(alpha: 0.3))
      ..drawPath(box, ink);

    // Top left, clear of the wedge: down by the foot the slope line runs
    // straight through the text on a gentle ramp.
    _write(canvas, '${slope.degrees.round()} degrees', const Offset(5, 3),
        AppColors.ink3);

    for (final arrow in arrows) {
      final isTruth = locked && arrow == truth;
      final chosen = picked == arrow;
      final color = isTruth
          ? AppColors.forest
          : (locked && chosen)
              ? AppColors.error
              : chosen
                  ? AppColors.ember
                  : (arrow == Arrow.weight ? AppColors.charcoal : AppColors.info);
      _arrow(canvas, seat, headOf(slope, size, arrow), color,
          heavy: chosen || isTruth);
    }
  }

  void _arrow(Canvas canvas, Offset from, Offset to, Color color,
      {bool heavy = false}) {
    if ((to - from).distance < 3) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = heavy ? 3 : 2;
    canvas.drawLine(from, to, paint);
    final unit = (to - from) / (to - from).distance;
    final side = Offset(-unit.dy, unit.dx);
    canvas.drawPath(
      Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo(to.dx - unit.dx * 9 + side.dx * 4.5,
            to.dy - unit.dy * 9 + side.dy * 4.5)
        ..lineTo(to.dx - unit.dx * 9 - side.dx * 4.5,
            to.dy - unit.dy * 9 - side.dy * 4.5)
        ..close(),
      Paint()..color = color,
    );
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
  bool shouldRepaint(SlopePainter2 old) =>
      old.slope != slope || old.picked != picked || old.locked != locked;
}

/// What is holding the body while the force is applied.
enum Held2 { axle, floor, free }

/// Where the force lands on it.
enum Lands { middle, rim, corner }

/// A body, what holds it, and where it is pushed.
@immutable
class Pushed {
  const Pushed({
    required this.round,
    required this.held,
    required this.lands,
  });

  /// Drawn as a disc rather than a box.
  final bool round;

  final Held2 held;
  final Lands lands;

  /// Whether the push makes it move off in a straight line.
  bool get translates => held != Held2.axle;

  /// Whether it makes it spin.
  bool get rotates => switch (held) {
        Held2.axle => lands != Lands.middle,
        _ => lands != Lands.middle,
      };
}

/// A body with a force on it and whatever is holding it.
class PushPainter extends CustomPainter {
  const PushPainter({required this.pushed, this.tone = AppColors.ember});

  final Pushed pushed;
  final Color tone;

  @override
  void paint(Canvas canvas, Size size) {
    final middle = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) * 0.24;

    if (pushed.held == Held2.floor) {
      final y = middle.dy + r + 10;
      canvas.drawLine(
        Offset(10, y),
        Offset(size.width - 10, y),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 1.6,
      );
      for (var h = 14.0; h < size.width - 10; h += 8) {
        canvas.drawLine(
          Offset(h, y),
          Offset(h - 5, y + 6),
          Paint()
            ..color = AppColors.ink3
            ..strokeWidth = 1,
        );
      }
    }

    final ink = Paint()
      ..color = AppColors.charcoal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final fill = Paint()..color = AppColors.info.withValues(alpha: 0.22);
    if (pushed.round) {
      canvas
        ..drawCircle(middle, r, fill)
        ..drawCircle(middle, r, ink);
    } else {
      final box = Rect.fromCenter(center: middle, width: r * 2, height: r * 1.5);
      canvas
        ..drawRect(box, fill)
        ..drawRect(box, ink);
    }

    if (pushed.held == Held2.axle) {
      canvas
        ..drawCircle(
          middle,
          7,
          Paint()
            ..color = AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        )
        ..drawCircle(middle, 2.5, Paint()..color = AppColors.charcoal);
    }

    // The force, drawn where it lands.
    final at = switch (pushed.lands) {
      Lands.middle => middle,
      Lands.rim => middle + Offset(0, -r),
      Lands.corner => middle + Offset(r, -r * 0.75),
    };
    final to = at + const Offset(52, 0);
    canvas.drawLine(at, to, Paint()..color = tone..strokeWidth = 2.6);
    canvas.drawPath(
      Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo(to.dx - 10, to.dy - 5)
        ..lineTo(to.dx - 10, to.dy + 5)
        ..close(),
      Paint()..color = tone,
    );
    TextPainter(
      text: TextSpan(text: 'F', style: AppTheme.mono(size: 11, color: tone)),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, to + const Offset(3, -6));
  }

  @override
  bool shouldRepaint(PushPainter old) => old.pushed != pushed;
}
