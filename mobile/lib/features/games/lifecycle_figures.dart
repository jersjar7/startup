import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// One option's cost, split into the stages of its life.
@immutable
class Option {
  const Option(this.name, this.stages);

  final String name;

  /// Build, operate, maintain, and take away, in that order.
  final List<int> stages;

  int get total => stages.fold(0, (a, b) => a + b);
}

/// The stage names, in the order they are drawn and lived.
const stageNames = <String>['build', 'operate', 'maintain', 'take away'];

/// Two options side by side, each split into what it costs at each stage.
///
/// A life-cycle assessment is not a slogan about being green, it is a longer
/// bar. The option that is cheapest to build is regularly not the cheapest to
/// own, and the only way to see that is to draw the whole life instead of the
/// first segment of it.
class StagesPainter extends CustomPainter {
  const StagesPainter({required this.options, this.revealed = false});

  final List<Option> options;
  final bool revealed;

  static const _padR = 14.0;

  /// The gutter is measured from the labels rather than guessed at. A fixed
  /// one clipped "Conventional" to "entional", which is worse than a narrow
  /// bar.
  double _gutter() {
    var widest = 0.0;
    for (final option in options) {
      final tp = TextPainter(
        text: TextSpan(
          text: option.name,
          style: AppTheme.mono(size: 11, color: AppColors.charcoal),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      if (tp.width > widest) widest = tp.width;
    }
    return widest + 14;
  }

  static const _colors = [
    Color(0xFFF5B731),
    Color(0xFF2D7A5F),
    Color(0xFF3B82B8),
    Color(0xFF8A7A62),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final padL = _gutter();
    final widest = options.map((o) => o.total).reduce((a, b) => a > b ? a : b);
    final scale = (size.width - padL - _padR) / (widest * 1.04);
    final rowH = (size.height - 34) / options.length;

    for (final (i, option) in options.indexed) {
      final y = 6 + rowH * i + rowH / 2;
      var x = padL;
      for (final (s, cost) in option.stages.indexed) {
        final w = cost * scale;
        canvas.drawRect(
          Rect.fromLTWH(x, y - 13, w, 26),
          Paint()..color = _colors[s].withValues(alpha: 0.55),
        );
        canvas.drawRect(
          Rect.fromLTWH(x, y - 13, w, 26),
          Paint()
            ..color = AppColors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
        x += w;
      }
      canvas.drawRect(
        Rect.fromLTWH(padL, y - 13, option.total * scale, 26),
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      _write(canvas, option.name, Offset(padL - 8, y - 6),
          color: AppColors.charcoal, align: -1);
      if (revealed) {
        _write(canvas, '${option.total}', Offset(x + 5, y - 6),
            color: AppColors.ink3, align: 1);
      }
    }

    // The key, along the bottom.
    var kx = padL;
    for (final (s, name) in stageNames.indexed) {
      canvas.drawRect(
        Rect.fromLTWH(kx, size.height - 16, 9, 9),
        Paint()..color = _colors[s].withValues(alpha: 0.55),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: name,
          style: AppTheme.mono(size: 9, color: AppColors.ink3),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(kx + 13, size.height - 17));
      kx += 17 + tp.width;
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
      text: TextSpan(text: text, style: AppTheme.mono(size: 11, color: color)),
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
  bool shouldRepaint(StagesPainter old) =>
      old.options != options || old.revealed != revealed;
}
