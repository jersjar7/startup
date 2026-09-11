import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';

/// A point held as coordinates, the way every modern survey holds one.
@immutable
class Peg2 {
  const Peg2(this.name, this.east, this.north);

  final String name;
  final double east;
  final double north;
}

/// Which of the two computations a job calls for.
enum Work { forward, inverse }

extension WorkWords on Work {
  String get plain => switch (this) {
        Work.forward =>
          'Forward: work the course out into coordinates',
        Work.inverse =>
          'Inverse: work the two coordinates back into a course',
      };
}

/// A piece of coordinate work: what is known on the ground, and what is
/// wanted from it.
@immutable
class Task {
  const Task({
    required this.known,
    this.wanted,
    this.length,
    this.azimuth,
  });

  /// Points whose coordinates are already held.
  final List<Peg2> known;

  /// A point that has no coordinates yet, drawn hollow. Where there is one,
  /// the job is a forward computation.
  final Peg2? wanted;

  /// A measured course from the known point, where one was measured.
  final double? length;
  final double? azimuth;

  /// Read off what is known and what is not, never declared: two known
  /// points and the course between them is wanted, or one known point and a
  /// course and the far point is wanted.
  Work get work => wanted == null ? Work.inverse : Work.forward;

  double get deltaEast =>
      known.length >= 2 ? known[1].east - known[0].east : 0;

  double get deltaNorth =>
      known.length >= 2 ? known[1].north - known[0].north : 0;

  double get distance =>
      math.sqrt(deltaEast * deltaEast + deltaNorth * deltaNorth);

  /// What a calculator hands back for arctangent of one number, in degrees.
  /// It lands between minus a right angle and a right angle, which is half
  /// the compass, so it is not yet an azimuth.
  double get rawArctan => deltaNorth == 0
      ? (deltaEast >= 0 ? 90 : -90)
      : math.atan(deltaEast / deltaNorth) * 180 / math.pi;

  /// What has to be done to that number to make it an azimuth: nothing when
  /// the line runs north and east, 180 whenever it runs south, and 360 when
  /// it runs north and west.
  double get toAdd {
    if (deltaNorth < 0) return 180;
    if (deltaEast < 0) return 360;
    return 0;
  }

  /// The azimuth the line actually has, clockwise from north.
  double get trueAzimuth =>
      (math.atan2(deltaEast, deltaNorth) * 180 / math.pi + 360) % 360;
}

/// The grid a survey works on: easting across, northing up, both labeled,
/// with the points plotted where their coordinates put them.
class CogoPainter extends CustomPainter {
  const CogoPainter({
    required this.task,
    this.showDeltas = false,
    this.showLine = true,
    this.step,
    this.showCoordinates = true,
    this.picked,
    this.answer,
    this.locked = false,
  });

  final Task task;

  /// The two coordinate differences drawn as the legs of their triangle.
  final bool showDeltas;
  final bool showLine;

  /// The spacing of the labeled grid, in feet. Left out, the drawing picks
  /// a round spacing that puts a handful of lines across the sheet rather
  /// than a hundred of them.
  final double? step;

  static double stepFor(Task task) {
    final pts = _all(task);
    final spanE = pts.map((p) => p.east).reduce(math.max) -
        pts.map((p) => p.east).reduce(math.min);
    final spanN = pts.map((p) => p.north).reduce(math.max) -
        pts.map((p) => p.north).reduce(math.min);
    final span = math.max(math.max(spanE, spanN), 1.0);
    final raw = span / 3;
    final k = (math.log(raw) / math.ln10).floor();
    final base = math.pow(10, k).toDouble();
    for (final m in [1.0, 2.0, 5.0]) {
      if (raw <= m * base) return m * base;
    }
    return 10 * base;
  }

  /// Whether each point carries its own coordinates. A round that asks
  /// which point a pair of numbers names cannot show them.
  final bool showCoordinates;

  /// Which of the known points a round has picked out, where the round is
  /// asking the reader to choose between them.
  final int? picked;
  final int? answer;
  final bool locked;

  static List<Peg2> _all(Task task) =>
      [...task.known, if (task.wanted != null) task.wanted!];

  static (double, double, double) _fit(Size size, Task task) {
    final pts = _all(task);
    var minE = pts.first.east, maxE = minE;
    var minN = pts.first.north, maxN = minN;
    for (final p in pts) {
      minE = math.min(minE, p.east);
      maxE = math.max(maxE, p.east);
      minN = math.min(minN, p.north);
      maxN = math.max(maxN, p.north);
    }
    // A margin round the outside, so a point never sits on the frame.
    const pad = 0.6;
    final spanE = math.max(maxE - minE, 1) * (1 + 2 * pad);
    final spanN = math.max(maxN - minN, 1) * (1 + 2 * pad);
    final scale = math.min((size.width - 74) / spanE,
        (size.height - 62) / spanN);
    final left = 52 - (minE - math.max(maxE - minE, 1) * pad) * scale;
    final bottom =
        size.height - 34 + (minN - math.max(maxN - minN, 1) * pad) * scale;
    return (scale, left, bottom);
  }

  /// Where point `i` of the drawing is tapped.
  static Offset spotOf(Size size, Task task, int i) {
    final p = _all(task)[i];
    return _at(size, task, p.east, p.north);
  }

  static int? at(Size size, Task task, Offset tap) {
    final pts = _all(task);
    for (var i = 0; i < pts.length; i++) {
      if ((spotOf(size, task, i) - tap).distance < 26) return i;
    }
    return null;
  }

  static Offset _at(Size size, Task task, double east, double north) {
    final (scale, left, bottom) = _fit(size, task);
    return Offset(left + east * scale, bottom - north * scale);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final pts = _all(task);
    final scale = _fit(size, task).$1;

    // The grid itself, drawn on round coordinate values with the easting
    // and northing written on the two axes.
    final thin = Paint()
      ..color = AppColors.line
      ..strokeWidth = 1;
    final step = this.step ?? stepFor(task);
    final minE = pts.map((p) => p.east).reduce(math.min);
    final maxE = pts.map((p) => p.east).reduce(math.max);
    final minN = pts.map((p) => p.north).reduce(math.min);
    final maxN = pts.map((p) => p.north).reduce(math.max);
    // Every line gets drawn; only a line far enough from the last labeled
    // one gets a number, so the axis never turns into a smear.
    var lastX = -999.0;
    for (var e = (minE / step).floor() * step - step;
        e <= maxE + step;
        e += step) {
      final x = _at(size, task, e, 0).dx;
      if (x < 30 || x > size.width - 8) continue;
      canvas.drawLine(Offset(x, 12), Offset(x, size.height - 30), thin);
      if (x - lastX > 46) {
        _write(canvas, size, _num(e), Offset(x - 16, size.height - 26),
            AppColors.ink3);
        lastX = x;
      }
    }
    var lastY = 999.0;
    for (var n = (minN / step).floor() * step - step;
        n <= maxN + step;
        n += step) {
      final y = _at(size, task, 0, n).dy;
      if (y < 12 || y > size.height - 30) continue;
      canvas.drawLine(Offset(30, y), Offset(size.width - 8, y), thin);
      if (lastY - y > 20) {
        _write(canvas, size, _num(n), Offset(2, y - 6), AppColors.ink3);
        lastY = y;
      }
    }
    _write(canvas, size, 'easting', Offset(size.width - 62, size.height - 14),
        AppColors.ink2);
    _write(canvas, size, 'northing', const Offset(2, 2), AppColors.ink2);

    final from = _at(size, task, task.known.first.east, task.known.first.north);
    final to = task.wanted != null
        ? _at(size, task, task.wanted!.east, task.wanted!.north)
        : (task.known.length > 1
            ? _at(size, task, task.known[1].east, task.known[1].north)
            : from);

    // The two coordinate differences, as the legs of the triangle the
    // inverse computation solves.
    if (showDeltas) {
      final corner = Offset(to.dx, from.dy);
      void dashed(Offset a, Offset b, Color color) {
        final run = b - a;
        if (run.distance < 1) return;
        final unit = run / run.distance;
        for (var k = 0.0; k < run.distance; k += 8) {
          canvas.drawLine(a + unit * k,
              a + unit * math.min(k + 4, run.distance),
              Paint()
                ..color = color
                ..strokeWidth = 1.6);
        }
      }

      dashed(from, corner, AppColors.forest);
      dashed(corner, to, AppColors.info);
      // A line straight along one axis has no triangle to hang labels off,
      // so the two signs go in the corner of the panel instead.
      if (task.deltaEast == 0 || task.deltaNorth == 0) {
        final signs = 'dE ${_sign(task.deltaEast)}   '
            'dN ${_sign(task.deltaNorth)}';
        _write(canvas, size, signs, Offset(size.width - 92, 4), AppColors.ink2);
      }
      // Otherwise each label goes on the side of its own leg away from the
      // triangle.
      if (task.deltaEast != 0) {
        _write(
            canvas,
            size,
            'dE ${task.deltaEast > 0 ? '+' : '-'}',
            Offset((from.dx + corner.dx) / 2 - 12,
                from.dy + (to.dy >= from.dy ? -15 : 6)),
            AppColors.forest);
      }
      if (task.deltaNorth != 0) {
        _write(
            canvas,
            size,
            'dN ${task.deltaNorth > 0 ? '+' : '-'}',
            Offset(corner.dx + (task.deltaEast > 0 ? 7 : -34),
                (corner.dy + to.dy) / 2 - 6),
            AppColors.info);
      }
    }

    if (showLine && (task.wanted != null || task.known.length > 1)) {
      canvas.drawLine(
          from,
          to,
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 2.2);
      final head = (to - from).distance < 1
          ? Offset.zero
          : (to - from) / (to - from).distance;
      final side = Offset(-head.dy, head.dx) * 4.5;
      final ink = Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 2;
      canvas
        ..drawLine(to, to - head * 10 + side, ink)
        ..drawLine(to, to - head * 10 - side, ink);
    }

    // The course, where one was measured but its far end is not yet fixed.
    if (task.length != null && task.azimuth != null) {
      final run = to - from;
      final along = run.distance < 1 ? const Offset(0, -1) : run / run.distance;
      final square = Offset(-along.dy, along.dx);
      // To the left of the way the course runs, which is the side of the
      // line the point labels are not on.
      final at = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2) -
          square * 14;
      _write(
        canvas,
        size,
        '${_num(task.length!)} ft at ${_num(task.azimuth!)}°',
        at + Offset(square.dx >= 0 ? 0 : -4, -5),
        AppColors.ember,
        fromRight: square.dx < 0,
      );
    }

    for (var i = 0; i < pts.length; i++) {
      final p = pts[i];
      final at = _at(size, task, p.east, p.north);
      final held = task.known.contains(p);
      Color tone = held ? AppColors.charcoal : AppColors.ember;
      if (locked && answer == i) {
        tone = AppColors.forest;
      } else if (locked && picked == i) {
        tone = AppColors.error;
      } else if (picked == i) {
        tone = AppColors.ember;
      }
      final chosen = picked == i || (locked && answer == i);
      canvas
        ..drawCircle(at, chosen ? 8 : 5.5, Paint()..color = AppColors.cream)
        ..drawCircle(
            at,
            chosen ? 8 : 5.5,
            Paint()
              ..color = tone
              ..style = PaintingStyle.stroke
              ..strokeWidth = chosen ? 2.4 : 1.8);
      if (held) {
        canvas.drawCircle(at, 2, Paint()..color = tone);
      }
      final label = !showCoordinates
          ? p.name
          : held
              ? '${p.name} (${_num(p.east)}, ${_num(p.north)})'
              : '${p.name} (?, ?)';
      // Hung off the side of the point that faces away from the line, so
      // the label never lies across the very thing it names.
      final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
      final off = at - mid;
      final away = off.distance < 1
          ? const Offset(1, -1)
          : off / off.distance;
      _write(
        canvas,
        size,
        label,
        at + Offset(away.dx >= 0 ? 9 : -9, away.dy >= 0 ? 12 : -17),
        tone,
        fromRight: away.dx < 0,
      );
    }

    if (scale > 0) viewTag(canvas, size, Looking.plan, note: 'E across, N up');
  }

  @override
  bool shouldRepaint(CogoPainter old) =>
      old.task != task ||
      old.showDeltas != showDeltas ||
      old.showLine != showLine ||
      old.step != step ||
      old.showCoordinates != showCoordinates ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked;
}

String _sign(double v) => v == 0 ? '0' : (v > 0 ? '+' : '-');

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();

void _write(Canvas canvas, Size size, String text, Offset at, Color color,
    {bool fromRight = false}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
    textDirection: TextDirection.ltr,
  )..layout();
  var x = fromRight ? at.dx - painter.width : at.dx;
  if (x + painter.width > size.width - 2) x = size.width - 2 - painter.width;
  if (x < 2) x = 2;
  final patch =
      Rect.fromLTWH(x - 2, at.dy - 1, painter.width + 4, painter.height + 2);
  canvas.drawRect(
      patch, Paint()..color = AppColors.cream.withValues(alpha: 0.92));
  painter.paint(canvas, Offset(x, at.dy));
}
