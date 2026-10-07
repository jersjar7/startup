// Searching the school directory.
//
// Why this exists. school.js says a dropdown was rejected because "there are
// hundreds of accredited civil programmes and no list anyone would scroll",
// which is true of a dropdown and not of a typeahead. Free text was tried and
// measured on 2026-10-07: 19 users had given a school and there were 19
// distinct names. Nothing grouped with anything. The list contained both "UCI"
// and "University of California, Irvine" as separate institutions, plus
// "Arizona state university" and "NCSU 2012", where somebody typed their
// graduation year into the school field.
//
// That is not a weak signal, it is no signal, and a cohort report cannot be
// built on it. normalizeSchoolName cannot rescue it either: its grouping key
// strips "university", "of" and "at", so "UCI" keys to "uci" and the full name
// keys to "california irvine", and the two can never meet.
//
// So: suggest canonical names, and keep free text underneath. The suggestion is
// what makes two students at one university land in one bucket. The free text
// is what stops a list we got wrong from blocking anybody.
//
// The directory is a SEED, not an authority. It covers the institutions most
// likely to be typed, with the abbreviations students actually use. It lives on
// the server rather than in the app so it can be corrected without shipping a
// build, which matters because it is certainly incomplete.

const DIRECTORY = require('./data/schools.json');

const MAX_RESULTS = 8;

/// Folded for matching: case, punctuation and spacing removed, so "Cal Poly",
/// "cal-poly" and "calpoly" are one thing. Deliberately NOT the grouping key
/// from school.js, which strips the words that distinguish one campus from
/// another.
function fold(s) {
  return String(s || '')
    .toLowerCase()
    .replace(/&/g, ' and ')
    .replace(/[^a-z0-9]+/g, '');
}

/// Every string that should find a given school.
function handlesFor(school) {
  return [school.name, ...(school.aka || [])];
}

const INDEX = DIRECTORY.map((school) => ({
  name: school.name,
  aka: school.aka || [],
  folded: handlesFor(school).map(fold),
  // The initials of the full name, so "ucsd" finds a campus even when the
  // abbreviation was never listed.
  initials: fold(
    school.name
      .split(/[\s,]+/)
      .filter((w) => w.length > 2 && !/^(of|the|at|and|state)$/i.test(w))
      .map((w) => w[0])
      .join(''),
  ),
}));

/// Where the match landed, which is what the ranking is built from.
function scoreOf(entry, q) {
  let best = null;
  for (const f of entry.folded) {
    if (f === q) return 0;                       // exact
    if (f.startsWith(q)) best = Math.min(best ?? 9, 1);
    else if (f.includes(q)) best = Math.min(best ?? 9, 2);
  }
  if (best === null && entry.initials === q) best = 1;
  return best;
}

/// Suggestions for what somebody has typed so far.
///
/// Returns canonical names only. An empty result is not a failure: it means
/// they should type their own, which the caller must always allow.
function searchSchools(query, { limit = MAX_RESULTS } = {}) {
  const q = fold(query);
  // One or two characters match most of the directory and suggest nothing.
  if (q.length < 2) return [];

  const hits = [];
  for (const entry of INDEX) {
    const score = scoreOf(entry, q);
    if (score === null) continue;
    hits.push({ name: entry.name, score, length: entry.name.length });
  }
  // Best match first; among equals the shorter name, which is the main campus
  // more often than not.
  hits.sort((a, b) => a.score - b.score || a.length - b.length
    || a.name.localeCompare(b.name));
  return hits.slice(0, limit).map((h) => h.name);
}

/// The canonical name for something already stored, or null when it is not in
/// the directory. Used to fold the records collected before this existed.
function canonicalSchool(raw) {
  const q = fold(raw);
  if (!q) return null;
  for (const entry of INDEX) {
    if (entry.folded.includes(q) || entry.initials === q) return entry.name;
  }
  return null;
}

module.exports = {
  DIRECTORY,
  MAX_RESULTS,
  fold,
  searchSchools,
  canonicalSchool,
};
