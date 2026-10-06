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

  // Right column: the index of what the exam covers.
  index: { x: 700, top: 72, rowHeight: 25.6, numberGap: 36, rule: 'rgba(44,44,44,0.10)' },

  // The title block, read the way a drawing sheet is read.
  titleBlock: { fromBottom: 78, ruleWidth: 2.5, cellPitch: 232, labelY: 18, valueY: 41 },
};

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
