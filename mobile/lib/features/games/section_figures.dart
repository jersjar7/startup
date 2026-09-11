import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';

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

  /// The second moment of area about this shape's OWN horizontal centroidal
  /// axis, straight from the handbook table. Never integrated: the exam does
  /// not ask you to and neither does this.
  double get ownIx => switch (kind) {
        Slab.box => _w * _h * _h * _h / 12,
        Slab.rightTri || Slab.isoTri => _w * _h * _h * _h / 36,
        // An ellipse of semi-axes w/2 and h/2.
        Slab.disc => math.pi * _w * _h * _h * _h / 64,
        // Half of that ellipse, moved onto its own centroid.
        Slab.halfDisc => (math.pi / 16 - 4 / (9 * math.pi)) * _w * _h * _h * _h / 4,
        Slab.quarterDisc =>
          (math.pi / 16 - 4 / (9 * math.pi)) * _w * _h * _h * _h / 4,
      };

  /// The same about the vertical centroidal axis, which is the other half of
  /// the trap: the dimension that gets cubed is the one square to the axis.
  double get ownIy => switch (kind) {
        Slab.box => _h * _w * _w * _w / 12,
        Slab.rightTri => _h * _w * _w * _w / 36,
        Slab.isoTri => _h * _w * _w * _w / 48,
        Slab.disc => math.pi * _h * _w * _w * _w / 64,
        Slab.halfDisc => math.pi * _h * _w * _w * _w / 64,
        Slab.quarterDisc =>
          (math.pi / 16 - 4 / (9 * math.pi)) * _h * _w * _w * _w / 4,
      };

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

  /// The second moment of area of the whole section about a horizontal axis
  /// at [axisY], by the parallel axis theorem piece by piece.
  ///
  /// Every piece contributes its own centroidal value AND a transfer term, and
  /// dropping either of them is the mistake this lesson is mostly about.
  double iAboutX(double axisY) {
    var total = 0.0;
    for (final p in pieces) {
      final d = p.centroid.dy - axisY;
      final own = p.hole ? -p.ownIx : p.ownIx;
      total += own + p.area * d * d;
    }
    return total;
  }

  double iAboutY(double axisX) {
    var total = 0.0;
    for (final p in pieces) {
      final d = p.centroid.dx - axisX;
      final own = p.hole ? -p.ownIy : p.ownIy;
      total += own + p.area * d * d;
    }
    return total;
  }

  /// About the section's own centroidal axes, which is what a table would
  /// give you and what a beam actually bends about.
  double get ownIx => iAboutX(centroid.dy);
  double get ownIy => iAboutY(centroid.dx);

  /// What one piece contributes to the whole section's stiffness: its own
  /// share plus its transfer term. On most real sections the transfer term is
  /// the bigger half by a long way.
  double shareOf(int piece) {
    final p = pieces[piece];
    final d = p.centroid.dy - centroid.dy;
    final own = p.hole ? -p.ownIx : p.ownIx;
    return own + p.area * d * d;
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

/// A horizontal axis drawn on a section, at a stated height.
@immutable
class Datum {
  const Datum(this.y, this.label);

  /// In world units, measured the same way the section is built.
  final double y;

  final String label;
}

/// What the parallel axis theorem does when you move between two axes.
enum Transfer {
  /// Leaving the centroidal axis, so the transfer term is added on.
  add,

  /// Arriving at the centroidal axis, so it comes back off.
  subtract,

  /// Neither axis is the centroidal one, and the theorem will not go
  /// directly between them at all.
  cannot,
}

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
    this.axes = const [],
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

  /// Axes drawn across the section, labelled where they sit.
  final List<Datum> axes;

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

  /// What the figure has to hold: the section, and any axis drawn across it.
  /// An axis can sit well outside the metal, and framing to the metal alone
  /// puts it off the bottom of the box.
  static Rect _frame(Profile profile, List<Datum> axes) {
    var box = profile.bounds;
    for (final a in axes) {
      box = box.expandToInclude(
          Rect.fromLTWH(box.left, a.y, box.width, 0));
    }
    return box;
  }

  static double _scale(Profile profile, Size size, List<Drop> drops,
      bool hasLabel, List<Datum> axes) {
    final b = _frame(profile, axes);
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
      {List<Drop> drops = const [],
      bool hasLabel = false,
      List<Datum> axes = const []}) {
    final b = _frame(profile, axes);
    final room = _roomFor(hasDrops: drops.isNotEmpty, hasLabel: hasLabel);
    final lanes = drops.length * _dim;
    final s = _scale(profile, size, drops, hasLabel, axes);
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

  /// The box one piece is drawn in, so it can be tapped on rather than near.
  static Rect pieceRect(Profile profile, Size size, int piece,
      {bool hasLabel = false, List<Datum> axes = const []}) {
    final b = profile.pieces[piece].box;
    final a = toScreen(profile, Offset(b.left, b.bottom), size,
        hasLabel: hasLabel, axes: axes);
    final c = toScreen(profile, Offset(b.right, b.top), size,
        hasLabel: hasLabel, axes: axes);
    return Rect.fromPoints(a, c);
  }

  /// Where a dimension's line runs down the figure, so the tap target can sit
  /// on it rather than near it.
  static double laneFor(
          Profile profile, Size size, List<Drop> drops, int index) =>
      _roomFor(hasDrops: true).left + _dim * (drops.length - index) - 13;

  @override
  void paint(Canvas canvas, Size size) {
    Offset at(Offset w) => toScreen(profile, w, size,
        drops: drops, hasLabel: showMiddle, axes: axes);

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

    for (var i = 0; i < axes.length; i++) {
      final y = at(Offset(box.left, axes[i].y)).dy;
      final onCentroid = (axes[i].y - profile.centroid.dy).abs() < 0.01;
      final colour = onCentroid ? AppColors.forest : AppColors.info;
      final left = at(Offset(box.left, 0)).dx - 22;
      final right = at(Offset(box.right, 0)).dx + 22;
      if (onCentroid) {
        // A centroidal axis is drawn as a chain line, the way a drawing
        // office marks one, so it is not just another line.
        _chain(canvas, Offset(left, y), Offset(right, y), colour);
      } else {
        _dash(canvas, Offset(left, y), Offset(right, y), colour);
      }
      taken.add(_write(canvas, axes[i].label, Offset(left - 4, y - 7), colour,
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
    viewTag(canvas, size, Looking.section);
  }

  Color _shade(int i) {
    if (locked && i == truth) return AppColors.forest;
    if (locked && picked == i) return AppColors.error;
    if (picked == i) return AppColors.ember;
    return AppColors.info;
  }

  Path _onScreen(Piece piece, Size size) {
    final b = _frame(profile, axes);
    final s = _scale(profile, size, drops, showMiddle, axes);
    final origin = toScreen(profile, Offset(b.left, b.bottom), size,
        drops: drops, hasLabel: showMiddle, axes: axes);
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

  /// Long dash, short dash: the drawing office mark for a centre line.
  void _chain(Canvas canvas, Offset from, Offset to, Color colour) {
    final total = (to - from).distance;
    if (total < 1) return;
    final step = (to - from) / total;
    final paint = Paint()
      ..color = colour
      ..strokeWidth = 1.8;
    var d = 0.0;
    var long = true;
    while (d < total) {
      final run = long ? 12.0 : 3.0;
      canvas.drawLine(
          from + step * d, from + step * math.min(d + run, total), paint);
      d += run + 4;
      long = !long;
    }
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

/// Several sections drawn side by side to be compared.
///
/// They share ONE scale. Two shapes each stretched to fill their own cell are
/// two shapes you cannot compare, and comparing them is the whole point.
class LineUpPainter extends CustomPainter {
  const LineUpPainter({
    required this.shapes,
    this.order = const [],
    this.truth = const [],
    this.locked = false,
  });

  final List<Profile> shapes;

  /// Which have been tapped, in the order they were tapped.
  final List<int> order;

  /// The right order, stiffest first.
  final List<int> truth;

  final bool locked;

  static const _room = EdgeInsets.fromLTRB(6, 28, 6, 32);
  static const _gap = 8.0;

  static double _cell(List<Profile> shapes, Size size) =>
      (size.width - _room.horizontal - _gap * (shapes.length - 1)) /
      shapes.length;

  static double scaleFor(List<Profile> shapes, Size size) {
    var widest = 0.0;
    var tallest = 0.0;
    for (final s in shapes) {
      widest = math.max(widest, s.bounds.width);
      tallest = math.max(tallest, s.bounds.height);
    }
    return math.min(
      (_cell(shapes, size) - 8) / math.max(widest, 0.001),
      (size.height - _room.vertical) / math.max(tallest, 0.001),
    );
  }

  /// The box one shape is drawn in, which is also where it is tapped.
  static Rect cellFor(List<Profile> shapes, Size size, int i) {
    final w = _cell(shapes, size);
    return Rect.fromLTWH(
      _room.left + i * (w + _gap),
      _room.top,
      w,
      size.height - _room.vertical,
    );
  }

  static Offset _toScreen(
      List<Profile> shapes, Size size, int i, Offset world) {
    final cell = cellFor(shapes, size, i);
    final s = scaleFor(shapes, size);
    final b = shapes[i].bounds;
    return Offset(
      cell.center.dx - b.width * s / 2 + (world.dx - b.left) * s,
      cell.center.dy + b.height * s / 2 - (world.dy - b.top) * s,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = scaleFor(shapes, size);

    for (var i = 0; i < shapes.length; i++) {
      final profile = shapes[i];
      final rank = order.indexOf(i);
      final right = locked && truth.indexOf(i) == rank;
      final Color edge;
      if (locked) {
        edge = right ? AppColors.forest : AppColors.error;
      } else if (rank >= 0) {
        edge = AppColors.ember;
      } else {
        edge = AppColors.charcoal;
      }

      final b = profile.bounds;
      final origin = _toScreen(shapes, size, i, Offset(b.left, b.bottom));
      final matrix = Matrix4(
        s, 0, 0, 0, //
        0, -s, 0, 0, //
        0, 0, 1, 0, //
        origin.dx - b.left * s, origin.dy + b.bottom * s, 0, 1, //
      ).storage;

      for (final piece in profile.pieces) {
        final path = piece.outline().transform(matrix);
        canvas.drawPath(
          path,
          Paint()
            ..color = piece.hole ? AppColors.cream : AppColors.sunbeamBg,
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = edge
            ..style = PaintingStyle.stroke
            ..strokeWidth = rank >= 0 || locked ? 2.6 : 2,
        );
      }

      // The axis it bends about, drawn through its own centroid and running
      // the width of the cell so it reads as an axis rather than a chord.
      final cell = cellFor(shapes, size, i);
      final axis = _toScreen(shapes, size, i, profile.centroid).dy;
      final dash = Paint()
        ..color = AppColors.ink3
        ..strokeWidth = 1.4;
      for (var x = cell.left + 2; x < cell.right - 2; x += 8) {
        canvas.drawLine(
            Offset(x, axis), Offset(x + 4.5, axis), dash);
      }

      if (rank >= 0) {
        _badge(canvas, Offset(cell.center.dx, cell.top - 15), '${rank + 1}',
            locked ? (right ? AppColors.forest : AppColors.error) : AppColors.ember);
      }
      if (locked && truth.indexOf(i) != rank) {
        _badge(canvas, Offset(cell.center.dx, cell.bottom + 17),
            '${truth.indexOf(i) + 1}', AppColors.forest);
      }
    }
  }

  void _badge(Canvas canvas, Offset at, String text, Color colour) {
    canvas.drawCircle(at, 11, Paint()..color = colour);
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTheme.mono(size: 12, color: AppColors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(LineUpPainter old) =>
      old.shapes != shapes || old.order != order || old.locked != locked;
}

/// Which second moment a job actually needs.
enum Needs {
  /// Bending about the horizontal axis, which a downward load causes.
  iAboutX,

  /// Bending about the vertical axis, which a sideways load causes.
  iAboutY,

  /// Twisting about the member's own length.
  polarJ,
}

/// What is being done to a member.
///
/// The answer follows from the direction of the load and nothing else, which
/// is the point: a section bends about the axis SQUARE to the push, not about
/// whichever of its axes happens to be the stronger one.
@immutable
class Job {
  const Job({required this.load, this.twists = false});

  /// The direction the load pushes, in the section's own coordinates with y
  /// upward. Only the direction matters.
  final Offset load;

  /// Whether it is a torque about the member's own length rather than a push.
  final bool twists;

  Needs get needs {
    if (twists) return Needs.polarJ;
    return load.dy.abs() >= load.dx.abs() ? Needs.iAboutX : Needs.iAboutY;
  }
}

/// A section with the job drawn on it: a straight arrow for a push, a curved
/// one for a twist.
class JobPainter extends CustomPainter {
  const JobPainter({
    required this.profile,
    required this.job,
    this.showAxis = false,
  });

  final Profile profile;
  final Job job;

  /// After answering, marks the axis the bending actually happens about.
  final bool showAxis;

  @override
  void paint(Canvas canvas, Size size) {
    Offset at(Offset w) => ProfilePainter.toScreen(profile, w, size);
    final b = profile.bounds;
    final middle = at(profile.centroid);

    // The section itself, drawn the way every other figure in this chapter
    // draws one.
    ProfilePainter(profile: profile).paint(canvas, size);

    if (showAxis) {
      final ink = Paint()
        ..color = AppColors.forest
        ..strokeWidth = 1.8;
      final long = math.max(
          (at(Offset(b.right, 0)).dx - at(Offset(b.left, 0)).dx).abs(), 60.0);
      if (job.needs == Needs.polarJ) {
        canvas.drawCircle(
          middle,
          9,
          Paint()
            ..color = AppColors.forest
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
        canvas.drawCircle(middle, 3, Paint()..color = AppColors.forest);
      } else if (job.needs == Needs.iAboutX) {
        _chain(canvas, middle - Offset(long / 2 + 14, 0),
            middle + Offset(long / 2 + 14, 0), ink);
      } else {
        final tall = (at(Offset(0, b.top)).dy - at(Offset(0, b.bottom)).dy)
            .abs();
        _chain(canvas, middle - Offset(0, tall / 2 + 14),
            middle + Offset(0, tall / 2 + 14), ink);
      }
    }

    if (job.twists) {
      _twistMark(canvas, middle, size);
      return;
    }

    // World y runs up, screen y runs down.
    final dir = Offset(job.load.dx, -job.load.dy);
    final unit = dir / dir.distance;
    final reach = math.min(size.width, size.height) * 0.30;
    final tip = middle + unit * reach * 0.45;
    final tail = tip - unit * reach;
    final paint = Paint()
      ..color = AppColors.ember
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(tail, tip, paint);
    final side = Offset(-unit.dy, unit.dx);
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - unit.dx * 13 + side.dx * 6.5,
            tip.dy - unit.dy * 13 + side.dy * 6.5)
        ..lineTo(tip.dx - unit.dx * 13 - side.dx * 6.5,
            tip.dy - unit.dy * 13 - side.dy * 6.5)
        ..close(),
      Paint()..color = AppColors.ember,
    );
  }

  /// A torque about the member's own length, drawn as a turn around the
  /// middle of the section.
  void _twistMark(Canvas canvas, Offset middle, Size size) {
    final r = math.min(size.width, size.height) * 0.17;
    final ink = Paint()
      ..color = AppColors.ember
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
        Rect.fromCircle(center: middle, radius: r), -2.6, 4.4, false, ink);
    const head = 1.8;
    final tip = middle + Offset(math.cos(head), math.sin(head)) * r;
    final along = Offset(-math.sin(head), math.cos(head));
    final side = Offset(-along.dy, along.dx);
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - along.dx * 13 + side.dx * 6.5,
            tip.dy - along.dy * 13 + side.dy * 6.5)
        ..lineTo(tip.dx - along.dx * 13 - side.dx * 6.5,
            tip.dy - along.dy * 13 - side.dy * 6.5)
        ..close(),
      Paint()..color = AppColors.ember,
    );
  }

  void _chain(Canvas canvas, Offset from, Offset to, Paint paint) {
    final total = (to - from).distance;
    final step = (to - from) / total;
    var d = 0.0;
    var long = true;
    while (d < total) {
      final run = long ? 12.0 : 3.0;
      canvas.drawLine(
          from + step * d, from + step * math.min(d + run, total), paint);
      d += run + 4;
      long = !long;
    }
  }

  @override
  bool shouldRepaint(JobPainter old) =>
      old.profile != profile ||
      old.job != job ||
      old.showAxis != showAxis;
}
