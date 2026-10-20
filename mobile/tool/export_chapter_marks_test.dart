// Writes every chapter mark as a large transparent PNG, for marketing art
// (App Store event cards and headers, where Apple asks for no text).
//
//   flutter test tool/export_chapter_marks_test.dart
//
// Lands in build/chapter-marks/<chapterId>-<color>.png at 1600 px. A test
// only so it can run the app's own painter; it lives outside test/ so the
// ordinary suite never runs it. ChapterMarkPainter stays the one source of
// every drawing.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/study/chapter_marks.dart';

void main() {
  test('export chapter marks', () async {
    const size = 1600.0;
    final out = Directory('build/chapter-marks')..createSync(recursive: true);
    const colors = {
      'charcoal': Color(0xFF2C2C2C),
      'cream': Color(0xFFFFF9F0),
    };
    for (final id in chapterMaps.keys) {
      for (final c in colors.entries) {
        final rec = ui.PictureRecorder();
        final canvas = Canvas(rec);
        ChapterMarkPainter(
          chapterId: id,
          color: c.value,
        ).paint(canvas, const Size(size, size));
        final img = await rec.endRecording().toImage(size.toInt(), size.toInt());
        final png = await img.toByteData(format: ui.ImageByteFormat.png);
        File(
          '${out.path}/$id-${c.key}.png',
        ).writeAsBytesSync(png!.buffer.asUint8List());
      }
    }
  });
}
