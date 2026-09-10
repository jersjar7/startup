import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// A project as its cash flows: what period, and how much. Money in is
/// positive and money out is negative, the way a diagram draws it.
///
/// Everything the rate-of-return items claim is worked out from here rather
/// than typed in beside it. A round cannot say fifteen percent and draw
/// twelve.
@immutable
class Project {
  const Project(this.name, this.flows);

  final String name;

  /// (period, amount) pairs. Period zero is today.
  final List<(int, double)> flows;

  double _at(double i, {required bool positive}) {
    var total = 0.0;
    for (final (n, a) in flows) {
      if (a > 0 != positive) continue;
      total += a.abs() / _pow(1 + i, n);
    }
    return total;
  }

  /// Present worth of everything coming in, at rate [i].
  double pwIn(double i) => _at(i, positive: true);

  /// Present worth of everything going out, at rate [i].
  double pwOut(double i) => _at(i, positive: false);

  double netPw(double i) => pwIn(i) - pwOut(i);

  /// Undiscounted, which is the number people mistake for the return.
  double get total {
    var sum = 0.0;
    for (final (_, a) in flows) {
      sum += a;
    }
    return sum;
  }

  int get lastPeriod {
    var last = 0;
    for (final (n, _) in flows) {
      if (n > last) last = n;
    }
    return last;
  }

  double get biggest {
    var most = 0.0;
    for (final (_, a) in flows) {
      if (a.abs() > most) most = a.abs();
    }
    return most;
  }

  /// The rate that drives net present worth to zero, found the way anybody
  /// without a solver finds it: by halving the interval until it stops moving.
  double get irr {
    var lo = 0.0;
    var hi = 3.0;
    for (var k = 0; k < 60; k++) {
      final mid = (lo + hi) / 2;
      if (netPw(mid) > 0) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return (lo + hi) / 2;
  }

  static double _pow(double base, int n) {
    var out = 1.0;
    for (var k = 0; k < n; k++) {
      out *= base;
    }
    return out;
  }
}

/// Two bars and a line: what the project's money is worth today coming in,
/// and what it is worth going out, at whatever rate is being tried.
///
/// This is the definition of a rate of return made visible. Raise the rate and
/// money arriving later is worth less today, so the top bar shrinks past the
/// line. The rate where the two ends meet is the answer, and at zero percent
/// the bars are the plain undiscounted totals, which is exactly the thing
/// people mistake the return for.
class BalancePainter extends CustomPainter {
  const BalancePainter({
    required this.project,
    required this.rate,
    required this.reference,
    required this.settled,
  });

  final Project project;

  /// The rate being tried, as a fraction.
  final double rate;

  /// What a full-width bar means, in money. Fixed for the whole round so the
  /// bars actually shrink instead of being redrawn to fit.
  final double reference;

  /// True once the round is answered, which is when the two ends get their
  /// color.
  final bool settled;

  static const _gap = 8.0;

  /// Measured, not guessed: the labels sit in a left gutter and the widest one
  /// sets it.
  static double get _padL {
    var widest = 0.0;
    for (final label in ['money in', 'money out']) {
      final w = _measure(label, AppColors.ink2).width;
      if (w > widest) widest = w;
    }
    return widest + 14;
  }

  static const _padR = 16.0;

  static TextPainter _measure(String text, Color color) => TextPainter(
        text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
        textDirection: TextDirection.ltr,
      )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    final padL = _padL;
    final full = size.width - padL - _padR;
    final inLen = project.pwIn(rate) / reference * full;
    final outLen = project.pwOut(rate) / reference * full;
    final height = 26.0;
    final top = (size.height - (height * 2 + _gap)) / 2;

    final rows = [
      ('money in', inLen, AppColors.forest),
      ('money out', outLen, AppColors.ink2),
    ];
    for (final (i, (label, len, color)) in rows.indexed) {
      final y = top + i * (height + _gap);
      final rect = Rect.fromLTWH(padL, y, len, height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(5)),
        Paint()..color = color.withValues(alpha: 0.28),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(5)),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3,
      );
      _measure(label, AppColors.ink2)
          .paint(canvas, Offset(padL - 8 - _measure(label, AppColors.ink2).width, y + 7));
    }

    // The line at the end of what goes out. Whether the top bar reaches it is
    // the entire question, so it is drawn hard and it runs past both bars.
    final x = padL + outLen;
    final matched = (inLen - outLen).abs() < 0.6;
    final lineColor = !settled
        ? AppColors.charcoal
        : (matched ? AppColors.forest : AppColors.error);
    final path = Path();
    for (var y = top - 10.0; y < top + height * 2 + _gap + 10; y += 6) {
      path
        ..moveTo(x, y)
        ..lineTo(x, y + 3.5);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  @override
  bool shouldRepaint(BalancePainter old) =>
      old.rate != rate || old.project != project || old.settled != settled;
}

/// A cash flow diagram with the amounts written on the arrows, drawn to a
/// scale somebody else chose.
///
/// The scale is the point. Two projects drawn each to its own tallest arrow
/// look identical whatever the numbers are, and the question in front of the
/// student is which of the two earns more, so the pictures have to be
/// comparable.
class DealPainter extends CustomPainter {
  const DealPainter({
    required this.project,
    required this.periods,
    required this.scale,
    required this.color,
  });

  final Project project;

  /// How far the axis runs, so two diagrams can share a time span as well.
  final int periods;

  /// The amount a full-height arrow means.
  final double scale;

  final Color color;

  static const _padL = 26.0;
  static const _padR = 44.0;

  double _x(Size size, int period) =>
      _padL + period / periods * (size.width - _padL - _padR);

  @override
  void paint(Canvas canvas, Size size) {
    // Half and half. The arrows go both ways and sizing the room from the
    // space above the line alone sent every cost off the bottom of the box.
    final axis = size.height * 0.5;
    final below = size.height - axis;
    final room = (axis < below ? axis : below) - 16;

    canvas.drawLine(
      Offset(_padL, axis),
      Offset(size.width - _padR, axis),
      Paint()
        ..color = color
        ..strokeWidth = 1.5,
    );
    for (var i = 0; i <= periods; i++) {
      final x = _x(size, i);
      canvas.drawLine(
        Offset(x, axis - 3),
        Offset(x, axis + 3),
        Paint()
          ..color = color
          ..strokeWidth = 1,
      );
    }
    _write(canvas, 'year $periods', Offset(size.width - 4, axis + 5),
        AppColors.ink3, align: -1, limit: size.width);

    for (final (n, a) in project.flows) {
      final x = _x(size, n);
      final len = a.abs() / scale * room;
      final up = a > 0;
      final tip = up ? axis - len : axis + len;
      canvas.drawLine(
        Offset(x, axis),
        Offset(x, tip),
        Paint()
          ..color = color
          ..strokeWidth = 1.8,
      );
      final head = Path()
        ..moveTo(x, tip)
        ..lineTo(x - 4, tip + (up ? 8 : -8))
        ..lineTo(x + 4, tip + (up ? 8 : -8))
        ..close();
      canvas.drawPath(head, Paint()..color = color);
      _write(
        canvas,
        _money(a.abs()),
        Offset(x, up ? tip - 14 : tip + 4),
        color,
        limit: size.width,
      );
    }
  }

  static String _money(double v) {
    final s = v.round().toString();
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }

  void _write(Canvas canvas, String text, Offset at, Color color,
      {int align = 0, double limit = 0}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = switch (align) {
      1 => 0.0,
      -1 => tp.width,
      _ => tp.width / 2,
    };
    var x = at.dx - dx;
    if (x < 2) x = 2;
    if (limit > 0 && x + tp.width > limit - 2) x = limit - 2 - tp.width;
    tp.paint(canvas, Offset(x, at.dy));
  }

  @override
  bool shouldRepaint(DealPainter old) =>
      old.project != project || old.color != color || old.scale != scale;
}
