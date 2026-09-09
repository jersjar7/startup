import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// One arrow on a cash flow diagram.
@immutable
class CashFlow {
  const CashFlow(this.period, this.size, {this.unknown = false});

  /// Which period it lands in. Zero is today.
  final int period;

  /// How tall the arrow is drawn, in the diagram's own units. Positive points
  /// up and negative points down, the way every textbook draws them.
  final double size;

  /// Drawn hollow, with a question mark. This is what the round is asking for.
  final bool unknown;
}

/// A cash flow diagram: a line of periods with arrows on it.
///
/// Choosing an interest factor is not arithmetic, it is reading a picture.
/// What have you got, and what do you want instead: a single amount, an equal
/// series, or a series that grows. Once the diagram is in front of somebody
/// the factor names stop being six pieces of notation to memorise and become
/// six answers to the same question.
class CashFlowPainter extends CustomPainter {
  const CashFlowPainter({
    required this.flows,
    required this.periods,
    this.unit = '',
  });

  final List<CashFlow> flows;

  /// How many periods the axis runs for, past today.
  final int periods;

  /// What one period is called, written under the far end.
  final String unit;

  static const _padL = 22.0;

  /// Wide enough on the right for the unit to sit clear of the last arrow.
  static const _padR = 46.0;

  double _x(Size size, num period) =>
      _padL + period / periods * (size.width - _padL - _padR);

  @override
  void paint(Canvas canvas, Size size) {
    // The axis sits wherever the arrows leave room. A diagram of nothing but
    // costs was leaving the top two thirds of the box empty and drawing the
    // arrows too short to compare.
    final anyUp = flows.any((f) => f.size > 0);
    final anyDown = flows.any((f) => f.size < 0);
    final axis = size.height *
        (anyUp && anyDown ? 0.55 : (anyUp ? 0.78 : 0.30));
    final tallest = flows
        .map((f) => f.size.abs())
        .fold<double>(1, (a, b) => a > b ? a : b);
    final room = (anyUp ? axis : size.height - axis) - 22;

    canvas.drawLine(
      Offset(_padL, axis),
      Offset(size.width - _padR, axis),
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 1.6,
    );

    // Ticks. Past a dozen periods they stop being countable and start being
    // noise, so only the ends are marked.
    final ticks = periods <= 12
        ? [for (var i = 0; i <= periods; i++) i]
        : [0, periods];
    for (final i in ticks) {
      final x = _x(size, i);
      canvas.drawLine(
        Offset(x, axis - 3),
        Offset(x, axis + 3),
        Paint()
          ..color = AppColors.ink2
          ..strokeWidth = 1,
      );
      if (i == 0 || i == periods) {
        // On a diagram of nothing but costs the arrows own the space under
        // the line, so the numbers go over it instead.
        _write(
          canvas,
          '$i',
          Offset(x, anyUp ? axis + 6 : axis - 15),
          color: AppColors.ink3,
        );
      }
    }
    if (unit.isNotEmpty) {
      // In the right margin, past the last tick. Beside the final period
      // number it ran into it and came out as "10year".
      _write(
        canvas,
        unit,
        Offset(size.width - 4, axis + 6),
        color: AppColors.ink3,
        align: -1,
      );
    }

    for (final flow in flows) {
      final x = _x(size, flow.period);
      final len = flow.size.abs() / tallest * room;
      final up = flow.size > 0;
      final tip = up ? axis - len : axis + len;
      final color = flow.unknown ? AppColors.ember : AppColors.charcoal;

      canvas.drawLine(
        Offset(x, axis),
        Offset(x, tip),
        Paint()
          ..color = color
          ..strokeWidth = flow.unknown ? 2 : 1.8,
      );
      final head = Path()
        ..moveTo(x, tip)
        ..lineTo(x - 4, tip + (up ? 8 : -8))
        ..lineTo(x + 4, tip + (up ? 8 : -8))
        ..close();
      canvas.drawPath(
        head,
        flow.unknown
            ? (Paint()..color = AppColors.cream)
            : (Paint()..color = color),
      );
      if (flow.unknown) {
        canvas.drawPath(
          head,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
        _write(
          canvas,
          '?',
          Offset(x, up ? tip - 14 : tip + 3),
          color: color,
        );
      }
    }
  }

  void _write(
    Canvas canvas,
    String text,
    Offset at, {
    required Color color,
    int align = 0,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = switch (align) {
      1 => 0.0,
      -1 => tp.width,
      _ => tp.width / 2,
    };
    tp.paint(canvas, at - Offset(dx, 0));
  }

  @override
  bool shouldRepaint(CashFlowPainter old) =>
      old.flows != flows || old.periods != periods;
}
