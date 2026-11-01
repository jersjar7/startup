// Closes each league week (ADR 0037) and, once a day, records each group's
// places so the board can show who moved (ADR 0038). Runs in-process next to
// the lifecycle scheduler and the nightly re-derive; LEAGUES_DISABLED=1 turns
// leagues off (no closing here, no placing in rederive).
//
// A week closes at 3 am Eastern on Sunday, once midnight has passed on the
// west coast, so a Saturday evening in California still counts. It runs
// before the 4 am re-derive and the 8 am digest, which reports the result.
// Any later check also closes a week left open, so a server that was down on
// Sunday catches up when it comes back.
const { closeEndedWeeks, snapshotPlaces } = require('./leagues/league.js');
const { LEAGUE } = require('./leagues/config.js');
const { etHour, etWeekday } = require('./lifecycle.js');

const CHECK_INTERVAL_MS = 15 * 60 * 1000;
let running = false;

const leaguesDisabled = () => process.env.LEAGUES_DISABLED === '1';

/** True when the week that just ended may be closed. */
function mayClose(now) {
  return !(etWeekday(now) === 'Sun' && etHour(now) < LEAGUE.closeHourEt);
}

async function tick(now = new Date(), opts = {}) {
  if (running || leaguesDisabled()) return null;
  running = true;
  try {
    // The day's places, once per Eastern day, so the board can show who
    // moved since yesterday. A failure here never blocks the week close.
    await snapshotPlaces(now).catch((e) => console.error('[leagues] snapshot:', e.message));
    if (!mayClose(now)) return null;
    const s = await closeEndedWeeks(now, opts);
    if (s.groups || s.students) console.log(`[leagues] closed ${s.groups} groups: ${s.students} students, ${s.up} up, ${s.down} down`);
    return s;
  } finally {
    running = false;
  }
}

function startLeagueJobs() {
  if (leaguesDisabled()) {
    console.log('[leagues] disabled (LEAGUES_DISABLED=1)');
    return;
  }
  setInterval(() => { tick().catch((e) => console.error('[leagues]', e.message)); }, CHECK_INTERVAL_MS);
  console.log(`[leagues] week close scheduled Sundays ${LEAGUE.closeHourEt}:00 ET`);
}

module.exports = { startLeagueJobs, tick, mayClose, leaguesDisabled };
