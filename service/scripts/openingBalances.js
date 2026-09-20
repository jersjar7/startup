// Step 2 of ADR 0018: write the past into the log, once.
//
// The log has held every answer since 2026-06-11 and every phone round since
// 2026-09-07. It never held the session boundaries (the bonus XP), the
// diagnostics, the quick-start reads, the simulation attempts, or the 428
// problem rows 13 accounts earned before the log existed. This writes each
// of those in as an event with a deterministic id, so a re-run adds nothing
// (unique index on email + eventId). Dry run by default; --write to write.
//
//   cd services/startup && set -a && . ./.env && set +a && node scripts/openingBalances.js [--write]
const {
  userStatsCollection, problemHistoryCollection, reviewEventsCollection, sessionLogCollection,
  diagnosticResultsCollection, examAttemptsCollection, userCollection, client,
} = require('../db/connection');
const { utcDay } = require('../studyDays.js');

const WRITE = process.argv.includes('--write');
const LOG_START = '2026-06-11';
const FAMILIARITY_CAP = 40;

async function main() {
  const users = await userStatsCollection.find({}, { projection: { email: 1 } }).toArray();
  const totals = { snapshot: 0, session: 0, quickstart: 0, diagnostic: 0, exam: 0, accounts: 0, inserted: 0, duplicates: 0 };
  for (const u of users) {
    const email = u.email;
    const docs = [];
    // 1. problem rows from before the log: one snapshot each, dated by the last answer
    const answered = new Set((await reviewEventsCollection.distinct('itemId', { email, kind: { $in: [null, 'answer'] } })).map((i) => String(i).split(':')[0]));
    const rows = await problemHistoryCollection.find({ email }).toArray();
    for (const r of rows) {
      if (answered.has(r.problemId)) continue;
      docs.push({ eventId: `open-row-${r._id}`, kind: 'snapshot', itemId: r.problemId, chapterId: r.topicId || null, source: 'web',
        ts: new Date(`${r.lastSeen || LOG_START}T12:00:00Z`).getTime(), localDate: r.lastSeen || LOG_START,
        data: { timesCorrect: r.timesCorrect || 0, timesIncorrect: r.timesIncorrect || 0, deskAttempts: r.deskAttempts ?? ((r.timesCorrect || 0) + (r.timesIncorrect || 0)),
          reviewActive: !!r.reviewActive, correctSinceMiss: r.correctSinceMiss || 0, nextReview: r.nextReview || null, interval: r.interval || 0, lastCorrectAt: r.lastCorrectAt || null } });
      totals.snapshot++;
    }
    // 2. every logged session: the boundary and its XP
    const sessions = await sessionLogCollection.find({ email }).toArray();
    for (const s of sessions) {
      const day = utcDay(s.completedAt) || LOG_START;
      const ts = new Date(s.completedAt || `${day}T12:00:00Z`).getTime();
      const base = { source: 'web', ts, localDate: day };
      if (s.type === 'practice' || s.type === 'review') {
        docs.push({ ...base, eventId: `open-session-${s._id}`, kind: 'session', chapterId: s.type === 'practice' ? s.topicId || null : null,
          data: { type: s.type, topicId: s.topicId || null, correct: s.correct || 0, total: s.totalProblems || 0, xp: s.xpEarned || 0, durationSeconds: s.durationSeconds ?? null } });
        totals.session++;
      } else if (s.type === 'quickstart') {
        const total = s.totalProblems || 0, correct = s.correct || 0;
        docs.push({ ...base, eventId: `open-quickstart-${s._id}`, kind: 'quickstart', chapterId: s.topicId || null,
          data: { chapterId: s.topicId || null, familiarity: total ? Math.min(Math.round((correct / total) * FAMILIARITY_CAP), FAMILIARITY_CAP) : 0, correct, total, xp: s.xpEarned || 0 } });
        totals.quickstart++;
      } else if (s.type === 'exam-simulation') {
        docs.push({ ...base, eventId: `open-exam-${s._id}`, kind: 'exam', chapterId: null,
          data: { totalCorrect: s.correct || 0, totalAttempted: s.totalProblems || 0, xp: s.xpEarned || 0, fromSessionLog: true } });
        totals.exam++;
      }
    }
    // 3. the diagnostics, with their chapter scores
    const diags = await diagnosticResultsCollection.find({ email }).toArray();
    for (const dgn of diags) {
      const day = utcDay(dgn.completedAt) || LOG_START;
      const chapterScores = Object.fromEntries(Object.entries(dgn.chapterScores || {}).map(([ch, v]) => [ch, v?.masterySeeded || 0]));
      docs.push({ eventId: `open-diagnostic-${dgn._id}`, kind: 'diagnostic', chapterId: null, source: 'web', ts: new Date(dgn.completedAt || `${day}T12:00:00Z`).getTime(), localDate: day,
        data: { chapterScores, correct: dgn.totalCorrect || 0, total: dgn.totalQuestions || 0, xp: dgn.xpEarned || 0, attemptNumber: dgn.attemptNumber || null } });
      totals.diagnostic++;
    }
    if (!docs.length) continue;
    totals.accounts++;
    if (WRITE) {
      const { insertReviewEvents } = require('../db/syncEvents');
      const fresh = await insertReviewEvents(email, docs);
      totals.inserted += fresh.length;
      totals.duplicates += docs.length - fresh.length;
    }
  }
  console.log(JSON.stringify({ mode: WRITE ? 'write' : 'dry-run', ...totals }));
}

main()
  .catch((e) => { console.error(e); process.exitCode = 1; })
  .finally(() => client.close());
