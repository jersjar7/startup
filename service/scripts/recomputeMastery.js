// Recomputes every account's chapter mastery under the one formula
// (2026-09-20, docs/mobile/sync-audit.md fix 2): the desk half from desk
// problem history, the games half from phone events, the diagnostic kept.
// Run once after the deploy that introduced composeMastery; safe to re-run.
//
//   cd services/startup && set -a && . ./.env && set +a && node scripts/recomputeMastery.js
const { composeMastery, computeStudyMastery } = require('../mastery.js');
const { clearedGames, gamesHalf, gamesIn } = require('../gamesHalf.js');
const {
  userStatsCollection, problemHistoryCollection, reviewEventsCollection, client,
} = require('../db/connection');

async function main() {
  const users = await userStatsCollection.find({}, { projection: { email: 1, chapterMastery: 1 } }).toArray();
  let changed = 0;
  for (const u of users) {
    const before = u.chapterMastery || {};
    const [history, events] = await Promise.all([
      problemHistoryCollection.find({ email: u.email }).toArray(),
      reviewEventsCollection.find({ email: u.email, source: { $ne: 'web' } }, { projection: { chapterId: 1, itemId: 1, grade: 1, source: 1 } }).toArray(),
    ]);
    const chapters = new Set([...Object.keys(before), ...history.map((h) => h.topicId), ...events.map((e) => e.chapterId)].filter(Boolean));
    const after = {};
    for (const ch of chapters) {
      const cleared = clearedGames(ch, events.filter((e) => e.chapterId === ch));
      after[ch] = composeMastery({
        diagnosticScore: before[ch]?.diagnosticScore || 0,
        studyScore: computeStudyMastery(history.filter((h) => h.topicId === ch), ch),
        gamesHalf: gamesHalf(ch, cleared),
        gamesCleared: cleared.length,
        gamesTotal: Object.keys(gamesIn(ch)).length,
      });
    }
    const moved = [...chapters].filter((ch) => (before[ch]?.totalMastery || 0) !== after[ch].totalMastery);
    if (JSON.stringify(before) !== JSON.stringify(after)) {
      await userStatsCollection.updateOne({ email: u.email }, { $set: { chapterMastery: after } });
      changed++;
    }
    if (moved.length) {
      console.log(`${u.email}: ${moved.map((ch) => `${ch} ${before[ch]?.totalMastery || 0}->${after[ch].totalMastery}`).join(', ')}`);
    }
  }
  console.log(`done: ${users.length} accounts, ${changed} rewritten`);
}

main()
  .catch((e) => { console.error(e); process.exitCode = 1; })
  .finally(() => client.close());
