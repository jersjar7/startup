const { waitlistCollection } = require('./connection');

// The PE waitlist (see ../waitlist.js). One row per address and exam.

/**
 * Adds a signup. A new row keeps its source and unsubscribe token for good;
 * joining again only updates when they plan to sit it, and turns their
 * emails back on. Returns { isNew }.
 */
async function joinWaitlist(entry, unsubToken) {
  const { email, exam, when, ...source } = entry;
  const set = { updatedAt: new Date(), optedOut: false };
  if (when) set.when = when;
  const r = await waitlistCollection.updateOne(
    { email, exam },
    { $set: set, $setOnInsert: { email, exam, ...source, ...(when ? {} : { when: null }), unsubToken, createdAt: new Date() } },
    { upsert: true },
  );
  return { isNew: r.upsertedCount > 0 };
}

/** Turns off waitlist emails for the row with this token. True if one matched. */
async function leaveWaitlist(unsubToken) {
  const r = await waitlistCollection.updateOne({ unsubToken }, { $set: { optedOut: true, optedOutAt: new Date() } });
  return r.matchedCount > 0;
}

/** Every row without addresses or tokens, for the admin summary. */
async function listWaitlistForSummary() {
  return waitlistCollection.find({}, { projection: { _id: 0, exam: 1, when: 1, channel: 1, optedOut: 1, hasFeAccount: 1, createdAt: 1 } }).toArray();
}

module.exports = { joinWaitlist, leaveWaitlist, listWaitlistForSummary };
