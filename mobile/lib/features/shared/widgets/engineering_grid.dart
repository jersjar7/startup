import 'package:flutter/material.dart';

/// The sage-green engineering-paper grid the website draws behind exercises.
/// A faint fine grid plus a stronger major grid on an off-white base. Wraps a
/// child; used behind exercise cards and the exercise screen.
class EngineeringGrid extends StatelessWidget {
  const EngineeringGrid({
    super.key,
    required this.child,
    this.minor = 8,
    this.major = 40,
  });

  final Widget child;
  final double minor;
  final double major;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(minor: minor, major: major),
      child: child,
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.minor, required this.major});

  final double minor;
  final double major;

  static const _sage = Color(0xFF64A08C); // rgb(100,160,140)

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFFDFCF8));

    void grid(double step, double opacity) {
      final p = Paint()
        ..color = _sage.withValues(alpha: opacity)
        ..strokeWidth = 1;
      for (double x = 0; x <= size.width; x += step) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
      }
      for (double y = 0; y <= size.height; y += step) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
      }
    }

    grid(minor, 0.05);
    grid(major, 0.10);
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.minor != minor || old.major != major;
}
