import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// The named points on a tensile test curve.
enum Mark { proportional, yieldPoint, ultimate, fracture }

extension MarkNames on Mark {
  String get plain => switch (this) {
        Mark.proportional => 'the proportional limit',
        Mark.yieldPoint => 'the yield point',
        Mark.ultimate => 'the ultimate strength',
        Mark.fracture => 'the fracture point',
      };

  String get short => switch (this) {
        Mark.proportional => 'proportional limit',
        Mark.yieldPoint => 'yield',
        Mark.ultimate => 'ultimate',
        Mark.fracture => 'fracture',
      };
}

/// One material's tensile test, described by the numbers a test report would
/// actually give, so the curve is a consequence of the material rather than a
/// shape drawn to suit the question.
@immutable
class Specimen {
  const Specimen({
    required this.label,
    required this.e,
    required this.yieldStress,
    required this.ultimate,
    required this.fractureStrain,
    this.plateau = 0,
    this.necksTo = 1,
    this.proportionalShare = 0.85,
  });

  /// What the round calls it.
  final String label;

  /// Modulus of elasticity, in megapascals.
  final double e;

  /// In megapascals.
  final double yieldStress;
  final double ultimate;

  /// Total strain when it breaks. Twenty five percent is 0.25.
  final double fractureStrain;

  /// How long the flat run at yield is, in strain. Mild steel has one and
  /// most other things do not.
  final double plateau;

  /// What is left of the ultimate stress when it finally parts. One means it
  /// breaks at its highest stress, which is what a brittle material does.
  final double necksTo;

  /// Where Hooke's law gives out, as a share of the yield stress.
  final double proportionalShare;

  double get proportionalStress => yieldStress * proportionalShare;
  double get proportionalStrain => proportionalStress / e;

  /// The knee between the proportional limit and yield is softer than the
  /// straight run, which is what makes it a knee.
  double get yieldStrain =>
      proportionalStrain + (yieldStress - proportionalStress) / (e * 0.5);

  double get plateauEnd => yieldStrain + plateau;

  /// Where it is carrying the most, which is also where necking starts.
  double get ultimateStrain => necksTo >= 1
      ? fractureStrain
      : plateauEnd + 0.62 * (fractureStrain - plateauEnd);

  double get fractureStress => ultimate * necksTo;

  /// Percent elongation, which is the ductility number a test report quotes.
  double get elongation => fractureStrain * 100;

  /// The lesson's own two tells, and it takes both: a material that breaks
  /// about where it yields, having stretched almost nowhere.
  bool get brittle =>
      elongation < 5 && (ultimate - yieldStress) < 0.05 * ultimate;

  /// Strain and stress of a named point.
  Offset pointAt(Mark mark) => switch (mark) {
        Mark.proportional => Offset(proportionalStrain, proportionalStress),
        Mark.yieldPoint => Offset(yieldStrain, yieldStress),
        Mark.ultimate => Offset(ultimateStrain, ultimate),
        Mark.fracture => Offset(fractureStrain, fractureStress),
      };

  /// The curve itself, in strain and stress, start to break.
  List<Offset> get trace {
    final out = <Offset>[Offset.zero];

    // Straight while Hooke's law holds.
    out.add(Offset(proportionalStrain, proportionalStress));

    // The knee, bending over to yield.
    for (var i = 1; i <= 8; i++) {
      final t = i / 8;
      final x = proportionalStrain + (yieldStrain - proportionalStrain) * t;
      final y = proportionalStress +
          (yieldStress - proportionalStress) * math.sin(t * math.pi / 2);
      out.add(Offset(x, y));
    }

    // The flat run, if this material has one.
    if (plateau > 0) out.add(Offset(plateauEnd, yieldStress));

    // Hardening up to the ultimate.
    if (ultimateStrain > plateauEnd) {
      for (var i = 1; i <= 14; i++) {
        final t = i / 14;
        final x = plateauEnd + (ultimateStrain - plateauEnd) * t;
        final y = yieldStress +
            (ultimate - yieldStress) * math.sin(t * math.pi / 2);
        out.add(Offset(x, y));
      }
    }

    // And down through necking, if it necks.
    if (necksTo < 1) {
      for (var i = 1; i <= 8; i++) {
        final t = i / 8;
        final x = ultimateStrain + (fractureStrain - ultimateStrain) * t;
        final y = ultimate - (ultimate - fractureStress) * math.pow(t, 1.4);
        out.add(Offset(x, y));
      }
    }
    return out;
  }
}

/// The axes one or more curves are drawn on.
///
/// A pair being compared shares one of these, because a comparison of two
/// curves drawn to two scales is not a comparison of anything.
@immutable
class Frame {
  const Frame({
    required this.prop,
    required this.knee,
    required this.maxStrain,
    required this.maxStress,
    this.elasticShare = 0.22,
    this.kneeShare = 0.20,
    this.knots = const <double>[],
    this.spots = const <double>[],
  });

  /// The axes for pointing at named points on ONE curve.
  ///
  /// This one is a schematic: the axis is handed out by FEATURE rather than
  /// by strain, so much the way a textbook draws it. Each stretch of the
  /// curve, the straight run, the knee, the flat run at yield if there is
  /// one, the climb to the top and the drop to the break, gets a share of the
  /// width big enough to see and to put a thumb on. A material with no yield
  /// plateau is drawn with no flat run, which is the whole tell, and at true
  /// scale nobody could see either one.
  factory Frame.over(List<Specimen> all) {
    final s = all.first;
    final knots = <double>[0, s.proportionalStrain, s.yieldStrain];
    final spots = <double>[0, 0.16, 0.32];
    if (s.plateau > 0) {
      // A short flat run is drawn short. Mild steel's is the long one this is
      // measured against, so a steel with a quarter of the plateau gets a
      // quarter of the room and the drawing does not flatter it.
      knots.add(s.plateauEnd);
      spots.add(0.32 + 0.16 * math.min(1, s.plateau / 0.014));
    }
    if (s.necksTo < 1) {
      knots.add(s.ultimateStrain);
      spots.add(0.86);
    }
    knots.add(s.fractureStrain);
    spots.add(1);
    return Frame(
      prop: s.proportionalStrain,
      knee: s.yieldStrain,
      maxStrain: s.fractureStrain,
      maxStress: s.ultimate * 1.18,
      knots: knots,
      spots: spots,
    );
  }

  /// The axes for COMPARING two curves. The early part gets much less room
  /// here, because a reader is being asked to judge how far each one gets
  /// before it breaks and a fat elastic run flatters the brittle one.
  factory Frame.comparing(List<Specimen> all) => Frame._of(all, 0.12, 0.08);

  factory Frame._of(List<Specimen> all, double elastic, double knee) => Frame(
        prop: all.map((s) => s.proportionalStrain).reduce(math.max),
        knee: all.map((s) => s.yieldStrain).reduce(math.max),
        maxStrain: all.map((s) => s.fractureStrain).reduce(math.max) * 1.12,
        maxStress: all.map((s) => s.ultimate).reduce(math.max) * 1.18,
        elasticShare: elastic,
        kneeShare: knee,
      );

  /// Where the straight run ends and where the knee ends.
  final double prop;
  final double knee;
  final double maxStrain;
  final double maxStress;

  /// A schematic frame's milestones, in strain, and where each one is put
  /// along the axis. Empty on a frame that maps strain straight across.
  final List<double> knots;
  final List<double> spots;

  /// The shares of the strain axis given to the straight run and to the knee.
  ///
  /// Steel yields at about a tenth of a percent of strain and breaks at
  /// twenty five, so at true scale the first two named points are the same
  /// pixel and nothing can be pointed at. Every textbook stretches the early
  /// part and so does this, with the axis left unnumbered and the panel
  /// saying so. Every curve on one set of axes goes through the SAME stretch,
  /// so a steeper line is still a stiffer material and a longer one still
  /// reaches further.
  final double elasticShare;
  final double kneeShare;
}

/// One tensile curve, drawn on axes.
class TensilePainter extends CustomPainter {
  const TensilePainter({
    required this.specimen,
    required this.frame,
    this.tone = AppColors.info,
    this.labelled = const <Mark>[],
    this.dotted = const <Mark>[],
    this.wrong,
    this.axes = true,
  });

  final Specimen specimen;
  final Frame frame;
  final Color tone;

  /// Points to name on the drawing. Empty while the round is being asked,
  /// because a label is the answer.
  final List<Mark> labelled;

  /// Points to show as a dot without naming them.
  final List<Mark> dotted;

  /// A point the reader chose that was not the one asked for.
  final Mark? wrong;

  /// False for the second curve of a pair, which shares the first one's axes.
  final bool axes;

  /// The axes box, inside the room the labels need.
  static Rect plot(Size size) => Rect.fromLTRB(
        34,
        18,
        size.width - 10,
        size.height - 24,
      );

  /// Where a strain and a stress land on the canvas.
  static Offset at(Frame frame, Size size, Offset point) {
    final box = plot(size);
    final s = point.dx;
    final y = box.bottom - box.height * (point.dy / frame.maxStress);
    if (frame.knots.isNotEmpty) {
      return Offset(box.left + box.width * _milestone(frame, s), y);
    }
    final a = frame.elasticShare;
    final b = frame.kneeShare;
    final double on;
    if (s <= frame.prop) {
      on = a * (s / frame.prop);
    } else if (s <= frame.knee) {
      on = a + b * (s - frame.prop) / (frame.knee - frame.prop);
    } else {
      on = a +
          b +
          (1 - a - b) * (s - frame.knee) / (frame.maxStrain - frame.knee);
    }
    return Offset(box.left + box.width * on, y);
  }

  /// Where a strain lands on a schematic axis: straight lines between the
  /// milestones, so the order never changes and no stretch of curve can
  /// vanish.
  static double _milestone(Frame frame, double strain) {
    final k = frame.knots;
    final v = frame.spots;
    if (strain <= k.first) return v.first;
    for (var i = 1; i < k.length; i++) {
      if (strain <= k[i]) {
        final span = k[i] - k[i - 1];
        final on = span <= 0 ? 1.0 : (strain - k[i - 1]) / span;
        return v[i - 1] + (v[i] - v[i - 1]) * on;
      }
    }
    return v.last;
  }

  /// Where a named point is drawn. Tap targets come from here rather than
  /// from an assumption about where the painter put it.
  static Offset markAt(Specimen s, Frame frame, Size size, Mark mark) =>
      at(frame, size, s.pointAt(mark));

  /// The named point nearest a tap, or nothing if the tap was not near one.
  static Mark? nearest(
    Specimen s,
    Frame frame,
    Size size,
    Offset tap,
    List<Mark> among, {
    double within = 40,
  }) {
    Mark? best;
    var bestGap = within;
    for (final m in among) {
      final gap = (markAt(s, frame, size, m) - tap).distance;
      if (gap < bestGap) {
        bestGap = gap;
        best = m;
      }
    }
    return best;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final box = plot(size);
    if (axes) _axes(canvas, size, box);
    final path = Path();
    final trace = specimen.trace;
    for (var i = 0; i < trace.length; i++) {
      final p = at(frame, size, trace[i]);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = tone
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeJoin = StrokeJoin.round,
    );

    // Where it breaks, on the curve, so a short brittle curve still reads as
    // having ended rather than as having been cut off.
    final end = at(frame, size, specimen.pointAt(Mark.fracture));
    canvas.drawLine(end + const Offset(-4, -4), end + const Offset(4, 4),
        Paint()..color = tone..strokeWidth = 1.8);
    canvas.drawLine(end + const Offset(4, -4), end + const Offset(-4, 4),
        Paint()..color = tone..strokeWidth = 1.8);

    for (final m in dotted) {
      _dot(canvas, markAt(specimen, frame, size, m), tone);
    }
    if (wrong != null) {
      _dot(canvas, markAt(specimen, frame, size, wrong!), AppColors.error);
    }
    // Labels last, so nothing is drawn over them.
    for (final m in labelled) {
      final at_ = markAt(specimen, frame, size, m);
      _dot(canvas, at_, AppColors.forest);
      _tag(canvas, m.short, at_, size);
    }
  }

  void _axes(Canvas canvas, Size size, Rect box) {
    final axis = Paint()
      ..color = AppColors.charcoal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawLine(box.bottomLeft, box.bottomRight, axis);
    canvas.drawLine(box.bottomLeft, box.topLeft, axis);
    _head(canvas, box.bottomRight, const Offset(1, 0));
    _head(canvas, box.topLeft, const Offset(0, -1));
    _write(canvas, 'strain', Offset(box.right - 34, box.bottom + 5),
        AppColors.ink3);
    _write(canvas, 'stress', const Offset(2, 0), AppColors.ink3);
  }

  void _dot(Canvas canvas, Offset at, Color color) {
    canvas
      ..drawCircle(at, 5.5, Paint()..color = AppColors.cream)
      ..drawCircle(at, 4, Paint()..color = color);
  }

  /// A name beside a point, kept inside the panel and away from the curve.
  void _tag(Canvas canvas, String text, Offset at, Size size) {
    final painter = TextPainter(
      text: TextSpan(
          text: text, style: AppTheme.mono(size: 10, color: AppColors.forest)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx - painter.width / 2;
    var y = at.dy - painter.height - 9;
    if (y < 0) y = at.dy + 9;
    if (x < 1) x = 1;
    if (x + painter.width > size.width - 1) x = size.width - 1 - painter.width;
    final patch = Rect.fromLTWH(x - 2, y - 1, painter.width + 4, painter.height + 2);
    canvas.drawRect(patch, Paint()..color = AppColors.cream.withValues(alpha: 0.9));
    painter.paint(canvas, Offset(x, y));
  }

  void _head(Canvas canvas, Offset tip, Offset along) {
    final back = Offset(-along.dx, -along.dy) * 6;
    final side = Offset(-along.dy, along.dx) * 3;
    final p = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx + back.dx + side.dx, tip.dy + back.dy + side.dy)
      ..lineTo(tip.dx + back.dx - side.dx, tip.dy + back.dy - side.dy)
      ..close();
    canvas.drawPath(p, Paint()..color = AppColors.charcoal);
  }

  void _write(Canvas canvas, String text, Offset at, Color color) {
    TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, at);
  }

  @override
  bool shouldRepaint(TensilePainter old) =>
      old.specimen != specimen ||
      old.labelled != labelled ||
      old.dotted != dotted ||
      old.wrong != wrong;
}

/// Two curves on one set of axes, for comparing.
class PairPainter extends CustomPainter {
  const PairPainter({required this.left, required this.right, this.frame});

  final Specimen left;
  final Specimen right;
  final Frame? frame;

  @override
  void paint(Canvas canvas, Size size) {
    final f = frame ?? Frame.comparing([left, right]);
    TensilePainter(specimen: left, frame: f, tone: AppColors.info)
        .paint(canvas, size);
    TensilePainter(
      specimen: right,
      frame: f,
      tone: AppColors.ember,
      axes: false,
    ).paint(canvas, size);
  }

  @override
  bool shouldRepaint(PairPainter old) =>
      old.left != left || old.right != right;
}
