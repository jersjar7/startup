import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// Which dimension of a reinforced concrete beam is being pointed at. The
/// whole first item is telling these apart, so they are drawn as separate
/// marks rather than described in words.
enum Depth { height, effective, cover, leverArm, blockDepth }

/// A rectangular beam with one layer of tension steel in it. Everything the
/// items quote about the section comes from here, so a round cannot ask
/// about a dimension the drawing does not have.
@immutable
class RcSection {
  const RcSection({
    required this.width,
    required this.height,
    this.cover = 1.5,
    this.stirrup = 0.375,
    this.barDiameter = 1.0,
    this.blockDepth = 4.4,
  });

  /// Everything in inches.
  final double width;
  final double height;
  final double cover;
  final double stirrup;
  final double barDiameter;

  /// The depth of the Whitney block, which the round is told rather than
  /// working out.
  final double blockDepth;

  /// The effective depth: top of the beam down to the CENTROID of the
  /// tension steel, which is the bar's centre and not its edge.
  double get effective => height - cover - stirrup - barDiameter / 2;

  /// How far apart the two forces in the couple are.
  double get leverArm => effective - blockDepth / 2;
}

/// The beam seen end on, with one dimension called out in orange. The point
/// of the drawing is that the effective depth stops at the middle of the
/// bars and the overall height does not.
class SectionMarkPainter extends CustomPainter {
  const SectionMarkPainter({
    required this.section,
    required this.marked,
    this.answered = false,
  });

  final RcSection section;
  final Depth marked;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(
      (size.width * 0.42) / section.width,
      (size.height - 56) / section.height,
    );
    final w = section.width * scale;
    final h = section.height * scale;
    final left = size.width * 0.30 - w / 2;
    final top = 26.0;
    final rect = Rect.fromLTWH(left, top, w, h);

    // The concrete.
    canvas.drawRect(
        rect,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    hatchIn(canvas, Path()..addRect(rect), step: 9, color: AppColors.ink2);

    // The stirrup, just inside the cover.
    final inset = section.cover * scale;
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(inset), const Radius.circular(3)),
        Paint()
          ..color = AppColors.ink3
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);

    // The tension bars, sitting on top of the bottom stirrup leg.
    final barR = section.barDiameter * scale / 2;
    final barY = rect.bottom -
        (section.cover + section.stirrup + section.barDiameter / 2) * scale;
    for (final f in [0.3, 0.7]) {
      canvas.drawCircle(Offset(rect.left + w * f, barY), math.max(barR, 3),
          Paint()..color = AppColors.charcoal);
    }

    // The called-out dimension, always to the right of the section.
    final x = rect.right + 30;
    switch (marked) {
      case Depth.height:
        _vertical(canvas, size, x, rect.top, rect.bottom, rect.right);
      case Depth.effective:
        _vertical(canvas, size, x, rect.top, barY, rect.right);
      case Depth.cover:
        _vertical(canvas, size, x, rect.bottom - inset, rect.bottom,
            rect.right);
      case Depth.leverArm:
        _vertical(canvas, size, x, rect.top + section.blockDepth * scale / 2,
            barY, rect.right);
      case Depth.blockDepth:
        _vertical(canvas, size, x, rect.top,
            rect.top + section.blockDepth * scale, rect.right);
    }

    if (answered) {
      writeOn(canvas, size, _named, Offset(x + 6, rect.top - 16),
          AppColors.forest, fontSize: 9.5);
    }

    writeOn(canvas, size, 'the tension steel',
        Offset(rect.left - 4, rect.bottom + 8), AppColors.ink3, fontSize: 9.5);
    viewTag(canvas, size, Looking.section, note: 'the beam');
  }

  String get _named => switch (marked) {
        Depth.height => 'h, the overall height',
        Depth.effective => 'd, the effective depth',
        Depth.cover => 'the clear cover',
        Depth.leverArm => 'd minus a over 2, the lever arm',
        Depth.blockDepth => 'a, the depth of the block',
      };

  /// A dimension outside the section, with a thin leader back to each end
  /// of it. Without the leaders the overall height and the effective depth
  /// are two orange bars of nearly the same length, which is exactly the
  /// confusion the item exists to clear up.
  void _vertical(Canvas canvas, Size size, double x, double from, double to,
      double face) {
    final ink = Paint()
      ..color = AppColors.ember
      ..strokeWidth = 2;
    final thin = Paint()
      ..color = AppColors.ember.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    for (final y in [from, to]) {
      for (var lx = face + 2; lx < x - 2; lx += 6) {
        canvas.drawLine(Offset(lx, y), Offset(math.min(lx + 3, x - 2), y),
            thin);
      }
    }
    canvas
      ..drawLine(Offset(x, from), Offset(x, to), ink)
      ..drawLine(Offset(x - 5, from), Offset(x + 5, from), ink)
      ..drawLine(Offset(x - 5, to), Offset(x + 5, to), ink);
    writeOn(canvas, size, 'this one', Offset(x + 7, (from + to) / 2 - 5),
        AppColors.ember, fontSize: 9.5);
  }

  @override
  bool shouldRepaint(SectionMarkPainter old) =>
      old.section != section ||
      old.marked != marked ||
      old.answered != answered;
}

/// Where a factored shear sits against the concrete's own capacity, which is
/// the whole of the stirrup decision.
enum Stirrups { none, minimum, designed, tooSmall }

/// One shear check: what the concrete can do and what is being asked of it.
@immutable
class ShearCheck {
  const ShearCheck({
    required this.concrete,
    required this.demand,
    this.phi = 0.75,
  });

  /// The concrete's own nominal shear capacity, in kips.
  final double concrete;

  /// The factored shear at the section, in kips.
  final double demand;

  final double phi;

  double get usable => phi * concrete;
  double get half => usable / 2;

  /// What the stirrups have to carry, once the concrete has done its share.
  double get stirrupShare => demand / phi - concrete;

  /// The ceiling on what stirrups may be asked to carry before the section
  /// itself is too small, which ACI puts at four times the concrete.
  double get ceiling => 4 * concrete;

  Stirrups get verdict {
    if (demand <= half) return Stirrups.none;
    if (demand <= usable) return Stirrups.minimum;
    if (stirrupShare > ceiling) return Stirrups.tooSmall;
    return Stirrups.designed;
  }
}

/// The three thresholds on one bar, with the demand drawn against them. The
/// decision is a place on a line, so the figure is a line.
class ShearLadderPainter extends CustomPainter {
  const ShearLadderPainter({required this.check, this.answered = false});

  final ShearCheck check;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 26.0;
    final right = size.width - 26;
    final y = size.height * 0.45;
    final top = math.max(check.demand, check.usable) * 1.35;
    double xOf(double v) => left + v / top * (right - left);

    canvas.drawLine(
        Offset(left, y),
        Offset(right, y),
        Paint()
          ..color = AppColors.ink3
          ..strokeWidth = 1.4);

    // The two thresholds the decision turns on. Their labels sit at
    // different heights because the two marks crowd together whenever the
    // demand is large, and a pair of captions on one line becomes soup.
    for (final (v, name, drop) in [
      (check.half, 'half of it', 20.0),
      (check.usable, 'all the concrete can do', 34.0),
    ]) {
      final x = xOf(v);
      canvas.drawLine(
          Offset(x, y - 16),
          Offset(x, y + drop - 4),
          Paint()
            ..color = AppColors.info
            ..strokeWidth = 1.6);
      writeOn(canvas, size, name, Offset(x - 16, y + drop), AppColors.info,
          fontSize: 9.5);
    }

    // What is being asked of the section.
    final dx = xOf(check.demand);
    canvas
      ..drawLine(
          Offset(dx, y - 44),
          Offset(dx, y - 8),
          Paint()
            ..color = AppColors.ember
            ..strokeWidth = 2.6)
      ..drawPath(
          Path()
            ..moveTo(dx, y - 2)
            ..lineTo(dx - 5, y - 12)
            ..lineTo(dx + 5, y - 12)
            ..close(),
          Paint()..color = AppColors.ember);
    writeOn(canvas, size, 'the factored shear', Offset(dx - 30, y - 58),
        AppColors.ember, fontSize: 9.5);

    writeOn(canvas, size, 'along here: how much shear, in kips',
        Offset(left - 4, size.height - 14), AppColors.ink3, fontSize: 9.5);
  }

  @override
  bool shouldRepaint(ShearLadderPainter old) =>
      old.check != check || old.answered != answered;
}

/// A square or rectangular column with its longitudinal bars, seen end on.
/// The bars are drawn at their real size relative to the section, so a cage
/// that is too light or too crowded looks it.
@immutable
class Cage {
  const Cage({
    required this.width,
    required this.depth,
    required this.bars,
    required this.barArea,
    this.spiral = false,
  });

  /// Both in inches.
  final double width;
  final double depth;

  /// How many longitudinal bars, and the area of one of them.
  final int bars;
  final double barArea;

  /// A spiral column instead of a tied one, which changes both factors.
  final bool spiral;

  double get gross => width * depth;
  double get steel => bars * barArea;

  /// The steel ratio the code puts a window around.
  double get ratio => steel / gross;

  bool get tooLittle => ratio < 0.01;
  bool get tooMuch => ratio > 0.08;

  /// The two multipliers on the capacity formula: the accidental
  /// eccentricity allowance and the resistance factor.
  double get allowance => spiral ? 0.85 : 0.80;
  double get phi => spiral ? 0.75 : 0.65;
}

/// The column drawn end on, with the bars where they would really sit.
class CagePainter extends CustomPainter {
  const CagePainter({required this.cage, this.answered = false});

  final Cage cage;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(
      (size.width * 0.5) / cage.width,
      (size.height - 60) / cage.depth,
    );
    final w = cage.width * scale;
    final h = cage.depth * scale;
    final rect =
        Rect.fromCenter(center: Offset(size.width / 2, size.height * 0.48),
            width: w, height: h);

    canvas.drawRect(
        rect,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    hatchIn(canvas, Path()..addRect(rect), step: 10, color: AppColors.ink2);

    // What holds the bars: separate ties follow the outline of the section,
    // a spiral is round, and the difference is the whole of one round.
    final inset = 1.9 * scale;
    final hoop = Paint()
      ..color = AppColors.ink3
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    if (cage.spiral) {
      final r = math.min(rect.width, rect.height) / 2 - inset;
      canvas.drawCircle(rect.center, r, hoop);
      // A second turn just inside, so it reads as a spiral and not a hoop.
      canvas.drawArc(Rect.fromCircle(center: rect.center, radius: r - 3.5),
          -math.pi / 2, math.pi * 1.7, false, hoop);
    } else {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              rect.deflate(inset), const Radius.circular(4)),
          hoop);
    }

    // The bars, at their own size, spread evenly around the tie.
    final radius = math.max(math.sqrt(cage.barArea / math.pi) * scale, 2.2);
    if (cage.spiral) {
      // Round the spiral, which is where the bars of such a column sit.
      final r = math.min(rect.width, rect.height) / 2 - inset - radius - 1;
      for (var i = 0; i < cage.bars; i++) {
        final a = -math.pi / 2 + i * 2 * math.pi / cage.bars;
        canvas.drawCircle(
            rect.center + Offset(math.cos(a) * r, math.sin(a) * r),
            radius,
            Paint()..color = AppColors.ember);
      }
    } else {
      final inner = rect.deflate(inset + radius + 1);
      for (final p in _around(inner, cage.bars)) {
        canvas.drawCircle(p, radius, Paint()..color = AppColors.ember);
      }
    }

    writeOn(
        canvas,
        size,
        cage.spiral ? '${cage.bars} bars in a spiral' : '${cage.bars} bars in ties',
        Offset(rect.left, rect.top - 14),
        AppColors.ember,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        '${_num(cage.width)} by ${_num(cage.depth)} inches',
        Offset(rect.left, rect.bottom + 8),
        AppColors.ink3,
        fontSize: 9.5);
    viewTag(canvas, size, Looking.section, note: 'the column');
  }

  /// Bar positions round the inside of the tie, corners first, which is how
  /// a real cage is built up.
  static List<Offset> _around(Rect r, int n) {
    if (n <= 0) return const [];
    final out = <Offset>[
      r.topLeft,
      r.topRight,
      r.bottomRight,
      r.bottomLeft,
    ];
    if (n <= 4) return out.take(n).toList();
    final left = n - 4;
    // Spread the rest along the four sides, starting with the long ones.
    final perSide = <int>[0, 0, 0, 0];
    for (var i = 0; i < left; i++) {
      perSide[i % 4]++;
    }
    final more = <Offset>[];
    for (var side = 0; side < 4; side++) {
      final count = perSide[side];
      for (var i = 1; i <= count; i++) {
        final t = i / (count + 1);
        more.add(switch (side) {
          0 => Offset(r.left + r.width * t, r.top),
          1 => Offset(r.right, r.top + r.height * t),
          2 => Offset(r.left + r.width * t, r.bottom),
          _ => Offset(r.left, r.top + r.height * t),
        });
      }
    }
    return [...out, ...more];
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  bool shouldRepaint(CagePainter old) =>
      old.cage != cage || old.answered != answered;
}
