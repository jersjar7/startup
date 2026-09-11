import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';

/// What the book does with a point in a level run. Every point in a run is
/// exactly one of these: the one you start from and only look back at, the
/// one you finish on and only look forward to, or a turning point, which is
/// read twice because the level moved.
enum Peg { back, fore, turning }

extension PegWords on Peg {
  String get plain => switch (this) {
        Peg.back => 'A backsight: its reading is added',
        Peg.fore => 'A foresight: its reading is taken off',
        Peg.turning => 'Both, at two setups: a turning point',
      };
}

/// One point on the ground, with the elevation nobody is allowed to see
/// until the round is over.
@immutable
class Stake {
  const Stake({required this.name, required this.elevation});

  final String name;

  /// Meters, on whatever datum the run starts from.
  final double elevation;
}

/// A level run: the points in the order they are shot, with the instrument
/// set up between each pair.
@immutable
class Level {
  const Level({required this.marks, this.clearances = const [1.6]});

  final List<Stake> marks;

  /// How far the line of sight clears the higher of the two rods it reads,
  /// at each setup, in meters. The instrument is set up afresh every time it
  /// moves, so this is a list: one height per setup, and the last one is
  /// reused if a run gives fewer than it has setups.
  final List<double> clearances;

  int get setups => marks.length - 1;

  double clearanceAt(int i) =>
      clearances[i < clearances.length ? i : clearances.length - 1];

  /// The height of the line of sight at setup `i`, which is what the book
  /// calls the height of instrument.
  double sightAt(int i) =>
      math.max(marks[i].elevation, marks[i + 1].elevation) + clearanceAt(i);

  /// The rod reading taken from setup `i` onto point `j`, which is the
  /// distance from the ground up to the line of sight.
  double readingAt(int i, int j) => sightAt(i) - marks[j].elevation;

  /// What the book does with point `i`.
  Peg roleOf(int i) {
    if (i == 0) return Peg.back;
    if (i == marks.length - 1) return Peg.fore;
    return Peg.turning;
  }
}

/// A level run drawn in section: the ground, the instrument on its tripod at
/// each setup, a rod standing on each point, and the level line of sight
/// between them. This is the drawing the whole method comes out of, so it is
/// drawn properly: the sight line is dead level, and every reading is the
/// height of that line above the ground at the rod.
class LevelPainter extends CustomPainter {
  const LevelPainter({
    required this.level,
    this.picked,
    this.answer,
    this.locked = false,
    this.showGround = true,
    this.readings = true,
  });

  final Level level;
  final int? picked;
  final int? answer;
  final bool locked;

  /// A round about which point is higher cannot draw the ground until it is
  /// answered: the drawing would be the answer. With this off the rods all
  /// stand on one line and only the readings are honest.
  final bool showGround;

  /// Whether the rod readings are written on.
  final bool readings;

  static double _lowest(Level level) =>
      level.marks.map((m) => m.elevation).reduce(math.min);

  static double _highest(Level level) {
    var top = level.marks.first.elevation;
    for (var i = 0; i < level.setups; i++) {
      top = math.max(top, level.sightAt(i));
    }
    return top;
  }

  static double _scale(Size size, Level level) {
    final span = math.max(0.5, _highest(level) - _lowest(level));
    return (size.height - 66) / span;
  }

  static double yOf(Size size, Level level, double elevation) =>
      size.height - 30 - (elevation - _lowest(level)) * _scale(size, level);

  static double xOf(Size size, Level level, int i) {
    final step = (size.width - 44) / (level.marks.length - 1);
    return 22 + step * i;
  }

  /// Where point `i` is tapped: the foot of its rod.
  static Offset spotOf(Size size, Level level, int i) =>
      Offset(xOf(size, level, i), yOf(size, level, level.marks[i].elevation));

  static int? at(Size size, Level level, Offset tap) {
    for (var i = 0; i < level.marks.length; i++) {
      if ((spotOf(size, level, i) - tap).distance < 28) return i;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final flat = yOf(size, level, _lowest(level));

    // The ground, when the round is allowed to show it.
    if (showGround) {
      final ground = Path()..moveTo(8, yOf(size, level, level.marks[0].elevation));
      for (var i = 0; i < level.marks.length; i++) {
        ground.lineTo(xOf(size, level, i),
            yOf(size, level, level.marks[i].elevation));
      }
      ground
        ..lineTo(size.width - 8, yOf(size, level,
            level.marks[level.marks.length - 1].elevation))
        ..lineTo(size.width - 8, size.height)
        ..lineTo(8, size.height)
        ..close();
      hatchIn(canvas, ground, step: 9);
      canvas.drawPath(
          ground,
          Paint()
            ..color = AppColors.ink2
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4);
    } else {
      groundLine(canvas, Offset(8, flat), Offset(size.width - 8, flat),
          color: AppColors.ink3);
    }

    final ink = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 1.6;

    for (var s = 0; s < level.setups; s++) {
      final sightY = yOf(size, level, level.sightAt(s));
      final x = (xOf(size, level, s) + xOf(size, level, s + 1)) / 2;
      final foot = showGround
          ? yOf(size, level,
              math.min(level.marks[s].elevation, level.marks[s + 1].elevation))
          : flat;

      // The line of sight, dead level, reaching both rods.
      final dash = Paint()
        ..color = AppColors.info
        ..strokeWidth = 1.3;
      for (var d = xOf(size, level, s); d < xOf(size, level, s + 1); d += 8) {
        canvas.drawLine(Offset(d, sightY), Offset(d + 4, sightY), dash);
      }

      // The instrument on its tripod.
      canvas
        ..drawLine(Offset(x, sightY), Offset(x - 9, foot), ink)
        ..drawLine(Offset(x, sightY), Offset(x + 9, foot), ink)
        ..drawLine(Offset(x, sightY), Offset(x, foot), ink)
        ..drawRect(
            Rect.fromCenter(
                center: Offset(x, sightY - 4), width: 16, height: 9),
            Paint()..color = AppColors.charcoal);
      _write(canvas, size, 'setup ${s + 1}', Offset(x - 20, sightY - 20),
          AppColors.ink3);
    }

    // The rods, and the readings on them.
    for (var i = 0; i < level.marks.length; i++) {
      final x = xOf(size, level, i);
      final base = showGround
          ? yOf(size, level, level.marks[i].elevation)
          : flat;
      // Every setup that can see this rod. A turning point is read by two,
      // which is the whole of what makes it a turning point, so the rod has
      // to reach both sight lines and be marked on both.
      final seenBy = <int>[
        if (i > 0) i - 1,
        if (i < level.setups) i,
      ];
      final sightY = seenBy
          .map((s) => yOf(size, level, level.sightAt(s)))
          .reduce(math.min);
      final s = seenBy.first;
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

      final rod = Rect.fromLTRB(x - 3.5, sightY - 26, x + 3.5, base);
      canvas
        ..drawRect(rod, Paint()..color = AppColors.cream)
        ..drawRect(
            rod,
            Paint()
              ..color = tone
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6);
      // Rod graduations, so it reads as a staff rather than a post.
      for (var y = base - 6; y > rod.top; y -= 7) {
        canvas.drawLine(
            Offset(x - 3.5, y),
            Offset(x + 3.5, y),
            Paint()
              ..color = tone.withValues(alpha: 0.45)
              ..strokeWidth = 1);
      }
      // A mark wherever a line of sight crosses the rod, one per setup that
      // reads it.
      for (final seen in seenBy) {
        final y = yOf(size, level, level.sightAt(seen));
        canvas.drawLine(
            Offset(x - 7, y),
            Offset(x + 7, y),
            Paint()
              ..color = AppColors.info
              ..strokeWidth = 2.2);
      }

      if (readings) {
        _write(canvas, size, level.readingAt(s, i).toStringAsFixed(2),
            Offset(x + 9, yOf(size, level, level.sightAt(s)) - 6),
            AppColors.info);
      }
      _write(canvas, size, level.marks[i].name, Offset(x - 12, base + 6), tone);

      // The point itself, marked where the rod stands.
      canvas
        ..drawCircle(Offset(x, base), 4.5, Paint()..color = AppColors.cream)
        ..drawCircle(Offset(x, base), 3, Paint()..color = tone);
    }

    if (!showGround) {
      _write(canvas, size, 'the ground is drawn once you answer',
          const Offset(10, 6), AppColors.ink3);
    }
    viewTag(canvas, size, Looking.section, note: 'sight line level');
  }

  @override
  bool shouldRepaint(LevelPainter old) =>
      old.level != level ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked ||
      old.showGround != showGround ||
      old.readings != readings;
}

/// A closed level loop, which is what the closure check is run on.
@immutable
class Loop {
  const Loop({required this.miles, required this.constant});

  final double miles;

  /// The C in C times the root of the distance, in feet.
  final double constant;

  /// What the run is allowed to be out by, in feet.
  double get allowable => constant * math.sqrt(miles);
}

/// The loop drawn in plan: a circuit of lines leaving a benchmark and coming
/// back to it, with how far it runs written on it.
class LoopPainter extends CustomPainter {
  const LoopPainter({required this.loop, required this.biggest});

  final Loop loop;

  /// The longest loop in the round, so two panels share one scale.
  final double biggest;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.46);
    // Longer runs are drawn bigger, but only by the root, so the drawing
    // does not become the answer by itself.
    final r = (size.height * 0.17) *
        (0.62 + 0.38 * math.sqrt(loop.miles / biggest));
    final path = Path();
    const corners = 5;
    for (var i = 0; i < corners; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / corners;
      final p = c + Offset(math.cos(a) * r * 1.25, math.sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8);

    // The benchmark it leaves from and comes back to.
    final bm = c + Offset(0, -r);
    canvas
      ..drawPath(
          Path()
            ..moveTo(bm.dx, bm.dy - 7)
            ..lineTo(bm.dx - 6, bm.dy + 4)
            ..lineTo(bm.dx + 6, bm.dy + 4)
            ..close(),
          Paint()..color = AppColors.cream)
      ..drawPath(
          Path()
            ..moveTo(bm.dx, bm.dy - 7)
            ..lineTo(bm.dx - 6, bm.dy + 4)
            ..lineTo(bm.dx + 6, bm.dy + 4)
            ..close(),
          Paint()
            ..color = AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6);
    _write(canvas, size, 'BM', bm + const Offset(9, -14), AppColors.charcoal);
    // Both halves of the allowance are on the drawing, or there is nothing
    // to judge it by: how far it runs, and what class of work it is.
    final miles = loop.miles == 1 ? '1 mile round' : '${_num(loop.miles)} miles round';
    _write(canvas, size, miles, Offset(10, size.height - 28), AppColors.ink3);
    _write(canvas, size, 'C = ${loop.constant}', Offset(10, size.height - 16),
        AppColors.ember);
    viewTag(canvas, size, Looking.plan);
  }

  @override
  bool shouldRepaint(LoopPainter old) =>
      old.loop != loop || old.biggest != biggest;
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
