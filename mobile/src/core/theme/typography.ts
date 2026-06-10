// Typographic scale. Families map to DM Sans / Inter / JetBrains Mono — loaded
// via expo-font at startup (see README "Fonts"). Until loaded, RN falls back to
// the system font with the given weight, so the app still renders.

import type { TextStyle } from 'react-native';

export const fontFamily = {
  heading: 'DMSans',   // headings, buttons, overlines
  body: 'Inter',       // body + secondary text
  mono: 'JetBrainsMono', // numbers, formulas, data
} as const;

export const textVariants = {
  h1: { fontFamily: fontFamily.heading, fontSize: 30, fontWeight: '700', letterSpacing: -0.9, lineHeight: 32 },
  h2: { fontFamily: fontFamily.heading, fontSize: 19, fontWeight: '700', letterSpacing: -0.3, lineHeight: 24 },
  title: { fontFamily: fontFamily.heading, fontSize: 15, fontWeight: '600', lineHeight: 20 },
  body: { fontFamily: fontFamily.body, fontSize: 14, fontWeight: '400', lineHeight: 22 },
  bodyStrong: { fontFamily: fontFamily.body, fontSize: 14, fontWeight: '600', lineHeight: 22 },
  sub: { fontFamily: fontFamily.body, fontSize: 13, fontWeight: '400', lineHeight: 18 },
  overline: { fontFamily: fontFamily.heading, fontSize: 10.5, fontWeight: '600', letterSpacing: 1, lineHeight: 14, textTransform: 'uppercase' },
  mono: { fontFamily: fontFamily.mono, fontSize: 14, fontWeight: '700' },
} satisfies Record<string, TextStyle>;

export type TextVariant = keyof typeof textVariants;
