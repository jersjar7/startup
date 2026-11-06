// Who gets the Exam Simulation through their school (ADR 0040).
//
// A college buys a yearly site license for one or more email domains. A student
// gets the simulation when one of their VERIFIED school addresses is on a
// domain an active license lists, and a seat is free or already theirs.
//
// Everything here is pure: the caller hands in the user, the licenses and the
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

/// A license may only list academic domains: the code flow that proves a
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

/// Exact match only. A subdomain counts only when the license lists it, so
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

/// Where a license stands, for the admin list.
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
///   licenses   licenses that MIGHT apply (any state); filtered here
///   claims     this user's seat claims ({ licenseId })
///   hintDomains domains we only GUESS are theirs (their profile school's);
///              they can point a student at verification, never grant access
///
/// Returns { access, via, license, domain, reason, needsClaim }:
///   via 'purchase'   bought it; nothing about schools matters
///   via 'school'     holds (or can take) a seat on an active license
///   reason, when access is false:
///     'none'          no purchase and no license for any verified domain
///     'unverified'    a license seems to cover them (their account domain or
///                     profile school) but no address on it is verified yet
///     'seats_full'    a license covers them but every seat is taken
///   needsClaim true   access via a license they do not hold a seat on yet
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

  // Not verified, but we have reason to think a license covers them: the
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

/// What the browser is told about a license. Never the contact or the notes.
function publicSchool(license) {
  if (!license) return null;
  return { name: license.schoolName, domains: license.domains || [], endsAt: license.endsAt };
}


// ── Admin input ────────────────────────────────────────────────────────────

const MAX_SEATS = 100000;
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function parseDate(v) {
  if (v == null || v === '') return null;
  // A bare YYYY-MM-DD from a date input is a whole day in UTC.
  const d = /^\d{4}-\d{2}-\d{2}$/.test(String(v)) ? new Date(`${v}T00:00:00Z`) : new Date(v);
  return Number.isFinite(d.getTime()) ? d : null;
}

/// Check and clean what the admin form sends. Returns { fields } or { error }.
/// partial: true (an edit) only checks the fields that were sent, then the
/// dates against the stored license (existing).
function parseLicenseInput(body = {}, { partial = false, existing = null } = {}) {
  const b = body || {};
  const out = {};
  const has = (k) => Object.prototype.hasOwnProperty.call(b, k);

  if (!partial || has('schoolName')) {
    const name = String(b.schoolName || '').trim();
    if (!name) return { error: 'School name is required.' };
    if (name.length > 120) return { error: 'School name is too long.' };
    out.schoolName = name;
  }
  if (!partial || has('domains')) {
    const raw = Array.isArray(b.domains) ? b.domains : String(b.domains || '').split(/[\s,;]+/);
    const domains = [];
    for (const r of raw) {
      if (!String(r || '').trim()) continue;
      const d = normalizeDomain(r);
      if (!d) return { error: `"${String(r).trim()}" is not a domain.` };
      if (!isLicensableDomain(d)) return { error: `${d} is not a school domain (.edu, .edu.xx or .ac.xx).` };
      if (!domains.includes(d)) domains.push(d);
    }
    if (!domains.length) return { error: 'Add at least one email domain, like byu.edu.' };
    if (domains.length > 20) return { error: 'At most 20 domains per license.' };
    out.domains = domains;
  }
  for (const k of ['startsAt', 'endsAt']) {
    if (!partial || has(k)) {
      const d = parseDate(b[k]);
      if (!d) return { error: `${k === 'startsAt' ? 'Start' : 'End'} date is required.` };
      out[k] = d;
    }
  }
  const starts = out.startsAt || existing?.startsAt;
  const ends = out.endsAt || existing?.endsAt;
  if (starts && ends && new Date(ends) <= new Date(starts)) return { error: 'The end date must be after the start date.' };
  if (!partial || has('seatCap')) {
    const n = Number(b.seatCap);
    if (!Number.isInteger(n) || n < 1 || n > MAX_SEATS) return { error: 'Seats must be a whole number from 1 to 100,000.' };
    out.seatCap = n;
  }
  if (!partial || has('contactName')) out.contactName = String(b.contactName || '').trim().slice(0, 120);
  if (!partial || has('contactEmail')) {
    const e = String(b.contactEmail || '').trim().toLowerCase();
    if (e && !EMAIL_RE.test(e)) return { error: 'Contact email does not look right.' };
    out.contactEmail = e;
  }
  if (!partial || has('notes')) out.notes = String(b.notes || '').trim().slice(0, 2000);
  return { fields: out };
}

/// A license as the admin page shows it.
function adminLicense(license, now = new Date()) {
  return {
    id: String(license._id),
    schoolName: license.schoolName,
    domains: license.domains || [],
    startsAt: license.startsAt,
    endsAt: license.endsAt,
    endedAt: license.endedAt || null,
    seatCap: license.seatCap,
    seatsUsed: Number(license.seatsUsed) || 0,
    seatsLeft: seatsLeft(license),
    state: licenseState(license, now),
    contactName: license.contactName || '',
    contactEmail: license.contactEmail || '',
    notes: license.notes || '',
    createdAt: license.createdAt,
  };
}

module.exports = {
  parseLicenseInput,
  adminLicense,
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
