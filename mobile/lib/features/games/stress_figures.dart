import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'section_figures.dart';

/// A plain rectangle, width by height, sitting on the origin.
Profile boxSection(double b, double h) =>
    Profile([Piece(Slab.box, Offset.zero, Size(b, h))]);

/// An I-section, given the way a steel table gives it.
Profile iSection({
  required double depth,
  required double flangeWidth,
  required double flangeThickness,
  required double webThickness,
}) {
  final web = depth - 2 * flangeThickness;
  final mid = (flangeWidth - webThickness) / 2;
  return Profile([
    Piece(Slab.box, Offset.zero, Size(flangeWidth, flangeThickness)),
    Piece(Slab.box, Offset(mid, flangeThickness), Size(webThickness, web)),
    Piece(Slab.box, Offset(0, depth - flangeThickness),
        Size(flangeWidth, flangeThickness)),
  ]);
}

/// A stack of rectangles, bottom first, each centred on the one below.
///
/// One shape covers a stepped column, a plate girder with unequal flanges and
/// anything else built up out of plates, and unlike a plain I it can have
/// three different widths to choose between.
Profile stackSection(List<(double, double)> layers) {
  final widest = layers.fold(0.0, (w, l) => math.max(w, l.$1));
  final pieces = <Piece>[];
  var y = 0.0;
  for (final (w, h) in layers) {
    pieces.add(Piece(Slab.box, Offset((widest - w) / 2, y), Size(w, h)));
    y += h;
  }
  return Profile(pieces);
}

/// A tee, flange on top, which is the section whose neutral axis is nowhere
/// near the middle of its depth.
Profile teeSection({
  required double depth,
  required double flangeWidth,
  required double flangeThickness,
  required double webThickness,
}) {
  final web = depth - flangeThickness;
  final mid = (flangeWidth - webThickness) / 2;
  return Profile([
    Piece(Slab.box, Offset(mid, 0), Size(webThickness, web)),
    Piece(Slab.box, Offset(0, web), Size(flangeWidth, flangeThickness)),
  ]);
}

/// What a section does under a moment and a shear.
///
/// Everything here is worked out from the pieces, so a round can draw a
/// section and ask about it without also declaring the answer.
extension Stresses on Profile {
  /// A hair, for reading a property just above or just below a height where
  /// the section changes width.
  static const _hair = 1e-9;

  /// The width of material at a height. Zero outside the section.
  ///
  /// [below] decides which side of a junction to read: at the underside of a
  /// flange the width is the web, which is the width the shear has to pass
  /// through and the one the formula wants.
  double widthAt(double y, {bool below = true}) {
    final at = below ? y - _hair : y + _hair;
    var w = 0.0;
    for (final p in pieces) {
      assert(p.kind == Slab.box, 'only boxes have a width at a height');
      if (at > p.box.top && at < p.box.top + p.box.height) {
        w += p.hole ? -p.box.width : p.box.width;
      }
    }
    return w;
  }

  /// The first moment about the neutral axis of everything above a cut, which
  /// is the Q in the shear formula. Taking it below the cut gives the same
  /// number, because the two sides balance about the centroid.
  double qAbove(double y) {
    var q = 0.0;
    for (final p in pieces) {
      final lo = p.box.top;
      final hi = lo + p.box.height;
      final from = math.max(y, lo);
      if (from >= hi) continue;
      final area = (hi - from) * p.box.width * (p.hole ? -1 : 1);
      final middle = (from + hi) / 2;
      q += area * (middle - centroid.dy);
    }
    return q;
  }

  /// Distance from the neutral axis to the furthest fiber.
  double get cTop => crown - centroid.dy;
  double get cBottom => centroid.dy - baseline;
  double get cMax => math.max(cTop, cBottom);

  /// Section modulus, which is only the bending formula with the two things
  /// that never change during a problem folded together.
  double get sectionModulus => ownIx / cMax;

  /// Bending stress at a height, tension positive, for a sagging moment.
  double bendingStressAt(double y, double moment) =>
      moment * (centroid.dy - y) / ownIx;

  /// Transverse shear stress at a height.
  double shearStressAt(double y, double shear, {bool below = true}) {
    final b = widthAt(y, below: below);
    if (b <= 0) return 0;
    return shear * qAbove(y).abs() / (ownIx * b);
  }
}

/// Which stress runs through the depth in the drawing beside the section.
enum Runs { bending, shear }

/// A horizontal layer of a section, which is the thing an item asks about.
@immutable
class Layer {
  const Layer(this.y, this.label);

  final double y;
  final String label;
}

/// A section with layers marked across it, and optionally the stress that
/// runs through its depth drawn beside it.
class LayerPainter extends CustomPainter {
  const LayerPainter({
    required this.profile,
    required this.layers,
    this.picked,
    this.truth = -1,
    this.locked = false,
    this.show,
    this.moment = 0,
    this.shear = 0,
  });

  final Profile profile;
  final List<Layer> layers;
  final int? picked;
  final int truth;
  final bool locked;

  /// Which distribution to draw beside the section, once the answer is out.
  final Runs? show;

  final double moment;
  final double shear;

  static const _stripWidth = 76.0;

  /// The part of the panel the section itself is drawn in, leaving room for
  /// the distribution beside it.
  static Size sectionBox(Size size) =>
      Size(size.width - _stripWidth, size.height);

  /// Where a layer sits on the canvas, so the tap targets are on the lines
  /// rather than near them.
  static Offset layerAt(Profile profile, Size size, double y) {
    final box = sectionBox(size);
    return ProfilePainter.toScreen(profile, Offset(profile.bounds.left, y), box);
  }

  /// The layer nearest a tap, if the tap is near one at all.
  static int? nearest(
    Profile profile,
    Size size,
    List<Layer> layers,
    Offset tap, {
    double within = 26,
  }) {
    int? best;
    var gap = within;
    for (var i = 0; i < layers.length; i++) {
      final d = (layerAt(profile, size, layers[i].y).dy - tap.dy).abs();
      if (d < gap) {
        gap = d;
        best = i;
      }
    }
    return best;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final box = sectionBox(size);
    ProfilePainter(profile: profile).paint(canvas, box);

    final left = ProfilePainter.toScreen(
        profile, Offset(profile.bounds.left, profile.baseline), box);
    final right = ProfilePainter.toScreen(
        profile, Offset(profile.bounds.right, profile.baseline), box);

    if (show != null) _strip(canvas, size, box);

    for (var i = 0; i < layers.length; i++) {
      final y = layerAt(profile, size, layers[i].y).dy;
      final isTruth = locked && i == truth;
      final chosen = picked == i;
      final tone = isTruth
          ? AppColors.forest
          : (locked && chosen)
              ? AppColors.error
              : chosen
                  ? AppColors.ember
                  : AppColors.ink3;
      final heavy = chosen || isTruth;
      canvas.drawLine(
        Offset(left.dx - 10, y),
        Offset(right.dx + 10, y),
        Paint()
          ..color = tone
          ..strokeWidth = heavy ? 2.6 : 1.3,
      );
      canvas.drawCircle(
        Offset(right.dx + 16, y),
        heavy ? 6 : 4,
        Paint()..color = tone,
      );
    }
  }

  /// The distribution through the depth, drawn as a shape whose width at each
  /// height is the stress there.
  void _strip(Canvas canvas, Size size, Size box) {
    final x0 = box.width + 14;
    final room = _stripWidth - 26;
    final steps = 60;
    var peak = 0.0;
    final values = <double, double>{};
    for (var i = 0; i <= steps; i++) {
      final y = profile.baseline +
          (profile.crown - profile.baseline) * i / steps;
      final v = show == Runs.bending
          ? profile.bendingStressAt(y, moment)
          : profile.shearStressAt(y, shear);
      values[y] = v;
      if (v.abs() > peak) peak = v.abs();
    }
    if (peak <= 0) return;

    final path = Path();
    var started = false;
    values.forEach((y, v) {
      final at = ProfilePainter.toScreen(profile, Offset(0, y), box);
      final p = Offset(x0 + v / peak * room / (show == Runs.bending ? 2 : 1),
          at.dy);
      started ? path.lineTo(p.dx, p.dy) : path.moveTo(p.dx, p.dy);
      started = true;
    });
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.ember
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final top = ProfilePainter.toScreen(profile, Offset(0, profile.crown), box);
    final bottom =
        ProfilePainter.toScreen(profile, Offset(0, profile.baseline), box);
    canvas.drawLine(
      Offset(x0, top.dy),
      Offset(x0, bottom.dy),
      Paint()
        ..color = AppColors.ink3
        ..strokeWidth = 1,
    );
    TextPainter(
      text: TextSpan(
        text: show == Runs.bending ? 'bending' : 'shear',
        style: AppTheme.mono(size: 10, color: AppColors.ink3),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, Offset(x0 - 10, bottom.dy + 6));
  }

  @override
  bool shouldRepaint(LayerPainter old) =>
      old.picked != picked ||
      old.locked != locked ||
      old.show != show ||
      old.profile != profile;
}

/// One candidate answer drawn on a section: either a width measured across it
/// at some height, or a band of material between two heights.
@immutable
class Ingredient {
  const Ingredient.width(double at)
      : y = at,
        from = 0,
        to = 0,
        isWidth = true;

  const Ingredient.band(this.from, this.to)
      : y = 0,
        isWidth = false;

  final bool isWidth;

  /// Where the width is measured, for a width.
  final double y;

  /// The bottom and top of the band, for a band.
  final double from;
  final double to;
}

/// One section with the cut drawn on it and ONE candidate marked, so three of
/// these side by side differ only in what they are pointing at.
class MarkPainter extends CustomPainter {
  const MarkPainter({
    required this.profile,
    required this.cut,
    required this.mark,
    this.tone = AppColors.info,
  });

  final Profile profile;

  /// Where the section is being cut, which every panel shows.
  final double cut;

  final Ingredient mark;
  final Color tone;

  Offset _at(Size size, double x, double y) =>
      ProfilePainter.toScreen(profile, Offset(x, y), size);

  @override
  void paint(Canvas canvas, Size size) {
    // The section first. It is drawn filled, so a band painted under it would
    // be invisible, which is exactly what happened the first time.
    ProfilePainter(profile: profile).paint(canvas, size);

    if (!mark.isWidth) {
      for (final p in profile.pieces) {
        final lo = math.max(mark.from, p.box.top);
        final hi = math.min(mark.to, p.box.top + p.box.height);
        if (hi <= lo) continue;
        final a = _at(size, p.box.left, lo);
        final b = _at(size, p.box.left + p.box.width, hi);
        final rect = Rect.fromPoints(a, b);
        canvas
          ..drawRect(rect, Paint()..color = tone.withValues(alpha: 0.38))
          ..drawRect(
            rect,
            Paint()
              ..color = tone
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
      }
    }

    // The cut, dashed all the way across, on top of any shading.
    final cutLeft = _at(size, profile.bounds.left, cut);
    final cutRight = _at(size, profile.bounds.right, cut);
    final dash = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 1.6;
    for (var x = cutLeft.dx - 8; x < cutRight.dx + 8; x += 7) {
      canvas.drawLine(Offset(x, cutLeft.dy), Offset(x + 4, cutLeft.dy), dash);
    }

    if (mark.isWidth) {
      final w = profile.widthAt(mark.y);
      if (w <= 0) return;
      // Centred on the section, because every piece here is centred on it.
      final mid = (profile.bounds.left + profile.bounds.right) / 2;
      final a = _at(size, mid - w / 2, mark.y);
      final b = _at(size, mid + w / 2, mark.y);
      final y = a.dy;
      final ink = Paint()
        ..color = tone
        ..strokeWidth = 2.2;
      canvas.drawLine(Offset(a.dx, y), Offset(b.dx, y), ink);
      for (final end in [(a.dx, 1.0), (b.dx, -1.0)]) {
        canvas.drawPath(
          Path()
            ..moveTo(end.$1, y)
            ..lineTo(end.$1 + 7 * end.$2, y - 3.5)
            ..lineTo(end.$1 + 7 * end.$2, y + 3.5)
            ..close(),
          Paint()..color = tone,
        );
      }
      // Ticks, so a width measured across a gap still reads as a measurement.
      for (final x in [a.dx, b.dx]) {
        canvas.drawLine(Offset(x, y - 9), Offset(x, y + 9),
            Paint()..color = tone..strokeWidth = 1.2);
      }
    }
  }

  @override
  bool shouldRepaint(MarkPainter old) =>
      old.mark != mark || old.tone != tone || old.profile != profile;
}
