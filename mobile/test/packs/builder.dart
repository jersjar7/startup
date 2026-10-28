import 'dart:async';
import 'dart:collection';
import 'dart:convert';
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
const plainTolerance = 1e-4;

/// The tolerance of the drawing being recorded: [plainTolerance], unless
/// [record] or [closer] asked for closer.
double _tol = plainTolerance;

/// Runs [body] with every drawing it records kept to [tolerance] instead
/// of [plainTolerance].
///
/// For a figure whose numbers land a pixel's edge sampling on the other
/// side at the plain tolerance across far more of the screen than ADR 0031
/// allows: Which Distance Counts runs a dashed line of action down the
/// middle of a slanted strut, and every dash of it drew a few shades off.
T closer<T>(double tolerance, T Function() body) {
  final was = _tol;
  _tol = tolerance;
  try {
    return body();
  } finally {
    _tol = was;
  }
}

/// The same for an angle. A turn moves a point by the angle times its
/// distance from the pivot, and a figure is up to a thousand pixels across,
/// so an angle is kept a thousand times closer (does-the-mass-matter's
/// blocks on the slope moved edge pixels at the plain tolerance).
const _angleTol = 1e-7;

/// How many times a run repeats at one width.
int _runCount(Object? count) => switch (count) {
  {'n': final int n} => n,
  final int n => n,
  _ => 1,
};

/// How close a move of the canvas is kept: it carries everything drawn
/// after it, turned shapes included, which land a shade differently on an
/// edge pixel at the plain tolerance.
const _moveTol = 1e-5;

/// How close a path's matrix (its `T` move) is kept: its scale multiplies
/// every point of a shape drawn in world units, so at the plain tolerance
/// the edge of a Statics cross section landed a row of pixels two shades
/// out.
const _matrixTol = 1e-8;

/// The tolerance for the numbers inside [op]: tighter for a rotation, for
/// a move of the canvas, and for a path's matrix.
double _tolFor(List<Object?> op, double tol) => switch (op.firstOrNull) {
  'rot' => _angleTol,
  'tr' => _moveTol,
  'T' => _matrixTol,
  _ => tol,
};

Object record(
  Draw draw,
  double height, {
  (double, double) range = gameRange,
  double? tolerance,
  required String what,
}) {
  final was = _tol;
  _tol = tolerance ?? _tol;
  try {
    return _recorded(draw, height, range, what);
  } finally {
    _tol = was;
  }
}

Object _recorded(
  Draw draw,
  double height,
  (double, double) range,
  String what,
) {
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
  _seeLoneBands(at, widths);
  final sorted = widths.toList()..sort();
  stats['drawings'] = stats['drawings']! + 1;
  stats['recordings'] = stats['recordings']! + cache.length * 2;
  return _fromWidths(at, sorted);
}

/// A drawing from its steps at the widths looked at: one list of steps, or
/// bands of them where the drawing itself changes with the width.
///
/// When only a stretch of it changes (a dashed line that gains a dash
/// every ten pixels, with a curve of 240 points before and after it), the
/// steps before and after that stretch can be kept once and only the
/// stretch in bands (`{"parts": [...]}`, played one after the other).
/// Kept that way when it is smaller: How Many Samples kept its whole
/// picture once per dash, 6.9 MB, and 45 KB in parts.
Object _fromWidths(List<Object?> Function(double) at, List<double> sorted) {
  final whole = _banded(at, sorted);
  if (whole is! Map) return whole;
  final lists = [for (final w in sorted) at(w)];
  final shortest = lists.map((l) => l.length).reduce(math.min);
  bool steady(int Function(List<Object?>) index) => lists.every(
    (l) => _sameShape(l[index(l)], lists.first[index(lists.first)]),
  );
  var head = 0;
  while (head < shortest && steady((l) => head)) {
    head++;
  }
  var tail = 0;
  while (head + tail < shortest && steady((l) => l.length - 1 - tail)) {
    tail++;
  }
  if (head + tail == 0) return whole;
  List<Object?> Function(double) slice(int from, int fromEnd) => (w) {
    final l = at(w);
    return l.sublist(from, l.length - fromEnd);
  };
  final parts = {
    'parts': [
      if (head > 0)
        _banded((w) => at(w).sublist(0, head), sorted, count: false),
      _banded(slice(head, tail), sorted, count: false),
      if (tail > 0)
        _banded(
          (w) {
            final l = at(w);
            return l.sublist(l.length - tail);
          },
          sorted,
          count: false,
        ),
    ],
  };
  return jsonEncode(parts).length < jsonEncode(whole).length ? parts : whole;
}

/// The steps as one list, or in bands where their shape changes.
Object _banded(
  List<Object?> Function(double) at,
  List<double> sorted, {
  bool count = true,
}) {
  final bands = <List<double>>[[]];
  for (final w in sorted) {
    if (bands.last.isNotEmpty && !_sameShape(at(bands.last.last), at(w))) {
      bands.add([]);
    }
    bands.last.add(w);
  }
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
  if (count) {
    final kind = bands.length > 1
        ? 'banded'
        : bent
        ? 'bent'
        : 'straight';
    stats[kind] = stats[kind]! + 1;
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

/// How close a width where the drawing changes (a dash more, a dash cut
/// short) is pinned. At a hundredth of a pixel, Which Rate's dashed line
/// drew its last dash from the wrong side of the change on a few widths.
const _pin = 1e-6;

/// How close together two widths may be looked at, while a number bends.
const _finest = 1 / 1024;

/// Adds widths between [a] and [b] until every number between them is a
/// straight line to within [_tol] (looking no closer than [_finest]), and
/// every change of shape is pinned to a quarter of a pixel.
void _refine(
  List<Object?> Function(double) at,
  double a,
  double b,
  Set<double> out,
) {
  out
    ..add(a)
    ..add(b);
  if (b - a <= _finest) {
    _pinJump(at, a, b, out);
    return;
  }
  final m = (a + b) / 2;
  final ta = at(a), tm = at(m), tb = at(b);
  final reshaped = !_sameShape(ta, tb) || !_sameShape(ta, tm);
  // A change of shape is pinned afterwards ([_boundary]), so a quarter of a
  // pixel is near enough here. A bend in a number (a dash cut short at the
  // end of its line, from some width on) is followed much closer, or the
  // straight piece across it misses by a tenth of a pixel.
  if (reshaped ? b - a > 0.25 : !_straight(ta, tm, tb, a, m, b)) {
    _refine(at, a, m, out);
    _refine(at, m, b, out);
  }
}

/// Looks again at every shape the search saw at one width only.
///
/// The search stops splitting a change of shape at a quarter of a pixel,
/// so a shape held for less than about that between two others can be
/// seen at a single width, and a band seen once is kept as constants: the
/// last dash of Along It or Not's cable, cut short for a third of a pixel
/// of width around a 320 phone, was played back two hundredths of a pixel
/// off along the whole cable. Each such band is found end to end and
/// searched like any other stretch.
void _seeLoneBands(List<Object?> Function(double) at, Set<double> widths) {
  final sorted = widths.toList()..sort();
  final bands = <List<double>>[[]];
  for (final w in sorted) {
    if (bands.last.isNotEmpty && !_sameShape(at(bands.last.last), at(w))) {
      bands.add([]);
    }
    bands.last.add(w);
  }
  for (var i = 0; i < bands.length; i++) {
    if (bands[i].length > 1) continue;
    final w = bands[i].single;
    final start = i == 0 ? w : _boundary(at, bands[i - 1].last, w);
    final end = i == bands.length - 1
        ? w
        : _boundary(at, w, bands[i + 1].first) - 2 * _pin;
    if (end - start > 2 * _pin && _sameShape(at(start), at(w))) {
      _refine(at, start, end, widths);
    }
  }
}

/// A number that jumps between two widths is never straight, however close
/// they are: a label that fits on one line from some width on, its patch
/// twice as tall below it. Between the two widths around the jump it plays
/// halfway. Which One Drags More, where "heavy oil, 0.4 Pa s" is exactly as
/// wide as the panel leaves it on a 320 phone, drew its patch two pixels
/// tall there. Where the two widths still disagree, a width as round as
/// any between them is recorded as well, so a jump that falls on a whole
/// width is played from the side the painter takes.
void _pinJump(
  List<Object?> Function(double) at,
  double a,
  double b,
  Set<double> out,
) {
  final m = (a + b) / 2;
  final ta = at(a), tm = at(m), tb = at(b);
  if (_sameShape(ta, tb) &&
      _sameShape(ta, tm) &&
      !_straight(ta, tm, tb, a, m, b)) {
    out.add(_roundest(a, b));
  }
}

/// The width between [a] and [b] with the fewest binary places.
double _roundest(double a, double b) {
  for (var step = 1.0; ; step /= 2) {
    final x = ((a / step).floor() + 1) * step;
    if (x < b) return x;
  }
}

double _boundary(List<Object?> Function(double) at, double a, double b) {
  final left = at(a);
  while (b - a > _pin) {
    final m = (a + b) / 2;
    if (_sameShape(left, at(m))) {
      a = m;
    } else {
      b = m;
    }
  }
  return b;
}

bool _straight(
  Object? a,
  Object? m,
  Object? b,
  double wa,
  double wm,
  double wb, [
  double? closer,
]) {
  final tol = closer ?? _tol;
  if (a is num) {
    final predicted = a + ((b! as num) - a) * (wm - wa) / (wb - wa);
    return (predicted - (m! as num)).abs() <= tol;
  }
  if (a is List) {
    final t = _tolFor(a, tol);
    final most = a.firstOrNull == 'run'
        ? [a, m, b].map((x) => _runCount((x! as List)[1])).reduce(math.max)
        : 1;
    for (var i = 0; i < a.length; i++) {
      final ti = most > 1 && i == 2
          ? t / 2
          : most > 1 && i == 3
          ? t / (2 * most)
          : t;
      if (!_straight(a[i], (m! as List)[i], (b! as List)[i], wa, wm, wb, ti)) {
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
    _drained(() => draw(canvas, size));
    return canvas.ops;
  } finally {
    AppPalette.dark = was;
    recordPaths = false;
  }
}

/// Runs [body], then the small jobs it left for the event loop, before
/// returning.
///
/// Every label a figure writes asks google_fonts for its style, and each
/// ask queues a job that only runs when the event loop turns. The builder
/// records each figure at hundreds of widths without ever letting it turn,
/// so the jobs piled up: Fluid Mechanics passed four gigabytes and slowed
/// to a crawl. Running them here keeps a build the size of one drawing.
void _drained(void Function() body) {
  final jobs = ListQueue<void Function()>();
  runZoned(
    () {
      body();
      while (jobs.isNotEmpty) {
        jobs.removeFirst()();
      }
    },
    zoneSpecification: ZoneSpecification(
      scheduleMicrotask: (self, parent, zone, job) => jobs.add(job),
    ),
  );
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
  double? closer,
}) {
  final tol = closer ?? _tol;
  Object? merge(List<Object?> sub, Object key, [double? t]) => _mergeWidths(
    sub,
    widths,
    bent,
    at: at,
    path: [...path, key],
    closer: t ?? _tol,
  );
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
    final most = first.firstOrNull == 'run'
        ? trees.map((tree) => _runCount((tree! as List)[1])).reduce(math.max)
        : 1;
    return [
      for (var i = 0; i < first.length; i++)
        merge(
          [for (final tree in trees) (tree! as List)[i]],
          i,
          // A run's step is added once per repeat, so its error is too, on
          // top of the first one's: half the tolerance each.
          most > 1 && i == 2
              ? t / 2
              : most > 1 && i == 3
              ? t / (2 * most)
              : t,
        ),
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
    while (b - a > _pin) {
      final m = (a + b) / 2;
      if (countAt(m) == left) {
        a = m;
      } else {
        b = m;
      }
    }
    steps.addAll([b, n(trees[i])]);
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
  double? closer,
]) {
  final tol = closer ?? _tol;
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
  final corners = [for (final i in keep) (w[i], v[i])];
  // A corner falls on a width that was looked at, which is near the real
  // bend but not on it, so the piece after it starts a hair off its own
  // line (VennPainter's circles stop growing at 270.45 wide, and the
  // labels under them came out 0.00003 of a pixel high, on a half pixel,
  // a whole pixel off). Where both pieces are straight, the corner moves to
  // where their lines meet, as long as every value still fits.
  for (var c = 1; c < keep.length - 1; c++) {
    final k = keep[c];
    if (k < 2 || k + 2 >= w.length) continue;
    // Each piece's line through two widths well inside it: the widths next
    // to a bend are looked at a thousandth of a pixel apart, too close to
    // find where the lines meet, and the widths at the ends of a piece may
    // already be a hair past a bend (Along It or Not's arrows, bending
    // where the drawing stops growing with the width, were 0.00004 of a
    // pixel out on a 390 phone and moved a row of edge pixels six shades).
    (double, double) line(int from, int to) {
      final (i, j) = to - from >= 4
          ? (from + (to - from) ~/ 4, to - (to - from) ~/ 4)
          : (from, to);
      final b = (v[j] - v[i]) / (w[j] - w[i]);
      return (v[i] - b * w[i], b);
    }

    final from = keep[c - 1] < k - 1 ? keep[c - 1] : k - 2;
    final to = keep[c + 1] > k + 1 ? keep[c + 1] : k + 2;
    final (a1, b1) = line(from, k - 1);
    final (a2, b2) = line(k + 1, to);
    if ((b1 - b2).abs() < 1e-12) continue;
    final wx = (a2 - a1) / (b1 - b2);
    // The bend may be a sample or two before the width kept for it: the
    // values just past it still fit the straight piece before it.
    if (!(wx > w[from] && wx < w[to])) continue;
    final moved = [...corners]..[c] = (wx, a1 + b1 * wx);
    if (_fits(w, v, moved, keep[c - 1], keep[c + 1], tol)) {
      corners[c] = moved[c];
    }
    // Where the lines meet can still be a hair off a bend that falls on a
    // width looked at (How Much Comes Off's squares stop growing at exactly
    // 300 wide, and the meeting came out at 299.99998: its hatching, every
    // line on a whole pixel at a 320 phone, drew thousands of pixels a
    // shade or two out). A width looked at near the meeting, with its own
    // value, is the corner instead when every value then fits closer.
    // (Never exactly: the figure's hatching starts from the bounds of a
    // path, which the engine keeps in single precision.)
    var best = _worst(w, v, corners, keep[c - 1], keep[c + 1]);
    for (var i = from + 1; i < to; i++) {
      if ((w[i] - wx).abs() > 0.01 || best < _exact) continue;
      final at = [...corners]..[c] = (w[i], v[i]);
      final worst = _worst(w, v, at, keep[c - 1], keep[c + 1]);
      if (worst < best && worst <= tol) {
        best = worst;
        corners[c] = at[c];
      }
    }
  }
  return corners;
}

/// Near enough to a straight piece to be on it.
const _exact = 1e-9;

/// The furthest any value from index [from] to [to] sits from the joins
/// of [corners].
double _worst(
  List<double> w,
  List<double> v,
  List<(double, double)> corners,
  int from,
  int to,
) {
  var worst = 0.0;
  for (var i = from; i <= to; i++) {
    var j = 0;
    while (j + 2 < corners.length && w[i] > corners[j + 1].$1) {
      j++;
    }
    final (w0, v0) = corners[j];
    final (w1, v1) = corners[j + 1];
    final off = (v0 + (v1 - v0) * (w[i] - w0) / (w1 - w0) - v[i]).abs();
    if (off > worst) worst = off;
  }
  return worst;
}

/// Whether the joins of [corners] stay within [tol] of every value from
/// index [from] to [to].
bool _fits(
  List<double> w,
  List<double> v,
  List<(double, double)> corners,
  int from,
  int to,
  double tol,
) {
  for (var i = from; i <= to; i++) {
    var j = 0;
    while (j + 2 < corners.length && w[i] > corners[j + 1].$1) {
      j++;
    }
    final (w0, v0) = corners[j];
    final (w1, v1) = corners[j + 1];
    if ((v0 + (v1 - v0) * (w[i] - w0) / (w1 - w0) - v[i]).abs() > tol) {
      return false;
    }
  }
  return true;
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
  // Any other row of pictures side by side, the same gap between each.
  if (w is Row &&
      w.crossAxisAlignment == CrossAxisAlignment.start &&
      w.mainAxisAlignment == MainAxisAlignment.start &&
      w.mainAxisSize == MainAxisSize.max &&
      w.key == null &&
      w.children.length.isOdd) {
    final pictures = <ConceptPicture>[];
    final gaps = <double?>{};
    for (final (i, c) in w.children.indexed) {
      if (i.isEven) {
        if (c case Expanded(flex: 1, child: final ConceptPicture p)) {
          pictures.add(p);
        } else {
          throw UnsupportedError('$name: picture row holds ${c.runtimeType}');
        }
      } else if (c case SizedBox(height: null, child: null)) {
        gaps.add(c.width);
      } else {
        throw UnsupportedError('$name: picture row gap ${c.runtimeType}');
      }
    }
    if (gaps.length > 1 || pictures.map((p) => p.height).toSet().length > 1) {
      throw UnsupportedError('$name: an uneven picture row');
    }
    return {
      'kind': 'row',
      'h': pictures.first.height,
      'gap': gaps.isEmpty ? 0 : gaps.single,
      'children': [
        for (final (i, p) in pictures.indexed)
          {
            'caption': p.caption,
            'ops': record(
              p.painter.paint,
              p.height,
              // Three across a sheet are each under a third of it.
              range: (60, 500),
              what: '$name $i',
            ),
          },
      ],
    };
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
  // A sheet's own widget that only lays pictures out (Surveying stacks two
  // full width pictures with one): whatever it builds. Its build reads
  // nothing from where it sits, so it is built here on its own.
  if (w is StatelessWidget) {
    // ignore: invalid_use_of_protected_member
    return pictureJson(w.build(StatelessElement(w)), name);
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

/// Builds [games] one at a time, letting the event loop turn after each.
///
/// Every label a figure writes asks google_fonts for its style, and each ask
/// leaves a little work queued for the event loop. A build that never lets
/// the loop turn keeps all of it: Fluid Mechanics grew past four gigabytes
/// and slowed to a crawl. [pause] is how the caller lets the loop turn.
Future<Map<String, Map<String, Object?>>> buildGames(
  Map<String, Map<String, Object?> Function()> games,
  Future<void> Function() pause,
) async {
  final built = <String, Map<String, Object?>>{};
  for (final MapEntry(:key, :value) in games.entries) {
    built[key] = value();
    await pause();
  }
  return built;
}
