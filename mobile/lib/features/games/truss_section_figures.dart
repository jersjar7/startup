import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';
import 'truss_figures.dart';

/// A candidate point to take moments about, drawn on the truss and named.
@immutable
class Anchor {
  const Anchor(this.name, this.at);

  final String name;

  /// In the truss's own world units.
  final Offset at;
}

/// The truss with a section cut across it, the member being chased lit up,
/// and the candidate moment centers marked. Everything the method of
/// sections asks after the cut is on this one drawing.
class SectionPointsPainter extends CustomPainter {
  const SectionPointsPainter({
    required this.truss,
    this.cut,
    required this.target,
    this.anchors = const [],
    this.picked,
    this.answer,
    this.locked = false,
  });

  final Truss truss;

  /// Where the section is taken, when the round has taken one.
  final Cut? cut;

  /// The member whose force is wanted.
  final int target;

  final List<Anchor> anchors;
  final int? picked;
  final int? answer;
  final bool locked;

  Offset _at(Size size, Offset world) => TrussPainter.toScreen(
      truss, world, size,
      cuts: cut == null ? const [] : [cut!]);

  @override
  void paint(Canvas canvas, Size size) {
    // The members.
    for (var m = 0; m < truss.members.length; m++) {
      final (a, b) = truss.members[m];
      final lit = m == target;
      canvas.drawLine(
          _at(size, truss.joints[a].at),
          _at(size, truss.joints[b].at),
          Paint()
            ..color = lit ? AppColors.ember : AppColors.charcoal
            ..strokeWidth = lit ? 4.4 : 2.2);
    }

    // The joints.
    for (final j in truss.joints) {
      final p = _at(size, j.at);
      canvas
        ..drawCircle(p, 3.6, Paint()..color = AppColors.cream)
        ..drawCircle(
            p,
            3.6,
            Paint()
              ..color = AppColors.charcoal
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4);
    }

    // What holds the truss up. It is not needed to pick a moment center,
    // but a truss floating free reads as a mistake.
    for (final e in truss.supports.entries) {
      TrussPainter.supportMark(canvas, _at(size, truss.joints[e.key].at),
          e.value);
    }

    // The cut, dashed, so it reads as a construction and not a member.
    if (cut != null) {
    final from = _at(size, cut!.from);
    final to = _at(size, cut!.to);
    final run = to - from;
    final unit = run / run.distance;
    for (var d = 0.0; d < run.distance; d += 9) {
      canvas.drawLine(from + unit * d, from + unit * math.min(d + 5,
          run.distance),
          Paint()
            ..color = AppColors.info
            ..strokeWidth = 2);
    }
    writeOn(canvas, size, 'the cut', to + const Offset(-18, -14),
        AppColors.info, fontSize: 9.5);
    }

    // The candidate moment centers.
    for (var i = 0; i < anchors.length; i++) {
      final p = _at(size, anchors[i].at);
      final Color tone;
      if (locked && answer == i) {
        tone = AppColors.forest;
      } else if (locked && picked == i) {
        tone = AppColors.error;
      } else {
        tone = AppColors.ink2;
      }
      canvas
        ..drawCircle(p, 9, Paint()..color = AppColors.cream)
        ..drawCircle(
            p,
            9,
            Paint()
              ..color = tone
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2);
      writeOn(canvas, size, anchors[i].name, p + const Offset(-3, -6), tone,
          fontSize: 9.5);
    }

    writeOn(canvas, size, 'the member wanted is in orange',
        const Offset(8, 8), AppColors.ember, fontSize: 9.5);
    viewTag(canvas, size, Looking.elevation, note: 'the truss');
  }

  @override
  bool shouldRepaint(SectionPointsPainter old) =>
      old.truss != truss ||
      old.cut != cut ||
      old.target != target ||
      old.anchors != anchors ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked;
}

/// One joint pulled out of a truss, with what is hanging on it and the
/// members that have to carry it away.
@immutable
class Corner {
  const Corner({
    required this.load,
    required this.degrees,
    this.horizontal = true,
  });

  /// The load hanging on the joint, downward, in whatever unit the round
  /// is using.
  final double load;

  /// How far above the horizontal the diagonal leaves the joint.
  final double degrees;

  /// Whether there is also a horizontal member at the joint.
  final bool horizontal;

  double get radians => degrees * math.pi / 180;

  /// The diagonal is the only member with a vertical component, so it has
  /// to carry the whole load, and it is longer than the load because only
  /// part of it points up.
  double get diagonal => load / math.sin(radians);

  /// What the horizontal member takes, which is the diagonal's other
  /// component.
  double get flat => diagonal * math.cos(radians);

  double get ratio => diagonal / load;
}

/// The joint drawn as a free body: the load down, the diagonal at its angle,
/// the flat member, and, once the round is over, the triangle that shows why
/// the diagonal has to be the biggest of the three.
class CornerPainter extends CustomPainter {
  const CornerPainter({required this.corner, this.answered = false});

  final Corner corner;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final at = Offset(size.width * 0.42, size.height * 0.62);
    final reach = math.min(size.width * 0.34, size.height * 0.42);

    // The two members leaving the joint.
    final along = Offset(math.cos(corner.radians), -math.sin(corner.radians));
    canvas.drawLine(
        at,
        at + along * reach,
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 3.4);
    writeOn(canvas, size, 'the diagonal', at + along * reach + const Offset(4, -12),
        AppColors.charcoal, fontSize: 9.5);
    if (corner.horizontal) {
      canvas.drawLine(
          at,
          at + Offset(-reach, 0),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 3.4);
      writeOn(canvas, size, 'the flat member',
          at + Offset(-reach, 6), AppColors.charcoal, fontSize: 9.5);
    }

    // The load.
    canvas
      ..drawLine(
          at,
          at + const Offset(0, 52),
          Paint()
            ..color = AppColors.info
            ..strokeWidth = 3)
      ..drawPath(
          Path()
            ..moveTo(at.dx, at.dy + 58)
            ..lineTo(at.dx - 5, at.dy + 48)
            ..lineTo(at.dx + 5, at.dy + 48)
            ..close(),
          Paint()..color = AppColors.info);
    writeOn(canvas, size, '${_num(corner.load)} down',
        at + const Offset(8, 34), AppColors.info, fontSize: 9.5);

    // The joint itself.
    canvas
      ..drawCircle(at, 5, Paint()..color = AppColors.cream)
      ..drawCircle(
          at,
          5,
          Paint()
            ..color = AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);

    writeOn(canvas, size, '${_num(corner.degrees)} degrees',
        at + const Offset(16, -18), AppColors.ink3, fontSize: 9.5);

    if (answered) {
      // The force triangle: the load up, the diagonal's line, and the
      // closing horizontal. The diagonal is the hypotenuse, so it is the
      // longest side, always.
      final base = Offset(size.width * 0.74, size.height * 0.78);
      const up = 46.0;
      final across = up / math.tan(corner.radians);
      final ink = Paint()
        ..color = AppColors.forest
        ..strokeWidth = 2.4;
      canvas
        ..drawLine(base, base + const Offset(0, -up), ink)
        ..drawLine(base + const Offset(0, -up),
            base + Offset(-across, -up), ink)
        ..drawLine(base + Offset(-across, -up), base, ink);
      writeOn(canvas, size, 'load', base + const Offset(4, -up / 2),
          AppColors.forest, fontSize: 9);
      writeOn(
          canvas,
          size,
          'diagonal, ${corner.ratio.toStringAsFixed(2)} times the load',
          base + Offset(-across - 30, -up - 16),
          AppColors.forest,
          fontSize: 9);
    }
    viewTag(canvas, size, Looking.elevation, note: 'one joint, free');
  }

  @override
  bool shouldRepaint(CornerPainter old) =>
      old.corner != corner || old.answered != answered;
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();
