import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// How a cell in the little spreadsheet is being drawn right now.
enum CellState {
  /// Nothing special: a value sitting in a cell.
  plain,

  /// The cell the formula lives in.
  source,

  /// The cell the formula is being copied into.
  target,

  /// The student says the copied formula reads this one.
  picked,

  /// It does.
  right,

  /// It does not.
  wrong,
}

/// A small spreadsheet, drawn the way a spreadsheet actually looks: lettered
/// columns across the top, numbered rows down the side, values in the middle.
///
/// Everything in this lesson is about WHERE a reference points, so a grid you
/// can put a finger on is worth more than the same question asked in words.
/// Cells are addressed the way the exam addresses them, "B2" and not a pair of
/// indices, so nothing has to be translated.
class SheetGrid extends StatelessWidget {
  const SheetGrid({
    super.key,
    required this.columns,
    required this.rows,
    required this.values,
    this.stateOf,
    this.onTap,
  });

  final List<String> columns;
  final int rows;

  /// Cell name to what it displays. A missing entry is an empty cell.
  final Map<String, String> values;

  /// How to draw each cell. Null means everything is plain.
  final CellState Function(String cell)? stateOf;
  final void Function(String cell)? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 30, height: 26),
              for (final c in columns)
                Expanded(
                  child: Container(
                    height: 26,
                    alignment: Alignment.center,
                    color: AppColors.creamDark,
                    child: Text(
                      c,
                      style: AppTheme.mono(size: 11, color: AppColors.ink2),
                    ),
                  ),
                ),
            ],
          ),
          for (var r = 1; r <= rows; r++)
            Row(
              children: [
                Container(
                  width: 30,
                  height: 42,
                  alignment: Alignment.center,
                  color: AppColors.creamDark,
                  child: Text(
                    '$r',
                    style: AppTheme.mono(size: 11, color: AppColors.ink2),
                  ),
                ),
                for (final c in columns)
                  Expanded(
                    child: _Cell(
                      key: ValueKey('cell-$c$r'),
                      name: '$c$r',
                      text: values['$c$r'] ?? '',
                      state: stateOf?.call('$c$r') ?? CellState.plain,
                      onTap: onTap == null ? null : () => onTap!('$c$r'),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    super.key,
    required this.name,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String name;
  final String text;
  final CellState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (fill, border, width) = switch (state) {
      CellState.plain => (AppColors.white, AppColors.line, 1.0),
      CellState.source => (AppColors.sunbeamBg, AppColors.sunbeam, 2.0),
      CellState.target => (AppColors.creamDark, AppColors.ink3, 2.0),
      CellState.picked => (AppColors.emberBg, AppColors.ember, 2.0),
      CellState.right => (AppColors.forestBg, AppColors.forest, 2.0),
      CellState.wrong => (AppColors.errorBg, AppColors.error, 2.0),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(color: border, width: width),
        ),
        child: Text(
          text,
          style: AppTheme.mono(size: 13, color: AppColors.charcoal),
        ),
      ),
    );
  }
}

/// The formula bar over the sheet, which is where a spreadsheet shows you what
/// a cell really holds rather than what it is displaying.
class FormulaBar extends StatelessWidget {
  const FormulaBar({super.key, required this.cell, required this.formula});

  final String cell;
  final String formula;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.sunbeamBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              cell,
              style: AppTheme.mono(size: 12, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              formula,
              // Ligatures off: the mono face draws ">=" as a single glyph, and
              // a spreadsheet formula bar shows the two characters you type.
              style: AppTheme.mono(
                size: 14,
                color: AppColors.charcoal,
              ).copyWith(fontFeatures: const [FontFeature.disable('calt')]),
            ),
          ),
        ],
      ),
    );
  }
}
