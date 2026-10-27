import 'dart:ui' as ui;

import 'package:flutter/painting.dart' as painting;

import 'recording_canvas.dart';

/// The text painter the figures use: Flutter's own, plus the one thing a
/// recorded drawing needs, which is to say what it wrote.
///
/// A painted paragraph keeps its words to itself, so a figure drawn onto a
/// [RecordingCanvas] would lose every label. This one hands the canvas its
/// text, style and layout instead. On a real canvas it is exactly Flutter's.
class TextPainter extends painting.TextPainter {
  TextPainter({
    super.text,
    super.textAlign,
    super.textDirection,
    super.textScaler,
    super.maxLines,
    super.ellipsis,
    super.locale,
    super.strutStyle,
    super.textWidthBasis,
    super.textHeightBehavior,
  });

  double _minWidth = 0;
  double _maxWidth = double.infinity;

  @override
  void layout({double minWidth = 0.0, double maxWidth = double.infinity}) {
    _minWidth = minWidth;
    _maxWidth = maxWidth;
    super.layout(minWidth: minWidth, maxWidth: maxWidth);
  }

  @override
  void paint(ui.Canvas canvas, ui.Offset offset) {
    if (canvas is RecordingCanvas) {
      canvas.recordText(this, _minWidth, _maxWidth, offset);
      return;
    }
    super.paint(canvas, offset);
  }
}
