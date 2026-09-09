import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile/core/theme/app_theme.dart';

/// Three node treatments, drawn from a designer's spec and nothing else.
///
/// The brief was written so the designer never saw what we already ship, so
/// none of this is a variation on our current node. Each direction is built
/// here exactly as specified, on the real page colour, at a real node size,
/// with a real stretch of road through it, because two of the three only make
/// sense in the context of the path.
///
/// Nothing in `lib` is touched. This is a place to look at pictures.

enum Look { notBuilt, untouched, underway, finished }

@immutable
class Stop {
  const Stop(this.look, [this.fraction = 0]);
  final Look look;
  final double fraction;
}

/// The five stops every direction is drawn with: two behind you, the one you
/// are on, one ahead, and one that does not exist yet.
const inOrder = [
  Stop(Look.finished, 1),
  Stop(Look.finished, 1),
  Stop(Look.underway, 0.4),
  Stop(Look.untouched),
  Stop(Look.notBuilt),
];

/// The same five stops finished in the order a real student picks them. This
/// app never locks anything, and the owner insisted on that, so a chapter
/// worked out of order is the normal case rather than the edge case.
const outOfOrder = [
  Stop(Look.finished, 1),
  Stop(Look.untouched),
  Stop(Look.finished, 1),
  Stop(Look.underway, 0.4),
  Stop(Look.notBuilt),
];

const _page = Color(0xFFFFF9F0);

Future<void> _fonts() async {
  final flutter =
      Platform.environment['FLUTTER_ROOT'] ?? '/opt/homebrew/share/flutter';
  final icons = File(
    '$flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (icons.existsSync()) {
    await (FontLoader('MaterialIcons')
          ..addFont(Future.value(icons.readAsBytesSync().buffer.asByteData())))
        .load();
  }
  final dir = Directory('assets/fonts');
  if (!dir.existsSync()) return;
  for (final family in const {
    'DM Sans': 'DMSans',
    'Inter': 'Inter',
    'JetBrains Mono': 'JetBrainsMono',
  }.entries) {
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains(family.value));
    if (files.isEmpty) continue;
    final loader = FontLoader(family.key);
    for (final f in files) {
      loader.addFont(Future.value(f.readAsBytesSync().buffer.asByteData()));
    }
    await loader.load();
  }
}

void _glyph(Canvas canvas, IconData icon, Offset at, double size, Color color) {
  final tp = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        fontSize: size,
        color: color,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
}

void _shadow(Canvas canvas, Path shape, Color color, double blur, double dy) {
  canvas.drawPath(
    shape.shift(Offset(0, dy)),
    Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
  );
}

void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint, double on,
    double off) {
  final total = (b - a).distance;
  if (total < 0.5) return;
  final unit = (b - a) / total;
  for (var t = 0.0; t < total; t += on + off) {
    canvas.drawLine(
      a + unit * t,
      a + unit * math.min(t + on, total),
      paint,
    );
  }
}

/// ── Direction 1 ─────────────────────────────────────────────────────────────
/// INK LEVEL. The node is a vessel and progress is how much ink is in it, so a
/// chapter reads as one sequence from empty to full.
class InkLevel extends _Direction {
  const InkLevel({this.thick = false});

  final bool thick;

  @override
  Color? bodyColor(Stop stop) => !thick || stop.look == Look.notBuilt
      ? null
      : stop.look == Look.finished
      ? const Color(0xFF1F5C46)
      : const Color(0xFFD8CFC0);

  @override
  double get roadWidth => 0.09;

  @override
  Color roadColor(Stop from, Stop to) => const Color(0xFFE7DCCB);

  @override
  bool roadDashed(Stop from, Stop to) =>
      from.look == Look.notBuilt || to.look == Look.notBuilt;

  @override
  void node(Canvas canvas, Offset c, double d, Stop stop) {
    final circle = Path()..addOval(Rect.fromCircle(center: c, radius: d / 2));
    switch (stop.look) {
      case Look.notBuilt:
        canvas.drawPath(circle, Paint()..color = const Color(0xFFFAF3E7));
        _dashedCircle(canvas, c, d / 2, const Color(0xFFC9BFAE), 0.022 * d,
            0.036 * d);
        _glyph(canvas, Icons.more_horiz, c, 0.26 * d, const Color(0xFFA79B87));
      case Look.untouched:
        _shadow(canvas, circle, const Color(0x1A2C2C2C), 7, 6);
        canvas.drawPath(circle, Paint()..color = Colors.white);
        _rim(canvas, c, d, const Color(0xFF2D7A5F), 0.023 * d);
      case Look.underway:
        _shadow(canvas, circle, const Color(0x1A2C2C2C), 7, 6);
        canvas.drawPath(circle, Paint()..color = Colors.white);
        // Ink up to a chord, clamped so a tenth never vanishes and nine
        // tenths never impersonates a finished node.
        final h = (stop.fraction * d).clamp(0.18 * d, 0.88 * d);
        final top = c.dy + d / 2 - h;
        canvas.save();
        canvas.clipPath(circle);
        canvas.drawRect(
          Rect.fromLTRB(c.dx - d, top, c.dx + d, c.dy + d),
          Paint()..color = const Color(0xFF2D7A5F),
        );
        // The meniscus, so the surface reads as a surface.
        final half = math.sqrt(math.max(0, (d / 2) * (d / 2) -
            math.pow(top - c.dy, 2)));
        canvas.drawLine(
          Offset(c.dx - half, top),
          Offset(c.dx + half, top),
          Paint()
            ..color = const Color(0xFF4A9B7D)
            ..strokeWidth = 0.014 * d,
        );
        canvas.restore();
        _rim(canvas, c, d, const Color(0xFF2D7A5F), 0.023 * d);
      case Look.finished:
        _shadow(canvas, circle, const Color(0x2E1F5C46), 9, 6);
        canvas.drawPath(circle, Paint()..color = const Color(0xFF2D7A5F));
        _rim(canvas, c, d, const Color(0xFF1F5C46), 0.023 * d);
        _glyph(canvas, Icons.check_rounded, c, 0.46 * d, _page);
    }
  }
}

/// ── Direction 2 ─────────────────────────────────────────────────────────────
/// MILESTONE AND TRAIL. The road is the progress bar and carries completion;
/// the node is a near-constant white marker whose only jobs are "openable" and
/// "you are here".
class Milestone extends _Direction {
  const Milestone();

  @override
  double get roadWidth => 0.13;

  @override
  Color roadColor(Stop from, Stop to) => from.look == Look.finished
      ? const Color(0xFF2D7A5F)
      : const Color(0xFFEDE3D4);

  @override
  bool roadDashed(Stop from, Stop to) =>
      from.look == Look.notBuilt || to.look == Look.notBuilt;

  @override
  void node(Canvas canvas, Offset c, double d, Stop stop) {
    switch (stop.look) {
      case Look.notBuilt:
        final small = 0.62 * d;
        canvas.drawCircle(c, small / 2, Paint()..color = _page);
        _rim(canvas, c, small, const Color(0xFFD8CCB8), 0.018 * d);
        _glyph(canvas, Icons.more_horiz, c, 0.24 * small,
            const Color(0xFFA79B87));
      case Look.untouched:
        final circle = Path()
          ..addOval(Rect.fromCircle(center: c, radius: d / 2));
        _shadow(canvas, circle, const Color(0x142C2C2C), 5, 4);
        canvas.drawPath(circle, Paint()..color = Colors.white);
        _rim(canvas, c, d, const Color(0xFFE7DCC9), 0.014 * d);
      case Look.underway:
        final big = d * 1.06;
        final circle = Path()
          ..addOval(Rect.fromCircle(center: c, radius: big / 2));
        _shadow(canvas, circle, const Color(0x38E8683A), 8, 5);
        canvas.drawPath(circle, Paint()..color = Colors.white);
        _rim(canvas, c, big, const Color(0xFFE7DCC9), 0.014 * d);
        // The ring lives OUTSIDE the node, so the marker itself stays white.
        final r = big / 2 + 0.055 * d;
        final rect = Rect.fromCircle(center: c, radius: r);
        final track = Paint()
          ..color = const Color(0xFFEDE3D4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.045 * d;
        canvas.drawArc(rect, 0, 2 * math.pi, false, track);
        final sweep = (stop.fraction * 2 * math.pi)
            .clamp(28 * math.pi / 180, 348 * math.pi / 180);
        canvas.drawArc(
          rect,
          -math.pi / 2,
          sweep,
          false,
          Paint()
            ..color = const Color(0xFFE8683A)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.045 * d
            ..strokeCap = StrokeCap.round,
        );
      case Look.finished:
        final circle = Path()
          ..addOval(Rect.fromCircle(center: c, radius: d / 2));
        _shadow(canvas, circle, const Color(0x142C2C2C), 5, 4);
        canvas.drawPath(circle, Paint()..color = Colors.white);
        _rim(canvas, c, d, const Color(0xFF2D7A5F), 0.027 * d);
        _glyph(canvas, Icons.check_rounded, c, 0.40 * d,
            const Color(0xFF2D7A5F));
    }
  }
}

/// ── Direction 3 ─────────────────────────────────────────────────────────────
/// SILHOUETTE CODE. Four states, four shapes, so the screen is legible with
/// the colour taken out and one saturated colour means one thing.
class Silhouette extends _Direction {
  const Silhouette({this.thick = false, this.raiseNotBuilt = false});

  final bool thick;

  /// Whether the state with no content behind it also gets a slab. Drawn both
  /// ways rather than argued about.
  final bool raiseNotBuilt;

  @override
  Color? bodyColor(Stop stop) {
    if (!thick) return null;
    if (stop.look == Look.notBuilt) {
      return raiseNotBuilt ? const Color(0xFFE3D8C6) : null;
    }
    return stop.look == Look.finished
        ? const Color(0xFF161616)
        : const Color(0xFFCDBFA8);
  }

  @override
  RRect bodySlab(Stop stop, Offset c, double d) {
    if (stop.look != Look.notBuilt) return super.bodySlab(stop, c, d);
    // This state is a rounded square, so its slab is one too.
    final side = 0.72 * d;
    return RRect.fromRectAndRadius(
      Rect.fromLTWH(c.dx - side / 2, c.dy - side / 2, side, side + 0.09 * d),
      Radius.circular(0.28 * side),
    );
  }

  @override
  double get roadWidth => 0.09;

  @override
  Color roadColor(Stop from, Stop to) => const Color(0xFFE7DCCB);

  @override
  bool roadDashed(Stop from, Stop to) =>
      from.look == Look.notBuilt || to.look == Look.notBuilt;

  @override
  void node(Canvas canvas, Offset c, double d, Stop stop) {
    switch (stop.look) {
      case Look.notBuilt:
        final side = 0.72 * d;
        final r = RRect.fromRectAndRadius(
          Rect.fromCenter(center: c, width: side, height: side),
          Radius.circular(0.28 * side),
        );
        canvas.drawRRect(r, Paint()..color = const Color(0xFFF5EDE0));
        _glyph(canvas, Icons.more_horiz, c, 0.34 * side,
            const Color(0xFFA79B87));
      case Look.untouched:
        final circle = Path()
          ..addOval(Rect.fromCircle(center: c, radius: d / 2));
        _shadow(canvas, circle, const Color(0x1A2C2C2C), 5, 4);
        canvas.drawPath(circle, Paint()..color = Colors.white);
        _rim(canvas, c, d, const Color(0xFF2C2C2C), 0.027 * d);
      case Look.underway:
        final circle = Path()
          ..addOval(Rect.fromCircle(center: c, radius: d / 2));
        _shadow(canvas, circle, const Color(0x332C2C2C), 7, 5);
        canvas.drawPath(circle, Paint()..color = Colors.white);
        // A pie gauge: the white that is left IS the work that is left.
        final inset = 0.027 * d / 2 + 0.014 * d;
        final sweep = (stop.fraction * 2 * math.pi)
            .clamp(54 * math.pi / 180, 330 * math.pi / 180);
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: d / 2 - inset),
          -math.pi / 2,
          sweep,
          true,
          Paint()..color = const Color(0xFFE8683A),
        );
        _rim(canvas, c, d, const Color(0xFF2C2C2C), 0.027 * d);
      case Look.finished:
        final circle = Path()
          ..addOval(Rect.fromCircle(center: c, radius: d / 2));
        _shadow(canvas, circle, const Color(0x282C2C2C), 7, 5);
        canvas.drawPath(circle, Paint()..color = const Color(0xFF2C2C2C));
        _glyph(canvas, Icons.check_rounded, c, 0.44 * d, _page);
    }
  }
}

abstract class _Direction {
  const _Direction();

  /// The slab under the face that gives the node its thickness, or null where
  /// a state is meant to lie flat on the page. The app's node already has
  /// this, and it is what makes a node look pressable and respond to a press;
  /// none of the three directions is about it, so none of them has to lose it.
  Color? bodyColor(Stop stop) => null;

  /// The slab's outline. Defaults to a capsule under a circular face; a
  /// direction with a different silhouette has to say so, or the comparison
  /// is measuring my harness rather than the design.
  RRect bodySlab(Stop stop, Offset c, double d) => RRect.fromRectAndRadius(
    Rect.fromLTWH(c.dx - d / 2, c.dy - d / 2, d, d + 0.09 * d),
    Radius.circular(d / 2),
  );

  double get roadWidth;
  Color roadColor(Stop from, Stop to);
  bool roadDashed(Stop from, Stop to);
  void node(Canvas canvas, Offset c, double d, Stop stop);

  void _rim(Canvas canvas, Offset c, double d, Color color, double width) {
    canvas.drawCircle(
      c,
      d / 2 - width / 2,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  void _dashedCircle(
      Canvas canvas, Offset c, double r, Color color, double w, double dash) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w;
    final step = dash / r;
    for (var a = 0.0; a < 2 * math.pi; a += step * 2) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r - w / 2),
        a,
        step,
        false,
        paint,
      );
    }
  }
}

/// A short stretch of path drawn in one direction's language.
class _PathPainter extends CustomPainter {
  const _PathPainter({
    required this.look,
    required this.d,
    required this.stops,
  });

  final _Direction look;
  final double d;
  final List<Stop> stops;

  @override
  void paint(Canvas canvas, Size size) {
    final gap = d * 1.62;
    final centres = <Offset>[
      for (var i = 0; i < stops.length; i++)
        Offset(
          size.width * 0.5 + math.sin(i * math.pi / 3) * size.width * 0.22,
          d / 2 + 10 + i * gap,
        ),
    ];

    for (var i = 0; i < centres.length - 1; i++) {
      final paint = Paint()
        ..color = look.roadColor(stops[i], stops[i + 1])
        ..strokeWidth = look.roadWidth * d
        ..strokeCap = StrokeCap.round;
      if (look.roadDashed(stops[i], stops[i + 1])) {
        _dashedLine(canvas, centres[i], centres[i + 1], paint, 0.09 * d,
            0.07 * d);
      } else {
        canvas.drawLine(centres[i], centres[i + 1], paint);
      }
    }
    for (var i = 0; i < centres.length; i++) {
      final body = look.bodyColor(stops[i]);
      if (body != null) {
        // A capsule the width of the face whose sides run straight down from
        // the midline, so the node reads as a slab you can press.
        canvas.drawRRect(
          look.bodySlab(stops[i], centres[i], d),
          Paint()..color = body,
        );
      }
      look.node(canvas, centres[i], d, stops[i]);
    }
  }

  @override
  bool shouldRepaint(_PathPainter old) => false;
}


/// A closer look at one direction with every state raised, laid out the way
/// the real screen is: nodes on a winding road with a label card beside each.
class _RealisticPainter extends CustomPainter {
  const _RealisticPainter({required this.look, required this.d, required this.rows});

  final _Direction look;
  final double d;
  final List<(Stop, String, String)> rows;

  @override
  void paint(Canvas canvas, Size size) {
    final gap = d * 1.72;
    final centres = <Offset>[
      for (var i = 0; i < rows.length; i++)
        Offset(
          size.width * 0.42 + math.sin(i * math.pi / 3) * size.width * 0.22,
          d / 2 + 14 + i * gap,
        ),
    ];

    for (var i = 0; i < centres.length - 1; i++) {
      final paint = Paint()
        ..color = look.roadColor(rows[i].$1, rows[i + 1].$1)
        ..strokeWidth = look.roadWidth * d
        ..strokeCap = StrokeCap.round;
      if (look.roadDashed(rows[i].$1, rows[i + 1].$1)) {
        _dashedLine(canvas, centres[i], centres[i + 1], paint, 0.09 * d,
            0.07 * d);
      } else {
        canvas.drawLine(centres[i], centres[i + 1], paint);
      }
    }

    for (var i = 0; i < centres.length; i++) {
      _card(canvas, size, centres[i], d, rows[i].$2, rows[i].$3);
      final body = look.bodyColor(rows[i].$1);
      if (body != null) {
        canvas.drawRRect(
          look.bodySlab(rows[i].$1, centres[i], d),
          Paint()..color = body,
        );
      }
      look.node(canvas, centres[i], d, rows[i].$1);
    }
  }

  /// The white label card, so the node is judged next to what it sits beside.
  void _card(Canvas canvas, Size size, Offset c, double d, String name,
      String detail) {
    final onLeft = c.dx > size.width * 0.45;
    const w = 150.0;
    final left = onLeft ? c.dx - d / 2 - 12 - w : c.dx + d / 2 + 12;
    final title = TextPainter(
      text: TextSpan(
        text: name,
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.25,
          color: Color(0xFF2C2C2C),
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w - 20);
    final sub = TextPainter(
      text: TextSpan(
        text: detail,
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 10.5,
          color: Color(0xFF9C9488),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final h = title.height + sub.height + 22;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, c.dy - h / 2, w, h),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      rect.shift(const Offset(0, 3)),
      Paint()
        ..color = const Color(0x0F2C2C2C)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawRRect(rect, Paint()..color = Colors.white);
    title.paint(canvas, Offset(left + (w - title.width) / 2, c.dy - h / 2 + 9));
    sub.paint(
      canvas,
      Offset(left + (w - sub.width) / 2, c.dy - h / 2 + 11 + title.height),
    );
  }

  @override
  bool shouldRepaint(_RealisticPainter old) => false;
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await _fonts();
  });

  testWidgets('three directions, drawn from the brief', (tester) async {
    tester.view.physicalSize = const Size(390, 4460);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const named = <(String, String, _Direction, List<Stop>)>[
      (
        'INK LEVEL',
        'the node is a vessel; progress is how full it is',
        InkLevel(),
        inOrder,
      ),
      (
        'MILESTONE AND TRAIL',
        'the road carries completion; the node says you are here',
        Milestone(),
        inOrder,
      ),
      (
        'SILHOUETTE CODE',
        'four shapes, legible with the colour taken out',
        Silhouette(),
        inOrder,
      ),
      (
        'MILESTONE, WORKED OUT OF ORDER',
        'the same treatment when the ribbon cannot be continuous',
        Milestone(),
        outOfOrder,
      ),
      (
        'SILHOUETTE, WORKED OUT OF ORDER',
        'for comparison, a per-node treatment under the same conditions',
        Silhouette(),
        outOfOrder,
      ),
      (
        'INK LEVEL, THICKNESS KEPT',
        'the same colours over the slab the app already has',
        InkLevel(thick: true),
        inOrder,
      ),
      (
        'SILHOUETTE, THICKNESS KEPT, NOT-BUILT LEFT FLAT',
        'the state with no content behind it stays on the page',
        Silhouette(thick: true),
        inOrder,
      ),
      (
        'SILHOUETTE, THICKNESS ON EVERY STATE',
        'not-built raised too, for comparison',
        Silhouette(thick: true, raiseNotBuilt: true),
        inOrder,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: _page,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (title, idea, look, path) in named) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 2),
                    child: Text(title, style: AppTheme.heading(size: 17)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                    child: Text(
                      idea,
                      style: AppTheme.mono(
                        size: 10.5,
                        color: const Color(0xFF9C9488),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 60 * 1.62 * (path.length - 1) + 80,
                    child: CustomPaint(
                      painter: _PathPainter(look: look, d: 60, stops: path),
                      // A CustomPaint with no child is zero-sized, and every
                      // node then lands on x = 0.
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/00-map/designer-directions.png'),
    );
  });

  testWidgets('silhouette, raised on every state', (tester) async {
    tester.view.physicalSize = const Size(390, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const rows = <(Stop, String, String)>[
      (Stop(Look.finished, 1), 'Straight Lines & Quadratics', 'All 3 done'),
      (Stop(Look.finished, 1), 'Logarithms', 'All 3 done'),
      (Stop(Look.underway, 0.66), 'Right Triangle Trigonometry', '2 of 3 done'),
      (Stop(Look.underway, 0.2), 'Law of Sines & Law of Cosines', 'Started'),
      (Stop(Look.untouched), 'Unit Circle & Trig Identities', '0 of 3 done'),
      (Stop(Look.notBuilt), 'Circles & Conic Sections', 'Not built yet'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: _page,
          body: CustomPaint(
            painter: const _RealisticPainter(
              look: Silhouette(thick: true, raiseNotBuilt: true),
              d: 76,
              rows: rows,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/00-map/silhouette-raised.png'),
    );
  });
}
