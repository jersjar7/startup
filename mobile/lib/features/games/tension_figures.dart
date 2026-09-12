import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// Which of the two limit states decides a tension member.
enum Limit { yielding, rupture, tie }

/// A flat bar in tension with bolt holes across it. The two areas and the
/// two design strengths are worked out here so no round can quote a number
/// its own drawing does not give.
@immutable
class Tie {
  const Tie({
    required this.width,
    required this.thickness,
    required this.holes,
    this.trailing = 0,
    required this.boltDiameter,
    required this.fy,
    required this.fu,
    this.u = 1.0,
  });

  /// Inches.
  final double width;
  final double thickness;

  /// How many holes sit on the one cross-section, which is the number the
  /// net area pays for.
  final int holes;

  /// Bolts further along the member, each on a cross-section of its own.
  /// They are drawn, because the round is about them, and they do not come
  /// off the net section, because they are not on it.
  final int trailing;
  final double boltDiameter;

  /// Stresses in ksi.
  final double fy;
  final double fu;

  /// The shear lag factor, which is one when every part of the section is
  /// connected.
  final double u;

  double get gross => width * thickness;

  /// A hole is punched a sixteenth over the bolt and another sixteenth is
  /// written off as damage, so the width lost is the bolt plus an eighth.
  double get holeLoss => boltDiameter + 0.125;

  double get net => (width - holes * holeLoss) * thickness;
  double get effective => u * net;

  double get yieldStrength => 0.90 * fy * gross;
  double get ruptureStrength => 0.75 * fu * effective;

  Limit get controls {
    if ((yieldStrength - ruptureStrength).abs() < 0.5) return Limit.tie;
    return yieldStrength < ruptureStrength ? Limit.yielding : Limit.rupture;
  }

  double get design => math.min(yieldStrength, ruptureStrength);
}

/// The bar seen flat on, with its holes, and the two sections the two limit
/// states care about drawn where they cut.
class TiePainter extends CustomPainter {
  const TiePainter({
    required this.tie,
    this.showSections = true,
    this.answered = false,
  });

  final Tie tie;

  /// Whether to mark the gross section and the section through the holes.
  final bool showSections;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min((size.width - 90) / 14, (size.height - 70) / 12);
    final w = tie.width * scale;
    final barLength = size.width - 40;
    final cy = size.height * 0.48;
    final rect = Rect.fromCenter(
        center: Offset(size.width / 2, cy), width: barLength, height: w);

    canvas.drawRect(
        rect,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // The pull, both ends.
    for (final dir in [-1.0, 1.0]) {
      final from = Offset(rect.center.dx + dir * (barLength / 2 + 4), cy);
      canvas.drawLine(
          from,
          from + Offset(dir * 16, 0),
          Paint()
            ..color = AppColors.ink3
            ..strokeWidth = 2);
    }

    // The holes, on one cross-section two thirds of the way along, with any
    // trailing bolts strung out behind them on their own sections.
    final holeX = rect.left + barLength * 0.66;
    final r = tie.holeLoss * scale / 2;
    void hole(Offset at) {
      canvas
        ..drawCircle(at, math.max(r, 3), Paint()..color = AppColors.cream)
        ..drawCircle(
            at,
            math.max(r, 3),
            Paint()
              ..color = AppColors.charcoal
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4);
    }

    for (var i = 0; i < tie.holes; i++) {
      final t = (i + 1) / (tie.holes + 1);
      hole(Offset(holeX, rect.top + w * t));
    }
    for (var i = 0; i < tie.trailing; i++) {
      hole(Offset(holeX - 34 * (i + 1), rect.center.dy));
    }

    if (showSections) {
      // Where each limit state does its arithmetic.
      final grossX = rect.left + barLength * 0.25;
      _cut(canvas, size, grossX, rect, AppColors.info, 'the gross section');
      _cut(canvas, size, holeX, rect, AppColors.ember, 'the net section');
    }

    writeOn(
        canvas,
        size,
        '${_num(tie.width)} in wide, ${_num(tie.thickness)} in thick',
        Offset(rect.right - 92, rect.top - 22),
        AppColors.ink3,
        fontSize: 9.5);
    final bolts = tie.holes + tie.trailing;
    if (bolts > 0) {
      writeOn(
          canvas,
          size,
          '$bolts bolts of ${_num(tie.boltDiameter)} in',
          Offset(rect.left, rect.top - 22),
          AppColors.ink3,
          fontSize: 9.5);
    }
    viewTag(canvas, size, Looking.plan, note: 'the bar');
  }

  void _cut(Canvas canvas, Size size, double x, Rect rect, Color tone,
      String label) {
    for (var y = rect.top - 8; y < rect.bottom + 8; y += 7) {
      canvas.drawLine(
          Offset(x, y),
          Offset(x, math.min(y + 4, rect.bottom + 8)),
          Paint()
            ..color = tone
            ..strokeWidth = 1.6);
    }
    writeOn(canvas, size, label, Offset(x - 28, rect.bottom + 24), tone,
        fontSize: 9.5);
  }

  static String _num(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '');
  }

  @override
  bool shouldRepaint(TiePainter old) =>
      old.tie != tie ||
      old.showSections != showSections ||
      old.answered != answered;
}

/// What part of a section a connection actually grips, seen end on. Shear
/// lag is entirely about this picture.
enum Grip { allOfIt, oneLeg, flangesOnly }

/// An angle or an I seen end on, with the connected part picked out, and the
/// unconnected part left plain so the reason for the reduction can be seen.
class GripPainter extends CustomPainter {
  const GripPainter({required this.grip, this.answered = false});

  final Grip grip;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.52;
    const t = 9.0;

    switch (grip) {
      case Grip.allOfIt:
        // A flat bar, gripped right across.
        final bar = Rect.fromCenter(
            center: Offset(cx, cy), width: 108, height: t + 3);
        canvas.drawRect(bar, Paint()..color = AppColors.ember);
        writeOn(canvas, size, 'a flat bar, bolted across its whole width',
            Offset(cx - 96, cy - 30), AppColors.ink3, fontSize: 9.5);
      case Grip.oneLeg:
        // An angle: the vertical leg connected, the horizontal one not.
        final upright = Rect.fromLTWH(cx - 34, cy - 42, t, 84);
        final out = Rect.fromLTWH(cx - 34, cy + 42 - t, 76, t);
        canvas
          ..drawRect(upright, Paint()..color = AppColors.ember)
          ..drawRect(out, Paint()..color = AppColors.charcoal);
        writeOn(canvas, size, 'bolted through this leg only',
            Offset(cx - 96, cy - 54), AppColors.ember, fontSize: 9.5);
        if (answered) {
          writeOn(canvas, size, 'this leg has to catch up along the length',
              Offset(cx - 30, cy + 48), AppColors.forest, fontSize: 9.5);
        }
      case Grip.flangesOnly:
        // A W shape connected through its flanges, the web left out.
        final top = Rect.fromLTWH(cx - 46, cy - 40, 92, t);
        final bottom = Rect.fromLTWH(cx - 46, cy + 40 - t, 92, t);
        final web = Rect.fromLTWH(cx - 5, cy - 40 + t, 10, 80 - 2 * t);
        canvas
          ..drawRect(top, Paint()..color = AppColors.ember)
          ..drawRect(bottom, Paint()..color = AppColors.ember)
          ..drawRect(web, Paint()..color = AppColors.charcoal);
        writeOn(canvas, size, 'bolted through the flanges only',
            Offset(cx - 96, cy - 54), AppColors.ember, fontSize: 9.5);
        if (answered) {
          writeOn(canvas, size, 'the web has to catch up',
              Offset(cx + 12, cy), AppColors.forest, fontSize: 9.5);
        }
    }

    writeOn(canvas, size, 'orange: what the bolts actually hold',
        Offset(8, size.height - 16), AppColors.ember, fontSize: 9.5);
    viewTag(canvas, size, Looking.section, note: 'the member');
  }

  @override
  bool shouldRepaint(GripPainter old) =>
      old.grip != grip || old.answered != answered;
}
