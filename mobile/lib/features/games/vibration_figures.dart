import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// A mass on a spring, which is every vibration problem on this exam.
@immutable
class Bouncer {
  const Bouncer({required this.mass, required this.stiffness});

  /// Kilograms and newtons per meter.
  final double mass;
  final double stiffness;

  /// Radians a second, which is what the formula gives.
  double get omega => math.sqrt(stiffness / mass);

  /// Cycles a second, which is what a question usually wants.
  double get hertz => omega / (2 * math.pi);

  double get period => 1 / hertz;
}

/// How heavily a system is damped.
///
/// The undamped ideal is in here on purpose: every free vibration formula on
/// this page is written for it, and its curve is the one that never shrinks.
enum Damped { none, under, critical, over }

extension DampedWords on Damped {
  String get plain => switch (this) {
        Damped.none => 'Undamped: it swings and never shrinks',
        Damped.under => 'Underdamped: it swings and dies away',
        Damped.critical => 'Critically damped: back fastest, no swing',
        Damped.over => 'Overdamped: no swing, and slow about it',
      };

  /// A damping ratio that shows this behavior clearly.
  double get zeta => switch (this) {
        Damped.none => 0,
        Damped.under => 0.12,
        Damped.critical => 1,
        Damped.over => 3,
      };
}

/// What a system pulled aside and let go does next.
///
/// Standard results, not derived here: an underdamped system swings inside a
/// decaying envelope, a critically damped one returns without crossing, and
/// an overdamped one takes longer to do the same.
List<Offset> settleCurve(Damped damped, {int steps = 120, double span = 12}) {
  final out = <Offset>[];
  final z = damped.zeta;
  for (var i = 0; i <= steps; i++) {
    final t = span * i / steps;
    final double x;
    if (z == 0) {
      x = math.cos(t);
    } else if (z < 1) {
      final wd = math.sqrt(1 - z * z);
      x = math.exp(-z * t) *
          (math.cos(wd * t) + z / wd * math.sin(wd * t));
    } else if (z == 1) {
      x = (1 + t) * math.exp(-t);
    } else {
      final r = math.sqrt(z * z - 1);
      final a = -z + r;
      final b = -z - r;
      x = (b * math.exp(a * t) - a * math.exp(b * t)) / (b - a);
    }
    out.add(Offset(t, x));
  }
  return out;
}

/// The settling curve, drawn against time.
class SettlePainter extends CustomPainter {
  const SettlePainter({
    required this.damped,
    this.tone = AppColors.info,
    this.span = 12,
  });

  final Damped damped;
  final Color tone;
  final double span;

  static const _padL = 22.0;
  static const _padB = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    final middle = size.height / 2;
    final room = size.height / 2 - 12;
    final wide = size.width - _padL - 10;

    canvas
      ..drawLine(Offset(_padL, middle), Offset(size.width - 8, middle),
          Paint()..color = AppColors.ink3..strokeWidth = 1)
      ..drawLine(Offset(_padL, 8), Offset(_padL, size.height - _padB),
          Paint()..color = AppColors.ink3..strokeWidth = 1);

    final path = Path();
    final points = settleCurve(damped, span: span);
    for (var i = 0; i < points.length; i++) {
      final p = Offset(
        _padL + points[i].dx / span * wide,
        middle - points[i].dy * room,
      );
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = tone
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    _write(canvas, 'pulled aside', const Offset(2, 2), AppColors.ink3);
    _write(canvas, 'time', Offset(size.width - 30, middle + 4),
        AppColors.ink3);
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
  bool shouldRepaint(SettlePainter old) =>
      old.damped != damped || old.tone != tone;
}

/// A block hanging on a spring, drawn simply.
class SpringPainter extends CustomPainter {
  const SpringPainter({
    required this.bouncer,
    this.label = '',
    this.frame,
    this.pull,
  });

  final Bouncer bouncer;
  final String label;

  /// The heaviest mass and stiffest spring in the row, so a pair drawn side
  /// by side is drawn to one scale.
  final (double, double)? frame;

  /// How far this one was pulled aside before being let go, in the row's own
  /// units. Null means the round is not about that and nothing is drawn.
  final double? pull;

  @override
  void paint(Canvas canvas, Size size) {
    final heaviest = frame?.$1 ?? bouncer.mass;
    final stiffest = frame?.$2 ?? bouncer.stiffness;

    final top = 26.0;
    final x = size.width / 2;
    // A stiffer spring is drawn the way a stiffer spring looks: fewer turns
    // of heavier wire. More turns of thin wire is a SOFTER spring, so drawing
    // it the other way round would teach the wrong cue.
    final share = bouncer.stiffness / stiffest;
    final turns = (13 - 7 * math.sqrt(share)).round();
    final wire = 1.6 + 2.2 * math.sqrt(share);
    // A round that pulls one system further aside needs the room to show it.
    final rest = size.height * (pull == null ? 0.56 : 0.48);
    final springBottom = rest + (pull ?? 0) * 13;

    canvas.drawLine(
      Offset(x - 26, top),
      Offset(x + 26, top),
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 2,
    );
    for (var h = x - 22.0; h < x + 24; h += 8) {
      canvas.drawLine(
        Offset(h, top),
        Offset(h - 5, top - 6),
        Paint()
          ..color = AppColors.ink3
          ..strokeWidth = 1,
      );
    }

    final path = Path()..moveTo(x, top);
    final coilTop = top + 8;
    final coilHigh = springBottom - coilTop;
    for (var i = 0; i <= turns * 2; i++) {
      final t = i / (turns * 2);
      path.lineTo(x + (i.isEven ? -12 : 12), coilTop + coilHigh * t);
    }
    path.lineTo(x, springBottom);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.info
        ..style = PaintingStyle.stroke
        ..strokeWidth = wire,
    );

    // The block, sized by its mass against the heaviest in the row.
    final wide = 34 + 28 * math.sqrt(bouncer.mass / heaviest);
    final high = 22 + 14 * math.sqrt(bouncer.mass / heaviest);
    final rect = Rect.fromLTWH(
        x - wide / 2, springBottom, wide, high);
    canvas
      ..drawRect(rect, Paint()..color = AppColors.sunbeam.withValues(alpha: 0.35))
      ..drawRect(
        rect,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );

    if (pull != null) {
      // Where the block would hang if nobody had touched it, plus how far it
      // was dragged down from there.
      final dashed = Paint()
        ..color = AppColors.ink3
        ..strokeWidth = 1;
      for (var d = 8.0; d < size.width - 8; d += 9) {
        canvas.drawLine(Offset(d, rest), Offset(d + 5, rest), dashed);
      }
      final arrowX = x + wide / 2 + 10;
      canvas.drawLine(
        Offset(arrowX, rest),
        Offset(arrowX, springBottom),
        Paint()
          ..color = AppColors.ember
          ..strokeWidth = 2,
      );
      canvas.drawLine(Offset(arrowX, springBottom),
          Offset(arrowX - 4, springBottom - 6), Paint()
            ..color = AppColors.ember
            ..strokeWidth = 2);
      canvas.drawLine(Offset(arrowX, springBottom),
          Offset(arrowX + 4, springBottom - 6), Paint()
            ..color = AppColors.ember
            ..strokeWidth = 2);
    }

    if (label.isNotEmpty) {
      TextPainter(
        text: TextSpan(
          text: label,
          style: AppTheme.mono(size: 10, color: AppColors.ink3),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout(maxWidth: size.width - 8)
        ..paint(canvas, Offset(4, size.height - 26));
    }
  }

  @override
  bool shouldRepaint(SpringPainter old) =>
      old.bouncer != bouncer ||
      old.label != label ||
      old.frame != frame ||
      old.pull != pull;
}
