import 'package:flutter/material.dart';
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
    final base = style ??
        const TextStyle(fontSize: 15, height: 1.5, color: AppColors.charcoal);
    final parts = data.split(r'$');
    final spans = <InlineSpan>[];
    for (var i = 0; i < parts.length; i++) {
      if (i.isEven) {
        if (parts[i].isNotEmpty) spans.add(TextSpan(text: parts[i]));
      } else {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: Math.tex(
            parts[i],
            textStyle: base,
            mathStyle: MathStyle.text,
            onErrorFallback: (_) => Text(parts[i], style: base),
          ),
        ));
      }
    }
    return Text.rich(TextSpan(style: base, children: spans));
  }
}

/// A standalone formula (a full LaTeX expression), centered, for formula cards.
class MathBlock extends StatelessWidget {
  const MathBlock(this.latex, {super.key, this.fontSize = 17});

  final String latex;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final s = TextStyle(fontSize: fontSize, color: AppColors.charcoal);
    return Math.tex(
      latex,
      textStyle: s,
      mathStyle: MathStyle.display,
      onErrorFallback: (_) => Text(latex, style: s),
    );
  }
}
