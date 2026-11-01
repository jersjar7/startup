// Weekly leagues (ADR 0037, docs/leagues-spec.md): the numbers that shape
// them, in one place. Group size and the zones can be changed from the
// environment without a release, so a quiet summer can shrink groups.

const num = (v, fallback) => {
  const n = Number(v);
  return Number.isInteger(n) && n > 0 ? n : fallback;
};

/** Weakest to strongest. A student's tier is one of these ids. */
const TIERS = [
  { id: 'timber', name: 'Timber' },
  { id: 'masonry', name: 'Masonry' },
  { id: 'concrete', name: 'Concrete' },
  { id: 'steel', name: 'Steel' },
  { id: 'titanium', name: 'Titanium' },
];

const LEAGUE = {
  groupSize: num(process.env.LEAGUE_GROUP_SIZE, 15),
  promote: num(process.env.LEAGUE_PROMOTE, 5),
  demote: num(process.env.LEAGUE_DEMOTE, 3),
  // A thin group (a late one, or a quiet week) never sends anyone down.
  minGroupForDemotion: num(process.env.LEAGUE_MIN_FOR_DEMOTION, 8),
  timezone: 'America/New_York',
  // The week closes at this hour on Sunday, Eastern, so a west-coast
  // Saturday evening still counts (midnight Pacific is 3 am Eastern).
  closeHourEt: 3,
};

const TIER_IDS = TIERS.map((t) => t.id);
const STARTING_TIER = TIER_IDS[0];

function tierName(id) {
  return (TIERS.find((t) => t.id === id) || TIERS[0]).name;
}

/** One tier up or down, held inside the list. */
function stepTier(id, by) {
  const i = Math.max(0, TIER_IDS.indexOf(id));
  return TIER_IDS[Math.min(TIER_IDS.length - 1, Math.max(0, i + by))];
}

module.exports = { TIERS, TIER_IDS, LEAGUE, STARTING_TIER, tierName, stepTier };
