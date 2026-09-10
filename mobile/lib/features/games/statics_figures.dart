import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Where the angle on a force triangle is measured from.
///
/// Which axis it opens off decides which component gets the cosine, and that
/// is the whole of the lesson's first trap. An angle from the vertical is not
/// exotic: the exam uses it whenever a cable hangs off something.
enum AngleFrom { horizontal, vertical, none }

/// A force drawn as the hypotenuse of its own right triangle, with both
/// components drawn beside it to the same scale.
///
/// Resolving a force is taught as a choice between sine and cosine and lost as
/// a choice between two arrows. Drawn to scale, the swap stops being a
/// notation slip and becomes a picture that is visibly wrong: the arrow you
/// have called the horizontal one is plainly the shorter of the two.
class ForceTrianglePainter extends CustomPainter {
  const ForceTrianglePainter({
    required this.dx,
    required this.dy,
    required this.angleFrom,
    required this.angleLabel,
    required this.xLabel,
    required this.yLabel,
    required this.selected,
    required this.locked,
    required this.truth,
  });

  /// The legs, in whatever units the round is drawing in. Only the ratio
  /// matters; the painter scales them to the box.
  final double dx;
  final double dy;

  final AngleFrom angleFrom;
  final String angleLabel;

  /// What to write along each leg, where the round gives lengths. Empty means
  /// the leg is drawn without a number, which is what an angle round wants.
  final String xLabel;
  final String yLabel;

  /// 0 is the horizontal component, 1 the vertical, 2 the force itself.
  final int? selected;
  final bool locked;
  final int truth;

  static const _padL = 34.0;
  static const _padB = 30.0;
  static const _padT = 20.0;
  static const _padR = 46.0;

  /// The strip down the left belongs to the vertical arrow and the strip
  /// along the bottom to the horizontal one, so that the three tap zones
  /// never overlap at the corner they share.
  static const gutter = 16.0;

  Color _colorOf(int which) {
    if (locked && which == truth) return AppColors.forest;
    if (locked && which == selected) return AppColors.error;
    if (which == selected) return AppColors.ember;
    return AppColors.charcoal;
  }

  bool _heavy(int which) => which == selected || (locked && which == truth);

  @override
  void paint(Canvas canvas, Size size) {
    final room = Size(
      size.width - _padL - _padR,
      size.height - _padT - _padB,
    );
    // One scale for both legs, or the picture lies about which is longer.
    final scale = math.min(room.width / dx, room.height / dy);
    final sx = dx * scale;
    final sy = dy * scale;

    final o = Offset(_padL, size.height - _padB);
    final tip = Offset(o.dx + sx, o.dy - sy);
    final alongX = Offset(o.dx + sx, o.dy);
    final alongY = Offset(o.dx, o.dy - sy);

    // The rectangle, so that both components read as parts of one force.
    _dashed(canvas, alongX, tip);
    _dashed(canvas, alongY, tip);

    _arrow(canvas, o, alongX, _colorOf(0), _heavy(0));
    _arrow(canvas, o, alongY, _colorOf(1), _heavy(1));
    _arrow(canvas, o, tip, _colorOf(2), _heavy(2));

    if (angleFrom != AngleFrom.none) {
      final from = angleFrom == AngleFrom.horizontal ? 0.0 : -math.pi / 2;
      final to = math.atan2(-sy, sx);
      canvas.drawArc(
        Rect.fromCircle(center: o, radius: 26),
        from,
        to - from,
        false,
        Paint()
          ..color = AppColors.ink2
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      // Down the middle of the wedge. On a narrow angle the label is wider
      // than the wedge whatever radius it sits at, so it gets a patch of
      // canvas behind it rather than being drawn over an arrow.
      final mid = (from + to) / 2;
      _write(
        canvas,
        angleLabel,
        o + Offset(math.cos(mid) * 46, math.sin(mid) * 46 - 7),
        AppColors.ink2,
        size,
        patch: true,
      );
    }

    if (xLabel.isNotEmpty) {
      _write(canvas, xLabel, Offset(o.dx + sx / 2, o.dy + 8),
          _colorOf(0), size, align: 1);
    }
    if (yLabel.isNotEmpty) {
      _write(canvas, yLabel, Offset(o.dx - 8, o.dy - sy / 2 - 6),
          _colorOf(1), size, align: -1);
    }
  }

  void _arrow(Canvas canvas, Offset from, Offset to, Color colour, bool heavy) {
    final paint = Paint()
      ..color = colour
      ..strokeWidth = heavy ? 3 : 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);

    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    const head = 9.0;
    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(to.dx - head * math.cos(angle - 0.4),
          to.dy - head * math.sin(angle - 0.4))
      ..lineTo(to.dx - head * math.cos(angle + 0.4),
          to.dy - head * math.sin(angle + 0.4))
      ..close();
    canvas.drawPath(path, Paint()..color = colour);
  }

  void _dashed(Canvas canvas, Offset from, Offset to) {
    final total = (to - from).distance;
    if (total < 1) return;
    final step = (to - from) / total;
    final paint = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1;
    for (var d = 0.0; d < total; d += 7) {
      final end = math.min(d + 4, total);
      canvas.drawLine(from + step * d, from + step * end, paint);
    }
  }

  void _write(Canvas canvas, String text, Offset at, Color colour, Size size,
      {int align = 0, bool patch = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 11, color: colour)),
      textDirection: TextDirection.ltr,
    )..layout();
    final dxOff = switch (align) {
      1 => tp.width / 2,
      -1 => tp.width,
      _ => tp.width / 2,
    };
    var x = at.dx - dxOff;
    if (x < 2) x = 2;
    if (x + tp.width > size.width - 2) x = size.width - 2 - tp.width;
    if (patch) {
      canvas.drawRect(
        Rect.fromLTWH(x - 2, at.dy, tp.width + 4, tp.height),
        Paint()..color = AppColors.cream.withValues(alpha: 0.92),
      );
    }
    tp.paint(canvas, Offset(x, at.dy));
  }

  @override
  bool shouldRepaint(ForceTrianglePainter old) =>
      old.dx != dx ||
      old.dy != dy ||
      old.selected != selected ||
      old.locked != locked ||
      old.angleFrom != angleFrom;
}

/// One dimension line on a moment figure: a distance somebody might reach for
/// when they are looking for the moment arm.
@immutable
class Mark {
  const Mark(this.from, this.to, this.label, {this.offset = 0});

  /// Both ends, in world units.
  final Offset from;
  final Offset to;
  final String label;

  /// How far to push the line off its own axis, in pixels, so that three
  /// distances measured from the same corner do not land on top of each other.
  final double offset;
}

/// One force on a body: where it acts and which way it pulls.
@immutable
class StaticForce {
  const StaticForce(this.at, this.dir, this.label, {this.lineOfAction = true});

  /// Where it is applied, in world units.
  final Offset at;

  /// Which way it points. Length is ignored; every force is drawn the same
  /// size, because this lesson is about geometry and not about magnitude.
  final Offset dir;

  final String label;

  /// Whether to run its line of action across the figure. That dashed line is
  /// the whole reason a moment arm is findable, so it is usually on.
  final bool lineOfAction;
}

/// Everything on a moment figure, in world units with y pointing up, plus the
/// arithmetic to put it on a canvas.
///
/// The widget needs the same transform as the painter, because the tap targets
/// sit over the arrows. Working it out in two places is how a figure ends up
/// with a target that is forty pixels off the thing it is supposed to be on.
@immutable
class Scene {
  const Scene({
    required this.members,
    required this.pivot,
    required this.forces,
    this.marks = const [],
  });

  /// The body, as one or more polylines.
  final List<List<Offset>> members;

  /// The point moments are taken about.
  final Offset pivot;

  final List<StaticForce> forces;
  final List<Mark> marks;

  /// Room round the outside. The arrows and their labels are drawn in pixels
  /// rather than world units, so the fit cannot know about them: without a pad
  /// this big, a force pointing away from the body took its label off the top
  /// of the figure.
  static const _pad = 68.0;

  Rect get bounds {
    var minX = pivot.dx, maxX = pivot.dx, minY = pivot.dy, maxY = pivot.dy;
    void see(Offset p) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    for (final m in members) {
      m.forEach(see);
    }
    for (final f in forces) {
      see(f.at);
    }
    for (final m in marks) {
      see(m.from);
      see(m.to);
    }
    // Never let a flat figure divide by zero.
    if (maxX - minX < 0.001) maxX = minX + 1;
    if (maxY - minY < 0.001) maxY = minY + 1;
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  double scaleFor(Size size) {
    final b = bounds;
    return math.min(
      (size.width - _pad * 2) / b.width,
      (size.height - _pad * 2) / b.height,
    );
  }

  /// World to canvas, with y flipped and the whole thing centred.
  Offset toScreen(Offset world, Size size) {
    final b = bounds;
    final s = scaleFor(size);
    final left = (size.width - b.width * s) / 2;
    final top = (size.height - b.height * s) / 2;
    return Offset(
      left + (world.dx - b.left) * s,
      top + (b.bottom - world.dy) * s,
    );
  }
}

/// What the painter is colouring: the candidate distances, or the forces.
enum SceneMode { marks, forces }

/// A body, a pivot, some forces and the distances anybody might mistake for
/// the moment arm.
///
/// The arm is the PERPENDICULAR distance from the point to the line of action,
/// and it is invisible until somebody draws it. Every wrong answer in the
/// lesson's crane problem is a different real distance on the same picture, so
/// the picture carries all of them and the question is which one counts.
class MomentPainter extends CustomPainter {
  const MomentPainter({
    required this.scene,
    required this.mode,
    required this.selected,
    required this.chosen,
    required this.locked,
    required this.truth,
    required this.truths,
  });

  final Scene scene;
  final SceneMode mode;

  /// The mark under the thumb, in [SceneMode.marks].
  final int? selected;

  /// The forces ticked, in [SceneMode.forces].
  final Set<int> chosen;

  final bool locked;

  /// The mark that is the moment arm.
  final int truth;

  /// The forces that answer the round.
  final Set<int> truths;

  Color _colour({required bool picked, required bool isTruth}) {
    if (locked && isTruth) return AppColors.forest;
    if (locked && picked) return AppColors.error;
    if (picked) return AppColors.ember;
    return AppColors.charcoal;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Offset at(Offset w) => scene.toScreen(w, size);

    for (final member in scene.members) {
      final path = Path()..moveTo(at(member.first).dx, at(member.first).dy);
      for (final p in member.skip(1)) {
        path.lineTo(at(p).dx, at(p).dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.ink2
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke,
      );
    }

    // The pivot, drawn as the little triangle every textbook uses.
    final p = at(scene.pivot);
    final tri = Path()
      ..moveTo(p.dx, p.dy)
      ..lineTo(p.dx - 8, p.dy + 13)
      ..lineTo(p.dx + 8, p.dy + 13)
      ..close();
    canvas.drawPath(tri, Paint()..color = AppColors.charcoal);
    canvas.drawCircle(p, 3.5, Paint()..color = AppColors.cream);

    for (final (i, f) in scene.forces.indexed) {
      final picked = mode == SceneMode.forces && chosen.contains(i);
      final isTruth = mode == SceneMode.forces && truths.contains(i);
      final colour = mode == SceneMode.forces
          ? _colour(picked: picked, isTruth: isTruth)
          : AppColors.ember;
      final origin = at(f.at);
      final len = f.dir.distance;
      final unit = Offset(f.dir.dx / len, -f.dir.dy / len);

      if (f.lineOfAction) {
        _dash(canvas, origin - unit * 400, origin + unit * 400,
            AppColors.ink3.withValues(alpha: 0.7));
      }
      _arrow(canvas, origin, origin + unit * 52, colour,
          heavy: picked || (locked && isTruth));
      _text(canvas, f.label, origin + unit * 64, colour, size);
    }

    for (final (i, m) in scene.marks.indexed) {
      final picked = mode == SceneMode.marks && selected == i;
      final isTruth = mode == SceneMode.marks && i == truth;
      final colour = _colour(picked: picked, isTruth: isTruth);
      final heavy = picked || (locked && isTruth);
      final a = at(m.from);
      final b = at(m.to);
      final along = b - a;
      final len = along.distance;
      if (len < 0.5) continue;
      final unit = along / len;
      final normal = Offset(-unit.dy, unit.dx) * m.offset;
      final from = a + normal;
      final to = b + normal;

      final paint = Paint()
        ..color = colour
        ..strokeWidth = heavy ? 2.4 : 1.3;
      canvas.drawLine(from, to, paint);
      // End ticks, square to the line.
      final tick = Offset(-unit.dy, unit.dx) * 5;
      canvas.drawLine(from - tick, from + tick, paint);
      canvas.drawLine(to - tick, to + tick, paint);
      // A thin leader back to whatever the distance was measured from.
      if (m.offset.abs() > 0.5) {
        final faint = Paint()
          ..color = colour.withValues(alpha: 0.4)
          ..strokeWidth = 1;
        canvas.drawLine(a, from, faint);
        canvas.drawLine(b, to, faint);
      }
      _text(canvas, m.label, (from + to) / 2 + normal * 0.24, colour, size);
    }
  }

  void _arrow(Canvas canvas, Offset from, Offset to, Color colour,
      {required bool heavy}) {
    final paint = Paint()
      ..color = colour
      ..strokeWidth = heavy ? 3.4 : 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    const head = 10.0;
    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(to.dx - head * math.cos(angle - 0.4),
          to.dy - head * math.sin(angle - 0.4))
      ..lineTo(to.dx - head * math.cos(angle + 0.4),
          to.dy - head * math.sin(angle + 0.4))
      ..close();
    canvas.drawPath(path, Paint()..color = colour);
  }

  void _dash(Canvas canvas, Offset from, Offset to, Color colour) {
    final total = (to - from).distance;
    if (total < 1) return;
    final step = (to - from) / total;
    final paint = Paint()
      ..color = colour
      ..strokeWidth = 1;
    for (var d = 0.0; d < total; d += 8) {
      canvas.drawLine(
          from + step * d, from + step * math.min(d + 4, total), paint);
    }
  }

  void _text(Canvas canvas, String text, Offset centre, Color colour, Size size) {
    if (text.isEmpty) return;
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 11, color: colour)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = centre.dx - tp.width / 2;
    var y = centre.dy - 7;
    if (x < 2) x = 2;
    if (x + tp.width > size.width - 2) x = size.width - 2 - tp.width;
    if (y < 1) y = 1;
    if (y + tp.height > size.height - 1) y = size.height - 1 - tp.height;
    // A patch of canvas behind it, so a label crossing a dashed line stays
    // readable.
    canvas.drawRect(
      Rect.fromLTWH(x - 2, y, tp.width + 4, tp.height),
      Paint()..color = AppColors.cream.withValues(alpha: 0.9),
    );
    tp.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(MomentPainter old) =>
      old.scene != scene ||
      old.selected != selected ||
      old.chosen != chosen ||
      old.locked != locked;
}
