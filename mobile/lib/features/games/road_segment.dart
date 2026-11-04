import 'dart:math' as math;
import 'dart:ui' show PathMetric, Tangent;

import 'package:flutter/material.dart';

import '../../core/theme/road.dart';

/// One stretch of road between two lesson platforms, seen in the isometric
/// view of `mobile/design/road/ROAD.md`.
///
/// The shape is not hand-drawn per chapter. It comes from the two platform
/// centres with the same rule everywhere (leave the platform, lean most of
/// the way toward the next one's column, arrive), worked out on the GROUND
/// and then projected, so a chapter of any length or weave gets its roads
/// for free. Each segment is a widget with its own progress, so one stretch
/// can be looked at, tested and debugged on its own.
///
/// [travelled] is 1 once the lesson behind it is finished, else 0. Turning
/// it to 1 plays the finishing moment (ROAD.md, "The finishing moment"):
/// the road fills and the centre line draws in behind it; then the path
/// walks the raccoon pin over it ([PinTrip]). With Reduce Motion the whole
/// segment cross-fades in over 180 ms instead.
class RoadSegment extends StatefulWidget {
  const RoadSegment({
    super.key,
    required this.from,
    required this.to,
    required this.travelled,
    this.size = RoadSize.phone,
    this.radius,
    this.reduceMotion = false,
    this.onMoment,
    this.onArrive,
  });

  /// The two platforms' foot centres (the middle of each platform's base on
  /// the ground), on screen, in the coordinate space of the widget that
  /// places this.
  final Offset from;
  final Offset to;

  /// 0 keeps the road pale; 1 walks it all the way to the next platform.
  final double travelled;

  final RoadSize size;

  /// The platforms' face radius on the ground; the platform's half width.
  final double? radius;

  /// System Reduce Motion: a 180 ms cross-fade, nothing runs along the road.
  final bool reduceMotion;

  /// Called once when the finishing moment starts, with its clock: the
  /// milliseconds into the moment, 0 to [AppRoad.momentMs]. The path uses it
  /// to walk the raccoon pin and its glow over the new road.
  final ValueChanged<Animation<double>>? onMoment;

  /// Called at [AppRoad.arriveStartMs]: the next platform's bounce.
  final VoidCallback? onArrive;

  double get r => radius ?? size.platform / 2;

  /// The road's geometry, in the same coordinate space as [from] and [to].
  RoadGeometry get geometry => RoadGeometry(from: from, to: to, r: r);

  /// The box this segment paints in, in the same coordinate space: both
  /// platforms' footprints, the road above them, and its shadow below.
  Rect get bounds {
    final pad = size.width + r;
    return Rect.fromLTRB(
      math.min(from.dx, to.dx) - pad,
      math.min(from.dy, to.dy) - r * AppRoad.k - size.plinth - size.width,
      math.max(from.dx, to.dx) + pad,
      math.max(from.dy, to.dy) +
          r * AppRoad.k +
          size.shadowY +
          4 * size.blur +
          size.width,
    );
  }

  @override
  State<RoadSegment> createState() => _RoadSegmentState();
}

/// The moment's curves: ease in-out on the road, line and pulse, the same
/// cubic as the mockups (`4t³` then mirrored).
class _InOutCubic extends Curve {
  const _InOutCubic();

  @override
  double transformInternal(double t) =>
      t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
}

const _inOut = _InOutCubic();

/// Where one phase stands, `ms` into the moment: 0 before it, 1 after it.
double momentSpan(double ms, double start, double end) =>
    _inOut.transform(((ms - start) / (end - start)).clamp(0.0, 1.0));

class _RoadSegmentState extends State<RoadSegment>
    with TickerProviderStateMixin {
  late final AnimationController _moment = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: AppRoad.momentMs.round()),
  );
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: AppRoad.reducedFadeMs.round()),
  );

  /// The moment's clock in milliseconds, for whoever follows it.
  late final Animation<double> _clock = _moment.drive(
    Tween(begin: 0.0, end: AppRoad.momentMs),
  );
  bool _arrived = false;

  @override
  void initState() {
    super.initState();
    // A road walked before the map opened is drawn walked, with no replay.
    if (widget.travelled >= 1) {
      _moment.value = 1;
      _fade.value = 1;
    }
    _moment.addListener(_watchArrival);
  }

  void _watchArrival() {
    if (_arrived || _clock.value < AppRoad.arriveStartMs) return;
    _arrived = true;
    widget.onArrive?.call();
  }

  @override
  void didUpdateWidget(RoadSegment old) {
    super.didUpdateWidget(old);
    if (old.travelled == widget.travelled) return;
    if (widget.travelled >= 1 && old.travelled < 1) {
      _arrived = false;
      if (widget.reduceMotion) {
        _arrived = true;
        _moment.value = 1;
        _fade.forward(from: 0);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onMoment?.call(_fadeClock);
        });
      } else {
        _fade.value = 1;
        _moment.forward(from: 0);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onMoment?.call(_clock);
        });
      }
    } else if (widget.travelled < 1) {
      _moment.value = 0;
      _fade.value = 0;
    }
  }

  /// Under Reduce Motion the moment's clock is the fade's, in milliseconds.
  late final Animation<double> _fadeClock = _fade.drive(
    Tween(begin: 0.0, end: AppRoad.reducedFadeMs),
  );

  @override
  void dispose() {
    _moment.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.bounds;
    final geometry = widget.geometry;
    return Positioned(
      left: b.left,
      top: b.top,
      width: b.width,
      height: b.height,
      child: IgnorePointer(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: Listenable.merge([_moment, _fade]),
            builder: (context, _) {
              final ms = _clock.value;
              final running = _moment.isAnimating;
              final walked = widget.travelled >= 1 || running;
              return CustomPaint(
                painter: RoadPainter(
                  geometry: geometry,
                  origin: b.topLeft,
                  size: widget.size,
                  fill: walked
                      ? momentSpan(ms, AppRoad.fillStartMs, AppRoad.fillEndMs)
                      : 0,
                  line: walked
                      ? momentSpan(ms, AppRoad.lineStartMs, AppRoad.lineEndMs)
                      : 0,
                  walkedAlpha: _fade.value,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// One segment's centre curve, worked out on the ground.
///
/// Ground coordinates are screen x and screen y over [AppRoad.k] for a point
/// on the ground, so a platform's foot centre `(x, Y)` on screen is
/// `(x, Y / k)` on the ground. The curve is the app's rule between the two
/// platform centres, trimmed by arc length 2 inside the face it leaves and
/// 4 inside the one it reaches.
class RoadGeometry {
  RoadGeometry({required this.from, required this.to, required this.r}) {
    final a = Offset(from.dx, from.dy / AppRoad.k);
    final b = Offset(to.dx, to.dy / AppRoad.k);
    final dx = b.dx - a.dx;
    final lean = dx.abs() > 4 ? a.dx + dx * 0.8 : a.dx + r * 0.55;
    final c = Offset(lean, a.dy + (b.dy - a.dy) * 0.52);
    final full = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(c.dx, c.dy, b.dx, b.dy);
    final metric = full.computeMetrics().first;

    const step = 0.25;
    var start = 0.0;
    for (var d = 0.0; d < metric.length; d += step) {
      final p = metric.getTangentForOffset(d)!.position;
      if ((p - a).distance >= r - 2) {
        start = d;
        break;
      }
    }
    var end = metric.length;
    for (var d = metric.length; d > start; d -= step) {
      final p = metric.getTangentForOffset(d)!.position;
      if ((p - b).distance >= r - 4) {
        end = d;
        break;
      }
    }
    ground = metric.extractPath(start, end);
    this.metric = ground.computeMetrics().first;
  }

  /// The platforms' foot centres on screen.
  final Offset from;
  final Offset to;

  /// The platforms' radius on the ground.
  final double r;

  /// The trimmed centre curve on the ground, and its metric.
  late final Path ground;
  late final PathMetric metric;

  double get length => metric.length;

  /// The ground point at fraction [f] along the curve, by arc length, and
  /// its ground angle.
  Tangent tangentAt(double f) =>
      metric.getTangentForOffset(length * f.clamp(0.0, 1.0))!;

  /// The screen point on the road's centre curve at [f], raised [height]
  /// (the road's slab height puts it on the road's top).
  Offset at(double f, double height) =>
      AppRoad.project(tangentAt(f).position, height);
}

/// The road, painted bottom to top as ROAD.md lays out: the shadow on the
/// ground, the side wall under the near edge, the top with its lit rim on
/// both edges, the dashed centre line, the lip where it meets the platform
/// it leaves. (The pin's spring glow is drawn with the pin, under it.)
///
/// Every layer is the trimmed ground curve stroked at the road's width and
/// drawn through one projection (`translate(0, -height)` then
/// `scale(1, k)`). The walked layers are drawn over the pale ones on the
/// first [fill] of the curve, so the wall turns with the fill.
class RoadPainter extends CustomPainter {
  RoadPainter({
    required this.geometry,
    required this.origin,
    required this.size,
    required this.fill,
    required this.line,
    this.walkedAlpha = 1,
  });

  final RoadGeometry geometry;

  /// Where the painter's box sits in the path's coordinates.
  final Offset origin;
  final RoadSize size;

  /// How far the walked top has run from the finished platform, 0..1.
  final double fill;

  /// How far the centre line is revealed, never more than [fill].
  final double line;

  /// The walked layers' opacity: 1, except during a Reduce Motion fade.
  final double walkedAlpha;

  @override
  void paint(Canvas canvas, Size box) {
    const k = AppRoad.k;
    final g = geometry;
    final hr = size.road;
    final w = size.width;
    final r = g.r;
    final path = g.ground;
    final len = g.length;
    final walked = fill > 0 ? g.metric.extractPath(0, len * fill) : null;
    final a = walkedAlpha.clamp(0.0, 1.0);

    canvas.save();
    canvas.translate(-origin.dx, -origin.dy);

    // The platform the road leaves, at a height: each layer is cut by its
    // outline at the layer's own height, so the road butts against the side
    // of the plinth instead of running under it.
    Rect ellipse(double height, [double grow = 0]) => Rect.fromCenter(
      center: Offset(g.from.dx, g.from.dy - height),
      width: 2 * (r + grow),
      height: 2 * (r + grow) * k,
    );
    void layer(double dy, double cutAt, void Function() draw) {
      canvas.save();
      canvas.clipPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(const Offset(-1e5, -1e5) & const Size(2e5, 2e5))
          ..addOval(ellipse(cutAt)),
      );
      canvas.translate(0, dy);
      canvas.scale(1, k);
      draw();
      canvas.restore();
    }

    Paint band(
      Color color,
      double width, {
      double alpha = 1,
      double? blur,
      StrokeCap cap = StrokeCap.round,
    }) {
      final p = Paint()
        ..color = color.withValues(alpha: color.a * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = cap;
      if (blur != null) p.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
      return p;
    }

    // 1. The shadow on the ground, under the wall. Half strength under road
    //    ahead, full under walked road.
    layer(size.shadowY, 0, () {
      canvas.drawPath(
        path,
        band(RoadColors.shadow, w, alpha: 0.5, blur: size.blur),
      );
      if (walked != null) {
        canvas.drawPath(
          walked,
          band(RoadColors.shadow, w, alpha: a, blur: size.blur),
        );
      }
    });

    // 2. The side wall: the road's band at the ground and half way up, which
    //    fills the slab's side under its near edge. Plinth tan on both.
    for (final (dy, cut) in [(0.0, 0.0), (-hr / 2, hr / 2)]) {
      layer(dy, cut, () {
        canvas.drawPath(path, band(RoadColors.plinth, w));
        if (walked != null) {
          canvas.drawPath(walked, band(RoadColors.plinth, w, alpha: a));
        }
      });
    }

    // 3. The top: the rim colour at full width, the surface 2 narrower on
    //    each side over it, so a thin lit rim shows on both edges. Pale, then
    //    the walked top over the first `fill` of it.
    final surface = w - 2 * size.rim;
    layer(-hr, hr, () {
      canvas.drawPath(path, band(RoadColors.aheadRim, w));
      canvas.drawPath(path, band(RoadColors.aheadTop, surface));
      if (walked != null) {
        canvas.drawPath(walked, band(RoadColors.walkedRim, w, alpha: a));
        canvas.drawPath(walked, band(RoadColors.walkedTop, surface, alpha: a));
      }

      // 4. The centre line, revealed up to `line` and never ahead of the
      //    fill: dashes from half a gap in, round ends.
      final shown = len * math.min(line, fill);
      if (shown > 0) {
        final dash = band(RoadColors.centreLine, size.line, alpha: a);
        for (var d = size.gap / 2; d < shown; d += size.dash + size.gap) {
          canvas.drawPath(
            g.metric.extractPath(d, math.min(d + size.dash, shown)),
            dash,
          );
        }
      }
    });

    // 5. The lip: the platform's outline, 1.2 wide, along the cut on the
    //    road's top. Plinth tan on walked road, the cream rim on road ahead.
    final bounds = Offset(origin.dx, origin.dy) & box;
    // The road's top band is the mask; the outline is composited into it.
    canvas.saveLayer(bounds, Paint());
    canvas.save();
    canvas.translate(0, -hr);
    canvas.scale(1, k);
    canvas.drawPath(
      path,
      band(const Color(0xFF000000), w, cap: StrokeCap.butt),
    );
    canvas.restore();
    canvas.saveLayer(bounds, Paint()..blendMode = BlendMode.srcIn);
    canvas.drawOval(
      ellipse(hr, 0.7),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = fill > 0 ? RoadColors.plinth : RoadColors.aheadRim,
    );
    canvas.restore();
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(RoadPainter old) =>
      old.fill != fill ||
      old.line != line ||
      old.walkedAlpha != walkedAlpha ||
      old.geometry.from != geometry.from ||
      old.geometry.to != geometry.to ||
      old.origin != origin ||
      old.size != size;
}

/// What lies under the raccoon pin, on the surface it stands on: its spring
/// glow while it walks, then the soft contact shadow, both centred on the
/// pin's anchor and squashed like the ground.
///
/// The glow is the pin's own light (owner, 2026-11-03): it travels with the
/// pin, fading in as the pin sets off and out as it stops ([glow], 0..1).
/// The shadow is a ground circle the width of the road's top plus 2. The
/// path places this right after the road or platform the pin is on, so
/// both lie on that surface, under the coin and under every label.
class PinShadow extends StatelessWidget {
  const PinShadow({
    super.key,
    required this.anchor,
    required this.size,
    this.opacity = 1,
    this.glow = 0,
  });

  final Offset anchor;
  final RoadSize size;
  final double opacity;

  /// The spring glow's strength, 0 (none) to 1.
  final double glow;

  /// The glow's radius on the ground.
  static double glowRadius(RoadSize size) => size.width * 0.9;

  @override
  Widget build(BuildContext context) {
    final rx = size.pinFoot / 2;
    final ry = rx * AppRoad.k;
    final gx = glowRadius(size);
    final pad = math.max(rx, gx) + 4;
    return Positioned(
      left: anchor.dx - pad,
      top: anchor.dy - pad * AppRoad.k,
      width: 2 * pad,
      height: 2 * pad * AppRoad.k,
      child: IgnorePointer(
        child: CustomPaint(
          key: const ValueKey('pin-shadow'),
          painter: _PinShadowPainter(
            rx: rx,
            ry: ry,
            gx: gx,
            opacity: opacity,
            glow: glow,
          ),
        ),
      ),
    );
  }
}

class _PinShadowPainter extends CustomPainter {
  const _PinShadowPainter({
    required this.rx,
    required this.ry,
    required this.gx,
    required this.opacity,
    required this.glow,
  });

  final double rx;
  final double ry;
  final double gx;
  final double opacity;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    if (glow > 0) {
      // A flat spring pool of light, lying on the surface.
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(gx, gx * AppRoad.k);
      final a = (glow * opacity).clamp(0.0, 1.0).toDouble();
      canvas.drawCircle(
        Offset.zero,
        1,
        Paint()
          ..shader = RadialGradient(
            colors: [
              RoadColors.pulse.withValues(alpha: 0.9 * a),
              RoadColors.pulse.withValues(alpha: 0.4 * a),
              RoadColors.pulse.withValues(alpha: 0),
            ],
            stops: const [0, 0.5, 1],
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: 1)),
      );
      canvas.restore();
    }
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 2 * rx, height: 2 * ry),
      Paint()
        ..color = const Color(
          0xFF000000,
        ).withValues(alpha: AppRoad.pinShadowAlpha * opacity)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          AppRoad.pinShadowBlur,
        ),
    );
  }

  @override
  bool shouldRepaint(_PinShadowPainter old) =>
      old.rx != rx ||
      old.ry != ry ||
      old.gx != gx ||
      old.opacity != opacity ||
      old.glow != glow;
}

/// Which surface the walking pin is on.
enum TripPart { oldRoad, jointUp, face, jointDown, newRoad }

/// One point of the pin's trip: where its anchor is on screen, the ground
/// point under it, how high it stands, and on what.
class TripPoint {
  const TripPoint(this.anchor, this.ground, this.height, this.part, this.s);

  final Offset anchor;
  final Offset ground;
  final double height;
  final TripPart part;

  /// Distance along the trip, on screen, from its start.
  final double s;

  /// Over the platform's face (inside its rim) rather than over a road.
  bool onFace(Offset centre, double r) => (ground - centre).distance < r;
}

/// The raccoon pin's walk when a lesson is finished (ROAD.md): from where it
/// rests on the road into that lesson, along the road's centre curve to the
/// platform, up the step onto its face, across the face through its centre,
/// down onto the new road, and along that road's centre curve to where it
/// rests.
///
/// Built on the ground with a height at every point, projected, and
/// measured by length ON SCREEN, so [at] moves the pin at an even speed
/// along what the student sees. The step up and down is a smooth rise
/// across a short band either side of the rim ([jointIn] inside, [jointOut]
/// outside), from the road's top to the face.
class PinTrip {
  PinTrip({
    required this.into,
    required this.out,
    required this.size,
    required this.plinth,
  }) : center = Offset(out.from.dx, out.from.dy / AppRoad.k),
       r = out.r {
    final road = size.road;
    final pts = <(Offset, double, TripPart)>[];
    double smooth(double t) {
      final u = t.clamp(0.0, 1.0).toDouble();
      return u * u * (3 - 2 * u);
    }

    // Where a road's curve is [d] from the finished platform's centre.
    double fAt(RoadGeometry g, double d, {required bool leaving}) {
      var lo = 0.0, hi = 1.0;
      for (var i = 0; i < 40; i++) {
        final mid = (lo + hi) / 2;
        final dist = (g.tangentAt(mid).position - center).distance;
        // Leaving, distance grows with f; arriving, it shrinks.
        if ((dist < d) == leaving) {
          lo = mid;
        } else {
          hi = mid;
        }
      }
      return (lo + hi) / 2;
    }

    void along(
      RoadGeometry g,
      double f0,
      double f1,
      TripPart part,
      double Function(double f) height,
    ) {
      final n = math.max(2, ((f1 - f0).abs() * g.length / 0.5).ceil());
      for (var i = 0; i <= n; i++) {
        final f = f0 + (f1 - f0) * i / n;
        pts.add((g.tangentAt(f).position, height(f), part));
      }
    }

    final i = into;
    Offset entry;
    if (i != null) {
      final rest = size.pinRest;
      final fOut = fAt(i, r + jointOut, leaving: false);
      final fIn = fAt(i, r - jointIn, leaving: false);
      along(i, rest, fOut, TripPart.oldRoad, (_) => road);
      along(i, fOut, fIn, TripPart.jointUp, (f) {
        final u = (f - fOut) / (fIn - fOut);
        return road + (plinth - road) * smooth(u);
      });
      entry = i.tangentAt(fIn).position;
    } else {
      // The first lesson: the pin stood on its face, at the centre.
      entry = center;
    }

    // Across the face: a curve from where it came up to where it goes
    // down, through the centre at its middle.
    final exit = out.tangentAt(0).position;
    final ctrl = center * 2 - (entry + exit) / 2;
    const faceSteps = 80;
    for (var k = 0; k <= faceSteps; k++) {
      final t = k / faceSteps;
      final a = (1 - t) * (1 - t), b = 2 * (1 - t) * t, c = t * t;
      pts.add((entry * a + ctrl * b + exit * c, plinth, TripPart.face));
    }
    if (i == null) {
      // No step up: drop the face's first half from the centre on.
      pts.removeRange(0, faceSteps ~/ 2);
    }

    final fDown = fAt(out, r + jointOut, leaving: true);
    along(out, 0, fDown, TripPart.jointDown, (f) {
      final u = f / fDown;
      return plinth + (road - plinth) * smooth(u);
    });
    along(out, fDown, size.pinRest, TripPart.newRoad, (_) => road);

    // Measure on screen, dropping repeats where two parts meet.
    var s = 0.0;
    Offset? last;
    for (final (g, h, part) in pts) {
      final a = AppRoad.project(g, h);
      if (last != null) {
        final d = (a - last).distance;
        if (d < 1e-6) continue;
        s += d;
      }
      points.add(TripPoint(a, g, h, part, s));
      last = a;
    }
  }

  /// How far inside and outside the rim the step up (and down) runs, on
  /// the ground.
  static const jointIn = 2.0;
  static const jointOut = 4.0;

  /// The road into the finished lesson (null for the first lesson, whose
  /// pin stood on its face) and the road just opened.
  final RoadGeometry? into;
  final RoadGeometry out;
  final RoadSize size;

  /// The platforms' height: the face stands this high.
  final double plinth;

  /// The finished platform's centre, on the ground, and its radius.
  final Offset center;
  final double r;

  final List<TripPoint> points = [];

  double get length => points.last.s;

  /// The finished platform's face centre on screen.
  Offset get faceCenter => AppRoad.project(center, plinth);

  /// The trip at [t], 0..1 of its length on screen.
  TripPoint at(double t) {
    final target = length * t.clamp(0.0, 1.0);
    var lo = 0, hi = points.length - 1;
    while (hi - lo > 1) {
      final mid = (lo + hi) >> 1;
      if (points[mid].s <= target) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    final a = points[lo], b = points[hi];
    final span = b.s - a.s;
    final u = span <= 0 ? 0.0 : (target - a.s) / span;
    return TripPoint(
      Offset.lerp(a.anchor, b.anchor, u)!,
      Offset.lerp(a.ground, b.ground, u)!,
      a.height + (b.height - a.height) * u,
      u < 0.5 ? a.part : b.part,
      target,
    );
  }
}

/// The raccoon pin: the brand's raccoon peek on a small charcoal coin with a
/// spring ring, day and night. Positioned by its BOTTOM CENTRE: [anchor] is
/// the lowest point of the outer ring, which sits exactly on the road's
/// centre curve (or on the centre of a platform's face).
class RoadPin extends StatelessWidget {
  const RoadPin({
    super.key,
    required this.anchor,
    required this.size,
    this.opacity = 1,
  });

  final Offset anchor;
  final RoadSize size;
  final double opacity;

  static const peek = 'assets/brand/raccoon_peek.png';

  @override
  Widget build(BuildContext context) {
    final d = size.coin;
    const ring = AppRoad.pinRing;
    return Positioned(
      left: anchor.dx,
      top: anchor.dy,
      child: IgnorePointer(
        child: FractionalTranslation(
          translation: const Offset(-0.5, -1),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Container(
              key: const ValueKey('road-pin'),
              width: d + 2 * ring,
              height: d + 2 * ring,
              padding: const EdgeInsets.all(ring),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: RoadColors.pulse,
              ),
              child: ClipOval(
                child: ColoredBox(
                  color: RoadColors.pinCoin,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: (d * 0.18).roundToDouble(),
                      ),
                      child: Image.asset(
                        peek,
                        width: (d * 0.78).roundToDouble(),
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
