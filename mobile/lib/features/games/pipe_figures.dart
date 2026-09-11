import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// One length of pipe at one diameter.
@immutable
class Bore {
  const Bore({required this.millimeters, this.share = 1});

  /// The bore in millimeters, and how much of the drawn run it takes up.
  final double millimeters;
  final double share;

  double get area => math.pi * millimeters * millimeters / 4;
}

/// A run of pipe that changes diameter along its length, carrying one flow.
@immutable
class Run {
  const Run({required this.bores, this.litersASecond = 60});

  final List<Bore> bores;

  /// The flow through all of it, which is the same everywhere: that is what
  /// continuity says.
  final double litersASecond;

  /// Speed in a section, in meters a second.
  double speedAt(int i) {
    final q = litersASecond / 1000;
    final a = bores[i].area / 1e6;
    return q / a;
  }

  /// Pressure at a section relative to the widest one, in kilopascals, with
  /// Bernoulli along a level pipe: where it speeds up, it drops.
  double pressureAt(int i, {double density = 1000}) {
    var slowest = 0;
    for (var j = 1; j < bores.length; j++) {
      if (bores[j].millimeters > bores[slowest].millimeters) slowest = j;
    }
    final v0 = speedAt(slowest);
    final v = speedAt(i);
    return density * (v0 * v0 - v * v) / 2 / 1000;
  }

  int get fastest {
    var best = 0;
    for (var i = 1; i < bores.length; i++) {
      if (bores[i].millimeters < bores[best].millimeters) best = i;
    }
    return best;
  }
}

/// The run drawn in section, narrow where it is narrow, with a point marked
/// in each length.
class RunPainter extends CustomPainter {
  const RunPainter({
    required this.run,
    this.picked,
    this.answer,
    this.locked = false,
  });

  final Run run;
  final int? picked;
  final int? answer;
  final bool locked;

  static double _widest(Run run) =>
      run.bores.map((b) => b.millimeters).reduce(math.max);

  /// Where each length of pipe sits across the panel.
  static Rect sectionOf(Size size, Run run, int i) {
    final total = run.bores.fold<double>(0, (a, b) => a + b.share);
    var x = 10.0;
    for (var j = 0; j < i; j++) {
      x += (size.width - 20) * run.bores[j].share / total;
    }
    final wide = (size.width - 20) * run.bores[i].share / total;
    final middle = size.height * 0.45;
    final half = 46 * run.bores[i].millimeters / _widest(run);
    return Rect.fromLTRB(x, middle - half, x + wide, middle + half);
  }

  /// The point marked in each length, which is what a round taps.
  static Offset spotOf(Size size, Run run, int i) =>
      sectionOf(size, run, i).center;

  static int? at(Size size, Run run, Offset tap) {
    for (var i = 0; i < run.bores.length; i++) {
      if (sectionOf(size, run, i).inflate(14).contains(tap)) return i;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // The pipe wall, as one outline down the top and back along the bottom.
    final top = Path();
    final bottom = Path();
    for (var i = 0; i < run.bores.length; i++) {
      final r = sectionOf(size, run, i);
      if (i == 0) {
        top.moveTo(r.left, r.top);
        bottom.moveTo(r.left, r.bottom);
      } else {
        top.lineTo(r.left, r.top);
        bottom.lineTo(r.left, r.bottom);
      }
      top.lineTo(r.right, r.top);
      bottom.lineTo(r.right, r.bottom);
    }
    // The water inside: down the top wall and back along the bottom one.
    final water = Path.from(top);
    for (var i = run.bores.length - 1; i >= 0; i--) {
      final r = sectionOf(size, run, i);
      water
        ..lineTo(r.right, r.bottom)
        ..lineTo(r.left, r.bottom);
    }
    water.close();

    canvas.drawPath(
        water, Paint()..color = AppColors.info.withValues(alpha: 0.22));
    final wall = Paint()
      ..color = AppColors.charcoal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas
      ..drawPath(top, wall)
      ..drawPath(bottom, wall);

    // Which way it is going.
    final flow = Paint()
      ..color = AppColors.info
      ..strokeWidth = 1.6;
    final middle = size.height * 0.45;
    canvas
      ..drawLine(Offset(14, middle), Offset(size.width - 18, middle), flow)
      ..drawLine(Offset(size.width - 18, middle),
          Offset(size.width - 26, middle - 4), flow)
      ..drawLine(Offset(size.width - 18, middle),
          Offset(size.width - 26, middle + 4), flow);

    for (var i = 0; i < run.bores.length; i++) {
      final r = sectionOf(size, run, i);
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
      final spot = spotOf(size, run, i);
      canvas
        ..drawCircle(spot, 8, Paint()..color = AppColors.cream)
        ..drawCircle(spot, 6, Paint()..color = tone);
      _write(canvas, size, '${i + 1}', spot + const Offset(-3, -19), tone);
      // All the bore labels on one line, below the widest section, so a
      // narrow throat's label does not land on the wall beside it.
      final belowAll = size.height * 0.45 + 46 + 12;
      _write(canvas, size, '${_num(run.bores[i].millimeters)} mm',
          Offset(r.center.dx - 24, belowAll), AppColors.ink3);
    }

    _write(canvas, size, '${_num(run.litersASecond)} liters a second, all of it',
        Offset(10, size.height - 16), AppColors.ink3);
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toString();

  void _write(Canvas canvas, Size size, String text, Offset at, Color color) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx;
    if (x + painter.width > size.width - 2) x = size.width - 2 - painter.width;
    if (x < 2) x = 2;
    final patch = Rect.fromLTWH(
        x - 2, at.dy - 1, painter.width + 4, painter.height + 2);
    canvas.drawRect(
        patch, Paint()..color = AppColors.cream.withValues(alpha: 0.9));
    painter.paint(canvas, Offset(x, at.dy));
  }

  @override
  bool shouldRepaint(RunPainter old) =>
      old.run != run ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked;
}

/// A tank with a hole in it, which is Torricelli's problem.
@immutable
class Squirt {
  const Squirt({
    required this.head,
    this.holeMillimeters = 25,
    this.tankWide = 3,
    this.liquid = 'water',
  });

  /// Meters from the free surface down to the hole.
  final double head;

  /// The size of the hole and how wide the tank is, neither of which the jet
  /// speed cares about.
  final double holeMillimeters;
  final double tankWide;
  final String liquid;

  /// Torricelli: the speed a jet leaves at, in meters a second.
  double get speed => math.sqrt(2 * 9.81 * head);
}

/// The tank in section with the hole marked, and the jet drawn only when the
/// round is over.
class SquirtPainter extends CustomPainter {
  const SquirtPainter({
    required this.squirt,
    required this.tallest,
    this.showJet = false,
    this.tone = AppColors.charcoal,
  });

  final Squirt squirt;

  /// The biggest head in the round, so two tanks share one scale.
  final double tallest;

  final bool showJet;
  final Color tone;

  static Rect tankOf(Size size, Squirt squirt, double tallest) {
    final floor = size.height - 26;
    // A shallow pan beside a tall tube would be a few pixels high and its
    // two labels would land on each other, so every tank gets a floor. The
    // head is written on it in words either way.
    final tall = math.max(
        46.0, (size.height - 60) * squirt.head / tallest);
    final top = floor - tall;
    final half = math.max(26.0, math.min(54.0, 16 * squirt.tankWide));
    return Rect.fromLTRB(
        size.width / 2 - half, top, size.width / 2 + half, floor);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final tank = tankOf(size, squirt, tallest);
    canvas
      ..drawRect(tank, Paint()..color = AppColors.info.withValues(alpha: 0.25))
      ..drawLine(tank.topLeft, tank.bottomLeft,
          Paint()..color = tone..strokeWidth = 1.8)
      ..drawLine(tank.bottomLeft, tank.bottomRight,
          Paint()..color = tone..strokeWidth = 1.8)
      ..drawLine(tank.topRight, tank.bottomRight,
          Paint()..color = tone..strokeWidth = 1.8)
      ..drawLine(tank.topLeft, tank.topRight,
          Paint()..color = AppColors.info..strokeWidth = 1.4);

    // The hole, drawn bigger than it is so it can be seen at all.
    final hole = math.max(6.0, math.min(20.0, squirt.holeMillimeters / 3));
    final at = Offset(tank.right, tank.bottom - 10 - hole / 2);
    canvas.drawRect(
      Rect.fromCenter(center: at, width: 6, height: hole),
      Paint()..color = AppColors.cream,
    );

    if (showJet) {
      final paint = Paint()
        ..color = AppColors.ember
        ..strokeWidth = 2.4;
      final len = 20 + 34 * squirt.speed / math.sqrt(2 * 9.81 * tallest);
      final tip = at + Offset(len, 10);
      canvas
        ..drawLine(at, tip, paint)
        ..drawLine(tip, tip + const Offset(-7, -2), paint)
        ..drawLine(tip, tip + const Offset(-4, -6), paint);
      _write(canvas, size, '${squirt.speed.toStringAsFixed(1)} m/s',
          at + const Offset(6, -16), AppColors.ember);
    }

    _write(canvas, size, '${_num(squirt.head)} m head',
        Offset(tank.left + 4, tank.top + 6), AppColors.ink3);
    _write(canvas, size, '${_num(squirt.holeMillimeters)} mm hole',
        Offset(tank.left - 4, tank.bottom + 6), AppColors.ink3);
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toString();

  void _write(Canvas canvas, Size size, String text, Offset at, Color color) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx;
    if (x + painter.width > size.width - 2) x = size.width - 2 - painter.width;
    if (x < 2) x = 2;
    final patch = Rect.fromLTWH(
        x - 2, at.dy - 1, painter.width + 4, painter.height + 2);
    canvas.drawRect(
        patch, Paint()..color = AppColors.cream.withValues(alpha: 0.9));
    painter.paint(canvas, Offset(x, at.dy));
  }

  @override
  bool shouldRepaint(SquirtPainter old) =>
      old.squirt != squirt ||
      old.tallest != tallest ||
      old.showJet != showJet ||
      old.tone != tone;
}
