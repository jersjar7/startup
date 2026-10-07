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
// The directory is 2,360 US institutions from the public university-domains
// dataset, with abbreviations layered on by hand because that dataset has none
// and "UCI" is what people actually type. Where a curated campus was missing
// from the dataset it was kept; where the dataset had the campus, it gained the
// abbreviations.
//
// It lives on the server rather than in the app so it can be corrected without
// shipping a build. Still not an authority: institutions merge, rename and open,
// so free text stays available underneath and the search returns nothing rather
// than guessing.
//
// Most entries carry their email domain, which is how [schoolForDomain] can
// name the institution of anybody who signed up with a .edu address without
// asking them at all.

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

/// Every email domain in the directory, pointing at its institution.
///
/// Built once. 2,337 of the 2,360 rows carry one, which is the whole reason the
/// dataset was worth taking over a hand-written list: school.js already pulls
/// the academic domain off an email address, and this turns that domain into a
/// name. Only 69 of 500 accounts had a knowable school on 2026-10-06, and
/// nobody has to be asked for a school this can already answer.
const BY_DOMAIN = (() => {
  const map = new Map();
  for (const school of DIRECTORY) {
    for (const domain of school.domains || []) {
      // First writer wins, so a shared domain cannot reassign an institution
      // out from under an earlier one.
      if (!map.has(domain)) map.set(domain, school.name);
    }
  }
  return map;
})();

/// The institution that owns an email domain, or null.
///
/// Exact matches first, then one level up, so "eng.berkeley.edu" still finds
/// Berkeley. Never guesses beyond that: two labels is where a domain stops
/// identifying one institution.
function schoolForDomain(domain) {
  const d = String(domain || '').toLowerCase().trim().replace(/^\.+|\.+$/g, '');
  if (!d) return null;
  if (BY_DOMAIN.has(d)) return BY_DOMAIN.get(d);
  const parts = d.split('.');
  for (let i = 1; i < parts.length - 1; i++) {
    const parent = parts.slice(i).join('.');
    if (BY_DOMAIN.has(parent)) return BY_DOMAIN.get(parent);
  }
  return null;
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
  schoolForDomain,
};
