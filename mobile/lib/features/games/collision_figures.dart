import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';

/// Two bodies meeting head on.
///
/// The speeds after are worked out from the two before it and the coefficient
/// of restitution, so a round declares the crash and the drawing, the answers
/// and the conservation checks all follow from the same numbers.
@immutable
class Crash {
  const Crash({
    required this.massA,
    required this.massB,
    required this.speedA,
    this.speedB = 0,
    required this.e,
  });

  /// Kilograms, and speeds in meters a second, positive to the right.
  final double massA;
  final double massB;
  final double speedA;
  final double speedB;

  /// One for a perfect bounce, nothing for a perfect stick.
  final double e;

  double get momentum => massA * speedA + massB * speedB;

  /// Standard result of the two equations: momentum across the pair, and the
  /// restitution relation between the two speeds.
  double get afterA =>
      (massA * speedA +
          massB * speedB +
          massB * e * (speedB - speedA)) /
      (massA + massB);

  double get afterB =>
      (massA * speedA +
          massB * speedB +
          massA * e * (speedA - speedB)) /
      (massA + massB);

  double get energyBefore =>
      0.5 * massA * speedA * speedA + 0.5 * massB * speedB * speedB;

  double get energyAfter =>
      0.5 * massA * afterA * afterA + 0.5 * massB * afterB * afterB;

  /// Momentum is conserved in every one of these, which is the point.
  bool get momentumKept =>
      (massA * afterA + massB * afterB - momentum).abs() < 1e-6;

  /// Energy only survives a perfect bounce.
  bool get energyKept => (energyAfter - energyBefore).abs() < 1e-6;

  bool get sticks => e == 0;
}

/// Two blocks with their speeds, before and after.
class CrashPainter extends CustomPainter {
  const CrashPainter({required this.crash, this.showAfter = false});

  final Crash crash;

  /// Draw the second row, what happens after the bang.
  final bool showAfter;

  @override
  void paint(Canvas canvas, Size size) {
    final rows = showAfter ? 2 : 1;
    for (var row = 0; row < rows; row++) {
      final y = rows == 1
          ? size.height / 2
          : size.height * (row == 0 ? 0.3 : 0.72);
      final after = row == 1;
      final speedA = after ? crash.afterA : crash.speedA;
      final speedB = after ? crash.afterB : crash.speedB;
      // Stuck together, the two are drawn touching. Otherwise they are set
      // far enough apart for the first one's speed arrow to finish before the
      // second one starts: at a smaller gap the arrow ran through block B and
      // the number landed on top of it.
      final gap = after && crash.sticks ? 0.0 : 46.0;
      final aX = size.width * 0.3;
      final bX =
          aX + _widthOf(crash.massA) / 2 + gap + _widthOf(crash.massB) / 2;

      // The road they run along, so the two are travelling on something
      // rather than floating in the panel.
      groundLine(canvas, Offset(6, y + 11), Offset(size.width - 6, y + 11),
          color: AppColors.ink3);
      _block(canvas, Offset(aX, y), crash.massA, 'A', speedA);
      _block(canvas, Offset(bX, y), crash.massB, 'B', speedB);
      _write(canvas, after ? 'after' : 'before', Offset(6, y - 8),
          AppColors.ink3);
    }
    viewTag(canvas, size, Looking.elevation);
  }

  double _widthOf(double mass) =>
      (18 + math.sqrt(mass) * 2.2).clamp(22.0, 46.0);

  void _block(Canvas canvas, Offset at, double mass, String name,
      double speed) {
    final w = _widthOf(mass);
    const h = 22.0;
    final rect = Rect.fromCenter(center: at, width: w, height: h);
    canvas
      ..drawRect(rect, Paint()..color = AppColors.info.withValues(alpha: 0.25))
      ..drawRect(
        rect,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    _write(canvas, name, at + const Offset(-3, -6), AppColors.charcoal);

    if (speed.abs() > 0.01) {
      final from = Offset(at.dx + (speed > 0 ? w / 2 + 3 : -w / 2 - 3), at.dy);
      final to = from + Offset(speed.sign * math.min(speed.abs() * 3 + 8, 34), 0);
      final paint = Paint()
        ..color = AppColors.ember
        ..strokeWidth = 2;
      canvas.drawLine(from, to, paint);
      final unit = Offset(speed.sign, 0);
      canvas.drawPath(
        Path()
          ..moveTo(to.dx, to.dy)
          ..lineTo(to.dx - unit.dx * 8, to.dy - 4)
          ..lineTo(to.dx - unit.dx * 8, to.dy + 4)
          ..close(),
        Paint()..color = AppColors.ember,
      );
      // Above the middle of the arrow, so it never sits on whatever the
      // arrow is pointing at.
      _write(
        canvas,
        speed.abs().toStringAsFixed(speed.abs() < 10 ? 1 : 0),
        Offset((from.dx + to.dx) / 2 - 6, at.dy - 20),
        AppColors.ember,
      );
    } else {
      _write(canvas, 'at rest', at + const Offset(-12, 14), AppColors.ink3);
    }
  }

  void _write(Canvas canvas, String text, Offset at, Color color) {
    TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, at);
  }

  @override
  bool shouldRepaint(CrashPainter old) =>
      old.crash != crash || old.showAfter != showAfter;
}

/// A force that acts for a while: how hard, and for how long.
///
/// The area under it is the impulse, and two pulses with the same area do the
/// same thing to a body's momentum however different they look.
@immutable
class Pulse {
  const Pulse({required this.force, required this.seconds, required this.label});

  final double force;
  final double seconds;
  final String label;

  double get impulse => force * seconds;
}

/// Two pulses drawn on one pair of axes, to be compared.
class PulsePainter extends CustomPainter {
  const PulsePainter({
    required this.pulse,
    required this.tallest,
    required this.longest,
    this.tone = AppColors.info,
  });

  final Pulse pulse;

  /// The biggest force and the longest time any pulse in the row reaches, so
  /// they share one pair of axes.
  final double tallest;
  final double longest;

  final Color tone;

  static const _padL = 26.0;
  static const _padB = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    final floor = size.height - _padB;
    final room = size.height - _padB - 14;
    final wide = size.width - _padL - 12;

    canvas
      ..drawLine(Offset(_padL, floor), Offset(size.width - 8, floor),
          Paint()..color = AppColors.ink3..strokeWidth = 1)
      ..drawLine(Offset(_padL, floor), Offset(_padL, 10),
          Paint()..color = AppColors.ink3..strokeWidth = 1);

    final w = pulse.seconds / longest * wide;
    final h = pulse.force / tallest * room;
    final rect = Rect.fromLTWH(_padL, floor - h, w, h);
    canvas
      ..drawRect(rect, Paint()..color = tone.withValues(alpha: 0.3))
      ..drawRect(
        rect,
        Paint()
          ..color = tone
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

    _write(canvas, 'force', const Offset(2, 2), AppColors.ink3);
    _write(canvas, 'time', Offset(size.width - 34, floor + 4), AppColors.ink3);
    _write(canvas, pulse.label, Offset(_padL + 4, floor - h - 13), tone);
  }

  void _write(Canvas canvas, String text, Offset at, Color color) {
    TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 9.5, color: color)),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, at);
  }

  @override
  bool shouldRepaint(PulsePainter old) =>
      old.pulse != pulse || old.tallest != tallest || old.longest != longest;
}
