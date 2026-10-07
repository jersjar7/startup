const {
  userCollection,
  userStatsCollection,
  problemHistoryCollection,
  sessionLogCollection,
  sessionsCollection,
  diagnosticResultsCollection,
  funnelEventsCollection,
  reviewEventsCollection,
  paperFlagsCollection,
  gameFeedbackCollection,
} = require('./connection');

// Moving an account to a new email address.
//
// The address is the KEY in nine collections, not just a field on the user, so
// a rename that misses one orphans that part of somebody's history: their
// stats, their problem log, their sessions, their diagnostic, their flags.
// This list is the same one deleteAllUserData walks, for the same reason, and
// the two must stay in step. If a collection is added there, it belongs here.
//
// Purchases and exam attempts are keyed by userId and are untouched on purpose.
const EMAIL_KEYED = [
  ['userStats', userStatsCollection],
  ['problemHistory', problemHistoryCollection],
  ['sessionLog', sessionLogCollection],
  ['sessions', sessionsCollection],
  ['diagnosticResults', diagnosticResultsCollection],
  ['funnelEvents', funnelEventsCollection],
  ['reviewEvents', reviewEventsCollection],
  ['paperFlags', paperFlagsCollection],
  ['gameFeedback', gameFeedbackCollection],
];

/// Move every row keyed by [from] onto [to], then the user document itself.
///
/// Order matters. The children move FIRST and the user document LAST, so a
/// failure part way leaves the account still logged in under its old address
/// with the rename incomplete but retryable. Doing the user first would hand
/// them a working new address pointing at nothing, which looks exactly like
/// data loss.
///
/// Sessions are renamed rather than dropped, so changing an address does not
/// sign somebody out of the device they are doing it on.
///
/// Returns what moved, per collection, so the caller can log it. A rename is
/// rare and irreversible enough to be worth a line in the log.
async function changeAccountEmail(from, to, update) {
  const moved = {};
  for (const [name, collection] of EMAIL_KEYED) {
    const res = await collection.updateMany({ email: from }, { $set: { email: to } });
    moved[name] = res.modifiedCount;
  }
  const res = await userCollection.updateOne({ email: from }, { $set: update });
  moved.user = res.modifiedCount;
  return moved;
}

module.exports = { changeAccountEmail, EMAIL_KEYED };
