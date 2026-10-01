// The pictures on the Engineering Economics concept sheets.
//
// A sheet is read picture first (owner's call, 2026-09-30): the drawing the
// student just played with, with one thing happening in it, then the idea in
// short steps, then the rule. Built from the same painters the games draw
// with; see mechanics_pictures.dart for the pattern and the shared
// ConceptPicture and ConceptPair tiles. Most of this chapter is a cash flow
// diagram of one kind or another, so the few painters that exist only here
// draw the comparison a sheet needs and no game ever did.
//
// Each function is a tear-off used from a `const BriefSection`, so they are
// top-level and take nothing.

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';
import 'breakeven_figures.dart';
import 'cash_flow_figures.dart';
import 'depreciation_figures.dart';
import 'irr_figures.dart';
import 'mechanics_pictures.dart' show ConceptPair, ConceptPicture;
import 'tree_figures.dart';

// ---------------------------------------------------------------------------
// Equivalence and interest factors

Widget factorsPicture() => const ConceptPicture(
  painter: CashFlowPainter(
    flows: [
      CashFlow(0, -3),
      CashFlow(1, 1, unknown: true),
      CashFlow(2, 1, unknown: true),
      CashFlow(3, 1, unknown: true),
      CashFlow(4, 1, unknown: true),
      CashFlow(5, 1, unknown: true),
    ],
    periods: 5,
  ),
  caption:
      'what you have: one amount today. what you want: the same money as five equal pieces',
  height: 180,
);

Widget ratesPicture() => const ConceptPicture(
  painter: _RatesPainter(),
  caption:
      '12 percent a year, charged one percent a month. twelve small steps climb past the straight line',
  height: 200,
);

Widget piecesPicture() => const ConceptPicture(
  painter: _PiecesPainter(),
  caption:
      'a series that grows by the same step each year is a flat series plus a triangle on top',
  height: 190,
);

Widget periodPicture() => const ConceptPicture(
  painter: TimelinePainter(periods: 5, truth: 2, locked: true),
  caption:
      'today is mark 0. the end of year 2 and the start of year 3 are the same mark',
  height: 150,
);

// ---------------------------------------------------------------------------
// Present, future and annual worth

Widget annualCostPicture() => const ConceptPicture(
  painter: _OwningPainter(),
  caption:
      'what owning it costs each year: the purchase spread out, plus running it, minus what it sells for at the end',
  height: 190,
);

Widget studyPeriodPicture() => const ConceptPicture(
  painter: LivesPainter(
    lifeA: 6,
    lifeB: 4,
    span: 12,
    nameA: 'Pump X',
    nameB: 'Pump Y',
  ),
  // No bracket: the painter writes its label a fixed distance from the top,
  // which lands on the first row of bars at any height a sheet gives it. The
  // drawing makes the point without it, since two lives and three end on the
  // same mark.
  caption:
      'a six year pump twice over, a four year pump three times. twelve is '
      'the first year they both end on',
  height: 180,
);

Widget methodsAgreePicture() => const ConceptPicture(
  painter: _ThreeClocksPainter(),
  caption:
      'the same cash flows moved to today, to the end, or spread per year. three views of one thing',
  height: 220,
);

// ---------------------------------------------------------------------------
// Costs and break-even

Widget costTypesPicture() => const ConceptPicture(
  painter: _CostLinePainter(),
  caption:
      'a cost line. the fixed cost is where it starts; the variable cost is how steeply it climbs',
  height: 190,
);

const _owned = CostLine('Owned', 4200, 3);
const _rented = CostLine('Rented', 1200, 7.30);

Widget breakEvenPicture() => const ConceptPicture(
  painter: BreakEvenPainter(
    lines: [_owned, _rented],
    qTo: 1400,
    at: 698,
    revealed: true,
  ),
  caption:
      'two cost lines. left of the crossing the cheaper start wins; right of it the cheaper rate wins',
  height: 200,
);

Widget paybackPicture() => const ConceptPicture(
  painter: _PaybackPainter(),
  caption:
      'the investment as a bar, paid back by what is left of each year\'s saving after the new costs',
  height: 200,
);

// ---------------------------------------------------------------------------
// Benefit-cost and decision trees

Widget ratioPicture() => const ConceptPicture(
  painter: _FractionPainter(),
  caption:
      'benefits on top, with any harm taken off them. every cost underneath, building and running',
  height: 200,
);

Widget incrementalPicture() => const ConceptPicture(
  painter: _StepsPainter(),
  caption:
      'three options in order of cost. each step up asks: does the extra benefit cover the extra cost',
  height: 210,
);

Widget rollbackPicture() => const ConceptPicture(
  painter: TreePainter(
    branches: [
      TreeBranch.certain('Bypass', 12),
      TreeBranch.uncertain('Widen', [Chance(0.4, 10), Chance(0.6, 5)]),
    ],
    selected: null,
    locked: true,
    truth: 1,
  ),
  caption:
      'a square is a choice, a circle is chance. work from the endings back to the square',
  height: 200,
);

// ---------------------------------------------------------------------------
// Rate of return

Widget irrPicture() => const ConceptPicture(
  painter: BalancePainter(
    project: Project('one year', [(0, -1000), (1, 1150)]),
    rate: 0.15,
    reference: 1300,
    settled: true,
  ),
  caption:
      'a thousand out today, 1,150 back next year. at 15 percent the two sides weigh the same',
  height: 170,
);

Widget marrPicture() => const ConceptPicture(
  painter: _HurdlePainter(),
  caption:
      'three projects and the bar the money must clear. over or on the bar passes; under it fails',
  height: 190,
);

Widget timingPicture() => const ConceptPair(
  left: DealPainter(
    project: Project('sooner', [(0, -1000), (1, 1200)]),
    periods: 2,
    scale: 1200,
    color: AppColors.charcoal,
  ),
  right: DealPainter(
    project: Project('later', [(0, -1000), (2, 1200)]),
    periods: 2,
    scale: 1200,
    color: AppColors.charcoal,
  ),
  leftCaption: 'the same 1,200 back after one year: 20 percent',
  rightCaption: 'after two years: about 9.5 percent a year',
  height: 170,
);

// ---------------------------------------------------------------------------
// Depreciation, taxes and inflation

Widget macrsPicture() => const ConceptPicture(
  painter: _MacrsPainter(),
  caption:
      'five year property: six bars, big early and small late. straight line would be five equal bars',
  height: 200,
);

Widget bookValuePicture() => const ConceptPicture(
  painter: SpentBarPainter(
    cost: 500000,
    factors: [20.00, 32.00, 19.20, 11.52, 11.52, 5.76],
    through: 3,
    spans: [(1, 3), (3, 3), (4, 6)],
    selected: null,
    locked: true,
    truth: 2,
  ),
  caption:
      'the whole cost as one bar. three years bitten off so far; what is left standing is the book value',
  height: 170,
);

Widget inflationPicture() => const ConceptPicture(
  painter: _DollarsPainter(),
  caption:
      'the same purchase, year by year. actual dollars grow with inflation; constant dollars do not',
  height: 200,
);

/// Every picture on this chapter's sheets, by the contact sheet's card name.
const economicsPictures = <String, Widget Function()>{
  'factors': factorsPicture,
  'rates': ratesPicture,
  'pieces': piecesPicture,
  'period': periodPicture,
  'annual-cost': annualCostPicture,
  'study-period': studyPeriodPicture,
  'methods-agree': methodsAgreePicture,
  'cost-types': costTypesPicture,
  'break-even': breakEvenPicture,
  'payback': paybackPicture,
  'ratio': ratioPicture,
  'incremental': incrementalPicture,
  'rollback': rollbackPicture,
  'irr': irrPicture,
  'marr': marrPicture,
  'timing': timingPicture,
  'macrs': macrsPicture,
  'book-value': bookValuePicture,
  'inflation': inflationPicture,
};

// ---------------------------------------------------------------------------
// The painters that exist only for a sheet

TextPainter _text(String s, {double size = 11, Color color = AppColors.ink2}) {
  return TextPainter(
    text: TextSpan(
      text: s,
      style: AppTheme.mono(size: size, color: color),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
}

Paint _stroke(Color color, [double width = 2.5]) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

Paint _fill(Color color) => Paint()..color = color;

void _arrow(Canvas canvas, Offset from, Offset to, Paint paint) {
  canvas.drawLine(from, to, paint);
  final d = to - from;
  final len = d.distance;
  if (len < 1) return;
  final u = d / len;
  final n = Offset(-u.dy, u.dx);
  final head = Path()
    ..moveTo(to.dx, to.dy)
    ..lineTo(to.dx - u.dx * 8 + n.dx * 4.5, to.dy - u.dy * 8 + n.dy * 4.5)
    ..lineTo(to.dx - u.dx * 8 - n.dx * 4.5, to.dy - u.dy * 8 - n.dy * 4.5)
    ..close();
  canvas.drawPath(head, _fill(paint.color));
}

void _dashed(
  Canvas canvas,
  Offset a,
  Offset b,
  Paint paint, {
  double dash = 6,
  double gap = 5,
}) {
  final d = b - a;
  final len = d.distance;
  if (len < 1) return;
  final u = d / len;
  var at = 0.0;
  while (at < len) {
    final to = (at + dash).clamp(0, len).toDouble();
    canvas.drawLine(a + u * at, a + u * to, paint);
    at += dash + gap;
  }
}

/// Twelve monthly steps of one percent, climbing past the straight twelve.
class _RatesPainter extends CustomPainter {
  const _RatesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.1;
    final right = size.width * 0.6;
    final base = size.height * 0.82;
    final top = size.height * 0.16;
    // 100 at the base, 114 at the top
    double y(double v) => base - (v - 100) / 14 * (base - top);
    final axis = _stroke(AppColors.ink2, 1.5);
    canvas.drawLine(Offset(left, base), Offset(right, base), axis);
    canvas.drawLine(Offset(left, base), Offset(left, top - 6), axis);
    // the nominal twelve, as a straight dashed line to 112
    _dashed(
      canvas,
      Offset(left, y(100)),
      Offset(right, y(112)),
      _stroke(AppColors.ink2, 1.5),
    );
    // the monthly steps
    var v = 100.0;
    final step = (right - left) / 12;
    final path = Path()..moveTo(left, y(v));
    for (var k = 1; k <= 12; k++) {
      final next = v * 1.01;
      path.lineTo(left + step * (k - 1), y(next));
      path.lineTo(left + step * k, y(next));
      v = next;
    }
    canvas.drawPath(path, _stroke(AppColors.ember, 3));
    final eff = _text('112.68 effective', color: AppColors.ember);
    inkLabel(canvas, eff, Offset(right + 6, y(112.68) - eff.height / 2));
    final nom = _text('112 nominal');
    inkLabel(canvas, nom, Offset(right + 6, y(112) + 4));
    final start = _text('100 today', color: AppColors.charcoal);
    inkLabel(canvas, start, Offset(left, base + 6));
    // Kept short so it cannot reach the two labels stacked at the right end.
    final one = _text('one percent a month', color: AppColors.ember);
    inkLabel(canvas, one, Offset(left + 8, top - 2));
  }

  @override
  bool shouldRepaint(_RatesPainter old) => false;
}

/// A growing series drawn as a flat run of bars with a triangle stacked on.
class _PiecesPainter extends CustomPainter {
  const _PiecesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.12;
    final right = size.width * 0.88;
    final base = size.height * 0.8;
    final unit = (base - size.height * 0.14) / 6;
    final slot = (right - left) / 5;
    final axis = _stroke(AppColors.ink2, 1.5);
    canvas.drawLine(Offset(left - 6, base), Offset(right + 6, base), axis);
    for (var k = 0; k < 5; k++) {
      final x = left + slot * k + slot * 0.2;
      final w = slot * 0.6;
      final flat = Rect.fromLTWH(x, base - unit * 2, w, unit * 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(flat, const Radius.circular(3)),
        _fill(AppColors.charcoal),
      );
      if (k > 0) {
        final grow = Rect.fromLTWH(x, base - unit * (2 + k), w, unit * k);
        canvas.drawRRect(
          RRect.fromRectAndRadius(grow, const Radius.circular(3)),
          _fill(AppColors.ember),
        );
      }
      final n = _text('${k + 1}');
      inkLabel(canvas, n, Offset(x + w / 2 - n.width / 2, base + 5));
    }
    final a = _text('the flat part, A', color: AppColors.charcoal);
    inkLabel(canvas, a, Offset(left, size.height * 0.04));
    final g = _text('the growing part, G', color: AppColors.ember);
    inkLabel(canvas, g, Offset(left + a.width + 16, size.height * 0.04));
  }

  @override
  bool shouldRepaint(_PiecesPainter old) => false;
}

/// One year of owning something, as a bar in three pieces.
class _OwningPainter extends CustomPainter {
  const _OwningPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.08;
    final right = size.width * 0.92;
    final mid = size.height * 0.42;
    final h = 30.0;
    final total = right - left;
    // purchase spread 50, running 35, salvage credit 15 (drawn back)
    final buy = Rect.fromLTWH(left, mid - h / 2, total * 0.5, h);
    final run = Rect.fromLTWH(left + total * 0.5, mid - h / 2, total * 0.35, h);
    final back = Rect.fromLTWH(
      left + total * 0.7,
      mid + h / 2 + 28,
      total * 0.15,
      h * 0.7,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(buy, const Radius.circular(4)),
      _fill(AppColors.charcoal),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(run, const Radius.circular(4)),
      _fill(AppColors.ink2),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(back, const Radius.circular(4)),
      _fill(AppColors.spring),
    );
    _arrow(
      canvas,
      Offset(back.right, back.center.dy),
      Offset(back.left - 14, back.center.dy),
      _stroke(AppColors.forest, 2.5),
    );
    final b = _text(
      'the purchase, spread over its life',
      color: AppColors.charcoal,
    );
    inkLabel(canvas, b, Offset(left, mid - h / 2 - b.height - 6));
    final r = _text('running it', color: AppColors.ink2);
    inkLabel(canvas, r, Offset(run.left, mid + h / 2 + 6));
    final s = _text('minus what it sells for', color: AppColors.forest);
    inkLabel(canvas, s, Offset(right - s.width, back.bottom + 6));
    final eq = _text(
      '= what it costs you each year',
      size: 12,
      color: AppColors.charcoal,
    );
    inkLabel(canvas, eq, Offset(left, size.height - eq.height - 10));
  }

  @override
  bool shouldRepaint(_OwningPainter old) => false;
}

/// The same cash flows shown three ways: piled at today, piled at the end,
/// spread evenly.
class _ThreeClocksPainter extends CustomPainter {
  const _ThreeClocksPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.08;
    final right = size.width * 0.92;
    final rows = [
      ('PW: all of it today', 0),
      ('FW: all of it at the end', 1),
      ('AW: the same, per year', 2),
    ];
    final rowH = size.height / 3;
    for (final (i, (label, kind)) in rows.indexed) {
      final base = rowH * i + rowH * 0.82;
      final axis = _stroke(AppColors.ink2, 1.5);
      canvas.drawLine(Offset(left, base), Offset(right, base), axis);
      for (var k = 0; k <= 5; k++) {
        final x = left + (right - left) * k / 5;
        canvas.drawLine(Offset(x, base - 3), Offset(x, base + 3), axis);
      }
      final tall = rowH * 0.42;
      final paint = _stroke(AppColors.ember, 3);
      if (kind == 0) {
        _arrow(canvas, Offset(left, base), Offset(left, base - tall), paint);
      } else if (kind == 1) {
        _arrow(canvas, Offset(right, base), Offset(right, base - tall), paint);
      } else {
        for (var k = 1; k <= 5; k++) {
          final x = left + (right - left) * k / 5;
          _arrow(canvas, Offset(x, base), Offset(x, base - tall * 0.4), paint);
        }
      }
      final t = _text(label, color: AppColors.charcoal);
      inkLabel(canvas, t, Offset(left, rowH * i + 4));
    }
  }

  @override
  bool shouldRepaint(_ThreeClocksPainter old) => false;
}

/// One total-cost line with its start and its slope named.
class _CostLinePainter extends CustomPainter {
  const _CostLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.12;
    final right = size.width * 0.9;
    final base = size.height * 0.82;
    final top = size.height * 0.14;
    final axis = _stroke(AppColors.ink2, 1.5);
    canvas.drawLine(Offset(left, base), Offset(right, base), axis);
    canvas.drawLine(Offset(left, base), Offset(left, top), axis);
    final start = Offset(left, base - (base - top) * 0.3);
    final end = Offset(right, top + 6);
    canvas.drawLine(start, end, _stroke(AppColors.charcoal, 3));
    // the fixed part, a bracket at the axis
    _arrow(
      canvas,
      Offset(left + 14, base),
      Offset(left + 14, start.dy + 2),
      _stroke(AppColors.ember, 2),
    );
    final f = _text('fixed: where it starts', color: AppColors.ember);
    inkLabel(
      canvas,
      f,
      Offset(left + 22, (base + start.dy) / 2 - f.height / 2),
    );
    // the variable part, a rise over a run
    final x1 = left + (right - left) * 0.55;
    final x2 = left + (right - left) * 0.8;
    double yAt(double x) =>
        start.dy + (end.dy - start.dy) * (x - left) / (right - left);
    _dashed(
      canvas,
      Offset(x1, yAt(x1)),
      Offset(x2, yAt(x1)),
      _stroke(AppColors.info, 1.5),
    );
    _dashed(
      canvas,
      Offset(x2, yAt(x1)),
      Offset(x2, yAt(x2)),
      _stroke(AppColors.info, 1.5),
    );
    final v = _text('variable: how steep', color: AppColors.info);
    inkLabel(canvas, v, Offset(x1 - 20, yAt(x1) + 6));
    final q = _text('how many you make');
    inkLabel(canvas, q, Offset(right - q.width, base + 6));
    final c = _text('total cost');
    inkLabel(canvas, c, Offset(left + 6, top - c.height - 2));
  }

  @override
  bool shouldRepaint(_CostLinePainter old) => false;
}

/// An investment bar being filled by seven years of net saving.
class _PaybackPainter extends CustomPainter {
  const _PaybackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.08;
    final right = size.width * 0.92;
    final w = right - left;
    final top = size.height * 0.3;
    const h = 34.0;
    final bar = Rect.fromLTWH(left, top, w, h);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bar, const Radius.circular(5)),
      _stroke(AppColors.charcoal, 2),
    );
    final t = _text('the investment: 1,400,000', color: AppColors.charcoal);
    inkLabel(canvas, t, Offset(left, top - t.height - 6));
    // seven blocks of 200,000 net saving fill it exactly
    for (var k = 0; k < 7; k++) {
      final block = Rect.fromLTWH(
        left + w * k / 7 + 2,
        top + 3,
        w / 7 - 4,
        h - 6,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(block, const Radius.circular(3)),
        _fill(AppColors.spring),
      );
      final n = _text('yr ${k + 1}', size: 10, color: AppColors.charcoal);
      inkLabel(
        canvas,
        n,
        Offset(block.center.dx - n.width / 2, block.center.dy - n.height / 2),
      );
    }
    // one year's saving, gross and net, under it
    final y2 = top + h + 34;
    final gross = Rect.fromLTWH(left, y2, w * 0.4, 18);
    final cost = Rect.fromLTWH(
      left + w * 0.4 * (200 / 280),
      y2,
      w * 0.4 * (80 / 280),
      18,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(gross, const Radius.circular(3)),
      _fill(AppColors.spring),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cost, const Radius.circular(3)),
      _fill(AppColors.ember),
    );
    final g = _text('one year: 280,000 saved', color: AppColors.forest);
    inkLabel(canvas, g, Offset(left, y2 + 22));
    final c = _text(
      'minus 80,000 new costs = 200,000 net',
      color: AppColors.ember,
    );
    inkLabel(canvas, c, Offset(left, y2 + 22 + g.height + 2));
  }

  @override
  bool shouldRepaint(_PaybackPainter old) => false;
}

/// A fraction drawn as bars: benefits less harm on top, every cost below.
class _FractionPainter extends CustomPainter {
  const _FractionPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.3;
    final right = size.width * 0.92;
    final w = right - left;
    final lineY = size.height * 0.5;
    canvas.drawLine(
      Offset(left - 10, lineY),
      Offset(right + 10, lineY),
      _stroke(AppColors.charcoal, 3),
    );
    const h = 26.0;
    // benefits: a long spring bar with a red bite for disbenefits
    final ben = Rect.fromLTWH(left, lineY - 16 - h, w * 0.9, h);
    canvas.drawRRect(
      RRect.fromRectAndRadius(ben, const Radius.circular(4)),
      _fill(AppColors.spring),
    );
    final dis = Rect.fromLTWH(left + w * 0.72, lineY - 16 - h, w * 0.18, h);
    canvas.drawRRect(
      RRect.fromRectAndRadius(dis, const Radius.circular(4)),
      _fill(AppColors.ember),
    );
    // costs: build and run, charcoal and ink2
    final build = Rect.fromLTWH(left, lineY + 16, w * 0.45, h);
    final run = Rect.fromLTWH(left + w * 0.45, lineY + 16, w * 0.3, h);
    canvas.drawRRect(
      RRect.fromRectAndRadius(build, const Radius.circular(4)),
      _fill(AppColors.charcoal),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(run, const Radius.circular(4)),
      _fill(AppColors.ink2),
    );
    final b = _text('benefits', color: AppColors.forest);
    inkLabel(canvas, b, Offset(left, ben.top - b.height - 4));
    final d = _text('minus harm', color: AppColors.ember);
    inkLabel(canvas, d, Offset(dis.right - d.width, ben.top - d.height - 4));
    final c = _text('building it', color: AppColors.charcoal);
    inkLabel(canvas, c, Offset(left, run.bottom + 4));
    final r = _text('running it, every year', color: AppColors.ink2);
    inkLabel(canvas, r, Offset(run.left, run.bottom + 4));
    final top = _text('B', size: 16, color: AppColors.charcoal);
    inkLabel(canvas, top, Offset(left - 34, ben.center.dy - top.height / 2));
    final bot = _text('C', size: 16, color: AppColors.charcoal);
    inkLabel(canvas, bot, Offset(left - 34, build.center.dy - bot.height / 2));
  }

  @override
  bool shouldRepaint(_FractionPainter old) => false;
}

/// Three options ordered by cost, with each step's extra cost and extra
/// benefit marked.
class _StepsPainter extends CustomPainter {
  const _StepsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.1;
    final right = size.width * 0.92;
    final base = size.height * 0.78;
    final tall = size.height * 0.56;
    final slot = (right - left) / 3;
    // (cost, benefit) as a share of the tallest bar
    const options = [('A', 0.35, 0.5), ('B', 0.6, 0.85), ('C', 0.95, 0.95)];
    final axis = _stroke(AppColors.ink2, 1.5);
    canvas.drawLine(Offset(left - 6, base), Offset(right + 6, base), axis);
    for (final (i, (name, cost, ben)) in options.indexed) {
      final x = left + slot * i + slot * 0.15;
      final w = slot * 0.3;
      final c = Rect.fromLTWH(x, base - tall * cost, w, tall * cost);
      final b = Rect.fromLTWH(x + w + 4, base - tall * ben, w, tall * ben);
      canvas.drawRRect(
        RRect.fromRectAndRadius(c, const Radius.circular(3)),
        _fill(AppColors.charcoal),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(b, const Radius.circular(3)),
        _fill(AppColors.spring),
      );
      final n = _text(name, size: 12, color: AppColors.charcoal);
      inkLabel(canvas, n, Offset(x + w + 2 - n.width / 2, base + 5));
      if (i > 0) {
        final prev = options[i - 1];
        final ok = (ben - prev.$3) >= (cost - prev.$2);
        final t = _text(
          ok ? 'step up: yes' : 'step up: no',
          size: 10,
          color: ok ? AppColors.forest : AppColors.error,
        );
        inkLabel(canvas, t, Offset(x - slot * 0.2, base - tall - 6));
      }
    }
    final k1 = _text('cost', color: AppColors.charcoal);
    inkLabel(canvas, k1, Offset(left, size.height * 0.03));
    final k2 = _text('benefit', color: AppColors.forest);
    inkLabel(canvas, k2, Offset(left + k1.width + 14, size.height * 0.03));
  }

  @override
  bool shouldRepaint(_StepsPainter old) => false;
}

/// Three projects' returns as bars against the hurdle line.
class _HurdlePainter extends CustomPainter {
  const _HurdlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.22;
    final right = size.width * 0.92;
    final w = right - left;
    // rates as a share of 20 percent
    const rows = [('first', 0.14), ('second', 0.10), ('third', 0.07)];
    const marr = 0.10;
    final rowH = size.height / 3.6;
    final hurdleX = left + w * (marr / 0.2);
    for (final (i, (name, rate)) in rows.indexed) {
      final y = rowH * i + rowH * 0.4;
      final passes = rate >= marr;
      final bar = Rect.fromLTWH(left, y, w * (rate / 0.2), rowH * 0.5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(bar, const Radius.circular(4)),
        _fill(passes ? AppColors.spring : AppColors.ember),
      );
      final n = _text(name, color: AppColors.charcoal);
      inkLabel(
        canvas,
        n,
        Offset(left - n.width - 8, bar.center.dy - n.height / 2),
      );
      final p = _text(
        '${(rate * 100).round()}%',
        size: 10,
        color: AppColors.charcoal,
      );
      inkLabel(canvas, p, Offset(bar.right + 6, bar.center.dy - p.height / 2));
    }
    _dashed(
      canvas,
      Offset(hurdleX, rowH * 0.2),
      Offset(hurdleX, size.height * 0.82),
      _stroke(AppColors.charcoal, 2),
    );
    final m = _text('the hurdle: 10%', color: AppColors.charcoal);
    inkLabel(canvas, m, Offset(hurdleX - m.width / 2, size.height * 0.84));
  }

  @override
  bool shouldRepaint(_HurdlePainter old) => false;
}

/// The five year MACRS bars beside the straight line's equal bars.
class _MacrsPainter extends CustomPainter {
  const _MacrsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.08;
    final right = size.width * 0.94;
    final base = size.height * 0.78;
    final tall = size.height * 0.52;
    final factors = macrsFactors[5]!;
    final slot = (right - left) / 6;
    final axis = _stroke(AppColors.ink2, 1.5);
    canvas.drawLine(Offset(left - 4, base), Offset(right + 4, base), axis);
    for (var k = 0; k < 6; k++) {
      final x = left + slot * k + slot * 0.12;
      final w = slot * 0.5;
      final h = tall * factors[k] / 32;
      final bar = Rect.fromLTWH(x, base - h, w, h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(bar, const Radius.circular(3)),
        _fill(AppColors.charcoal),
      );
      final p = _text(
        factors[k].toStringAsFixed(factors[k] % 1 == 0 ? 0 : 2),
        size: 9,
        color: AppColors.charcoal,
      );
      inkLabel(
        canvas,
        p,
        Offset(x + w / 2 - p.width / 2, base - h - p.height - 2),
      );
      final n = _text('${k + 1}', size: 10);
      inkLabel(canvas, n, Offset(x + w / 2 - n.width / 2, base + 5));
      if (k < 5) {
        // straight line would be 20 percent, five times
        final sl = Rect.fromLTWH(
          x + w + 3,
          base - tall * 20 / 32,
          slot * 0.22,
          tall * 20 / 32,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(sl, const Radius.circular(3)),
          _stroke(AppColors.ember, 1.5),
        );
      }
    }
    final a = _text('MACRS, from the table', color: AppColors.charcoal);
    inkLabel(canvas, a, Offset(left, size.height * 0.03));
    final b = _text('straight line, 20 each', color: AppColors.ember);
    inkLabel(canvas, b, Offset(left + a.width + 14, size.height * 0.03));
    final yr = _text('year');
    inkLabel(canvas, yr, Offset(right - yr.width, base + 5));
  }

  @override
  bool shouldRepaint(_MacrsPainter old) => false;
}

/// The same purchase priced year by year in actual and in constant dollars.
class _DollarsPainter extends CustomPainter {
  const _DollarsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.3;
    final right = size.width * 0.92;
    final slot = (right - left) / 5;
    final rowH = size.height / 2;
    void row(int i, String label, Color color, bool grows, String rate) {
      final base = rowH * i + rowH * 0.74;
      final axis = _stroke(AppColors.ink2, 1.5);
      canvas.drawLine(Offset(left, base), Offset(right, base), axis);
      for (var k = 0; k < 5; k++) {
        final h = (grows ? 18 + 6.0 * k : 18.0);
        final x = left + slot * k + slot * 0.25;
        final bar = Rect.fromLTWH(x, base - h, slot * 0.5, h);
        canvas.drawRRect(
          RRect.fromRectAndRadius(bar, const Radius.circular(3)),
          _fill(color),
        );
      }
      final t = _text(label, color: color);
      inkLabel(canvas, t, Offset(8, base - rowH * 0.5));
      final r = _text(rate, size: 10, color: color);
      inkLabel(canvas, r, Offset(8, base - rowH * 0.5 + t.height + 2));
    }

    row(0, 'actual dollars', AppColors.ember, true, 'discount at d');
    row(1, 'constant dollars', AppColors.charcoal, false, 'discount at i');
    final yr = _text('year 1 to 5');
    inkLabel(canvas, yr, Offset(right - yr.width, size.height - yr.height - 4));
  }

  @override
  bool shouldRepaint(_DollarsPainter old) => false;
}
