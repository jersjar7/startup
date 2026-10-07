const {
  userCollection,
  userStatsCollection,
  problemHistoryCollection,
  sessionLogCollection,
  diagnosticResultsCollection,
  purchasesCollection,
  examAttemptsCollection,
  funnelEventsCollection,
  sessionsCollection,
  reviewEventsCollection,
  paperFlagsCollection,
  gameFeedbackCollection,
  deletionLogCollection,
} = require('./connection');
const { deletionRecord } = require('../deletionRecord.js');

// Remove every trace of a user across all collections — email-keyed AND
// userId-keyed — so no orphaned PII is left behind. The user document is
// deleted LAST so a partial failure leaves the account usable/retryable rather
// than a half-deleted orphan.
async function deleteAllUserData(email, userId, { reason = 'user' } = {}) {
  // The tally goes first, because every field it needs is about to be deleted.
  // It carries a date, a reason and three aggregate facts, never anything that
  // could point back at the person. See service/deletionRecord.js for why this
  // exists: without it the account total drops and nothing says why.
  //
  // Never allowed to block the deletion. Somebody asking to be removed is
  // removed, and a failure to count it is our problem.
  try {
    const user = await userCollection.findOne(
      { email },
      { projection: { createdAt: 1, emailVerified: 1, acquisition: 1, _id: 0 } },
    );
    const hadPurchased = userId
      ? (await purchasesCollection.countDocuments({ userId }, { limit: 1 })) > 0
      : false;
    const row = deletionRecord({ ...user, hasPurchased: hadPurchased }, { reason });
    if (row) await deletionLogCollection.insertOne(row);
  } catch (e) {
    console.error('[deletion] could not record the deletion:', e.message);
  }

  await Promise.all([
    userStatsCollection.deleteOne({ email }),
    problemHistoryCollection.deleteMany({ email }),
    sessionLogCollection.deleteMany({ email }),
    sessionsCollection.deleteMany({ email }),
    diagnosticResultsCollection.deleteMany({ email }),
    funnelEventsCollection.deleteMany({ email }),
    // The phone's log, its hand-offs and its feedback (missed until 2026-09-20).
    reviewEventsCollection.deleteMany({ email }),
    paperFlagsCollection.deleteMany({ email }),
    gameFeedbackCollection.deleteMany({ email }),
    ...(userId ? [
      purchasesCollection.deleteMany({ userId }),
      examAttemptsCollection.deleteMany({ userId }),
    ] : []),
  ]);
  await userCollection.deleteOne({ email });
}

module.exports = { deleteAllUserData };
