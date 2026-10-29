import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../../core/theme/app_colors.dart';

/// Renders a string that mixes plain text with inline LaTeX delimited by `$…$`
/// (e.g. "The cap is $\\mu_s N$."). Math segments render with flutter_math;
/// anything it can't parse falls back to its raw source so nothing disappears.
class MathText extends StatelessWidget {
  const MathText(this.data, {super.key, this.style});

  final String data;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base =
        style ??
        const TextStyle(fontSize: 15, height: 1.5, color: AppColors.charcoal);
    final parts = data.split(r'$');
    final spans = <InlineSpan>[];
    for (var i = 0; i < parts.length; i++) {
      if (i.isEven) {
        if (parts[i].isNotEmpty) spans.add(TextSpan(text: parts[i]));
      } else {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: _FitMath(parts[i], base),
          ),
        );
      }
    }
    return Text.rich(TextSpan(style: base, children: spans));
  }
}

/// One inline formula. Drawn whole when it fits the line, exactly as
/// before. A formula wider than the screen breaks where a textbook would,
/// after an equals or a plus sign (and between the words of `\text{}`), and
/// a piece still too wide on its own shrinks to fit. It never runs off.
class _FitMath extends StatelessWidget {
  const _FitMath(this.latex, this.style);

  final String latex;
  final TextStyle style;

  Math _math(String tex) => Math.tex(
    tex,
    textStyle: style,
    mathStyle: MathStyle.text,
    onErrorFallback: (_) => Text(tex, style: style),
  );

  @override
  Widget build(BuildContext context) {
    return _WholeOrBroken(
      children: [
        _math(latex),
        // A Wrap hands each piece the full width, so a piece shrinks only
        // when it is wider than the whole line.
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 4,
          children: [
            for (final piece in formulaPieces(latex))
              FittedBox(fit: BoxFit.scaleDown, child: _math(piece)),
          ],
        ),
      ],
    );
  }
}

/// The pieces a long formula may break into: after each equals, plus,
/// minus, times or comparison outside any braces, and between the words of
/// a `\text{}`. Each piece is whole TeX. One that ends on a sign carries an
/// empty group after it (`a \times{}`), so the sign keeps its spacing at
/// the end of a line as it has in the middle of one.
@visibleForTesting
List<String> formulaPieces(String tex) {
  const signs = {
    'times', 'cdot', 'pm', 'approx', 'le', 'leq', 'ge', 'geq', 'neq', //
    'to', 'Rightarrow',
  };
  bool isLetter(String c) => RegExp('[A-Za-z]').hasMatch(c);
  final pieces = <String>[];
  var start = 0, depth = 0, i = 0;
  void cut(int end, {String sign = ''}) {
    final piece = tex.substring(start, end).trim();
    if (piece.isNotEmpty) pieces.add(sign.isEmpty ? piece : '$piece{}');
    start = end;
  }

  while (i < tex.length) {
    final c = tex[i];
    if (c == r'\') {
      var j = i + 1;
      while (j < tex.length && isLetter(tex[j])) {
        j++;
      }
      if (j == i + 1) j++; // \{, \, and the like: one character.
      final name = tex.substring(i + 1, j);
      if (name == 'left') depth++;
      if (name == 'right') depth--;
      if (depth == 0 && name == 'text' && j < tex.length && tex[j] == '{') {
        // The words of a \text{} of several, with nothing nested inside.
        final close = tex.indexOf('}', j);
        final words = tex.substring(j + 1, close);
        if (close > 0 && words.trim().contains(' ') && !words.contains('{')) {
          cut(i);
          final split = words.split(' ');
          for (final (k, w) in split.indexed) {
            if (w.isEmpty) continue;
            pieces.add('\\text{$w${k < split.length - 1 ? ' ' : ''}}');
          }
          start = i = close + 1;
          continue;
        }
      }
      i = j;
      if (depth == 0 && signs.contains(name)) cut(i, sign: name);
      continue;
    }
    if (c == '{') depth++;
    if (c == '}') depth--;
    i++;
    if (depth == 0 && '=+-<>'.contains(c)) {
      final before = tex.substring(start, i - 1).trim();
      // A sign with nothing before it, or a power's minus, is no break.
      if (before.isEmpty || before.endsWith('^') || before.endsWith('_')) {
        continue;
      }
      cut(i, sign: c);
    }
  }
  cut(tex.length);
  return pieces;
}

/// Lays out its first child at its natural width and shows it if it fits;
/// otherwise shows the second child, laid out to the width there is.
class _WholeOrBroken extends MultiChildRenderObjectWidget {
  const _WholeOrBroken({required super.children});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderWholeOrBroken();
}

class _RenderWholeOrBroken extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  RenderBox get _whole => firstChild!;
  RenderBox get _broken => lastChild!;
  bool _fits = true;

  RenderBox get _shown => _fits ? _whole : _broken;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData) {
      child.parentData = MultiChildLayoutParentData();
    }
  }

  // Measured by laying the formula out, not from its intrinsic width:
  // flutter_math cannot always give one, and when it does it can come out a
  // few pixels short.
  bool _fitsIn(BoxConstraints constraints) =>
      _whole.getDryLayout(const BoxConstraints()).width <= constraints.maxWidth;

  @override
  double computeMinIntrinsicWidth(double height) =>
      _whole.getMinIntrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _whole.getMaxIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) =>
      _whole.getMinIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _whole.getMaxIntrinsicHeight(width);

  @override
  Size computeDryLayout(BoxConstraints constraints) => _fitsIn(constraints)
      ? _whole.getDryLayout(constraints.loosen())
      : _broken.getDryLayout(constraints.loosen());

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) => _fitsIn(constraints)
      ? _whole.getDryBaseline(constraints.loosen(), baseline)
      : _broken.getDryBaseline(constraints.loosen(), baseline);

  @override
  void performLayout() {
    _whole.layout(const BoxConstraints(), parentUsesSize: true);
    _fits = _whole.size.width <= constraints.maxWidth;
    if (_fits) _whole.layout(constraints.loosen(), parentUsesSize: true);
    _broken.layout(constraints.loosen(), parentUsesSize: true);
    size = constraints.constrain(_shown.size);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      _shown.getDistanceToActualBaseline(baseline);

  @override
  void paint(PaintingContext context, Offset offset) =>
      context.paintChild(_shown, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      _shown.hitTest(result, position: position);
}

/// A standalone formula (a full LaTeX expression), for formula cards.
///
/// Long expressions shrink to fit rather than running off the card: a
/// half-visible formula is worse than a small one, and phones are narrow.
class MathBlock extends StatelessWidget {
  const MathBlock(
    this.latex, {
    super.key,
    this.fontSize = 17,
    this.align,
    this.fit = true,
  });

  final String latex;
  final double fontSize;

  /// Where the formula sits when it is narrower than its box.
  final Alignment? align;

  /// Shrink to fit the space offered. Turn it OFF for a small piece that
  /// should take only the width its own characters need: inside a Wrap, a
  /// fitted box claims the whole row and a three-part expression ends up
  /// stacked vertically.
  final bool fit;

  @override
  Widget build(BuildContext context) {
    final s = TextStyle(fontSize: fontSize, color: AppColors.charcoal);
    final math = Math.tex(
      latex,
      textStyle: s,
      mathStyle: MathStyle.display,
      onErrorFallback: (_) => Text(latex, style: s),
    );
    if (!fit) return math;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: align ?? Alignment.center,
      child: Math.tex(
        latex,
        textStyle: s,
        mathStyle: MathStyle.display,
        onErrorFallback: (_) => Text(latex, style: s),
      ),
    );
  }
}
