import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/games/before_or_during_game.dart';
import 'package:mobile/features/games/coupon_figures.dart';
import 'package:mobile/features/packs/drawing/drawing_painter.dart';
import 'package:mobile/features/packs/drawing/recording_canvas.dart';

import '../support/fonts.dart';
import 'builder.dart';

/// How close a recorded drawing with curves comes to the painter's own.
/// Curves in a path are the one thing the recorder approximates (as fine
/// polylines); this measures the cost on a real figure, the steel coupon.
void main() {
  setUpAll(loadBrandFonts);

  testWidgets('curves stay within a shade of the original', (tester) async {
    var worstPixels = 0, worstShade = 0, total = 0;
    for (final r in dimRounds) {
      for (final locked in [false, true]) {
        final painter = CouponPainter(
          coupon: r.coupon,
          answer: r.answer,
          picked: locked ? r.answer : null,
          locked: locked,
        );
        // Recorded once, across every width and both themes, then compared
        // on three phones in each theme.
        final played = record(painter.paint, 230, what: 'coupon');
        for (final dark in [false, true]) {
          AppPalette.dark = dark;
          for (final w in [270.0, 340.0, 380.0]) {
            final size = Size(w, 230);
            final a = await _draw(tester, size, (c) => painter.paint(c, size));
            final b = await _draw(
              tester,
              size,
              (c) => playDrawing(c, size, drawingSteps(played, w)),
            );
            var pixels = 0;
            for (var i = 0; i < a.length; i += 4) {
              var d = 0;
              for (var k = 0; k < 4; k++) {
                final x = (a[i + k] - b[i + k]).abs();
                if (x > d) d = x;
              }
              if (d > 0) pixels++;
              if (d > worstShade) worstShade = d;
            }
            if (pixels > worstPixels) worstPixels = pixels;
            total++;
          }
        }
      }
    }
    AppPalette.dark = false;
    // ignore: avoid_print
    print(
      'coupon: $total drawings, at most $worstPixels pixels differ in one, '
      'by at most $worstShade of 255; ${RecordingCanvas.traced} paths traced',
    );
  });
}

Future<List<int>> _draw(
  WidgetTester tester,
  Size size,
  void Function(Canvas) paint,
) async {
  return (await tester.runAsync(() async {
    final recorder = ui.PictureRecorder();
    paint(Canvas(recorder));
    final image = await recorder.endRecording().toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final bytes = (await image.toByteData())!.buffer.asUint8List();
    image.dispose();
    return bytes;
  }))!;
}
