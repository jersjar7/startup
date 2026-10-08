const { emailRetriesCollection } = require('./connection');
const { retryEntry } = require('../emailRetry.js');

// Queue and drain verification emails that failed to send.
//
// One row per address, replaced on each attempt, so a person who keeps failing
// does not accumulate rows. Removing the row is what marks it done.

/// Remember that this person still needs their verification email.
///
/// Never throws. It is called from a failure path, and a queue that cannot be
/// written must not turn a logged problem into a crashed request.
async function queueVerificationRetry(email, error, attempts = 0) {
  try {
    const row = retryEntry({ email, kind: 'verification', error, attempts });
    if (!row) {
      // Out of attempts, or an address that will never work. Drop the row so
      // the queue does not keep an entry nothing will ever act on.
      await emailRetriesCollection.deleteOne({ email, kind: 'verification' });
      return;
    }
    await emailRetriesCollection.updateOne(
      { email, kind: 'verification' },
      { $set: row },
      { upsert: true },
    );
    console.log(`[emailRetry] queued ${email} attempt ${row.attempts}: ${row.lastError}`);
  } catch (e) {
    console.error('[emailRetry] could not queue:', e.message);
  }
}

/// Everything due now.
function dueVerificationRetries(now = new Date(), limit = 50) {
  return emailRetriesCollection
    .find({ kind: 'verification', nextAt: { $lte: now } })
    .limit(limit)
    .toArray();
}

/// It went out. Stop tracking it.
function clearVerificationRetry(email) {
  return emailRetriesCollection.deleteOne({ email, kind: 'verification' });
}

module.exports = {
  queueVerificationRetry,
  dueVerificationRetries,
  clearVerificationRetry,
};
