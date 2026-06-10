import React from 'react';
import { Text as RNText, type TextProps, type TextStyle } from 'react-native';
import { useTheme } from '@/core/theme/useTheme';
import type { TextVariant } from '@/core/theme/typography';

interface Props extends TextProps {
  variant?: TextVariant;
  color?: string;
}

// All text goes through here so typography + color come from the theme.
export function Text({ variant = 'body', color, style, ...rest }: Props) {
  const theme = useTheme();
  const base = theme.textVariants[variant] as TextStyle;
  const tint = { color: color ?? theme.palette.charcoal };
  return <RNText {...rest} style={[base, tint, style]} />;
}
