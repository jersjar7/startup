import 'dart:math' as math;
import 'dart:ui' as ui;

import 'recording_canvas.dart';

/// A dashed line from [a] to [b] the way the figures draw one: a dash
/// [on] long every [every] along the line, the last cut short at [b].
///
/// On a real canvas this is the figures' own loop, step for step. While the
/// pack builder records ([RecordingCanvas]), it is kept as one step with
/// its two ends, and the player runs the same loop: a dashed line along a
/// slope, recorded dash by dash, put every dash end on a curve in the
/// width, and Road or Grade Line took 1.8 MB to download that way.
void drawDashes(
  ui.Canvas canvas,
  ui.Offset a,
  ui.Offset b,
  ui.Paint paint, {
  double on = 4,
  double every = 8,
}) {
  if (canvas is RecordingCanvas) {
    canvas.recordDashes(a, b, on, every, paint);
    return;
  }
  dashes(canvas, a, b, paint, on, every);
}

/// The loop itself, shared by the figures and the player.
void dashes(
  ui.Canvas canvas,
  ui.Offset a,
  ui.Offset b,
  ui.Paint paint,
  double on,
  double every,
) {
  final run = b - a;
  if (run.distance < 1) return;
  final unit = run / run.distance;
  for (var k = 0.0; k < run.distance; k += every) {
    canvas.drawLine(
      a + unit * k,
      a + unit * math.min(k + on, run.distance),
      paint,
    );
  }
}

/// A dashed outline along [path] the way the figures draw one: a piece
/// [on] long every [every] along each of its contours, the last cut short
/// at the contour's end.
///
/// On a real canvas this is the figures' own loop. While the pack builder
/// records, it is kept as one step holding the path's moves, and the
/// player rebuilds the path and runs the same loop: a dash cut from a
/// circle is a curve that could only be traced otherwise (Which Area
/// Twists It dashes the middle of a tube's wall).
void drawPathDashes(
  ui.Canvas canvas,
  ui.Path path,
  ui.Paint paint, {
  double on = 4,
  double every = 8,
}) {
  if (canvas is RecordingCanvas) {
    canvas.recordPathDashes(path, on, every, paint);
    return;
  }
  pathDashes(canvas, path, paint, on, every);
}

/// The loop itself, shared by the figures and the player.
void pathDashes(
  ui.Canvas canvas,
  ui.Path path,
  ui.Paint paint,
  double on,
  double every,
) {
  for (final m in path.computeMetrics()) {
    for (var d = 0.0; d < m.length; d += every) {
      canvas.drawPath(m.extractPath(d, math.min(d + on, m.length)), paint);
    }
  }
}
