import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// A move in moisture content, from where the timber was to where it ends up.
@immutable
class Drying {
  const Drying({required this.from, required this.to});

  /// Percent of the oven dry mass. Green timber can be well over a hundred,
  /// because it is water against the weight of the wood, not of the sample.
  final double from;
  final double to;

  /// The fiber saturation point: the cell walls are full at about here, and
  /// everything above it is free water sitting in the cavities.
  static const fsp = 30.0;

  bool get drying => to < from;

  /// How much of the move happens below the saturation point, which is the
  /// only part that changes the timber.
  double get belowMoved {
    final low = from < to ? from : to;
    final high = from < to ? to : from;
    final top = high < fsp ? high : fsp;
    if (top <= low) return 0;
    return top - low;
  }

  bool get touchesWood => belowMoved > 0.5;
}

/// The moisture scale, with the saturation point marked and the round's move
/// drawn on it as an arrow.
class DryingPainter extends CustomPainter {
  const DryingPainter({required this.move, this.showMove = true});

  final Drying move;
  final bool showMove;

  static const _most = 130.0;

  static Rect plot(Size size) =>
      Rect.fromLTRB(16, size.height * 0.34, size.width - 16, size.height * 0.58);

  static double xOf(Size size, double mc) {
    final box = plot(size);
    return box.left + box.width * (mc / _most).clamp(0, 1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final box = plot(size);
    final fsp = xOf(size, Drying.fsp);

    // Below the saturation point the water is in the cell walls, above it the
    // walls are already full. The two stretches are drawn as two grounds
    // because everything in this lesson turns on which one you are in.
    canvas
      ..drawRect(Rect.fromLTRB(box.left, box.top, fsp, box.bottom),
          Paint()..color = AppColors.sunbeam.withValues(alpha: 0.3))
      ..drawRect(Rect.fromLTRB(fsp, box.top, box.right, box.bottom),
          Paint()..color = AppColors.info.withValues(alpha: 0.18))
      ..drawRect(
        box,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

    canvas.drawLine(
      Offset(fsp, box.top - 12),
      Offset(fsp, box.bottom + 12),
      Paint()
        ..color = AppColors.ember
        ..strokeWidth = 2,
    );
    // The three rows of writing are kept on their own lines: the saturation
    // point at the very top, the move's two ends against the bar, and the
    // two grounds named underneath.
    _write(canvas, size, 'saturation point, 30%', Offset(fsp - 58, 4),
        AppColors.ember);
    // Kept short: the left ground is only a quarter of the scale wide, and a
    // longer caption runs straight into the one beside it.
    _write(canvas, size, 'in the walls',
        Offset(box.left + 2, box.bottom + 22), AppColors.ink3);
    _write(canvas, size, 'free in the cavities',
        Offset(fsp + 6, box.bottom + 22), AppColors.ink3);

    for (final mc in [0.0, 30.0, 60.0, 90.0, 120.0]) {
      final x = xOf(size, mc);
      canvas.drawLine(Offset(x, box.bottom), Offset(x, box.bottom + 4),
          Paint()..color = AppColors.ink3..strokeWidth = 1);
      if (mc != 30) {
        _write(canvas, size, '${mc.round()}', Offset(x - 7, box.bottom + 38),
            AppColors.ink3);
      }
    }
    _write(canvas, size, 'moisture content, percent of the dry wood',
        Offset(box.left, box.bottom + 54), AppColors.ink3);

    if (!showMove) return;

    final from = xOf(size, move.from);
    final to = xOf(size, move.to);
    final y = box.center.dy;
    final paint = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 2.4;
    final way = to > from ? 1.0 : -1.0;
    canvas
      ..drawLine(Offset(from, y), Offset(to, y), paint)
      ..drawLine(Offset(to, y), Offset(to - 6 * way, y - 5), paint)
      ..drawLine(Offset(to, y), Offset(to - 6 * way, y + 5), paint)
      ..drawCircle(Offset(from, y), 4, Paint()..color = AppColors.charcoal);
    _write(canvas, size, '${_num(move.from)}%', Offset(from - 14, box.top - 16),
        AppColors.charcoal);
    _write(canvas, size, '${_num(move.to)}%', Offset(to - 14, box.bottom + 6),
        AppColors.charcoal);
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  void _write(Canvas canvas, Size size, String text, Offset at, Color color) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 9.5, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx;
    if (x + painter.width > size.width - 2) x = size.width - 2 - painter.width;
    if (x < 2) x = 2;
    final patch = Rect.fromLTWH(
        x - 2, at.dy - 1, painter.width + 4, painter.height + 2);
    canvas.drawRect(
        patch, Paint()..color = AppColors.cream.withValues(alpha: 0.9));
    painter.paint(canvas, Offset(x, at.dy));
  }

  @override
  bool shouldRepaint(DryingPainter old) =>
      old.move != move || old.showMove != showMove;
}

/// The mortar types, strongest first, which is the order they are named in.
enum Mortar { m, s, n, o }

extension MortarWords on Mortar {
  String get plain => switch (this) {
        Mortar.m => 'Type M',
        Mortar.s => 'Type S',
        Mortar.n => 'Type N',
        Mortar.o => 'Type O',
      };

  /// Where it sits in strength order: zero is the strongest.
  int get rank => Mortar.values.indexOf(this);
}
