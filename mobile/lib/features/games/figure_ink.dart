import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Drafting conventions shared by the figures, so that the same thing is
/// drawn the same way everywhere.
///
/// Three of these matter more than anything else in a fluids drawing, and
/// all three were missing: a reader has to be told WHICH VIEW they are
/// looking at, solid material has to look solid rather than be a line, and
/// a water surface has to be unmistakably a water surface rather than
/// another line of the same weight. A bare line can be a floor, a wall, a
/// water level or a pipe, and the reader should never have to guess which.

/// Which view the panel is: looking at it from the side, cut through it, or
/// looking down on it.
enum Looking { elevation, section, plan }

extension LookingWords on Looking {
  String get tag => switch (this) {
        Looking.elevation => 'ELEVATION',
        Looking.section => 'SECTION',
        Looking.plan => 'PLAN',
      };
}

/// Says what the drawing is, in the bottom right corner where nothing else
/// goes.
void viewTag(Canvas canvas, Size size, Looking view, {String? note}) {
  final text = note == null ? view.tag : '${view.tag}  ${note.toUpperCase()}';
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: AppTheme.mono(size: 8.5, color: AppColors.ink3),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final at = Offset(size.width - painter.width - 7, size.height - 13);
  // A patch behind it, because it often sits over ground hatching.
  canvas.drawRect(
      Rect.fromLTWH(at.dx - 3, at.dy - 1, painter.width + 6,
          painter.height + 2),
      Paint()..color = AppColors.cream.withValues(alpha: 0.92));
  painter.paint(canvas, at);
}

/// Solid material: concrete, steel, a valve body, the ground. Diagonal
/// hatching inside the shape, with the shape's own outline left to the
/// caller.
void hatchIn(
  Canvas canvas,
  Path shape, {
  double step = 7,
  Color? color,
  double slope = 1,
}) {
  final bounds = shape.getBounds();
  if (bounds.isEmpty) return;
  canvas
    ..save()
    ..clipPath(shape);
  final ink = Paint()
    ..color = (color ?? AppColors.ink3).withValues(alpha: 0.75)
    ..strokeWidth = 0.9;
  final span = bounds.width + bounds.height;
  for (var d = -bounds.height; d < span; d += step) {
    canvas.drawLine(
      Offset(bounds.left + d, bounds.top),
      Offset(bounds.left + d - slope * bounds.height, bounds.bottom),
      ink,
    );
  }
  canvas.restore();
}

/// Ground, or any fixed surface a thing sits on: the line itself with the
/// usual back-slanted ticks under it, so it can never be read as a water
/// level or a wall.
void groundLine(
  Canvas canvas,
  Offset from,
  Offset to, {
  Color? color,
  double step = 9,
}) {
  final ink = Paint()
    ..color = color ?? AppColors.ink2
    ..strokeWidth = 1.4;
  canvas.drawLine(from, to, ink);
  final tick = Paint()
    ..color = (color ?? AppColors.ink2).withValues(alpha: 0.8)
    ..strokeWidth = 1.1;
  for (var x = math.min(from.dx, to.dx) + 3;
      x < math.max(from.dx, to.dx);
      x += step) {
    final t = (x - from.dx) / (to.dx - from.dx == 0 ? 1 : to.dx - from.dx);
    final y = from.dy + (to.dy - from.dy) * t;
    canvas.drawLine(Offset(x, y), Offset(x - 6, y + 7), tick);
  }
}

/// A free water surface: the line, and on it the triangle that says this is
/// a water level and not a piece of the structure.
void waterLevel(
  Canvas canvas,
  Offset from,
  Offset to, {
  double? markAt,
  Color? color,
}) {
  final tone = color ?? AppColors.info;
  canvas.drawLine(
      from,
      to,
      Paint()
        ..color = tone
        ..strokeWidth = 1.6);
  final x = markAt ?? (from.dx + to.dx) / 2;
  final t = (to.dx - from.dx).abs() < 0.001
      ? 0.0
      : (x - from.dx) / (to.dx - from.dx);
  final y = from.dy + (to.dy - from.dy) * t;
  canvas
    ..drawPath(
        Path()
          ..moveTo(x - 5, y - 8)
          ..lineTo(x + 5, y - 8)
          ..lineTo(x, y)
          ..close(),
        Paint()..color = tone)
    ..drawLine(
        Offset(x - 7, y + 3),
        Offset(x + 7, y + 3),
        Paint()
          ..color = tone.withValues(alpha: 0.6)
          ..strokeWidth = 1.1);
}

/// The fill used for water everywhere.
Paint get waterFill =>
    Paint()..color = AppColors.info.withValues(alpha: 0.22);

/// Where a label can actually go: the offset moved, if it has to be, so the
/// whole of the text lands inside the panel.
///
/// Panels are clipped by the rounded box they sit in, so a label placed
/// past an edge is not drawn small or drawn faintly, it is cut in half and
/// the reader gets the bottom of a letter. It happens most often at the end
/// of a line that runs to the top of the drawing: the label goes above the
/// line end, and the line end is already at the edge.
///
/// Clamping is the floor, not the fix. A label shoved back inside can land
/// on top of the thing it names, so a painter that knows it is near an edge
/// should choose the other side first and let this catch what it missed.
Offset insidePanel(Size size, Size text, Offset at, {double pad = 2}) {
  var x = at.dx;
  var y = at.dy;
  if (x + text.width > size.width - pad) x = size.width - pad - text.width;
  if (x < pad) x = pad;
  if (y + text.height > size.height - pad) y = size.height - pad - text.height;
  if (y < pad) y = pad;
  return Offset(x, y);
}

/// Paints a laid-out label at `at`, moved if it has to be so that none of it
/// falls off the panel. `at` is the top left of the text.
void paintInside(Canvas canvas, Size size, TextPainter text, Offset at) {
  text.paint(canvas, insidePanel(size, text.size, at));
}

/// A small label written on a figure, kept inside the panel and given a
/// patch of background so it never sits on top of a line.
void writeOn(
  Canvas canvas,
  Size size,
  String text,
  Offset at,
  Color color, {
  double fontSize = 10,
}) {
  // Laid out against the panel width, so a sentence longer than the drawing
  // wraps onto a second line instead of running off the side and being cut.
  // Several of the explanation notes are full sentences and were losing
  // their last few words to the edge.
  final painter = TextPainter(
    text: TextSpan(
        text: text, style: AppTheme.mono(size: fontSize, color: color)),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: (size.width - 8).clamp(1.0, double.infinity));
  final place = insidePanel(size, painter.size, at);
  final patch = Rect.fromLTWH(
      place.dx - 2, place.dy - 1, painter.width + 4, painter.height + 2);
  canvas.drawRect(
      patch, Paint()..color = AppColors.cream.withValues(alpha: 0.92));
  painter.paint(canvas, place);
}
