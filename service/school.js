// Which institution a user belongs to, and when they graduate.
//
// Why this exists at all: a university will only ever buy a cohort report, and
// a cohort cannot be computed without knowing who is in it. On 2026-10-06 only
// 69 of 500 accounts could be attached to a school, because 380 people signed
// up with a Gmail address. Inferring the institution from the email domain
// captures about one in seven users, which is not a cohort, so it has to be
// asked.
//
// Deliberately a free text name rather than a dropdown. There are hundreds of
// accredited civil programmes and no list anyone would scroll. Normalisation
// happens here instead, so "BYU", "byu" and "Brigham Young University  " do not
// become three institutions in a report.
//
// Resolved means the same thing it means for acquisition (see acquisition.js):
// they answered OR they dismissed. Asked once, never again, server-side so the
// same person is not asked again on their phone.

const MAX_NAME = 120;

// Four years ahead covers an incoming freshman. "Already graduated" is a real
// answer for the repeat takers, who are a third of the FE Civil population and
// have no graduation year to give.
const GRAD_YEAR_MIN = 1960;
const GRAD_YEAR_AHEAD = 6;

function isSchoolResolved(user) {
  const s = user && user.school;
  if (!s) return false;
  return Boolean(s.name || s.dismissedAt);
}

/// Collapses the spelling differences that would otherwise split one school
/// into several rows of a report. Keeps the user's own capitalisation for
/// display; `key` is what grouping is done on.
function normalizeSchoolName(raw) {
  const name = String(raw || '')
    .replace(/\s+/g, ' ')
    .trim()
    .slice(0, MAX_NAME);
  if (!name) return null;
  const key = name
    .toLowerCase()
    .replace(/[.,'’]/g, '')
    .replace(/\b(the|university|univ|college|institute|of|at|state)\b/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
  // A name that is nothing but filler words ("the university of") is not a
  // school. Fall back to the raw lowercase so it still groups with itself.
  return { name, key: key || name.toLowerCase() };
}

/// The academic domain of an address, when there is one. This is the only
/// authoritative grouping key available: "BYU" and "Brigham Young University"
/// normalise to different names but both sit on byu.edu. A report groups by
/// domain where it exists and by name key otherwise, so the 69 accounts that
/// already carry a .edu address group perfectly and the rest group well enough.
function academicDomain(...emails) {
  for (const e of emails) {
    const at = String(e || '').lastIndexOf('@');
    if (at < 0) continue;
    const domain = String(e).slice(at + 1).toLowerCase().trim();
    if (/\.(edu|ac\.[a-z]{2})$/.test(domain)) return domain;
  }
  return null;
}

/// What a cohort report groups on, best key first.
function groupingKey(school) {
  if (!school) return null;
  return school.domain || school.key || null;
}

/// Which term they finish in. A May and a December graduate are a full exam
/// cycle apart, so the year alone blurs two different cohorts, but twelve
/// months is too much friction on a field people already skip. Four terms is
/// two taps and it is how universities actually talk (owner, 2026-10-06).
const GRAD_TERMS = ['winter', 'spring', 'summer', 'fall'];

/// undefined means invalid, null means not given. Optional on purpose: a
/// repeat taker who graduated years ago has no term to offer.
function validGraduationTerm(value) {
  if (value === null || value === undefined || value === '') return null;
  const term = String(value).toLowerCase().trim();
  return GRAD_TERMS.includes(term) ? term : undefined;
}

function validGraduationYear(value, now = new Date()) {
  if (value === null || value === undefined || value === '') return null;
  const year = Number(value);
  if (!Number.isInteger(year)) return undefined; // undefined means invalid
  const max = now.getUTCFullYear() + GRAD_YEAR_AHEAD;
  if (year < GRAD_YEAR_MIN || year > max) return undefined;
  return year;
}

module.exports = {
  isSchoolResolved,
  normalizeSchoolName,
  academicDomain,
  validGraduationTerm,
  GRAD_TERMS,
  groupingKey,
  validGraduationYear,
  MAX_NAME,
  GRAD_YEAR_MIN,
  GRAD_YEAR_AHEAD,
};
