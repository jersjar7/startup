import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// How two events sit against each other.
enum Link {
  /// They cannot both happen, so there is no overlap to subtract.
  exclusive,

  /// One happening tells you nothing about the other.
  independent,

  /// One happening changes the odds of the other.
  dependent,
}

/// Two events, described by the facts that decide their relationship rather
/// than by the relationship itself.
@immutable
class Pairing {
  const Pairing({
    required this.oneTrial,
    required this.canCoexist,
    required this.firstChangesSecond,
  });

  /// Both events describe the same single trial: one roll, one sample, one
  /// specimen.
  final bool oneTrial;

  /// Whether both could be true at once.
  final bool canCoexist;

  /// Whether the first happening changes what is left for the second.
  final bool firstChangesSecond;

  /// Worked out from those three, never declared beside the round.
  Link get link {
    if (oneTrial && !canCoexist) return Link.exclusive;
    return firstChangesSecond ? Link.dependent : Link.independent;
  }
}

/// Two circles showing what a relationship means, and the rule it licenses.
///
/// Drawn only once the round is answered. Shown beforehand it would hand over
/// the whole question, because the picture IS the answer.
class VennPainter extends CustomPainter {
  const VennPainter({
    required this.link,
    required this.left,
    required this.right,
  });

  final Link link;
  final String left;
  final String right;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width * 0.22, size.height * 0.34);
    final mid = Offset(size.width / 2, size.height * 0.44);
    // Exclusive circles stand apart; the other two overlap, because they can
    // both happen.
    final gap = link == Link.exclusive ? r * 1.25 : r * 0.62;
    final a = mid - Offset(gap, 0);
    final b = mid + Offset(gap, 0);

    for (final (at, tone, label) in [
      (a, AppColors.emberBg, left),
      (b, AppColors.sunbeamBg, right),
    ]) {
      canvas.drawCircle(at, r, Paint()..color = tone.withValues(alpha: 0.75));
      canvas.drawCircle(
        at,
        r,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
      _write(canvas, label, Offset(at.dx, mid.dy + r + 8), AppColors.ink3,
          size);
    }

    if (link != Link.exclusive) {
      // The lens where both happen, which is the term the addition rule takes
      // back off.
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: a, radius: r)));
      canvas.drawCircle(b, r, Paint()..color = AppColors.forestBg);
      canvas.drawCircle(
        b,
        r,
        Paint()
          ..color = AppColors.forest
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
      canvas.restore();
      _write(canvas, 'both', Offset(mid.dx, mid.dy - 7), AppColors.forest,
          size);
    } else {
      _write(canvas, 'no overlap', Offset(mid.dx, mid.dy - 7), AppColors.ink3,
          size);
    }

    _write(canvas, _rule, Offset(size.width / 2, size.height - 20),
        AppColors.charcoal, size);
  }

  String get _rule => switch (link) {
        Link.exclusive => 'P(A or B) = P(A) + P(B)',
        Link.independent => 'P(A and B) = P(A) x P(B)',
        Link.dependent => 'P(A and B) = P(A) x P(B given A)',
      };

  void _write(Canvas canvas, String text, Offset at, Color colour, Size size) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 11, color: colour)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 8);
    var x = at.dx - tp.width / 2;
    if (x < 2) x = 2;
    if (x + tp.width > size.width - 2) x = size.width - 2 - tp.width;
    canvas.drawRect(
      Rect.fromLTWH(x - 3, at.dy, tp.width + 6, tp.height),
      Paint()..color = AppColors.cream.withValues(alpha: 0.92),
    );
    tp.paint(canvas, Offset(x, at.dy));
  }

  @override
  bool shouldRepaint(VennPainter old) => old.link != link;
}
