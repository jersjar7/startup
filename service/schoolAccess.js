// Who gets the Exam Simulation through their school (ADR 0040).
//
// A college buys a yearly site licence for one or more email domains. A student
// gets the simulation when one of their VERIFIED school addresses is on a
// domain an active licence lists, and a seat is free or already theirs.
//
// Everything here is pure: the caller hands in the user, the licences and the
// student's existing seat claims. The database half (looking those up and
// claiming a seat without a race) is in db/schoolLicenses.js.

const { isStudentEmail } = require('./pricing.js');

/// A domain as we store and compare it: trimmed, lowercased, no leading "@"
/// or trailing dot. Returns '' for anything that is not a plausible domain.
function normalizeDomain(d) {
  const s = String(d || '').trim().toLowerCase().replace(/^@+/, '').replace(/\.+$/, '');
  if (!/^[a-z0-9-]+(\.[a-z0-9-]+)+$/.test(s)) return '';
  if (s.split('.').some((label) => !label || label.startsWith('-') || label.endsWith('-'))) return '';
  return s;
}

/// The domain part of an address, normalized. '' when there is none.
function emailDomain(email) {
  const s = String(email || '').trim().toLowerCase();
  const at = s.lastIndexOf('@');
  if (at <= 0 || at !== s.indexOf('@')) return '';
  return normalizeDomain(s.slice(at + 1));
}

/// A licence may only list academic domains: the code flow that proves a
/// student owns a school inbox only mails academic addresses.
function isLicensableDomain(domain) {
  const d = normalizeDomain(domain);
  return !!d && isStudentEmail(`x@${d}`);
}

/// The school addresses this account has PROVEN it controls. A typed address
/// never counts; these are the two proofs the student price already accepts
/// (see qualifiesForStudent in pricing.js):
///   - a school address confirmed with the emailed 6-digit code, and
///   - the account address itself once its verification link was clicked.
function verifiedSchoolEmails(user) {
  if (!user) return [];
  const out = [];
  if (user.studentVerified === true && user.verifiedStudentEmail) {
    out.push(String(user.verifiedStudentEmail).trim().toLowerCase());
  }
  if (user.emailVerified === true && user.email) {
    out.push(String(user.email).trim().toLowerCase());
  }
  return [...new Set(out)];
}

/// The verified domains, in the same order (code-verified school email first).
function verifiedSchoolDomains(user) {
  return [...new Set(verifiedSchoolEmails(user).map(emailDomain).filter(Boolean))];
}

/// Exact match only. A subdomain counts only when the licence lists it, so
/// byu.edu never admits student.byu.edu by itself and byu.edu.evil.com or
/// evilbyu.edu never match anything.
function licenseCoversDomain(license, domain) {
  const d = normalizeDomain(domain);
  if (!d || !license || !Array.isArray(license.domains)) return false;
  return license.domains.some((x) => normalizeDomain(x) === d);
}

const toMs = (v) => (v == null ? NaN : new Date(v).getTime());

/// Live between startsAt (inclusive) and endsAt (exclusive), unless ended early.
function isLicenseActive(license, now = new Date()) {
  if (!license || license.endedAt) return false;
  const t = new Date(now).getTime();
  const s = toMs(license.startsAt);
  const e = toMs(license.endsAt);
  if (!Number.isFinite(s) || !Number.isFinite(e)) return false;
  return s <= t && t < e;
}

/// Where a licence stands, for the admin list.
function licenseState(license, now = new Date()) {
  if (!license) return 'unknown';
  if (license.endedAt) return 'ended';
  const t = new Date(now).getTime();
  if (toMs(license.startsAt) > t) return 'scheduled';
  if (toMs(license.endsAt) <= t) return 'expired';
  return 'active';
}

function seatsLeft(license) {
  const cap = Number(license?.seatCap) || 0;
  const used = Number(license?.seatsUsed) || 0;
  return Math.max(cap - used, 0);
}

/// The decision, from facts already in hand.
///
///   purchased  hasPurchased(userId): a completed (not refunded) purchase
///   user       the user document
///   licenses   licences that MIGHT apply (any state); filtered here
///   claims     this user's seat claims ({ licenseId })
///   hintDomains domains we only GUESS are theirs (their profile school's);
///              they can point a student at verification, never grant access
///
/// Returns { access, via, license, domain, reason, needsClaim }:
///   via 'purchase'   bought it; nothing about schools matters
///   via 'school'     holds (or can take) a seat on an active licence
///   reason, when access is false:
///     'none'          no purchase and no licence for any verified domain
///     'unverified'    a licence seems to cover them (their account domain or
///                     profile school) but no address on it is verified yet
///     'seats_full'    a licence covers them but every seat is taken
///   needsClaim true   access via a licence they do not hold a seat on yet
function decideSimAccess({
  purchased = false, user = null, licenses = [], claims = [], hintDomains = [], now = new Date(),
} = {}) {
  if (purchased) return { access: true, via: 'purchase', license: null, domain: null, reason: null, needsClaim: false };

  const active = (licenses || []).filter((l) => isLicenseActive(l, now));
  const claimed = new Set((claims || []).map((c) => String(c.licenseId)));
  const domains = verifiedSchoolDomains(user);

  let full = null;
  for (const domain of domains) {
    const matching = active.filter((l) => licenseCoversDomain(l, domain));
    // A seat already held wins over taking a new one.
    const held = matching.find((l) => claimed.has(String(l._id)));
    if (held) return { access: true, via: 'school', license: held, domain, reason: null, needsClaim: false };
    const open = matching.find((l) => seatsLeft(l) > 0);
    if (open) return { access: true, via: 'school', license: open, domain, reason: null, needsClaim: true };
    if (matching.length && !full) full = { license: matching[0], domain };
  }
  if (full) return { access: false, via: null, license: full.license, domain: full.domain, reason: 'seats_full', needsClaim: false };

  // Not verified, but we have reason to think a licence covers them: the
  // account address sits on a licensed domain, or the school on their profile
  // owns one (hintDomains). Never access, only a pointer: tell the student
  // their school covers them so they verify instead of paying.
  const hints = [
    user && user.emailVerified !== true ? emailDomain(user.email) : '',
    ...(hintDomains || []).map(normalizeDomain),
  ].filter(Boolean);
  for (const domain of hints) {
    const lic = active.find((l) => licenseCoversDomain(l, domain));
    if (lic) return { access: false, via: null, license: lic, domain, reason: 'unverified', needsClaim: false };
  }

  return { access: false, via: null, license: null, domain: null, reason: 'none', needsClaim: false };
}

/// What the browser is told about a licence. Never the contact or the notes.
function publicSchool(license) {
  if (!license) return null;
  return { name: license.schoolName, domains: license.domains || [], endsAt: license.endsAt };
}

module.exports = {
  normalizeDomain,
  emailDomain,
  isLicensableDomain,
  verifiedSchoolEmails,
  verifiedSchoolDomains,
  licenseCoversDomain,
  isLicenseActive,
  licenseState,
  seatsLeft,
  decideSimAccess,
  publicSchool,
};
