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

Object record(
  Draw draw,
  double height, {
  (double, double) range = gameRange,
  required String what,
}) {
  final cache = <double, List<Object?>>{};
  List<Object?> at(double w) => cache.putIfAbsent(
    w,
    () =>
        _mergeThemes(
              _once(draw, Size(w, height), dark: false),
              _once(draw, Size(w, height), dark: true),
              '$what at width $w',
            )
            as List<Object?>,
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
      _mergeWidths([for (final w in band) at(w)], band, () => bent = true),
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
  double wb,
) {
  if (a is num) {
    final predicted = a + ((b! as num) - a) * (wm - wa) / (wb - wa);
    return (predicted - (m! as num)).abs() <= _tol;
  }
  if (a is List) {
    for (var i = 0; i < a.length; i++) {
      if (!_straight(a[i], (m! as List)[i], (b! as List)[i], wa, wm, wb)) {
        return false;
      }
    }
  }
  if (a is Map) {
    for (final k in a.keys) {
      if (k == '#') continue;
      if (!_straight(a[k], (m! as Map)[k], (b! as Map)[k], wa, wm, wb)) {
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
  void Function() bent,
) {
  final first = trees.first;
  if (first is Map) {
    return {
      for (final k in first.keys)
        k: k == '#'
            ? first[k]
            : _mergeWidths(
                [for (final t in trees) (t! as Map)[k]],
                widths,
                bent,
              ),
    };
  }
  if (first is List) {
    return [
      for (var i = 0; i < first.length; i++)
        _mergeWidths([for (final t in trees) (t! as List)[i]], widths, bent),
    ];
  }
  if (first is num) {
    final v = [for (final t in trees) (t! as num).toDouble()];
    if (v.every((x) => (x - v.first).abs() < 1e-9)) return first;
    final keep = _corners(widths, v);
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

/// The fewest (width, value) points whose straight joins stay within
/// [_tol] of every recorded value.
List<(double, double)> _corners(List<double> w, List<double> v) {
  final keep = <int>[0];
  var start = 0;
  for (var end = 2; end < w.length; end++) {
    for (var i = start + 1; i < end; i++) {
      final predicted =
          v[start] +
          (v[end] - v[start]) * (w[i] - w[start]) / (w[end] - w[start]);
      if ((predicted - v[i]).abs() > _tol) {
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
  Object? picture;
  if (b.picture != null) {
    final w = b.picture!();
    if (w is ConceptPicture) {
      picture = {
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
    } else if (w is ConceptPair) {
      picture = {
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
    } else {
      throw UnsupportedError('$name: picture layout ${w.runtimeType}');
    }
  }
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

/// A rectangle as a region, in the same width-following numbers.
Object regionOf(Rect Function(Size size) rect, double height, String what) =>
    record(
      (canvas, size) => canvas.drawRect(rect(size), ui.Paint()),
      height,
      what: what,
    );
