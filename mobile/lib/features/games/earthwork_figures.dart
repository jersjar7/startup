import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// One cross-section taken at a station along a job.
@immutable
class Slab {
  const Slab({required this.station, required this.area});

  /// Feet along the line, so 100 is station 1+00.
  final double station;

  /// Square feet of cut or fill on that section.
  final double area;

  /// The station written the way a road job writes it.
  String get name {
    final whole = (station / 100).floor();
    final part = (station - whole * 100).round();
    return '$whole+${part.toString().padLeft(2, '0')}';
  }
}

/// A run of cross-sections along a job, and the volumes between them.
@immutable
class Haul {
  const Haul({required this.slabs});

  final List<Slab> slabs;

  double get length => slabs.last.station - slabs.first.station;

  /// The average end area volume worked section by section, which is the
  /// way it is meant to be worked.
  double get byEndAreas {
    var total = 0.0;
    for (var i = 0; i < slabs.length - 1; i++) {
      total += (slabs[i + 1].station - slabs[i].station) /
          2 *
          (slabs[i].area + slabs[i + 1].area);
    }
    return total;
  }

  /// The same method used once across the whole run, skipping everything in
  /// between. It is a different number, and sometimes a startling one.
  double get endToEnd => length / 2 * (slabs.first.area + slabs.last.area);

  /// The prismoidal volume, which needs exactly three sections with the
  /// middle one halfway along.
  double get byPrismoid => slabs.length == 3
      ? length / 6 * (slabs[0].area + 4 * slabs[1].area + slabs[2].area)
      : double.nan;

  /// Where the average of the two end sections sits, which is the line the
  /// middle section gets compared against.
  double get endAverage => (slabs.first.area + slabs.last.area) / 2;

  /// Quantities get paid for in cubic yards, and a cubic yard is twenty
  /// seven cubic feet.
  static const double cubicFeetPerYard = 27;

  double get endAreaYards => byEndAreas / cubicFeetPerYard;
  double get prismoidYards => byPrismoid / cubicFeetPerYard;

  /// Forgetting the two in the average, which doubles the answer.
  double get withoutTheHalf => length * (slabs.first.area + slabs.last.area);
}

/// The run drawn as a profile: a cross-section standing at every station,
/// drawn as a bar whose height is its area, with the stationing along the
/// bottom.
class HaulPainter extends CustomPainter {
  const HaulPainter({
    required this.haul,
    this.showEndAverage = false,
    this.skipMiddle = false,
    this.locked = false,
  });

  final Haul haul;

  /// The dashed line at the average of the two ends. Whether the middle
  /// section stands above or below it is the whole of one round, so it is
  /// drawn from the start: the reader is meant to compare them.
  final bool showEndAverage;

  /// Draw the run as though only the two ends had been taken.
  final bool skipMiddle;
  final bool locked;

  static double _base(Size size) => size.height - 34;

  static double _x(Size size, Haul haul, double station) {
    // Wider on the left than the right, to leave the dashed average line
    // somewhere to be labeled that is not on top of a section.
    final room = size.width - 70;
    final span = math.max(haul.length, 1);
    return 44 + room * (station - haul.slabs.first.station) / span;
  }

  static double _tallest(Haul haul) =>
      math.max(haul.slabs.map((s) => s.area).reduce(math.max), 1);

  /// Headroom above the tallest section, so the number written over it
  /// never lands on the caption along the top of the panel.
  static double _y(Size size, Haul haul, double area) =>
      _base(size) - (_base(size) - 44) * area / _tallest(haul);

  @override
  void paint(Canvas canvas, Size size) {
    final base = _base(size);

    // The ground line the sections stand on, which is the center line of
    // the job seen from the side.
    groundLine(canvas, Offset(10, base), Offset(size.width - 10, base),
        color: AppColors.ink3);

    // The solid between the sections, which is what the volume is.
    final body = Path()..moveTo(_x(size, haul, haul.slabs.first.station), base);
    if (skipMiddle) {
      body
        ..lineTo(_x(size, haul, haul.slabs.first.station),
            _y(size, haul, haul.slabs.first.area))
        ..lineTo(_x(size, haul, haul.slabs.last.station),
            _y(size, haul, haul.slabs.last.area));
    } else {
      for (final s in haul.slabs) {
        body.lineTo(_x(size, haul, s.station), _y(size, haul, s.area));
      }
    }
    body
      ..lineTo(_x(size, haul, haul.slabs.last.station), base)
      ..close();
    canvas.drawPath(
        body, Paint()..color = AppColors.sunbeam.withValues(alpha: 0.25));

    // The average of the two ends, for the round that compares against it.
    if (showEndAverage) {
      final y = _y(size, haul, haul.endAverage);
      for (var x = 14.0; x < size.width - 14; x += 9) {
        canvas.drawLine(
            Offset(x, y),
            Offset(x + 5, y),
            Paint()
              ..color = AppColors.info
              ..strokeWidth = 1.4);
      }
      // In the margin at the left end of the line, where no section stands.
      writeOn(canvas, size, 'avg', Offset(6, y - 5), AppColors.info);
    }

    for (var i = 0; i < haul.slabs.length; i++) {
      final s = haul.slabs[i];
      final x = _x(size, haul, s.station);
      final top = _y(size, haul, s.area);
      final faded = skipMiddle && i > 0 && i < haul.slabs.length - 1;
      final tone = faded ? AppColors.ink3 : AppColors.charcoal;
      // The section itself, drawn as a bar standing on the line.
      canvas.drawLine(
          Offset(x, base),
          Offset(x, top),
          Paint()
            ..color = tone
            ..strokeWidth = faded ? 1.2 : 3);
      if (s.area > 0) {
        canvas.drawCircle(Offset(x, top), 3, Paint()..color = tone);
      }
      writeOn(canvas, size, _num(s.area), Offset(x - 12, top - 15), tone);
      writeOn(canvas, size, s.name, Offset(x - 14, base + 6), AppColors.ink3);
    }

    if (skipMiddle) {
      // Along the top, which is clear: the stationing runs along the
      // bottom and the section numbers sit on their own bars.
      writeOn(canvas, size, 'worked end to end, the middle ignored',
          const Offset(12, 6), AppColors.error);
    }
    writeOn(canvas, size, 'areas in square feet', Offset(12, size.height - 16),
        AppColors.ink3);
    viewTag(canvas, size, Looking.elevation, note: 'along the job');
  }

  @override
  bool shouldRepaint(HaulPainter old) =>
      old.haul != haul ||
      old.showEndAverage != showEndAverage ||
      old.skipMiddle != skipMiddle ||
      old.locked != locked;
}

/// A solid that a job throws up, named by what its far end does.
enum Solid { prism, wedge, point }

extension SolidWords on Solid {
  String get plain => switch (this) {
        Solid.prism => 'the same section all the way',
        Solid.wedge => 'tapering to an edge',
        Solid.point => 'tapering to a point',
      };

  /// How much of the box around it the solid actually fills.
  double get share => switch (this) {
        Solid.prism => 1,
        Solid.wedge => 0.5,
        Solid.point => 1 / 3,
      };
}

/// The three solids drawn in a plain axonometric, with the box around them
/// shown dashed so that the fraction is something you can see rather than
/// something you have to take on faith.
class SolidPainter extends CustomPainter {
  const SolidPainter({required this.solid, this.showBox = true});

  final Solid solid;
  final bool showBox;

  @override
  void paint(Canvas canvas, Size size) {
    // A simple axonometric: x to the right, y up, and depth up and right.
    final o = Offset(size.width * 0.26, size.height * 0.74);
    final long = size.width * 0.44;
    final tall = size.height * 0.40;
    const depth = Offset(26, -16);

    Offset at(double u, double v, double w) =>
        o + Offset(long * u, -tall * v) + depth * w;

    final ink = Paint()
      ..color = AppColors.charcoal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final dash = Paint()
      ..color = AppColors.ink3
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    if (showBox) {
      // The box: the section carried the whole way, which is what the
      // solid is being measured against.
      final box = [
        [at(0, 0, 0), at(1, 0, 0), at(1, 1, 0), at(0, 1, 0)],
        [at(0, 0, 1), at(1, 0, 1), at(1, 1, 1), at(0, 1, 1)],
      ];
      for (final face in box) {
        for (var i = 0; i < 4; i++) {
          canvas.drawLine(face[i], face[(i + 1) % 4], dash);
        }
      }
      for (var i = 0; i < 4; i++) {
        canvas.drawLine(box[0][i], box[1][i], dash);
      }
    }

    Path face(List<Offset> pts) {
      final p = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final q in pts.skip(1)) {
        p.lineTo(q.dx, q.dy);
      }
      return p..close();
    }

    final fill = Paint()..color = AppColors.sunbeam.withValues(alpha: 0.35);

    switch (solid) {
      case Solid.prism:
        final front = face([at(0, 0, 0), at(1, 0, 0), at(1, 1, 0), at(0, 1, 0)]);
        final top = face([at(0, 1, 0), at(1, 1, 0), at(1, 1, 1), at(0, 1, 1)]);
        final side = face([at(1, 0, 0), at(1, 0, 1), at(1, 1, 1), at(1, 1, 0)]);
        canvas
          ..drawPath(top, fill)
          ..drawPath(side, fill)
          ..drawPath(front, fill)
          ..drawPath(front, ink)
          ..drawPath(top, ink)
          ..drawPath(side, ink);
      case Solid.wedge:
        // Full section at the near end, closing to a horizontal edge at the
        // far end: a half.
        final front = face([at(0, 0, 0), at(0, 0, 1), at(0, 1, 1), at(0, 1, 0)]);
        final slope = face([at(0, 1, 0), at(0, 1, 1), at(1, 0, 1), at(1, 0, 0)]);
        final bottom = face([at(0, 0, 0), at(1, 0, 0), at(1, 0, 1), at(0, 0, 1)]);
        canvas
          ..drawPath(bottom, fill)
          ..drawPath(slope, fill)
          ..drawPath(front, fill)
          ..drawPath(front, ink)
          ..drawPath(slope, ink)
          ..drawPath(bottom, ink);
      case Solid.point:
        // Full section at the near end, closing to a single point: a third.
        final tip = at(1, 0, 0.5);
        final front = face([at(0, 0, 0), at(0, 0, 1), at(0, 1, 1), at(0, 1, 0)]);
        canvas
          ..drawPath(front, fill)
          ..drawPath(face([at(0, 1, 0), at(0, 1, 1), tip]), fill)
          ..drawPath(face([at(0, 0, 0), at(0, 1, 0), tip]), fill)
          ..drawPath(front, ink)
          ..drawPath(face([at(0, 1, 0), at(0, 1, 1), tip]), ink)
          ..drawPath(face([at(0, 0, 0), at(0, 1, 0), tip]), ink)
          ..drawPath(face([at(0, 0, 0), at(0, 0, 1), tip]), ink);
    }

    writeOn(canvas, size, 'the section', Offset(o.dx - 22, o.dy - tall - 20),
        AppColors.charcoal);
    if (showBox) {
      writeOn(canvas, size, 'the box around it',
          Offset(size.width - 110, size.height - 30), AppColors.ink3);
    }
    viewTag(canvas, size, Looking.elevation, note: 'drawn in the round');
  }

  @override
  bool shouldRepaint(SolidPainter old) =>
      old.solid != solid || old.showBox != showBox;
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();

