import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// One place along the run that a round marks and can be tapped.
@immutable
class Sta {
  const Sta({required this.at, this.meters = false, this.bore});

  /// Where it sits across the drawing, 0 at the left edge and 1 at the right.
  final double at;

  /// Whether this is the opening the flow rate is metered on. Exactly one
  /// station in a round is, which is the answer.
  final bool meters;

  /// The width of the water there, where that is not the width of the pipe:
  /// the squeezed jet downstream of an orifice plate is narrower than the
  /// hole it came through.
  final double? bore;
}

/// A meter drawn in section: the wall profile, the two pressure taps that
/// define what is being measured, and the stations a round marks along it.
@immutable
class Gauge {
  const Gauge({
    required this.wall,
    required this.stations,
    required this.taps,
    this.plateAt,
    this.jet,
  });

  /// The flow path, as (x across the drawing, bore in millimeters) control
  /// points. Straight lengths are two points at the same bore; a cone is two
  /// points at different ones.
  final List<(double, double)> wall;

  final List<Sta> stations;

  /// Where the two pressure tappings are. What the meter measures is the
  /// difference between these, so the opening between them is the one the
  /// formula meters on.
  final (double, double) taps;

  /// An orifice plate, if there is one.
  final double? plateAt;

  /// The free jet downstream of a plate, which squeezes below the hole
  /// before it spreads again. Drawn, and never the metering area.
  final List<(double, double)>? jet;

  /// The bore of the flow path at any point across the drawing.
  double boreAt(double x) {
    if (x <= wall.first.$1) return wall.first.$2;
    if (x >= wall.last.$1) return wall.last.$2;
    for (var i = 1; i < wall.length; i++) {
      final (x0, b0) = wall[i - 1];
      final (x1, b1) = wall[i];
      if (x <= x1) {
        if (x1 == x0) return b1;
        return b0 + (b1 - b0) * (x - x0) / (x1 - x0);
      }
    }
    return wall.last.$2;
  }

  double get widest => wall.map((w) => w.$2).reduce(math.max);

  int get answer => stations.indexWhere((s) => s.meters);
}

/// The meter in section, with the stations numbered along the center line.
class GaugePainter extends CustomPainter {
  const GaugePainter({
    required this.gauge,
    this.picked,
    this.locked = false,
  });

  final Gauge gauge;
  final int? picked;
  final bool locked;

  static double _x(Size size, double at) => 14 + (size.width - 28) * at;

  static double _half(Size size, Gauge gauge, double bore) =>
      30 * bore / gauge.widest;

  static double _middle(Size size) => size.height * 0.45;

  /// Where station `i` is tapped.
  static Offset spotOf(Size size, Gauge gauge, int i) =>
      Offset(_x(size, gauge.stations[i].at), _middle(size));

  static int? at(Size size, Gauge gauge, Offset tap) {
    for (var i = 0; i < gauge.stations.length; i++) {
      if ((spotOf(size, gauge, i) - tap).distance < 26) return i;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final middle = _middle(size);
    Path side(List<(double, double)> profile, int sign) {
      final path = Path();
      for (var i = 0; i < profile.length; i++) {
        final x = _x(size, profile[i].$1);
        final y = middle + sign * _half(size, gauge, profile[i].$2);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      return path;
    }

    // The water, as the whole flow path filled in.
    final water = Path.from(side(gauge.wall, -1));
    for (var i = gauge.wall.length - 1; i >= 0; i--) {
      water.lineTo(_x(size, gauge.wall[i].$1),
          middle + _half(size, gauge, gauge.wall[i].$2));
    }
    canvas.drawPath(
        water..close(), Paint()..color = AppColors.info.withValues(alpha: 0.2));

    if (gauge.jet != null) {
      final jet = Path.from(side(gauge.jet!, -1));
      for (var i = gauge.jet!.length - 1; i >= 0; i--) {
        jet.lineTo(_x(size, gauge.jet![i].$1),
            middle + _half(size, gauge, gauge.jet![i].$2));
      }
      canvas.drawPath(
          jet..close(), Paint()..color = AppColors.info.withValues(alpha: 0.3));
    }

    // The pipe wall itself, as a band of steel rather than a bare line: the
    // flow path offset outward by a wall thickness, hatched between the two.
    final outer = [
      for (final w in gauge.wall) (w.$1, w.$2 + 2 * 0.09 * gauge.widest)
    ];
    for (final sign in [-1, 1]) {
      final band = Path.from(side(outer, sign));
      for (var i = gauge.wall.length - 1; i >= 0; i--) {
        band.lineTo(_x(size, gauge.wall[i].$1),
            middle + sign * _half(size, gauge, gauge.wall[i].$2));
      }
      band.close();
      canvas.drawPath(band, Paint()..color = AppColors.cream);
      hatchIn(canvas, band, step: 6);
      canvas.drawPath(
          band,
          Paint()
            ..color = AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4);
    }

    // The plate, drawn in from both walls to the edge of the hole.
    if (gauge.plateAt != null) {
      final x = _x(size, gauge.plateAt!);
      final hole = _half(size, gauge, gauge.boreAt(gauge.plateAt!));
      final outerHalf = _half(size, gauge, gauge.widest);
      for (final sign in [-1, 1]) {
        final leaf = Path()
          ..addRect(Rect.fromLTRB(x - 2.5, middle + sign * hole, x + 2.5,
              middle + sign * outerHalf));
        canvas.drawPath(leaf, Paint()..color = AppColors.cream);
        hatchIn(canvas, leaf, step: 4);
        canvas.drawPath(
            leaf,
            Paint()
              ..color = AppColors.charcoal
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4);
      }
    }

    // Which way it runs.
    final flow = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 1.5;
    final tip = Offset(_x(size, 0.06), middle);
    canvas
      ..drawLine(tip, tip - const Offset(9, -5), flow)
      ..drawLine(tip, tip - const Offset(9, 5), flow);

    // The two tappings, which are what says where the meter is.
    for (final at in [gauge.taps.$1, gauge.taps.$2]) {
      final x = _x(size, at);
      final top = middle - _half(size, gauge, gauge.boreAt(at));
      final stand = Paint()
        ..color = AppColors.ember
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas
        ..drawLine(Offset(x, top), Offset(x, top - 16), stand)
        ..drawCircle(Offset(x, top - 20), 4, stand);
    }
    writeOn(canvas, size, 'the two tappings', Offset(_x(size, 0.5) - 42, 6),
        AppColors.ember);
    viewTag(canvas, size, Looking.section);

    for (var i = 0; i < gauge.stations.length; i++) {
      final spot = spotOf(size, gauge, i);
      final Color tone;
      if (locked && i == gauge.answer) {
        tone = AppColors.forest;
      } else if (locked && picked == i) {
        tone = AppColors.error;
      } else if (picked == i) {
        tone = AppColors.ember;
      } else {
        tone = AppColors.charcoal;
      }
      canvas
        ..drawCircle(spot, 11, Paint()..color = AppColors.cream)
        ..drawCircle(
            spot,
            10,
            Paint()
              ..color = tone
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.2);
      writeOn(canvas, size, '${i + 1}', spot + const Offset(-3, -6), tone);
      // Two rows of bore labels, so neighboring stations never write over
      // each other.
      writeOn(          canvas,
          size,
          '${_num(gauge.stations[i].bore ?? gauge.boreAt(gauge.stations[i].at))} mm',
          Offset(spot.dx - 20, size.height - (i.isEven ? 27 : 15)),
          AppColors.ink3);
    }
  }

  @override
  bool shouldRepaint(GaugePainter old) =>
      old.gauge != gauge || old.picked != picked || old.locked != locked;
}

/// Bores are written to the nearest millimeter: a tenth of a millimeter on
/// a drawing of a water main is noise.
String _num(double v) => v.round().toString();

