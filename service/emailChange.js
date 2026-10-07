// Changing the address on an account.
//
// Why this exists. Until 2026-10-07 there was no way to change an email, and
// "resend verification" mailed the SAME address, so anybody who mistyped theirs
// at signup could never fix it. One real account has been stuck since 2 October
// on enail.sc.edu, a typo for email.sc.edu: that domain has no MX record and no
// A record, so the verification mail had nowhere to go and never will. They can
// still study, because verification gates nothing, but every email we send them
// is lost: the welcome, the digest, the countdowns, and the exam outcome ask.
//
// Pure rules only. The cascade that moves their data lives in
// db/accountEmail.js, because the address is the key in nine collections and a
// rename that misses one orphans somebody's entire history.

const MAX_EMAIL = 254; // RFC 5321

/// Why a change was refused, or null when it is allowed.
///
/// Returns the message the person reads, so the wording is testable. Each one
/// says what to do rather than what went wrong.
function emailChangeProblem({ current, next, password, normalize }) {
  if (!password) return 'Enter your password to change your email.';

  const raw = String(next || '').trim();
  if (!raw) return 'Enter the new email address.';
  if (raw.length > MAX_EMAIL) return 'That email address is too long.';

  const clean = normalize(raw);
  // Deliberately permissive: one @, something either side, a dot in the
  // domain. Anything stricter rejects real addresses, and the verification
  // email is the real test of whether an address works.
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(clean)) {
    return 'That does not look like an email address.';
  }
  if (clean === normalize(current)) {
    return 'That is already your email address.';
  }
  return null;
}

/// What the account looks like after the change.
///
/// Verification is reset, always. The new address is unproven even if the old
/// one was verified years ago, and leaving the flag set would mean we never
/// find out the new one is wrong either, which is the whole bug this fixes.
///
/// The unsubscribe and outcome tokens are deliberately NOT reset: they are
/// capabilities tied to the person, not the address, and rotating them would
/// break the links in any email already sitting in their inbox.
function emailChangeUpdate(nextEmail, { now = new Date() } = {}) {
  return {
    email: nextEmail,
    emailVerified: false,
    verifiedAt: null,
    emailChangedAt: now,
    // So the morning job can send the one-off reminder again for the new
    // address. Without clearing it, somebody who already had their single
    // reminder would never be nudged about the address they just fixed.
    verifyReminderSentAt: null,
  };
}

module.exports = { MAX_EMAIL, emailChangeProblem, emailChangeUpdate };
