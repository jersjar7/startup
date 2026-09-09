import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// One alternative's cost line: a fixed amount plus a rate per unit.
@immutable
class CostLine {
  const CostLine(this.name, this.fixed, this.variable);

  final String name;

  /// What it costs before a single unit is produced.
  final double fixed;

  /// What each unit adds.
  final double variable;

  double at(double q) => fixed + variable * q;
}

/// Two cost lines over a volume axis, with a volume marked on it.
///
/// A break-even question is two straight lines and the place they cross, and
/// the algebra hides both. Drawn out, the whole topic becomes obvious: the
/// steeper line starts lower, the flatter one starts higher, and which is
/// cheaper depends entirely on which side of the crossing you are standing.
/// A pair that never crosses looks different enough that nobody looks for a
/// break-even volume that is not there.
class BreakEvenPainter extends CustomPainter {
  const BreakEvenPainter({
    required this.lines,
    required this.qTo,
    required this.at,
    this.revealed = false,
  });

  final List<CostLine> lines;

  /// The right-hand end of the volume axis.
  final double qTo;

  /// The volume the round is asking about.
  final double at;

  /// Once answered, the crossing gets a mark of its own.
  final bool revealed;

  static const _padL = 26.0;
  static const _padT = 14.0;
  static const _padB = 26.0;

  /// Measured from the line names. A fixed gutter clipped "Option A" to
  /// "Option" and "On site" to "On sit", which is the third painter in this
  /// app to learn the same lesson.
  double get _padR {
    var widest = 0.0;
    for (final line in lines) {
      final tp = TextPainter(
        text: TextSpan(
          text: line.name,
          style: AppTheme.mono(size: 10, color: AppColors.charcoal),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      if (tp.width > widest) widest = tp.width;
    }
    return widest + 12;
  }

  static const _colors = [AppColors.sunbeam, AppColors.forest];

  /// Where the two lines meet, or null when they never do.
  double? get crossing {
    final dv = lines[0].variable - lines[1].variable;
    if (dv == 0) return null;
    final q = (lines[1].fixed - lines[0].fixed) / dv;
    return q > 0 && q < qTo ? q : null;
  }

  double _top() {
    var tallest = 0.0;
    for (final line in lines) {
      final v = line.at(qTo);
      if (v > tallest) tallest = v;
    }
    return tallest * 1.08;
  }

  double _x(Size size, double q) =>
      _padL + q / qTo * (size.width - _padL - _padR);

  double _y(Size size, double cost) =>
      size.height - _padB - cost / _top() * (size.height - _padB - _padT);

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = AppColors.ink2
      ..strokeWidth = 1.4;
    canvas.drawLine(
      Offset(_padL, size.height - _padB),
      Offset(size.width - _padR, size.height - _padB),
      axis,
    );
    canvas.drawLine(
      Offset(_padL, size.height - _padB),
      Offset(_padL, _padT),
      axis,
    );

    for (final (i, line) in lines.indexed) {
      canvas.drawLine(
        Offset(_x(size, 0), _y(size, line.at(0))),
        Offset(_x(size, qTo), _y(size, line.at(qTo))),
        Paint()
          ..color = _colors[i]
          ..strokeWidth = 2.6,
      );
      _write(
        canvas,
        line.name,
        Offset(_x(size, qTo) + 5, _y(size, line.at(qTo)) - 5),
        color: _colors[i],
        align: 1,
      );
    }

    final cross = crossing;
    if (cross != null && revealed) {
      final cx = _x(size, cross);
      final cy = _y(size, lines[0].at(cross));
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx, size.height - _padB),
        Paint()
          ..color = AppColors.ink3
          ..strokeWidth = 1.2,
      );
      canvas.drawCircle(Offset(cx, cy), 5, Paint()..color = AppColors.charcoal);
      _write(
        canvas,
        'break even',
        Offset(cx, _padT - 2),
        color: AppColors.ink3,
      );
    }

    // The volume being asked about.
    final ax = _x(size, at);
    canvas.drawLine(
      Offset(ax, _padT),
      Offset(ax, size.height - _padB + 4),
      Paint()
        ..color = AppColors.ember
        ..strokeWidth = 2,
    );
    _write(
      canvas,
      'here',
      Offset(ax, size.height - _padB + 6),
      color: AppColors.ember,
    );

    _write(
      canvas,
      'volume',
      Offset(size.width - 4, size.height - _padB + 6),
      color: AppColors.ink3,
      align: -1,
    );
    _write(
      canvas,
      'cost',
      const Offset(2, _padT - 12),
      color: AppColors.ink3,
      align: 1,
    );
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
  bool shouldRepaint(BreakEvenPainter old) =>
      old.lines != lines || old.at != at || old.revealed != revealed;
}
