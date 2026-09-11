import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';

/// A projectile launched from the ground.
///
/// Everything an item asks about the flight is worked out from the launch, so
/// a round declares the speed and the angle and the answers follow.
@immutable
class Flight {
  const Flight({
    required this.speed,
    required this.degrees,
    this.g = 9.81,
  });

  /// Metres per second, and degrees above the horizontal.
  final double speed;
  final double degrees;
  final double g;

  double get _radians => degrees * math.pi / 180;

  /// The two pieces the flight splits into, and they never mix.
  double get vx => speed * math.cos(_radians);
  double get vy0 => speed * math.sin(_radians);

  /// How long it is in the air, and when it is highest.
  double get airborne => 2 * vy0 / g;
  double get apexTime => vy0 / g;

  double get apexHeight => vy0 * vy0 / (2 * g);
  double get range => vx * airborne;

  Offset at(double t) => Offset(vx * t, vy0 * t - g * t * t / 2);

  /// Velocity at a moment: the across part never changes and the up part
  /// runs steadily down through zero.
  Offset velocityAt(double t) => Offset(vx, vy0 - g * t);

  double speedAt(double t) => velocityAt(t).distance;
}

/// A moment during the flight that a round can ask about.
enum Moment { launch, rising, apex, falling, landing }

extension MomentWords on Moment {
  String get plain => switch (this) {
        Moment.launch => 'the instant it leaves the ground',
        Moment.rising => 'on the way up',
        Moment.apex => 'the top of the arc',
        Moment.falling => 'on the way down',
        Moment.landing => 'the instant it lands',
      };

  /// When it happens, as a share of the whole flight.
  double get share => switch (this) {
        Moment.launch => 0,
        Moment.rising => 0.25,
        Moment.apex => 0.5,
        Moment.falling => 0.75,
        Moment.landing => 1,
      };
}

/// The arc, with the moments marked on it.
class FlightPainter extends CustomPainter {
  const FlightPainter({
    required this.flight,
    this.moments = const <Moment>[],
    this.picked,
    this.truth,
    this.locked = false,
    this.showVelocities = false,
  });

  final Flight flight;
  final List<Moment> moments;
  final Moment? picked;
  final Moment? truth;
  final bool locked;

  /// Draw the velocity at each marked moment, split into its two pieces.
  final bool showVelocities;

  static const _padX = 18.0;
  static const _padTop = 26.0;
  static const _padBottom = 22.0;

  static double _scale(Flight flight, Size size) => math.min(
        (size.width - _padX * 2) / flight.range,
        (size.height - _padTop - _padBottom) / flight.apexHeight,
      );

  static Offset at(Flight flight, Size size, Offset world) {
    final scale = _scale(flight, size);
    final wide = flight.range * scale;
    return Offset(
      _padX + (size.width - _padX * 2 - wide) / 2 + world.dx * scale,
      size.height - _padBottom - world.dy * scale,
    );
  }

  /// Where a marked moment sits on the canvas, so tap targets are on the arc.
  static Offset momentAt(Flight flight, Size size, Moment moment) =>
      at(flight, size, flight.at(flight.airborne * moment.share));

  /// The marked moment nearest a tap, if the tap is near one.
  static Moment? nearest(
    Flight flight,
    Size size,
    List<Moment> moments,
    Offset tap, {
    double within = 34,
  }) {
    Moment? best;
    var gap = within;
    for (final m in moments) {
      final d = (momentAt(flight, size, m) - tap).distance;
      if (d < gap) {
        gap = d;
        best = m;
      }
    }
    return best;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // The ground, with its ticks: a plain line could be anything.
    final ground = at(flight, size, Offset.zero).dy;
    groundLine(canvas, Offset(4, ground), Offset(size.width - 4, ground),
        color: AppColors.ink3);

    final path = Path();
    for (var k = 0; k <= 80; k++) {
      final p = at(flight, size, flight.at(flight.airborne * k / 80));
      k == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.info
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    for (final m in moments) {
      final p = momentAt(flight, size, m);
      final isTruth = locked && m == truth;
      final chosen = picked == m;
      final color = isTruth
          ? AppColors.forest
          : (locked && chosen)
              ? AppColors.error
              : chosen
                  ? AppColors.ember
                  : AppColors.ink2;
      if (showVelocities) {
        final v = flight.velocityAt(flight.airborne * m.share);
        final scale = 2.2;
        _arrow(canvas, p, p + Offset(v.dx * scale, -v.dy * scale), color);
      }
      canvas
        ..drawCircle(p, 7, Paint()..color = AppColors.cream)
        ..drawCircle(p, chosen || isTruth ? 6 : 4.5, Paint()..color = color);
    }
    viewTag(canvas, size, Looking.elevation);
  }

  void _arrow(Canvas canvas, Offset from, Offset to, Color color) {
    if ((to - from).distance < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    canvas.drawLine(from, to, paint);
    final along = (to - from) / (to - from).distance;
    final side = Offset(-along.dy, along.dx);
    canvas.drawPath(
      Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo(to.dx - along.dx * 8 + side.dx * 4,
            to.dy - along.dy * 8 + side.dy * 4)
        ..lineTo(to.dx - along.dx * 8 - side.dx * 4,
            to.dy - along.dy * 8 - side.dy * 4)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(FlightPainter old) =>
      old.flight != flight ||
      old.picked != picked ||
      old.locked != locked ||
      old.showVelocities != showVelocities;
}

/// Something going round a bend.
@immutable
class Bend {
  const Bend({
    required this.speed,
    required this.radius,
    required this.alongRoad,
  });

  /// Metres per second and metres.
  final double speed;
  final double radius;

  /// How hard it is speeding up along the road. Negative for braking.
  final double alongRoad;

  /// Turning: always toward the middle of the bend, and it does not care
  /// which way round the corner you are going.
  double get towardCenter => speed * speed / radius;

  double get total =>
      math.sqrt(alongRoad * alongRoad + towardCenter * towardCenter);

  /// The mistake the lesson names: adding two things that sit at right
  /// angles to each other.
  double get addedUp => alongRoad.abs() + towardCenter;
}

/// Which acceleration a round is asking about.
enum Piece { along, toward, total }

/// A vehicle on a curved road, with the accelerations drawn on it.
class BendPainter extends CustomPainter {
  const BendPainter({
    required this.bend,
    this.show = const <Piece>[],
    this.picked,
    this.truth,
    this.locked = false,
  });

  final Bend bend;

  /// Which arrows to draw.
  final List<Piece> show;

  final Piece? picked;
  final Piece? truth;
  final bool locked;

  /// The middle of the bend, which is kept ON the canvas: with it off the
  /// bottom of the picture the arc read as a hill seen from the side rather
  /// than a road seen from above, and the arrow toward the middle read as
  /// gravity.
  static Offset centerOf(Size size) =>
      Offset(size.width / 2, size.height * 0.94);

  static double radiusOf(Size size) => size.height * 0.70;

  /// Where the vehicle sits on the drawn arc, and which way it is heading.
  static (Offset, Offset) carAt(Size size) {
    final at = centerOf(size) + Offset(0, -radiusOf(size));
    return (at, const Offset(1, 0));
  }

  /// How long to draw an acceleration. Scaled so the biggest arrow in the
  /// round fills a sensible part of the panel: a fixed pixels-per-unit rate
  /// drew the small pieces as stubs nobody could tap.
  static double scaleFor(Bend bend, Size size) =>
      size.height * 0.42 / math.max(bend.total, 0.001);

  /// Where an arrow's head lands, so a tap can be judged against it.
  static Offset headOf(Bend bend, Size size, Piece piece) {
    final (at, along) = carAt(size);
    const toward = Offset(0, 1);
    final scale = scaleFor(bend, size);
    return switch (piece) {
      Piece.along => at + along * (bend.alongRoad * scale),
      Piece.toward => at + toward * (bend.towardCenter * scale),
      Piece.total => at +
          along * (bend.alongRoad * scale) +
          toward * (bend.towardCenter * scale),
    };
  }

  static Piece? nearest(Bend bend, Size size, List<Piece> pieces, Offset tap,
      {double within = 34}) {
    Piece? best;
    var gap = within;
    for (final p in pieces) {
      final d = (headOf(bend, size, p) - tap).distance;
      if (d < gap) {
        gap = d;
        best = p;
      }
    }
    return best;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final middle = centerOf(size);
    final r = radiusOf(size);
    // The road, seen from above, as an arc through the vehicle.
    canvas
      ..drawArc(
        Rect.fromCircle(center: middle, radius: r),
        -math.pi * 0.86,
        math.pi * 0.72,
        false,
        Paint()
          ..color = AppColors.ink3
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14,
      )
      // The middle of the bend itself, so the arrow toward it has somewhere
      // to be pointing.
      ..drawCircle(middle, 3, Paint()..color = AppColors.ink2);
    for (final spoke in [-0.7, 0.0, 0.7]) {
      final on = middle +
          Offset(math.cos(-math.pi / 2 + spoke) * r,
              math.sin(-math.pi / 2 + spoke) * r);
      canvas.drawLine(
        middle,
        on,
        Paint()
          ..color = AppColors.line
          ..strokeWidth = 0.8,
      );
    }

    final (at, _) = carAt(size);
    canvas.drawRect(
      Rect.fromCenter(center: at, width: 22, height: 11),
      Paint()..color = AppColors.charcoal,
    );

    for (final piece in show) {
      final isTruth = locked && piece == truth;
      final chosen = picked == piece;
      final color = isTruth
          ? AppColors.forest
          : (locked && chosen)
              ? AppColors.error
              : chosen
                  ? AppColors.ember
                  : AppColors.info;
      _arrow(canvas, at, headOf(bend, size, piece), color,
          heavy: chosen || isTruth);
    }

    // Which way the middle of the bend is, since that is what normal means.
    _write(canvas, 'center of the bend',
        Offset(middle.dx + 8, middle.dy - 4), AppColors.ink3);
    _write(canvas, 'along the road', Offset(size.width - 92, 4),
        AppColors.ink3);
    viewTag(canvas, size, Looking.plan);
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
      text: TextSpan(text: text, style: AppTheme.mono(size: 9.5, color: color)),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, at);
  }

  @override
  bool shouldRepaint(BendPainter old) =>
      old.bend != bend || old.picked != picked || old.locked != locked;
}
