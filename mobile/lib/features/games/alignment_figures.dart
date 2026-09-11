import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';

/// The pieces of a circular curve that a road alignment is made of.
enum Bit { radius, tangent, arc, chord, external, middle }

extension BitWords on Bit {
  String get plain => switch (this) {
        Bit.radius => 'the radius, R',
        Bit.tangent => 'the tangent distance, T',
        Bit.arc => 'the curve length, L',
        Bit.chord => 'the long chord, LC',
        Bit.external => 'the external distance, E',
        Bit.middle => 'the middle ordinate, M',
      };

  String get short => switch (this) {
        Bit.radius => 'R',
        Bit.tangent => 'T',
        Bit.arc => 'L',
        Bit.chord => 'LC',
        Bit.external => 'E',
        Bit.middle => 'M',
      };
}

/// A circular curve joining two tangents, held the way the lesson holds it:
/// a radius and the angle the road turns through.
@immutable
class Bend2 {
  const Bend2({required this.radius, required this.turn});

  /// Feet.
  final double radius;

  /// The intersection angle, in degrees: how far the road turns.
  final double turn;

  double get _half => turn / 2 * math.pi / 180;

  /// Out along the tangent from the PC to the PI.
  double get tangent => radius * math.tan(_half);

  /// Round the arc from PC to PT.
  double get arc => math.pi * radius * turn / 180;

  double get chord => 2 * radius * math.sin(_half);

  double get external => radius * (1 / math.cos(_half) - 1);

  double get middle => radius * (1 - math.cos(_half));

  /// The degree of curve, the angle a hundred feet of arc subtends.
  double get degree => 5729.58 / radius;

  double lengthOf(Bit piece) => switch (piece) {
        Bit.radius => radius,
        Bit.tangent => tangent,
        Bit.arc => arc,
        Bit.chord => chord,
        Bit.external => external,
        Bit.middle => middle,
      };
}

/// The curve drawn in plan the way every alignment sheet draws it: the two
/// tangents running in to the PI, the arc between PC and PT, the center of
/// the curve below with its two radii, and each element marked where it
/// actually lies.
class AlignPainter extends CustomPainter {
  const AlignPainter({
    required this.bend,
    this.picked,
    this.answer,
    this.locked = false,
    this.label,
    this.other,
    this.names,
    this.pickedCurve,
    this.answerCurve,
  });

  final Bend2 bend;
  final Bit? picked;
  final Bit? answer;
  final bool locked;

  /// A note written along the bottom, where a round wants one.
  final String? label;

  /// A second curve fitted to the SAME two tangents, which is the only way
  /// two curves can be compared for sharpness: a curve drawn on its own is
  /// the same shape whatever its radius, and only the corner it has to fit
  /// tells you how hard it bends. It must turn through the same angle.
  final Bend2? other;

  /// What the two curves are called, when there are two.
  final (String, String)? names;

  /// Which of the two the round has picked out, 0 or 1.
  final int? pickedCurve;
  final int? answerCurve;

  /// Drawn the way an alignment sheet draws it: the curve fills the panel
  /// and the center of the curve is off the sheet, because on any real road
  /// the radius is far longer than the piece of curve being shown. The turn
  /// is marked where it is actually marked, at the PI, between the back
  /// tangent carried on and the tangent ahead.
  static ({Offset pc, Offset pt, Offset pi, Offset crest, double r})
      _frame(Size size, Bend2 bend, {Bend2? other}) {
    final half = bend.turn / 2 * math.pi / 180;
    // In units of the radius: the box the drawing has to fit.
    final wide = 2 * math.sin(half);
    final tall = (1 / math.cos(half) - 1) + (1 - math.cos(half));
    final r = math.min((size.width - 90) / math.max(wide, 0.2),
        (size.height - 96) / math.max(tall, 0.12));
    // The PI stands E above the crest and the chord hangs M below it, so
    // the crest goes E down from the top of the space.
    final crest =
        Offset(size.width / 2, 34 + (1 / math.cos(half) - 1) * r);
    final centre = crest + Offset(0, r);
    final pc = centre + Offset(-math.sin(half) * r, -math.cos(half) * r);
    final pt = centre + Offset(math.sin(half) * r, -math.cos(half) * r);
    final along = Offset(math.cos(half), -math.sin(half));
    final pi = pc + along * (bend.tangent / bend.radius * r);
    return (pc: pc, pt: pt, pi: pi, crest: crest, r: r);
  }

  /// The second curve, drawn to the first one's scale and tucked into the
  /// same corner: its own PC and PT lie on the same two tangents.
  static ({Offset pc, Offset pt, Offset crest, double r}) _inner(
      Size size, Bend2 bend, Bend2 other) {
    final f = _frame(size, bend, other: other);
    final half = bend.turn / 2 * math.pi / 180;
    final share = other.radius / bend.radius;
    final r = f.r * share;
    final back = (f.pi - f.pc) / (f.pi - f.pc).distance;
    final ahead = (f.pt - f.pi) / (f.pt - f.pi).distance;
    final t = other.tangent / other.radius * r;
    final pc = f.pi - back * t;
    final pt = f.pi + ahead * t;
    final centre = pc +
        Offset(math.sin(half), math.cos(half)) * r;
    return (pc: pc, pt: pt, crest: centre + Offset(0, -r), r: r);
  }

  /// Where each piece is tapped: a point on the piece itself.
  static Offset spotOf(Size size, Bend2 bend, Bit piece) {
    final f = _frame(size, bend);
    final half = bend.turn / 2 * math.pi / 180;
    final centre = f.crest + Offset(0, f.r);
    final chordMid = Offset((f.pc.dx + f.pt.dx) / 2, (f.pc.dy + f.pt.dy) / 2);
    return switch (piece) {
      // Along the stub that runs off toward the center.
      Bit.radius => f.pc + (centre - f.pc) / (centre - f.pc).distance * 30,
      Bit.tangent =>
        Offset((f.pc.dx + f.pi.dx) / 2, (f.pc.dy + f.pi.dy) / 2),
      // On the arc, most of the way round toward the PT. Near the PC end
      // a shallow arc runs so close to its own tangent that the two spots
      // land on top of each other.
      Bit.arc => centre +
          Offset(math.sin(half * 0.4) * f.r, -math.cos(half * 0.4) * f.r),
      Bit.chord => chordMid,
      Bit.external => Offset(f.pi.dx, (f.pi.dy + f.crest.dy) / 2),
      // Up near the crest end of the middle ordinate, so it stays clear of
      // the chord marker at the other end of it.
      Bit.middle =>
        Offset(f.crest.dx, chordMid.dy + (f.crest.dy - chordMid.dy) * 0.75),
    };
  }

  static Bit? at(Size size, Bend2 bend, Offset tap) {
    Bit? best;
    var near = 24.0;
    for (final p in Bit.values) {
      final d = (spotOf(size, bend, p) - tap).distance;
      if (d < near) {
        near = d;
        best = p;
      }
    }
    return best;
  }

  Color _tone(Bit piece) {
    if (locked && answer == piece) return AppColors.forest;
    if (locked && picked == piece) return AppColors.error;
    if (picked == piece) return AppColors.ember;
    return AppColors.ink3;
  }

  double _weight(Bit piece) =>
      (picked == piece || (locked && answer == piece)) ? 3.2 : 1.6;

  @override
  void paint(Canvas canvas, Size size) {
    final f = _frame(size, bend);
    final half = bend.turn / 2 * math.pi / 180;
    final centre = f.crest + Offset(0, f.r);
    final chordMid = Offset((f.pc.dx + f.pt.dx) / 2, (f.pc.dy + f.pt.dy) / 2);

    void dashed(Offset a, Offset b, Color color, double w) {
      final run = b - a;
      if (run.distance < 1) return;
      final unit = run / run.distance;
      for (var k = 0.0; k < run.distance; k += 8) {
        canvas.drawLine(a + unit * k, a + unit * math.min(k + 4, run.distance),
            Paint()
              ..color = color
              ..strokeWidth = w);
      }
    }

    // The two tangents, running in from off the sheet through the PI, and
    // the back tangent carried on past it so the turn can be marked.
    final back = (f.pi - f.pc) / (f.pi - f.pc).distance;
    final ahead = (f.pt - f.pi) / (f.pt - f.pi).distance;
    final road = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 1.6;
    canvas
      ..drawLine(f.pc - back * 30, f.pc, road)
      ..drawLine(f.pt + ahead * 30, f.pt, road);
    dashed(f.pi, f.pi + back * 46, AppColors.ink3, 1.1);

    // The turn, marked at the PI between the back tangent carried on and
    // the tangent ahead, which is where a drawing marks it.
    final fromAngle = math.atan2(back.dy, back.dx);
    canvas.drawArc(
      Rect.fromCircle(center: f.pi, radius: 30),
      fromAngle,
      bend.turn * math.pi / 180,
      false,
      Paint()
        ..color = AppColors.ember
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    _write(canvas, size, 'I ${_num(bend.turn)}°',
        f.pi + Offset(14, -6), AppColors.ember);

    // The radius: a stub off each end running toward a center that is not
    // on the sheet, with an arrow to say the line keeps going.
    for (final (at, isLeft) in [(f.pc, true), (f.pt, false)]) {
      final toCentre = (centre - at) / (centre - at).distance;
      final end = at + toCentre * 54;
      dashed(at, end, isLeft ? _tone(Bit.radius) : AppColors.ink3,
          isLeft ? _weight(Bit.radius) : 1.1);
      final side = Offset(-toCentre.dy, toCentre.dx) * 4;
      final tip = Paint()
        ..color = isLeft ? _tone(Bit.radius) : AppColors.ink3
        ..strokeWidth = 1.4;
      canvas
        ..drawLine(end, end - toCentre * 8 + side, tip)
        ..drawLine(end, end - toCentre * 8 - side, tip);
    }
    _write(canvas, size, 'to the center, off the sheet',
        Offset(size.width / 2 - 78, size.height - 30), AppColors.ink3);

    // The pieces, each drawn where it lies.
    canvas
      ..drawLine(f.pc, f.pi, Paint()
        ..color = _tone(Bit.tangent)
        ..strokeWidth = _weight(Bit.tangent))
      ..drawLine(f.pi, f.pt, Paint()
        ..color = AppColors.ink3
        ..strokeWidth = 1.2)
      ..drawLine(f.pc, f.pt, Paint()
        ..color = _tone(Bit.chord)
        ..strokeWidth = _weight(Bit.chord))
      ..drawLine(f.pi, f.crest, Paint()
        ..color = _tone(Bit.external)
        ..strokeWidth = _weight(Bit.external))
      ..drawLine(chordMid, f.crest, Paint()
        ..color = _tone(Bit.middle)
        ..strokeWidth = _weight(Bit.middle))
      ..drawArc(
        Rect.fromCircle(center: centre, radius: f.r),
        -math.pi / 2 - half,
        2 * half,
        false,
        Paint()
          ..color = other == null
              ? _tone(Bit.arc)
              : (locked && answerCurve == 0)
                  ? AppColors.forest
                  : (locked && pickedCurve == 0)
                      ? AppColors.error
                      : pickedCurve == 0
                          ? AppColors.ember
                          : AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(_weight(Bit.arc), 2.4),
      );

    // The three named points.
    for (final (at, name, off) in [
      (f.pc, 'PC', const Offset(-26, 4)),
      (f.pt, 'PT', const Offset(9, 4)),
      (f.pi, 'PI', const Offset(-8, -19)),
    ]) {
      canvas
        ..drawCircle(at, 4.5, Paint()..color = AppColors.cream)
        ..drawCircle(
            at,
            4.5,
            Paint()
              ..color = AppColors.charcoal
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.8);
      _write(canvas, size, name, at + off, AppColors.charcoal);
    }

    // The second curve, fitted into the same corner between the same two
    // tangents, which is what makes one of them visibly the tighter.
    if (other != null) {
      final g = _inner(size, bend, other!);
      final halfOther = other!.turn / 2 * math.pi / 180;
      final centre = g.crest + Offset(0, g.r);
      Color tone(int which) {
        if (locked && answerCurve == which) return AppColors.forest;
        if (locked && pickedCurve == which) return AppColors.error;
        if (pickedCurve == which) return AppColors.ember;
        return AppColors.charcoal;
      }

      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: g.r),
        -math.pi / 2 - halfOther,
        2 * halfOther,
        false,
        Paint()
          ..color = tone(1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = pickedCurve == 1 || (locked && answerCurve == 1)
              ? 3.4
              : 2.4,
      );
      for (final at in [g.pc, g.pt]) {
        canvas
          ..drawCircle(at, 3.6, Paint()..color = AppColors.cream)
          ..drawCircle(
              at,
              3.6,
              Paint()
                ..color = tone(1)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.6);
      }
      if (names != null) {
        // One name on each curve's own shoulder, and on opposite sides, so
        // the two never end up in the gap between the arcs together.
        final outerCentre = f.crest + Offset(0, f.r);
        final outerAt = outerCentre +
            Offset(-math.sin(half * 0.6) * f.r, -math.cos(half * 0.6) * f.r);
        final innerAt = centre +
            Offset(math.sin(halfOther * 0.6) * g.r,
                -math.cos(halfOther * 0.6) * g.r);
        _write(canvas, size, names!.$1, outerAt + const Offset(-18, 2),
            tone(0));
        _write(canvas, size, names!.$2, innerAt + const Offset(8, -4),
            tone(1));
      }
    }

    _write(canvas, size, label ?? 'R ${_num(bend.radius)} ft',
        Offset(10, size.height - 16), AppColors.ink3);
    viewTag(canvas, size, Looking.plan);
  }

  @override
  bool shouldRepaint(AlignPainter old) =>
      old.bend != bend ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked ||
      old.label != label ||
      old.other != other ||
      old.names != names ||
      old.pickedCurve != pickedCurve ||
      old.answerCurve != answerCurve;
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

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
