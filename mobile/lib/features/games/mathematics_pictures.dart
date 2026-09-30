// The pictures on the Mathematics & Computational Tools concept sheets.
//
// A sheet is read picture first (owner's call, 2026-09-30): the drawing the
// student just played with, with one thing happening in it, then the idea in
// short steps, then the rule. Built from the same painters the games draw
// with; see mechanics_pictures.dart for the pattern and the shared
// ConceptPicture and ConceptPair tiles.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'discriminant_gate_game.dart' show Para, ParaPainter;
import 'calculus_figures.dart';
import 'grid_figures.dart';
import 'mechanics_pictures.dart' show ConceptPicture, ConceptPair;
import 'oblique_figures.dart';
import 'trig_figures.dart';
import 'unit_circle_figures.dart';

// ---------------------------------------------------------------------------
// Shared helpers

/// A picture that is a widget rather than a painter (a spreadsheet grid, a
/// row of tiles), wrapped the same way ConceptPicture wraps a painter.
class MathTile extends StatelessWidget {
  const MathTile({
    super.key,
    required this.child,
    required this.caption,
    this.height = 200,
    this.grid = true,
  });

  final Widget child;
  final String caption;
  final double height;
  final bool grid;

  @override
  Widget build(BuildContext context) {
    final inside = Container(
      height: height,
      width: double.infinity,
      color: AppColors.creamDark,
      padding: const EdgeInsets.all(10),
      child: child,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: grid
              ? EngineeringGrid(minor: 18, major: 90, child: inside)
              : inside,
        ),
        const SizedBox(height: 8),
        Text(caption, style: AppTheme.mono(size: 11.5, color: AppColors.ink2)),
      ],
    );
  }
}

TextPainter _text(
  String s, {
  double size = 12,
  Color color = AppColors.ink2,
  bool mono = true,
  FontWeight? weight,
}) {
  return TextPainter(
    text: TextSpan(
      text: s,
      style: mono
          ? AppTheme.mono(
              size: size,
              color: color,
              weight: weight ?? FontWeight.w500,
            )
          : AppTheme.body(size: size, color: color),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
}

void _at(
  Canvas c,
  String s,
  Offset o, {
  double size = 12,
  Color color = AppColors.ink2,
  bool center = false,
  bool mono = true,
  FontWeight? weight,
}) {
  final tp = _text(s, size: size, color: color, mono: mono, weight: weight);
  tp.paint(c, center ? Offset(o.dx - tp.width / 2, o.dy - tp.height / 2) : o);
}

Paint _stroke(Color color, [double width = 2.5]) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

void _arrow(Canvas canvas, Offset from, Offset to, Paint paint) {
  canvas.drawLine(from, to, paint);
  final d = to - from;
  final len = d.distance;
  if (len < 1) return;
  final u = d / len;
  final n = Offset(-u.dy, u.dx);
  canvas.drawPath(
    Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(to.dx - u.dx * 8 + n.dx * 4.5, to.dy - u.dy * 8 + n.dy * 4.5)
      ..lineTo(to.dx - u.dx * 8 - n.dx * 4.5, to.dy - u.dy * 8 - n.dy * 4.5)
      ..close(),
    Paint()..color = paint.color,
  );
}

/// A rounded box with a label in it, the building block of the symbolic
/// pictures (a box is a thing; an arrow is what happens to it).
void _box(
  Canvas canvas,
  Rect r,
  String label, {
  Color fill = AppColors.cream,
  Color ink = AppColors.charcoal,
  double size = 13,
  double radius = 10,
}) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(r, Radius.circular(radius)),
    Paint()..color = fill,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(r, Radius.circular(radius)),
    _stroke(AppColors.charcoal.withValues(alpha: 0.35), 1.5),
  );
  _at(canvas, label, r.center, size: size, color: ink, center: true);
}

void _tick(
  Canvas canvas,
  Offset at, {
  double s = 7,
  Color color = AppColors.forest,
}) {
  canvas.drawPath(
    Path()
      ..moveTo(at.dx - s, at.dy)
      ..lineTo(at.dx - s * 0.2, at.dy + s * 0.8)
      ..lineTo(at.dx + s, at.dy - s * 0.8),
    _stroke(color, 2.6),
  );
}

void _cross(
  Canvas canvas,
  Offset at, {
  double s = 6,
  Color color = AppColors.error,
}) {
  canvas.drawLine(at + Offset(-s, -s), at + Offset(s, s), _stroke(color, 2.6));
  canvas.drawLine(at + Offset(-s, s), at + Offset(s, -s), _stroke(color, 2.6));
}

// ---------------------------------------------------------------------------
// 01 straight lines

Widget perpendicularPicture() => ConceptPair(
  left: _SlopePairPainter(parallel: true),
  right: _SlopePairPainter(parallel: false),
  leftCaption: 'parallel: the same slope, so they never meet',
  rightCaption: 'perpendicular: flipped and negated, so they cross square',
  height: 170,
);

Widget discriminantPicture() => const ConceptPicture(
  painter: _ParaTriplePainter(),
  caption:
      'the same curve slid up and down. How many times it crosses is the whole question',
  height: 190,
);

Widget gradePicture() => ConceptPicture(
  painter: _GradePainter(),
  caption: 'a road climbing. Grade is how much it rises over how far it runs',
  height: 190,
);

// ---------------------------------------------------------------------------
// 02 logarithms

Widget logRulesPicture() => const ConceptPicture(
  painter: _LogMeaningPainter(),
  caption:
      'a log asks one question: how many times do you multiply the base to get there',
  height: 250,
);

Widget undoExponentPicture() => const ConceptPicture(
  painter: _UndoPainter(),
  caption:
      'the unknown is stuck up in the exponent. A log is the tool that brings it down',
  height: 175,
);

Widget combineLogsPicture() => const ConceptPicture(
  painter: _CombinePainter(),
  caption:
      'three separate logs squeezed into one before anything is worked out',
  height: 190,
);

// ---------------------------------------------------------------------------
// 03 right triangle

Widget sideNamesPicture() => const ConceptPair(
  left: TrianglePainter(angleAtTop: false, mirror: false, showNames: true),
  right: TrianglePainter(angleAtTop: true, mirror: false, showNames: true),
  leftCaption: 'angle marked at the bottom',
  rightCaption: 'same triangle, angle at the top: two names swap',
  height: 180,
);

Widget ratiosPicture() => const ConceptPicture(
  painter: TrianglePainter(
    angleAtTop: false,
    mirror: false,
    showNames: true,
    highlight: TriSide.opposite,
  ),
  caption: 'pick the ratio that joins the side you know to the side you want',
  height: 190,
);

Widget componentsPicture() => const ConceptPair(
  left: ForcePainter(degrees: 35, fromVertical: false, magnitude: 'F'),
  right: ForcePainter(degrees: 35, fromVertical: true, magnitude: 'F'),
  leftCaption: 'angle measured from across: the across piece takes cosine',
  rightCaption: 'same arrow, angle from upright: now the two swap',
  height: 185,
);

// ---------------------------------------------------------------------------
// 04 oblique triangles

Widget whichLawPicture() => const ConceptPair(
  left: ObliqueTrianglePainter(
    knownSides: {'a'},
    knownAngles: {'A', 'B'},
    wanted: 'b',
  ),
  right: ObliqueTrianglePainter(
    knownSides: {'a', 'b'},
    knownAngles: {'C'},
    wanted: 'c',
  ),
  leftCaption: 'a side with its own angle facing it: sines',
  rightCaption: 'two sides with the angle between them: cosines',
  height: 185,
);

Widget setupPicture() => const ConceptPicture(
  painter: ObliqueTrianglePainter(
    knownSides: {'a', 'b', 'c'},
    knownAngles: {'A', 'B', 'C'},
  ),
  caption:
      'every side is labelled with the small letter of the angle facing it',
  height: 195,
);

Widget obtusePicture() => const ConceptPicture(
  painter: _CosineSignPainter(),
  caption:
      'cosine runs from plus one down through zero to minus one as the angle opens',
  height: 190,
);

// ---------------------------------------------------------------------------
// 05 unit circle

Widget unitCirclePicture() => const ConceptPicture(
  painter: UnitCirclePainter(showRayTo: 30, revealed: true),
  caption: 'walk round a circle of radius one. Across is cosine, up is sine',
  height: 210,
);

Widget quadrantPicture() => const ConceptPicture(
  painter: UnitCirclePainter(quadrantLabels: true, revealed: true),
  caption:
      'the four quarters. Which way across and which way up decides every sign',
  height: 210,
);

Widget identitiesPicture() => const ConceptPicture(
  painter: _IdentityPainter(),
  caption:
      'the triangle inside the circle. Its two short sides are cosine and sine, and the long one is 1',
  height: 200,
);

// ---------------------------------------------------------------------------
// 06 circles and conics

Widget circleFormPicture() => const ConceptPicture(
  painter: GridPainter(truth: (2, -1), radius: 3, revealed: true),
  caption:
      'a circle is a center and a reach. The equation carries both, with the signs flipped',
  height: 210,
);

Widget readingConicsPicture() => const ConceptPicture(
  painter: _ConicFormsPainter(),
  caption: 'three shapes, told apart by what the two squared terms are doing',
  height: 185,
);

Widget completeSquarePicture() => const ConceptPicture(
  painter: _CompleteSquarePainter(),
  caption:
      'x squared plus a strip of x. Cut the strip in two and one corner is missing',
  height: 200,
);

// ---------------------------------------------------------------------------
// 07 derivatives

Widget whichRulePicture() => const ConceptPicture(
  painter: _ShapePainter(),
  caption:
      'read the shape before you reach for a rule. Two questions settle it',
  height: 215,
);

Widget chainRulePicture() => const ConceptPicture(
  painter: _NestPainter(),
  caption:
      'a function wrapped round another one. Peel the outside, then pay for the inside',
  height: 200,
);

Widget quotientOrderPicture() => const ConceptPicture(
  painter: _QuotientPainter(),
  caption: 'the bottom goes first. Swap the two and every sign comes out wrong',
  height: 200,
);

// ---------------------------------------------------------------------------
// 08 applications of the derivative

const _hump = Poly([0, -3, 0, 1]); // x cubed minus three x

Widget criticalPointPicture() => const ConceptPicture(
  painter: CurvePainter(
    poly: _hump,
    x0: -2.4,
    x1: 2.4,
    yLo: -3.2,
    yHi: 3.2,
    markerX: -1,
    showTangent: true,
  ),
  caption:
      'the slope is flat at the top of the hill and flat at the bottom of the valley',
  height: 215,
);

Widget concavityPicture() => const ConceptPicture(
  painter: _BendPainter(),
  caption:
      'a smile holds water, a frown spills it. The bend flips where they meet',
  height: 200,
);

Widget askedForPicture() => const ConceptPicture(
  painter: _WhereOrWhatPainter(),
  caption:
      'two different answers from one hilltop: where it is, and how high it is',
  height: 210,
);

// ---------------------------------------------------------------------------
// 09 integrals

Widget substitutionPicture() => const ConceptPicture(
  painter: _MatchPainter(),
  caption:
      'substitution needs a matched pair: an inside, and its own derivative sitting there too',
  height: 200,
);

Widget byPartsPicture() => const ConceptPicture(
  painter: _LiatePainter(),
  caption:
      'whichever is higher up the list goes in the u slot and gets differentiated',
  height: 225,
);

Widget finishingPicture() => const ConceptPair(
  left: _FamilyPainter(),
  right: _AreaPainter(),
  leftCaption: 'no limits: a whole family of curves, so it ends in plus C',
  rightCaption: 'with limits: one number, and the C cancels itself',
  height: 180,
);

// ---------------------------------------------------------------------------
// 10 limits and l'Hopital

Widget formCheckPicture() => const ConceptPicture(
  painter: _FormCheckPainter(),
  caption: 'put the number in first. Only two answers let you use the rule',
  height: 215,
);

Widget separatelyPicture() => const ConceptPicture(
  painter: _SeparatelyPainter(),
  caption:
      'top on its own, bottom on its own. Nothing multiplies and nothing is squared',
  height: 190,
);

Widget bothSidesPicture() => const ConceptPair(
  left: _BlowUpPainter(agree: true),
  right: _BlowUpPainter(agree: false),
  leftCaption: 'both sides shoot up: the limit is that infinity',
  rightCaption: 'one up, one down: there is no limit at all',
  height: 185,
);

// ---------------------------------------------------------------------------
// The painters that exist only for a sheet

/// Two lines: the same slope twice, or a slope and its flipped negative.
class _SlopePairPainter extends CustomPainter {
  _SlopePairPainter({required this.parallel});

  final bool parallel;

  @override
  void paint(Canvas canvas, Size size) {
    final base = _stroke(AppColors.charcoal, 3);
    final second = _stroke(parallel ? AppColors.info : AppColors.forest, 3);
    const m = 0.55;
    final c = Offset(size.width / 2, size.height / 2);

    void line(double slope, Offset through, Paint p) {
      final d = Offset(1, -slope) / math.sqrt(1 + slope * slope);
      final reach = size.width + size.height;
      canvas.drawLine(through - d * reach, through + d * reach, p);
    }

    canvas.clipRect(Offset.zero & size);
    if (parallel) {
      line(m, c + const Offset(0, 24), base);
      line(m, c - const Offset(0, 24), second);
    } else {
      line(m, c, base);
      line(-1 / m, c, second);
      Offset u(double s) => Offset(1, -s) / math.sqrt(1 + s * s);
      final a = u(m) * 15, b = u(-1 / m) * 15;
      canvas.drawPath(
        Path()
          ..moveTo(c.dx + a.dx, c.dy + a.dy)
          ..lineTo(c.dx + a.dx + b.dx, c.dy + a.dy + b.dy)
          ..lineTo(c.dx + b.dx, c.dy + b.dy),
        _stroke(AppColors.forest, 2),
      );
      canvas.drawCircle(c, 4, Paint()..color = AppColors.charcoal);
    }
  }

  @override
  bool shouldRepaint(_SlopePairPainter old) => old.parallel != parallel;
}

/// The same parabola at three heights: two crossings, one, none.
class _ParaTriplePainter extends CustomPainter {
  const _ParaTriplePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const cases = [
      (Para(opensUp: true, vertexY: -1.4), 'two', AppColors.forest),
      (Para(opensUp: true, vertexY: 0), 'one', AppColors.sunbeam),
      (Para(opensUp: true, vertexY: 1.2), 'none', AppColors.error),
    ];
    final w = size.width / 3;
    for (final (i, (para, label, tone)) in cases.indexed) {
      canvas.save();
      canvas.translate(i * w, 0);
      ParaPainter(
        para: para,
        color: tone,
      ).paint(canvas, Size(w, size.height - 20));
      _at(
        canvas,
        '$label crossing${label == 'one' ? '' : 's'}',
        Offset(w / 2, size.height - 12),
        center: true,
        size: 11,
        color: tone,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ParaTriplePainter old) => false;
}

/// A road climbing away from a ground line, with the two stations marked.
class _GradePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.16, right = size.width * 0.84;
    final base = size.height * 0.7, top = size.height * 0.3;

    final ground = _stroke(AppColors.charcoal.withValues(alpha: 0.35), 2);
    final road = _stroke(AppColors.ember, 4);

    canvas.drawLine(Offset(left, base), Offset(right, base), ground);
    canvas.drawLine(Offset(left, base), Offset(right, top), road);
    canvas.drawLine(Offset(right, base), Offset(right, top), ground);

    _at(canvas, 'rise', Offset(right + 6, (base + top) / 2 - 8), size: 11);
    _at(canvas, 'run', Offset((left + right) / 2 - 12, base + 6), size: 11);
    _at(canvas, '0+00', Offset(left - 14, base + 24), size: 11);
    _at(canvas, '3+00', Offset(right - 22, base + 24), size: 11);
    _at(
      canvas,
      'that is 300 feet apart, not 3',
      Offset(size.width / 2, base + 46),
      center: true,
      size: 11,
      color: AppColors.ember,
    );
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

/// What a logarithm is: how many copies of the base multiply to the number.
class _LogMeaningPainter extends CustomPainter {
  const _LogMeaningPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.34;
    const n = 3;
    final boxW = math.min(46.0, size.width / 7);
    final gap = boxW * 0.42;
    final total = n * boxW + (n - 1) * gap;
    var x = size.width / 2 - total / 2;
    for (var i = 0; i < n; i++) {
      _box(
        canvas,
        Rect.fromLTWH(x, y - boxW / 2, boxW, boxW),
        '2',
        fill: AppColors.cream,
        size: 17,
      );
      if (i < n - 1) {
        _at(canvas, 'x', Offset(x + boxW + gap / 2, y), center: true, size: 13);
      }
      x += boxW + gap;
    }
    _at(
      canvas,
      'three 2s multiplied make 8',
      Offset(size.width / 2, y + boxW / 2 + 22),
      center: true,
      size: 11.5,
    );
    final arrowY = y + boxW / 2 + 44;
    _arrow(
      canvas,
      Offset(size.width * 0.3, arrowY),
      Offset(size.width * 0.7, arrowY),
      _stroke(AppColors.ember, 2.5),
    );
    _at(
      canvas,
      'so the log of 8, base 2, is 3',
      Offset(size.width / 2, arrowY + 22),
      center: true,
      size: 12,
      color: AppColors.ember,
    );
    final ruleY = arrowY + 46;
    _tick(canvas, Offset(size.width * 0.16, ruleY));
    _at(
      canvas,
      'times inside becomes plus outside',
      Offset(size.width * 0.16 + 14, ruleY - 7),
      size: 11,
    );
    _cross(canvas, Offset(size.width * 0.16, ruleY + 20));
    _at(
      canvas,
      'a plus INSIDE has no rule at all',
      Offset(size.width * 0.16 + 14, ruleY + 13),
      size: 11,
      color: AppColors.error,
    );
  }

  @override
  bool shouldRepaint(_LogMeaningPainter old) => false;
}

/// The unknown stuck in the exponent, and the log that pulls it down.
class _UndoPainter extends CustomPainter {
  const _UndoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final top = size.height * 0.26;
    final bottom = size.height * 0.68;
    final w = math.min(120.0, size.width * 0.34);

    _box(
      canvas,
      Rect.fromCenter(
        center: Offset(size.width * 0.29, top),
        width: w,
        height: 40,
      ),
      'e to the x',
      fill: AppColors.cream,
      size: 12,
    );
    _at(
      canvas,
      'x is up here, out of reach',
      Offset(size.width * 0.29, top + 34),
      center: true,
      size: 10.5,
    );

    _arrow(
      canvas,
      Offset(size.width * 0.47, top),
      Offset(size.width * 0.62, top),
      _stroke(AppColors.ember, 2.5),
    );
    _at(
      canvas,
      'take ln',
      Offset(size.width * 0.545, top - 16),
      center: true,
      size: 11,
      color: AppColors.ember,
    );

    _box(
      canvas,
      Rect.fromCenter(
        center: Offset(size.width * 0.78, top),
        width: w * 0.5,
        height: 40,
      ),
      'x',
      fill: AppColors.spring,
      size: 17,
    );
    _at(
      canvas,
      'ln undoes e exactly, and log undoes 10',
      Offset(size.width / 2, bottom + 6),
      center: true,
      size: 11.5,
    );
    _at(
      canvas,
      'clear anything multiplying it FIRST',
      Offset(size.width / 2, bottom + 26),
      center: true,
      size: 11.5,
      color: AppColors.ember,
    );
  }

  @override
  bool shouldRepaint(_UndoPainter old) => false;
}

/// Three separate log terms collapsing into one.
class _CombinePainter extends CustomPainter {
  const _CombinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.3;
    final boxW = math.min(74.0, (size.width - 40) / 3.4);
    const labels = ['log a', '+ log b', '- log c'];
    var x = size.width / 2 - (3 * boxW + 2 * 8) / 2;
    for (final l in labels) {
      _box(canvas, Rect.fromLTWH(x, y - 18, boxW, 36), l, size: 12);
      x += boxW + 8;
    }
    final midY = y + 40;
    _arrow(
      canvas,
      Offset(size.width / 2, midY),
      Offset(size.width / 2, midY + 26),
      _stroke(AppColors.ember, 2.5),
    );
    _box(
      canvas,
      Rect.fromCenter(
        center: Offset(size.width / 2, midY + 50),
        width: math.min(190.0, size.width * 0.72),
        height: 40,
      ),
      'log of (a times b over c)',
      fill: AppColors.spring,
      size: 12,
    );
    _at(
      canvas,
      'one log, then work it out once',
      Offset(size.width / 2, midY + 80),
      center: true,
      size: 11,
      color: AppColors.ember,
    );
  }

  @override
  bool shouldRepaint(_CombinePainter old) => false;
}

/// Cosine across the half turn: positive, zero at square, negative when open.
class _CosineSignPainter extends CustomPainter {
  const _CosineSignPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.12, right = size.width * 0.88;
    final mid = size.height * 0.44;
    final amp = size.height * 0.26;

    canvas.drawLine(
      Offset(left, mid),
      Offset(right, mid),
      _stroke(AppColors.charcoal.withValues(alpha: 0.3), 1.5),
    );

    final path = Path();
    for (var i = 0; i <= 60; i++) {
      final t = i / 60;
      final x = left + (right - left) * t;
      final y = mid - amp * math.cos(t * math.pi);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, _stroke(AppColors.ember, 3));

    final ninety = left + (right - left) * 0.5;
    canvas.drawLine(
      Offset(ninety, mid - amp - 6),
      Offset(ninety, mid + amp + 6),
      _stroke(AppColors.charcoal.withValues(alpha: 0.25), 1.5),
    );
    canvas.drawCircle(
      Offset(ninety, mid),
      4,
      Paint()..color = AppColors.charcoal,
    );

    _at(canvas, '0 deg', Offset(left - 4, mid + amp + 10), size: 10.5);
    _at(canvas, '90', Offset(ninety - 8, mid + amp + 10), size: 10.5);
    _at(canvas, '180', Offset(right - 20, mid + amp + 10), size: 10.5);
    _at(
      canvas,
      'cos is +',
      Offset(left + 10, mid - amp - 4),
      size: 11,
      color: AppColors.forest,
    );
    _at(
      canvas,
      'cos is -',
      Offset(right - 62, mid + amp - 12),
      size: 11,
      color: AppColors.error,
    );
    _at(
      canvas,
      'a minus answer means the angle is past square',
      Offset(size.width / 2, size.height - 12),
      center: true,
      size: 11,
      color: AppColors.ember,
    );
  }

  @override
  bool shouldRepaint(_CosineSignPainter old) => false;
}

/// The right triangle hiding inside the unit circle.
class _IdentityPainter extends CustomPainter {
  const _IdentityPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) * 0.32;
    final c = Offset(size.width * 0.44, size.height * 0.56);
    canvas.drawCircle(
      c,
      r,
      _stroke(AppColors.charcoal.withValues(alpha: 0.25), 1.5),
    );
    canvas.drawLine(
      c - Offset(r + 12, 0),
      c + Offset(r + 12, 0),
      _stroke(AppColors.charcoal.withValues(alpha: 0.2), 1.2),
    );
    canvas.drawLine(
      c - Offset(0, r + 12),
      c + Offset(0, r + 12),
      _stroke(AppColors.charcoal.withValues(alpha: 0.2), 1.2),
    );

    const a = 0.9; // radians
    final p = c + Offset(r * math.cos(a), -r * math.sin(a));
    final foot = Offset(p.dx, c.dy);

    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(foot.dx, foot.dy)
        ..lineTo(p.dx, p.dy)
        ..close(),
      Paint()..color = AppColors.spring.withValues(alpha: 0.35),
    );
    canvas.drawLine(c, foot, _stroke(AppColors.info, 3));
    canvas.drawLine(foot, p, _stroke(AppColors.forest, 3));
    canvas.drawLine(c, p, _stroke(AppColors.ember, 3));
    canvas.drawCircle(p, 4, Paint()..color = AppColors.charcoal);

    _at(
      canvas,
      'cos',
      Offset((c.dx + foot.dx) / 2 - 12, c.dy + 6),
      size: 11,
      color: AppColors.info,
    );
    _at(
      canvas,
      'sin',
      Offset(foot.dx + 6, (foot.dy + p.dy) / 2 - 7),
      size: 11,
      color: AppColors.forest,
    );
    _at(
      canvas,
      '1',
      Offset((c.dx + p.dx) / 2 - 12, (c.dy + p.dy) / 2 - 16),
      size: 12,
      color: AppColors.ember,
    );
    _at(
      canvas,
      'short side squared plus short side squared',
      Offset(size.width / 2, size.height - 28),
      center: true,
      size: 11,
    );
    _at(
      canvas,
      'equals the long one squared, which is 1',
      Offset(size.width / 2, size.height - 12),
      center: true,
      size: 11,
      color: AppColors.ember,
    );
  }

  @override
  bool shouldRepaint(_IdentityPainter old) => false;
}

/// A circle, an ellipse and a parabola side by side.
class _ConicFormsPainter extends CustomPainter {
  const _ConicFormsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width / 3;
    final cy = size.height * 0.44;
    final r = math.min(w * 0.3, size.height * 0.24);

    canvas.drawCircle(Offset(w * 0.5, cy), r, _stroke(AppColors.info, 3));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 1.5, cy),
        width: r * 2.6,
        height: r * 1.3,
      ),
      _stroke(AppColors.forest, 3),
    );
    final p = Path();
    for (var i = 0; i <= 40; i++) {
      final t = -1 + 2 * i / 40;
      final x = w * 2.5 + t * r * 1.3;
      final y = cy + r * 0.9 - t * t * r * 1.7;
      i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
    }
    canvas.drawPath(p, _stroke(AppColors.ember, 3));

    const caps = [
      ('circle', 'same number on both squares'),
      ('ellipse', 'different numbers, both plus'),
      ('parabola', 'only ONE square'),
    ];
    for (final (i, (name, why)) in caps.indexed) {
      _at(
        canvas,
        name,
        Offset(w * (i + 0.5), cy + r + 26),
        center: true,
        size: 12,
        color: AppColors.charcoal,
      );
      final tp = _text(why, size: 10);
      if (tp.width > w - 6) {
        final words = why.split(' ');
        final half = (words.length / 2).ceil();
        _at(
          canvas,
          words.take(half).join(' '),
          Offset(w * (i + 0.5), cy + r + 44),
          center: true,
          size: 10,
        );
        _at(
          canvas,
          words.skip(half).join(' '),
          Offset(w * (i + 0.5), cy + r + 58),
          center: true,
          size: 10,
        );
      } else {
        _at(
          canvas,
          why,
          Offset(w * (i + 0.5), cy + r + 46),
          center: true,
          size: 10,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ConicFormsPainter old) => false;
}

/// The area picture behind completing the square.
class _CompleteSquarePainter extends CustomPainter {
  const _CompleteSquarePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final unit = math.min(size.width * 0.16, size.height * 0.3);
    final strip = unit * 0.45;
    final x0 = size.width * 0.12;
    final y0 = size.height * 0.2;

    // x squared
    canvas.drawRect(
      Rect.fromLTWH(x0, y0, unit, unit),
      Paint()..color = AppColors.info.withValues(alpha: 0.5),
    );
    _at(
      canvas,
      'x sq',
      Offset(x0 + unit / 2, y0 + unit / 2),
      center: true,
      size: 11,
    );
    // the two half strips
    canvas.drawRect(
      Rect.fromLTWH(x0 + unit, y0, strip, unit),
      Paint()..color = AppColors.sunbeam.withValues(alpha: 0.65),
    );
    canvas.drawRect(
      Rect.fromLTWH(x0, y0 + unit, unit, strip),
      Paint()..color = AppColors.sunbeam.withValues(alpha: 0.65),
    );
    // the missing corner
    canvas.drawRect(
      Rect.fromLTWH(x0 + unit, y0 + unit, strip, strip),
      Paint()..color = AppColors.ember.withValues(alpha: 0.28),
    );
    canvas.drawRect(
      Rect.fromLTWH(x0 + unit, y0 + unit, strip, strip),
      _stroke(AppColors.ember, 2),
    );

    _at(
      canvas,
      'half the x strip',
      Offset(x0 + unit + strip + 12, y0 + unit * 0.4),
      size: 11,
    );
    _at(
      canvas,
      'the same again',
      Offset(x0 + unit + strip + 12, y0 + unit * 0.4 + 16),
      size: 11,
    );
    _at(
      canvas,
      'this corner is missing',
      Offset(x0 + unit + strip + 12, y0 + unit + strip * 0.3),
      size: 11,
      color: AppColors.ember,
    );
    _at(
      canvas,
      'add it to both sides: half the x number, squared',
      Offset(size.width / 2, size.height - 16),
      center: true,
      size: 11,
      color: AppColors.ember,
    );
  }

  @override
  bool shouldRepaint(_CompleteSquarePainter old) => false;
}

/// Two shapes side by side: something multiplied, and something wrapped.
class _ShapePainter extends CustomPainter {
  const _ShapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width / 2;
    final y = size.height * 0.3;

    // multiplied
    _box(
      canvas,
      Rect.fromCenter(center: Offset(w * 0.28, y), width: 54, height: 38),
      'x sq',
      fill: AppColors.info.withValues(alpha: 0.28),
    );
    _at(canvas, 'x', Offset(w * 0.5, y), center: true, size: 14);
    _box(
      canvas,
      Rect.fromCenter(center: Offset(w * 0.72, y), width: 54, height: 38),
      'sin x',
      fill: AppColors.info.withValues(alpha: 0.28),
    );
    _at(
      canvas,
      'two things multiplied',
      Offset(w * 0.5, y + 34),
      center: true,
      size: 11,
    );
    _at(
      canvas,
      'so: product rule',
      Offset(w * 0.5, y + 50),
      center: true,
      size: 11,
      color: AppColors.ember,
    );

    // wrapped
    final cx = w * 1.5;
    _box(
      canvas,
      Rect.fromCenter(center: Offset(cx, y), width: 120, height: 48),
      '',
      fill: AppColors.forest.withValues(alpha: 0.2),
      radius: 14,
    );
    _at(canvas, 'sin(', Offset(cx - 44, y), center: true, size: 13);
    _box(
      canvas,
      Rect.fromCenter(center: Offset(cx + 6, y), width: 56, height: 30),
      '3x + 5',
      fill: AppColors.spring.withValues(alpha: 0.55),
      size: 11.5,
      radius: 8,
    );
    _at(canvas, ')', Offset(cx + 46, y), center: true, size: 13);
    _at(
      canvas,
      'something inside something',
      Offset(cx, y + 38),
      center: true,
      size: 11,
    );
    _at(
      canvas,
      'so: chain rule',
      Offset(cx, y + 54),
      center: true,
      size: 11,
      color: AppColors.ember,
    );

    _at(
      canvas,
      'both can be true at once, and usually are',
      Offset(size.width / 2, size.height - 16),
      center: true,
      size: 11.5,
    );
  }

  @override
  bool shouldRepaint(_ShapePainter old) => false;
}

/// Nested boxes: peel the outer function, then multiply by the inner one.
class _NestPainter extends CustomPainter {
  const _NestPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final y = size.height * 0.3;
    final outer = Rect.fromCenter(
      center: Offset(cx, y),
      width: math.min(230.0, size.width * 0.78),
      height: 66,
    );
    _box(
      canvas,
      outer,
      '',
      fill: AppColors.forest.withValues(alpha: 0.18),
      radius: 18,
    );
    _at(
      canvas,
      'to the power 4',
      Offset(outer.right - 80, outer.top - 16),
      size: 11,
      color: AppColors.forest,
    );
    final inner = Rect.fromCenter(
      center: Offset(cx, y),
      width: outer.width * 0.56,
      height: 36,
    );
    _box(
      canvas,
      inner,
      '3x + 5',
      fill: AppColors.spring.withValues(alpha: 0.6),
      size: 12.5,
    );

    _arrow(
      canvas,
      Offset(inner.left - 10, y + 44),
      Offset(inner.left - 10, y + 24),
      _stroke(AppColors.ember, 2.2),
    );
    _at(
      canvas,
      'the inside has its own',
      Offset(cx, y + 56),
      center: true,
      size: 11,
    );
    _at(
      canvas,
      'slope, and you pay for it',
      Offset(cx, y + 72),
      center: true,
      size: 11,
    );
    _at(
      canvas,
      'peel the outside, then multiply by 3',
      Offset(cx, size.height - 16),
      center: true,
      size: 11.5,
      color: AppColors.ember,
    );
  }

  @override
  bool shouldRepaint(_NestPainter old) => false;
}

/// The quotient rule the right way round, and the same thing swapped.
class _QuotientPainter extends CustomPainter {
  const _QuotientPainter();

  @override
  void paint(Canvas canvas, Size size) {
    void row(double y, String text, bool right) {
      final bar = Rect.fromLTWH(size.width * 0.12, y, size.width * 0.62, 2);
      _at(
        canvas,
        text,
        Offset(size.width * 0.12, y - 22),
        size: 12.5,
        color: right ? AppColors.charcoal : AppColors.error,
      );
      canvas.drawRect(
        bar,
        Paint()..color = AppColors.charcoal.withValues(alpha: 0.5),
      );
      _at(
        canvas,
        'bottom, squared',
        Offset(size.width * 0.12, y + 8),
        size: 11,
      );
      if (right) {
        _tick(canvas, Offset(size.width * 0.86, y - 6));
      } else {
        _cross(canvas, Offset(size.width * 0.86, y - 6));
      }
    }

    row(size.height * 0.3, 'bottom x d(top)  -  top x d(bottom)', true);
    row(size.height * 0.68, 'top x d(bottom)  -  bottom x d(top)', false);
    _at(
      canvas,
      'lo d-hi minus hi d-lo, over lo-lo',
      Offset(size.width / 2, size.height - 14),
      center: true,
      size: 11.5,
      color: AppColors.ember,
    );
  }

  @override
  bool shouldRepaint(_QuotientPainter old) => false;
}

/// A smile and a frown, and the point where one becomes the other.
class _BendPainter extends CustomPainter {
  const _BendPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.1, right = size.width * 0.9;
    final mid = size.height * 0.45;
    final path = Path();
    for (var i = 0; i <= 80; i++) {
      final t = -1.0 + 2 * i / 80;
      final x = left + (right - left) * (i / 80);
      final y = mid - (t * t * t - 0) * size.height * 0.2;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, _stroke(AppColors.ember, 3));
    final flip = Offset((left + right) / 2, mid);
    canvas.drawCircle(flip, 5, Paint()..color = AppColors.charcoal);
    canvas.drawLine(
      Offset(flip.dx, mid - size.height * 0.26),
      Offset(flip.dx, mid + size.height * 0.26),
      _stroke(AppColors.charcoal.withValues(alpha: 0.25), 1.5),
    );

    _at(
      canvas,
      'frown: spills',
      Offset(left + 4, mid - size.height * 0.3),
      size: 11,
      color: AppColors.ink2,
    );
    _at(
      canvas,
      'smile: holds',
      Offset(right - 76, mid + size.height * 0.28),
      size: 11,
      color: AppColors.ink2,
    );
    _at(
      canvas,
      'the bend flips HERE',
      Offset(flip.dx + 8, mid - 16),
      size: 11,
      color: AppColors.ember,
    );
    _at(
      canvas,
      'zero is not enough: it must come out the other way',
      Offset(size.width / 2, size.height - 14),
      center: true,
      size: 11,
    );
  }

  @override
  bool shouldRepaint(_BendPainter old) => false;
}

/// One hilltop, two possible answers: where it is, and how high it is.
class _WhereOrWhatPainter extends CustomPainter {
  const _WhereOrWhatPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.16, right = size.width * 0.9;
    final base = size.height * 0.76;
    final peakX = left + (right - left) * 0.42;
    final peakY = size.height * 0.22;

    canvas.drawLine(
      Offset(left, base),
      Offset(right, base),
      _stroke(AppColors.charcoal.withValues(alpha: 0.35), 1.5),
    );
    canvas.drawLine(
      Offset(left, base),
      Offset(left, size.height * 0.12),
      _stroke(AppColors.charcoal.withValues(alpha: 0.35), 1.5),
    );

    final path = Path()..moveTo(left + 6, base - 6);
    path.quadraticBezierTo(peakX, peakY - 46, right - 8, base - 18);
    canvas.drawPath(path, _stroke(AppColors.ember, 3));
    canvas.drawCircle(
      Offset(peakX, peakY),
      5,
      Paint()..color = AppColors.charcoal,
    );

    // where
    canvas.drawLine(
      Offset(peakX, peakY),
      Offset(peakX, base),
      _stroke(AppColors.info, 2)..strokeCap = StrokeCap.butt,
    );
    _at(
      canvas,
      'where: x = a',
      Offset(peakX + 8, base - 20),
      size: 11,
      color: AppColors.info,
    );
    // how much
    canvas.drawLine(
      Offset(peakX, peakY),
      Offset(left, peakY),
      _stroke(AppColors.forest, 2)..strokeCap = StrokeCap.butt,
    );
    _at(
      canvas,
      'how high: f(a)',
      Offset(left + 6, peakY - 18),
      size: 11,
      color: AppColors.forest,
    );

    _at(
      canvas,
      'setting the slope to zero gives the FIRST one only',
      Offset(size.width / 2, size.height - 14),
      center: true,
      size: 11,
      color: AppColors.ember,
    );
  }

  @override
  bool shouldRepaint(_WhereOrWhatPainter old) => false;
}

/// The matched pair substitution needs, and a case with no match.
class _MatchPainter extends CustomPainter {
  const _MatchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.3;
    _at(canvas, 'the integral of', Offset(size.width * 0.08, y - 34), size: 11);
    _box(
      canvas,
      Rect.fromLTWH(size.width * 0.08, y - 18, size.width * 0.34, 38),
      'cos(x squared)',
      fill: AppColors.forest.withValues(alpha: 0.2),
      size: 11.5,
    );
    _at(canvas, 'x', Offset(size.width * 0.445, y), center: true, size: 13);
    _box(
      canvas,
      Rect.fromLTWH(size.width * 0.48, y - 18, size.width * 0.2, 38),
      '2x',
      fill: AppColors.spring.withValues(alpha: 0.6),
      size: 12.5,
    );
    _tick(canvas, Offset(size.width * 0.73, y));
    _at(
      canvas,
      'a match',
      Offset(size.width * 0.77, y - 7),
      size: 11,
      color: AppColors.forest,
    );

    final curve = Path()
      ..moveTo(size.width * 0.3, y + 24)
      ..quadraticBezierTo(size.width * 0.44, y + 44, size.width * 0.57, y + 24);
    canvas.drawPath(curve, _stroke(AppColors.ember, 2));
    _at(
      canvas,
      'the inside is x squared, and its slope 2x is here too',
      Offset(size.width / 2, y + 58),
      center: true,
      size: 10.5,
    );

    final y2 = size.height * 0.78;
    _box(
      canvas,
      Rect.fromLTWH(size.width * 0.08, y2 - 17, size.width * 0.34, 34),
      'cos(x squared)',
      fill: AppColors.cream,
      size: 11.5,
    );
    _at(canvas, 'alone', Offset(size.width * 0.45, y2 - 7), size: 11);
    _cross(canvas, Offset(size.width * 0.58, y2));
    _at(
      canvas,
      'no 2x, no swap',
      Offset(size.width * 0.62, y2 - 7),
      size: 10.5,
      color: AppColors.error,
    );
  }

  @override
  bool shouldRepaint(_MatchPainter old) => false;
}

/// The LIATE ladder: the higher one goes in the u slot.
class _LiatePainter extends CustomPainter {
  const _LiatePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const rows = [
      ('L', 'logs'),
      ('I', 'inverse trig'),
      ('A', 'algebra, like x'),
      ('T', 'trig'),
      ('E', 'e to the x'),
    ];
    final h = (size.height - 54) / rows.length;
    final x = size.width * 0.3;
    for (final (i, (letter, name)) in rows.indexed) {
      final y = 14 + i * h;
      _box(
        canvas,
        Rect.fromLTWH(x, y, 30, h - 6),
        letter,
        fill: i == 0
            ? AppColors.spring.withValues(alpha: 0.6)
            : AppColors.cream,
        size: 13,
      );
      _at(canvas, name, Offset(x + 40, y + (h - 6) / 2 - 7), size: 11.5);
    }
    _arrow(
      canvas,
      Offset(x - 12, 14 + 4 * h),
      Offset(x - 12, 18),
      _stroke(AppColors.ember, 2.2),
    );
    _at(
      canvas,
      'higher wins',
      Offset(2, 14 + 2 * h - 7),
      size: 10.5,
      color: AppColors.ember,
    );
    _at(
      canvas,
      'the winner becomes u and gets differentiated',
      Offset(size.width / 2, size.height - 16),
      center: true,
      size: 11,
    );
  }

  @override
  bool shouldRepaint(_LiatePainter old) => false;
}

/// A family of parallel curves: the plus C.
class _FamilyPainter extends CustomPainter {
  const _FamilyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.12, right = size.width * 0.88;
    for (var k = -1; k <= 1; k++) {
      final path = Path();
      for (var i = 0; i <= 40; i++) {
        final t = i / 40;
        final x = left + (right - left) * t;
        final y =
            size.height * 0.62 -
            t * t * size.height * 0.34 +
            k * size.height * 0.16;
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      canvas.drawPath(
        path,
        _stroke(
          k == 0 ? AppColors.ember : AppColors.ember.withValues(alpha: 0.4),
          k == 0 ? 3 : 2,
        ),
      );
    }
    _at(
      canvas,
      'same slope,',
      Offset(size.width / 2, size.height - 28),
      center: true,
      size: 11,
    );
    _at(
      canvas,
      'different heights',
      Offset(size.width / 2, size.height - 14),
      center: true,
      size: 11,
    );
  }

  @override
  bool shouldRepaint(_FamilyPainter old) => false;
}

/// The area under a curve between two limits.
class _AreaPainter extends CustomPainter {
  const _AreaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.14, right = size.width * 0.86;
    final base = size.height * 0.68;
    double yAt(double t) => base - (0.35 + 0.5 * t) * size.height * 0.4;

    final a = left + (right - left) * 0.22;
    final b = left + (right - left) * 0.78;
    final fill = Path()..moveTo(a, base);
    for (var i = 0; i <= 30; i++) {
      final t = i / 30;
      fill.lineTo(
        a + (b - a) * t,
        yAt((a - left) / (right - left) + t * (b - a) / (right - left)),
      );
    }
    fill
      ..lineTo(b, base)
      ..close();
    canvas.drawPath(
      fill,
      Paint()..color = AppColors.spring.withValues(alpha: 0.45),
    );

    final curve = Path();
    for (var i = 0; i <= 40; i++) {
      final t = i / 40;
      final x = left + (right - left) * t;
      i == 0 ? curve.moveTo(x, yAt(t)) : curve.lineTo(x, yAt(t));
    }
    canvas.drawPath(curve, _stroke(AppColors.ember, 3));
    canvas.drawLine(
      Offset(left, base),
      Offset(right, base),
      _stroke(AppColors.charcoal.withValues(alpha: 0.35), 1.5),
    );
    for (final (x, label) in [(a, 'a'), (b, 'b')]) {
      canvas.drawLine(
        Offset(x, base),
        Offset(x, yAt((x - left) / (right - left))),
        _stroke(AppColors.charcoal.withValues(alpha: 0.4), 1.5),
      );
      _at(canvas, label, Offset(x - 3, base + 6), size: 11);
    }
    _at(
      canvas,
      'top minus bottom',
      Offset(size.width / 2, size.height - 14),
      center: true,
      size: 11,
    );
  }

  @override
  bool shouldRepaint(_AreaPainter old) => false;
}

/// The form check: three possible readings, one of which lets the rule run.
class _FormCheckPainter extends CustomPainter {
  const _FormCheckPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const rows = [
      ('0 over 0', 'the rule applies', true),
      ('big over big', 'the rule applies', true),
      ('7 over 2', 'you already have it', false),
      ('7 over 0', 'it blows up, no rule', false),
    ];
    final h = (size.height - 46) / rows.length;
    for (final (i, (form, verdict, ok)) in rows.indexed) {
      final y = 14 + i * h;
      _box(
        canvas,
        Rect.fromLTWH(size.width * 0.08, y, size.width * 0.3, h - 8),
        form,
        fill: ok ? AppColors.spring.withValues(alpha: 0.5) : AppColors.cream,
        size: 12,
      );
      ok
          ? _tick(canvas, Offset(size.width * 0.44, y + (h - 8) / 2))
          : _cross(canvas, Offset(size.width * 0.44, y + (h - 8) / 2));
      _at(
        canvas,
        verdict,
        Offset(size.width * 0.52, y + (h - 8) / 2 - 7),
        size: 10.5,
        color: ok ? AppColors.forest : AppColors.ink2,
      );
    }
    _at(
      canvas,
      'put the number in, read the form, then decide',
      Offset(size.width / 2, size.height - 14),
      center: true,
      size: 11,
      color: AppColors.ember,
    );
  }

  @override
  bool shouldRepaint(_FormCheckPainter old) => false;
}

/// Two arrows straight down: the top differentiated, the bottom differentiated.
class _SeparatelyPainter extends CustomPainter {
  const _SeparatelyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.32;
    final barY = size.height * 0.46;
    final w = size.width * 0.34;

    _at(canvas, 'sin x', Offset(cx, barY - 26), center: true, size: 13);
    canvas.drawRect(
      Rect.fromLTWH(cx - w / 2, barY - 1, w, 2),
      Paint()..color = AppColors.charcoal.withValues(alpha: 0.6),
    );
    _at(canvas, 'x', Offset(cx, barY + 20), center: true, size: 13);

    _arrow(
      canvas,
      Offset(cx + w / 2 + 8, barY - 24),
      Offset(cx + w * 1.1, barY - 24),
      _stroke(AppColors.forest, 2.2),
    );
    _arrow(
      canvas,
      Offset(cx + w / 2 + 8, barY + 22),
      Offset(cx + w * 1.1, barY + 22),
      _stroke(AppColors.forest, 2.2),
    );

    final rx = cx + w * 1.5;
    _at(
      canvas,
      'cos x',
      Offset(rx, barY - 26),
      center: true,
      size: 13,
      color: AppColors.forest,
    );
    canvas.drawRect(
      Rect.fromLTWH(rx - w / 2, barY - 1, w, 2),
      Paint()..color = AppColors.charcoal.withValues(alpha: 0.6),
    );
    _at(
      canvas,
      '1',
      Offset(rx, barY + 20),
      center: true,
      size: 13,
      color: AppColors.forest,
    );

    _at(
      canvas,
      'not the quotient rule: nothing squared',
      Offset(size.width / 2, size.height - 14),
      center: true,
      size: 10.5,
      color: AppColors.ember,
    );
  }

  @override
  bool shouldRepaint(_SeparatelyPainter old) => false;
}

/// A curve blowing up at zero: both branches the same way, or opposite ways.
class _BlowUpPainter extends CustomPainter {
  const _BlowUpPainter({required this.agree});

  final bool agree;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final mid = size.height * 0.5;
    final top = size.height * 0.12, bottom = size.height * 0.88;

    canvas.drawLine(
      Offset(size.width * 0.08, mid),
      Offset(size.width * 0.92, mid),
      _stroke(AppColors.charcoal.withValues(alpha: 0.3), 1.5),
    );
    canvas.drawLine(
      Offset(cx, top - 4),
      Offset(cx, bottom + 4),
      _stroke(AppColors.charcoal.withValues(alpha: 0.3), 1.5),
    );

    void branch(bool rightSide, bool up) {
      final path = Path();
      for (var i = 1; i <= 34; i++) {
        final t = i / 34;
        final dx = (size.width * 0.4) * t;
        final x = rightSide ? cx + dx : cx - dx;
        final v = 1 / (t * 3.2 + 0.28);
        final y = up
            ? mid - v * size.height * 0.3
            : mid + v * size.height * 0.3;
        i == 1
            ? path.moveTo(x, y.clamp(top, bottom))
            : path.lineTo(x, y.clamp(top, bottom));
      }
      canvas.drawPath(path, _stroke(up ? AppColors.ember : AppColors.info, 3));
    }

    branch(true, true);
    branch(false, agree);
  }

  @override
  bool shouldRepaint(_BlowUpPainter old) => old.agree != agree;
}

/// Every picture on this chapter's sheets, by the contact sheet's card name.
const mathematicsPictures = <String, Widget Function()>{
  'perpendicular': perpendicularPicture,
  'discriminant': discriminantPicture,
  'grade': gradePicture,
  'log-rules': logRulesPicture,
  'undo-exponent': undoExponentPicture,
  'combine-logs': combineLogsPicture,
  'side-names': sideNamesPicture,
  'ratios': ratiosPicture,
  'components': componentsPicture,
  'which-law': whichLawPicture,
  'writing-the-laws': setupPicture,
  'negative-cosine': obtusePicture,
  'unit-circle': unitCirclePicture,
  'quadrants': quadrantPicture,
  'identities': identitiesPicture,
  'circle-form': circleFormPicture,
  'three-forms': readingConicsPicture,
  'completing-the-square': completeSquarePicture,
  'which-rule': whichRulePicture,
  'chain-rule': chainRulePicture,
  'quotient-order': quotientOrderPicture,
  'critical-points': criticalPointPicture,
  'concavity': concavityPicture,
  'where-or-how-much': askedForPicture,
  'substitution': substitutionPicture,
  'by-parts': byPartsPicture,
  'finishing': finishingPicture,
  'check-the-form': formCheckPicture,
  'separately': separatelyPicture,
  'both-sides': bothSidesPicture,
};
