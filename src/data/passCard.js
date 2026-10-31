// The pass card: the one description both renderers draw from.
//
// There are two renderers because there are two surfaces and no shared drawing
// runtime: Canvas 2D in the browser, and a Flutter painter on the phone. They
// must produce the same image, so every number either of them needs lives here
// and nowhere else. The Dart side mirrors this file; mobile/test has a golden
// that compares the two outputs.
//
// Nothing here is per person. The card carries a name and a month and is
// otherwise identical for everybody, which is deliberate: bars that look like a
// personal record but are the same for everyone would make every card posted to
// LinkedIn claim a study record its owner never had. See
// docs/EXAM-OUTCOME-AND-PASS-CARD.md section 4.

// ── Source of the chapter list ────────────────────────────────────────────────
//
// NAMES ONLY. There are deliberately no question counts here.
//
// The counts in src/data/chapters.js are the NCEES FE Civil specification
// effective January 2014, which was superseded in July 2020 (all fifteen
// reconstruct from the 2014 document exactly, including three merged pairs).
// Printing them on something a student publishes under their own name would put
// a retired figure in public.
//
// The chapter NAMES are stable and are what the platform teaches, so they are
// safe. If counts are ever added here, they come from the current NCEES
// specification PDF in research/civil/, and this comment gets its date updated.
//
// Last checked: 2026-10-06.
export const PASS_CARD_CHAPTERS = [
  'Mathematics',
  'Probability & Statistics',
  'Ethics & Professional Practice',
  'Engineering Economics',
  'Statics',
  'Dynamics',
  'Mechanics of Materials',
  'Materials',
  'Fluid Mechanics',
  'Surveying',
  'Water Resources & Env.',
  'Structural Engineering',
  'Geotechnical Engineering',
  'Transportation Engineering',
  'Construction Engineering',
];

/// 110 is in both our sources and in the NCEES document, so it is safe to print
/// even though the per-chapter split is not.
export const TOTAL_QUESTIONS = 110;

// ── Geometry ─────────────────────────────────────────────────────────────────
//
// One design size, in design units. Both renderers scale from it rather than
// carrying their own numbers, so a change here moves both.
//
// 1200 x 627 is the link-preview ratio LinkedIn, X and Facebook all crop to.
// Exported at 2x so it stays sharp on a retina timeline.
export const CARD = {
  width: 1200,
  height: 627,
  exportScale: 2,
  pad: 52,

  // The engineering paper ground, which is the brand's floor everywhere else.
  paper: '#FDFCF8',
  gridFine: { step: 24, ink: 'rgba(44,44,44,0.055)' },
  gridBold: { step: 120, ink: 'rgba(44,44,44,0.10)' },

  // Left column: the claim.
  eyebrow: { size: 15, tracking: 2.6, y: 16 },
  headline: { size: 84, lineOne: 108, lineTwo: 188, nudge: -4 },
  name: { size: 37, y: 252, nudge: -2 },
  footnote: { size: 17, y: 283, text: 'Prepared with FE for Raccoons' },

  // A warm ember light in the top right corner, so the card is not flat
  // (owner, 2026-10-31). An ellipse centred at (cx, cy) with radii (rx, ry),
  // all as fractions of the card, fading from `ink` to clear.
  glow: { cx: 0.92, cy: 0.10, rx: 0.50, ry: 0.60, ink: 'rgba(232,104,58,0.18)' },

  // Right column: the fifteen chapters as a stack of books (owner, 2026-10-31,
  // from the exam simulation picture), chapter 15 on top with the raccoon
  // peeking over it, chapter 1 at the bottom. Replaced a plain list.
  // `x`/`top`/`width` place the stack; each book has a share of the width
  // (`w`, percent), a nudge right (`dx`), a tilt (`tilt`, degrees) and a
  // cover. Books overlap the one above by `overlap` of their height.
  stack: {
    x: 640, top: 94, width: 510, bookHeight: 30, overlap: 0.04, radius: 6,
    padLeft: 16, numberGap: 26, bandsFromRight: [22, 14], bandWidth: 3, bandInset: 0.24,
    caption: { x: 640, y: 579 },
    peek: { width: 118, along: 0.70, seat: 0.835 },
  },

  // The title block, read the way a drawing sheet is read. It runs under the
  // left column only; the stack takes the right.
  titleBlock: { fromBottom: 78, ruleWidth: 2.5, ruleEnd: 580, cellPitch: 180, labelY: 18, valueY: 41 },
};

/// Book covers, from the brand: charcoal, cream, sand, and ember for the top
/// book only. `band` is the two binding lines near the spine's end.
export const BOOK_COVERS = {
  charcoal: { fill: '#2C2C2C', text: '#FFF9F0', band: 'rgba(255,249,240,0.30)' },
  cream: { fill: '#FFFDF8', text: '#2C2C2C', band: 'rgba(44,44,44,0.22)' },
  sand: { fill: '#EADFCB', text: '#2C2C2C', band: 'rgba(44,44,44,0.22)' },
  ember: { fill: '#E8683A', text: '#FFFFFF', band: 'rgba(255,255,255,0.45)' },
};

/// One entry per chapter, in chapter order (index 0 is chapter 1, drawn at the
/// bottom). Hand-placed so the stack looks stacked by a person, not a machine.
export const BOOKS = [
  { w: 86, dx: 22, tilt: -1.1, cover: 'charcoal' },
  { w: 92, dx: 6, tilt: 0.8, cover: 'cream' },
  { w: 88, dx: 14, tilt: -0.5, cover: 'sand' },
  { w: 95, dx: 0, tilt: 0.4, cover: 'charcoal' },
  { w: 84, dx: 28, tilt: -0.9, cover: 'cream' },
  { w: 90, dx: 10, tilt: 0.6, cover: 'sand' },
  { w: 93, dx: 4, tilt: -0.3, cover: 'charcoal' },
  { w: 87, dx: 18, tilt: 0.7, cover: 'cream' },
  { w: 96, dx: 0, tilt: -0.4, cover: 'sand' },
  { w: 85, dx: 24, tilt: 0.9, cover: 'charcoal' },
  { w: 91, dx: 8, tilt: -0.6, cover: 'cream' },
  { w: 89, dx: 16, tilt: 0.3, cover: 'sand' },
  { w: 94, dx: 2, tilt: -0.7, cover: 'charcoal' },
  { w: 88, dx: 12, tilt: 0.5, cover: 'cream' },
  { w: 97, dx: 0, tilt: -0.2, cover: 'ember' },
];

// Ember is the only accent. Two accents on one surface is out, and this surface
// is small.
export const CARD_INK = {
  ink: '#2C2C2C',
  soft: '#6B6358',
  mute: '#A8A196',
  ember: '#E8683A',
};

/// What the card says, given an account. The only two things that vary.
///
/// [name] is the one field that has to come from the person. Account creation
/// has never collected a name, so for most accounts it is absent and has to be
/// asked for before the card can be drawn. Returns null for the name rather
/// than inventing one, and never falls back to the email address: the card is
/// the one thing they will publish under their own identity.
export function passCardData({ firstName, lastName, answeredAt, now = new Date() } = {}) {
  const full = [firstName, lastName].filter(Boolean).join(' ').trim();
  const when = answeredAt ? new Date(answeredAt) : now;
  return {
    // "EIT" is appended by the renderer, never typed, so nobody has to know the
    // abbreviation to get it right.
    name: full ? `${full}, EIT` : null,
    hasName: Boolean(full),
    discipline: 'Civil Engineering',
    result: 'Pass',
    when: when.toLocaleString('en-US', { month: 'long', year: 'numeric' }),
    chapters: PASS_CARD_CHAPTERS,
    totalQuestions: TOTAL_QUESTIONS,
  };
}

/// The filename they end up with in their downloads folder.
///
/// Prefixed with their name when there is one so it is findable among a hundred
/// other downloads, and just the plain name when there is not. The nameless
/// fallback cannot be "FE Civil" or the suffix stutters.
export function passCardFilename(data) {
  const who = (data?.name || '').replace(/[^A-Za-z0-9]+/g, '-').replace(/^-|-$/g, '');
  return who ? `${who}-FE-Civil-passed.png` : 'FE-Civil-passed.png';
}
