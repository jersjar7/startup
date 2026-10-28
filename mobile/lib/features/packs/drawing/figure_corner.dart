import 'dart:math' as math;
import 'dart:ui' as ui;

import 'recording_canvas.dart';

// The triangle figures (right triangles, oblique triangles) place their
// labels and angle arcs by directions scaled to unit length: a side's
// label sits a set distance off the side's middle, turned to the side; an
// angle's arc runs between the two sides at a corner; an angle's name sits
// a set distance out from the corner. Every one of those numbers bends
// with the width, since a unit direction divides by a length that grows
// with it, so recorded as numbers they took a line with thousands of bends
// each: Which Ratio and Which Law were each 650 KB to download.
//
// Each helper below is, on a real canvas, the figures' own arithmetic in
// the figures' own order, so a built-in screen draws exactly what it drew
// before. While the pack builder records ([RecordingCanvas]), each is kept
// as one step holding the points it starts from, which are straight lines
// in the width, and the player runs the same arithmetic on them.

/// Moves and turns the canvas for a label beside the side [a] to [b]: [by]
/// off the side's middle, on the side away from [away], turned to lie along
/// the side (never upside down) when [turned], otherwise upright.
void turnBeside(
  ui.Canvas canvas,
  ui.Offset a,
  ui.Offset b, {
  required ui.Offset away,
  required double by,
  required bool turned,
}) {
  if (canvas is RecordingCanvas) {
    canvas.recordBeside(a, b, away, by, turned);
    return;
  }
  besideTurn(canvas, a, b, away, by, turned);
}

/// The move and turn itself, shared by the figures and the player.
void besideTurn(
  ui.Canvas canvas,
  ui.Offset a,
  ui.Offset b,
  ui.Offset away,
  double by,
  bool turned,
) {
  final mid = (a + b) / 2;
  final along = b - a;
  final unit = along / along.distance;
  var normal = ui.Offset(-unit.dy, unit.dx);
  if ((mid + normal - away).distance < (mid - normal - away).distance) {
    normal = -normal;
  }
  var angle = math.atan2(unit.dy, unit.dx);
  if (angle > math.pi / 2 || angle < -math.pi / 2) angle += math.pi;
  canvas.translate(mid.dx + normal.dx * by, mid.dy + normal.dy * by);
  canvas.rotate(turned ? angle : 0);
}

/// The arc of [radius] round the corner [at], from the side toward [p] to
/// the side toward [q], the short way round. With [unit] the two
/// directions are scaled to unit length first, as the right triangle
/// figures do (the angles come out a hair different from the unscaled
/// directions the oblique figures use).
void drawCornerArc(
  ui.Canvas canvas,
  ui.Offset at,
  ui.Offset p,
  ui.Offset q, {
  required double radius,
  required ui.Paint paint,
  bool unit = false,
}) {
  if (canvas is RecordingCanvas) {
    canvas.recordCornerArc(at, p, q, radius, unit, paint);
    return;
  }
  cornerArc(canvas, at, p, q, radius, unit, paint);
}

/// The arc itself, shared by the figures and the player.
void cornerArc(
  ui.Canvas canvas,
  ui.Offset at,
  ui.Offset p,
  ui.Offset q,
  double radius,
  bool unit,
  ui.Paint paint,
) {
  final u1 = unit ? (p - at) / (p - at).distance : (p - at);
  final u2 = unit ? (q - at) / (q - at).distance : (q - at);
  final start = math.atan2(u1.dy, u1.dx);
  final end = math.atan2(u2.dy, u2.dx);
  var sweep = end - start;
  if (sweep > math.pi) sweep -= 2 * math.pi;
  if (sweep < -math.pi) sweep += 2 * math.pi;
  canvas.drawArc(
    ui.Rect.fromCircle(center: at, radius: radius),
    start,
    sweep,
    false,
    paint,
  );
}

/// Where a figure centres a label, kept as how the figure found it: a
/// point as it is, a point [by] out from [from] along [away], or a point
/// [by] out from the corner [from] along the line halving the angle
/// between the sides toward [p] and [q].
final class Spot {
  const Spot(this.from) : away = null, p = null, q = null, by = 0;

  const Spot.pushed(this.from, ui.Offset this.away, this.by)
    : p = null,
      q = null;

  const Spot.halving(this.from, ui.Offset this.p, ui.Offset this.q, this.by)
    : away = null;

  final ui.Offset from;
  final ui.Offset? away;
  final ui.Offset? p;
  final ui.Offset? q;
  final double by;

  /// A point as it is, recorded as a plain number pair.
  bool get plain => away == null && p == null;

  ui.Offset get at => switch (this) {
    Spot(away: final ui.Offset away) => pushedFrom(from, away, by),
    Spot(p: final ui.Offset p, q: final ui.Offset q) => halving(from, p, q, by),
    _ => from,
  };

  /// As a recorded step keeps it: `["push", x, y, ax, ay, by]` or
  /// `["half", x, y, px, py, qx, qy, by]`.
  List<Object> get recorded => switch (this) {
    Spot(away: final ui.Offset away) => [
      'push',
      from.dx,
      from.dy,
      away.dx,
      away.dy,
      by,
    ],
    Spot(p: final ui.Offset p, q: final ui.Offset q) => [
      'half',
      from.dx,
      from.dy,
      p.dx,
      p.dy,
      q.dx,
      q.dy,
      by,
    ],
    _ => throw StateError('A plain spot is recorded as its point'),
  };
}

/// [by] out from [from] along [away].
ui.Offset pushedFrom(ui.Offset from, ui.Offset away, double by) =>
    from + away / away.distance * by;

/// [by] out from the corner [at] along the line halving the angle between
/// the sides toward [p] and [q].
ui.Offset halving(ui.Offset at, ui.Offset p, ui.Offset q, double by) {
  final u1 = (p - at) / (p - at).distance;
  final u2 = (q - at) / (q - at).distance;
  final bisect = (u1 + u2) / 2;
  return at + bisect / bisect.distance * by;
}
