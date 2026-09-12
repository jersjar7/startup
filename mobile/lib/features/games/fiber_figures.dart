import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// Which way the load runs against the fibers, which is the only thing that
/// decides how a composite behaves.
enum Lay { along, across }

extension LayWords on Lay {
  String get plain => switch (this) {
        Lay.along => 'the load runs along the fibers',
        Lay.across => 'the load runs across the fibers',
      };
}

/// Two materials in known proportions, and what they do together.
@immutable
class Blend {
  const Blend({
    required this.fiberE,
    required this.matrixE,
    required this.fiberShare,
    this.fiberName = 'fiber',
    this.matrixName = 'matrix',
  });

  /// Gigapascals, and the fiber's share of the volume.
  final double fiberE;
  final double matrixE;
  final double fiberShare;

  final String fiberName;
  final String matrixName;

  double get matrixShare => 1 - fiberShare;

  /// Loaded along the fibers: both stretch the same, so the moduli add up in
  /// proportion to volume.
  double get along => fiberShare * fiberE + matrixShare * matrixE;

  /// Loaded across them: both carry the same stress and the softer one gives
  /// way, so the reciprocals add and the answer is always the smaller.
  double get across =>
      1 / (fiberShare / fiberE + matrixShare / matrixE);

  double modulusFor(Lay lay) => lay == Lay.along ? along : across;

  /// Along the fibers, the share of the total load the fibers take.
  double get fiberLoadShare => fiberShare * fiberE / along;

  /// The stress in each phase when the composite as a whole carries this.
  double fiberStress(double composite) => composite * fiberE / along;
  double matrixStress(double composite) => composite * matrixE / along;
}

/// A block of composite with its fibers drawn in, pulled along or across.
class BlendPainter extends CustomPainter {
  const BlendPainter({
    required this.blend,
    required this.lay,
    this.picked,
    this.answer,
    this.locked = false,
    this.stretched = false,
  });

  final Blend blend;
  final Lay lay;

  /// Zero is the fiber and one is the matrix: what the reader chose and what
  /// was right, once the round is over.
  final int? picked;
  final int? answer;
  final bool locked;

  /// Whether to draw what the block does under the load, which is only shown
  /// once the answer is in.
  final bool stretched;

  static Rect block(Size size) => Rect.fromLTRB(
        46,
        size.height * 0.20,
        size.width - 46,
        size.height * 0.72,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final box = block(size);
    final fiberTone = _toneOf(0, AppColors.charcoal);
    final matrixTone = _toneOf(1, AppColors.sunbeam);

    canvas.drawRect(
        box, Paint()..color = matrixTone.withValues(alpha: 0.28));

    // The fibers: lines running left to right, always. It is the LOAD that
    // changes direction between rounds, never the fibers, because that is
    // what the reader has to notice.
    final count = 7;
    final fibers = Paint()
      ..color = fiberTone
      ..strokeWidth = 3.4;
    for (var i = 1; i <= count; i++) {
      final y = box.top + box.height * i / (count + 1);
      canvas.drawLine(Offset(box.left + 4, y), Offset(box.right - 4, y), fibers);
    }
    canvas.drawRect(
      box,
      Paint()
        ..color = AppColors.charcoal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // The pull.
    if (lay == Lay.along) {
      _arrow(canvas, Offset(box.left - 10, box.center.dy),
          Offset(box.left - 34, box.center.dy));
      _arrow(canvas, Offset(box.right + 10, box.center.dy),
          Offset(box.right + 34, box.center.dy));
    } else {
      for (final x in [box.center.dx - 40, box.center.dx + 40]) {
        _arrow(canvas, Offset(x, box.top - 8), Offset(x, box.top - 30));
        _arrow(canvas, Offset(x, box.bottom + 8), Offset(x, box.bottom + 30));
      }
    }

    writeOn(canvas, size, blend.fiberName, Offset(2, box.top - 4), fiberTone);
    writeOn(        canvas,
        size,
        '${_num(blend.fiberE)} GPa, ${(blend.fiberShare * 100).round()}%',
        Offset(2, box.top + 10),
        AppColors.ink3);
    writeOn(canvas, size, blend.matrixName, Offset(2, box.bottom - 16),
        AppColors.charcoal);
    writeOn(        canvas,
        size,
        '${_num(blend.matrixE)} GPa, ${(blend.matrixShare * 100).round()}%',
        Offset(2, box.bottom - 2),
        AppColors.ink3);
    writeOn(canvas, size, lay.plain, Offset(box.left, size.height - 16),
        AppColors.ink3);

    if (!stretched) return;
    // What it does: along the fibers everything moves together, across them
    // the soft matrix gives way and the fibers hardly move at all.
    final grew = Paint()
      ..color = AppColors.forest
      ..strokeWidth = 2;
    if (lay == Lay.along) {
      canvas.drawLine(Offset(box.right + 2, box.top - 6),
          Offset(box.right + 16, box.top - 6), grew);
      writeOn(canvas, size, 'both stretch the same',
          Offset(box.left, box.bottom + 12), AppColors.forest);
    } else {
      writeOn(canvas, size, 'the matrix gives way first',
          Offset(box.left, box.bottom + 12), AppColors.forest);
    }
  }

  Color _toneOf(int which, Color base) {
    if (locked && answer == which) return AppColors.forest;
    if (locked && picked == which) return AppColors.error;
    if (picked == which) return AppColors.ember;
    return base;
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  void _arrow(Canvas canvas, Offset from, Offset to) {
    final paint = Paint()
      ..color = AppColors.info
      ..strokeWidth = 2.2;
    final d = to - from;
    final len = d.distance;
    final unit = Offset(d.dx / len, d.dy / len);
    final side = Offset(-unit.dy, unit.dx);
    canvas
      ..drawLine(from, to, paint)
      ..drawLine(to, to - unit * 7 + side * 4, paint)
      ..drawLine(to, to - unit * 7 - side * 4, paint);
  }

  @override
  bool shouldRepaint(BlendPainter old) =>
      old.blend != blend ||
      old.lay != lay ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked ||
      old.stretched != stretched;
}
