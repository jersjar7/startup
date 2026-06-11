import React from 'react';
import { Text as RNText, type TextProps } from 'react-native';
import { Text } from '@/presentation/ui/Text';
import type { TextVariant } from '@/core/theme/typography';
import { useTheme } from '@/core/theme/useTheme';
import { latexToText } from './latexToText';

interface Props extends TextProps {
  children: string;
  variant?: TextVariant;
  color?: string;
}

// Drop-in <Text> that renders a string's inline `$...$` LaTeX as native
// Unicode. Math runs render in JetBrains Mono (brand rule: formulas are mono)
// while surrounding prose keeps the parent font.
export function MathText({ children, ...rest }: Props) {
  const theme = useTheme();
  const segments = children.split(/(\$[^$]+\$)/g).filter((s) => s.length > 0);
  return (
    <Text {...rest}>
      {segments.map((seg, i) =>
        seg.startsWith('$') && seg.endsWith('$') ? (
          <RNText key={i} style={{ fontFamily: theme.fontFamily.mono }}>
            {/* NBSP inside a math run — an expression must wrap as one unit,
                never mid-fraction ("(y₂ -" / "y₁)…") */}
            {latexToText(seg).trim().replace(/ /g, ' ')}
          </RNText>
        ) : (
          <React.Fragment key={i}>{latexToText(seg)}</React.Fragment>
        ),
      )}
    </Text>
  );
}
