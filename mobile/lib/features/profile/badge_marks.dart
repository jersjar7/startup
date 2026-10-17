import 'package:flutter/material.dart';

import '../study/chapter_marks.dart';

/// The drawing on each badge, on the same 512 square as the chapter marks.
///
/// A chapter badge IS its chapter's mark (chapter_marks.dart), so the
/// student meets the drawing on the chapter card first and recognises it
/// on the coin. The four milestones get drawings by the same rules: inside
/// a 64 margin, a 20 stroke for structure and 13 for annotation, round caps,
/// fills only for small solid markers.
///
/// These painters are also the source of the Rive artwork: the export in
/// `tool/export_badge_marks_test.dart` plays them onto a recording canvas and
/// writes the strokes out for `mobile/rive/badge/gen.py`. Change a drawing
/// here, re-run the export and the build, and both stay the same picture.
class BadgeMarkPainter extends CustomPainter {
  const BadgeMarkPainter({required this.markId, required this.color});

  /// A chapter id, or one of the milestone ids in [milestoneMarks].
  final String markId;
  final Color color;

  static const milestoneMarks = [
    'flawless',
    'first-daily',
    'daily-7',
    'every-chapter',
  ];

  static const double _canvas = 512;

  @override
  void paint(Canvas canvas, Size size) {
    if (!milestoneMarks.contains(markId)) {
      ChapterMarkPainter(chapterId: markId, color: color).paint(canvas, size);
      return;
    }
    final scale = size.shortestSide / _canvas;
    canvas
      ..save()
      ..translate(
        (size.width - _canvas * scale) / 2,
        (size.height - _canvas * scale) / 2,
      )
      ..scale(scale);
    final ink = _stroke(20);
    final thin = _stroke(13);
    final solid = Paint()..color = color;
    switch (markId) {
      case 'flawless':
        _flawless(canvas, ink, thin, solid);
      case 'first-daily':
        _firstDaily(canvas, ink, thin);
      case 'daily-7':
        _sevenInARow(canvas, ink, thin, solid);
      case 'every-chapter':
        _everyChapter(canvas, thin, solid);
    }
    canvas.restore();
  }

  Paint _stroke(double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  /// An arrow in the middle of a target: every round right the first time.
  void _flawless(Canvas canvas, Paint ink, Paint thin, Paint solid) {
    const c = Offset(240, 288);
    canvas
      ..drawCircle(c, 160, ink)
      ..drawCircle(c, 96, thin)
      ..drawCircle(c, 24, solid)
      ..drawLine(c, const Offset(416, 112), ink);
    // Fletching, two pairs, at the tail.
    for (final t in const [Offset(416, 112), Offset(384, 144)]) {
      canvas
        ..drawLine(t, t.translate(0, -44), thin)
        ..drawLine(t, t.translate(44, 0), thin);
    }
  }

  /// A page off the calendar, ticked: the first Daily.
  void _firstDaily(Canvas canvas, Paint ink, Paint thin) {
    canvas
      ..drawRRect(
        RRect.fromLTRBR(96, 136, 416, 440, const Radius.circular(36)),
        ink,
      )
      ..drawLine(const Offset(96, 216), const Offset(416, 216), thin)
      ..drawLine(const Offset(184, 88), const Offset(184, 168), ink)
      ..drawLine(const Offset(328, 88), const Offset(328, 168), ink)
      ..drawPath(
        Path()
          ..moveTo(184, 324)
          ..lineTo(236, 376)
          ..lineTo(332, 280),
        ink,
      );
  }

  /// The same calendar page with a whole week filled in: seven Dailies in a
  /// row. A sibling of [_firstDaily] on purpose, so the two read as a pair.
  void _sevenInARow(Canvas canvas, Paint ink, Paint thin, Paint solid) {
    canvas
      ..drawRRect(
        RRect.fromLTRBR(96, 136, 416, 440, const Radius.circular(36)),
        ink,
      )
      ..drawLine(const Offset(96, 216), const Offset(416, 216), thin)
      ..drawLine(const Offset(184, 88), const Offset(184, 168), ink)
      ..drawLine(const Offset(328, 88), const Offset(328, 168), ink);
    // Laid out as the days of a calendar: four, then three.
    for (var i = 0; i < 7; i++) {
      canvas.drawCircle(
        Offset(160 + (i % 4) * 64.0, i < 4 ? 296 : 368),
        22,
        solid,
      );
    }
  }

  /// Fifteen dots, all of them filled: a round played in every chapter.
  void _everyChapter(Canvas canvas, Paint thin, Paint solid) {
    canvas.drawRRect(
      RRect.fromLTRBR(72, 136, 440, 376, const Radius.circular(44)),
      thin,
    );
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 5; col++) {
        canvas.drawCircle(
          Offset(128 + col * 64.0, 192 + row * 64.0),
          20,
          solid,
        );
      }
    }
  }

  @override
  bool shouldRepaint(BadgeMarkPainter old) =>
      old.markId != markId || old.color != color;
}
