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
    ...(userId ? [
      purchasesCollection.deleteMany({ userId }),
      examAttemptsCollection.deleteMany({ userId }),
    ] : []),
  ]);
  await userCollection.deleteOne({ email });
}

module.exports = { deleteAllUserData };
