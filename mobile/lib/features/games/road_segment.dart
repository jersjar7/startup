import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// One stretch of road between two nodes, with its own animation.
///
/// The shape is not hand-drawn per chapter: it is derived from the two node
/// centers with the same rule everywhere, so a chapter map of any length or
/// weave gets its roads for free. Each segment is a widget, so a single
/// stretch can be looked at, tested and debugged on its own.
///
/// [travelled] is what the student has walked. It paints forward from the
/// finished node toward the next one, so completing a lesson visibly opens the
/// way to the one after it.
class RoadSegment extends StatefulWidget {
  const RoadSegment({
    super.key,
    required this.from,
    required this.to,
    required this.travelled,
    this.startDelay = Duration.zero,
    this.duration = const Duration(milliseconds: 850),
    this.nodeRadius = 39,
  });

  /// Node centers, in the coordinate space of the widget that places this.
  final Offset from;
  final Offset to;

  /// 0 keeps the road pale, 1 walks it all the way to the next node.
  final double travelled;

  /// Held back so the node's own ring can finish filling first.
  final Duration startDelay;
  final Duration duration;
  final double nodeRadius;

  /// The box this segment needs, in the same coordinate space.
  Rect get bounds => Rect.fromLTRB(
        math.min(from.dx, to.dx) - nodeRadius - 24,
        math.min(from.dy, to.dy) - 4,
        math.max(from.dx, to.dx) + nodeRadius + 24,
        math.max(from.dy, to.dy) + 4,
      );

  @override
  State<RoadSegment> createState() => _RoadSegmentState();
}

class _RoadSegmentState extends State<RoadSegment>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.travelled,
  );

  @override
  void initState() {
    super.initState();
    if (widget.travelled > 0) _c.value = widget.travelled;
  }

  @override
  void didUpdateWidget(RoadSegment old) {
    super.didUpdateWidget(old);
    if (old.travelled == widget.travelled) return;
    if (widget.travelled > _c.value) {
      Future.delayed(widget.startDelay, () {
        if (mounted) _c.animateTo(widget.travelled, curve: Curves.easeOutCubic);
      });
    } else {
      _c.value = widget.travelled;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.bounds;
    return Positioned(
      left: b.left,
      top: b.top,
      width: b.width,
      height: b.height,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: RoadPainter(
            from: widget.from - b.topLeft,
            to: widget.to - b.topLeft,
            travelled: _c.value,
            nodeRadius: widget.nodeRadius,
          ),
        ),
      ),
    );
  }
}

/// The road itself: a warm track with a dashed center line, and the walked
/// part of it painted over in forest.
class RoadPainter extends CustomPainter {
  RoadPainter({
    required this.from,
    required this.to,
    required this.travelled,
    required this.nodeRadius,
  });

  final Offset from;
  final Offset to;
  final double travelled;
  final double nodeRadius;

  /// Same curve rule for every segment on every chapter: leave the node, lean
  /// most of the way toward the next node's column, arrive.
  ///
  /// The curve is drawn center to center and then trimmed by ARC LENGTH at
  /// both ends, so it meets each circle wherever the curve actually crosses
  /// it. Trimming along the straight line between centers instead, which is
  /// what this did first, leaves the road stopping short of a node it bends
  /// away from.
  Path _road() {
    final gap = (to - from).distance;
    if (gap == 0) return Path();

    final dx = to.dx - from.dx;
    final lean = dx.abs() > 4 ? from.dx + dx * 0.8 : from.dx + nodeRadius * 0.55;
    final control = Offset(lean, from.dy + (to.dy - from.dy) * 0.52);

    final full = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(control.dx, control.dy, to.dx, to.dy);

    final metrics = full.computeMetrics().toList();
    if (metrics.isEmpty) return full;
    final metric = metrics.first;

    // Tuck a little under each node so there is no seam where they meet.
    final reach = nodeRadius - 3;
    const step = 2.0;

    var start = 0.0;
    for (var d = 0.0; d < metric.length; d += step) {
      final p = metric.getTangentForOffset(d)?.position;
      if (p == null) break;
      if ((p - from).distance >= reach) {
        start = d;
        break;
      }
    }

    var end = metric.length;
    for (var d = metric.length; d > start; d -= step) {
      final p = metric.getTangentForOffset(d)?.position;
      if (p == null) break;
      if ((p - to).distance >= reach) {
        end = d;
        break;
      }
    }

    return metric.extractPath(start, end);
  }

  /// The trimmed path, exposed so its geometry can be checked directly.
  @visibleForTesting
  Path debugRoad() => _road();

  @override
  void paint(Canvas canvas, Size size) {
    final road = _road();

    canvas.drawPath(
      road,
      Paint()
        ..color = const Color(0xFFEADFCD)
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    _dash(canvas, road, const Color(0xFFCBBBA0), 3);

    if (travelled <= 0) return;

    // The walked part, painted forward from the finished node.
    for (final metric in road.computeMetrics()) {
      final walked = metric.extractPath(0, metric.length * travelled.clamp(0, 1));
      canvas.drawPath(
        walked,
        Paint()
          ..color = AppColors.forest.withValues(alpha: 0.75)
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
      _dash(canvas, walked, Colors.white.withValues(alpha: 0.8), 3);
    }
  }

  void _dash(Canvas canvas, Path path, Color color, double width) {
    const dash = 10.0, space = 9.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final metric in path.computeMetrics()) {
      var d = 4.0;
      while (d < metric.length) {
        canvas.drawPath(
          metric.extractPath(d, math.min(d + dash, metric.length)),
          paint,
        );
        d += dash + space;
      }
    }
  }

  @override
  bool shouldRepaint(RoadPainter old) =>
      old.travelled != travelled || old.from != from || old.to != to;
}
