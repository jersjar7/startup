// Who still gets the weekly digest.
//
// Pulled out of the job so the rule can be tested without a database, the same
// way sendBudgetPolicy.js is.
//
// Why this exists. The digest went to every verified address that had not opted
// out, which was 394 people spread over seven days: 56 a day against a lifecycle
// ceiling of 65. It was consuming the entire daily send budget on the free
// Resend tier, leaving about nine a day for welcomes, verification reminders,
// exam countdowns, win-backs and the exam outcome question. Measured on
// 2026-10-06: 94 of those 394 had never completed a single study session, and
// had been receiving a weekly summary of nothing since they signed up.
//
// Cutting to 45 days of activity takes it to 190 people, 27 a day, and frees
// about 29 a day (owner's call, 2026-10-06).

/// How recently somebody must have studied to still be sent a digest.
///
/// Not a hard product rule, a budget one. If the send budget stops being the
/// constraint this can widen again, which is why it is one number in one place.
const DIGEST_ACTIVE_DAYS = 45;

/// The cutoff a session must be newer than.
function digestActiveSince(now = new Date(), days = DIGEST_ACTIVE_DAYS) {
  return new Date(now.getTime() - days * 86400000);
}

/// Whether this person is still in the digest audience.
///
/// Takes the set of recently active addresses rather than looking each one up:
/// one query for the whole batch instead of one per user, and it keeps this
/// function pure.
///
/// A digest is a summary of your week. Somebody who has not studied in six
/// weeks does not have a week to summarise, so this is not only a budget cut.
function inDigestAudience(user, activeEmails) {
  if (!user?.email) return false;
  if (user.emailVerified !== true) return false;
  if (user.lifecycleOptOut === true) return false;
  const set = activeEmails instanceof Set ? activeEmails : new Set(activeEmails || []);
  return set.has(user.email);
}

/// What the cut is expected to save, for the log line.
///
/// Printed on every run so a change in the audience is visible in the logs
/// rather than something to go and measure later.
function audienceNote(eligible, active) {
  const perDay = (n) => (n / 7).toFixed(1);
  return `digest audience ${active}/${eligible} active in ${DIGEST_ACTIVE_DAYS}d `
    + `(~${perDay(active)}/day, ~${perDay(eligible - active)}/day freed)`;
}

module.exports = {
  DIGEST_ACTIVE_DAYS,
  digestActiveSince,
  inDigestAudience,
  audienceNote,
};
