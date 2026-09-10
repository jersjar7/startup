import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// A job's cost against what it was priced at, drawn as one bar.
///
/// Every pricing question in this lesson is the same question about the same
/// picture: somebody has to absorb the piece past the line, and which contract
/// was signed decides who. Drawn out, the overrun stops being an abstraction
/// about risk and becomes a length of bar with a name on it.
class CostBarPainter extends CustomPainter {
  const CostBarPainter({
    required this.priced,
    required this.actual,
    required this.pricedLabel,
    this.revealed = false,
  });

  /// What the job was priced at, and what it came to. Same arbitrary units.
  final double priced;
  final double actual;

  /// What the priced amount is called in this contract.
  final String pricedLabel;

  final bool revealed;

  static const _padL = 14.0;
  static const _padR = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    final full = actual > priced ? actual : priced;
    final scale = (size.width - _padL - _padR) / (full * 1.06);
    final y = size.height * 0.52;
    const h = 34.0;

    // Everything up to the priced amount: nobody argues about this part.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(_padL, y - h / 2, priced * scale, h),
        const Radius.circular(6),
      ),
      Paint()..color = AppColors.sunbeam.withValues(alpha: 0.45),
    );

    if (actual > priced) {
      final overrun = Rect.fromLTWH(
        _padL + priced * scale,
        y - h / 2,
        (actual - priced) * scale,
        h,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(overrun, const Radius.circular(6)),
        Paint()..color = (revealed ? AppColors.error : AppColors.ember)
            .withValues(alpha: 0.35),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(overrun, const Radius.circular(6)),
        Paint()
          ..color = revealed ? AppColors.error : AppColors.ember
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _write(
        canvas,
        'the overrun',
        Offset(overrun.center.dx, y - h / 2 - 15),
        color: revealed ? AppColors.error : AppColors.ember,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(_padL, y - h / 2, full * scale, h),
        const Radius.circular(6),
      ),
      Paint()
        ..color = AppColors.charcoal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // The line the contract drew.
    final px = _padL + priced * scale;
    canvas.drawLine(
      Offset(px, y - h / 2 - 8),
      Offset(px, y + h / 2 + 8),
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 2.2,
    );
    // Only one label under the bar. A second one at the far end collided
    // with this one every time the overrun was small, which is most of them,
    // and the end of the bar says what it cost without being told to.
    _write(
      canvas,
      pricedLabel,
      Offset(px, y + h / 2 + 12),
      color: AppColors.ink3,
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
  bool shouldRepaint(CostBarPainter old) =>
      old.priced != priced || old.actual != actual || old.revealed != revealed;
}

/// Who holds a contract with whom, which is what a delivery method IS.
///
/// The names are the least useful part of this topic. What separates
/// design-bid-build from design-build is the number of lines running out of
/// the owner's box, and once that is drawn the definitions stop needing to be
/// remembered.
class DeliveryPainter extends CustomPainter {
  const DeliveryPainter({required this.boxes, required this.color});

  /// The parties below the owner, left to right. Each is joined to the owner
  /// by a contract line; anything joined to another box instead hangs off it.
  final List<(String, bool)> boxes;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const topH = 22.0;
    final ownerRect = Rect.fromCenter(
      center: Offset(size.width / 2, 16),
      width: size.width * 0.5,
      height: topH,
    );
    _box(canvas, ownerRect, 'Owner', strong: true);

    final slot = size.width / boxes.length;
    for (final (i, box) in boxes.indexed) {
      final cx = slot * (i + 0.5);
      final rect = Rect.fromCenter(
        center: Offset(cx, size.height - 30),
        width: slot * 0.86,
        height: topH,
      );

      // A party the owner holds a contract with is joined to the owner. One
      // that does not is joined to the party that hired it.
      if (box.$2) {
        // A contract the owner holds: down out of the owner's box.
        final from = Offset(ownerRect.center.dx, ownerRect.bottom);
        canvas.drawPath(
          Path()
            ..moveTo(from.dx, from.dy)
            ..lineTo(from.dx, rect.top - 12)
            ..lineTo(cx, rect.top - 12)
            ..lineTo(cx, rect.top),
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2,
        );
      } else {
        // One the owner does NOT hold: joined straight across to whoever did
        // the hiring. Routed up over the row instead, it ran along under the
        // owner's own line and could not be told apart from it, which is the
        // one distinction this figure exists to draw.
        final prev = Rect.fromCenter(
          center: Offset(slot * (i - 0.5), rect.center.dy),
          width: slot * 0.86,
          height: topH,
        );
        canvas.drawLine(
          Offset(prev.right, rect.center.dy),
          Offset(rect.left, rect.center.dy),
          Paint()
            ..color = AppColors.ink3
            ..strokeWidth = 1.6,
        );
      }
      _box(canvas, rect, box.$1, strong: false);
    }
  }

  void _box(Canvas canvas, Rect rect, String label, {required bool strong}) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = strong
          ? AppColors.charcoal.withValues(alpha: 0.08)
          : AppColors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()
        ..color = AppColors.charcoal
        ..style = PaintingStyle.stroke
        ..strokeWidth = strong ? 1.6 : 1.2,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: AppTheme.mono(size: 9.5, color: AppColors.charcoal),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '.',
    )..layout(maxWidth: rect.width - 6);
    tp.paint(canvas, rect.center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(DeliveryPainter old) =>
      old.boxes != boxes || old.color != color;
}

/// Two clocks running on the same claim.
///
/// A statute of limitations starts when the harm is discovered. A statute of
/// repose starts at a fixed event, usually substantial completion, and cannot
/// be extended by anything that happens afterwards. On a page they are two
/// paragraphs that sound alike; drawn on one line they are two windows, and a
/// claim has to land inside both of them.
class TwoClocksPainter extends CustomPainter {
  const TwoClocksPainter({
    required this.from,
    required this.to,
    required this.completion,
    required this.discovery,
    required this.filed,
    required this.reposeYears,
    required this.limitationYears,
  });

  final int from;
  final int to;

  /// Substantial completion, which starts the repose clock.
  final int completion;

  /// When the harm was found, which starts the limitations clock.
  final int discovery;

  /// When the claim was actually brought.
  final int filed;

  final int reposeYears;
  final int limitationYears;

  static const _padL = 16.0;
  static const _padR = 16.0;

  double _x(Size size, num year) =>
      _padL + (year - from) / (to - from) * (size.width - _padL - _padR);

  @override
  void paint(Canvas canvas, Size size) {
    final axis = size.height * 0.66;

    // The two windows, stacked above the line so their overlap is visible.
    _window(
      canvas,
      size,
      y: axis - 52,
      openAt: completion,
      shutAt: completion + reposeYears,
      label: 'repose, from completion',
      color: AppColors.ember,
    );
    _window(
      canvas,
      size,
      y: axis - 26,
      openAt: discovery,
      shutAt: discovery + limitationYears,
      label: 'limitations, from discovery',
      color: AppColors.forest,
    );

    canvas.drawLine(
      Offset(_padL, axis),
      Offset(size.width - _padR, axis),
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 1.6,
    );

    for (final (i, (year, name)) in [
      (completion, 'completed'),
      (discovery, 'found'),
      (filed, 'filed'),
    ].indexed) {
      final x = _x(size, year);
      final isFiling = name == 'filed';
      // Two rows, alternating. Three names on one row ran together into a
      // single word whenever the dates were close, which is most of them.
      final labelY = axis + 10 + (i.isOdd ? 26 : 0);
      canvas.drawLine(
        Offset(x, axis - 6),
        Offset(x, axis + 7),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = isFiling ? 2.4 : 1.4,
      );
      if (isFiling) {
        canvas.drawCircle(
          Offset(x, axis),
          5,
          Paint()..color = AppColors.charcoal,
        );
      }
      _write(canvas, name, Offset(x, labelY),
          color: AppColors.ink3, size: size);
      _write(
        canvas,
        '$year',
        Offset(x, labelY + 11),
        color: AppColors.charcoal,
        size: size,
      );
    }
  }

  void _window(
    Canvas canvas,
    Size size, {
    required double y,
    required int openAt,
    required int shutAt,
    required String label,
    required Color color,
  }) {
    final a = _x(size, openAt);
    final b = _x(size, shutAt);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(a, y - 6, b, y + 6),
        const Radius.circular(6),
      ),
      Paint()..color = color.withValues(alpha: 0.22),
    );
    for (final end in [a, b]) {
      canvas.drawLine(
        Offset(end, y - 8),
        Offset(end, y + 8),
        Paint()
          ..color = color
          ..strokeWidth = 2,
      );
    }
    _write(canvas, label, Offset(a + 4, y - 20),
        color: color, align: 1, size: size);
  }

  void _write(
    Canvas canvas,
    String text,
    Offset at, {
    required Color color,
    int align = 0,
    Size? size,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 9.5, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = switch (align) {
      1 => 0.0,
      -1 => tp.width,
      _ => tp.width / 2,
    };
    var x = at.dx - dx;
    // A window that opens late in the span had its name running off the right
    // of the card: "limitations, from dis".
    if (size != null) {
      if (x + tp.width > size.width - 2) x = size.width - 2 - tp.width;
      if (x < 2) x = 2;
    }
    tp.paint(canvas, Offset(x, at.dy));
  }

  @override
  bool shouldRepaint(TwoClocksPainter old) =>
      old.completion != completion ||
      old.discovery != discovery ||
      old.filed != filed;
}
