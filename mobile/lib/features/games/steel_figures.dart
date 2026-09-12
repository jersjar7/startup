import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';
import 'virtual_work_figures.dart' show pinMark, rollerMark;

/// What a beam's bending capacity comes to, once the distance between its
/// braces has been taken into account.
enum Gets { fullPlastic, inelastic, elastic }

/// A beam and the braces along it. Everything the item asks comes from the
/// numbers here rather than from words beside the drawing.
@immutable
class Braced {
  const Braced({
    required this.span,
    required this.braceEvery,
    required this.lp,
    required this.lr,
    this.continuous = false,
  });

  /// All in feet.
  final double span;

  /// How far apart the braces are, which is the unbraced length.
  final double braceEvery;
  final double lp;
  final double lr;

  /// A slab on top, holding the compression flange all the way along.
  final bool continuous;

  double get unbraced => continuous ? 0 : braceEvery;

  Gets get reach {
    if (unbraced <= lp) return Gets.fullPlastic;
    if (unbraced <= lr) return Gets.inelastic;
    return Gets.elastic;
  }

  /// Where the braces sit along the span, ends included.
  List<double> get braces {
    if (continuous || braceEvery <= 0) return const [];
    final out = <double>[];
    for (var x = 0.0; x <= span + 0.001; x += braceEvery) {
      out.add(math.min(x, span));
    }
    if (out.last < span - 0.001) out.add(span);
    return out;
  }
}

/// The beam in elevation with its braces marked, and the unbraced length
/// dimensioned against the two lengths the code tabulates. The comparison is
/// the question, so the three lengths are drawn to one scale.
class BracePainter extends CustomPainter {
  const BracePainter({required this.beam, this.answered = false});

  final Braced beam;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 30.0;
    final right = size.width - 30;
    final y = size.height * 0.34;
    double xOf(double at) => left + at / beam.span * (right - left);

    // The beam, drawn as a shallow I with a top flange the braces hold.
    canvas
      ..drawLine(
          Offset(left, y),
          Offset(right, y),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 4)
      ..drawLine(
          Offset(left, y + 12),
          Offset(right, y + 12),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 4)
      ..drawLine(
          Offset(left, y + 6),
          Offset(right, y + 6),
          Paint()
            ..color = AppColors.ink3
            ..strokeWidth = 1.4);
    pinMark(canvas, Offset(left, y + 12));
    rollerMark(canvas, Offset(right, y + 12));

    if (beam.continuous) {
      // A slab sitting on the top flange, hatched, holding it everywhere.
      final slab = Rect.fromLTRB(left - 6, y - 14, right + 6, y - 3);
      canvas.drawRect(
          slab,
          Paint()
            ..color = AppColors.ink2
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4);
      hatchIn(canvas, Path()..addRect(slab), step: 7);
      writeOn(canvas, size, 'a slab along the whole top flange',
          Offset(left, y - 28), AppColors.forest, fontSize: 9.5);
    } else {
      for (final at in beam.braces) {
        final x = xOf(at);
        canvas
          ..drawLine(
              Offset(x, y - 16),
              Offset(x, y - 2),
              Paint()
                ..color = AppColors.forest
                ..strokeWidth = 2.4)
          ..drawCircle(
              Offset(x, y - 18), 2.6, Paint()..color = AppColors.forest);
      }
      writeOn(canvas, size, 'braces on the top flange', Offset(left, y - 34),
          AppColors.forest, fontSize: 9.5);
    }

    // The three lengths, to one scale, under the beam.
    var row = y + 44;
    for (final (v, name, tone) in [
      (beam.unbraced, 'the gap between braces', AppColors.ember),
      (beam.lp, 'the full strength limit', AppColors.info),
      (beam.lr, 'the buckling limit', AppColors.ink3),
    ]) {
      final end = xOf(math.min(v, beam.span));
      canvas
        ..drawLine(
            Offset(left, row),
            Offset(math.max(end, left + 1), row),
            Paint()
              ..color = tone
              ..strokeWidth = 3)
        ..drawLine(Offset(left, row - 4), Offset(left, row + 4),
            Paint()..color = tone)
        ..drawLine(Offset(math.max(end, left + 1), row - 4),
            Offset(math.max(end, left + 1), row + 4), Paint()..color = tone);
      writeOn(canvas, size, '$name, ${_num(v)} ft',
          Offset(math.max(end, left + 1) + 6, row - 5), tone, fontSize: 9.5);
      row += 18;
    }

    viewTag(canvas, size, Looking.elevation, note: 'the beam');
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  bool shouldRepaint(BracePainter old) =>
      old.beam != beam || old.answered != answered;
}

/// A W shape seen end on, with one part of it called out. Which flange is in
/// compression is the whole of the bracing question, and it is not always
/// the top one.
enum Part2 { topFlange, bottomFlange, web, none }

/// The beam end on, with the called-out part in orange and, once the round
/// is over, which way it wants to move.
class ShapePainter extends CustomPainter {
  const ShapePainter({
    required this.part,
    this.sagging = true,
    this.answered = false,
  });

  final Part2 part;

  /// Sagging puts the top flange in compression; hogging puts the bottom
  /// one there, which is the round most people get wrong.
  final bool sagging;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    const halfW = 46.0;
    const halfH = 40.0;
    const t = 9.0;

    final top = Rect.fromLTRB(cx - halfW, cy - halfH, cx + halfW, cy - halfH + t);
    final bottom =
        Rect.fromLTRB(cx - halfW, cy + halfH - t, cx + halfW, cy + halfH);
    final web = Rect.fromLTRB(cx - 5, cy - halfH + t, cx + 5, cy + halfH - t);

    // Nothing is lit when the round is asking the reader to find the part
    // rather than to name the one that has been pointed at.
    Color toneFor(Part2 which) =>
        part == which ? AppColors.ember : AppColors.charcoal;

    for (final (r, which) in [
      (top, Part2.topFlange),
      (bottom, Part2.bottomFlange),
      (web, Part2.web),
    ]) {
      canvas.drawRect(r, Paint()..color = toneFor(which));
    }

    writeOn(canvas, size, sagging ? 'sagging: the middle of a span' : 'hogging: over a support',
        const Offset(8, 8), AppColors.ink3, fontSize: 9.5);

    if (answered) {
      final compressed = sagging ? top : bottom;
      writeOn(canvas, size, 'this flange is in compression',
          Offset(cx - 74, compressed.center.dy - 26), AppColors.forest,
          fontSize: 9.5);
      // Which way it wants to go, drawn as a pair of arrows sideways.
      for (final dir in [-1.0, 1.0]) {
        final from = Offset(cx + dir * (halfW + 4), compressed.center.dy);
        final to = from + Offset(dir * 22, 0);
        canvas.drawLine(
            from,
            to,
            Paint()
              ..color = AppColors.forest
              ..strokeWidth = 2);
      }
    }

    viewTag(canvas, size, Looking.section, note: 'the beam');
  }

  @override
  bool shouldRepaint(ShapePainter old) =>
      old.part != part || old.sagging != sagging || old.answered != answered;
}

/// Which axis a column would fold about, and how far it is held for each.
enum Axis2 { strong, weak, either }

/// A column, with what braces it about each of its two axes. The strong axis
/// bends the deep way and the weak axis the shallow way, and a brace only
/// shortens the length for the axis it is fitted to.
@immutable
class Post {
  const Post({
    required this.height,
    required this.rx,
    required this.ry,
    this.weakBraces = 1,
    this.strongBraces = 1,
  });

  /// In feet.
  final double height;

  /// The two radii of gyration, in inches. A W shape has the larger one
  /// about its strong axis.
  final double rx;
  final double ry;

  /// How many clear lengths the column is divided into about each axis: one
  /// means braced at the ends only.
  final int weakBraces;
  final int strongBraces;

  double get weakLength => height / weakBraces;
  double get strongLength => height / strongBraces;

  /// Slenderness about each axis, in consistent units.
  double get weakRatio => weakLength * 12 / ry;
  double get strongRatio => strongLength * 12 / rx;

  /// The larger slenderness is the one that decides the column.
  Axis2 get decides {
    if ((weakRatio - strongRatio).abs() < 0.5) return Axis2.either;
    return weakRatio > strongRatio ? Axis2.weak : Axis2.strong;
  }
}

/// The column drawn twice, once for each axis, with the braces that apply to
/// that axis and the shape it would buckle into between them.
class AxisPainter extends CustomPainter {
  const AxisPainter({required this.post, this.answered = false});

  final Post post;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final half = size.width / 2;
    _one(canvas, size, Rect.fromLTWH(0, 16, half, size.height - 34),
        strong: true);
    _one(canvas, size, Rect.fromLTWH(half, 16, half, size.height - 34),
        strong: false);
    canvas.drawLine(
        Offset(half, 20),
        Offset(half, size.height - 20),
        Paint()
          ..color = AppColors.line
          ..strokeWidth = 1);
    viewTag(canvas, size, Looking.elevation, note: 'the column');
  }

  void _one(Canvas canvas, Size size, Rect box, {required bool strong}) {
    final x = box.center.dx;
    final top = box.top + 16;
    final bottom = box.bottom - 16;
    final pieces = strong ? post.strongBraces : post.weakBraces;

    canvas.drawLine(
        Offset(x, top),
        Offset(x, bottom),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 4);

    // The braces that count for this axis, drawn as a pair of stubs.
    for (var i = 1; i < pieces; i++) {
      final y = top + (bottom - top) * i / pieces;
      for (final dir in [-1.0, 1.0]) {
        canvas.drawLine(
            Offset(x + dir * 3, y),
            Offset(x + dir * 20, y),
            Paint()
              ..color = AppColors.forest
              ..strokeWidth = 2.4);
      }
    }

    // The shape it would go into between braces, one bow per clear length.
    final bow = Path()..moveTo(x, top);
    final piece = (bottom - top) / pieces;
    for (var i = 0; i < pieces; i++) {
      final a = top + piece * i;
      final side = i.isEven ? 1 : -1;
      bow.quadraticBezierTo(x + side * 16, a + piece / 2, x, a + piece);
    }
    canvas.drawPath(
        bow,
        Paint()
          ..color = AppColors.ember
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8);

    writeOn(
        canvas,
        size,
        strong ? 'the deep way' : 'the shallow way',
        Offset(box.left + 8, box.top - 12),
        AppColors.ink3,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        strong
            ? 'r = ${_num(post.rx)} in, free over ${_num(post.strongLength)} ft'
            : 'r = ${_num(post.ry)} in, free over ${_num(post.weakLength)} ft',
        Offset(box.left + 8, box.bottom - 6),
        AppColors.ink3,
        fontSize: 9.5);
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  bool shouldRepaint(AxisPainter old) =>
      old.post != post || old.answered != answered;
}
