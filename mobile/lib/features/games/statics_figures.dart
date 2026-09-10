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

    // Centred in what is left over. Anchored at the corner, a tall narrow
    // triangle sat in the left third of the box with nothing beside it.
    final o = Offset(
      _padL + (room.width - sx) / 2,
      _padT + (room.height + sy) / 2,
    );
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
      // Big enough to read as an angle rather than as a tick, and never more
      // than half the shorter leg or it runs past the corner it marks.
      final radius = math.min(math.min(sx, sy) * 0.45, 46.0).clamp(20.0, 46.0);
      canvas.drawArc(
        Rect.fromCircle(center: o, radius: radius),
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
      // Down the middle of the wedge, and then clear of the axis the angle
      // was measured from: an angle off the vertical opens into a narrow
      // wedge beside the vertical arrow, and the label is wider than it.
      final mid = (from + to) / 2;
      final nudge = angleFrom == AngleFrom.vertical
          ? _measure(angleLabel).width / 2 + 8
          : 0.0;
      _write(
        canvas,
        angleLabel,
        o +
            Offset(math.cos(mid) * (radius + 20) + nudge,
                math.sin(mid) * (radius + 20) - 7),
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

  TextPainter _measure(String text, {Color colour = AppColors.ink2}) =>
      TextPainter(
        text:
            TextSpan(text: text, style: AppTheme.mono(size: 11, color: colour)),
        textDirection: TextDirection.ltr,
      )..layout();

  void _write(Canvas canvas, String text, Offset at, Color colour, Size size,
      {int align = 0, bool patch = false}) {
    final tp = _measure(text, colour: colour);
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

/// Where a dimension line sits relative to the thing it measures.
enum MarkPlace {
  /// Pushed clear of the figure the way a drafter would: horizontal distances
  /// below everything, vertical ones out to the left, slanted ones offset
  /// square to their own axis on the side away from the body.
  auto,

  /// Drawn exactly where it falls, because its position is the point. A
  /// perpendicular dropped from a pivot to a line of action means nothing if
  /// it is moved off the pivot to keep the picture tidy.
  inPlace,
}

/// One dimension line on a moment figure: a distance somebody might reach for
/// when they are looking for the moment arm.
@immutable
class Mark {
  const Mark(this.from, this.to, this.label, {this.place = MarkPlace.auto});

  /// Both ends, in world units.
  final Offset from;
  final Offset to;
  final String label;

  final MarkPlace place;
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

  /// Where the body actually sits on the canvas, pivot furniture included.
  Rect bodyOn(Size size) {
    var box = Rect.fromCircle(center: toScreen(pivot, size), radius: 1);
    void swallow(Offset o) {
      box = box.expandToInclude(Rect.fromCircle(center: o, radius: 1));
    }

    for (final member in members) {
      for (final p in member) {
        swallow(toScreen(p, size));
      }
    }
    for (final f in forces) {
      swallow(toScreen(f.at, size));
    }
    return Rect.fromLTRB(
      box.left - 9,
      box.top - 3,
      box.right + 9,
      box.bottom + 14,
    );
  }

  /// Every dimension line where it actually gets drawn.
  ///
  /// A drafter puts horizontal distances below the object, vertical ones out
  /// to the side, and stacks parallel ones outward. Doing that here rather
  /// than in the painter means the tap targets and the lines they sit on come
  /// from one piece of arithmetic and cannot drift apart.
  List<(Offset, Offset)> placedMarks(Size size) {
    final box = bodyOn(size);
    final out = List<(Offset, Offset)?>.filled(marks.length, null);

    // Anything a dimension line should keep away from. Forces go in first;
    // the square-on distances add themselves as they are placed.
    final busy = <Offset>[
      for (final f in forces)
        toScreen(f.at, size) +
            Offset(f.dir.dx, -f.dir.dy) / f.dir.distance * 30,
    ];

    // Pass one: the distances whose placement is not a judgment call.
    var below = 0;
    var left = 0;
    for (final (i, m) in marks.indexed) {
      final a = toScreen(m.from, size);
      final b = toScreen(m.to, size);
      final along = b - a;
      final len = along.distance;
      if (len < 0.5) {
        out[i] = (a, b);
        continue;
      }
      final unit = along / len;
      Offset? shift;
      if (m.place == MarkPlace.inPlace) {
        shift = Offset.zero;
      } else if (unit.dy.abs() < 0.02) {
        shift = Offset(0, box.bottom + 20 + 22 * below - a.dy);
        below++;
      } else if (unit.dx.abs() < 0.02) {
        shift = Offset(box.left - 20 - 22 * left - a.dx, 0);
        left++;
      }
      if (shift != null) {
        out[i] = (a + shift, b + shift);
        busy.add((a + b) / 2 + shift);
      }
    }

    // Pass two: a distance measured along a slanted member has two sides and
    // both are equally empty of members, so the tie is broken by whatever
    // else is already on the figure. Taking the side with more room is what
    // stopped a steep member's dimension landing on the vertical one.
    for (final (i, m) in marks.indexed) {
      if (out[i] != null) continue;
      final a = toScreen(m.from, size);
      final b = toScreen(m.to, size);
      final unit = (b - a) / (b - a).distance;
      final normal = Offset(-unit.dy, unit.dx);
      final mid = (a + b) / 2;

      var best = 1.0;
      var room = -1.0;
      for (final sign in [1.0, -1.0]) {
        final at = mid + normal * 26 * sign;
        var nearest = double.infinity;
        for (final o in busy) {
          final d = (at - o).distance;
          if (d < nearest) nearest = d;
        }
        if (nearest > room) {
          room = nearest;
          best = sign;
        }
      }
      final shift = normal * 26 * best;
      out[i] = (a + shift, b + shift);
      busy.add(mid + shift);
    }
    return [for (final o in out) o!];
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

    // Roughly where the body is, for deciding which side of a force its
    // label should sit on.
    var bodyCentre = p;
    for (final member in scene.members) {
      for (final pt in member) {
        bodyCentre = (bodyCentre + at(pt)) / 2;
      }
    }

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
      // Beside the head rather than past it. A force pointing straight down
      // its own member used to write its label on the member. Cleared by half
      // its own width so it never sits on the arrow or its line of action.
      final side = Offset(-unit.dy, unit.dx);
      final away = origin - bodyCentre;
      final sign = side.dx * away.dx + side.dy * away.dy >= 0 ? 1.0 : -1.0;
      final tag = _label(f.label, colour);
      _put(canvas, tag,
          origin + unit * 48 + side * (tag.width / 2 + 10) * sign, size);
    }

    final placed = scene.placedMarks(size);

    for (final (i, m) in scene.marks.indexed) {
      final picked = mode == SceneMode.marks && selected == i;
      final isTruth = mode == SceneMode.marks && i == truth;
      final colour = _colour(picked: picked, isTruth: isTruth);
      final heavy = picked || (locked && isTruth);
      final a = at(m.from);
      final b = at(m.to);
      final (from, to) = placed[i];
      final along = to - from;
      final len = along.distance;
      if (len < 0.5) continue;
      final unit = along / len;
      final normal = Offset(-unit.dy, unit.dx);
      final shift = from - a;

      final paint = Paint()
        ..color = colour
        ..strokeWidth = heavy ? 2.2 : 1.3
        ..strokeCap = StrokeCap.round;

      // The label sits in a break in the line rather than on top of it,
      // except on a near-vertical one, where a horizontal label eats the
      // whole line and leaves two stubs. That one goes beside it.
      final tp = _label(m.label, colour);
      final upright = unit.dx.abs() < 0.35;
      final gap = math.max(tp.width, 14) + 12;
      final mid = (from + to) / 2;
      final broken = !upright && len > gap + 26;
      if (broken) {
        canvas.drawLine(from, mid - unit * (gap / 2), paint);
        canvas.drawLine(mid + unit * (gap / 2), to, paint);
      } else {
        canvas.drawLine(from, to, paint);
      }

      // Ticks square to the line at both ends.
      final tick = normal * 5;
      canvas.drawLine(from - tick, from + tick, paint);
      canvas.drawLine(to - tick, to + tick, paint);

      // Extension lines: out of the body, past the dimension line, with a
      // gap at the body end so they never touch what they measure.
      if (shift.distance > 1) {
        final reach = shift.distance;
        final away = shift / reach;
        final thin = Paint()
          ..color = colour.withValues(alpha: 0.45)
          ..strokeWidth = 1;
        for (final end in [a, b]) {
          canvas.drawLine(end + away * 7, end + away * (reach + 5), thin);
        }
      }

      final Offset tuck;
      if (broken) {
        tuck = mid;
      } else if (upright) {
        // Out to the side the dimension line was pushed, so it stays clear
        // of the body.
        final out = shift.distance > 1 ? shift / shift.distance : normal;
        tuck = mid + out * (tp.width / 2 + 8);
      } else {
        tuck = to + unit * (tp.width / 2 + 9);
      }
      _put(canvas, tp, tuck, size);
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

  TextPainter _label(String text, Color colour) => TextPainter(
        text:
            TextSpan(text: text, style: AppTheme.mono(size: 11, color: colour)),
        textDirection: TextDirection.ltr,
      )..layout();

  void _put(Canvas canvas, TextPainter tp, Offset centre, Size size) {
    var x = centre.dx - tp.width / 2;
    var y = centre.dy - tp.height / 2;
    if (x < 2) x = 2;
    if (x + tp.width > size.width - 2) x = size.width - 2 - tp.width;
    if (y < 1) y = 1;
    if (y + tp.height > size.height - 1) y = size.height - 1 - tp.height;
    canvas.drawRect(
      Rect.fromLTWH(x - 3, y, tp.width + 6, tp.height),
      Paint()..color = AppColors.cream.withValues(alpha: 0.94),
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
