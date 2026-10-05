// The pictures on the Probability & Statistics concept sheets.
//
// A sheet is read picture first (owner's call, 2026-09-30): the drawing the
// student just played with, with one thing happening in it, then the idea in
// short steps, then the rule. Built from the same painters the games draw
// with; see mechanics_pictures.dart for the pattern and the shared
// ConceptPicture and ConceptPair tiles. The few painters that exist only
// here draw a comparison no game needed to draw.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';
import 'dot_plot_figures.dart';
import 'expectation_figures.dart';
import 'interval_figures.dart';
import 'mechanics_pictures.dart' show ConceptPair, ConceptPicture;
import 'normal_figures.dart';
import 'scatter_figures.dart';
import 'test_figures.dart';

// ---------------------------------------------------------------------------
// Central tendency and dispersion

Widget centerPicture() => const ConceptPicture(
  painter: DotPlotPainter(
    values: [11, 12, 13, 13, 14, 16, 29],
    from: 10,
    to: 30,
    truth: {13},
    revealed: true,
  ),
  caption:
      'seven readings. The middle one sits at 13; the far one drags the mean out to 15',
  height: 160,
);

Widget spreadPicture() => const ConceptPicture(
  painter: _ReadoutPainter(),
  caption:
      'the calculator gives both. Sx divides by n minus one and is the one the exam wants',
  height: 170,
);

Widget weightedPicture() => const ConceptPicture(
  painter: _WeightedBarsPainter(),
  caption:
      'three batches, strength in MPa. The wide one had ten cylinders, so it pulls the average toward it',
  height: 190,
);

// ---------------------------------------------------------------------------
// Regression and correlation

const _tight = [
  Pair(1, 2),
  Pair(2, 3),
  Pair(3, 5),
  Pair(4, 6),
  Pair(5, 8),
  Pair(6, 9),
];
const _loose = [
  Pair(1, 8),
  Pair(2, 5),
  Pair(3, 7),
  Pair(4, 3),
  Pair(5, 5),
  Pair(6, 2),
];

/// Rises, then falls. Perfectly symmetric, so r is exactly zero while the
/// shape is as obvious as a shape gets.
const _arch = [
  Pair(1, 3),
  Pair(2, 6),
  Pair(3, 8),
  Pair(4, 8),
  Pair(5, 6),
  Pair(6, 3),
];

Widget correlationPicture() => const Column(
  children: [
    ConceptPair(
      left: ScatterPainter(points: _tight, xTo: 7, yTo: 10),
      right: ScatterPainter(points: _loose, xTo: 7, yTo: 10),
      leftCaption: 'tight and rising: r near plus one',
      rightCaption: 'loose and falling: r about minus a half',
      height: 170,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: ScatterPainter(points: _arch, xTo: 7, yTo: 10),
      caption:
          'and this one has r of exactly zero. There is plainly a pattern, it '
          'is just not a straight one. r near zero means no straight line, '
          'not no relationship',
      height: 175,
    ),
  ],
);

Widget regressionLinePicture() => const ConceptPicture(
  painter: ScatterPainter(
    points: _tight,
    xTo: 7,
    yTo: 10,
    lines: [
      FitLine(0, 1.257, label: 'through the origin'),
      FitLine(1.1, 1.257, label: 'through the means'),
    ],
    meanPoint: true,
    truthLine: 1,
    revealed: true,
  ),
  caption:
      'the same slope twice. Only the line through the point of the means fits',
  height: 200,
);

Widget determinationPicture() => const ConceptPicture(
  painter: _RSquaredPainter(),
  caption:
      'r is minus 0.92. Squared, 0.85 of the variation is explained and 0.15 is not',
  height: 150,
);

// ---------------------------------------------------------------------------
// Distributions

Widget countingPicture() => const ConceptPicture(
  painter: _PickPainter(),
  caption:
      'pick three letters. Six orderings, but only one group if order does not matter',
  height: 180,
);

Widget binomialPicture() => const ConceptPicture(
  painter: _ThreeFactorsPainter(),
  caption:
      'five trials, three successes. The formula is always these three factors multiplied',
  height: 190,
);

Widget normalTablePicture() => const Column(
  children: [
    ConceptPicture(
      painter: NormalPainter(
        regions: [
          CurveRegion(spans: [(zMin, 1.2)], column: 'F'),
        ],
        cuts: [1.2],
        labels: ['4,000 psi'],
        truth: 0,
        revealed: true,
      ),
      caption: 'F: everything to the LEFT of the cut, here the fail rate',
      height: 140,
    ),
    SizedBox(height: 10),
    ConceptPicture(
      painter: NormalPainter(
        regions: [
          CurveRegion(spans: [(1.2, zMax)], column: 'R'),
        ],
        cuts: [1.2],
        labels: ['4,000 psi'],
        truth: 0,
        revealed: true,
      ),
      caption:
          'R: everything to the RIGHT of it, here the pass rate. F and R '
          'together make one',
      height: 140,
    ),
    SizedBox(height: 10),
    ConceptPicture(
      painter: NormalPainter(
        regions: [
          CurveRegion(spans: [(-1.2, 1.2)], column: 'W'),
        ],
        cuts: [-1.2, 1.2],
        labels: ['minus z', 'plus z'],
        truth: 0,
        revealed: true,
      ),
      caption: 'W: the band in the middle, the same distance either side',
      height: 140,
    ),
  ],
);

Widget lawsPicture() => const ConceptPair(
  left: _OverlapPainter(overlap: false),
  right: _OverlapPainter(overlap: true),
  leftCaption: 'cannot both happen: nothing shared, just add',
  rightCaption: 'can both happen: the middle got counted twice',
  height: 185,
);

// ---------------------------------------------------------------------------
// Expected value

Widget expectedValuePicture() => const ConceptPicture(
  painter: BeamPainter(
    outcomes: [Outcome(2, 10), Outcome(6, 20), Outcome(10, 70)],
    fulcrums: [6, 8.4, 10],
    from: 0,
    to: 12,
    unit: 'trucks',
    truth: 1,
    revealed: true,
  ),
  caption:
      'outcomes as blocks, probabilities as their weight. The beam sits level at 8.4',
  height: 190,
);

Widget varianceShortcutPicture() => const ConceptPicture(
  painter: _TwoColumnsPainter(),
  caption:
      'two columns of scratch work, then one subtraction in the right order',
  height: 200,
);

Widget combiningPicture() => const ConceptPicture(
  painter: SigmaTrianglePainter(
    a: 3,
    b: 8,
    aLabel: '3 kN',
    bLabel: '8 kN',
    showHypotenuse: true,
  ),
  caption:
      'two spreads as the legs of a triangle. The total is the slanted side, not 3 plus 8',
  height: 190,
);

// ---------------------------------------------------------------------------
// Estimation

Widget marginOfErrorPicture() => const ConceptPicture(
  painter: IntervalPainter(
    center: 42,
    widest: 2.4,
    unit: 'MPa',
    bands: [
      Band(margin: 1.96, label: 'sigma over root n', tone: BandTone.truth),
      Band(margin: 0.39, label: 'sigma over n', tone: BandTone.wrong),
    ],
  ),
  caption:
      'the same 25 samples. Dropping the root shrinks the interval to a sliver it has not earned',
  height: 170,
);

Widget zOrTPicture() => const ConceptPicture(
  painter: IntervalPainter(
    center: 0,
    widest: 1.5,
    unit: 'the true mean',
    bands: [
      Band(margin: 1, label: 'z: sigma was given', tone: BandTone.before),
      Band(
        margin: 1.154,
        label: 't: s came from the sample',
        tone: BandTone.truth,
      ),
    ],
  ),
  caption:
      'ten samples at 95 percent. The t interval is wider because the spread is a guess too',
  height: 170,
);

Widget sampleSizePicture() => const ConceptPicture(
  painter: MarginCurvePainter(
    k: 1568,
    target: 200,
    candidates: [60, 61, 62],
    nFrom: 48,
    nTo: 65,
    truth: 2,
    revealed: true,
  ),
  caption:
      'margin against sample count. The curve crosses the target between 61 and 62, so 62',
  height: 190,
);

// ---------------------------------------------------------------------------
// Hypothesis testing

Widget hypothesesPicture() => const Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: ConceptPicture(
        painter: TailPainter(tail: Tail.left, color: AppColors.ember),
        caption: '"falls short": all of alpha on the left',
        height: 120,
      ),
    ),
    SizedBox(width: 8),
    Expanded(
      child: ConceptPicture(
        painter: TailPainter(tail: Tail.both, color: AppColors.ember),
        caption: '"differs": alpha split in two',
        height: 120,
      ),
    ),
    SizedBox(width: 8),
    Expanded(
      child: ConceptPicture(
        painter: TailPainter(tail: Tail.right, color: AppColors.ember),
        caption: '"exceeds": all of alpha on the right',
        height: 120,
      ),
    ),
  ],
);

Widget decisionRulePicture() => const ConceptPicture(
  painter: ScalePainter(
    statistic: 2.4,
    critical: 1.753,
    twoTailed: false,
    to: 4,
    statLabel: 't = 2.4',
    critLabel: '1.753',
  ),
  caption:
      'the statistic and the critical value on one line. Past the line means reject',
  height: 150,
);

Widget goodnessOfFitPicture() => const ConceptPicture(
  painter: CellsPainter(
    cells: [
      Cell('P1', 62, 50),
      Cell('P2', 45, 50),
      Cell('P3', 53, 50),
      Cell('P4', 40, 50),
    ],
    truth: 0,
    revealed: true,
  ),
  caption:
      'what was counted as bars, what was expected as a line. The biggest gap pays the most',
  height: 190,
);

// ---------------------------------------------------------------------------
// The painters that exist only for a sheet

TextPainter _text(
  String s, {
  double size = 11,
  Color color = AppColors.ink2,
  FontWeight weight = FontWeight.w500,
}) {
  return TextPainter(
    text: TextSpan(
      text: s,
      style: AppTheme.mono(size: size, color: color, weight: weight),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
}

Paint _stroke(Color color, [double width = 2]) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round;

/// Two events as two areas, with the shared middle made loud.
///
/// The game's own Venn is drawn in the pale background tints, which is right
/// beside an answered round and too quiet to carry a sheet. The whole idea
/// here is that the middle belongs to BOTH circles, so adding the two areas
/// counts it a second time. That only lands if the middle is the loudest
/// thing in the picture.
class _OverlapPainter extends CustomPainter {
  const _OverlapPainter({required this.overlap});

  final bool overlap;

  void _write(
    Canvas canvas,
    String s,
    Offset at, {
    double size = 10.5,
    Color color = AppColors.ink2,
    FontWeight weight = FontWeight.w500,
  }) {
    final tp = _text(s, size: size, color: color, weight: weight);
    inkLabel(canvas, tp, Offset(at.dx - tp.width / 2, at.dy - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width * 0.27, size.height * 0.26);
    final mid = Offset(size.width / 2, size.height * 0.42);
    final gap = overlap ? r * 0.58 : r * 1.22;
    final a = mid - Offset(gap, 0);
    final b = mid + Offset(gap, 0);

    canvas.drawCircle(
      a,
      r,
      Paint()..color = AppColors.ember.withValues(alpha: 0.45),
    );
    canvas.drawCircle(
      b,
      r,
      Paint()..color = AppColors.sunbeam.withValues(alpha: 0.5),
    );

    if (overlap) {
      // the lens itself, in the loudest tone on the panel
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: a, radius: r)));
      canvas.drawCircle(
        b,
        r,
        Paint()..color = AppColors.forest.withValues(alpha: 0.85),
      );
      canvas.restore();
    }

    for (final at in [a, b]) {
      canvas.drawCircle(at, r, _stroke(AppColors.charcoal, 1.8));
    }

    _write(
      canvas,
      'A',
      Offset(a.dx - r * 0.42, mid.dy),
      size: 13,
      color: AppColors.charcoal,
      weight: FontWeight.w700,
    );
    _write(
      canvas,
      'B',
      Offset(b.dx + r * 0.42, mid.dy),
      size: 13,
      color: AppColors.charcoal,
      weight: FontWeight.w700,
    );

    if (overlap) {
      _write(
        canvas,
        'both',
        mid,
        size: 10.5,
        color: AppColors.cream,
        weight: FontWeight.w700,
      );
      _write(
        canvas,
        'inside A and inside B,',
        Offset(size.width / 2, mid.dy + r + 16),
        color: AppColors.forest,
        weight: FontWeight.w700,
      );
      _write(
        canvas,
        'so take it off once',
        Offset(size.width / 2, mid.dy + r + 32),
        color: AppColors.forest,
        weight: FontWeight.w700,
      );
    } else {
      _write(
        canvas,
        'nothing is inside both,',
        Offset(size.width / 2, mid.dy + r + 16),
      );
      _write(
        canvas,
        'so nothing to take off',
        Offset(size.width / 2, mid.dy + r + 32),
      );
    }
  }

  @override
  bool shouldRepaint(_OverlapPainter old) => old.overlap != overlap;
}

/// A calculator's statistics screen: the mean, then the two spreads two
/// lines apart, with the sample one marked.
class _ReadoutPainter extends CustomPainter {
  const _ReadoutPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final screen = Rect.fromLTWH(
      size.width * 0.14,
      size.height * 0.1,
      size.width * 0.72,
      size.height * 0.8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(screen, const Radius.circular(14)),
      Paint()..color = AppColors.charcoal,
    );
    const rows = [
      ('mean', '13.40', false),
      ('Sx', '2.07', true),
      ('sigma x', '1.85', false),
      ('n', '5', false),
    ];
    final rowH = screen.height / rows.length;
    for (final (i, (label, value, mark)) in rows.indexed) {
      final y = screen.top + rowH * i + rowH / 2;
      final tone = mark ? AppColors.spring : AppColors.mutedOnDark;
      if (mark) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              screen.left + 8,
              y - rowH / 2 + 3,
              screen.width - 16,
              rowH - 6,
            ),
            const Radius.circular(8),
          ),
          Paint()..color = AppColors.tile2,
        );
      }
      final l = _text(label, size: 15, color: tone, weight: FontWeight.w600);
      inkLabel(canvas, l, Offset(screen.left + 22, y - l.height / 2));
      final v = _text(value, size: 15, color: tone, weight: FontWeight.w600);
      inkLabel(
        canvas,
        v,
        Offset(screen.right - 22 - v.width, y - v.height / 2),
      );
      if (mark) {
        // Backed off the reading's own left edge, not placed at a fixed 92
        // from the left: on a narrow screen that offset ran the note into
        // the number it is there to explain.
        final note = _text('sample: n - 1', size: 10, color: AppColors.spring);
        inkLabel(
          canvas,
          note,
          Offset(
            math.max(
              screen.left + 22 + l.width + 10,
              screen.right - 22 - v.width - note.width - 10,
            ),
            y - note.height / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ReadoutPainter old) => false;
}

/// Three bars: the height is what is being averaged, the width is how much
/// each one counts.
class _WeightedBarsPainter extends CustomPainter {
  const _WeightedBarsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // (cylinders tested, strength in MPa)
    const batches = [(2, 30.0), (4, 36.0), (10, 42.0)];
    final base = size.height * 0.74;
    final top = size.height * 0.24;
    final unit = (size.width * 0.72) / 16;
    var x = size.width * 0.14;
    final gap = unit * 0.7;
    var weighted = 0.0;
    var count = 0;
    for (final (n, mpa) in batches) {
      weighted += n * mpa;
      count += n;
      final w = unit * n;
      final h = (base - top) * (mpa / 46);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, base - h, w, h),
          const Radius.circular(5),
        ),
        Paint()..color = n == 10 ? AppColors.ember : AppColors.charcoal,
      );
      final v = _text('${mpa.round()}', size: 10, color: AppColors.cream);
      inkLabel(canvas, v, Offset(x + w / 2 - v.width / 2, base - h + 4));
      final c = _text('$n tested', size: 10, color: AppColors.ink2);
      inkLabel(canvas, c, Offset(x + w / 2 - c.width / 2, base + 5));
      x += w + gap;
    }
    final mean = weighted / count;
    final y = base - (base - top) * (mean / 46);
    canvas.drawLine(
      Offset(size.width * 0.1, y),
      Offset(size.width * 0.9, y),
      _stroke(AppColors.forest, 2)..strokeCap = StrokeCap.butt,
    );
    final m = _text(
      'weighted mean ${mean.toStringAsFixed(1)}',
      size: 10,
      color: AppColors.forest,
      weight: FontWeight.w600,
    );
    inkLabel(canvas, m, Offset(size.width * 0.1, y - m.height - 3));
  }

  @override
  bool shouldRepaint(_WeightedBarsPainter old) => false;
}

/// A bar from zero to one: the share r squared explains, and what is left.
class _RSquaredPainter extends CustomPainter {
  const _RSquaredPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const r = -0.92;
    const r2 = 0.8464;
    final left = size.width * 0.1;
    final right = size.width * 0.9;
    final y = size.height * 0.5;
    final bar = Rect.fromLTRB(left, y - 16, right, y + 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bar, const Radius.circular(8)),
      Paint()..color = AppColors.creamDark,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bar, const Radius.circular(8)),
      _stroke(AppColors.charcoal, 1.5),
    );
    final split = left + (right - left) * r2;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(left, y - 16, split, y + 16),
        topLeft: const Radius.circular(8),
        bottomLeft: const Radius.circular(8),
      ),
      Paint()..color = AppColors.forest,
    );
    final a = _text(
      'explained by x: 0.85',
      size: 11,
      color: AppColors.cream,
      weight: FontWeight.w600,
    );
    inkLabel(canvas, a, Offset(left + 12, y - a.height / 2));
    final b = _text('not: 0.15', size: 10, color: AppColors.charcoal);
    inkLabel(canvas, b, Offset(split + 6, y - b.height / 2));
    final top = _text(
      'r = $r  (it leans down)',
      size: 11,
      color: AppColors.charcoal,
    );
    inkLabel(canvas, top, Offset(left, y - 16 - top.height - 8));
    final bottom = _text(
      'r squared = ${r2.toStringAsFixed(2)}  (no sign)',
      size: 11,
      color: AppColors.forest,
      weight: FontWeight.w600,
    );
    inkLabel(canvas, bottom, Offset(left, y + 16 + 8));
  }

  @override
  bool shouldRepaint(_RSquaredPainter old) => false;
}

/// Three letters picked from a pool: the six orderings, bracketed into the
/// one group they all are.
class _PickPainter extends CustomPainter {
  const _PickPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const orders = ['ABC', 'ACB', 'BAC', 'BCA', 'CAB', 'CBA'];
    final chipW = size.width * 0.13;
    final chipH = size.height * 0.22;
    final startX = size.width * 0.06;
    final y1 = size.height * 0.16;
    final y2 = y1 + chipH + 8;
    for (final (i, o) in orders.indexed) {
      final x = startX + (i % 3) * (chipW + 8);
      final y = i < 3 ? y1 : y2;
      final rect = Rect.fromLTWH(x, y, chipW, chipH);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()..color = AppColors.charcoal,
      );
      final t = _text(
        o,
        size: 12,
        color: AppColors.cream,
        weight: FontWeight.w600,
      );
      inkLabel(canvas, t, rect.center - Offset(t.width / 2, t.height / 2));
    }
    final blockRight = startX + 3 * chipW + 16;
    final head = _text('order matters: 6', size: 11, color: AppColors.charcoal);
    inkLabel(canvas, head, Offset(startX, y2 + chipH + 8));
    // the bracket and the one group
    final bx = blockRight + 14;
    final midY = (y1 + y2 + chipH) / 2;
    final brace = Path()
      ..moveTo(bx, y1)
      ..lineTo(bx + 10, y1)
      ..lineTo(bx + 10, y2 + chipH)
      ..lineTo(bx, y2 + chipH);
    canvas.drawPath(brace, _stroke(AppColors.ink2, 1.5));
    final gx = bx + 30;
    final group = Rect.fromLTWH(
      gx,
      midY - chipH / 2,
      size.width - gx - size.width * 0.05,
      chipH,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(group, const Radius.circular(8)),
      Paint()..color = AppColors.ember,
    );
    final g = _text(
      '{A, B, C}',
      size: 12,
      color: AppColors.charcoal,
      weight: FontWeight.w600,
    );
    inkLabel(canvas, g, group.center - Offset(g.width / 2, g.height / 2));
    final tail = _text(
      'just a group: 1',
      size: 11,
      color: AppColors.ember,
      weight: FontWeight.w600,
    );
    inkLabel(canvas, tail, Offset(gx, group.bottom + 8));
  }

  @override
  bool shouldRepaint(_PickPainter old) => false;
}

/// Five trials with three successes, and the three factors of the binomial
/// written under the parts of the row they count.
class _ThreeFactorsPainter extends CustomPainter {
  const _ThreeFactorsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const hits = [true, false, true, true, false];
    final r = size.width * 0.05;
    final gap = size.width * 0.05;
    final rowW = hits.length * 2 * r + (hits.length - 1) * gap;
    var x = (size.width - rowW) / 2 + r;
    final y = size.height * 0.3;
    for (final hit in hits) {
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = hit ? AppColors.forest : AppColors.creamDark,
      );
      canvas.drawCircle(Offset(x, y), r, _stroke(AppColors.charcoal, 1.5));
      final t = _text(hit ? 'yes' : 'no', size: 9, color: AppColors.ink2);
      inkLabel(canvas, t, Offset(x - t.width / 2, y + r + 4));
      x += 2 * r + gap;
    }
    final head = _text(
      'one way 3 of 5 could land',
      size: 11,
      color: AppColors.charcoal,
    );
    inkLabel(
      canvas,
      head,
      Offset(size.width / 2 - head.width / 2, y - r - head.height - 8),
    );
    // the three factors
    const factors = [
      ('C(5, 3)', 'ways to\narrange them', AppColors.charcoal),
      ('p³', 'the three\nsuccesses', AppColors.forest),
      ('(1 - p)²', 'the two\nfailures', AppColors.ember),
    ];
    final boxW = size.width * 0.26;
    final boxY = size.height * 0.6;
    var bx = (size.width - 3 * boxW - 2 * 10) / 2;
    for (final (i, (f, why, tone)) in factors.indexed) {
      final rect = Rect.fromLTWH(bx, boxY, boxW, size.height * 0.34);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(10)),
        Paint()..color = AppColors.cream,
      );
      final t = _text(f, size: 13, color: tone, weight: FontWeight.w700);
      inkLabel(canvas, t, Offset(rect.center.dx - t.width / 2, rect.top + 6));
      final w = TextPainter(
        text: TextSpan(
          text: why,
          style: AppTheme.mono(size: 9, color: AppColors.ink2),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: boxW);
      inkLabel(
        canvas,
        w,
        Offset(rect.center.dx - w.width / 2, rect.top + 6 + t.height + 2),
      );
      if (i < 2) {
        final times = _text('×', size: 14, color: AppColors.charcoal);
        inkLabel(
          canvas,
          times,
          Offset(
            rect.right + 5 - times.width / 2,
            rect.center.dy - times.height / 2,
          ),
        );
      }
      bx += boxW + 10;
    }
  }

  @override
  bool shouldRepaint(_ThreeFactorsPainter old) => false;
}

/// The variance shortcut as the scratch work it is: two totals, then the
/// square of the first taken from the second.
class _TwoColumnsPainter extends CustomPainter {
  const _TwoColumnsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const rows = [
      ('x', 'P(x)', 'x P(x)', 'x² P(x)'),
      ('1', '0.20', '0.20', '0.20'),
      ('3', '0.50', '1.50', '4.50'),
      ('4', '0.30', '1.20', '4.80'),
      ('', 'total', '2.90', '9.50'),
    ];
    final colX = [0.12, 0.30, 0.52, 0.78].map((f) => size.width * f).toList();
    final rowH = size.height * 0.13;
    var y = size.height * 0.08;
    for (final (i, row) in rows.indexed) {
      final head = i == 0;
      final total = i == rows.length - 1;
      final cells = [row.$1, row.$2, row.$3, row.$4];
      for (final (c, s) in cells.indexed) {
        final tone = total && c >= 2
            ? (c == 2 ? AppColors.ember : AppColors.forest)
            : (head ? AppColors.ink2 : AppColors.charcoal);
        final t = _text(
          s,
          size: head ? 10 : 12,
          color: tone,
          weight: total || head ? FontWeight.w600 : FontWeight.w500,
        );
        inkLabel(canvas, t, Offset(colX[c], y));
      }
      if (total) {
        canvas.drawLine(
          Offset(colX[2] - 6, y - 4),
          Offset(size.width * 0.95, y - 4),
          _stroke(AppColors.ink2, 1)..strokeCap = StrokeCap.butt,
        );
      }
      y += rowH;
    }
    y += size.height * 0.04;
    // The line of scratch work, with the total it starts from picked out.
    // ONE label with coloured spans, not three butted together: three made
    // the kerning the sum of three separate layouts, and each adjacent pair
    // read as two labels sitting on each other.
    const pieces = <(String, Color, FontWeight)>[
      ('9.50', AppColors.forest, FontWeight.w700),
      (' - (2.90)² = 9.50 - 8.41 = ', AppColors.charcoal, FontWeight.w600),
      ('1.09', AppColors.charcoal, FontWeight.w700),
    ];
    final sum = TextPainter(
      text: TextSpan(
        children: [
          for (final (piece, ink, weight) in pieces)
            TextSpan(
              text: piece,
              style: AppTheme.mono(size: 13, color: ink, weight: weight),
            ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    inkLabel(canvas, sum, Offset(size.width * 0.12, y));
    final note = _text(
      'mean of the squares, less the square of the mean',
      size: 10,
      color: AppColors.ink2,
    );
    inkLabel(canvas, note, Offset(size.width * 0.12, y + sum.height + 4));
  }

  @override
  bool shouldRepaint(_TwoColumnsPainter old) => false;
}

/// Every picture on this chapter's sheets, by the contact sheet's card name.
const statisticsPictures = <String, Widget Function()>{
  'center': centerPicture,
  'spread': spreadPicture,
  'weighted': weightedPicture,
  'correlation': correlationPicture,
  'regression-line': regressionLinePicture,
  'determination': determinationPicture,
  'counting': countingPicture,
  'binomial': binomialPicture,
  'normal-table': normalTablePicture,
  'laws': lawsPicture,
  'expected-value': expectedValuePicture,
  'variance-shortcut': varianceShortcutPicture,
  'combining': combiningPicture,
  'margin-of-error': marginOfErrorPicture,
  'z-or-t': zOrTPicture,
  'sample-size': sampleSizePicture,
  'hypotheses': hypothesesPicture,
  'decision-rule': decisionRulePicture,
  'goodness-of-fit': goodnessOfFitPicture,
};
