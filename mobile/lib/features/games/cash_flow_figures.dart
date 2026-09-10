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
/// the factor names stop being six pieces of notation to memorize and become
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
    }
    if (unit.isNotEmpty) {
      // In the right margin, past the last tick. Beside the final period
      // number it ran into it and came out as "10year".
      _write(
        canvas,
        unit,
        Offset(size.width - 4, anyUp ? axis + 6 : axis - 15),
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

    // The end numbers go on last, on a patch of canvas and nudged off the
    // tick. An arrow standing at the first or last period runs its shaft
    // straight through the number for that period, and drawing the number
    // first only put it underneath.
    for (final i in [0, periods]) {
      // On a diagram of nothing but costs the arrows own the space under the
      // line, so the numbers go over it instead.
      _write(
        canvas,
        '$i',
        Offset(_x(size, i) - 9, anyUp ? axis + 6 : axis - 15),
        color: AppColors.ink3,
        patch: true,
      );
    }
  }

  void _write(
    Canvas canvas,
    String text,
    Offset at, {
    required Color color,
    int align = 0,
    bool patch = false,
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
    final at2 = at - Offset(dx, 0);
    if (patch) {
      canvas.drawRect(
        Rect.fromLTWH(at2.dx - 2, at2.dy, tp.width + 4, tp.height),
        Paint()..color = AppColors.cream.withValues(alpha: 0.92),
      );
    }
    tp.paint(canvas, at2);
  }

  @override
  bool shouldRepaint(CashFlowPainter old) =>
      old.flows != flows || old.periods != periods;
}

/// Two alternatives with different lives, laid on the same timeline.
///
/// Comparing a six year pump against a four year one by present worth is the
/// most common way to get an economics question wrong, and the reason is
/// invisible in algebra: the two are being priced over different amounts of
/// time. Drawn as blocks that repeat until they end together, the least common
/// multiple stops being a rule and becomes the point at which the picture
/// finally lines up.
class LivesPainter extends CustomPainter {
  const LivesPainter({
    required this.lifeA,
    required this.lifeB,
    required this.span,
    required this.nameA,
    required this.nameB,
    this.bracket,
  });

  final int lifeA;
  final int lifeB;

  /// How far the timeline runs.
  final int span;

  final String nameA;
  final String nameB;

  /// A study period to mark, when the round has settled on one.
  final int? bracket;

  static const _padR = 14.0;

  /// Measured from the names rather than guessed at, which is what stopped
  /// "Option A" arriving as "ption A".
  double get _padL {
    var widest = 0.0;
    for (final name in [nameA, nameB]) {
      final tp = TextPainter(
        text: TextSpan(
          text: name,
          style: AppTheme.mono(size: 10, color: AppColors.charcoal),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      if (tp.width > widest) widest = tp.width;
    }
    return widest + 14;
  }

  double _x(Size size, num year) =>
      _padL + year / span * (size.width - _padL - _padR);

  @override
  void paint(Canvas canvas, Size size) {
    final rows = [(lifeA, nameA, AppColors.sunbeam), (lifeB, nameB, AppColors.forest)];
    for (final (i, (life, name, color)) in rows.indexed) {
      final y = 22 + i * 34.0;
      // One block per replacement, laid end to end until the timeline runs
      // out. A part-block at the end is what an awkward study period looks
      // like, and it is drawn rather than hidden.
      var start = 0;
      while (start < span) {
        final end = start + life < span ? start + life : span;
        final rect = Rect.fromLTRB(
          _x(size, start) + 1,
          y - 11,
          _x(size, end) - 1,
          y + 11,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(5)),
          Paint()..color = color.withValues(alpha: 0.45),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(5)),
          Paint()
            ..color = AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = start + life <= span ? 1.3 : 1,
        );
        start += life;
      }
      _write(canvas, name, Offset(_padL - 8, y - 6),
          color: AppColors.charcoal, align: -1);
    }

    final axisY = 22 + rows.length * 34.0 - 4;
    canvas.drawLine(
      Offset(_padL, axisY),
      Offset(size.width - _padR, axisY),
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 1.4,
    );
    for (var t = 0; t <= span; t += span > 14 ? 4 : 2) {
      final x = _x(size, t);
      canvas.drawLine(
        Offset(x, axisY - 3),
        Offset(x, axisY + 3),
        Paint()
          ..color = AppColors.ink2
          ..strokeWidth = 1,
      );
      _write(canvas, '$t', Offset(x, axisY + 5), color: AppColors.ink3);
    }

    final mark = bracket;
    if (mark != null) {
      final x = _x(size, mark);
      canvas.drawLine(
        Offset(x, 6),
        Offset(x, axisY),
        Paint()
          ..color = AppColors.ember
          ..strokeWidth = 2,
      );
      _write(canvas, 'compare to here', Offset(x - 4, 4),
          color: AppColors.ember, align: -1);
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
  bool shouldRepaint(LivesPainter old) =>
      old.lifeA != lifeA || old.lifeB != lifeB || old.bracket != bracket;
}

/// When a payment actually lands, worked out from how the sentence phrased it.
///
/// The lesson's convention warning is that the end of one year and the
/// beginning of the next are the SAME instant on the diagram. Getting it wrong
/// shifts every factor by a period, and the arithmetic afterwards is perfect.
@immutable
class Moment {
  const Moment({required this.year, required this.atEnd});

  final int year;

  /// True for "at the end of year n", false for "at the beginning of".
  final bool atEnd;

  /// The end of year n is period n. The beginning of year n is the end of
  /// year n minus one, so it is period n minus one, and the beginning of year
  /// one is today.
  int get period => atEnd ? year : year - 1;
}

/// A bare timeline with the periods marked, for pointing at one of them.
class TimelinePainter extends CustomPainter {
  const TimelinePainter({
    required this.periods,
    this.picked,
    this.truth = -1,
    this.locked = false,
  });

  final int periods;
  final int? picked;
  final int truth;
  final bool locked;

  static const _padL = 30.0;
  static const _padR = 30.0;

  /// Where a period sits across the figure, so a tap target can be put on it.
  static double xFor(Size size, int periods, int period) =>
      _padL + period / periods * (size.width - _padL - _padR);

  static double axisFor(Size size) => size.height * 0.52;

  @override
  void paint(Canvas canvas, Size size) {
    final axis = axisFor(size);
    canvas.drawLine(
      Offset(_padL - 12, axis),
      Offset(size.width - _padR + 12, axis),
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 2,
    );

    for (var p = 0; p <= periods; p++) {
      final x = xFor(size, periods, p);
      final chosen = picked == p;
      final right = locked && p == truth;
      final Color colour;
      if (right) {
        colour = AppColors.forest;
      } else if (locked && chosen) {
        colour = AppColors.error;
      } else if (chosen) {
        colour = AppColors.ember;
      } else {
        colour = AppColors.ink3;
      }

      canvas.drawLine(Offset(x, axis - 7), Offset(x, axis + 7),
          Paint()
            ..color = colour
            ..strokeWidth = chosen || right ? 3 : 1.8);

      // The arrow only appears once the round is answered, on the period the
      // payment really belongs to.
      if (right || chosen) {
        final tip = Offset(x, axis - 54);
        canvas.drawLine(Offset(x, axis - 8), tip,
            Paint()
              ..color = colour
              ..strokeWidth = 3
              ..strokeCap = StrokeCap.round);
        canvas.drawPath(
          Path()
            ..moveTo(tip.dx, tip.dy)
            ..lineTo(tip.dx - 5.5, tip.dy + 11)
            ..lineTo(tip.dx + 5.5, tip.dy + 11)
            ..close(),
          Paint()..color = colour,
        );
      }

      _write(canvas, '$p', Offset(x, axis + 12), colour, size);
      if (p > 0) {
        // The year each interval covers, so "year 3" and "period 3" can be
        // seen to be different things.
        final from = xFor(size, periods, p - 1);
        _write(canvas, 'yr $p', Offset((from + x) / 2, axis + 30),
            AppColors.ink2, size);
      }
    }
  }

  void _write(Canvas canvas, String text, Offset at, Color colour, Size size) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 11, color: colour)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx - tp.width / 2;
    if (x < 1) x = 1;
    if (x + tp.width > size.width - 1) x = size.width - 1 - tp.width;
    tp.paint(canvas, Offset(x, at.dy));
  }

  @override
  bool shouldRepaint(TimelinePainter old) =>
      old.picked != picked || old.locked != locked || old.periods != periods;
}
