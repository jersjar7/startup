import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../games/game_catalog.dart';
import '../study/content_repository.dart';
import 'mastery_model.dart';

/// Every chapter as a place rather than a row.
///
/// Across is what a chapter is worth on the exam, up is how far through it
/// you are. A chapter worth a lot that you have barely started lands bottom
/// right, so "where do I work next" stops being a calculation and becomes a
/// corner of the drawing (owner's call, 2026-10-04).
///
/// The grid this replaced could not rank: fifteen tiles in catalog order, no
/// shared baseline, two thirds of each tile air. Position is the strongest
/// thing a drawing has for comparing two quantities at once, and this is two
/// quantities at once.
class PriorityField extends StatefulWidget {
  const PriorityField({super.key, required this.mastery, required this.onOpen});

  /// chapterId -> both halves, as the server composes them.
  final Map<String, ChapterMastery> mastery;

  /// Open a chapter's map from the detail panel.
  final void Function(ChapterMap chapter) onOpen;

  @override
  State<PriorityField> createState() => _PriorityFieldState();
}

class _PriorityFieldState extends State<PriorityField> {
  String? _picked;

  @override
  Widget build(BuildContext context) {
    final totals = totalsOf(widget.mastery);
    final focus = focusChapters(totals).toSet();
    // Six chapters share a weight of 4, and most sit at the same mastery on
    // day one, so a plain plot would stack them into one dot and hide five
    // chapters. Ties fan out sideways, which is honest: the axis they share
    // is the one being nudged, and mastery, the axis that matters, stays
    // exact.
    final rows = [
      for (final chapter in chapterMaps.values)
        (
          chapter.id,
          (examWeights[chapter.id] ?? 4).toDouble(),
          (totals[chapter.id] ?? 0).toDouble(),
        ),
    ];
    final crowd = <String, int>{};
    for (final r in rows) {
      final key = '${r.$2}:${(r.$3 / 6).round()}';
      crowd[key] = (crowd[key] ?? 0) + 1;
    }
    final seen = <String, int>{};
    final points = <_Point>[];
    for (final r in rows) {
      final key = '${r.$2}:${(r.$3 / 6).round()}';
      final n = crowd[key]!;
      final i = seen[key] = (seen[key] ?? -1) + 1;
      points.add(
        _Point(
          id: r.$1,
          weight: r.$2,
          mastery: r.$3,
          fan: n == 1 ? 0 : (i - (n - 1) / 2) * 20.0,
          hot: focus.contains(r.$1),
          touched: (widget.mastery[r.$1]?.gamesCleared ?? 0) > 0,
        ),
      );
    }
    final picked = _picked ?? (focus.isEmpty ? null : focus.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final size = Size(box.maxWidth, box.maxWidth * 0.82);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) {
                final hit = _nearest(points, d.localPosition, size);
                if (hit != null) setState(() => _picked = hit);
              },
              child: CustomPaint(
                size: size,
                painter: _FieldPainter(points: points, picked: picked),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        if (picked != null)
          _Detail(
            chapter: chapterMaps[picked]!,
            mastery: widget.mastery[picked],
            pct: totals[picked] ?? 0,
            rank: focusRank(totals, picked),
            onOpen: () => widget.onOpen(chapterMaps[picked]!),
          ),
      ],
    );
  }

  /// The chapter nearest the tap, within a thumb's reach of it.
  String? _nearest(List<_Point> points, Offset at, Size size) {
    String? best;
    var near = 34.0;
    for (final p in points) {
      final d = (p.place(size) - at).distance;
      if (d < near) {
        near = d;
        best = p.id;
      }
    }
    return best;
  }
}

class _Point {
  _Point({
    required this.id,
    required this.weight,
    required this.mastery,
    required this.fan,
    required this.hot,
    required this.touched,
  });

  final String id;
  final double weight;
  final double mastery;

  /// How far sideways this dot moves to clear the ones it would land on.
  final double fan;
  final bool hot;

  /// Anything done in the app for this chapter, which the dot marks with a
  /// green pip: the app's own work, never mixed into the mastery figure.
  final bool touched;

  static const pad = EdgeInsets.fromLTRB(34, 30, 14, 36);

  Offset place(Size size) {
    final w = size.width - pad.horizontal;
    final h = size.height - pad.vertical;
    // Weights run 4 to 14; a little room either side so no dot sits on an axis.
    final x = pad.left + ((weight - 3) / 12).clamp(0.0, 1.0) * w;
    final y = pad.top + h - (mastery / 100).clamp(0.0, 1.0) * h;
    return Offset((x + fan).clamp(pad.left + 6, pad.left + w), y);
  }
}

class _FieldPainter extends CustomPainter {
  _FieldPainter({required this.points, required this.picked});

  final List<_Point> points;
  final String? picked;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = _Point.pad;
    final plot = Rect.fromLTRB(
      pad.left,
      pad.top,
      size.width - pad.right,
      size.height - pad.bottom,
    );

    // The corner that answers the question: worth a lot, barely started.
    final zone = Rect.fromLTRB(
      pad.left + plot.width * 0.46,
      plot.top + plot.height * 0.55,
      plot.right,
      plot.bottom,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(zone, const Radius.circular(10)),
      Paint()..color = AppColors.peach.withValues(alpha: 0.42),
    );
    _write(
      canvas,
      'work here first',
      Offset(zone.right - 7, zone.top + 7),
      align: TextAlign.right,
      color: AppColors.charcoal,
    );

    final rule = Paint()
      ..color = AppColors.charcoal.withValues(alpha: 0.13)
      ..strokeWidth = 1;
    for (final m in [0, 25, 50, 75, 100]) {
      final y = plot.bottom - plot.height * m / 100;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), rule);
      _write(
        canvas,
        '$m',
        Offset(plot.left - 6, y - 6),
        align: TextAlign.right,
      );
    }
    canvas.drawLine(plot.bottomLeft, plot.bottomRight, rule);
    canvas.drawLine(plot.topLeft, plot.bottomLeft, rule);

    for (final w in [4, 8, 12]) {
      final x = plot.left + plot.width * ((w - 3) / 12);
      _write(
        canvas,
        '$w Q',
        Offset(x, plot.bottom + 6),
        align: TextAlign.center,
      );
    }
    _write(
      canvas,
      'share of the exam',
      Offset(plot.right, plot.bottom + 20),
      align: TextAlign.right,
    );
    _write(canvas, 'mastery %', const Offset(0, 2), align: TextAlign.left);

    for (final p in points) {
      final at = p.place(size);
      final on = p.id == picked;
      final r = on ? 11.0 : 8.0;
      if (on) {
        canvas.drawCircle(
          at,
          r + 5,
          Paint()..color = AppColors.charcoal.withValues(alpha: 0.14),
        );
      }
      canvas.drawCircle(
        at,
        r,
        Paint()..color = p.hot ? AppColors.ember : AppColors.charcoal,
      );
      if (p.touched) {
        canvas.drawCircle(at, r * 0.4, Paint()..color = AppColors.spring);
      }
    }
  }

  void _write(
    Canvas canvas,
    String text,
    Offset at, {
    TextAlign align = TextAlign.left,
    Color color = AppColors.mutedOnLight,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTheme.mono(size: 9.5, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = switch (align) {
      TextAlign.right => at.dx - tp.width,
      TextAlign.center => at.dx - tp.width / 2,
      _ => at.dx,
    };
    tp.paint(canvas, Offset(dx, at.dy));
  }

  @override
  bool shouldRepaint(_FieldPainter old) =>
      old.picked != picked || old.points.length != points.length;
}

/// What the tapped dot is, and what finishing it would do. The two halves are
/// named and colored apart: ember is the website's mastery, spring is what
/// this phone has done (ADR 0020).
class _Detail extends StatelessWidget {
  const _Detail({
    required this.chapter,
    required this.mastery,
    required this.pct,
    required this.rank,
    required this.onOpen,
  });

  final ChapterMap chapter;
  final ChapterMastery? mastery;
  final int pct;
  final int rank;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final done = mastery?.gamesCleared ?? 0;
    final items = mastery?.gamesTotal ?? 0;
    final weight = examWeights[chapter.id] ?? 4;
    final gain = ((100 - pct) * weight / 110).toStringAsFixed(1);

    return GestureDetector(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chapter.name,
              style: AppTheme.display(size: 20, height: 1.1, tracking: -0.03),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Half(
                    label: 'MASTERY',
                    value: '$pct',
                    unit: '%',
                    source: 'earned on the website',
                    tone: AppColors.ember,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Half(
                    label: 'PROGRESS',
                    value: '$done',
                    unit: items == 0 ? '' : ' of $items',
                    source: 'done in this app',
                    tone: AppColors.forest,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Text(
              'Worth ${weightChip(chapter)} of the exam. Finishing it would '
              'move your total by about $gain points, which puts it '
              '${_ordinal(rank)} of ${chapterMaps.length} for where effort '
              'pays.',
              style: AppTheme.body(
                size: 13,
                height: 1.45,
                color: AppColors.mutedOnLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    return switch (n % 10) {
      1 => '${n}st',
      2 => '${n}nd',
      3 => '${n}rd',
      _ => '${n}th',
    };
  }
}

class _Half extends StatelessWidget {
  const _Half({
    required this.label,
    required this.value,
    required this.unit,
    required this.source,
    required this.tone,
  });

  final String label;
  final String value;
  final String unit;
  final String source;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.eyebrow(color: AppColors.mutedOnLight)),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                text: value,
                style: AppTheme.display(
                  size: 26,
                  height: 0.9,
                  tracking: -0.04,
                  color: tone,
                ),
                children: [
                  TextSpan(
                    text: unit,
                    style: AppTheme.display(size: 13, height: 0.9, color: tone),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            source,
            style: AppTheme.mono(size: 9.5, color: AppColors.mutedOnLight),
          ),
        ],
      ),
    );
  }
}

/// Where a chapter sits in the "where effort pays" order, one-based.
int focusRank(Map<String, int> totals, String id) {
  final rows = [
    for (final c in chapterMaps.keys)
      (c, (100 - (totals[c] ?? 0)) * (examWeights[c] ?? 0)),
  ]..sort((a, b) => b.$2.compareTo(a.$2));
  return rows.indexWhere((r) => r.$1 == id) + 1;
}
