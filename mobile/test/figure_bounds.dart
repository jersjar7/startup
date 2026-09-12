import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Catches ink that falls outside its own panel.
///
/// Every figure is drawn inside a rounded box that clips it, so anything a
/// painter puts outside the size it was handed is simply cut off on the
/// phone. A label at the end of a line that runs to the top of the drawing
/// is the usual way this happens: the label is placed above the line end,
/// which is above the panel, and the reader sees the bottom third of a
/// letter or nothing at all. `writeOn` in `figure_ink.dart` keeps text
/// inside the panel; painters that lay out their own `TextPainter` have to
/// be checked, and there is no way to see this in a screenshot of the app,
/// because by then the evidence has been clipped away.
///
/// The trick is to paint the figure again into a canvas that is bigger than
/// the panel, with the panel offset into the middle of it, and then look at
/// the margin. Ink in the margin is ink the phone throws away.
///
/// A stroke sitting exactly on the edge spills half its width, so the first
/// two pixels outside are ignored.

@immutable
class Spill {
  const Spill({
    required this.painter,
    required this.side,
    required this.pixels,
    required this.reach,
  });

  /// The painter class, which is enough to find it in the source.
  final String painter;

  /// Which edge it went over.
  final String side;

  /// How many pixels of ink landed outside.
  final int pixels;

  /// How far past the edge the furthest one was.
  final int reach;

  @override
  String toString() => '$painter: $pixels px over the $side edge, '
      'reaching ${reach}px out';
}

/// Margin painted around the panel. Wide enough to hold a line of text that
/// has drifted off the top, narrow enough to keep the images small.
const _margin = 28;

/// Strokes on the boundary itself spill half a line width. Anything within
/// this distance of the edge is the drawing touching its own frame, not a
/// label falling off it.
const _grace = 2;

/// Ink is anything meaningfully opaque. The figures paint pale wash fills
/// (0.06 alpha grid lines) that would otherwise count as a spill.
const _alphaFloor = 40;

/// Repaints every figure on the current screen into an oversized canvas and
/// reports what landed outside the panel.
///
/// Call inside `tester.runAsync`-free code; it handles the async image read
/// itself.
Future<List<Spill>> findSpills(WidgetTester tester, {String? saveAs}) async {
  final spills = <Spill>[];
  final finder = find.byType(CustomPaint);
  var n = 0;

  for (final element in finder.evaluate()) {
    final widget = element.widget as CustomPaint;
    for (final painter in [widget.painter, widget.foregroundPainter]) {
      if (painter == null) continue;
      final size = (element.renderObject as RenderBox).size;
      if (size.isEmpty) continue;
      final found = await _spillsOf(
        tester,
        painter,
        size,
        saveAs == null ? null : '$saveAs-${n++}',
      );
      spills.addAll(found);
    }
  }
  return spills;
}

Future<List<Spill>> _spillsOf(
  WidgetTester tester,
  CustomPainter painter,
  Size size,
  String? saveAs,
) async {
  final width = size.width.ceil() + _margin * 2;
  final height = size.height.ceil() + _margin * 2;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.translate(_margin.toDouble(), _margin.toDouble());
  if (saveAs != null) {
    // The panel edge, so the picture shows what the phone keeps and what it
    // throws away.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = const Color(0xFFE8683A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
  try {
    painter.paint(canvas, size);
  } catch (_) {
    // A painter that will not repaint outside its widget is not what this
    // check is about.
    return const [];
  }
  final picture = recorder.endRecording();

  ByteData? bytes;
  await tester.runAsync(() async {
    final image = await picture.toImage(width, height);
    bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
  });
  if (bytes == null) {
    picture.dispose();
    return const [];
  }

  final data = bytes!.buffer.asUint8List();
  final counts = <String, int>{};
  final reaches = <String, int>{};

  void note(String side, int outBy) {
    counts[side] = (counts[side] ?? 0) + 1;
    if (outBy > (reaches[side] ?? 0)) reaches[side] = outBy;
  }

  final left = _margin;
  final top = _margin;
  final right = _margin + size.width.ceil();
  final bottom = _margin + size.height.ceil();

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final inside = x >= left - _grace &&
          x < right + _grace &&
          y >= top - _grace &&
          y < bottom + _grace;
      if (inside) continue;
      if (data[(y * width + x) * 4 + 3] < _alphaFloor) continue;

      if (y < top) {
        note('top', top - y);
      } else if (y >= bottom) {
        note('bottom', y - bottom + 1);
      } else if (x < left) {
        note('left', left - x);
      } else {
        note('right', x - right + 1);
      }
    }
  }

  final name = painter.runtimeType.toString();

  if (saveAs != null && counts.isNotEmpty) {
    await tester.runAsync(() async {
      final image = await picture.toImage(width, height);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final file = File('build/review/bounds/$saveAs-$name.png');
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(png!.buffer.asUint8List());
    });
  }

  picture.dispose();
  return [
    for (final side in counts.keys)
      Spill(
        painter: name,
        side: side,
        pixels: counts[side]!,
        reach: reaches[side]!,
      ),
  ];
}
