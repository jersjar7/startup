import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// The simple shapes the handbook tables cover, which is all you are ever
/// expected to split a section into.
enum Slab { box, rightTri, isoTri, disc, halfDisc, quarterDisc }

/// One piece of a cross section, given by the box it fits in.
///
/// Its area and its own centroid are worked out from the shape, never
/// declared, so a piece cannot be drawn as one thing and counted as another.
@immutable
class Piece {
  const Piece(
    this.kind,
    this.at,
    this.size, {
    this.hole = false,
    this.flip = false,
  });

  final Slab kind;

  /// The lower left corner of the box it fits in, in world units, y upward.
  final Offset at;

  final Size size;

  /// Drilled out rather than filled in, which the sum handles by counting it
  /// as a negative area.
  final bool hole;

  /// For a right triangle, whether the upright leg is on the right.
  final bool flip;

  double get _w => size.width;
  double get _h => size.height;

  /// How much area the shape covers, before any question of holes.
  double get span => switch (kind) {
        Slab.box => _w * _h,
        Slab.rightTri || Slab.isoTri => _w * _h / 2,
        Slab.disc ||
        Slab.halfDisc ||
        Slab.quarterDisc =>
          math.pi * _w * _h / 4,
      };

  /// What it contributes to the sum. A hole subtracts from the top and the
  /// bottom of the weighted average both, which is the whole trick.
  double get area => hole ? -span : span;

  /// Where this piece's own centroid sits, from the handbook table.
  Offset get centroid {
    final local = switch (kind) {
      Slab.box => Offset(_w / 2, _h / 2),
      Slab.rightTri => Offset(flip ? _w * 2 / 3 : _w / 3, _h / 3),
      Slab.isoTri => Offset(_w / 2, _h / 3),
      Slab.disc => Offset(_w / 2, _h / 2),
      Slab.halfDisc => Offset(_w / 2, 4 * _h / (3 * math.pi)),
      Slab.quarterDisc =>
        Offset(4 * _w / (3 * math.pi), 4 * _h / (3 * math.pi)),
    };
    return at + local;
  }

  Rect get box => Rect.fromLTWH(at.dx, at.dy, _w, _h);

  /// The outline, in world units with y upward.
  Path outline() {
    final l = at.dx;
    final b = at.dy;
    switch (kind) {
      case Slab.box:
        return Path()..addRect(Rect.fromLTWH(l, b, _w, _h));
      case Slab.rightTri:
        return Path()
          ..moveTo(l, b)
          ..lineTo(l + _w, b)
          ..lineTo(flip ? l + _w : l, b + _h)
          ..close();
      case Slab.isoTri:
        return Path()
          ..moveTo(l, b)
          ..lineTo(l + _w, b)
          ..lineTo(l + _w / 2, b + _h)
          ..close();
      case Slab.disc:
        return Path()..addOval(Rect.fromLTWH(l, b, _w, _h));
      case Slab.halfDisc:
        return Path()
          ..addArc(Rect.fromLTWH(l, b - _h, _w, _h * 2), 0, math.pi)
          ..close();
      case Slab.quarterDisc:
        return Path()
          ..addArc(Rect.fromLTWH(l - _w, b - _h, _w * 2, _h * 2), 0,
              math.pi / 2)
          ..lineTo(l, b)
          ..close();
    }
  }
}

/// A whole cross section, made of pieces.
@immutable
class Profile {
  const Profile(this.pieces);

  final List<Piece> pieces;

  double get area => pieces.fold(0.0, (sum, p) => sum + p.area);

  /// The area-weighted average of the pieces, which is the only thing this
  /// lesson is about. Never the middle of the height, however tempting.
  Offset get centroid {
    var mx = 0.0;
    var my = 0.0;
    for (final p in pieces) {
      mx += p.area * p.centroid.dx;
      my += p.area * p.centroid.dy;
    }
    return Offset(mx / area, my / area);
  }

  /// The outside of the section. A hole does not make it any bigger.
  Rect get bounds {
    Rect? box;
    for (final p in pieces) {
      if (p.hole) continue;
      box = box == null ? p.box : box.expandToInclude(p.box);
    }
    return box!;
  }

  /// The bottom edge and the top edge, in world y.
  ///
  /// Named rather than reached for through the Rect, because a Rect thinks y
  /// grows downward and this drawing has it growing up, so its `bottom` is
  /// this section's TOP. That inversion cost one wrong answer already.
  double get baseline => bounds.top;
  double get crown => bounds.bottom;

  /// Halfway up, which is where the centroid is only when the area happens to
  /// be spread evenly about it.
  double get midHeight => baseline + bounds.height / 2;

  /// Whether the centroid sits above, below, or on that halfway line. Worked
  /// out from the pieces, and the tolerance is a tenth of a percent of the
  /// height so a genuinely symmetric section reads as symmetric.
  Sit get sit {
    final gap = centroid.dy - midHeight;
    if (gap.abs() < bounds.height * 0.004) return Sit.onIt;
    return gap > 0 ? Sit.above : Sit.below;
  }
}

/// Where the centroid sits against the middle of the height.
enum Sit { above, onIt, below }

/// One candidate distance, drawn as a dimension beside the section.
@immutable
class Drop {
  const Drop(this.from, this.to, this.label);

  /// In world units, measured up from the same zero the section is built on.
  final double from;
  final double to;

  final String label;
}

class ProfilePainter extends CustomPainter {
  const ProfilePainter({
    required this.profile,
    this.showMiddle = false,
    this.spots = const [],
    this.drops = const [],
    this.spotlight = -1,
    this.picked,
    this.truth = -1,
    this.locked = false,
    this.markCentroid = false,
  });

  final Profile profile;

  /// Draws the halfway line, which is the answer people reach for.
  final bool showMiddle;

  /// Candidate places for the centroid, in world units.
  final List<Offset> spots;

  /// Candidate distances, drawn as dimensions down the left.
  final List<Drop> drops;

  /// The piece the round is asking about.
  final int spotlight;

  final int? picked;
  final int truth;
  final bool locked;
  final bool markCentroid;

  static const _dim = 46.0;

  /// Room round the drawing. The right hand margin exists only to hold the
  /// halfway line's label, so a figure without one gets the width back.
  static EdgeInsets _roomFor({bool hasDrops = false, bool hasLabel = false}) =>
      EdgeInsets.fromLTRB(
        hasDrops ? 26 : 22,
        22,
        hasLabel ? 68 : 22,
        22,
      );

  static double _scale(
      Profile profile, Size size, List<Drop> drops, bool hasLabel) {
    final b = profile.bounds;
    final room = _roomFor(hasDrops: drops.isNotEmpty, hasLabel: hasLabel);
    // Every dimension takes a lane down the left, and the lanes are measured
    // rather than guessed at.
    final lanes = drops.length * _dim;
    return math.min(
      (size.width - room.horizontal - lanes) / math.max(b.width, 0.001),
      (size.height - room.vertical) / math.max(b.height, 0.001),
    );
  }

  static Offset toScreen(Profile profile, Offset world, Size size,
      {List<Drop> drops = const [], bool hasLabel = false}) {
    final b = profile.bounds;
    final room = _roomFor(hasDrops: drops.isNotEmpty, hasLabel: hasLabel);
    final lanes = drops.length * _dim;
    final s = _scale(profile, size, drops, hasLabel);
    return Offset(
      room.left +
          lanes +
          (size.width - room.horizontal - lanes - b.width * s) / 2 +
          (world.dx - b.left) * s,
      room.top +
          (size.height - room.vertical - b.height * s) / 2 +
          (b.bottom - world.dy) * s,
    );
  }

  /// Where a dimension's line runs down the figure, so the tap target can sit
  /// on it rather than near it.
  static double laneFor(
          Profile profile, Size size, List<Drop> drops, int index) =>
      _roomFor(hasDrops: true).left + _dim * (drops.length - index) - 13;

  @override
  void paint(Canvas canvas, Size size) {
    Offset at(Offset w) =>
        toScreen(profile, w, size, drops: drops, hasLabel: showMiddle);

    for (var i = 0; i < profile.pieces.length; i++) {
      final piece = profile.pieces[i];
      final path = _onScreen(piece, size);
      final lit = i == spotlight;
      canvas.drawPath(
        path,
        Paint()
          ..color = piece.hole
              ? AppColors.cream
              : lit
                  ? AppColors.emberBg
                  : AppColors.sunbeamBg,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = lit ? AppColors.ember : AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = lit ? 3 : 2,
      );
    }

    final taken = <Rect>[];
    final box = profile.bounds;

    if (showMiddle) {
      final y = at(Offset(box.left, profile.midHeight)).dy;
      _dash(canvas, Offset(at(Offset(box.left, 0)).dx - 12, y),
          Offset(at(Offset(box.right, 0)).dx + 12, y), AppColors.ink3);
      taken.add(_write(
        canvas,
        'halfway up',
        Offset(at(Offset(box.right, 0)).dx + 16, y - 6),
        AppColors.ink3,
        size,
        taken,
        fromLeft: true,
      ));
    }

    for (var i = 0; i < drops.length; i++) {
      final lane = laneFor(profile, size, drops, i);
      _dimension(
        canvas,
        size,
        lane,
        at(Offset(box.left, drops[i].from)).dy,
        at(Offset(box.left, drops[i].to)).dy,
        at(Offset(box.left, 0)).dx,
        '${i + 1}',
        _shade(i),
        taken,
      );
    }

    for (var i = 0; i < spots.length; i++) {
      final here = at(spots[i]);
      final colour = _shade(i);
      canvas.drawCircle(here, 9, Paint()..color = AppColors.cream);
      canvas.drawCircle(
        here,
        9,
        Paint()
          ..color = colour
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
      canvas.drawCircle(here, 3, Paint()..color = colour);
      taken.add(_write(canvas, '${i + 1}', here + const Offset(0, 11), colour,
          size, taken));
    }

    if (markCentroid) {
      final here = at(profile.centroid);
      final ink = Paint()
        ..color = AppColors.forest
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(here - const Offset(11, 0), here + const Offset(11, 0),
          ink);
      canvas.drawLine(here - const Offset(0, 11), here + const Offset(0, 11),
          ink);
      canvas.drawCircle(
        here,
        6.5,
        Paint()
          ..color = AppColors.forest
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4,
      );
    }
  }

  Color _shade(int i) {
    if (locked && i == truth) return AppColors.forest;
    if (locked && picked == i) return AppColors.error;
    if (picked == i) return AppColors.ember;
    return AppColors.info;
  }

  Path _onScreen(Piece piece, Size size) {
    final b = profile.bounds;
    final s = _scale(profile, size, drops, showMiddle);
    final origin = toScreen(profile, Offset(b.left, b.bottom), size,
        drops: drops, hasLabel: showMiddle);
    return piece.outline().transform(Matrix4(
          s, 0, 0, 0, //
          0, -s, 0, 0, //
          0, 0, 1, 0, //
          origin.dx - b.left * s, origin.dy + b.bottom * s, 0, 1, //
        ).storage);
  }

  /// One dimension, drawn the way a drafter draws one: extension lines that
  /// run from the feature being measured out to the dimension line, so it is
  /// obvious what is being measured. Without them it is three floating
  /// arrows beside a picture.
  void _dimension(Canvas canvas, Size size, double x, double from, double to,
      double edge, String label, Color colour, List<Rect> taken) {
    final thin = Paint()
      ..color = colour.withValues(alpha: 0.55)
      ..strokeWidth = 1.0;
    for (final tip in [from, to]) {
      canvas.drawLine(Offset(x - 7, tip), Offset(edge + 4, tip), thin);
    }

    final ink = Paint()
      ..color = colour
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final short = (to - from).abs() < 26;
    if (short) {
      // Too small to hold its own arrows, so they go outside and point in,
      // which is what a drafter does with a tight dimension.
      canvas.drawLine(Offset(x, from - 14), Offset(x, to + 14), ink);
    } else {
      canvas.drawLine(Offset(x, from), Offset(x, to), ink);
    }

    final down = to > from;
    for (final (tip, into) in [(from, down ? 1.0 : -1.0), (to, down ? -1.0 : 1.0)]) {
      final way = short ? -into : into;
      canvas.drawPath(
        Path()
          ..moveTo(x, tip)
          ..lineTo(x - 3.6, tip + way * 8)
          ..lineTo(x + 3.6, tip + way * 8)
          ..close(),
        Paint()..color = colour,
      );
    }

    taken.add(_write(
      canvas,
      label,
      Offset(x, short ? math.min(from, to) - 28 : (from + to) / 2 - 6),
      colour,
      size,
      taken,
    ));
  }

  void _dash(Canvas canvas, Offset from, Offset to, Color colour) {
    final total = (to - from).distance;
    if (total < 1) return;
    final step = (to - from) / total;
    final paint = Paint()
      ..color = colour
      ..strokeWidth = 1.6;
    for (var d = 0.0; d < total; d += 9) {
      canvas.drawLine(
          from + step * d, from + step * math.min(d + 5, total), paint);
    }
  }

  Rect _write(Canvas canvas, String text, Offset at, Color colour, Size size,
      List<Rect> avoid, {bool fromLeft = false}) {
    final tp = TextPainter(
      text: TextSpan(
          text: text, style: AppTheme.mono(size: 11, color: colour)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = fromLeft ? at.dx : at.dx - tp.width / 2;
    var y = at.dy;
    if (x < 2) x = 2;
    if (x + tp.width > size.width - 2) x = size.width - 2 - tp.width;
    Rect box() => Rect.fromLTWH(x - 3, y, tp.width + 6, tp.height);
    for (var tries = 0; tries < 4; tries++) {
      if (!avoid.any((r) => r.overlaps(box()))) break;
      y -= tp.height + 3;
    }
    if (y < 1) y = 1;
    if (y + tp.height > size.height - 1) y = size.height - 1 - tp.height;
    canvas.drawRect(
        box(), Paint()..color = AppColors.cream.withValues(alpha: 0.94));
    tp.paint(canvas, Offset(x, y));
    return box();
  }

  @override
  bool shouldRepaint(ProfilePainter old) =>
      old.profile != profile ||
      old.picked != picked ||
      old.locked != locked ||
      old.spotlight != spotlight;
}
