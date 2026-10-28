import 'dart:ui' as ui;

/// Whether the pack builder keeps a figure's hatching as one step
/// ([RecordingCanvas.recordHatch]) rather than line by line. Off unless a
/// game asks for it, so every game recorded before it records the same.
bool recordHatches = false;

/// The figures' hatching loop (figure_ink.dart's hatchIn), shared by the
/// figures and the player: lines [step] apart across [shape]'s bounds,
/// leaning by [slope], clipped to the shape.
///
/// It starts from the bounds of the path, which the engine keeps in single
/// precision. Recorded line by line, each line's ends were that single
/// precision number plus a double one, and no line in the width lands on
/// it exactly: a one in a hundred thousand of a pixel was enough to move
/// a V-notch plate's hatching two shades on hundreds of pixels (Which
/// Formula Fits This Weir). The player takes the bounds from the same path
/// instead, as the figure did.
void hatches(
  ui.Canvas canvas,
  ui.Path shape,
  ui.Paint ink,
  double step,
  double slope,
) {
  final bounds = shape.getBounds();
  if (bounds.isEmpty) return;
  canvas
    ..save()
    ..clipPath(shape);
  final span = bounds.width + bounds.height;
  for (var d = -bounds.height; d < span; d += step) {
    canvas.drawLine(
      ui.Offset(bounds.left + d, bounds.top),
      ui.Offset(bounds.left + d - slope * bounds.height, bounds.bottom),
      ink,
    );
  }
  canvas.restore();
}
