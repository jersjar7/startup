import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';
import 'survey_figures.dart';

/// One course of a traverse: how long it is and which way it runs.
@immutable
class Course {
  const Course({
    required this.azimuth,
    required this.length,
    this.from = 'A',
    this.to = 'B',
  });

  /// Clockwise from north, 0 to 360.
  final double azimuth;
  final double length;
  final String from;
  final String to;

  double get _r => azimuth * math.pi / 180;

  /// How far north it goes. Negative means south.
  double get latitude => length * math.cos(_r);

  /// How far east it goes. Negative means west.
  double get departure => length * math.sin(_r);

  /// Which quarter of the compass it runs into, which is the whole of what
  /// decides the two signs.
  Quad get quad {
    final a = azimuth % 360;
    if (a < 90) return Quad.ne;
    if (a < 180) return Quad.se;
    if (a < 270) return Quad.sw;
    return Quad.nw;
  }
}

/// One course drawn in plan with its latitude and departure: the right
/// triangle the two formulas come out of, with north up the sheet.
class LegPainter extends CustomPainter {
  const LegPainter({required this.course, this.showSigns = false});

  final Course course;

  /// The two signs are written on only once the round is over. Before that
  /// the drawing shows which way the course runs and nothing more.
  final bool showSigns;

  @override
  void paint(Canvas canvas, Size size) {
    // The course is drawn from the corner it starts at, to scale in
    // direction, sized to fit whichever way it runs.
    final r = course.azimuth * math.pi / 180;
    final dir = Offset(math.sin(r), -math.cos(r));
    final room = math.min(size.width * 0.33, size.height * 0.34);
    final a = Offset(size.width * 0.5 - dir.dx * room * 0.5,
        size.height * 0.52 - dir.dy * room * 0.5);
    final b = a + dir * room;
    final corner = Offset(b.dx, a.dy);

    final thin = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1;
    void dashed(Offset from, Offset to, Color color) {
      final run = to - from;
      if (run.distance < 1) return;
      final unit = run / run.distance;
      for (var k = 0.0; k < run.distance; k += 8) {
        canvas.drawLine(from + unit * k, from + unit * math.min(k + 4, run.distance),
            Paint()
              ..color = color
              ..strokeWidth = 1.6);
      }
    }

    // The meridian through the starting corner, so north is not in doubt.
    for (var y = a.dy - room - 18; y < a.dy + room + 18; y += 7) {
      canvas.drawLine(Offset(a.dx, y), Offset(a.dx, y + 4), thin);
    }

    // The two components: the latitude up or down the sheet, the departure
    // across it.
    dashed(a, corner, AppColors.info);
    dashed(corner, b, AppColors.forest);

    // The course itself.
    canvas.drawLine(
        a,
        b,
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 2.4);
    final head = (b - a) / (b - a).distance;
    final side = Offset(-head.dy, head.dx) * 4.5;
    canvas
      ..drawLine(b, b - head * 10 + side,
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 2)
      ..drawLine(b, b - head * 10 - side,
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 2);

    // The angle off north, which is the azimuth.
    canvas.drawArc(
      Rect.fromCircle(center: a, radius: 26),
      -math.pi / 2,
      r,
      false,
      Paint()
        ..color = AppColors.ember
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final mid = -math.pi / 2 + r / 2;
    _write(
        canvas,
        size,
        '${_num(course.azimuth)}°',
        a + Offset(math.cos(mid), math.sin(mid)) * 40 + const Offset(-10, -6),
        AppColors.ember);

    // The two stations.
    for (final (p, name) in [(a, course.from), (b, course.to)]) {
      canvas
        ..drawCircle(p, 5, Paint()..color = AppColors.cream)
        ..drawCircle(p, 3.4, Paint()..color = AppColors.charcoal);
      _write(canvas, size, name, p + const Offset(7, -16), AppColors.charcoal);
    }

    final latMid = Offset(a.dx, (a.dy + corner.dy) / 2);
    final depMid = Offset((corner.dx + b.dx) / 2, b.dy);
    _write(canvas, size, showSigns
        ? 'lat ${course.latitude >= 0 ? '+' : '-'}'
        : 'lat', latMid + const Offset(-30, -6), AppColors.info);
    _write(canvas, size, showSigns
        ? 'dep ${course.departure >= 0 ? '+' : '-'}'
        : 'dep', depMid + const Offset(-12, 8), AppColors.forest);
    _write(canvas, size, 'N', Offset(a.dx - 3, a.dy - room - 30),
        AppColors.ink2);
    _write(canvas, size, '${_num(course.length)} m long',
        const Offset(8, 8), AppColors.ink3);

    viewTag(canvas, size, Looking.plan, note: 'north up the sheet');
  }

  @override
  bool shouldRepaint(LegPainter old) =>
      old.course != course || old.showSigns != showSigns;
}

/// A closed traverse: the courses round it, and how far out it finished.
@immutable
class Trip {
  const Trip({
    required this.lengths,
    this.driftNorth = 0,
    this.driftEast = 0,
    this.names = const ['A', 'B', 'C', 'D', 'E', 'F'],
  });

  /// The length of each course, in order round the figure.
  final List<double> lengths;

  /// What the latitudes and the departures came to instead of nothing, in
  /// meters. Positive north and positive east.
  final double driftNorth;
  final double driftEast;

  final List<String> names;

  double get perimeter => lengths.fold(0, (a, b) => a + b);

  /// How far the far end finished from where it started.
  double get closure =>
      math.sqrt(driftNorth * driftNorth + driftEast * driftEast);

  /// One over the precision ratio, so a bigger number is a better traverse.
  double get precision => closure == 0 ? double.infinity : perimeter / closure;

  /// The course that takes the biggest share of the compass rule
  /// correction, which is the longest one and nothing else.
  int get longest {
    var best = 0;
    for (var i = 1; i < lengths.length; i++) {
      if (lengths[i] > lengths[best]) best = i;
    }
    return best;
  }
}

/// A traverse drawn in plan the way a field sketch is drawn: roughly to
/// shape, lengths written on the courses, and not to scale. The closing gap
/// is drawn far larger than it is, and says so.
class TripPainter extends CustomPainter {
  const TripPainter({
    required this.trip,
    this.picked,
    this.answer,
    this.locked = false,
    this.showGap = true,
  });

  final Trip trip;
  final int? picked;
  final int? answer;
  final bool locked;

  /// Whether the closing gap is drawn at all.
  final bool showGap;

  static List<Offset> _corners(Size size, Trip trip) {
    final n = trip.lengths.length;
    final rx = size.width * 0.30;
    final ry = size.height * 0.30;
    final c = Offset(size.width * 0.5, size.height * 0.50);
    return [
      for (var i = 0; i < n; i++)
        c +
            Offset(math.cos(-math.pi / 2 + i * 2 * math.pi / n) * rx,
                math.sin(-math.pi / 2 + i * 2 * math.pi / n) * ry),
    ];
  }

  /// Where course `i` is tapped: the middle of its own line.
  static Offset spotOf(Size size, Trip trip, int i) {
    final pts = _corners(size, trip);
    final a = pts[i];
    final b = pts[(i + 1) % pts.length];
    return Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
  }

  static int? at(Size size, Trip trip, Offset tap) {
    for (var i = 0; i < trip.lengths.length; i++) {
      if ((spotOf(size, trip, i) - tap).distance < 26) return i;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final pts = _corners(size, trip);
    final n = pts.length;

    for (var i = 0; i < n; i++) {
      final a = pts[i];
      final b = pts[(i + 1) % n];
      final Color tone;
      if (locked && answer == i) {
        tone = AppColors.forest;
      } else if (locked && picked == i) {
        tone = AppColors.error;
      } else if (picked == i) {
        tone = AppColors.ember;
      } else {
        tone = AppColors.charcoal;
      }
      // The last course stops short of the start when the traverse did.
      final short = i == n - 1 && showGap && trip.closure > 0;
      final end = short ? a + (b - a) * 0.86 : b;
      canvas.drawLine(
          a,
          end,
          Paint()
            ..color = tone
            ..strokeWidth = (picked == i || (locked && answer == i)) ? 3 : 1.8);
      final mid = spotOf(size, trip, i);
      _write(canvas, size, '${_num(trip.lengths[i])} m',
          mid + const Offset(-16, -6), tone);
      if (short) {
        canvas.drawLine(
            end,
            b,
            Paint()
              ..color = AppColors.error
              ..strokeWidth = 2.4);
        // The gap is labeled outward, away from the middle of the figure,
        // so the word never lands on a course.
        final middle = Offset(size.width / 2, size.height / 2);
        final gapAt = Offset((end.dx + b.dx) / 2, (end.dy + b.dy) / 2);
        final out = gapAt - middle;
        final away = out.distance < 1 ? const Offset(0, -1) : out / out.distance;
        _write(canvas, size, 'gap', gapAt + away * 18 + const Offset(-8, -6),
            AppColors.error);
      }
    }

    // Station letters are worth having on a full width sketch and are only
    // clutter on a panel half that wide.
    final roomy = size.width > 200;
    for (var i = 0; i < n; i++) {
      canvas
        ..drawCircle(pts[i], 5, Paint()..color = AppColors.cream)
        ..drawCircle(pts[i], 3.4, Paint()..color = AppColors.charcoal);
      if (roomy) {
        _write(canvas, size, trip.names[i % trip.names.length],
            pts[i] + const Offset(7, -16), AppColors.ink2);
      }
    }

    // The two numbers the whole check runs on, each on its own row and both
    // clear of the view tag along the bottom.
    _write(canvas, size, '${_num(trip.perimeter)} m round',
        Offset(8, size.height - 40), AppColors.ink3);
    if (showGap && trip.closure > 0) {
      _write(canvas, size, 'out by ${trip.closure.toStringAsFixed(2)} m',
          Offset(8, size.height - 28), AppColors.error);
    }
    viewTag(canvas, size, Looking.plan,
        note: roomy ? 'gap exaggerated' : null);
  }

  @override
  bool shouldRepaint(TripPainter old) =>
      old.trip != trip ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked ||
      old.showGap != showGap;
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();

void _write(Canvas canvas, Size size, String text, Offset at, Color color) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
    textDirection: TextDirection.ltr,
  )..layout();
  var x = at.dx;
  if (x + painter.width > size.width - 2) x = size.width - 2 - painter.width;
  if (x < 2) x = 2;
  final patch =
      Rect.fromLTWH(x - 2, at.dy - 1, painter.width + 4, painter.height + 2);
  canvas.drawRect(
      patch, Paint()..color = AppColors.cream.withValues(alpha: 0.92));
  painter.paint(canvas, Offset(x, at.dy));
}
