// Writes every badge drawing out as strokes for the Rive build.
//
//   flutter test tool/export_badge_marks_test.dart
//   python3 rive/badge/gen.py && rive rive/badge --once
//
// It is a test only so that it can run the app's own painters; it lives
// outside test/ so the ordinary suite never runs it. The painters in
// badge_marks.dart stay the one source of every drawing: this plays each
// one onto a canvas that records instead of drawing, turns every curve into
// points (simplified, so a straight line stays two points), and writes
// rive/badge/marks.json in the badges' own order.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/profile/badge_marks.dart';
import 'package:mobile/features/profile/badges.dart';

class _Stroke {
  _Stroke(this.path, this.paint);
  final Path path;
  final Paint paint;
}

/// Keeps every shape as a path, under the painter's save, translate and
/// scale. The marks use lines, paths, circles and rounded rectangles.
class _Recorder implements Canvas {
  final strokes = <_Stroke>[];
  final List<Matrix4> _stack = [];
  Matrix4 _m = Matrix4.identity();

  void _add(Path p, Paint paint) =>
      strokes.add(_Stroke(p.transform(_m.storage), paint));

  @override
  void save() => _stack.add(_m.clone());
  @override
  void restore() =>
      _m = _stack.isEmpty ? Matrix4.identity() : _stack.removeLast();
  @override
  void translate(double dx, double dy) => _m.translateByDouble(dx, dy, 0, 1);
  @override
  void scale(double sx, [double? sy]) => _m.scaleByDouble(sx, sy ?? sx, 1, 1);
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) => _add(
    Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy),
    paint,
  );
  @override
  void drawPath(Path path, Paint paint) => _add(Path.from(path), paint);
  @override
  void drawCircle(Offset c, double radius, Paint paint) =>
      _add(Path()..addOval(Rect.fromCircle(center: c, radius: radius)), paint);
  @override
  void drawRect(Rect rect, Paint paint) => _add(Path()..addRect(rect), paint);
  @override
  void drawRRect(RRect rrect, Paint paint) =>
      _add(Path()..addRRect(rrect), paint);
  @override
  void drawOval(Rect rect, Paint paint) => _add(Path()..addOval(rect), paint);
  @override
  void drawArc(Rect r, double start, double sweep, bool useCenter, Paint p) =>
      _add(Path()..addArc(r, start, sweep), p);
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('a badge mark used ${invocation.memberName}');
}

double _distToSegment(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 == 0) return (p - a).distance;
  final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2).clamp(0.0, 1.0);
  return (p - (a + ab * t)).distance;
}

/// Ramer-Douglas-Peucker, to [tol] units of the 512 square.
List<Offset> _simplify(List<Offset> pts, double tol) {
  if (pts.length < 3) return pts;
  var worst = 0.0;
  var at = 0;
  for (var i = 1; i < pts.length - 1; i++) {
    final d = _distToSegment(pts[i], pts.first, pts.last);
    if (d > worst) {
      worst = d;
      at = i;
    }
  }
  if (worst <= tol) return [pts.first, pts.last];
  final left = _simplify(pts.sublist(0, at + 1), tol);
  final right = _simplify(pts.sublist(at), tol);
  return [...left.sublist(0, left.length - 1), ...right];
}

List<Map<String, Object>> _contours(Path path) {
  final out = <Map<String, Object>>[];
  for (final m in path.computeMetrics()) {
    final pts = <Offset>[];
    const step = 1.0;
    for (var d = 0.0; d < m.length; d += step) {
      pts.add(m.getTangentForOffset(d)!.position);
    }
    pts.add(m.getTangentForOffset(m.length)!.position);
    var simple = _simplify(pts, 0.35);
    if (m.isClosed && simple.length > 2 && simple.first == simple.last) {
      simple = simple.sublist(0, simple.length - 1);
    }
    // A closed shape simplified from its start point can lose too much; a
    // circle keeps at least a smooth ring of points.
    if (m.isClosed && simple.length < 12) {
      simple = [
        for (var i = 0; i < 24; i++)
          m.getTangentForOffset(m.length * i / 24)!.position,
      ];
    }
    out.add({
      'closed': m.isClosed,
      'length': double.parse(m.length.toStringAsFixed(2)),
      'points': [
        for (final p in simple)
          [
            double.parse(p.dx.toStringAsFixed(2)),
            double.parse(p.dy.toStringAsFixed(2)),
          ],
      ],
    });
  }
  return out;
}

void main() {
  test('export badge marks', () {
    final marks = <Map<String, Object>>[];
    for (final b in allBadges) {
      final rec = _Recorder();
      BadgeMarkPainter(
        markId: b.id,
        color: Colors.black,
      ).paint(rec, const Size(512, 512));
      marks.add({
        'id': b.id,
        'strokes': [
          for (final s in rec.strokes)
            {
              'fill': s.paint.style == PaintingStyle.fill,
              'width': s.paint.strokeWidth,
              'contours': _contours(s.path),
            },
        ],
      });
    }
    final file = File('rive/badge/marks.json');
    file.writeAsStringSync(
      '${const JsonEncoder.withIndent(null).convert({'marks': marks})}\n',
    );
    final points = marks.fold<int>(
      0,
      (a, m) =>
          a +
          (m['strokes'] as List).fold<int>(
            0,
            (b, s) =>
                b +
                ((s as Map)['contours'] as List).fold<int>(
                  0,
                  (c, k) => c + ((k as Map)['points'] as List).length,
                ),
          ),
    );
    // ignore: avoid_print
    print('wrote ${marks.length} marks, $points points');
    expect(marks.length, allBadges.length);
    expect(math.max(points, 1), greaterThan(0));
  });
}
