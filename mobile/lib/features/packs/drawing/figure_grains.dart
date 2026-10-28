import 'dart:math' as math;
import 'dart:ui' as ui;

import 'recording_canvas.dart';

/// Soil grains packed into [block] the way the aquifer figures draw them:
/// circles of radius 4 to 11, placed by a seeded random walk until they
/// cover the share of the block that is not void (one less [porosity]),
/// each filled with [fill] and ringed with [edge].
///
/// On a real canvas this is the figures' own loop, step for step. While
/// the pack builder records ([RecordingCanvas]), it is kept as one step
/// with the block and the porosity, and the player runs the same loop:
/// recorded grain by grain, a wider block holds more grains, so every
/// couple of pixels of width was a drawing of its own, and Which Speed Is
/// That took 44 MB to download that way.
void drawGrains(
  ui.Canvas canvas,
  ui.Rect block,
  double porosity,
  ui.Paint fill,
  ui.Paint edge, {
  int seed = 7,
}) {
  if (canvas is RecordingCanvas) {
    canvas.recordGrains(block, porosity, seed, fill, edge);
    return;
  }
  grains(canvas, block, porosity, seed, fill, edge);
}

/// The loop itself, shared by the figures and the player.
void grains(
  ui.Canvas canvas,
  ui.Rect block,
  double porosity,
  int seed,
  ui.Paint fill,
  ui.Paint edge,
) {
  final left = block.left;
  final top = block.top;
  final right = block.right;
  final bottom = block.bottom;
  final random = math.Random(seed);
  final want = (1 - porosity) * (right - left) * (bottom - top);
  var covered = 0.0;
  var guard = 0;
  while (covered < want && guard++ < 600) {
    final r = 4.0 + random.nextDouble() * 7;
    final c = ui.Offset(
      left + r + random.nextDouble() * (right - left - 2 * r),
      top + r + random.nextDouble() * (bottom - top - 2 * r),
    );
    canvas
      ..drawCircle(c, r, fill)
      ..drawCircle(c, r, edge);
    covered += math.pi * r * r * 0.72;
  }
}
