// The nightly re-derive (ADR 0018): every account rebuilt from its log once
// a night, so the caches the surfaces read can never drift from the record.
// Runs in-process next to the lifecycle scheduler; NIGHTLY_REDERIVE_DISABLED=1
// turns it off. What moved is logged, never sent anywhere.
const DB = require('./database.js');
const { rederiveAccount } = require('./rederive.js');
const { etHour, etDate } = require('./lifecycle.js');

const RUN_HOUR_ET = 4; // 4 am Eastern: after the last west-coast evening, before the 8 am mail
const CHECK_INTERVAL_MS = 15 * 60 * 1000;
let lastRunDay = null;
let running = false;

async function rederiveEveryone() {
  const users = await DB.listUserStatsEmails();
  let changed = 0;
  const t0 = Date.now();
  for (const email of users) {
    try {
      const before = await DB.getUserStats(email);
      const d = await rederiveAccount(email);
      if ((before?.totalXp || 0) !== d.totalXp || (before?.currentStreak || 0) !== d.daysStudied) changed++;
    } catch (e) {
      console.error(`[nightly] ${email}: ${e.message}`);
    }
  }
  console.log(`[nightly] re-derived ${users.length} accounts in ${Math.round((Date.now() - t0) / 1000)}s, ${changed} moved`);
  return { accounts: users.length, changed };
}

async function tick(now = new Date()) {
  if (running) return;
  const day = etDate(now);
  if (etHour(now) !== RUN_HOUR_ET || lastRunDay === day) return;
  running = true;
  try {
    await rederiveEveryone();
    lastRunDay = day;
  } finally {
    running = false;
  }
}

function startNightlyRederive() {
  if (process.env.NIGHTLY_REDERIVE_DISABLED === '1') {
    console.log('[nightly] re-derive disabled (NIGHTLY_REDERIVE_DISABLED=1)');
    return;
  }
  setInterval(() => { tick().catch((e) => console.error('[nightly]', e.message)); }, CHECK_INTERVAL_MS);
  console.log(`[nightly] re-derive scheduled at ${RUN_HOUR_ET}:00 ET`);
}

module.exports = { startNightlyRederive, rederiveEveryone, tick };
