import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';

/// Where the crack is, which is the only thing that decides both numbers the
/// fracture formula needs.
enum Flaw { edgeLeft, edgeRight, internal }

extension FlawWords on Flaw {
  bool get isEdge => this != Flaw.internal;

  String get plain => switch (this) {
        Flaw.edgeLeft => 'an edge crack',
        Flaw.edgeRight => 'an edge crack on the far side',
        Flaw.internal => 'an internal crack',
      };
}

/// A cracked plate under tension.
///
/// Everything here comes off the lesson's one formula. Nothing is declared:
/// the geometry factor comes from where the crack is, and the a that goes
/// into the formula is the whole of an edge crack and half of an internal
/// one, which is the distinction the lesson's hardest problem turns on.
@immutable
class Plate {
  const Plate({
    required this.flaw,
    required this.crackMm,
    required this.stress,
    required this.toughness,
    required this.material,
  });

  final Flaw flaw;

  /// The crack as a drawing would measure it: the depth of an edge crack, or
  /// the whole length of an internal one, in millimeters.
  final double crackMm;

  /// Megapascals, and megapascals times the root of a meter.
  final double stress;
  final double toughness;

  final String material;

  /// The geometry factor from the handbook table.
  double get y => flaw.isEdge ? 1.1 : 1.0;

  /// What goes into the formula, in meters. Half of an internal crack.
  double get a => (flaw.isEdge ? crackMm : crackMm / 2) / 1000;

  /// How hard the crack tip is being driven, in the same units as toughness.
  double get driving => y * stress * math.sqrt(math.pi * a);

  /// The share of the material's toughness this plate is already using. One
  /// means it is on the point of going.
  double get usedUp => driving / toughness;

  /// The most stress this plate could take with the crack it has.
  double get criticalStress => toughness / (y * math.sqrt(math.pi * a));

  /// The biggest crack it could carry at the stress it is under, measured the
  /// way a drawing would measure it.
  double get criticalCrackMm {
    final root = toughness / (y * stress);
    final meters = root * root / math.pi;
    return meters * 1000 * (flaw.isEdge ? 1 : 2);
  }

  bool get broken => usedUp >= 1;
}

/// A plate with a crack in it, pulled from top and bottom.
class PlatePainter extends CustomPainter {
  const PlatePainter({
    required this.plate,
    this.showCrackLength = true,
    this.showStress = true,
    this.showMaterial = true,
    this.tone = AppColors.charcoal,
  });

  final Plate plate;
  final bool showCrackLength;
  final bool showStress;
  final bool showMaterial;
  final Color tone;

  /// The plate itself, inside the room the arrows and labels need.
  static Rect body(Size size) => Rect.fromLTRB(
        18,
        size.height * 0.24,
        size.width - 18,
        size.height * 0.78,
      );

  /// Where the crack is drawn, as a line across the plate.
  static (Offset, Offset) crackLine(Plate plate, Size size) {
    final box = body(size);
    final y = box.center.dy;
    // Cracks are drawn to one scale, so two panels side by side can be read
    // against each other. The floor only catches a crack small enough to
    // vanish, and no round relies on telling two floored cracks apart.
    final drawn = math.max(12.0, box.width * plate.crackMm / 45);
    return switch (plate.flaw) {
      Flaw.edgeLeft => (Offset(box.left, y), Offset(box.left + drawn, y)),
      Flaw.edgeRight => (Offset(box.right - drawn, y), Offset(box.right, y)),
      Flaw.internal => (
          Offset(box.center.dx - drawn / 2, y),
          Offset(box.center.dx + drawn / 2, y)
        ),
    };
  }

  @override
  void paint(Canvas canvas, Size size) {
    final box = body(size);
    // The plate is a piece of steel, so it is drawn as one: hatched, not an
    // empty outline with a red line inside it.
    canvas.drawRect(box, Paint()..color = AppColors.cream);
    hatchIn(canvas, Path()..addRect(box), step: 11);
    canvas.drawRect(
      box,
      Paint()
        ..color = tone
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // The pull, top and bottom, which is what opens the crack.
    for (final way in [-1.0, 1.0]) {
      for (final at in [0.3, 0.5, 0.7]) {
        final x = box.left + box.width * at;
        final from = Offset(x, way < 0 ? box.top : box.bottom);
        _arrow(canvas, from, from + Offset(0, 16 * way));
      }
    }
    if (showStress) {
      _write(canvas, '${plate.stress.round()} MPa', Offset(box.right - 58, 2),
          AppColors.ink3, size);
    }

    final (from, to) = crackLine(plate, size);
    canvas.drawLine(
      from,
      to,
      Paint()
        ..color = AppColors.error
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );

    if (showCrackLength) {
      // The number a drawing carries is what a tape measure would read, never
      // the a that goes into the formula. Reading one off the other is the
      // whole question.
      final label = plate.flaw.isEdge
          ? '${_mm(plate.crackMm)} mm deep'
          : '${_mm(plate.crackMm)} mm long';
      final mid = Offset((from.dx + to.dx) / 2, from.dy);
      _span(canvas, from + const Offset(0, 14), to + const Offset(0, 14));
      _write(canvas, label, Offset(mid.dx - 34, mid.dy + 18), AppColors.error,
          size);
    }

    if (showMaterial) {
      _write(
        canvas,
        '${plate.material}  K = ${_mm(plate.toughness)}',
        Offset(box.left, size.height - 14),
        AppColors.ink3,
        size,
      );
    }
  }

  static String _mm(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  void _arrow(Canvas canvas, Offset from, Offset to) {
    final paint = Paint()
      ..color = AppColors.info
      ..strokeWidth = 1.8;
    final way = (to - from).dy.sign;
    canvas
      ..drawLine(from, to, paint)
      ..drawLine(to, to + Offset(-3.5, -5 * way), paint)
      ..drawLine(to, to + Offset(3.5, -5 * way), paint);
  }

  void _span(Canvas canvas, Offset a, Offset b) {
    final paint = Paint()
      ..color = AppColors.error
      ..strokeWidth = 1;
    canvas
      ..drawLine(a, b, paint)
      ..drawLine(a + const Offset(0, -3), a + const Offset(0, 3), paint)
      ..drawLine(b + const Offset(0, -3), b + const Offset(0, 3), paint);
  }

  /// A label, kept inside the panel: a narrow panel used to cut the number
  /// off the front of "10 mm deep" and leave "mm deep".
  void _write(
      Canvas canvas, String text, Offset at, Color color, Size size) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx;
    if (x + painter.width > size.width - 3) x = size.width - 3 - painter.width;
    if (x < 3) x = 3;
    at = Offset(x, at.dy);
    final patch = Rect.fromLTWH(
        at.dx - 2, at.dy - 1, painter.width + 4, painter.height + 2);
    canvas.drawRect(
        patch, Paint()..color = AppColors.cream.withValues(alpha: 0.9));
    painter.paint(canvas, at);
    viewTag(canvas, size, Looking.elevation, note: 'plate seen flat');
  }

  @override
  bool shouldRepaint(PlatePainter old) =>
      old.plate != plate ||
      old.tone != tone ||
      old.showCrackLength != showCrackLength ||
      old.showStress != showStress ||
      old.showMaterial != showMaterial;
}
