// Design tokens — the single source of color/space/shape for the app.
// Mirrors docs/mobile/visual-language.md ("calm canvas, confident color").
// Nothing in the UI hard-codes a hex value; it all comes from here.

export const palette = {
  cream: '#FFF9F0',
  creamDark: '#F5EDE0',
  charcoal: '#2C2C2C',
  ink2: '#6B6358',
  ink3: '#9C9488',
  ink4: '#BCB3A6',

  ember: '#E8683A',
  emberBg: '#FEF0EA',
  emberInk: '#B8431C',

  sunbeam: '#F5B731',
  sunbeamBg: '#FEF7E0',
  sunbeamInk: '#C28800',

  forest: '#2D7A5F',
  forestBg: '#E8F5EE',
  forestInk: '#1F5A44',

  error: '#D64045',
  errorBg: '#FBEAEA',
  white: '#FFFFFF',
  line: 'rgba(44,44,44,0.09)',
} as const;

export const spacing = { xs: 4, sm: 8, md: 16, lg: 24, xl: 32, xxl: 48 } as const;

export const radius = { chip: 6, control: 10, card: 16, hero: 20, pill: 24 } as const;

export const shadow = {
  card: {
    shadowColor: '#2C2C2C',
    shadowOpacity: 0.06,
    shadowRadius: 24,
    shadowOffset: { width: 0, height: 8 },
    elevation: 3,
  },
  emberButton: {
    shadowColor: '#E8683A',
    shadowOpacity: 0.28,
    shadowRadius: 16,
    shadowOffset: { width: 0, height: 6 },
    elevation: 4,
  },
} as const;

export type Palette = typeof palette;
