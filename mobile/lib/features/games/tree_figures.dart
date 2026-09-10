import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// One possible ending on a chance branch: how likely it is, and what the
/// whole path costs if it happens.
///
/// The cost is the TOTAL, not the extra. A second phase that adds five to an
/// initial five is written as ten, because that is what the county ends up
/// paying and comparing halves of a path is how people lose these.
@immutable
class Chance {
  const Chance(this.p, this.cost, {this.note});

  /// Probability, as a fraction.
  final double p;

  /// What the whole path costs if this is what happens.
  final double cost;

  /// What to write on the branch instead of the percentage. The lesson warns
  /// about the unlabeled branch whose probability is whatever is left over,
  /// and the only honest way to draw that is to say so.
  final String? note;

  String get label => note ?? '${(p * 100).round()}%';
}

/// One thing you can choose at the decision node: either a price, or a fork.
@immutable
class TreeBranch {
  const TreeBranch.certain(this.name, double cost)
      : ends = const [],
        certain = cost;

  const TreeBranch.uncertain(this.name, this.ends) : certain = null;

  final String name;

  /// The cost if there is nothing to weigh. Null on a chance branch.
  final double? certain;

  /// The endings, when there are several. Empty on a certain branch.
  final List<Chance> ends;

  bool get isChance => certain == null;

  /// Rolled back: the expected cost of taking this branch.
  double get expected {
    if (certain != null) return certain!;
    var total = 0.0;
    for (final e in ends) {
      total += e.p * e.cost;
    }
    return total;
  }

  /// The cheapest and dearest this branch can turn out, which is the pair the
  /// expected cost has to sit between.
  (double, double) get span {
    if (certain != null) return (certain!, certain!);
    var lo = ends.first.cost;
    var hi = ends.first.cost;
    for (final e in ends) {
      if (e.cost < lo) lo = e.cost;
      if (e.cost > hi) hi = e.cost;
    }
    return (lo, hi);
  }
}

/// A decision tree, drawn the way the lesson draws one: a square where you
/// choose, circles where you do not, and a triangle at every ending.
///
/// The picture is the question here. Rolling a tree back is a reading skill
/// before it is an arithmetic one, and a tree written out as prose ("a forty
/// percent chance of a further five million") hides the one thing worth
/// seeing, which is that the two endings bracket the answer.
class TreePainter extends CustomPainter {
  const TreePainter({
    required this.branches,
    required this.selected,
    required this.locked,
    required this.truth,
  });

  final List<TreeBranch> branches;

  /// Which branch the thumb is on, if any.
  final int? selected;
  final bool locked;

  /// The branch the rollback actually picks.
  final int truth;

  /// How tall one branch needs to be. A fork needs room for its endings; a
  /// price needs a thumb's worth and no more.
  static double rowHeight(TreeBranch b) =>
      b.isChance ? 30 + 26.0 * b.ends.length : 52;

  static double heightOf(List<TreeBranch> branches) {
    var total = 0.0;
    for (final b in branches) {
      total += rowHeight(b);
    }
    return total + 10;
  }

  static const _nodeX = 30.0;
  static const _nameX = _nodeX + 18;

  /// Where the circles sit, measured from the branch names rather than fixed,
  /// because "Reversible lane" is twice the width of "Widen" and a guessed
  /// column drew one straight through the other and through its probability.
  double get _forkX {
    var widest = 0.0;
    for (final b in branches) {
      final w = _measure(b.name).width;
      if (w > widest) widest = w;
    }
    return _nameX + widest + 22;
  }

  /// Measured from the amounts, because a figure that guesses its right-hand
  /// gutter clips the last digit off the widest one.
  double get _padR {
    var widest = 0.0;
    for (final b in branches) {
      final texts = b.isChance
          ? [for (final e in b.ends) _money(e.cost)]
          : [_money(b.certain!)];
      for (final t in texts) {
        final w = _measure(t).width;
        if (w > widest) widest = w;
      }
    }
    return widest + 16;
  }

  static String _money(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  static TextPainter _measure(String text, {Color color = AppColors.charcoal}) =>
      TextPainter(
        text: TextSpan(text: text, style: AppTheme.mono(size: 10.5, color: color)),
        textDirection: TextDirection.ltr,
      )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    final endX = size.width - _padR;
    final forkX = _forkX;
    final tops = <double>[];
    var y = 5.0;
    for (final b in branches) {
      tops.add(y);
      y += rowHeight(b);
    }

    // The square, centerd on the whole fan of branches so that every line
    // leaves the same point.
    final firstMid = tops.first + rowHeight(branches.first) / 2;
    final lastMid = tops.last + rowHeight(branches.last) / 2;
    final rootY = (firstMid + lastMid) / 2;

    for (var i = 0; i < branches.length; i++) {
      final b = branches[i];
      final mid = tops[i] + rowHeight(b) / 2;
      final chosen = selected == i;
      final isTruth = i == truth;
      final Color color;
      if (locked && isTruth) {
        color = AppColors.forest;
      } else if (locked && chosen) {
        color = AppColors.error;
      } else if (chosen) {
        color = AppColors.ember;
      } else {
        color = AppColors.ink2;
      }
      final heavy = chosen || (locked && isTruth);

      if (heavy) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(
              _nodeX - 6,
              tops[i] + 2,
              size.width - 2,
              tops[i] + rowHeight(b) - 2,
            ),
            const Radius.circular(10),
          ),
          Paint()..color = color.withValues(alpha: 0.08),
        );
      }

      final stroke = Paint()
        ..color = color
        ..strokeWidth = heavy ? 2 : 1.3
        ..style = PaintingStyle.stroke;

      // Out of the square, up or down to this branch's own line.
      canvas.drawLine(Offset(_nodeX, rootY), Offset(_nodeX + 14, mid), stroke);

      _write(canvas, b.name, Offset(_nameX, mid - 20), color, align: 1);

      if (!b.isChance) {
        canvas.drawLine(Offset(_nodeX + 14, mid), Offset(endX, mid), stroke);
        _triangle(canvas, Offset(endX, mid), color);
        _write(canvas, _money(b.certain!), Offset(endX + 8, mid - 6), color,
            align: 1);
        continue;
      }

      canvas.drawLine(Offset(_nodeX + 14, mid), Offset(forkX, mid), stroke);
      // The circle: nobody chooses here, the weather does.
      canvas.drawCircle(Offset(forkX, mid), 7, Paint()..color = AppColors.white);
      canvas.drawCircle(Offset(forkX, mid), 7, stroke);

      final n = b.ends.length;
      for (var j = 0; j < n; j++) {
        final e = b.ends[j];
        final ey = mid + (j - (n - 1) / 2) * 26.0;
        canvas.drawLine(Offset(forkX + 7, mid), Offset(forkX + 26, ey), stroke);
        canvas.drawLine(Offset(forkX + 26, ey), Offset(endX, ey), stroke);
        _triangle(canvas, Offset(endX, ey), color);
        _write(canvas, _money(e.cost), Offset(endX + 8, ey - 6), color,
            align: 1);
        _write(canvas, e.label, Offset(forkX + 30, ey - 15), AppColors.ink3,
            align: 1);
      }
    }

    // Drawn last so the branch fills never sit on top of it.
    final root = Rect.fromCenter(
      center: Offset(_nodeX, rootY),
      width: 15,
      height: 15,
    );
    canvas.drawRect(root, Paint()..color = AppColors.creamDark);
    canvas.drawRect(
      root,
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  void _triangle(Canvas canvas, Offset at, Color color) {
    final path = Path()
      ..moveTo(at.dx, at.dy - 5)
      ..lineTo(at.dx + 7, at.dy)
      ..lineTo(at.dx, at.dy + 5)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _write(Canvas canvas, String text, Offset at, Color color,
      {int align = 0}) {
    final tp = _measure(text, color: color);
    final dx = switch (align) {
      1 => 0.0,
      -1 => tp.width,
      _ => tp.width / 2,
    };
    tp.paint(canvas, at - Offset(dx, 0));
  }

  @override
  bool shouldRepaint(TreePainter old) =>
      old.branches != branches ||
      old.selected != selected ||
      old.locked != locked;
}
