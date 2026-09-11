import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// The buckets energy can sit in, or leave through.
enum Bucket { moving, height, spring, gone, added }

extension BucketWords on Bucket {
  String get plain => switch (this) {
        Bucket.moving => 'moving',
        Bucket.height => 'height',
        Bucket.spring => 'spring',
        Bucket.gone => 'lost',
        Bucket.added => 'put in',
      };

  Color get tone => switch (this) {
        Bucket.moving => AppColors.info,
        Bucket.height => AppColors.forest,
        Bucket.spring => AppColors.sunbeam,
        Bucket.gone => AppColors.error,
        Bucket.added => AppColors.ember,
      };
}

/// An energy account for one situation: what it started with, what it ended
/// with, and what left or joined along the way.
///
/// The items never quote these numbers. They are here so a drawing cannot
/// show one story while the round tells another, and so the tests can insist
/// the books balance.
@immutable
class Ledger {
  const Ledger({
    this.movingStart = 0,
    this.heightStart = 0,
    this.springStart = 0,
    this.movingEnd = 0,
    this.heightEnd = 0,
    this.springEnd = 0,
    this.gone = 0,
    this.added = 0,
  });

  final double movingStart;
  final double heightStart;
  final double springStart;
  final double movingEnd;
  final double heightEnd;
  final double springEnd;

  /// Rubbed away by friction or drag, and put in from outside.
  final double gone;
  final double added;

  double get start => movingStart + heightStart + springStart;
  double get end => movingEnd + heightEnd + springEnd;

  /// Whether the books balance, which every honest ledger must.
  bool get balances => (start + added - gone - end).abs() < 1e-6;

  /// Nothing left and nothing joined: the case where energy is conserved.
  bool get conserved => gone == 0 && added == 0;

  double get tallest => math.max(start + added, end + gone);

  List<(Bucket, double)> get before => [
        if (movingStart > 0) (Bucket.moving, movingStart),
        if (heightStart > 0) (Bucket.height, heightStart),
        if (springStart > 0) (Bucket.spring, springStart),
        if (added > 0) (Bucket.added, added),
      ];

  List<(Bucket, double)> get after => [
        if (movingEnd > 0) (Bucket.moving, movingEnd),
        if (heightEnd > 0) (Bucket.height, heightEnd),
        if (springEnd > 0) (Bucket.spring, springEnd),
        if (gone > 0) (Bucket.gone, gone),
      ];
}

/// Two stacked bars, before and after, with the energy in each bucket.
class LedgerPainter extends CustomPainter {
  const LedgerPainter({required this.ledger, required this.tallest});

  final Ledger ledger;

  /// The tallest bar any drawing beside this one has to hold, so three of
  /// them share a scale and a taller bar really is more energy.
  final double tallest;

  static const _padY = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    final floor = size.height - _padY;
    final room = size.height - _padY * 2;
    final wide = math.min(size.width * 0.22, 54.0);
    final scale = room / (tallest <= 0 ? 1 : tallest);

    for (final (i, stack) in [ledger.before, ledger.after].indexed) {
      final x = size.width * (i == 0 ? 0.3 : 0.68) - wide / 2;
      var y = floor;
      for (final (bucket, amount) in stack) {
        final high = amount * scale;
        final rect = Rect.fromLTWH(x, y - high, wide, high);
        canvas
          ..drawRect(rect, Paint()..color = bucket.tone.withValues(alpha: 0.45))
          ..drawRect(
            rect,
            Paint()
              ..color = bucket.tone
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4,
          );
        if (high > 13) {
          _write(canvas, bucket.plain, Offset(x + 4, y - high / 2 - 6),
              AppColors.charcoal, 9);
        }
        y -= high;
      }
      _write(canvas, i == 0 ? 'before' : 'after',
          Offset(x + 2, floor + 4), AppColors.ink3, 10);
    }

    canvas.drawLine(
      Offset(10, floor),
      Offset(size.width - 10, floor),
      Paint()
        ..color = AppColors.ink3
        ..strokeWidth = 1,
    );
  }

  void _write(Canvas canvas, String text, Offset at, Color color, double size) {
    TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: size, color: color)),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, at);
  }

  @override
  bool shouldRepaint(LedgerPainter old) =>
      old.ledger != ledger || old.tallest != tallest;
}
