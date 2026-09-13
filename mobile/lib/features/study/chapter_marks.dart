import 'package:flutter/material.dart';

/// A small line drawing for each chapter, drawn on the chapter card.
///
/// Fifteen chapter names set in the same weight of type all look the same,
/// and the student has to read every one to find the one they want. Fifteen
/// drawings do not: a truss is Statics, a U-tube is Fluids, three hatched
/// bands are Geotechnical. After a couple of days a chapter is found by its
/// shape, which is faster than reading.
///
/// They are drawn in the same language as the figures inside the items,
/// stroked in one weight with no fill, so the home screen looks like it
/// belongs to the same app as the boards.
///
/// The mark is NOT put in a box. Its COLOR says where the chapter stands
/// (quiet when untouched, forest once started, ember for the one in flight,
/// mint on charcoal when cleared), which is the job a tinted panel behind it
/// used to do badly.

/// Everything is drawn in a 46 by 32 box and scaled to whatever it is given,
/// so every mark has the same optical weight next to its neighbors.
const Size _drawn = Size(46, 32);

class ChapterMark extends StatelessWidget {
  const ChapterMark({
    super.key,
    required this.chapterId,
    required this.color,
    this.width = 46,
  });

  final String chapterId;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * _drawn.height / _drawn.width,
      child: CustomPaint(
        painter: _MarkPainter(chapterId: chapterId, color: color),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.chapterId, required this.color});

  final String chapterId;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / _drawn.width, size.height / _drawn.height);

    final ink = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final solid = Paint()..color = color;

    switch (chapterId) {
      case 'mathematics':
        _drawMathematics(canvas, ink);
      case 'statistics':
        _drawStatistics(canvas, ink);
      case 'ethics':
        _drawEthics(canvas, ink);
      case 'economics':
        _drawEconomics(canvas, ink);
      case 'statics':
        _drawStatics(canvas, ink);
      case 'dynamics':
        _drawDynamics(canvas, ink, solid);
      case 'mechanics-materials':
        _drawMechanicsMaterials(canvas, ink);
      case 'materials':
        _drawMaterials(canvas, ink, solid);
      case 'fluid-mechanics':
        _drawFluids(canvas, ink);
      case 'surveying':
        _drawSurveying(canvas, ink);
      case 'water-resources':
        _drawWater(canvas, ink, solid);
      case 'structural':
        _drawStructural(canvas, ink);
      case 'geotechnical':
        _drawGeotechnical(canvas, ink);
      case 'transportation':
        _drawTransportation(canvas, ink);
      case 'construction':
        _drawConstruction(canvas, ink);
      default:
        _drawFallback(canvas, ink);
    }

    canvas.restore();
  }

  /// A curve over its axes: the analytic geometry the chapter opens with.
  void _drawMathematics(Canvas canvas, Paint ink) {
    canvas
      ..drawLine(const Offset(6, 27), const Offset(40, 27), ink)
      ..drawLine(const Offset(10, 5), const Offset(10, 29), ink)
      ..drawPath(
          Path()
            ..moveTo(12, 25)
            ..quadraticBezierTo(23, 3, 38, 21),
          ink);
  }

  /// A normal curve with its mean marked.
  void _drawStatistics(Canvas canvas, Paint ink) {
    canvas
      ..drawLine(const Offset(6, 27), const Offset(40, 27), ink)
      ..drawPath(
          Path()
            ..moveTo(8, 27)
            ..cubicTo(16, 27, 15, 9, 23, 9)
            ..cubicTo(31, 9, 30, 27, 38, 27),
          ink);
    _dashed(canvas, const Offset(23, 9), const Offset(23, 27), ink);
  }

  /// A balance: the one drawing everybody reads as a judgment call.
  void _drawEthics(Canvas canvas, Paint ink) {
    canvas
      ..drawLine(const Offset(23, 6), const Offset(23, 25), ink)
      ..drawLine(const Offset(15, 27), const Offset(31, 27), ink)
      ..drawLine(const Offset(11, 10), const Offset(35, 10), ink)
      ..drawPath(
          Path()
            ..moveTo(11, 10)
            ..lineTo(7, 18)
            ..lineTo(15, 18)
            ..close(),
          ink)
      ..drawPath(
          Path()
            ..moveTo(35, 10)
            ..lineTo(31, 18)
            ..lineTo(39, 18)
            ..close(),
          ink);
  }

  /// A cash flow diagram: arrows of different sizes on a time line.
  void _drawEconomics(Canvas canvas, Paint ink) {
    canvas.drawLine(const Offset(7, 22), const Offset(39, 22), ink);
    for (final (x, top) in [(13.0, 13.0), (21.0, 9.0), (29.0, 15.0), (37.0, 6.0)]) {
      canvas
        ..drawLine(Offset(x, 22), Offset(x, top), ink)
        ..drawLine(Offset(x, top), Offset(x - 2, top + 3), ink)
        ..drawLine(Offset(x, top), Offset(x + 2, top + 3), ink);
    }
  }

  /// A truss, which is what the chapter is for.
  void _drawStatics(Canvas canvas, Paint ink) {
    canvas
      ..drawLine(const Offset(7, 25), const Offset(39, 25), ink)
      ..drawPath(
          Path()
            ..moveTo(7, 25)
            ..lineTo(15, 8)
            ..lineTo(23, 25)
            ..lineTo(31, 8)
            ..lineTo(39, 25),
          ink)
      ..drawLine(const Offset(15, 8), const Offset(31, 8), ink);
  }

  /// A projectile on its arc, with the body partway along it.
  void _drawDynamics(Canvas canvas, Paint ink, Paint solid) {
    canvas
      ..drawLine(const Offset(5, 27), const Offset(41, 27), ink)
      ..drawPath(
          Path()
            ..moveTo(8, 27)
            ..quadraticBezierTo(23, 3, 38, 27),
          ink)
      ..drawCircle(const Offset(23, 10), 2.6, solid);
  }

  /// A simply supported beam under a point load.
  void _drawMechanicsMaterials(Canvas canvas, Paint ink) {
    canvas
      ..drawLine(const Offset(9, 18), const Offset(37, 18), ink)
      ..drawLine(const Offset(23, 5), const Offset(23, 15), ink)
      ..drawLine(const Offset(23, 16), const Offset(20, 11), ink)
      ..drawLine(const Offset(23, 16), const Offset(26, 11), ink)
      ..drawPath(
          Path()
            ..moveTo(9, 18)
            ..lineTo(6, 25)
            ..lineTo(12, 25)
            ..close(),
          ink)
      ..drawPath(
          Path()
            ..moveTo(37, 18)
            ..lineTo(34, 25)
            ..lineTo(40, 25)
            ..close(),
          ink);
  }

  /// A stress-strain curve with the yield point on it.
  void _drawMaterials(Canvas canvas, Paint ink, Paint solid) {
    canvas
      ..drawLine(const Offset(9, 27), const Offset(9, 5), ink)
      ..drawLine(const Offset(9, 27), const Offset(40, 27), ink)
      ..drawPath(
          Path()
            ..moveTo(11, 25)
            ..lineTo(20, 11)
            ..quadraticBezierTo(27, 6, 36, 10),
          ink)
      ..drawCircle(const Offset(20, 11), 1.8, solid);
  }

  /// A U-tube manometer with its two legs at different heights.
  void _drawFluids(Canvas canvas, Paint ink) {
    canvas.drawPath(
        Path()
          ..moveTo(13, 5)
          ..lineTo(13, 20)
          ..quadraticBezierTo(13, 26, 19, 26)
          ..lineTo(27, 26)
          ..quadraticBezierTo(33, 26, 33, 20)
          ..lineTo(33, 9),
        ink);
    _dashed(canvas, const Offset(9, 13), const Offset(17, 13), ink);
    _dashed(canvas, const Offset(29, 13), const Offset(37, 13), ink);
  }

  /// An instrument sighting on a staff, which is every surveying lesson.
  void _drawSurveying(Canvas canvas, Paint ink) {
    canvas
      ..drawLine(const Offset(6, 27), const Offset(40, 27), ink)
      ..drawLine(const Offset(13, 27), const Offset(13, 15), ink)
      ..drawLine(const Offset(10, 15), const Offset(16, 15), ink)
      ..drawLine(const Offset(34, 27), const Offset(34, 8), ink)
      ..drawLine(const Offset(31, 8), const Offset(37, 8), ink);
    _dashed(canvas, const Offset(14, 16), const Offset(33, 10), ink);
  }

  /// A trapezoidal channel with water in it.
  void _drawWater(Canvas canvas, Paint ink, Paint solid) {
    canvas
      ..drawPath(
          Path()
            ..moveTo(7, 8)
            ..lineTo(15, 26)
            ..lineTo(31, 26)
            ..lineTo(39, 8),
          ink)
      ..drawLine(const Offset(10, 15), const Offset(36, 15), ink)
      ..drawPath(
          Path()
            ..moveTo(21, 11)
            ..lineTo(25, 11)
            ..lineTo(23, 15)
            ..close(),
          solid);
  }

  /// A portal frame carrying a load across its top.
  void _drawStructural(Canvas canvas, Paint ink) {
    canvas
      ..drawPath(
          Path()
            ..moveTo(11, 26)
            ..lineTo(11, 9)
            ..lineTo(35, 9)
            ..lineTo(35, 26),
          ink)
      ..drawLine(const Offset(6, 26), const Offset(16, 26), ink)
      ..drawLine(const Offset(30, 26), const Offset(40, 26), ink);
    for (final x in [15.0, 23.0, 31.0]) {
      canvas.drawLine(Offset(x, 5), Offset(x, 8), ink);
    }
  }

  /// Three soil layers, hatched the way a boring log is.
  ///
  /// Sparse on purpose. Four ticks per band turned into a scribble at the 46
  /// points a card gives it: the ticks have to be far enough apart to read as
  /// hatching rather than as a texture.
  void _drawGeotechnical(Canvas canvas, Paint ink) {
    for (final y in [9.0, 18.0, 27.0]) {
      canvas.drawLine(Offset(5, y), Offset(41, y), ink);
    }
    for (final x in [14.0, 28.0]) {
      canvas.drawLine(Offset(x, 9), Offset(x - 4, 14), ink);
    }
    for (final x in [21.0, 35.0]) {
      canvas.drawLine(Offset(x, 18), Offset(x - 4, 23), ink);
    }
  }

  /// A road easing into a curve, with the far edge behind it.
  void _drawTransportation(Canvas canvas, Paint ink) {
    canvas.drawPath(
        Path()
          ..moveTo(5, 24)
          ..lineTo(17, 24)
          ..quadraticBezierTo(28, 24, 32, 13)
          ..lineTo(41, 6),
        ink);
    final faint = Paint()
      ..color = ink.color.withValues(alpha: ink.color.a * 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
        Path()
          ..moveTo(5, 30)
          ..lineTo(17, 30)
          ..quadraticBezierTo(33, 30, 37, 17),
        faint);
  }

  /// Three bars stepping down a schedule.
  void _drawConstruction(Canvas canvas, Paint ink) {
    final bar = Paint()
      ..color = ink.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(const Offset(8, 9), const Offset(23, 9), bar)
      ..drawLine(const Offset(14, 16), const Offset(32, 16), bar)
      ..drawLine(const Offset(23, 23), const Offset(39, 23), bar);
  }

  /// Only reachable if a chapter id ever stops matching the catalog, which
  /// the test in study_tab_test.dart is there to stop.
  void _drawFallback(Canvas canvas, Paint ink) {
    canvas.drawRect(const Rect.fromLTRB(11, 8, 35, 25), ink);
  }

  /// A dashed run between two points. Flutter has no dash support on a
  /// stroke, so the segments are stepped by hand.
  void _dashed(Canvas canvas, Offset from, Offset to, Paint ink) {
    const on = 2.4;
    const off = 2.0;
    final span = to - from;
    final length = span.distance;
    if (length == 0) return;
    final step = span / length;
    var at = 0.0;
    while (at < length) {
      final end = (at + on).clamp(0.0, length);
      canvas.drawLine(from + step * at, from + step * end, ink);
      at = end + off;
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.chapterId != chapterId || old.color != color;
}
