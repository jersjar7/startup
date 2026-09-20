// Re-derives every account from its log (ADR 0018): the one-time switch to
// the deriver's numbers, and the nightly drift check afterwards. Prints how
// many accounts changed and which figures moved; --dry-run writes nothing.
//
//   cd services/startup && set -a && . ./.env && set +a && node scripts/rederiveAll.js [--dry-run]
const { rederiveAccount } = require('../rederive.js');
const { deriveAccount } = require('../derive.js');
const { allEvents } = require('../rederive.js');
const { userStatsCollection, client } = require('../db/connection');

const DRY = process.argv.includes('--dry-run');

async function main() {
  const users = await userStatsCollection.find({}, { projection: { email: 1, totalXp: 1, currentStreak: 1, chapterMastery: 1 } }).toArray();
  let changed = 0; const moved = { xp: 0, days: 0, mastery: 0 };
  for (const u of users) {
    let d;
    if (DRY) d = deriveAccount({ events: await allEvents(u.email) });
    else d = await rederiveAccount(u.email);
    const xpMoved = (u.totalXp || 0) !== d.totalXp;
    const daysMoved = (u.currentStreak || 0) !== d.daysStudied;
    const masteryMoved = Object.keys({ ...(u.chapterMastery || {}), ...d.chapterMastery })
      .some((ch) => (u.chapterMastery?.[ch]?.totalMastery || 0) !== (d.chapterMastery[ch]?.totalMastery || 0));
    if (xpMoved) moved.xp++;
    if (daysMoved) moved.days++;
    if (masteryMoved) moved.mastery++;
    if (xpMoved || daysMoved || masteryMoved) changed++;
  }
  console.log(JSON.stringify({ mode: DRY ? 'dry-run' : 'write', accounts: users.length, changed, moved }));
}

main()
  .catch((e) => { console.error(e); process.exitCode = 1; })
  .finally(() => client.close());
