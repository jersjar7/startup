// Step 1 of ADR 0018, read-only: rebuild every account from its log with the
// deriver and compare to the stored figures. Prints how many accounts agree
// on each figure and the largest disagreements, so the migration knows which
// event kinds the log still lacks. Writes nothing.
//
//   cd services/startup && set -a && . ./.env && set +a && node scripts/deriveCompare.js [--show 10]
const { deriveAccount } = require('../derive.js');
const {
  userStatsCollection, problemHistoryCollection, reviewEventsCollection, client,
} = require('../db/connection');

const show = Number((process.argv.indexOf('--show') > -1 && process.argv[process.argv.indexOf('--show') + 1]) || 8);

async function main() {
  const users = await userStatsCollection.find({}).toArray();
  const agree = { mastery: 0, days: 0, historyRows: 0, queue: 0, xp: 0, diagnostic: 0 };
  const diffs = [];
  let withEvents = 0;
  for (const u of users) {
    const [events, stored] = await Promise.all([
      reviewEventsCollection.find({ email: u.email }).toArray(),
      problemHistoryCollection.find({ email: u.email }).toArray(),
    ]);
    if (events.length) withEvents++;
    const d = deriveAccount({ events });

    // chapter mastery: every stored chapter's total vs derived
    const chapters = Object.keys(u.chapterMastery || {});
    const masteryOff = chapters.filter((ch) => (u.chapterMastery[ch].totalMastery || 0) !== (d.chapterMastery[ch]?.totalMastery || 0));
    if (!masteryOff.length) agree.mastery++;
    // study days: the stored list vs the log's days
    const storedDays = new Set(u.studyDays || []);
    const daysOff = storedDays.size === d.studyDays.length && d.studyDays.every((x) => storedDays.has(x));
    if (daysOff) agree.days++;
    // problem history: stored rows vs derived rows (counts)
    const storedById = Object.fromEntries(stored.map((r) => [r.problemId, r]));
    const rowsOff = Object.keys(storedById).filter((id) => !d.history[id]
      || d.history[id].timesCorrect !== (storedById[id].timesCorrect || 0)
      || d.history[id].timesIncorrect !== (storedById[id].timesIncorrect || 0));
    if (!rowsOff.length && Object.keys(d.history).length === stored.length) agree.historyRows++;
    const queueOff = Object.keys(storedById).filter((id) => !!storedById[id].reviewActive !== !!d.history[id]?.reviewActive);
    if (!queueOff.length) agree.queue++;
    // XP: the stored total vs the log's sessions, diagnostics, quick starts, exams and capped phone rounds
    const xpOff = (u.totalXp || 0) !== d.totalXp;
    if (!xpOff) agree.xp++;
    // the diagnostic floor: stored vs derived from the log's diagnostic and quick-start kinds
    const diagOff = chapters.filter((ch) => (u.chapterMastery[ch].diagnosticScore || 0) !== (d.chapterMastery[ch]?.diagnosticScore || 0));
    if (!diagOff.length) agree.diagnostic++;

    const score = masteryOff.length + (daysOff ? 0 : 1) + rowsOff.length + queueOff.length + (xpOff ? 1 : 0) + diagOff.length;
    if (score) diffs.push({ email: u.email.replace(/^(..).*(@.*)$/, '$1…$2'), events: events.length, stored: stored.length, derived: Object.keys(d.history).length,
      masteryOff: masteryOff.map((ch) => `${ch} ${u.chapterMastery[ch].totalMastery}/${d.chapterMastery[ch]?.totalMastery ?? '-'}`).slice(0, 3),
      days: `${storedDays.size}/${d.studyDays.length}`, xp: `${u.totalXp || 0}/${d.totalXp}`, rowsOff: rowsOff.length, queueOff: queueOff.length, diagOff: diagOff.length, score });
  }
  diffs.sort((a, b) => b.score - a.score);
  console.log(`accounts ${users.length}, with events ${withEvents}`);
  for (const k of ['mastery', 'days', 'historyRows', 'queue', 'xp', 'diagnostic']) console.log(`  agree on ${k.padEnd(12)} ${agree[k]} of ${users.length}`);
  console.log(`largest disagreements (${Math.min(show, diffs.length)} of ${diffs.length}):`);
  for (const x of diffs.slice(0, show)) console.log('  ' + JSON.stringify(x));
}

main()
  .catch((e) => { console.error(e); process.exitCode = 1; })
  .finally(() => client.close());
