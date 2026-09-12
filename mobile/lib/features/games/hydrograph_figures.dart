import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// A hydrograph: what the discharge at the outlet does over the hours after
/// a storm. Drawn as a curve that climbs to a peak and falls away more
/// slowly, which is the shape every real one has.
@immutable
class Wave {
  const Wave({
    required this.peak,
    required this.toPeak,
    required this.base,
  });

  /// The highest discharge the storm produces, in cubic feet a second.
  final double peak;

  /// Hours from the start of runoff to the peak.
  final double toPeak;

  /// Hours from the start to the end of direct runoff.
  final double base;

  /// A unit hydrograph scaled for a storm of this many inches of excess
  /// rainfall. Every ORDINATE is multiplied; the times are untouched,
  /// because the watershed routes water at the same speed whatever the
  /// storm does.
  Wave forRain(double inches) =>
      Wave(peak: peak * inches, toPeak: toPeak, base: base);

  /// What a wrongly stretched hydrograph would look like: the times pulled
  /// about instead of the flows. Drawn only to be rejected.
  Wave stretched(double by) =>
      Wave(peak: peak, toPeak: toPeak * by, base: base * by);

  double at(double hour) {
    if (hour <= 0 || hour >= base) return 0;
    if (hour <= toPeak) {
      final t = hour / toPeak;
      return peak * t * t * (3 - 2 * t) / 1;
    }
    final t = (hour - toPeak) / (base - toPeak);
    return peak * (1 - t) * (1 - t);
  }

  /// The volume under the curve, in cfs-hours. A unit hydrograph's volume
  /// is one inch over the watershed, and scaling for a three inch storm
  /// triples it.
  double get volume {
    var sum = 0.0;
    const steps = 400;
    for (var i = 0; i < steps; i++) {
      sum += at(base * (i + 0.5) / steps) * base / steps;
    }
    return sum;
  }
}

/// One or more hydrographs on one pair of axes.
class HydrographPainter extends CustomPainter {
  const HydrographPainter({
    required this.waves,
    this.names = const [],
    this.tones = const [],
    this.markAt,
    this.markLabel,
    this.topFlow,
    this.hours,
    this.note,
  });

  final List<Wave> waves;
  final List<String> names;
  final List<Color> tones;

  /// An hour the round is asking about, drawn as a vertical line.
  final double? markAt;
  final String? markLabel;

  /// The top of the discharge axis, when it has to be held fixed across
  /// two drawings so they can be compared.
  final double? topFlow;
  final double? hours;
  final String? note;

  static const _left = 44.0;
  static const _bottom = 34.0;
  static const _top = 18.0;
  static const _right = 12.0;

  double get _span =>
      hours ?? waves.map((w) => w.base).reduce(math.max) * 1.05;

  double get _tallest =>
      topFlow ?? waves.map((w) => w.peak).reduce(math.max) * 1.18;

  Offset _at(Size size, double hour, double flow) => Offset(
        _left + (size.width - _left - _right) * hour / _span,
        size.height -
            _bottom -
            (size.height - _bottom - _top) * flow / _tallest,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1.2;
    canvas
      ..drawLine(Offset(_left, _top), Offset(_left, size.height - _bottom),
          axis)
      ..drawLine(Offset(_left, size.height - _bottom),
          Offset(size.width - _right, size.height - _bottom), axis);
    writeOn(canvas, size, 'cfs', const Offset(6, 10), AppColors.ink3,
        fontSize: 9);
    writeOn(canvas, size, 'hours',
        Offset(size.width - 46, size.height - 15), AppColors.ink3,
        fontSize: 9);

    for (var i = 0; i < waves.length; i++) {
      final wave = waves[i];
      final tone = i < tones.length ? tones[i] : AppColors.charcoal;
      final path = Path();
      for (var step = 0; step <= 120; step++) {
        final hour = _span * step / 120;
        final p = _at(size, hour, wave.at(hour));
        if (step == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = tone
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4);
      if (i < names.length) {
        final top = _at(size, wave.toPeak, wave.peak);
        writeOn(canvas, size, names[i], top + const Offset(4, -14), tone,
            fontSize: 9.5);
      }
    }

    if (markAt != null) {
      final x = _at(size, markAt!, 0).dx;
      for (var y = _top; y < size.height - _bottom; y += 8) {
        canvas.drawLine(
            Offset(x, y),
            Offset(x, y + 4),
            Paint()
              ..color = AppColors.ember
              ..strokeWidth = 1.4);
      }
      if (markLabel != null) {
        writeOn(canvas, size, markLabel!, Offset(x + 4, _top), AppColors.ember,
            fontSize: 9.5);
      }
    }

    if (note != null) {
      writeOn(canvas, size, note!, const Offset(_left + 6, 4), AppColors.ink2,
          fontSize: 9);
    }
    // Top right, because the bottom right belongs to the time axis label.
    writeOn(canvas, size, 'HYDROGRAPH', Offset(size.width, 4), AppColors.ink3,
        fontSize: 8.5);
  }

  @override
  bool shouldRepaint(HydrographPainter old) =>
      old.waves != waves ||
      old.markAt != markAt ||
      old.markLabel != markLabel ||
      old.topFlow != topFlow ||
      old.hours != hours ||
      old.note != note;
}

/// A detention pond with a storm coming in and a smaller flow let out.
@immutable
class Pond {
  const Pond({required this.inflow, required this.outflow});

  /// Cubic feet a second arriving.
  final double inflow;

  /// Cubic feet a second leaving.
  final double outflow;

  /// Positive when the pond is filling, which is the whole of the storage
  /// routing equation.
  double get change => inflow - outflow;
}

/// The pond drawn with what goes in and what comes out, and the level
/// answering to the difference.
class PondPainter extends CustomPainter {
  const PondPainter({required this.pond, this.answered = false});

  final Pond pond;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    // The ground surface runs out of the section at both sides.
    // Clipped here rather than left to the widget, so that anything
    // leaving the panel is deliberate and the bounds check stays
    // honest.
    canvas.clipRect(Offset.zero & size);

    const groundY = 58.0;
    final bedY = size.height - 42;
    final bedLeft = 104.0;
    final bedRight = size.width - 104;
    const run = 58.0;
    final rise = bedY - groundY;

    // How far in from the ground line the bank has come at a given height.
    double inset(double y) => run * (bedY - y) / rise;

    // The ground, cut open for the basin.
    groundLine(canvas, const Offset(0, groundY),
        Offset(bedLeft - run, groundY));
    groundLine(canvas, Offset(bedRight + run, groundY),
        Offset(size.width, groundY));
    canvas.drawPath(
        Path()
          ..moveTo(bedLeft - run, groundY)
          ..lineTo(bedLeft, bedY)
          ..lineTo(bedRight, bedY)
          ..lineTo(bedRight + run, groundY),
        Paint()
          ..color = AppColors.ink2
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8);

    // The pool, with its surface ending exactly on the banks.
    final waterY = groundY + 34;
    final left = bedLeft - inset(waterY);
    final right = bedRight + inset(waterY);
    canvas.drawPath(
        Path()
          ..moveTo(left, waterY)
          ..lineTo(bedLeft, bedY)
          ..lineTo(bedRight, bedY)
          ..lineTo(right, waterY)
          ..close(),
        waterFill);
    waterLevel(canvas, Offset(left, waterY), Offset(right, waterY),
        markAt: left + 22);

    void pipe(double y, double from, double to, Color tone, String text) {
      // Nothing arriving is drawn as nothing, not as a stub with an
      // arrowhead on it.
      if ((to - from).abs() < 1) {
        writeOn(canvas, size, text, Offset(math.min(from, to) + 2, y + 6),
            tone, fontSize: 9.5);
        return;
      }
      canvas.drawLine(
          Offset(from, y),
          Offset(to, y),
          Paint()
            ..color = tone
            ..strokeWidth = 3.4);
      final back = to > from ? -8.0 : 8.0;
      canvas.drawPath(
          Path()
            ..moveTo(to, y)
            ..lineTo(to + back, y - 5)
            ..lineTo(to + back, y + 5)
            ..close(),
          Paint()..color = tone);
      // Under the pipe, not over it: over it the inflow label sat in the
      // ground hatching.
      writeOn(canvas, size, text, Offset(math.min(from, to) + 2, y + 6),
          tone, fontSize: 9.5);
    }

    // Arrow lengths to one scale, so the drawing says which is bigger.
    final most = math.max(math.max(pond.inflow, pond.outflow), 1);
    const room = 62.0;
    pipe(groundY + 14, 6, 6 + room * pond.inflow / most, AppColors.info,
        'in ${_num(pond.inflow)} cfs');
    pipe(bedY - 16, bedRight + 6, bedRight + 6 + room * pond.outflow / most,
        AppColors.ink2, 'out ${_num(pond.outflow)} cfs');

    if (answered) {
      final rising = pond.change > 0;
      final tone = pond.change == 0
          ? AppColors.sunbeam
          : (rising ? AppColors.forest : AppColors.error);
      final middle = (bedLeft + bedRight) / 2;
      if (pond.change != 0) {
        final tip = waterY + (rising ? -14 : 30);
        final tail = waterY + (rising ? 22 : -6);
        canvas
          ..drawLine(
              Offset(middle, tail),
              Offset(middle, tip + (rising ? 8 : -8)),
              Paint()
                ..color = tone
                ..strokeWidth = 2.6)
          ..drawPath(
              Path()
                ..moveTo(middle, tip)
                ..lineTo(middle - 5, tip + (rising ? 8 : -8))
                ..lineTo(middle + 5, tip + (rising ? 8 : -8))
                ..close(),
              Paint()..color = tone);
      }
      writeOn(
          canvas,
          size,
          pond.change == 0
              ? 'the level holds'
              : '${rising ? 'filling' : 'emptying'} at '
                  '${pond.change.abs().toStringAsFixed(0)} cfs',
          Offset(middle + 12, waterY + 4),
          tone,
          fontSize: 9.5);
    }

    viewTag(canvas, size, Looking.section, note: 'through the pond');
  }

  @override
  bool shouldRepaint(PondPainter old) =>
      old.pond != pond || old.answered != answered;
}

/// A watershed with its travel times drawn on it. The bands are
/// isochrones: ground that drains to the outlet in the same number of
/// minutes. The far band is the one that sets the time of concentration.
@immutable
class Basin {
  const Basin({required this.travelTime, required this.stormMinutes});

  /// The time of concentration, in minutes: how long water from the most
  /// distant corner takes to reach the outlet.
  final double travelTime;

  /// How long the storm lasts.
  final double stormMinutes;

  /// The fraction of the watershed contributing at the moment the storm
  /// ends. Below the time of concentration the far ground has not reported
  /// in yet.
  double get contributing =>
      math.min(stormMinutes / travelTime, 1).toDouble();

  bool get tooShort => stormMinutes < travelTime - 0.01;

  bool get tooLong => stormMinutes > travelTime + 0.01;
}

/// The watershed in plan, as bands of equal travel time running down to one
/// outlet, with the contributing ones filled in.
class BasinPainter extends CustomPainter {
  const BasinPainter({required this.basin});

  final Basin basin;

  @override
  void paint(Canvas canvas, Size size) {
    final outlet = Offset(size.width / 2, size.height - 34);
    final reach = math.min(size.width / 2 - 18, size.height - 74);
    const bands = 5;

    // The bands themselves, drawn empty.
    for (var i = bands; i >= 1; i--) {
      final wedge = Path()
        ..moveTo(outlet.dx, outlet.dy)
        ..arcTo(Rect.fromCircle(center: outlet, radius: reach * i / bands),
            math.pi * 1.15, math.pi * 0.7, false)
        ..close();
      canvas.drawPath(
          wedge,
          Paint()
            ..color = AppColors.ink3
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);
    }

    // The ground that is contributing: everything whose travel time is
    // less than the length of the storm. The bands are TIMES, so this is a
    // radius, and how much AREA it covers depends on the shape of the
    // basin. The drawing does not claim a percentage of the area, because
    // that is not a thing this figure can honestly say.
    if (basin.contributing > 0) {
      final filled = Path()
        ..moveTo(outlet.dx, outlet.dy)
        ..arcTo(
            Rect.fromCircle(
                center: outlet, radius: reach * basin.contributing),
            math.pi * 1.15,
            math.pi * 0.7,
            false)
        ..close();
      canvas.drawPath(filled,
          Paint()..color = AppColors.info.withValues(alpha: 0.28));
    }

    // The outlet everything drains to.
    canvas.drawCircle(outlet, 5, Paint()..color = AppColors.info);
    writeOn(canvas, size, 'outlet', outlet + const Offset(8, 2),
        AppColors.info, fontSize: 9);

    // The longest path, which is what the time of concentration measures.
    final far = Offset(outlet.dx - reach * 0.80, outlet.dy - reach * 0.58);
    canvas.drawLine(
        far,
        outlet,
        Paint()
          ..color = AppColors.ember
          ..strokeWidth = 1.8);
    writeOn(canvas, size, 'the far corner: ${_num(basin.travelTime)} min',
        far + const Offset(-6, -14), AppColors.ember, fontSize: 9);

    writeOn(canvas, size, 'storm ${_num(basin.stormMinutes)} min',
        const Offset(8, 8), AppColors.ink2, fontSize: 9.5);
    writeOn(
        canvas,
        size,
        basin.contributing >= 0.999
            ? 'all of it is contributing'
            : 'only the ground within ${_num(basin.stormMinutes)} min of the '
                'outlet is in',
        const Offset(8, 22),
        basin.contributing >= 0.999 ? AppColors.forest : AppColors.ink2,
        fontSize: 9.5);
    viewTag(canvas, size, Looking.plan, note: 'bands of equal travel time');
  }

  @override
  bool shouldRepaint(BasinPainter old) => old.basin != basin;
}
String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();
