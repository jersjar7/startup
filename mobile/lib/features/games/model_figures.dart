import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Which of the two similitude numbers a test has to match.
enum Law { froude, reynolds, either }

extension LawWords on Law {
  String get plain => switch (this) {
        Law.froude => 'Match the Froude number',
        Law.reynolds => 'Match the Reynolds number',
        Law.either => 'Either one: both ask the same here',
      };
}

/// What the test looks like, which is the evidence for which law governs it.
/// A free water surface means gravity is shaping the flow and Froude
/// governs. No free surface means it is not, and viscosity is what is left.
enum Bench { openChannel, closedPipe, submerged, tunnel }

extension BenchWords on Bench {
  bool get hasSurface => this == Bench.openChannel;
}

/// The test rig drawn in section.
class BenchPainter extends CustomPainter {
  const BenchPainter({required this.bench, required this.caption});

  final Bench bench;
  final String caption;

  @override
  void paint(Canvas canvas, Size size) {
    final wall = Paint()
      ..color = AppColors.charcoal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final wet = Paint()..color = AppColors.info.withValues(alpha: 0.22);
    final body = Paint()..color = AppColors.charcoal.withValues(alpha: 0.75);
    final middle = size.height * 0.5;
    final left = 16.0;
    final right = size.width - 16;

    switch (bench) {
      case Bench.openChannel:
        // A channel with a step down it and air above the water, which is
        // the thing to look for.
        final bed = Path()
          ..moveTo(left, middle - 4)
          ..lineTo(size.width * 0.42, middle - 4)
          ..lineTo(size.width * 0.62, middle + 34)
          ..lineTo(right, middle + 34);
        final water = Path()
          ..moveTo(left, middle - 26)
          ..lineTo(size.width * 0.44, middle - 26)
          ..lineTo(size.width * 0.66, middle + 22)
          ..lineTo(right, middle + 22)
          ..lineTo(right, middle + 34)
          ..lineTo(size.width * 0.62, middle + 34)
          ..lineTo(size.width * 0.42, middle - 4)
          ..lineTo(left, middle - 4)
          ..close();
        canvas
          ..drawPath(water, wet)
          ..drawPath(bed, wall)
          ..drawLine(Offset(left, middle - 26),
              Offset(size.width * 0.44, middle - 26), wall)
          ..drawLine(Offset(size.width * 0.66, middle + 22),
              Offset(right, middle + 22), wall);
        _write(canvas, size, 'open to the air', Offset(left + 4, middle - 46),
            AppColors.ember);
      case Bench.closedPipe:
        // A full bore with a fitting in it and no surface anywhere.
        canvas
          ..drawRect(Rect.fromLTRB(left, middle - 22, right, middle + 22), wet)
          ..drawLine(Offset(left, middle - 22), Offset(right, middle - 22), wall)
          ..drawLine(Offset(left, middle + 22), Offset(right, middle + 22), wall)
          ..drawRect(
              Rect.fromLTRB(size.width * 0.46, middle - 30, size.width * 0.54,
                  middle + 30),
              body);
        _write(canvas, size, 'full bore, no surface',
            Offset(left + 4, middle - 48), AppColors.ink2);
      case Bench.submerged:
        // A body well under the surface, with the surface far enough away
        // that it is not making waves.
        canvas
          ..drawRect(Rect.fromLTRB(left, middle - 34, right, middle + 34), wet)
          ..drawLine(Offset(left, middle - 34), Offset(right, middle - 34), wall)
          ..drawOval(
              Rect.fromCenter(
                  center: Offset(size.width * 0.5, middle + 8),
                  width: 84,
                  height: 22),
              body);
        _write(canvas, size, 'deep under, no waves made',
            Offset(left + 4, middle - 50), AppColors.ink2);
      case Bench.tunnel:
        // Air over a shape, which has no free surface in it at all.
        canvas
          ..drawLine(Offset(left, middle - 36), Offset(right, middle - 36), wall)
          ..drawLine(Offset(left, middle + 36), Offset(right, middle + 36), wall)
          ..drawRect(
              Rect.fromCenter(
                  center: Offset(size.width * 0.5, middle),
                  width: 90,
                  height: 14),
              body);
        for (var i = 0; i < 3; i++) {
          final y = middle - 24 + i * 24;
          canvas.drawLine(
              Offset(left + 6, y),
              Offset(size.width * 0.38, y),
              Paint()
                ..color = AppColors.ink3
                ..strokeWidth = 1.2);
        }
        _write(canvas, size, 'air, no free surface',
            Offset(left + 4, middle - 52), AppColors.ink2);
    }

    _write(canvas, size, caption, Offset(left, size.height - 16),
        AppColors.ink3);
  }

  @override
  bool shouldRepaint(BenchPainter old) =>
      old.bench != bench || old.caption != caption;
}

/// A model beside the thing it stands for, and what matching one number or
/// the other asks of the model's speed.
@immutable
class Twins {
  const Twins({required this.law, required this.model, required this.proto});

  /// Which number the test is being run to match. Never `either` here: this
  /// is about what a named law asks for.
  final Law law;

  /// The two sizes, in whatever unit: only their ratio matters.
  final double model;
  final double proto;

  /// The model speed over the prototype speed, in the same fluid. Froude
  /// scales as the square root of the length ratio; Reynolds scales as its
  /// inverse, which is why a small Reynolds model has to run so fast.
  double get ratio => law == Law.froude
      ? math.sqrt(model / proto)
      : proto / model;
}

/// The two of them side by side, drawn to the scale that is claimed.
class TwinsPainter extends CustomPainter {
  const TwinsPainter({required this.twins});

  final Twins twins;

  @override
  void paint(Canvas canvas, Size size) {
    final biggest = math.max(twins.model, twins.proto);
    final middle = size.height * 0.56;
    final body = Paint()..color = AppColors.info.withValues(alpha: 0.35);
    final edge = Paint()
      ..color = AppColors.charcoal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    void block(double centerX, double share, String title, String below) {
      // Nothing is drawn smaller than a few pixels, or a hundred to one
      // would be a speck with a label under it.
      final wide = math.max(10.0, 118 * share);
      final tall = math.max(7.0, 42 * share);
      final rect = Rect.fromLTWH(
          centerX - wide / 2, middle - tall, wide, tall);
      canvas
        ..drawRect(rect, body)
        ..drawRect(rect, edge);
      _write(canvas, size, title, Offset(centerX - 26, 10), AppColors.charcoal);
      _write(canvas, size, below, Offset(centerX - 30, middle + 12),
          AppColors.ink3);
    }

    block(size.width * 0.29, twins.proto / biggest, 'the real thing',
        '${_num(twins.proto)} across');
    block(size.width * 0.72, twins.model / biggest, 'the model',
        '${_num(twins.model)} across');

    canvas.drawLine(Offset(16, middle + 2), Offset(size.width - 16, middle + 2),
        Paint()
          ..color = AppColors.line
          ..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(TwinsPainter old) => old.twins != twins;
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();

void _write(Canvas canvas, Size size, String text, Offset at, Color color) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
    textDirection: TextDirection.ltr,
  )..layout();
  var x = at.dx;
  if (x + painter.width > size.width - 2) x = size.width - 2 - painter.width;
  if (x < 2) x = 2;
  final patch =
      Rect.fromLTWH(x - 2, at.dy - 1, painter.width + 4, painter.height + 2);
  canvas.drawRect(
      patch, Paint()..color = AppColors.cream.withValues(alpha: 0.9));
  painter.paint(canvas, Offset(x, at.dy));
}
