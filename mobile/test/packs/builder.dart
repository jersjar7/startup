import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/mechanics_pictures.dart';
import 'package:mobile/features/packs/drawing/figure_path.dart';
import 'package:mobile/features/packs/drawing/recording_canvas.dart';

/// The pack builder's recording half (ADR 0030; docs/mobile/
/// content-packs-migration.md, phase 0).
///
/// A painter draws to whatever width the phone gives it, so a figure is
/// recorded across the whole range of widths it can meet, in both themes:
///
/// - Day and night must be the same drawing in different colors. Colors
///   become `[day, night]` pairs; any other difference stops the build.
/// - Each number keeps the rule it follows as the width changes. Most follow
///   one straight line (`{"w": [a, b]}`). A number that bends, say a label
///   pushed back inside the frame on a narrow phone, keeps the widths where
///   it bends (`{"p": [w0, v0, w1, v1, ...]}`), each found to within a
///   quarter of a pixel of width.
/// - Where the drawing itself changes (a different label, a step more or
///   less), it is split into bands, each its own drawing (`{"bands": [[from
///   width, steps], ...]}`).
///
/// Numbers are kept at full precision, and the result matches the painter at
/// every width to within a ten-thousandth of a pixel.

typedef Draw = void Function(Canvas canvas, Size size);

/// The widths a game's figure meets: the screen less 50. From the smallest
/// phone to a large Android tablet.
const gameRange = (250.0, 1000.0);

/// A drawing that shares its row with another on a concept sheet.
const pairRange = (100.0, 500.0);

/// A drawing alone on a concept sheet.
const sheetRange = (250.0, 1000.0);

/// What the builder found, for the phase 0 report.
final stats = <String, int>{
  'drawings': 0,
  'straight': 0,
  'bent': 0,
  'banded': 0,
  'recordings': 0,
};

/// How far a played-back number may sit from the painter's own: a ten
/// thousandth of a pixel, which no phone can show.
const _tol = 1e-4;

/// The same for an angle. A turn moves a point by the angle times its
/// distance from the pivot, and a figure is up to a thousand pixels across,
/// so an angle is kept a thousand times closer (does-the-mass-matter's
/// blocks on the slope moved edge pixels at the plain tolerance).
const _angleTol = 1e-7;

/// How close a move of the canvas is kept: it carries everything drawn
/// after it, turned shapes included, which land a shade differently on an
/// edge pixel at the plain tolerance.
const _moveTol = 1e-5;

/// The tolerance for the numbers inside [op]: tighter for a rotation and
/// for a move of the canvas.
double _tolFor(List<Object?> op, double tol) => switch (op.firstOrNull) {
  'rot' => _angleTol,
  'tr' => _moveTol,
  _ => tol,
};

Object record(
  Draw draw,
  double height, {
  (double, double) range = gameRange,
  required String what,
}) {
  final cache = <double, List<Object?>>{};
  List<Object?> at(double w) => cache.putIfAbsent(
    w,
    () => _runs(
      _mergeThemes(
            _once(draw, Size(w, height), dark: false),
            _once(draw, Size(w, height), dark: true),
            '$what at width $w',
          )
          as List<Object?>,
    ),
  );

  final (lo, hi) = range;
  final widths = <double>{};
  for (var w = lo; w < hi; w += 25) {
    _refine(at, w, (w + 25).clamp(lo, hi), widths);
  }
  final sorted = widths.toList()..sort();

  // Split into bands wherever the drawing itself changes.
  final bands = <List<double>>[[]];
  for (final w in sorted) {
    if (bands.last.isNotEmpty && !_sameShape(at(bands.last.last), at(w))) {
      bands.add([]);
    }
    bands.last.add(w);
  }

  stats['drawings'] = stats['drawings']! + 1;
  stats['recordings'] = stats['recordings']! + cache.length * 2;
  var bent = false;
  final merged = [
    for (final band in bands)
      _mergeWidths(
        [for (final w in band) at(w)],
        band,
        () => bent = true,
        at: at,
        path: const [],
      ),
  ];
  if (bands.length > 1) {
    stats['banded'] = stats['banded']! + 1;
  } else if (bent) {
    stats['bent'] = stats['bent']! + 1;
  } else {
    stats['straight'] = stats['straight']! + 1;
  }
  if (bands.length == 1) return _round(merged.single)!;
  return {
    'bands': [
      for (var i = 0; i < bands.length; i++)
        [
          i == 0 ? 0 : _boundary(at, bands[i - 1].last, bands[i].first),
          _round(merged[i]),
        ],
    ],
  };
}

/// Adds widths between [a] and [b] until every number between them is a
/// straight line to within [_tol], and every change of shape is pinned to
/// a quarter of a pixel.
void _refine(
  List<Object?> Function(double) at,
  double a,
  double b,
  Set<double> out,
) {
  out
    ..add(a)
    ..add(b);
  if (b - a <= 0.25) return;
  final m = (a + b) / 2;
  final ta = at(a), tm = at(m), tb = at(b);
  if (!_sameShape(ta, tb) ||
      !_sameShape(ta, tm) ||
      !_straight(ta, tm, tb, a, m, b)) {
    _refine(at, a, m, out);
    _refine(at, m, b, out);
  }
}

double _boundary(List<Object?> Function(double) at, double a, double b) {
  final left = at(a);
  while (b - a > 0.01) {
    final m = (a + b) / 2;
    if (_sameShape(left, at(m))) {
      a = m;
    } else {
      b = m;
    }
  }
  return (b * 100).ceil() / 100;
}

bool _straight(
  Object? a,
  Object? m,
  Object? b,
  double wa,
  double wm,
  double wb, [
  double tol = _tol,
]) {
  if (a is num) {
    final predicted = a + ((b! as num) - a) * (wm - wa) / (wb - wa);
    return (predicted - (m! as num)).abs() <= tol;
  }
  if (a is List) {
    final t = _tolFor(a, tol);
    for (var i = 0; i < a.length; i++) {
      if (!_straight(a[i], (m! as List)[i], (b! as List)[i], wa, wm, wb, t)) {
        return false;
      }
    }
  }
  if (a is Map && a.length == 1 && a.containsKey('n')) {
    // A count steps; it is never a straight line between two widths.
    return a['n'] == (m! as Map)['n'] && a['n'] == (b! as Map)['n'];
  }
  if (a is Map) {
    for (final k in a.keys) {
      if (k == '#') continue;
      if (!_straight(a[k], (m! as Map)[k], (b! as Map)[k], wa, wm, wb, tol)) {
        return false;
      }
    }
  }
  return true;
}

List<Object?> _once(Draw draw, Size size, {required bool dark}) {
  final was = AppPalette.dark;
  AppPalette.dark = dark;
  recordPaths = true;
  try {
    final canvas = RecordingCanvas();
    draw(canvas, size);
    return canvas.ops;
  } finally {
    AppPalette.dark = was;
    recordPaths = false;
  }
}

bool _same(Object? a, Object? b) {
  if (a is num && b is num) return (a - b).abs() < 1e-9;
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_same(a[i], b[i])) return false;
    }
    return true;
  }
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    return a.keys.every((k) => b.containsKey(k) && _same(a[k], b[k]));
  }
  return a == b;
}

/// The same drawing, numbers aside.
bool _sameShape(Object? a, Object? b) {
  if (a is num && b is num) return true;
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_sameShape(a[i], b[i])) return false;
    }
    return true;
  }
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    return a.keys.every(
      (k) =>
          b.containsKey(k) &&
          (k == '#' ? _same(a[k], b[k]) : _sameShape(a[k], b[k])),
    );
  }
  return a == b;
}

/// Day and night as one drawing: identical except for colors, which become
/// `[day, night]` pairs where they differ.
Object? _mergeThemes(Object? day, Object? night, String where) {
  if (day is Map && night is Map) {
    if (!_same(day.keys.toList()..sort(), night.keys.toList()..sort())) {
      throw StateError('$where: day and night draw different things');
    }
    return {
      for (final k in day.keys)
        k: k == '#'
            ? (_same(day[k], night[k]) ? day[k] : [day[k], night[k]])
            : _mergeThemes(day[k], night[k], '$where.$k'),
    };
  }
  if (day is List && night is List) {
    if (day.length != night.length) {
      throw StateError('$where: day and night draw different things');
    }
    return [
      for (var i = 0; i < day.length; i++)
        _mergeThemes(day[i], night[i], '$where[$i]'),
    ];
  }
  if (!_same(day, night)) {
    throw StateError('$where: day $day, night $night (only colors may differ)');
  }
  return day;
}

/// One band's widths as one drawing.
Object? _mergeWidths(
  List<Object?> trees,
  List<double> widths,
  void Function() bent, {
  required List<Object?> Function(double) at,
  required List<Object> path,
  double tol = _tol,
}) {
  Object? merge(List<Object?> sub, Object key, [double t = _tol]) =>
      _mergeWidths(sub, widths, bent, at: at, path: [...path, key], tol: t);
  final first = trees.first;
  if (first is Map && first.length == 1 && first.containsKey('n')) {
    return _count(trees, widths, at, path);
  }
  if (first is Map) {
    return {
      for (final k in first.keys)
        k: k == '#'
            ? first[k]
            : merge([for (final t in trees) (t! as Map)[k]], k, tol),
    };
  }
  if (first is List) {
    final t = _tolFor(first, tol);
    return [
      for (var i = 0; i < first.length; i++)
        merge([for (final tree in trees) (tree! as List)[i]], i, t),
    ];
  }
  if (first is num) {
    final v = [for (final t in trees) (t! as num).toDouble()];
    if (v.every((x) => (x - v.first).abs() < 1e-9)) return first;
    if (tol == _angleTol) {
      if (_slopeAngle(widths, v) case final fit?) return {'a': fit};
    }
    final keep = _corners(widths, v, tol);
    if (keep.length == 2) {
      final (w0, v0) = keep[0];
      final (w1, v1) = keep[1];
      final b = (v1 - v0) / (w1 - w0);
      return {
        'w': [v0 - b * w0, b],
      };
    }
    bent();
    return {
      'p': [
        for (final (w, x) in keep) ...[w, x],
      ],
    };
  }
  return first;
}

/// How many times a repeated shape is drawn, as the width changes: a whole
/// number that steps, so it keeps the widths where it steps, each pinned to
/// a hundredth of a pixel (`{"n": [count, width, count, width, count...]}`).
Object _count(
  List<Object?> trees,
  List<double> widths,
  List<Object?> Function(double) at,
  List<Object> path,
) {
  int n(Object? t) => ((t! as Map)['n'] as num).toInt();
  int countAt(double w) {
    Object? node = at(w);
    for (final k in path) {
      node = k is int ? (node! as List)[k] : (node! as Map)[k];
    }
    return n(node);
  }

  final steps = <num>[n(trees.first)];
  for (var i = 1; i < trees.length; i++) {
    if (n(trees[i]) == n(trees[i - 1])) continue;
    var (a, b) = (widths[i - 1], widths[i]);
    final left = n(trees[i - 1]);
    while (b - a > 0.005) {
      final m = (a + b) / 2;
      if (countAt(m) == left) {
        a = m;
      } else {
        b = m;
      }
    }
    steps.addAll([(b * 1000).ceil() / 1000, n(trees[i])]);
  }
  return steps.length == 1 ? steps.single : {'n': steps};
}

/// The same shape drawn again and again at an even spacing (a dashed line,
/// a row of ticks, a hatch) becomes one step: draw this, so many times,
/// moving by this much each time (`["run", {"n": count}, first, step]`).
/// Without it, every width that fits one more dash would be a drawing of
/// its own.
List<Object?> _runs(List<Object?> ops) {
  const least = 3;
  final out = <Object?>[];
  var i = 0;
  while (i < ops.length) {
    var end = i + 1;
    final step = end < ops.length ? _step(ops[i], ops[end]) : null;
    if (step != null) {
      while (end + 1 < ops.length &&
          _same(_step(ops[end], ops[end + 1]), step)) {
        end++;
      }
      end++;
    }
    if (step != null && end - i >= least) {
      out.add([
        'run',
        {'n': end - i},
        ops[i],
        step,
      ]);
      i = end;
    } else {
      out.add(ops[i]);
      i++;
    }
  }
  return out;
}

/// What changes from [a] to [b], if they are the same drawing step moved:
/// every number's difference, null where nothing is a number. Null when
/// they differ in anything but numbers.
Object? _step(Object? a, Object? b) {
  if (a is! List || b is! List || a.isEmpty || a.first == 'run') return null;
  if (!_sameShape(a, b)) return null;
  Object? diff(Object? x, Object? y) {
    if (x is num && y is num) return y - x;
    if (x is List) {
      return [for (var i = 0; i < x.length; i++) diff(x[i], (y! as List)[i])];
    }
    if (x is Map) {
      return {
        for (final k in x.keys)
          if (k != '#') k: diff(x[k], (y! as Map)[k]),
      };
    }
    return null;
  }

  final d = diff(a, b);
  // Nothing moved: the same step twice is not a run.
  bool moved(Object? v) => v is num
      ? v != 0
      : v is List
      ? v.any(moved)
      : v is Map && v.values.any(moved);
  return moved(d) ? d : null;
}

/// An angle that is atan2 of two straight lines in the width, as a figure
/// turned to lie along a slope whose run follows the width: `[c, d, e, f]`
/// for atan2(c + d w, e + f w), when that matches every recorded angle to
/// within [_angleTol]. Solved from three widths and checked at all of them.
List<double>? _slopeAngle(List<double> w, List<double> v) {
  if (w.length < 4) return null;
  final picks = [0, w.length ~/ 2, w.length - 1];
  // tan v (1 + b w) = c + d w, so  -w tan v * b + c + d w = tan v.
  final rows = [
    for (final i in picks) [-w[i] * math.tan(v[i]), 1.0, w[i], math.tan(v[i])],
  ];
  // Gaussian elimination with partial pivoting on the 3 by 4 system.
  for (var col = 0; col < 3; col++) {
    var best = col;
    for (var r = col + 1; r < 3; r++) {
      if (rows[r][col].abs() > rows[best][col].abs()) best = r;
    }
    if (rows[best][col].abs() < 1e-12) return null;
    final t = rows[col];
    rows[col] = rows[best];
    rows[best] = t;
    for (var r = 0; r < 3; r++) {
      if (r == col) continue;
      final k = rows[r][col] / rows[col][col];
      for (var c = col; c < 4; c++) {
        rows[r][c] -= k * rows[col][c];
      }
    }
  }
  final b = rows[0][3] / rows[0][0];
  final c = rows[1][3] / rows[1][1];
  final d = rows[2][3] / rows[2][2];
  // The run (1 + b w) must keep one sign, and match the angle's quadrant.
  final sign = math.cos(v.first).sign;
  final fit = [c * sign, d * sign, sign, b * sign];
  for (var i = 0; i < w.length; i++) {
    final x = fit[2] + fit[3] * w[i];
    final y = fit[0] + fit[1] * w[i];
    if (x.sign != sign) return null;
    if ((math.atan2(y, x) - v[i]).abs() > _angleTol) return null;
  }
  return fit;
}

/// The fewest (width, value) points whose straight joins stay within
/// [_tol] of every recorded value.
List<(double, double)> _corners(
  List<double> w,
  List<double> v, [
  double tol = _tol,
]) {
  final keep = <int>[0];
  var start = 0;
  for (var end = 2; end < w.length; end++) {
    for (var i = start + 1; i < end; i++) {
      final predicted =
          v[start] +
          (v[end] - v[start]) * (w[i] - w[start]) / (w[end] - w[start]);
      if ((predicted - v[i]).abs() > tol) {
        start = end - 1;
        keep.add(start);
        break;
      }
    }
  }
  keep.add(w.length - 1);
  return [for (final i in keep) (w[i], v[i])];
}

/// Whole numbers written as whole numbers; everything else exactly as the
/// painter computed it, since the phone draws in single precision and a
/// rounded corner of a rectangle is a different pixel.
Object? _round(Object? v) {
  if (v is double) {
    return v == v.roundToDouble() && v.abs() < 1e15 ? v.toInt() : v;
  }
  if (v is List) return [for (final x in v) _round(x)];
  if (v is Map) {
    return {
      for (final e in v.entries)
        // A color's exact components stay exact.
        e.key: e.key == '#' ? e.value : _round(e.value),
    };
  }
  return v;
}

/// A concept sheet as pack data, its picture recorded.
Map<String, Object?> briefJson(BriefSection b, String name) {
  final picture = b.picture == null ? null : pictureJson(b.picture!(), name);
  return {
    'title': b.title,
    'lesson': ?lessonForBrief(b)?.name,
    if (b.body.isNotEmpty) 'body': b.body,
    'formula': ?b.formula,
    if (b.formulas.isNotEmpty)
      'formulas': [
        for (final (a, c) in b.formulas) [a, c],
      ],
    'handbook': ?b.handbook,
    if (b.steps.isNotEmpty)
      'steps': [
        for (final (a, c) in b.steps) [a, c],
      ],
    if (b.spoken.isNotEmpty)
      'spoken': [
        for (final (a, c, d) in b.spoken) [a, c, d],
      ],
    'picture': ?picture,
  };
}

/// A concept sheet's picture as pack data: one drawing, two side by side,
/// or several of those stacked in a column with gaps between.
Map<String, Object?> pictureJson(Widget w, String name) {
  if (w is ConceptPicture) {
    return {
      'kind': 'one',
      'h': w.height,
      'caption': w.caption,
      'ops': record(
        w.painter.paint,
        w.height,
        range: sheetRange,
        what: '$name picture',
      ),
    };
  }
  if (w is ConceptPair) {
    return {
      'kind': 'pair',
      'h': w.height,
      'left': {
        'caption': w.leftCaption,
        'ops': record(
          w.left.paint,
          w.height,
          range: pairRange,
          what: '$name left',
        ),
      },
      'right': {
        'caption': w.rightCaption,
        'ops': record(
          w.right.paint,
          w.height,
          range: pairRange,
          what: '$name right',
        ),
      },
    };
  }
  // A row written out by hand exactly as ConceptPair builds it is that pair.
  if (w case Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
    mainAxisSize: MainAxisSize.max,
    key: null,
    children: [
      Expanded(flex: 1, child: final ConceptPicture left),
      SizedBox(width: 10, height: null, child: null),
      Expanded(flex: 1, child: final ConceptPicture right),
    ],
  ) when left.height == right.height) {
    return pictureJson(
      ConceptPair(
        left: left.painter,
        right: right.painter,
        leftCaption: left.caption,
        rightCaption: right.caption,
        height: left.height,
      ),
      name,
    );
  }
  // Only a plain column: any setting off its defaults would be lost.
  if (w is Column &&
      w.mainAxisAlignment == MainAxisAlignment.start &&
      w.mainAxisSize == MainAxisSize.max &&
      w.crossAxisAlignment == CrossAxisAlignment.center &&
      w.key == null) {
    return {
      'kind': 'column',
      'children': [
        for (final (i, c) in w.children.indexed)
          if (c is SizedBox && c.child == null && c.width == null)
            {'kind': 'gap', 'h': c.height}
          else
            pictureJson(c, '$name $i'),
      ],
    };
  }
  throw UnsupportedError('$name: picture layout ${w.runtimeType}');
}

/// A rectangle as a region, in the same width-following numbers.
Object regionOf(Rect Function(Size size) rect, double height, String what) =>
    record(
      (canvas, size) => canvas.drawRect(rect(size), ui.Paint()),
      height,
      what: what,
    );
