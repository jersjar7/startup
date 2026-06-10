import React from 'react';
import type { TextProps } from 'react-native';
import { Text } from '@/presentation/ui/Text';
import type { TextVariant } from '@/core/theme/typography';
import { latexToText } from './latexToText';

interface Props extends TextProps {
  children: string;
  variant?: TextVariant;
  color?: string;
}

// Drop-in <Text> that renders a string's inline `$...$` LaTeX as native Unicode.
export function MathText({ children, ...rest }: Props) {
  return <Text {...rest}>{latexToText(children)}</Text>;
}
