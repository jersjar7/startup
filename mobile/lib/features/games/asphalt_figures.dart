import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// The pieces a compacted asphalt specimen is made of, by volume, plus the
/// two spans this lesson keeps asking about.
enum Piece2 { aggregate, binder, air, vma }

extension PieceWords on Piece2 {
  String get plain => switch (this) {
        Piece2.aggregate => 'the aggregate itself',
        Piece2.binder => 'the asphalt binder',
        Piece2.air => 'the air voids',
        Piece2.vma => 'the voids in the mineral aggregate',
      };

  String get tag => switch (this) {
        Piece2.aggregate => 'aggregate',
        Piece2.binder => 'binder',
        Piece2.air => 'air',
        Piece2.vma => 'VMA',
      };
}

/// A compacted specimen, by volume: what is stone, what is binder, what is
/// air. VMA is the last two together, which is the relationship the whole
/// lesson rests on.
@immutable
class Puck {
  const Puck({required this.air, required this.binder});

  /// Percent of the total volume.
  final double air;
  final double binder;

  double get aggregate => 100 - air - binder;

  /// The space between the stones, however it is filled.
  double get vma => air + binder;

  /// The share of that space the binder has taken.
  double get vfa => 100 * binder / vma;

  /// What the lesson calls a workable design: about four percent air, and
  /// enough room between the stones to carry a proper film of binder.
  bool get tooOpen => air > 5;
  bool get tooTight => air < 3;
}

/// The specimen drawn as one column, stone at the bottom, then binder, then
/// air, with a bracket beside the two that make up the VMA.
class PuckPainter extends CustomPainter {
  const PuckPainter({
    required this.puck,
    this.picked,
    this.answer,
    this.locked = false,
  });

  final Puck puck;
  final Piece2? picked;
  final Piece2? answer;
  final bool locked;

  static const _barLeft = 82.0;
  static const _barWide = 110.0;

  static Rect column(Size size) =>
      Rect.fromLTWH(_barLeft, 16, _barWide, size.height - 44);

  /// Where each piece sits in the column. The VMA is a bracket beside the
  /// air and the binder together, so it has its own strip of canvas and
  /// cannot be confused with either of them.
  /// The voids are drawn far bigger than they are. Four percent of a column
  /// is a few pixels and nothing could be pointed at, so the stone is given
  /// under half the height and the void space the rest, split between air and
  /// binder in their true proportion. The panel says so, and the percentages
  /// beside each band are the real ones.
  static Rect rectOf(Size size, Puck puck, Piece2 piece) {
    final box = column(size);
    const stoneShare = 0.42;
    final voids = box.height * (1 - stoneShare);
    final airTop = box.top;
    final binderTop = airTop + voids * puck.air / puck.vma;
    final stoneTop = box.top + voids;
    return switch (piece) {
      Piece2.air =>
        Rect.fromLTRB(box.left, airTop, box.right, binderTop),
      Piece2.binder =>
        Rect.fromLTRB(box.left, binderTop, box.right, stoneTop),
      Piece2.aggregate =>
        Rect.fromLTRB(box.left, stoneTop, box.right, box.bottom),
      Piece2.vma =>
        Rect.fromLTRB(box.right + 6, airTop, box.right + 42, stoneTop),
    };
  }

  /// Which piece a tap landed on.
  static Piece2? at(Size size, Puck puck, Offset tap) {
    for (final piece in Piece2.values) {
      if (rectOf(size, puck, piece).inflate(6).contains(tap)) return piece;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final box = column(size);

    for (final piece in [Piece2.air, Piece2.binder, Piece2.aggregate]) {
      final rect = rectOf(size, puck, piece);
      final Color tone = switch (piece) {
        Piece2.air => AppColors.info,
        Piece2.binder => AppColors.charcoal,
        _ => AppColors.sunbeam,
      };
      final chosen = picked == piece;
      final truth = locked && answer == piece;
      canvas
        ..drawRect(
            rect, Paint()..color = tone.withValues(alpha: piece == Piece2.binder ? 0.55 : 0.35))
        ..drawRect(
          rect,
          Paint()
            ..color = truth
                ? AppColors.forest
                : (locked && chosen)
                    ? AppColors.error
                    : chosen
                        ? AppColors.ember
                        : AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = truth || chosen ? 2.6 : 1.2,
        );
      final label = '${piece.tag} ${_num(_shareOf(piece))}%';
      _write(canvas, size, label, Offset(4, rect.center.dy - 6), AppColors.ink3,
          room: box.left - 8);
    }

    // The VMA bracket, which is the air and the binder together.
    final span = rectOf(size, puck, Piece2.vma);
    final chosen = picked == Piece2.vma;
    final truth = locked && answer == Piece2.vma;
    final tone = truth
        ? AppColors.forest
        : (locked && chosen)
            ? AppColors.error
            : chosen
                ? AppColors.ember
                : AppColors.ink3;
    final paint = Paint()
      ..color = tone
      ..strokeWidth = truth || chosen ? 2.6 : 1.4;
    canvas
      ..drawLine(Offset(span.left + 6, span.top), Offset(span.left + 6, span.bottom), paint)
      ..drawLine(Offset(span.left, span.top), Offset(span.left + 12, span.top), paint)
      ..drawLine(
          Offset(span.left, span.bottom), Offset(span.left + 12, span.bottom), paint);
    _write(canvas, size, 'VMA ${_num(puck.vma)}%',
        Offset(span.left + 16, span.center.dy - 6), tone);

    _write(canvas, size, 'by volume', Offset(4, size.height - 18),
        AppColors.ink3);
    _write(canvas, size, 'voids drawn big', Offset(box.right + 6, size.height - 18),
        AppColors.ink3);
  }

  double _shareOf(Piece2 piece) => switch (piece) {
        Piece2.air => puck.air,
        Piece2.binder => puck.binder,
        Piece2.aggregate => puck.aggregate,
        Piece2.vma => puck.vma,
      };

  static String _num(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  void _write(Canvas canvas, Size size, String text, Offset at, Color color,
      {double? room}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: room ?? size.width);
    var x = at.dx;
    if (x + painter.width > size.width - 2) x = size.width - 2 - painter.width;
    if (x < 2) x = 2;
    painter.paint(canvas, Offset(x, at.dy));
  }

  @override
  bool shouldRepaint(PuckPainter old) =>
      old.puck != puck ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked;
}
