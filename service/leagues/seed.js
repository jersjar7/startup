// The first league week's starting tiers (ADR 0037, decision 5): regular
// students should not spend a month climbing out of Copper. Everyone who
// earned XP in the four weeks before leagues start is ranked by that XP and
// split into five equal bands, one per tier. Nobody else is seeded; a
// student with no recent XP starts in Copper like a new one.
const { TIER_IDS } = require('./config.js');

/**
 * entries: [{ email, xp }]. Returns { tiers: Map(email -> tier), cutoffs }
 * where cutoffs[t] is the lowest XP that landed in tier t.
 */
function seedTiers(entries) {
  const active = entries.filter((e) => e.xp > 0).sort((a, b) => a.xp - b.xp || a.email.localeCompare(b.email));
  const n = active.length;
  const tiers = new Map();
  const cutoffs = {};
  active.forEach((e, i) => {
    const tier = TIER_IDS[Math.min(TIER_IDS.length - 1, Math.floor((i * TIER_IDS.length) / n))];
    tiers.set(e.email, tier);
    if (cutoffs[tier] == null) cutoffs[tier] = e.xp;
  });
  return { tiers, cutoffs };
}

module.exports = { seedTiers };
