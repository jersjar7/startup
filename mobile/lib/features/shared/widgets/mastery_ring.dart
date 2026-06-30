import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// A small progress ring colored by mastery (forest/sunbeam/ember/neutral),
/// with the percent in JetBrains Mono in the center. Used on the chapter list,
/// chapter header, and onboarding preview.
class MasteryRing extends StatelessWidget {
  const MasteryRing({super.key, required this.pct, this.size = 42, this.stroke = 4.5});

  final int pct;
  final double size;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(pct: pct, stroke: stroke),
        child: Center(
          child: Text(
            '$pct',
            style: AppTheme.mono(
              size: size * 0.26,
              weight: FontWeight.w700,
              color: pct > 0 ? AppColors.charcoal : AppColors.ink3,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.pct, required this.stroke});

  final int pct;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFFF0E7D8);
    canvas.drawCircle(center, radius, track);

    if (pct > 0) {
      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = AppColors.masteryColor(pct);
      final sweep = (pct.clamp(0, 100) / 100) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweep,
        false,
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.pct != pct || old.stroke != stroke;
}
