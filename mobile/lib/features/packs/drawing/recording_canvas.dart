import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart' as painting;
import 'package:flutter/rendering.dart' show Matrix4;

import 'drawing_painter.dart' show buildPath;
import 'figure_path.dart' show pathMoves;

/// A canvas that writes down what a figure draws instead of drawing it.
///
/// The pack builder runs each figure's painter against one of these, once
/// per theme and once per width, and keeps the list of shapes as the
/// figure's drawing (ADR 0030). [DrawingPainter] plays the list back.
///
/// Anything a painter does that this cannot write down exactly throws,
/// naming the call, so a figure is never shipped with a part missing.
class RecordingCanvas implements ui.Canvas {
  final List<List<Object?>> ops = [];

  final List<Float64List> _stack = [_identity()];

  static Float64List _identity() =>
      Float64List.fromList([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);

  Matrix4 get _m => Matrix4.fromFloat64List(_stack.last);
  set _m(Matrix4 m) => _stack.last = m.storage;

  // Transforms and clips

  @override
  void save() {
    _stack.add(Float64List.fromList(_stack.last));
    ops.add(['save']);
  }

  @override
  void restore() {
    if (_stack.length > 1) _stack.removeLast();
    ops.add(['restore']);
  }

  @override
  int getSaveCount() => _stack.length;

  @override
  void restoreToCount(int count) {
    while (_stack.length > count && _stack.length > 1) {
      restore();
    }
  }

  @override
  void translate(double dx, double dy) {
    _m = _m..translateByDouble(dx, dy, 0, 1);
    ops.add(['tr', dx, dy]);
  }

  @override
  void scale(double sx, [double? sy]) {
    _m = _m..scaleByDouble(sx, sy ?? sx, 1, 1);
    ops.add(['sc', sx, sy ?? sx]);
  }

  @override
  void rotate(double radians) {
    _m = _m..rotateZ(radians);
    ops.add(['rot', radians]);
  }

  @override
  Float64List getTransform() => Float64List.fromList(_stack.last);

  @override
  void clipRect(
    ui.Rect rect, {
    ui.ClipOp clipOp = ui.ClipOp.intersect,
    bool doAntiAlias = true,
  }) {
    if (clipOp != ui.ClipOp.intersect) _unsupported('clipRect difference');
    ops.add(['clipR', ..._rect(rect), if (!doAntiAlias) 0]);
  }

  @override
  void clipRRect(ui.RRect rrect, {bool doAntiAlias = true}) {
    ops.add(['clipRR', ..._rrect(rrect), if (!doAntiAlias) 0]);
  }

  @override
  void clipPath(ui.Path path, {bool doAntiAlias = true}) {
    ops.add(['clipP', path.fillType.index, _moves(path)]);
  }

  // Shapes

  @override
  void drawLine(ui.Offset p1, ui.Offset p2, ui.Paint paint) =>
      ops.add(['line', p1.dx, p1.dy, p2.dx, p2.dy, _paint(paint)]);

  /// Called by the figures' dashed lines (figure_dash.dart): one step for
  /// the whole line, which the player draws dash by dash as the figure did.
  void recordDashes(
    ui.Offset a,
    ui.Offset b,
    double on,
    double every,
    ui.Paint paint,
  ) => ops.add(['dash', a.dx, a.dy, b.dx, b.dy, on, every, _paint(paint)]);

  @override
  void drawRect(ui.Rect rect, ui.Paint paint) =>
      ops.add(['rect', ..._rect(rect), _paint(paint)]);

  @override
  void drawRRect(ui.RRect rrect, ui.Paint paint) =>
      ops.add(['rrect', ..._rrect(rrect), _paint(paint)]);

  @override
  void drawDRRect(ui.RRect outer, ui.RRect inner, ui.Paint paint) =>
      ops.add(['drrect', ..._rrect(outer), ..._rrect(inner), _paint(paint)]);

  @override
  void drawCircle(ui.Offset c, double radius, ui.Paint paint) =>
      ops.add(['circle', c.dx, c.dy, radius, _paint(paint)]);

  @override
  void drawOval(ui.Rect rect, ui.Paint paint) =>
      ops.add(['oval', ..._rect(rect), _paint(paint)]);

  @override
  void drawArc(
    ui.Rect rect,
    double startAngle,
    double sweepAngle,
    bool useCenter,
    ui.Paint paint,
  ) => ops.add([
    'arc',
    ..._rect(rect),
    startAngle,
    sweepAngle,
    useCenter ? 1 : 0,
    _paint(paint),
  ]);

  @override
  void drawPath(ui.Path path, ui.Paint paint) =>
      ops.add(['path', path.fillType.index, _moves(path), _paint(paint)]);

  /// Paths this canvas could only trace, for the build report.
  static int traced = 0;

  /// The moves that built [path], checked by rebuilding it; or, for a path
  /// made some other way, its traced outline.
  static List<Object?> _moves(ui.Path path) {
    final moves = pathMoves(path);
    if (moves != null) {
      final copy = [for (final m in moves) List<Object?>.of(m)];
      final rebuilt = buildPath(path.fillType.index, copy, 0);
      if (rebuilt.getBounds() == path.getBounds()) {
        // The fill rule travels with the path step, not as a move.
        return [
          for (final m in copy)
            if (m[0] != 'F') m,
        ];
      }
    }
    traced++;
    return pathCommands(path);
  }

  @override
  void drawPoints(
    ui.PointMode pointMode,
    List<ui.Offset> points,
    ui.Paint paint,
  ) => ops.add([
    'points',
    pointMode.index,
    [
      for (final p in points) ...[p.dx, p.dy],
    ],
    _paint(paint),
  ]);

  @override
  void drawColor(ui.Color color, ui.BlendMode blendMode) =>
      ops.add(['fill', _color(color), blendMode.index]);

  @override
  void drawPaint(ui.Paint paint) => ops.add(['paint', _paint(paint)]);

  /// Called by the figures' own [TextPainter] (figure_text.dart), which
  /// knows its words, where a plain paragraph would not say what it says.
  void recordText(
    painting.TextPainter text,
    double minWidth,
    double maxWidth,
    ui.Offset at,
  ) {
    if (text.textScaler != painting.TextScaler.noScaling) {
      _unsupported('scaled text');
    }
    if (text.strutStyle != null || text.textHeightBehavior != null) {
      _unsupported('strut or height behavior on text');
    }
    ops.add([
      'text',
      _span(text.text),
      minWidth,
      maxWidth.isFinite ? maxWidth : null,
      at.dx,
      at.dy,
      {
        if (text.textAlign != ui.TextAlign.start) 'al': text.textAlign.index,
        if (text.textDirection != ui.TextDirection.ltr) 'rtl': 1,
        if (text.maxLines != null) 'ml': text.maxLines,
        if (text.ellipsis != null) 'el': text.ellipsis,
        if (text.textWidthBasis != painting.TextWidthBasis.parent)
          'wb': text.textWidthBasis.index,
      },
    ]);
  }

  @override
  void drawParagraph(ui.Paragraph paragraph, ui.Offset offset) =>
      _unsupported('text drawn with a plain TextPainter');

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      _unsupported('canvas ${invocation.memberName}');

  // Encoding

  static Never _unsupported(String what) =>
      throw UnsupportedError('A figure used something not recordable: $what');

  static List<double> _rect(ui.Rect r) => [r.left, r.top, r.right, r.bottom];

  static List<double> _rrect(ui.RRect r) => [
    r.left,
    r.top,
    r.right,
    r.bottom,
    r.tlRadiusX,
    r.tlRadiusY,
    r.trRadiusX,
    r.trRadiusY,
    r.brRadiusX,
    r.brRadiusY,
    r.blRadiusX,
    r.blRadiusY,
  ];

  /// A color, marked so the builder can pair its day and night values.
  static Map<String, Object?> _color(ui.Color c) => {'#': colorValue(c)};

  /// A color as ARGB when it is one, or its exact components when it is
  /// not: a token at a fractional opacity (`withValues(alpha: 0.35)`) is
  /// drawn from the fraction, and rounding it to a byte moves pixels.
  static Object colorValue(ui.Color c) {
    final argb = c.toARGB32();
    final byte = ui.Color(argb);
    // A paint keeps its color in single precision, so a whole byte comes
    // back a hair off; that is still the byte.
    bool near(double x, double y) => (x - y).abs() < 1e-6;
    if (near(byte.a, c.a) &&
        near(byte.r, c.r) &&
        near(byte.g, c.g) &&
        near(byte.b, c.b)) {
      return argb;
    }
    return {
      'f': [c.a, c.r, c.g, c.b],
    };
  }

  static Map<String, Object?> _paint(ui.Paint p) {
    if (p.shader != null ||
        p.maskFilter != null ||
        p.colorFilter != null ||
        p.imageFilter != null ||
        p.invertColors) {
      _unsupported('a paint effect (shader, blur or filter)');
    }
    return {
      '#': colorValue(p.color),
      if (p.style == ui.PaintingStyle.stroke) 's': 1,
      if (p.strokeWidth != 0) 'w': p.strokeWidth,
      if (p.strokeCap != ui.StrokeCap.butt) 'cap': p.strokeCap.index,
      if (p.strokeJoin != ui.StrokeJoin.miter) 'join': p.strokeJoin.index,
      // Zero is how a paint says it was never set (the engine's default).
      if (p.strokeMiterLimit != 0) 'ml': p.strokeMiterLimit,
      if (!p.isAntiAlias) 'aa': 0,
      if (p.blendMode != ui.BlendMode.srcOver) 'bm': p.blendMode.index,
    };
  }

  static Object? _span(painting.InlineSpan? span) {
    if (span == null) return null;
    if (span is! painting.TextSpan) _unsupported('a widget inside text');
    return {
      if (span.text != null) 't': span.text,
      if (span.style != null) 'st': _style(span.style!),
      if (span.children != null)
        'ch': [for (final c in span.children!) _span(c)],
    };
  }

  static Map<String, Object?> _style(painting.TextStyle s) {
    if (s.foreground != null ||
        s.background != null ||
        s.shadows != null ||
        s.fontFeatures != null ||
        s.fontVariations != null ||
        s.decoration != null && s.decoration != ui.TextDecoration.none) {
      _unsupported('a text effect');
    }
    return {
      if (s.fontFamily != null) 'ff': s.fontFamily,
      if (s.fontFamilyFallback != null) 'fb': s.fontFamilyFallback,
      if (s.fontSize != null) 'fs': s.fontSize,
      if (s.fontWeight != null) 'fw': s.fontWeight!.value,
      if (s.fontStyle == ui.FontStyle.italic) 'it': 1,
      if (s.letterSpacing != null) 'ls': s.letterSpacing,
      if (s.wordSpacing != null) 'ws': s.wordSpacing,
      if (s.height != null) 'h': s.height,
      if (s.color != null) 'c': _color(s.color!),
      if (s.textBaseline != null) 'bl': s.textBaseline!.index,
      if (s.leadingDistribution != null) 'ld': s.leadingDistribution!.index,
    };
  }
}

/// A path as the moves that make it up.
///
/// A built path does not say how it was built, so it is walked: every
/// contour is followed in small steps, every corner is found to within a
/// ten-thousandth of a pixel, and straight runs collapse back to their two
/// ends. Curves come back as fine polylines, close enough that no reader
/// can tell (the parity test measures how close).
List<Object?> pathCommands(ui.Path path) {
  const step = 0.5;
  final out = <Object?>[];
  for (final metric in path.computeMetrics()) {
    final length = metric.length;
    if (length == 0) continue;
    ui.Offset at(double t) => metric.getTangentForOffset(t)!.position;
    double angle(double t) => metric.getTangentForOffset(t)!.angle;

    final pts = <ui.Offset>[at(0)];
    var prev = 0.0;
    for (var t = step; ; t += step) {
      final here = math.min(t, length);
      final turn = _turn(angle(prev), angle(here));
      if (turn > 0.2) {
        // A corner somewhere between the two samples: close in on it.
        var lo = prev, hi = here;
        for (var i = 0; i < 24; i++) {
          final mid = (lo + hi) / 2;
          if (_turn(angle(lo), angle(mid)) > 0.1) {
            hi = mid;
          } else {
            lo = mid;
          }
        }
        pts.add(at(hi));
      }
      pts.add(at(here));
      prev = here;
      if (here >= length) break;
    }
    final simple = _simplify(pts, 0.02);
    out.add(['M', simple.first.dx, simple.first.dy]);
    final last = metric.isClosed ? simple.length - 1 : simple.length;
    for (var i = 1; i < last; i++) {
      out.add(['L', simple[i].dx, simple[i].dy]);
    }
    if (metric.isClosed) out.add(['Z']);
  }
  return out;
}

double _turn(double a, double b) {
  var d = (a - b).abs() % (2 * math.pi);
  if (d > math.pi) d = 2 * math.pi - d;
  return d;
}

/// Douglas-Peucker: drops every point that sits within [tol] of the line
/// between its neighbours that are kept.
List<ui.Offset> _simplify(List<ui.Offset> pts, double tol) {
  if (pts.length < 3) return pts;
  final keep = List<bool>.filled(pts.length, false)
    ..[0] = true
    ..[pts.length - 1] = true;
  final work = <(int, int)>[(0, pts.length - 1)];
  while (work.isNotEmpty) {
    final (a, b) = work.removeLast();
    var far = -1.0;
    var at = -1;
    for (var i = a + 1; i < b; i++) {
      final d = _distance(pts[i], pts[a], pts[b]);
      if (d > far) {
        far = d;
        at = i;
      }
    }
    if (far > tol) {
      keep[at] = true;
      work
        ..add((a, at))
        ..add((at, b));
    }
  }
  return [
    for (var i = 0; i < pts.length; i++)
      if (keep[i]) pts[i],
  ];
}

double _distance(ui.Offset p, ui.Offset a, ui.Offset b) {
  final ab = b - a;
  final len = ab.distance;
  if (len == 0) return (p - a).distance;
  return ((p.dx - a.dx) * ab.dy - (p.dy - a.dy) * ab.dx).abs() / len;
}
