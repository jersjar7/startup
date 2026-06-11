import type { TextStyle } from 'react-native';

// Exact @expo-google-fonts family names (loaded in App.tsx). Custom fonts need
// the weight baked into the family name — fontWeight alone won't pick the file.
export const fonts = {
  headingBold: 'DMSans_700Bold',
  headingSemi: 'DMSans_600SemiBold',
  bodyRegular: 'Inter_400Regular',
  bodyMedium: 'Inter_500Medium',
  bodySemi: 'Inter_600SemiBold',
  mono: 'JetBrainsMono_700Bold',
} as const;

// Convenience map for spots that take a bare family (e.g. tab labels).
export const fontFamily = {
  heading: fonts.headingSemi,
  body: fonts.bodyRegular,
  mono: fonts.mono,
} as const;

export const textVariants = {
  h1: { fontFamily: fonts.headingBold, fontSize: 30, letterSpacing: -0.9, lineHeight: 34 },
  h2: { fontFamily: fonts.headingBold, fontSize: 19, letterSpacing: -0.3, lineHeight: 24 },
  // Question stems: content to READ, not headings — body face at medium
  // weight (bold display stems read shouty; panel + owner ratified).
  question: { fontFamily: fonts.bodyMedium, fontSize: 19, lineHeight: 28 },
  title: { fontFamily: fonts.headingSemi, fontSize: 15, lineHeight: 20 },
  body: { fontFamily: fonts.bodyRegular, fontSize: 14, lineHeight: 22 },
  bodyStrong: { fontFamily: fonts.bodySemi, fontSize: 14, lineHeight: 22 },
  sub: { fontFamily: fonts.bodyRegular, fontSize: 13, lineHeight: 18 },
  overline: {
    fontFamily: fonts.headingSemi,
    fontSize: 10.5,
    letterSpacing: 1,
    lineHeight: 14,
    textTransform: 'uppercase',
  },
  mono: { fontFamily: fonts.mono, fontSize: 14 },
} satisfies Record<string, TextStyle>;

export type TextVariant = keyof typeof textVariants;
