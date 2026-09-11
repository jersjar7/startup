import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

const _g = 9.81;

/// A rectangular channel carrying a given flow per unit of width. Nearly
/// everything in this lesson falls out of that one number.
@immutable
class Flume {
  const Flume({required this.unitFlow, required this.depth});

  /// q, the discharge per unit width, in square meters a second.
  final double unitFlow;

  /// How deep the water is running, in meters.
  final double depth;

  double get speed => unitFlow / depth;

  /// How fast a ripple travels over still water of this depth. The Froude
  /// number is the flow speed measured against it, so the two are the only
  /// quantities that matter to whether a disturbance can work upstream.
  double get waveSpeed => math.sqrt(_g * depth);

  double get froude => speed / waveSpeed;

  /// The depth at which the specific energy is least. It depends on the
  /// flow per unit width and on nothing else: not the slope, not the
  /// lining, not how long the channel is.
  double get criticalDepth => math.pow(unitFlow * unitFlow / _g, 1 / 3) as double;

  /// The energy measured from the channel bed.
  double get energy => depth + unitFlow * unitFlow / (2 * _g * depth * depth);

  double get leastEnergy => 1.5 * criticalDepth;

  double energyAt(double y) => y + unitFlow * unitFlow / (2 * _g * y * y);

  bool get isCritical => (froude - 1).abs() < 0.02;

  bool get isFast => !isCritical && froude > 1;
}

/// The specific energy diagram: energy across the sheet, depth up it. The
/// curve has two arms, one for every energy above the minimum, and the nose
/// of it is the critical depth.
class EnergyCurvePainter extends CustomPainter {
  const EnergyCurvePainter({
    required this.flume,
    this.after,
    this.showPoint = false,
    this.label,
  });

  final Flume flume;

  /// A second curve, drawn once the round is over, for a change that moved
  /// it. Null when nothing moved, which is itself the answer to some
  /// rounds.
  final Flume? after;

  /// The flow's own point on the curve. Held back until the round is over
  /// on the items where it would give the answer away.
  final bool showPoint;
  final String? label;

  double get _topDepth =>
      math.max(flume.criticalDepth, after?.criticalDepth ?? 0) * 3.4;

  double get _rightEnergy =>
      math.max(flume.leastEnergy, after?.leastEnergy ?? 0) * 3.0;

  static const _left = 42.0;
  static const _bottom = 34.0;
  static const _top = 16.0;
  static const _right = 14.0;

  Offset _at(Size size, double energy, double depth) => Offset(
        _left + (size.width - _left - _right) * energy / _rightEnergy,
        size.height - _bottom - (size.height - _bottom - _top) * depth / _topDepth,
      );

  void _curve(Canvas canvas, Size size, Flume f, Paint ink) {
    final path = Path();
    var started = false;
    // Walked in depth rather than in energy, because the curve doubles back
    // on itself in energy and a single pass in depth draws both arms.
    for (var i = 1; i <= 200; i++) {
      final y = _topDepth * i / 200;
      final e = f.energyAt(y);
      if (e > _rightEnergy) {
        started = false;
        continue;
      }
      final p = _at(size, e, y);
      if (!started) {
        path.moveTo(p.dx, p.dy);
        started = true;
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, ink);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1.2;
    canvas
      ..drawLine(Offset(_left, _top), Offset(_left, size.height - _bottom), axis)
      ..drawLine(Offset(_left, size.height - _bottom),
          Offset(size.width - _right, size.height - _bottom), axis);
    writeOn(canvas, size, 'depth y', const Offset(6, 6), AppColors.ink3,
        fontSize: 9);
    writeOn(canvas, size, 'specific energy E',
        Offset(_left + 8, size.height - 14), AppColors.ink3, fontSize: 9);

    // The line E = y, which the deep arm creeps toward and never reaches.
    final far = math.min(_topDepth, _rightEnergy);
    final run = _at(size, 0, 0);
    final to = _at(size, far, far);
    for (var t = 0.0; t < 1; t += 0.06) {
      canvas.drawLine(
          Offset.lerp(run, to, t)!,
          Offset.lerp(run, to, math.min(t + 0.03, 1))!,
          Paint()
            ..color = AppColors.ink3.withValues(alpha: 0.55)
            ..strokeWidth = 1);
    }
    writeOn(canvas, size, 'E = y', _at(size, far, far) + const Offset(-34, -14),
        AppColors.ink3, fontSize: 9);

    // The curve that was there before anything changed.
    _curve(
        canvas,
        size,
        flume,
        Paint()
          ..color = after == null ? AppColors.charcoal : AppColors.ink3
          ..style = PaintingStyle.stroke
          ..strokeWidth = after == null ? 2.6 : 1.8);
    _nose(canvas, size, flume,
        after == null ? AppColors.ember : AppColors.ink3);

    if (after != null) {
      _curve(
          canvas,
          size,
          after!,
          Paint()
            ..color = AppColors.forest
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6);
      _nose(canvas, size, after!, AppColors.forest);
    }

    if (showPoint) {
      final p = _at(size, flume.energy, flume.depth);
      canvas
        ..drawCircle(p, 6, Paint()..color = AppColors.cream)
        ..drawCircle(
            p,
            5,
            Paint()
              ..color = AppColors.info
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.4);
      writeOn(canvas, size, 'the flow', p + const Offset(9, -6),
          AppColors.info, fontSize: 9);
    }

    if (label != null) {
      // Under the axis name, never beside it: the two ran together once.
      writeOn(canvas, size, label!, const Offset(6, 20), AppColors.ink2,
          fontSize: 9);
    }
    // Not a view of anything, so it gets no view tag: a specific energy
    // diagram is a graph, and calling it an elevation would be a lie about
    // what the reader is looking at.
    writeOn(canvas, size, 'SPECIFIC ENERGY DIAGRAM',
        Offset(size.width, size.height - 13), AppColors.ink3, fontSize: 8.5);
  }

  void _nose(Canvas canvas, Size size, Flume f, Color tone) {
    final p = _at(size, f.leastEnergy, f.criticalDepth);
    canvas.drawCircle(p, 3.5, Paint()..color = tone);
    writeOn(canvas, size, 'y crit ${f.criticalDepth.toStringAsFixed(2)}',
        p + const Offset(-64, -7), tone, fontSize: 9);
  }

  @override
  bool shouldRepaint(EnergyCurvePainter old) =>
      old.flume != flume ||
      old.after != after ||
      old.showPoint != showPoint ||
      old.label != label;
}

/// Flow in a channel with a stone dropped in it, looking from the side. The
/// two arrows are the flow speed and the speed of the ring the stone made,
/// drawn to one scale, and everything about subcritical and supercritical
/// is in which of the two is longer.
class RipplePainter extends CustomPainter {
  const RipplePainter({required this.flume, this.answered = false});

  final Flume flume;

  /// Whether the round is over. The ripple is only drawn where it actually
  /// got to once the reader has committed.
  final bool answered;

  static const _bed = 30.0;

  /// One meter of depth, in pixels. Fixed across every round so that a
  /// shallow flow LOOKS shallow beside a deep one: the depth is what sets
  /// the ripple speed, so hiding it would hide the point.
  static const _perMeter = 30.0;

  double get _scale => math.max(flume.speed, flume.waveSpeed) * 1.15;

  @override
  void paint(Canvas canvas, Size size) {
    final bedY = size.height - _bed;
    final surfaceY = bedY - flume.depth * _perMeter;
    const left = 18.0;
    final right = size.width - 18;
    final stoneX = (left + right) / 2;

    // The channel: bed hatched, water filled, surface marked as a surface.
    canvas.drawRect(Rect.fromLTRB(left, surfaceY, right, bedY), waterFill);
    groundLine(canvas, Offset(left, bedY), Offset(right, bedY));
    waterLevel(canvas, Offset(left, surfaceY), Offset(right, surfaceY),
        markAt: left + 30);

    // The two speeds, drawn to one scale in a clear band above the water
    // so that neither arrow has to sit inside the flow it describes.
    final room = (right - left) * 0.36;
    void arrow(double y, double speed, Color tone, String text, bool forward) {
      final length = math.max(room * speed / _scale, 10);
      final from = Offset(stoneX, y);
      final to = Offset(stoneX + (forward ? length : -length), y);
      canvas.drawLine(
          from,
          to,
          Paint()
            ..color = tone
            ..strokeWidth = 2.4);
      final head = forward ? -7.0 : 7.0;
      canvas.drawPath(
          Path()
            ..moveTo(to.dx, to.dy)
            ..lineTo(to.dx + head, to.dy - 4.5)
            ..lineTo(to.dx + head, to.dy + 4.5)
            ..close(),
          Paint()..color = tone);
      writeOn(canvas, size, text,
          Offset(forward ? from.dx + 8 : to.dx + 2, y - 15), tone,
          fontSize: 9.5);
    }

    arrow(54, flume.speed, AppColors.info,
        'the water, ${flume.speed.toStringAsFixed(1)} m/s', true);
    arrow(84, flume.waveSpeed, AppColors.ember,
        'a ripple, ${flume.waveSpeed.toStringAsFixed(1)} m/s', false);

    // Where the stone went in, tying the two arrows to a place in the flow.
    canvas
      ..drawLine(
          Offset(stoneX, 92),
          Offset(stoneX, surfaceY),
          Paint()
            ..color = AppColors.ink3
            ..strokeWidth = 1)
      ..drawCircle(
          Offset(stoneX, surfaceY - 4), 3.5, Paint()..color = AppColors.ink2);
    writeOn(canvas, size, 'a stone goes in', Offset(stoneX - 40, 26),
        AppColors.ink2, fontSize: 9.5);

    if (answered) {
      // Where the upstream edge of the ring actually gets to: the two
      // speeds, one against the other.
      final net = flume.speed - flume.waveSpeed;
      final tone = net.abs() < 0.06
          ? AppColors.sunbeam
          : (net < 0 ? AppColors.forest : AppColors.error);
      final reach = room * net / _scale;
      final y = (surfaceY + bedY) / 2;
      canvas.drawLine(
          Offset(stoneX, y),
          Offset(stoneX + reach, y),
          Paint()
            ..color = tone
            ..strokeWidth = 3.4
            ..strokeCap = StrokeCap.round);
      writeOn(
          canvas,
          size,
          net.abs() < 0.06
              ? 'the ring holds still'
              : (net < 0 ? 'the ring works upstream' : 'swept downstream'),
          Offset(stoneX + (reach < 0 ? reach - 6 : 8), y - 16),
          tone,
          fontSize: 9.5);
    }

    writeOn(canvas, size, 'flow  >', Offset(right - 52, surfaceY - 15),
        AppColors.ink3, fontSize: 9);
    writeOn(
        canvas,
        size,
        'q ${flume.unitFlow.toStringAsFixed(1)} m2/s   depth '
            '${flume.depth.toStringAsFixed(2)} m',
        const Offset(8, 8),
        AppColors.ink3,
        fontSize: 9);
    viewTag(canvas, size, Looking.elevation, note: 'along the channel');
  }

  @override
  bool shouldRepaint(RipplePainter old) =>
      old.flume != flume || old.answered != answered;
}

/// A hydraulic jump: fast shallow water arriving, slow deep water leaving,
/// and a roller between them where the energy goes.
@immutable
class Surge {
  const Surge({required this.beforeDepth, required this.froudeBefore});

  final double beforeDepth;
  final double froudeBefore;

  double get unitFlow =>
      froudeBefore * math.sqrt(_g * beforeDepth) * beforeDepth;

  Flume get before => Flume(unitFlow: unitFlow, depth: beforeDepth);

  /// The conjugate depth. Always deeper than what arrived, which is what
  /// makes a jump a jump.
  double get afterDepth =>
      beforeDepth / 2 * (-1 + math.sqrt(1 + 8 * froudeBefore * froudeBefore));

  Flume get after => Flume(unitFlow: unitFlow, depth: afterDepth);

  /// Energy per unit weight, measured from the bed. The difference is what
  /// the roller throws away as heat and noise.
  double get energyLost => before.energy - after.energy;

  /// The momentum function per unit width, which is what a jump actually
  /// conserves. Energy is not conserved and this is: solving a jump with an
  /// energy balance is the classic way to get it wrong.
  static double momentumOf(Flume f) =>
      f.depth * f.depth / 2 + f.unitFlow * f.unitFlow / (_g * f.depth);
}

/// One of the things a question can ask about across the jump.
enum Carried { discharge, depth, speed, energy, momentum, froude, bed }

extension CarriedWords on Carried {
  String get plain => switch (this) {
        Carried.discharge => 'the discharge',
        Carried.depth => 'the depth of water',
        Carried.speed => 'the velocity',
        Carried.energy => 'the specific energy',
        Carried.momentum => 'the momentum function',
        Carried.froude => 'the Froude number',
        Carried.bed => 'the elevation of the channel bed',
      };

  /// How the quantity is marked on the drawing, on each side.
  String reading(Surge s, bool upstream) {
    final f = upstream ? s.before : s.after;
    return switch (this) {
      Carried.discharge => '${f.unitFlow.toStringAsFixed(2)} m2/s',
      Carried.depth => '${f.depth.toStringAsFixed(2)} m',
      Carried.speed => '${f.speed.toStringAsFixed(2)} m/s',
      Carried.energy => '${f.energy.toStringAsFixed(2)} m',
      Carried.momentum => '${Surge.momentumOf(f).toStringAsFixed(2)} m2',
      Carried.froude => f.froude.toStringAsFixed(2),
      Carried.bed => 'level',
    };
  }

  double valueOn(Surge s, bool upstream) {
    final f = upstream ? s.before : s.after;
    return switch (this) {
      Carried.discharge => f.unitFlow,
      Carried.depth => f.depth,
      Carried.speed => f.speed,
      Carried.energy => f.energy,
      Carried.momentum => Surge.momentumOf(f),
      Carried.froude => f.froude,
      Carried.bed => 0,
    };
  }
}

/// The jump drawn along the channel, with whatever the round is asking
/// about written on both sides of it.
class JumpPainter extends CustomPainter {
  const JumpPainter({
    required this.surge,
    required this.asked,
    this.answered = false,
  });

  final Surge surge;
  final Carried asked;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final bedY = size.height - 34;
    final scale = math.min(
        (size.height - 74) / math.max(surge.afterDepth, 0.05), 70.0);
    final left = 16.0;
    final right = size.width - 16;
    final jumpAt = left + (right - left) * 0.42;
    final jumpEnd = jumpAt + (right - left) * 0.16;
    final up = bedY - surge.beforeDepth * scale;
    final down = bedY - surge.afterDepth * scale;

    // The water, rising through the roller from one depth to the other.
    final water = Path()
      ..moveTo(left, up)
      ..lineTo(jumpAt, up)
      ..cubicTo(jumpAt + (jumpEnd - jumpAt) * 0.4, up,
          jumpAt + (jumpEnd - jumpAt) * 0.6, down, jumpEnd, down)
      ..lineTo(right, down)
      ..lineTo(right, bedY)
      ..lineTo(left, bedY)
      ..close();
    canvas.drawPath(water, waterFill);
    groundLine(canvas, Offset(left, bedY), Offset(right, bedY));

    canvas.drawPath(
        Path()
          ..moveTo(left, up)
          ..lineTo(jumpAt, up)
          ..cubicTo(jumpAt + (jumpEnd - jumpAt) * 0.4, up,
              jumpAt + (jumpEnd - jumpAt) * 0.6, down, jumpEnd, down)
          ..lineTo(right, down),
        Paint()
          ..color = AppColors.info
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8);

    // The roller: the churn that throws the energy away.
    for (var i = 0; i < 5; i++) {
      final t = i / 4;
      final x = jumpAt + (jumpEnd - jumpAt) * t;
      final y = up + (down - up) * t;
      canvas.drawArc(
          Rect.fromCircle(center: Offset(x + 3, y + 5), radius: 5 + i.toDouble()),
          -2.4,
          4.2,
          false,
          Paint()
            ..color = AppColors.info.withValues(alpha: 0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
    }

    // Which way the water is going, which the reader is never asked to
    // guess: a jump only ever runs shallow and fast into deep and slow.
    final arrowY = bedY - 8;
    canvas
      ..drawLine(
          Offset(left + 6, arrowY),
          Offset(left + 46, arrowY),
          Paint()
            ..color = AppColors.ink2
            ..strokeWidth = 1.6)
      ..drawPath(
          Path()
            ..moveTo(left + 52, arrowY)
            ..lineTo(left + 44, arrowY - 4)
            ..lineTo(left + 44, arrowY + 4)
            ..close(),
          Paint()..color = AppColors.ink2);

    writeOn(canvas, size, 'coming in', Offset(left + 2, up - 28),
        AppColors.ink3, fontSize: 9);
    writeOn(canvas, size, 'going out', Offset(right - 60, down - 28),
        AppColors.ink3, fontSize: 9);

    // What the round is asking about, read off each side.
    final tone = answered ? AppColors.forest : AppColors.charcoal;
    writeOn(canvas, size, asked.reading(surge, true),
        Offset(left + 2, up - 16), tone, fontSize: 10);
    writeOn(canvas, size, asked.reading(surge, false),
        Offset(right - 60, down - 16), tone, fontSize: 10);

    writeOn(canvas, size, asked.plain, const Offset(8, 8), AppColors.ember,
        fontSize: 9);
    viewTag(canvas, size, Looking.elevation, note: 'along the channel');
  }

  @override
  bool shouldRepaint(JumpPainter old) =>
      old.surge != surge || old.asked != asked || old.answered != answered;
}
