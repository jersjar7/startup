// One-time backfill of userStats.studyDays from the dated records that
// existed before the list did (2026-09-19). Safe to re-run: it only adds.
//
//   cd services/startup && set -a && . ./.env && set +a && node scripts/backfillStudyDays.js
//
// Sources: sessionLog (web sessions, server UTC day), reviewEvents (client
// local day), diagnosticResults, examAttempts. See ../studyDays.js.
const { collectStudyDays } = require('../studyDays.js');
const {
  userStatsCollection, sessionLogCollection, reviewEventsCollection,
  diagnosticResultsCollection, examAttemptsCollection, userCollection, client,
} = require('../db/connection');

async function main() {
  const users = await userStatsCollection.find({}, { projection: { email: 1, studyDays: 1, currentStreak: 1 } }).toArray();
  let touched = 0;
  for (const u of users) {
    const [sessions, events, diagnostics, user] = await Promise.all([
      sessionLogCollection.find({ email: u.email }, { projection: { completedAt: 1 } }).toArray(),
      reviewEventsCollection.find({ email: u.email }, { projection: { localDate: 1 } }).toArray(),
      diagnosticResultsCollection.find({ email: u.email }, { projection: { completedAt: 1, createdAt: 1, date: 1 } }).toArray(),
      userCollection.findOne({ email: u.email }, { projection: { _id: 1 } }),
    ]);
    const ids = user ? [user._id, String(user._id)] : [];
    const attempts = ids.length
      ? await examAttemptsCollection.find({ userId: { $in: ids } }, { projection: { createdAt: 1, startedAt: 1 } }).toArray()
      : [];
    const days = collectStudyDays({ sessions, events, diagnostics, attempts, existing: u.studyDays || [] });
    const fresh = days.filter((d) => !(u.studyDays || []).includes(d));
    if (fresh.length) {
      await userStatsCollection.updateOne({ email: u.email }, { $addToSet: { studyDays: { $each: fresh } } });
      touched++;
    }
    console.log(`${u.email}: count=${u.currentStreak || 0} days=${days.length} (+${fresh.length})`);
  }
  console.log(`done: ${users.length} users, ${touched} updated`);
}

main()
  .catch((e) => { console.error(e); process.exitCode = 1; })
  .finally(() => client.close());
