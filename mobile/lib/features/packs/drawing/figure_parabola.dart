import 'dart:ui' as ui;

import 'recording_canvas.dart';

/// A parabola drawn the way the discriminant figures draw one: a point
/// every [step] pixels from the left edge to [width], each [arm] above or
/// below the [vertex] times the square of its distance across over [half],
/// joined by straight lines.
///
/// On a real canvas this is the figures' own loop, step for step. While the
/// pack builder records ([RecordingCanvas]), it is kept as one step with
/// those numbers, and the player runs the same loop. Recorded point by
/// point, the curve gained a point every three pixels of width and every
/// point's height bent with the width, so one curve would have been a
/// separate drawing for every three pixels of a phone.
void drawParabola(
  ui.Canvas canvas, {
  required double width,
  required ui.Offset vertex,
  required double arm,
  required double half,
  required bool opensUp,
  required ui.Paint paint,
  double step = 3,
}) {
  if (canvas is RecordingCanvas) {
    canvas.recordParabola(width, vertex, arm, half, opensUp, step, paint);
    return;
  }
  parabola(canvas, width, vertex, arm, half, opensUp, step, paint);
}

/// The loop itself, shared by the figures and the player.
void parabola(
  ui.Canvas canvas,
  double width,
  ui.Offset vertex,
  double arm,
  double half,
  bool opensUp,
  double step,
  ui.Paint paint,
) {
  final k = arm / (half * half);
  final path = ui.Path();
  for (double x = 0; x <= width; x += step) {
    final dx = x - vertex.dx;
    // Screen y grows downward, so "opens up" subtracts.
    final y = vertex.dy + (opensUp ? -1 : 1) * k * dx * dx;
    if (x == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  canvas.drawPath(path, paint);
}
