import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// The shape of the cut, looking straight down the channel.
enum Shaped { rectangle, trapezoid, circle }

/// A named piece of the boundary. The whole of this lesson's first trap is
/// which of these the water is actually rubbing against: the free surface
/// is not one of them, and neither is anything above the water line.
enum Edge {
  bed,
  leftWet,
  rightWet,
  surface,
  leftDry,
  rightDry,
}

extension EdgeWords on Edge {
  String get plain => switch (this) {
        Edge.bed => 'the bed',
        Edge.leftWet => 'the left wall, up to the water',
        Edge.rightWet => 'the right wall, up to the water',
        Edge.surface => 'the water surface',
        Edge.leftDry => 'the left wall above the water',
        Edge.rightDry => 'the right wall above the water',
      };
}

/// A channel cut across, with water in it.
@immutable
class Channel {
  const Channel({
    required this.shape,
    required this.width,
    required this.depth,
    this.sideRun = 0,
    this.rim = 0,
    this.unit = 'ft',
  });

  final Shaped shape;

  /// The bed width, or for a circle the diameter.
  final double width;

  /// How deep the water is. At or above the diameter a circle runs full.
  final double depth;

  /// A trapezoid's side slope: this much across for each one up.
  final double sideRun;

  /// Freeboard: how much wall stands above the water. Dry, so it never
  /// counts toward the wetted perimeter, which is exactly the trap.
  final double rim;

  /// What the drawing is dimensioned in. Manning's equation takes feet or
  /// meters and nothing else, so this is the only thing that decides which
  /// constant goes in front of it, and whether the lengths have to be fixed
  /// before anything else can happen.
  final String unit;

  /// Whether the lengths can go straight into Manning's as they stand.
  bool get readyToUse => unit == 'ft' || unit == 'm';

  /// 1.0 in meters, 1.486 in feet. Nothing else about the equation changes,
  /// and n is dimensionless, so it is the same number either way.
  double get constant => unit == 'm' ? 1.0 : 1.486;

  bool get isFull => shape == Shaped.circle && depth >= width - 0.0001;

  /// The angle the water subtends at the middle of a part full pipe.
  double get _theta {
    final ratio = (1 - 2 * depth / width).clamp(-1.0, 1.0);
    return 2 * math.acos(ratio);
  }

  double get area => switch (shape) {
        Shaped.rectangle => width * depth,
        Shaped.trapezoid => depth * (width + sideRun * depth),
        Shaped.circle => isFull
            ? math.pi * width * width / 4
            : width * width / 8 * (_theta - math.sin(_theta)),
      };

  /// What the water rubs against. The free surface is not in it.
  double get wetted => switch (shape) {
        Shaped.rectangle => width + 2 * depth,
        Shaped.trapezoid =>
          width + 2 * depth * math.sqrt(1 + sideRun * sideRun),
        Shaped.circle => isFull ? math.pi * width : width * _theta / 2,
      };

  /// Area per unit of rubbing. It is not a radius of anything: on a full
  /// pipe it comes to a quarter of the diameter, half the physical radius.
  double get hydraulicRadius => area / wetted;

  /// The widest the drawing gets: on a trapezoid the banks keep spreading
  /// above the water, so the top of the freeboard is wider than the water
  /// surface is. Leaving the freeboard out of this once ran the banks off
  /// both sides of the panel.
  double get brimWidth => switch (shape) {
        Shaped.rectangle => width,
        Shaped.trapezoid => width + 2 * sideRun * (depth + rim),
        Shaped.circle => width,
      };

  /// The width of the free surface, which a covered full pipe does not have.
  double get topWidth => switch (shape) {
        Shaped.rectangle => width,
        Shaped.trapezoid => width + 2 * sideRun * depth,
        Shaped.circle =>
          isFull ? 0 : width * math.sin(_theta / 2),
      };

  /// Straight sided sections have named boundary pieces to point at. A
  /// circle is one curve and is asked about a different way.
  bool get hasParts => shape != Shaped.circle;
}

/// The cut, drawn as a section: lining hatched so it reads as material, the
/// water filled and given a proper surface mark, and the view stated.
class SectionPainter extends CustomPainter {
  const SectionPainter({
    required this.channel,
    this.traced = const [],
    this.picked,
    this.answer,
    this.locked = false,
    this.showDimensions = true,
    this.note,
    this.caption,
    this.alongside,
  });

  final Channel channel;

  /// A boundary a worked solution counted, drawn over the section. One of
  /// the rounds always has it wrong.
  final List<Edge> traced;
  final Edge? picked;
  final Edge? answer;
  final bool locked;

  /// Whether the width and depth are dimensioned on the drawing.
  final bool showDimensions;
  final String? note;

  /// A line under the drawing, for the roughness or the slope.
  final String? caption;

  /// The section this one is being compared against, so both are drawn to
  /// the same scale and sit on the same baseline.
  final Channel? alongside;

  static const _pad = 30.0;
  static const _lining = 9.0;

  /// How many pixels one foot, or one meter, is worth. A wide shallow ditch
  /// drawn to one scale is a line: at 12 feet across and 1 foot deep the bed
  /// and the water surface land on top of each other. Sections like that are
  /// drawn with the vertical exaggerated, which is ordinary drafting, and
  /// the drawing says so when it happens. A pipe never is: a stretched
  /// circle is a lie about the shape.
  static double _across(Channel c) =>
      math.max(c.brimWidth, c.topWidth) * 1.1;

  static double _up(Channel c) =>
      c.shape == Shaped.circle ? c.width : c.depth + c.rim + 0.6;

  /// When two sections are shown together they must be drawn to ONE scale,
  /// or the comparison between them is a lie: a ditch twenty feet across
  /// would be drawn the same width as a channel four feet across, and the
  /// reader would have no way to see it.
  static (double, double) scaleOf(Size size, Channel c, {Channel? other}) {
    final across = math.max(_across(c), other == null ? 0 : _across(other));
    final up = math.max(_up(c), other == null ? 0 : _up(other));
    final sx = (size.width - 2 * _pad - 2 * _lining) / math.max(across, 0.1);
    final sy = (size.height - _pad - 40) / math.max(up, 0.1);
    final flat = math.min(sx, sy);
    if (c.shape == Shaped.circle) return (flat, flat);
    // To scale unless the shallower water would come out too thin to point
    // at, and then stretched by just enough to read, never more.
    const readable = 60.0;
    final thinnest =
        other == null ? c.depth : math.min(c.depth, other.depth);
    if (thinnest * flat >= readable) return (flat, flat);
    final wanted = readable / math.max(thinnest, 0.01);
    return (flat, wanted.clamp(flat, math.min(sy, flat * 3)));
  }

  /// How much taller than life the section is drawn, 1 when it is to scale.
  static double stretchOf(Size size, Channel c, {Channel? other}) {
    final (sx, sy) = scaleOf(size, c, other: other);
    return sy / sx;
  }

  /// The middle of the bed, in panel coordinates.
  static Offset originOf(Size size, Channel c, {Channel? other}) {
    final (_, sy) = scaleOf(size, c, other: other);
    final up = math.max(
        c.shape == Shaped.circle ? c.width : c.depth + c.rim,
        other == null
            ? 0.0
            : (other.shape == Shaped.circle
                ? other.width
                : other.depth + other.rim));
    return Offset(size.width / 2, (size.height - 30 + up * sy) / 2);
  }

  /// The boundary pieces, as lines on the panel.
  static List<(Edge, Offset, Offset)> segmentsOf(Size size, Channel c) {
    if (!c.hasParts) return const [];
    final (sx, sy) = scaleOf(size, c);
    final o = originOf(size, c);
    final halfBed = c.width / 2 * sx;
    final water = c.depth * sy;
    final rim = c.rim * sy;
    final runWet = c.sideRun * c.depth * sx;
    final runRim = c.sideRun * (c.depth + c.rim) * sx;

    final bedLeft = Offset(o.dx - halfBed, o.dy);
    final bedRight = Offset(o.dx + halfBed, o.dy);
    final wetLeft = Offset(o.dx - halfBed - runWet, o.dy - water);
    final wetRight = Offset(o.dx + halfBed + runWet, o.dy - water);
    final topLeft = Offset(o.dx - halfBed - runRim, o.dy - water - rim);
    final topRight = Offset(o.dx + halfBed + runRim, o.dy - water - rim);

    return [
      (Edge.bed, bedLeft, bedRight),
      (Edge.leftWet, bedLeft, wetLeft),
      (Edge.rightWet, bedRight, wetRight),
      (Edge.surface, wetLeft, wetRight),
      if (c.rim > 0) (Edge.leftDry, wetLeft, topLeft),
      if (c.rim > 0) (Edge.rightDry, wetRight, topRight),
    ];
  }

  /// Where a label for a piece can sit without landing on the section.
  static Offset labelAnchorOf(Size size, Channel c, Edge part) {
    final seg = segmentsOf(size, c).firstWhere((s) => s.$1 == part);
    return Offset((seg.$2.dx + seg.$3.dx) / 2, (seg.$2.dy + seg.$3.dy) / 2);
  }

  static Edge? at(Size size, Channel c, Offset tap) {
    Edge? best;
    var near = 22.0;
    for (final (part, a, b) in segmentsOf(size, c)) {
      final d = _distanceTo(tap, a, b);
      if (d < near) {
        near = d;
        best = part;
      }
    }
    return best;
  }

  static double _distanceTo(Offset p, Offset a, Offset b) {
    final run = b - a;
    final len2 = run.dx * run.dx + run.dy * run.dy;
    if (len2 < 0.01) return (p - a).distance;
    final t =
        (((p - a).dx * run.dx + (p - a).dy * run.dy) / len2).clamp(0.0, 1.0);
    return (p - (a + run * t)).distance;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final (sx, sy) = scaleOf(size, channel, other: alongside);
    final o = originOf(size, channel, other: alongside);

    if (channel.shape == Shaped.circle) {
      _paintPipe(canvas, size, sx, o);
    } else {
      _paintOpen(canvas, size, sx, sy, o);
    }

    // The counted boundary, laid over the section in ember so it reads as
    // somebody's working rather than as part of the drawing.
    for (final (part, a, b) in segmentsOf(size, channel)) {
      final tracedHere = traced.contains(part);
      final Color? tone;
      if (locked && answer == part) {
        tone = AppColors.forest;
      } else if (locked && picked == part) {
        tone = AppColors.error;
      } else if (picked == part) {
        tone = AppColors.ember;
      } else if (tracedHere) {
        tone = AppColors.ember;
      } else {
        tone = null;
      }
      if (tone == null) continue;
      canvas.drawLine(
          a,
          b,
          Paint()
            ..color = tone
            ..strokeWidth = tracedHere ? 3.4 : 2.6
            ..strokeCap = StrokeCap.round);
    }

    if (showDimensions) _dimension(canvas, size, sx, sy, o);
    final stretch = stretchOf(size, channel, other: alongside);
    if (stretch > 1.2) {
      writeOn(canvas, size, 'vertical x${stretch.toStringAsFixed(1)}',
          Offset(8, size.height - 26), AppColors.ink3, fontSize: 8.5);
    }
    if (caption != null) {
      writeOn(canvas, size, caption!, const Offset(8, 8), AppColors.ink2);
    }
    viewTag(canvas, size, Looking.section, note: note ?? 'across the channel');
  }

  void _paintOpen(
      Canvas canvas, Size size, double sx, double sy, Offset o) {
    final halfBed = channel.width / 2 * sx;
    final water = channel.depth * sy;
    final rim = channel.rim * sy;
    final runWet = channel.sideRun * channel.depth * sx;
    final runRim = channel.sideRun * (channel.depth + channel.rim) * sx;

    final inside = Path()
      ..moveTo(o.dx - halfBed - runRim, o.dy - water - rim)
      ..lineTo(o.dx - halfBed, o.dy)
      ..lineTo(o.dx + halfBed, o.dy)
      ..lineTo(o.dx + halfBed + runRim, o.dy - water - rim);

    // The lining: the inside profile and the same profile pushed out,
    // closed into one ring, so a wall is material with a thickness rather
    // than a line.
    final wall = Path()
      ..moveTo(o.dx - halfBed - runRim - _lining, o.dy - water - rim)
      ..lineTo(o.dx - halfBed - _lining, o.dy + _lining)
      ..lineTo(o.dx + halfBed + _lining, o.dy + _lining)
      ..lineTo(o.dx + halfBed + runRim + _lining, o.dy - water - rim)
      ..lineTo(o.dx + halfBed + runRim, o.dy - water - rim)
      ..lineTo(o.dx + halfBed, o.dy)
      ..lineTo(o.dx - halfBed, o.dy)
      ..lineTo(o.dx - halfBed - runRim, o.dy - water - rim)
      ..close();
    hatchIn(canvas, wall, step: 4.5);
    canvas.drawPath(
        wall,
        Paint()
          ..color = AppColors.ink2
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);

    // The water, filled to its surface.
    final wet = Path()
      ..moveTo(o.dx - halfBed - runWet, o.dy - water)
      ..lineTo(o.dx - halfBed, o.dy)
      ..lineTo(o.dx + halfBed, o.dy)
      ..lineTo(o.dx + halfBed + runWet, o.dy - water)
      ..close();
    canvas.drawPath(wet, waterFill);
    waterLevel(canvas, Offset(o.dx - halfBed - runWet, o.dy - water),
        Offset(o.dx + halfBed + runWet, o.dy - water));
    canvas.drawPath(
        inside,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);
  }

  void _paintPipe(Canvas canvas, Size size, double s, Offset o) {
    final r = channel.width / 2 * s;
    final middle = Offset(o.dx, o.dy - r);
    final bore = Path()..addOval(Rect.fromCircle(center: middle, radius: r));
    final barrel = Path.combine(
        PathOperation.difference,
        Path()
          ..addOval(Rect.fromCircle(center: middle, radius: r + _lining)),
        bore);
    hatchIn(canvas, barrel, step: 4.5);
    canvas.drawPath(
        barrel,
        Paint()
          ..color = AppColors.ink2
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);

    if (channel.isFull) {
      canvas.drawPath(bore, waterFill);
    } else {
      final water = channel.depth * s;
      final wet = Path.combine(
          PathOperation.intersect,
          bore,
          Path()
            ..addRect(Rect.fromLTWH(
                middle.dx - r, o.dy - water, 2 * r, water + 2)));
      canvas.drawPath(wet, waterFill);
      final half = channel.topWidth / 2 * s;
      waterLevel(canvas, Offset(middle.dx - half, o.dy - water),
          Offset(middle.dx + half, o.dy - water));
    }
    canvas.drawPath(
        bore,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);
  }

  void _dimension(
      Canvas canvas, Size size, double sx, double sy, Offset o) {
    final ink = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1;
    if (channel.shape == Shaped.circle) {
      // Under the barrel, not across the bore: on a part full pipe the
      // middle of the circle is exactly where the water surface is.
      final r = channel.width / 2 * sx;
      final y = o.dy + _lining + 12;
      canvas.drawLine(Offset(o.dx - r, y), Offset(o.dx + r, y), ink);
      writeOn(canvas, size, 'D ${_num(channel.width)} ${channel.unit}',
          Offset(o.dx - 24, y + 2), AppColors.ink3);
      return;
    }
    final halfBed = channel.width / 2 * sx;
    final water = channel.depth * sy;
    // The bed width, dimensioned below the lining.
    final y = o.dy + _lining + 12;
    canvas.drawLine(Offset(o.dx - halfBed, y), Offset(o.dx + halfBed, y), ink);
    writeOn(canvas, size, 'b ${_num(channel.width)} ${channel.unit}',
        Offset(o.dx - 24, y + 2), AppColors.ink3);
    // The depth, dimensioned inside the water and far enough off the wall
    // that its label does not sit on the boundary being asked about.
    final x = o.dx - halfBed + math.max(22, halfBed * 0.15);
    canvas.drawLine(Offset(x, o.dy), Offset(x, o.dy - water), ink);
    writeOn(canvas, size, 'y ${_num(channel.depth)} ${channel.unit}',
        Offset(x + 4, o.dy - water / 2 - 6), AppColors.ink3);
  }

  @override
  bool shouldRepaint(SectionPainter old) =>
      old.channel != channel ||
      old.traced != traced ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked ||
      old.caption != caption ||
      old.alongside != alongside;
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();
