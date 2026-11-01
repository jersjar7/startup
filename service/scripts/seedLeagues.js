// Seeds everyone's starting league tier from their XP in the four full weeks
// before this one (ADR 0037, decision 5). Prints the cutoffs and how many
// land in each tier. Dry run by default; --apply writes, and only for
// students who have not finished a league week yet.
//
//   cd services/startup && set -a && . ./.env && set +a && node scripts/seedLeagues.js [--apply]
const { deriveAccount } = require('../derive.js');
const { allEvents } = require('../rederive.js');
const { reviewEventsCollection, client } = require('../db/connection');
const { seedLeagueTier } = require('../db/leagues');
const { isExcluded } = require('../internalAccounts.js');
const { seedTiers } = require('../leagues/seed.js');
const { TIER_IDS, tierName } = require('../leagues/config.js');
const { dayIn, sundayOf, addDays } = require('../leagues/week.js');

const APPLY = process.argv.includes('--apply');

async function main() {
  const thisSunday = sundayOf(dayIn(new Date()));
  const from = addDays(thisSunday, -28);
  const to = addDays(thisSunday, -1);
  const emails = (await reviewEventsCollection.distinct('email', { localDate: { $gte: from, $lte: to } }))
    .filter((e) => !isExcluded(e));

  const entries = [];
  for (const email of emails) {
    const d = deriveAccount({ events: await allEvents(email) });
    let xp = 0;
    for (const [day, v] of Object.entries(d.xpByDay)) if (day >= from && day <= to) xp += v;
    entries.push({ email, xp });
  }
  const { tiers, cutoffs } = seedTiers(entries);

  const counts = Object.fromEntries(TIER_IDS.map((t) => [t, 0]));
  for (const t of tiers.values()) counts[t]++;
  console.log(`[seed] XP from ${from} to ${to}: ${emails.length} students with activity, ${tiers.size} with XP`);
  for (const t of TIER_IDS) {
    console.log(`[seed] ${tierName(t).padEnd(9)} ${String(counts[t]).padStart(4)} students, from ${cutoffs[t] ?? '-'} XP`);
  }

  if (!APPLY) {
    console.log('[seed] dry run: nothing written. Run with --apply to write.');
    return;
  }
  let written = 0;
  for (const [email, tier] of tiers) if (await seedLeagueTier(email, tier)) written++;
  console.log(`[seed] wrote ${written} starting tiers`);
}

main()
  .catch((e) => { console.error(e); process.exitCode = 1; })
  .finally(() => client.close());
