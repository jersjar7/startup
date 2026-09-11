import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'section_figures.dart';

/// What a layer of a built-up beam is made of, and the only property of it
/// this lesson needs.
enum Made { steel, concrete, timber, aluminum }

extension MadeFacts on Made {
  /// Modulus of elasticity in megapascals, near enough for comparing.
  double get e => switch (this) {
        Made.steel => 200000,
        Made.concrete => 25000,
        Made.timber => 12000,
        Made.aluminum => 70000,
      };

  String get plain => switch (this) {
        Made.steel => 'steel',
        Made.concrete => 'concrete',
        Made.timber => 'timber',
        Made.aluminum => 'aluminum',
      };

  Color get tone => switch (this) {
        Made.steel => AppColors.info,
        Made.concrete => AppColors.ink3,
        Made.timber => AppColors.sunbeam,
        Made.aluminum => AppColors.forest,
      };
}

/// One rectangle of one material, in world units with y running up.
@immutable
class Slice {
  const Slice(this.at, this.size, this.made);

  final Offset at;
  final Size size;
  final Made made;

  Piece get piece => Piece(Slab.box, at, size);
}

/// A beam made of two materials bonded together.
///
/// Everything the items ask is worked out from the slices: which material is
/// stiffer, what the modular ratio is, what the transformed section looks
/// like and what the stresses do at the join.
@immutable
class Composite {
  const Composite(this.slices);

  final List<Slice> slices;

  Profile get profile => Profile([for (final s in slices) s.piece]);

  /// The two materials in it, stiffer first.
  (Made, Made) get materials {
    final kinds = {for (final s in slices) s.made}.toList()
      ..sort((a, b) => b.e.compareTo(a.e));
    return (kinds.first, kinds.last);
  }

  Made get stiffer => materials.$1;
  Made get softer => materials.$2;

  /// The modular ratio, stiffer over softer, which is always more than one.
  double get n => stiffer.e / softer.e;

  /// The section rewritten as though it were all one material.
  ///
  /// Transforming toward the SOFTER material means widening the stiffer one
  /// by n: there is more of the soft stuff needed to do the same job. Every
  /// slice keeps its depth and its position, because bending is about how far
  /// material sits from the axis and the transform must not move it.
  Profile transformed({bool towardSofter = true, double? factor}) {
    final k = factor ?? n;
    final pieces = <Piece>[];
    for (final s in slices) {
      final widen = towardSofter ? s.made == stiffer : s.made == softer;
      final w = widen ? s.size.width * k : s.size.width;
      final mid = s.at.dx + s.size.width / 2;
      pieces.add(Piece(
        Slab.box,
        Offset(mid - w / 2, s.at.dy),
        Size(w, s.size.height),
      ));
    }
    return Profile(pieces);
  }

  /// Stress at a height in the transformed section, for a sagging moment,
  /// tension positive. The stiffer material carries the extra factor of n,
  /// which is the whole point of the method.
  double stressAt(double y, double moment, Made material) {
    final t = transformed();
    final basic = moment * (t.centroid.dy - y) / t.ownIx;
    return material == stiffer ? basic * n : basic;
  }

  /// Strain at a height, which is the same number whatever the material is:
  /// the two are bonded, so they have to stretch together.
  double strainAt(double y, double moment) {
    final t = transformed();
    return moment * (t.centroid.dy - y) / (t.ownIx * softer.e);
  }
}

/// A built-up section drawn with each material in its own color.
class MadePainter extends CustomPainter {
  const MadePainter({
    required this.slices,
    this.widths,
    this.join,
    this.label = '',
    this.frame,
  });

  final List<Slice> slices;

  /// Widths to draw instead of the real ones, for showing a transformed
  /// section. Same order as the slices.
  final List<double>? widths;

  /// A height to mark with a line, where two materials meet.
  final double? join;

  /// What to scale the drawing by, when this panel sits beside others that
  /// must share its scale. Without it each panel would size itself to its own
  /// contents and a section widened by the modular ratio would come out the
  /// same size on the screen as the one it was widened from, which hides the
  /// one thing the drawing is for.
  final Profile? frame;

  final String label;

  Profile get _drawn => Profile([
        for (var i = 0; i < slices.length; i++)
          Piece(
            Slab.box,
            Offset(
              slices[i].at.dx +
                  slices[i].size.width / 2 -
                  (widths?[i] ?? slices[i].size.width) / 2,
              slices[i].at.dy,
            ),
            Size(widths?[i] ?? slices[i].size.width, slices[i].size.height),
          ),
      ]);

  @override
  void paint(Canvas canvas, Size size) {
    final shown = _drawn;
    final ruler = frame ?? shown;
    for (var i = 0; i < shown.pieces.length; i++) {
      final box = shown.pieces[i].box;
      final a = ProfilePainter.toScreen(ruler, Offset(box.left, box.top), size);
      final b = ProfilePainter.toScreen(
          ruler, Offset(box.right, box.top + box.height), size);
      final rect = Rect.fromPoints(a, b);
      canvas
        ..drawRect(
          rect,
          Paint()..color = slices[i].made.tone.withValues(alpha: 0.35),
        )
        ..drawRect(
          rect,
          Paint()
            ..color = AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
    }

    if (join != null) {
      final left = ProfilePainter.toScreen(
          ruler, Offset(shown.bounds.left, join!), size);
      final right = ProfilePainter.toScreen(
          ruler, Offset(shown.bounds.right, join!), size);
      canvas.drawLine(
        Offset(left.dx - 6, left.dy),
        Offset(right.dx + 6, right.dy),
        Paint()
          ..color = AppColors.ember
          ..strokeWidth = 2,
      );
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
        ..paint(canvas, const Offset(4, 2));
    }
  }

  @override
  bool shouldRepaint(MadePainter old) =>
      old.widths != widths ||
      old.slices != slices ||
      old.join != join ||
      old.frame != frame;
}

/// A box big enough to hold every drawing in a row, so they can all be drawn
/// to one scale.
Profile frameOver(List<List<Slice>> drawings) {
  var left = double.infinity;
  var right = -double.infinity;
  var bottom = double.infinity;
  var top = -double.infinity;
  for (final drawing in drawings) {
    for (final s in drawing) {
      final mid = s.at.dx + s.size.width / 2;
      left = math.min(left, mid - s.size.width / 2);
      right = math.max(right, mid + s.size.width / 2);
      bottom = math.min(bottom, s.at.dy);
      top = math.max(top, s.at.dy + s.size.height);
    }
  }
  return Profile([
    Piece(Slab.box, Offset(left, bottom), Size(right - left, top - bottom)),
  ]);
}

/// How far yielding has spread through a section.
enum Spread3 {
  /// Still straight, nothing yielded.
  elastic,

  /// The outermost fibers have just reached yield and nothing else has.
  firstYield,

  /// Yielded in from both faces, with an elastic core left in the middle.
  partly,

  /// Yielded right through, which is what the plastic moment means.
  fully,
}

extension SpreadWords on Spread3 {
  String get plain => switch (this) {
        Spread3.elastic => 'nothing has yielded yet',
        Spread3.firstYield => 'the outside fibers have just yielded',
        Spread3.partly => 'yielded in from both faces, elastic in the middle',
        Spread3.fully => 'yielded the whole way through',
      };
}

/// The stress running through the depth of a section at some stage of
/// yielding, drawn as a block beside the section.
class StressBlockPainter extends CustomPainter {
  const StressBlockPainter({
    required this.profile,
    required this.state,
    this.tone = AppColors.info,
  });

  final Profile profile;
  final Spread3 state;
  final Color tone;

  /// How much of the half depth is still elastic at each stage.
  double get core => switch (state) {
        Spread3.elastic => 1,
        Spread3.firstYield => 1,
        Spread3.partly => 0.4,
        Spread3.fully => 0,
      };

  /// How much of yield the outermost fiber has reached.
  double get reach => state == Spread3.elastic ? 0.55 : 1;

  /// The stress at a height, as a share of the yield stress.
  double shareAt(double y) {
    final axis = profile.centroid.dy;
    final half = math.max(profile.crown - axis, axis - profile.baseline);
    final up = (y - axis) / half;
    if (core == 0) return up >= 0 ? 1 : -1;
    if (up.abs() <= core) return up / core * reach;
    return up > 0 ? reach : -reach;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final box = Size(size.width * 0.33, size.height);
    ProfilePainter(profile: profile).paint(canvas, box);

    final x0 = size.width * 0.64;
    final room = size.width * 0.30;
    final top = ProfilePainter.toScreen(
        profile, Offset(profile.bounds.left, profile.crown), box);
    final bottom = ProfilePainter.toScreen(
        profile, Offset(profile.bounds.left, profile.baseline), box);
    final axis = ProfilePainter.toScreen(
        profile, Offset(profile.bounds.left, profile.centroid.dy), box);

    /// One lobe of the diagram, from the neutral axis out to a face. Drawn as
    /// its own closed shape: a single path through both lobes crosses itself
    /// at the axis and fills as a bowtie.
    void lobe(double fromY, double toY) {
      final path = Path()..moveTo(x0, _y(fromY, box));
      const steps = 30;
      for (var k = 0; k <= steps; k++) {
        final y = fromY + (toY - fromY) * k / steps;
        path.lineTo(x0 + shareAt(y) * room, _y(y, box));
      }
      path
        ..lineTo(x0, _y(toY, box))
        ..close();
      canvas
        ..drawPath(path, Paint()..color = tone.withValues(alpha: 0.28))
        ..drawPath(
          path,
          Paint()
            ..color = tone
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
    }

    lobe(profile.centroid.dy, profile.crown);
    lobe(profile.centroid.dy, profile.baseline);

    canvas.drawLine(
      Offset(x0, top.dy),
      Offset(x0, bottom.dy),
      Paint()
        ..color = AppColors.ink3
        ..strokeWidth = 1,
    );
    // The neutral axis, carried across from the section so the two drawings
    // line up.
    canvas.drawLine(
      Offset(x0 - room - 4, axis.dy),
      Offset(x0 + room + 4, axis.dy),
      Paint()
        ..color = AppColors.ink3
        ..strokeWidth = 0.8,
    );

    // Where yield sits, on both sides, so a block that stops short of it
    // reads as stopping short.
    for (final side in [1.0, -1.0]) {
      final x = x0 + side * room;
      for (var y = top.dy; y < bottom.dy; y += 6) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, y + 3),
          Paint()
            ..color = AppColors.ink3
            ..strokeWidth = 1,
        );
      }
    }
    TextPainter(
      text: TextSpan(
        text: 'yield',
        style: AppTheme.mono(size: 9, color: AppColors.ink3),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, Offset(x0 + room - 12, bottom.dy + 2));
  }

  double _y(double worldY, Size box) =>
      ProfilePainter.toScreen(profile, Offset(0, worldY), box).dy;

  @override
  bool shouldRepaint(StressBlockPainter old) =>
      old.state != state || old.profile != profile || old.tone != tone;
}
