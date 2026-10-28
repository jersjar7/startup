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
