import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart' show CustomPainter;
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import 'figure_dash.dart' show dashes, pathDashes;
import 'figure_grains.dart' show grains;
import 'figure_hatch.dart' show hatches;

/// Plays back a figure recorded by the pack builder (ADR 0030).
///
/// A recorded number is either a plain number or `{"w": [a, b]}`, meaning
/// `a + b * width`: the builder records every figure at several widths and
/// keeps only the straight-line rule each position follows, so one drawing
/// fits every phone the way the painter it came from did. A color is
/// `{"#": argb}`, or `{"#": [day, night]}` when the two themes differ, and is
/// played back as the app's own [ThemedColor].
class DrawingPainter extends CustomPainter {
  const DrawingPainter(this.drawing);

  /// The steps, or `{"bands": [[from width, steps], ...]}` for a drawing
  /// that changes at some width.
  final Object drawing;

  @override
  void paint(Canvas canvas, Size size) =>
      playDrawing(canvas, size, drawingSteps(drawing, size.width));

  @override
  bool shouldRepaint(DrawingPainter old) => !identical(old.drawing, drawing);
}

/// The steps a drawing takes at this width.
List<Object?> drawingSteps(Object drawing, double width) {
  // Kept in parts (the steady steps once, only the stretch that changes
  // with the width in bands): played one after the other.
  if (drawing case {'parts': final List parts}) {
    return [for (final p in parts) ...drawingSteps(p! as Object, width)];
  }
  var steps = drawing;
  if (drawing is Map) {
    final bands = drawing['bands'] as List;
    steps = (bands.first as List)[1];
    for (final band in bands) {
      if (width >= ((band as List)[0] as num)) steps = band[1];
    }
  }
  return _unrun(steps as List<Object?>, width);
}

/// A repeated step (`["run", count, first, step]`) drawn out in full: the
/// first, then each one moved on by the step, as many times as the width
/// allows. The painter that was recorded drew them one by one, so this is
/// the same drawing.
List<Object?> _unrun(List<Object?> ops, double w) {
  if (!ops.any((o) => (o! as List).first == 'run')) return ops;
  return [
    for (final raw in ops)
      if (raw case ['run', final count, final first, final step])
        for (var i = 0; i < drawingCount(count, w); i++)
          _moved(first, step, i, w)
      else
        raw,
  ];
}

/// How many times a run is drawn at [width].
int drawingCount(Object? v, double width) {
  if (v is num) return v.toInt();
  final s = ((v! as Map)['n'] as List).cast<num>();
  var n = s[0];
  for (var i = 1; i + 1 < s.length; i += 2) {
    if (width >= s[i]) n = s[i + 1];
  }
  return n.toInt();
}

bool _isNumber(Object? v) =>
    v is num ||
    (v is Map &&
        v.length == 1 &&
        (v.containsKey('w') || v.containsKey('p') || v.containsKey('a')));

Object? _moved(Object? op, Object? step, int i, double w) {
  if (step == null || i == 0) return op;
  if (_isNumber(op)) {
    // What does not move stays exactly as recorded: some numbers are
    // settings (a stroke cap, a style) that must stay whole.
    if (step == 0) return op;
    return drawingNumber(op, w) + drawingNumber(step, w) * i;
  }
  if (op is List) {
    return [
      for (var k = 0; k < op.length; k++)
        _moved(op[k], (step as List)[k], i, w),
    ];
  }
  if (op is Map) {
    return {
      for (final k in op.keys)
        k: k == '#' ? op[k] : _moved(op[k], (step as Map)[k], i, w),
    };
  }
  return op;
}

void playDrawing(Canvas canvas, Size size, List<Object?> ops) {
  final w = size.width;
  double n(Object? v) => drawingNumber(v, w);
  for (final raw in ops) {
    final op = raw as List<Object?>;
    switch (op[0]) {
      case 'save':
        canvas.save();
      case 'restore':
        canvas.restore();
      case 'tr':
        canvas.translate(n(op[1]), n(op[2]));
      case 'sc':
        canvas.scale(n(op[1]), n(op[2]));
      case 'rot':
        canvas.rotate(n(op[1]));
      case 'clipR':
        canvas.clipRect(_rect(op, 1, w), doAntiAlias: op.length < 6);
      case 'clipRR':
        canvas.clipRRect(_rrect(op, 1, w), doAntiAlias: op.length < 14);
      case 'clipP':
        canvas.clipPath(_path(op[1] as int, op[2] as List<Object?>, w));
      case 'line':
        canvas.drawLine(
          Offset(n(op[1]), n(op[2])),
          Offset(n(op[3]), n(op[4])),
          _paint(op[5], w),
        );
      case 'dash':
        // A whole dashed line, drawn by the figures' own loop.
        dashes(
          canvas,
          Offset(n(op[1]), n(op[2])),
          Offset(n(op[3]), n(op[4])),
          _paint(op[7], w),
          n(op[5]),
          n(op[6]),
        );
      case 'pdash':
        // A whole dashed outline, cut into dashes by the figures' own loop.
        pathDashes(
          canvas,
          _path(op[1] as int, op[2] as List<Object?>, w),
          _paint(op[5], w),
          n(op[3]),
          n(op[4]),
        );
      case 'hatch':
        // A whole hatched shape, hatched by the figures' own loop.
        hatches(
          canvas,
          _path(op[1] as int, op[2] as List<Object?>, w),
          _paint(op[5], w),
          n(op[3]),
          n(op[4]),
        );
      case 'grains':
        // Soil grains packed into a block, by the figures' own loop.
        grains(
          canvas,
          _rect(op, 1, w),
          n(op[5]),
          (op[6]! as num).toInt(),
          _paint(op[7], w),
          _paint(op[8], w),
        );
      case 'rect':
        canvas.drawRect(_rect(op, 1, w), _paint(op[5], w));
      case 'rrect':
        canvas.drawRRect(_rrect(op, 1, w), _paint(op[13], w));
      case 'drrect':
        canvas.drawDRRect(
          _rrect(op, 1, w),
          _rrect(op, 13, w),
          _paint(op[25], w),
        );
      case 'circle':
        canvas.drawCircle(
          Offset(n(op[1]), n(op[2])),
          n(op[3]),
          _paint(op[4], w),
        );
      case 'oval':
        canvas.drawOval(_rect(op, 1, w), _paint(op[5], w));
      case 'arc':
        canvas.drawArc(
          _rect(op, 1, w),
          n(op[5]),
          n(op[6]),
          op[7] == 1,
          _paint(op[8], w),
        );
      case 'path':
        canvas.drawPath(
          _path(op[1] as int, op[2] as List<Object?>, w),
          _paint(op[3], w),
        );
      case 'points':
        final flat = op[2] as List<Object?>;
        canvas.drawPoints(ui.PointMode.values[op[1] as int], [
          for (var i = 0; i < flat.length; i += 2)
            Offset(n(flat[i]), n(flat[i + 1])),
        ], _paint(op[3], w));
      case 'fill':
        canvas.drawColor(drawingColor(op[1]), BlendMode.values[op[2] as int]);
      case 'paint':
        canvas.drawPaint(_paint(op[1], w));
      case 'text':
        _text(canvas, op, w);
      default:
        throw UnsupportedError('Unknown drawing step ${op[0]}');
    }
  }
}

double drawingNumber(Object? v, double width) {
  if (v is num) return v.toDouble();
  final m = v as Map;
  final line = m['w'] as List?;
  if (line != null) return (line[0] as num) + (line[1] as num) * width;
  // An angle between two straight lines in the width, as a painter turns
  // to lie along a slope: atan2(c + d w, e + f w).
  if (m['a'] case [num c, num d, num e, num f]) {
    return math.atan2(c + d * width, e + f * width);
  }
  // Bent: straight between the recorded corners, and the end pieces carried
  // on past the ends.
  final p = (m['p'] as List).cast<num>();
  var i = 0;
  while (i + 4 < p.length && width > p[i + 2]) {
    i += 2;
  }
  final (w0, v0, w1, v1) = (p[i], p[i + 1], p[i + 2], p[i + 3]);
  return v0 + (v1 - v0) * (width - w0) / (w1 - w0);
}

Color drawingColor(Object? v) {
  final c = (v as Map)['#'];
  if (c is List) {
    final (day, night) = (c[0], c[1]);
    if (day is int && night is int) return ThemedColor(day, night);
    return _PairColor(_color(day), _color(night));
  }
  return _color(c);
}

Color _color(Object? c) {
  if (c is int) return Color(c);
  final f = ((c as Map)['f'] as List).cast<num>();
  return Color.from(
    alpha: f[0].toDouble(),
    red: f[1].toDouble(),
    green: f[2].toDouble(),
    blue: f[3].toDouble(),
  );
}

/// [ThemedColor] for colors that are not whole bytes.
class _PairColor extends Color {
  _PairColor(this.day, this.night)
    : super.from(alpha: day.a, red: day.r, green: day.g, blue: day.b);

  final Color day;
  final Color night;

  Color get _now => AppPalette.dark ? night : day;

  @override
  double get a => _now.a;
  @override
  double get r => _now.r;
  @override
  double get g => _now.g;
  @override
  double get b => _now.b;
}

Rect _rect(List<Object?> op, int at, double w) => Rect.fromLTRB(
  drawingNumber(op[at], w),
  drawingNumber(op[at + 1], w),
  drawingNumber(op[at + 2], w),
  drawingNumber(op[at + 3], w),
);

RRect _rrect(List<Object?> op, int at, double w) {
  double n(int i) => drawingNumber(op[at + i], w);
  return RRect.fromLTRBAndCorners(
    n(0),
    n(1),
    n(2),
    n(3),
    topLeft: Radius.elliptical(n(4), n(5)),
    topRight: Radius.elliptical(n(6), n(7)),
    bottomRight: Radius.elliptical(n(8), n(9)),
    bottomLeft: Radius.elliptical(n(10), n(11)),
  );
}

Path _path(int fillType, List<Object?> cmds, double w) =>
    buildPath(fillType, cmds, w);

/// A path from its recorded moves: the moves a figure made (figure_path.dart),
/// or, for a path built some other way, its traced outline (M, L, Z). A
/// `T` move carries everything before it through a matrix.
Path buildPath(int fillType, List<Object?> cmds, double w) {
  var path = Path()..fillType = PathFillType.values[fillType];
  for (final raw in cmds) {
    final c = raw! as List<Object?>;
    double n(int i) => drawingNumber(c[i], w);
    Rect rect(int i) => Rect.fromLTRB(n(i), n(i + 1), n(i + 2), n(i + 3));
    switch (c[0]) {
      case 'F':
        path.fillType = PathFillType.values[c[1]! as int];
      case 'M':
        path.moveTo(n(1), n(2));
      case 'm':
        path.relativeMoveTo(n(1), n(2));
      case 'L':
        path.lineTo(n(1), n(2));
      case 'l':
        path.relativeLineTo(n(1), n(2));
      case 'Q':
        path.quadraticBezierTo(n(1), n(2), n(3), n(4));
      case 'q':
        path.relativeQuadraticBezierTo(n(1), n(2), n(3), n(4));
      case 'C':
        path.cubicTo(n(1), n(2), n(3), n(4), n(5), n(6));
      case 'c':
        path.relativeCubicTo(n(1), n(2), n(3), n(4), n(5), n(6));
      case 'K':
        path.conicTo(n(1), n(2), n(3), n(4), n(5));
      case 'A':
        path.arcTo(rect(1), n(5), n(6), c[7] == 1);
      case 'AP':
        path.arcToPoint(
          Offset(n(1), n(2)),
          radius: Radius.elliptical(n(3), n(4)),
          rotation: n(5),
          largeArc: c[6] == 1,
          clockwise: c[7] == 1,
        );
      case 'R':
        path.addRect(rect(1));
      case 'O':
        path.addOval(rect(1));
      case 'AA':
        path.addArc(rect(1), n(5), n(6));
      case 'PG':
        final flat = c[2]! as List<Object?>;
        path.addPolygon([
          for (var i = 0; i < flat.length; i += 2)
            Offset(drawingNumber(flat[i], w), drawingNumber(flat[i + 1], w)),
        ], c[1] == 1);
      case 'RR':
        path.addRRect(
          RRect.fromLTRBAndCorners(
            n(1),
            n(2),
            n(3),
            n(4),
            topLeft: Radius.elliptical(n(5), n(6)),
            topRight: Radius.elliptical(n(7), n(8)),
            bottomRight: Radius.elliptical(n(9), n(10)),
            bottomLeft: Radius.elliptical(n(11), n(12)),
          ),
        );
      case 'Z':
        path.close();
      case 'X':
        // Two paths combined, each rebuilt from its own moves.
        path = Path.combine(
          PathOperation.values[c[1]! as int],
          buildPath(c[2]! as int, c[3]! as List<Object?>, w),
          buildPath(c[4]! as int, c[5]! as List<Object?>, w),
        )..fillType = PathFillType.values[fillType];
      case 'T':
        // Everything so far moved by a 4 by 4 matrix, in column order.
        path = path.transform(
          Float64List.fromList([for (var i = 1; i <= 16; i++) n(i)]),
        );
      default:
        throw UnsupportedError('Unknown path move ${c[0]}');
    }
  }
  return path;
}

Paint _paint(Object? raw, double w) {
  final p = raw as Map;
  final paint = Paint()..color = drawingColor(p);
  if (p['s'] == 1) paint.style = PaintingStyle.stroke;
  if (p['w'] != null) paint.strokeWidth = drawingNumber(p['w'], w);
  if (p['cap'] != null) paint.strokeCap = StrokeCap.values[p['cap'] as int];
  if (p['join'] != null) {
    paint.strokeJoin = StrokeJoin.values[p['join'] as int];
  }
  if (p['ml'] != null) paint.strokeMiterLimit = drawingNumber(p['ml'], w);
  if (p['aa'] == 0) paint.isAntiAlias = false;
  if (p['bm'] != null) paint.blendMode = BlendMode.values[p['bm'] as int];
  return paint;
}

void _text(Canvas canvas, List<Object?> op, double w) {
  final opts = op[6] as Map;
  final max = op[3];
  final painter =
      TextPainter(
        text: drawingSpan(op[1]),
        textAlign:
            TextAlign.values[(opts['al'] as int?) ?? TextAlign.start.index],
        textDirection: opts['rtl'] == 1 ? TextDirection.rtl : TextDirection.ltr,
        maxLines: opts['ml'] as int?,
        ellipsis: opts['el'] as String?,
        textWidthBasis: TextWidthBasis.values[(opts['wb'] as int?) ?? 0],
      )..layout(
        minWidth: drawingNumber(op[2], w),
        maxWidth: max == null ? double.infinity : drawingNumber(max, w),
      );
  painter
    ..paint(canvas, Offset(drawingNumber(op[4], w), drawingNumber(op[5], w)))
    ..dispose();
}

InlineSpan? drawingSpan(Object? raw) {
  if (raw == null) return null;
  final s = raw as Map;
  return TextSpan(
    text: s['t'] as String?,
    style: s['st'] == null ? null : _style(s['st'] as Map),
    children: s['ch'] == null
        ? null
        : [for (final c in s['ch'] as List) drawingSpan(c)!],
  );
}

/// The families google_fonts registers, by the name it registers them
/// under ("JetBrainsMono_500"), back to the name it is asked for by, so a
/// played-back label loads its face exactly as the painter's did.
const _googleNames = {
  'JetBrainsMono': 'JetBrains Mono',
  'DMSans': 'DM Sans',
  'Inter': 'Inter',
};

TextStyle _style(Map s) {
  final style = TextStyle(
    fontFamily: s['ff'] as String?,
    fontFamilyFallback: (s['fb'] as List?)?.cast<String>(),
    fontSize: (s['fs'] as num?)?.toDouble(),
    fontWeight: s['fw'] == null
        ? null
        : FontWeight.values.firstWhere((f) => f.value == s['fw']),
    fontStyle: s['it'] == 1 ? FontStyle.italic : null,
    letterSpacing: (s['ls'] as num?)?.toDouble(),
    wordSpacing: (s['ws'] as num?)?.toDouble(),
    height: (s['h'] as num?)?.toDouble(),
    color: s['c'] == null ? null : drawingColor(s['c']),
    textBaseline: s['bl'] == null ? null : TextBaseline.values[s['bl'] as int],
    leadingDistribution: s['ld'] == null
        ? null
        : TextLeadingDistribution.values[s['ld'] as int],
  );
  final family = style.fontFamily;
  if (family == null) return style;
  final [name, variant] = family.contains('_')
      ? family.split('_')
      : [family, 'regular'];
  final google = _googleNames[name];
  if (google == null) return style;
  // Ask google_fonts for the exact face the painter's style named, which is
  // what loads it. The style is kept as recorded: a painter that asked for a
  // heavier weight on a lighter face (copyWith on a google style) must get
  // that, not the heavier face.
  final weight = int.tryParse(variant.replaceAll('italic', '')) ?? 400;
  GoogleFonts.getFont(
    google,
    fontWeight: FontWeight.values.firstWhere((f) => f.value == weight),
    fontStyle: variant.contains('italic') ? FontStyle.italic : null,
  );
  return style;
}
