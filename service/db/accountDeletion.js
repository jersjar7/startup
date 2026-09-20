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
} = require('./connection');

// Remove every trace of a user across all collections — email-keyed AND
// userId-keyed — so no orphaned PII is left behind. The user document is
// deleted LAST so a partial failure leaves the account usable/retryable rather
// than a half-deleted orphan.
async function deleteAllUserData(email, userId) {
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
