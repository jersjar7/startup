import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// The raccoon from the app icon, peeking over an edge: ears, the top of
/// the head, the mask and the nose, nothing below. Drawn rather than cut
/// from the icon so it stays crisp at any size and can take other colors
/// later without new artwork.
///
/// It is the only pose the mascot has. Place its bottom edge on the top of
/// whatever it peeks over: the nose rests on that edge, as it rests on the
/// 4 in the icon.
class RaccoonPeek extends StatelessWidget {
  const RaccoonPeek({super.key});

  static const width = 80.0;
  static const height = width * _RaccoonPainter.aspect;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'The FE for Raccoons raccoon',
      child: const SizedBox(
        width: width,
        height: height,
        child: CustomPaint(painter: _RaccoonPainter()),
      ),
    );
  }
}

class _RaccoonPainter extends CustomPainter {
  const _RaccoonPainter();

  /// Designed on a 120 by 62 box.
  static const _w = 120.0;
  static const _h = 62.0;
  static const aspect = _h / _w;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _w, size.height / _h);

    final fur = Paint()..color = AppColors.cream;
    final mask = Paint()..color = AppColors.charcoal;

    Path tri(Offset a, Offset b, Offset c) => Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..close();

    // Ears, outer then inner, each side mirrored.
    canvas
      ..drawPath(
        tri(const Offset(15, 44), const Offset(20, 0), const Offset(50, 22)),
        fur,
      )
      ..drawPath(
        tri(const Offset(22, 26), const Offset(25, 9), const Offset(40, 21)),
        mask,
      )
      ..drawPath(
        tri(const Offset(105, 44), const Offset(100, 0), const Offset(70, 22)),
        fur,
      )
      ..drawPath(
        tri(const Offset(98, 26), const Offset(95, 9), const Offset(80, 21)),
        mask,
      );

    final head = Path()
      ..moveTo(4, _h)
      ..cubicTo(18, 14, 102, 14, 116, _h)
      ..close();
    canvas.drawPath(head, fur);

    // The mask: a lobe round each eye, running down to the edge, with the
    // snout left light between them so the nose reads, as in the icon.
    Path lobe(double dir) {
      double x(double v) => dir > 0 ? v : _w - v;
      return Path()
        ..moveTo(x(8), _h)
        ..cubicTo(x(12), 34, x(44), 28, x(55), 44)
        ..cubicTo(x(50), 50, x(46), 56, x(45), _h)
        ..close();
    }

    canvas
      ..save()
      ..clipPath(head)
      ..drawPath(lobe(1), mask)
      ..drawPath(lobe(-1), mask)
      ..restore()
      ..drawCircle(const Offset(35, 46), 4, fur)
      ..drawCircle(const Offset(85, 46), 4, fur)
      ..drawOval(
        Rect.fromCenter(center: const Offset(60, 57), width: 16, height: 10),
        mask,
      );
  }

  @override
  bool shouldRepaint(_RaccoonPainter oldDelegate) => false;
}
