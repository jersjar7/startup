// What we keep when an account goes away.
//
// Deleting an account removes every trace of the person across every
// collection, which is correct and is not changing. The cost of that is that
// the account total silently drops and nothing says why. The owner noticed the
// number falling day to day with no way to find out what happened
// (2026-10-06).
//
// So: a tally, not a record of a person. One document per deletion carrying a
// date, a reason, and three facts that are only meaningful in aggregate. No
// email, no name, no id, nothing that could point back at who it was. A row
// here cannot be joined to anything, because everything it could be joined to
// has been deleted.
//
// Most of these are not users leaving. The lifecycle job purges unverified
// signups after 30 days and removes one to three every day, which is what was
// actually moving the total.

/// Why an account went away.
const DELETION_REASONS = {
  /// They asked. The one that matters for retention.
  user: 'user',
  /// Signed up, never verified, passed the 30-day stale window. Ours, not
  /// theirs, and the bulk of the volume.
  stalePurge: 'stale-purge',
};

/// How long the account existed, in whole days.
///
/// Bucketed rather than exact: a precise lifetime plus a precise date is close
/// to a fingerprint, and the question this answers is "did they leave quickly
/// or after months", which buckets answer just as well.
function ageBucket(createdAt, now = new Date()) {
  if (!createdAt) return 'unknown';
  const days = Math.floor((now - new Date(createdAt)) / 86400000);
  if (Number.isNaN(days) || days < 0) return 'unknown';
  if (days < 1) return 'same-day';
  if (days < 7) return 'under-a-week';
  if (days < 30) return 'under-a-month';
  if (days < 90) return 'under-three-months';
  return 'over-three-months';
}

/// The row to write, built from the user document before it is deleted.
///
/// Deliberately small. Every field here has to earn its place by answering a
/// question the owner would actually ask, because every field is one more thing
/// that survives a deletion.
function deletionRecord(user, { reason, now = new Date() } = {}) {
  if (!user) return null;
  return {
    at: now,
    // The calendar day, so a daily count needs no date arithmetic to read.
    day: now.toISOString().slice(0, 10),
    reason: DELETION_REASONS[reason] ? DELETION_REASONS[reason] : reason,
    ageBucket: ageBucket(user.createdAt, now),
    // Did they ever confirm the address. Separates "signed up and vanished"
    // from "used it and left", which are different problems.
    wasVerified: user.emailVerified === true,
    // A paying customer deleting is worth knowing about immediately, and it is
    // rare enough that it would otherwise disappear into the count.
    hadPurchased: Boolean(user.hasPurchased),
    // Which channel brought them, when we know. The only field with any
    // external reference, and it is a channel name like "search", never an id.
    source: user.acquisition?.channel || null,
  };
}

/// Whether a reason is one we know. An unknown reason is still recorded rather
/// than dropped: losing the count is worse than an unfamiliar label.
function isKnownReason(reason) {
  return Object.values(DELETION_REASONS).includes(reason)
    || Object.keys(DELETION_REASONS).includes(reason);
}

module.exports = { DELETION_REASONS, ageBucket, deletionRecord, isKnownReason };
