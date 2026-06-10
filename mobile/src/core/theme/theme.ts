// The assembled theme object passed through React context.

import { palette, spacing, radius, shadow } from './tokens';
import { textVariants, fontFamily } from './typography';

export const theme = {
  palette,
  spacing,
  radius,
  shadow,
  textVariants,
  fontFamily,
} as const;

export type Theme = typeof theme;
