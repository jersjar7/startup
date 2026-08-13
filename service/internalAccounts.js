// Accounts that are OURS, and must never be counted as real users.
//
// These are filtered out of the leaderboard, the funnel counts, the admin user
// list and the analytics dashboard, so that testing the product does not move
// the numbers we use to judge it.
//
// PLUS-ALIASES COUNT AS THE SAME ACCOUNT. `admin+test1@oqupa.com` is the same
// inbox as `admin@oqupa.com`, and Gmail-style plus-tagging is exactly how test
// accounts get made here. Matching the literal string alone meant the QA account
// was excluded from `scripts/baseline-report.js` (which strips plus-tags) while
// still counting as a real user everywhere on the server — two sources of truth
// disagreeing about whether the same account existed.
const EXCLUDED_EMAILS = (process.env.EXCLUDED_ACCOUNTS || 'admin@oqupa.com,qa-bot@fe4raccoons.com')
  .split(',')
  .map((s) => s.trim().toLowerCase())
  .filter(Boolean);

function escapeRe(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

// admin@oqupa.com  ->  ^admin(\+[^@]*)?@oqupa\.com$
// so admin+test1@, admin+qa@ and friends are all the same account.
function aliasPattern(email) {
  const at = email.lastIndexOf('@');
  if (at <= 0) return `^${escapeRe(email)}$`;
  const local = email.slice(0, at);
  const domain = email.slice(at + 1);
  return `^${escapeRe(local)}(\\+[^@]*)?@${escapeRe(domain)}$`;
}

// Matches an excluded address or any plus-alias of one. Guarded against an empty
// list, where an empty alternation would otherwise match EVERY email and hide
// every user on the site.
const EXCLUDED_PATTERN = EXCLUDED_EMAILS.length
  ? new RegExp(EXCLUDED_EMAILS.map(aliasPattern).join('|'), 'i')
  : /(?!)/;

// Drop-in replacement for `{ $nin: EXCLUDED_EMAILS }` in a Mongo query. A plain
// $nin can only ever compare literal strings, which is what let the aliases
// through. Valid in both find() and an aggregation $match.
const NOT_EXCLUDED = { $not: EXCLUDED_PATTERN };

function isExcluded(email) {
  const e = String(email || '').trim();
  return e !== '' && EXCLUDED_PATTERN.test(e);
}

module.exports = { EXCLUDED_EMAILS, EXCLUDED_PATTERN, NOT_EXCLUDED, isExcluded };
