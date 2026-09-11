import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';

/// A thing that spins, and the places on it a round can ask about.
///
/// Every point shares the same angular velocity and none of them share a
/// speed, which is the whole of the first item.
@immutable
class Spinner {
  const Spinner({
    required this.rpm,
    required this.radius,
    required this.marks,
  });

  /// Turns a minute, which is how a machine is labelled and not what any
  /// formula wants.
  final double rpm;

  /// The outside radius, in meters.
  final double radius;

  /// Where the marked points sit: a distance from the middle and an angle,
  /// in degrees, so two points can share a radius and sit in different
  /// places.
  final List<(double, double)> marks;

  /// Radians a second, which is what the formulas want.
  double get omega => rpm * 2 * math.pi / 60;

  /// Speed of a point, which is the only thing on this drawing that depends
  /// on where the point is.
  double speedAt(int i) => marks[i].$1 * omega;

  /// Acceleration toward the middle of the spin.
  double towardCenterAt(int i) => marks[i].$1 * omega * omega;
}

/// A spinning body with its marked points, drawn face on.
class SpinnerPainter extends CustomPainter {
  const SpinnerPainter({
    required this.spinner,
    this.picked,
    this.truth,
    this.locked = false,
    this.arm = false,
  });

  final Spinner spinner;
  final int? picked;
  final int? truth;
  final bool locked;

  /// Draw it as an arm swinging about one end rather than as a wheel.
  final bool arm;

  /// An arm is drawn lying across the panel, so it gets the width; a wheel
  /// has to fit both ways. Sharing one rule drew the arm's marks close enough
  /// together to be untappable.
  static double _scale(Spinner s, Size size, {bool arm = false}) => arm
      ? (size.width * 0.78) / s.radius
      : math.min(size.width * 0.42, size.height * 0.40) / s.radius;

  static Offset middleOf(Size size) =>
      Offset(size.width / 2, size.height / 2 + 6);

  /// Where a marked point is drawn, so the tap targets sit on the marks.
  static Offset markAt(Spinner s, Size size, int i, {bool arm = false}) {
    final scale = _scale(s, size, arm: arm);
    final (r, degrees) = s.marks[i];
    if (arm) {
      // An arm is drawn lying to the right of its pivot.
      return Offset(
        size.width * 0.16 + r * scale,
        size.height / 2,
      );
    }
    final a = degrees * math.pi / 180;
    return middleOf(size) +
        Offset(math.cos(a) * r * scale, -math.sin(a) * r * scale);
  }

  static int? nearest(Spinner s, Size size, Offset tap,
      {bool arm = false, double within = 30}) {
    int? best;
    var gap = within;
    for (var i = 0; i < s.marks.length; i++) {
      final d = (markAt(s, size, i, arm: arm) - tap).distance;
      if (d < gap) {
        gap = d;
        best = i;
      }
    }
    return best;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = _scale(spinner, size, arm: arm);
    if (arm) {
      final pivot = Offset(size.width * 0.16, size.height / 2);
      canvas
        ..drawLine(
          pivot,
          pivot + Offset(spinner.radius * scale, 0),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round,
        )
        ..drawCircle(pivot, 6, Paint()..color = AppColors.ink2);
      _turn(canvas, pivot, 22);
    } else {
      final middle = middleOf(size);
      canvas
        ..drawCircle(
          middle,
          spinner.radius * scale,
          Paint()
            ..color = AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        )
        ..drawCircle(middle, 4, Paint()..color = AppColors.ink2);
      for (final spoke in [0, 90, 180, 270]) {
        final a = spoke * math.pi / 180;
        canvas.drawLine(
          middle,
          middle +
              Offset(math.cos(a), -math.sin(a)) * (spinner.radius * scale),
          Paint()
            ..color = AppColors.line
            ..strokeWidth = 1,
        );
      }
      _turn(canvas, middle, spinner.radius * scale + 14);
    }

    for (var i = 0; i < spinner.marks.length; i++) {
      final p = markAt(spinner, size, i, arm: arm);
      final isTruth = locked && i == truth;
      final chosen = picked == i;
      final color = isTruth
          ? AppColors.forest
          : (locked && chosen)
              ? AppColors.error
              : chosen
                  ? AppColors.ember
                  : AppColors.ink2;
      canvas
        ..drawCircle(p, 8, Paint()..color = AppColors.cream)
        ..drawCircle(p, chosen || isTruth ? 6.5 : 5, Paint()..color = color);
    }

    _write(
      canvas,
      '${spinner.rpm.round()} rpm',
      Offset(6, 4),
      AppColors.ink3,
    );
    viewTag(canvas, size, Looking.plan, note: 'axis toward you');
  }

  /// The arrow that says it is turning, drawn clear of the body.
  void _turn(Canvas canvas, Offset middle, double r) {
    final rect = Rect.fromCircle(center: middle, radius: r);
    canvas.drawArc(
      rect,
      -math.pi * 0.85,
      math.pi * 0.45,
      false,
      Paint()
        ..color = AppColors.info
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final tip = middle +
        Offset(math.cos(-math.pi * 0.4), math.sin(-math.pi * 0.4)) * r;
    canvas.drawCircle(tip, 3.4, Paint()..color = AppColors.info);
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
  bool shouldRepaint(SpinnerPainter old) =>
      old.spinner != spinner ||
      old.picked != picked ||
      old.locked != locked ||
      old.arm != arm;
}

/// The standard shapes the handbook's table covers.
enum Shape3 { hoop, disc, sphere, rod, cylinder }

/// Which axis it is being spun about.
enum Spin {
  /// The one the table gives first: through the middle, the way the thing
  /// naturally rolls or spins.
  ownAxis,

  /// Through the middle but across it, like a wheel tipped on its side.
  diameter,

  /// Through one end, for a rod.
  end,

  /// Parallel to its own axis but a distance away, which is where the
  /// transfer term comes in.
  offset,
}

/// A body and the axis it is being spun about.
@immutable
class Body {
  const Body({
    required this.kind,
    required this.mass,
    this.radius = 0,
    this.length = 0,
    this.spin = Spin.ownAxis,
    this.offset = 0,
  });

  final Shape3 kind;

  /// Kilograms and meters.
  final double mass;
  final double radius;
  final double length;

  final Spin spin;

  /// How far the axis sits from the body's own centroid.
  final double offset;

  /// Straight from the handbook's table, never derived here.
  double get centroidal => switch ((kind, spin)) {
        (Shape3.hoop, Spin.diameter) => mass * radius * radius / 2,
        (Shape3.hoop, _) => mass * radius * radius,
        (Shape3.disc, Spin.diameter) => mass * radius * radius / 4,
        (Shape3.disc, _) => mass * radius * radius / 2,
        (Shape3.cylinder, Spin.diameter) =>
          mass * (3 * radius * radius + length * length) / 12,
        (Shape3.cylinder, _) => mass * radius * radius / 2,
        (Shape3.sphere, _) => 2 * mass * radius * radius / 5,
        (Shape3.rod, _) => mass * length * length / 12,
      };

  /// What it takes to spin it about the axis actually drawn.
  double get inertia => switch (spin) {
        Spin.end => kind == Shape3.rod
            ? mass * length * length / 3
            : centroidal + mass * (length / 2) * (length / 2),
        Spin.offset => centroidal + mass * offset * offset,
        _ => centroidal,
      };

  /// The transfer term on its own, which is the piece people drop.
  double get transfer => spin == Spin.offset ? mass * offset * offset : 0;

  String get plain => switch (kind) {
        Shape3.hoop => 'a hoop',
        Shape3.disc => 'a solid disc',
        Shape3.sphere => 'a solid sphere',
        Shape3.rod => 'a slender rod',
        Shape3.cylinder => 'a solid cylinder',
      };
}

/// A body drawn face on with the axis it spins about marked.
class BodyPainter extends CustomPainter {
  const BodyPainter({
    required this.body,
    required this.frame,
    this.tone = AppColors.info,
    this.label = '',
  });

  final Body body;

  /// The biggest dimension any body in the row has to fit, so two bodies
  /// drawn side by side are drawn to ONE scale.
  final double frame;

  final Color tone;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    // The frame already carries its own margin, so this uses most of the
    // panel: at a third of it the bodies came out as specks.
    final scale = math.min(size.width * 0.46, size.height * 0.46) / frame;
    // An offset axis sits to the left, and the body beside it, so the
    // distance between the two is part of the picture.
    final axisAt = body.spin == Spin.offset
        ? Offset(size.width * 0.22, size.height / 2)
        : Offset(size.width / 2, size.height / 2);
    final middle = body.spin == Spin.offset
        ? axisAt + Offset(body.offset * scale, 0)
        : axisAt;

    final ink = Paint()
      ..color = AppColors.charcoal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    final fill = Paint()..color = tone.withValues(alpha: 0.25);

    switch (body.kind) {
      case Shape3.hoop:
        canvas.drawCircle(middle, body.radius * scale, ink);
        canvas.drawCircle(
            middle, body.radius * scale - 4, ink..strokeWidth = 1.2);
      case Shape3.disc:
      case Shape3.cylinder:
      case Shape3.sphere:
        canvas
          ..drawCircle(middle, body.radius * scale, fill)
          ..drawCircle(
            middle,
            body.radius * scale,
            Paint()
              ..color = AppColors.charcoal
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.4,
          );
        if (body.kind == Shape3.sphere) {
          canvas.drawArc(
            Rect.fromCenter(
              center: middle,
              width: body.radius * scale * 1.1,
              height: body.radius * scale * 2,
            ),
            -math.pi / 2,
            math.pi,
            false,
            Paint()
              ..color = AppColors.ink3
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1,
          );
        }
      case Shape3.rod:
        final half = body.length * scale / 2;
        canvas.drawLine(
          middle - Offset(half, 0),
          middle + Offset(half, 0),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 7
            ..strokeCap = StrokeCap.round,
        );
    }

    // The axis itself. Out of the page for the natural spin, across the page
    // for a diameter, and at the end or off to one side where it belongs.
    final place = switch (body.spin) {
      Spin.end => body.kind == Shape3.rod
          ? middle - Offset(body.length * scale / 2, 0)
          : middle,
      _ => axisAt,
    };
    switch (body.spin) {
      case Spin.diameter:
        canvas.drawLine(
          Offset(place.dx, place.dy - size.height * 0.36),
          Offset(place.dx, place.dy + size.height * 0.36),
          Paint()
            ..color = AppColors.ember
            ..strokeWidth = 2,
        );
      default:
        // A dot in a circle: the axis comes out of the page.
        canvas
          ..drawCircle(
            place,
            7,
            Paint()
              ..color = AppColors.ember
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          )
          ..drawCircle(place, 2.4, Paint()..color = AppColors.ember);
    }

    if (body.spin == Spin.offset) {
      // The distance the transfer term is about.
      final y = middle.dy + size.height * 0.26;
      canvas.drawLine(
        Offset(axisAt.dx, y),
        Offset(middle.dx, y),
        Paint()
          ..color = AppColors.ink2
          ..strokeWidth = 1.4,
      );
      for (final x in [axisAt.dx, middle.dx]) {
        canvas.drawLine(
          Offset(x, y - 4),
          Offset(x, y + 4),
          Paint()
            ..color = AppColors.ink2
            ..strokeWidth = 1.4,
        );
      }
      _write(canvas, 'd', Offset((axisAt.dx + middle.dx) / 2 - 3, y + 4),
          AppColors.ink2);
    }

    if (label.isNotEmpty) {
      _write(canvas, label, const Offset(5, 3), AppColors.ink3);
    }
    viewTag(canvas, size, Looking.plan, note: 'axis toward you');
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
  bool shouldRepaint(BodyPainter old) =>
      old.body != body || old.tone != tone || old.frame != frame;
}
