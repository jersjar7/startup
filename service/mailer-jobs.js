// Lifecycle-email scheduler. A lightweight self-scheduling loop (no external
// cron) that, during the morning send hour, dispatches welcome / win-back /
// weekly-digest emails. All sends are guarded by per-user timestamps, so the
// loop is idempotent — running it twice in the same hour (or after a restart)
// never double-sends.

const { userCollection, userStatsCollection, sessionLogCollection } = require('./db/connection.js');
const { generateToken } = require('./crypto.js');
const { sendWelcomeEmail, sendWeeklyDigestEmail, sendWinbackEmail } = require('./email.js');
const {
  TZ_DEFAULT, etHour, etWeekday, isWelcomeDue, daysSince, digestIsActive,
} = require('./lifecycle.js');

const TZ = process.env.LIFECYCLE_TZ || TZ_DEFAULT;
const SEND_HOUR = Number(process.env.LIFECYCLE_HOUR) || 8;
const appUrl = process.env.APP_URL || 'https://fe4raccoons.com';
const MAX_PER_RUN = 300;
const SEND_GAP_MS = 250; // stay well under Resend's per-second rate limit
const INACTIVE_DAYS = 7;
const CHECK_INTERVAL_MS = 30 * 60 * 1000;

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const unsubUrl = (token) => `${appUrl}/api/email/unsubscribe/${token}`;

async function ensureUnsubToken(user) {
  if (user.unsubToken) return user.unsubToken;
  const token = generateToken();
  await userCollection.updateOne({ email: user.email }, { $set: { unsubToken: token } });
  return token;
}

// Weekly numbers for the digest + the user's weakest chapter for the focus line.
async function weeklyStatsFor(email) {
  const stats = await userStatsCollection.findOne({ email });
  const weekAgo = new Date(Date.now() - 7 * 86400000);
  const agg = await sessionLogCollection.aggregate([
    { $match: { email, completedAt: { $gte: weekAgo } } },
    { $group: { _id: null, problems: { $sum: { $ifNull: ['$totalProblems', 0] } } } },
  ]).toArray();
  const problems = agg[0]?.problems || 0;

  let masteryTo = null;
  let focusChapter = null;
  const cm = stats?.chapterMastery || {};
  const entries = Object.entries(cm).map(([k, v]) => [k, Number(v?.totalMastery || 0)]);
  if (entries.length) {
    masteryTo = Math.round(entries.reduce((a, [, v]) => a + v, 0) / entries.length);
    focusChapter = entries.slice().sort((a, b) => a[1] - b[1])[0][0];
  }
  return {
    weeklyXp: stats?.weeklyXp || 0,
    streak: stats?.currentStreak || 0,
    problems,
    masteryTo,
    focusChapter,
    lastSessionDate: stats?.lastSessionDate || null,
  };
}

async function sendWelcomes(now) {
  const users = await userCollection.find({
    emailVerified: true,
    verifiedAt: { $exists: true, $ne: null },
    welcomeSentAt: { $exists: false },
    lifecycleOptOut: { $ne: true },
  }).limit(MAX_PER_RUN).toArray();

  let sent = 0;
  for (const u of users) {
    if (!isWelcomeDue(u.verifiedAt, now, TZ)) continue;
    try {
      const token = await ensureUnsubToken(u);
      await sendWelcomeEmail(u.email, { unsubUrl: unsubUrl(token) });
      await userCollection.updateOne({ email: u.email }, { $set: { welcomeSentAt: new Date() } });
      sent += 1;
      await sleep(SEND_GAP_MS);
    } catch (e) {
      console.error('[lifecycle] welcome failed for', u.email, e.message);
    }
  }
  return sent;
}

async function sendWinbacks(now) {
  const users = await userCollection.find({
    emailVerified: true,
    winbackSentAt: { $exists: false },
    lifecycleOptOut: { $ne: true },
  }).limit(MAX_PER_RUN).toArray();

  let sent = 0;
  for (const u of users) {
    // Don't win-back brand-new accounts; wait until they've existed a week.
    if (daysSince(u.verifiedAt || u.createdAt, now) < INACTIVE_DAYS) continue;
    const stats = await weeklyStatsFor(u.email);
    const lastActivity = stats.lastSessionDate
      ? new Date(`${stats.lastSessionDate}T12:00:00Z`)
      : (u.verifiedAt || u.createdAt);
    if (daysSince(lastActivity, now) < INACTIVE_DAYS) continue;
    try {
      const token = await ensureUnsubToken(u);
      await sendWinbackEmail(u.email, { focusChapter: stats.focusChapter, unsubUrl: unsubUrl(token) });
      await userCollection.updateOne({ email: u.email }, { $set: { winbackSentAt: new Date() } });
      sent += 1;
      await sleep(SEND_GAP_MS);
    } catch (e) {
      console.error('[lifecycle] winback failed for', u.email, e.message);
    }
  }
  return sent;
}

async function sendWeeklyDigests(now) {
  const users = await userCollection.find({
    emailVerified: true,
    lifecycleOptOut: { $ne: true },
  }).limit(MAX_PER_RUN).toArray();

  let sent = 0;
  for (const u of users) {
    if (u.lastWeeklyAt && daysSince(u.lastWeeklyAt, now) < 3) continue; // already sent this week
    try {
      const s = await weeklyStatsFor(u.email);
      const active = digestIsActive({ weeklyXp: s.weeklyXp, problemsThisWeek: s.problems });
      const token = await ensureUnsubToken(u);
      await sendWeeklyDigestEmail(u.email, {
        active,
        weeklyXp: s.weeklyXp,
        streak: s.streak,
        problems: s.problems,
        masteryTo: s.masteryTo,
        focusChapter: s.focusChapter,
        unsubUrl: unsubUrl(token),
      });
      await userCollection.updateOne({ email: u.email }, { $set: { lastWeeklyAt: new Date() } });
      sent += 1;
      await sleep(SEND_GAP_MS);
    } catch (e) {
      console.error('[lifecycle] weekly failed for', u.email, e.message);
    }
  }
  return sent;
}

let running = false;

// Run one pass. Only acts during the morning send hour; weekly digests only on
// Sundays. Exposed for manual/triggered runs and tests.
async function runLifecycleEmails(now = new Date()) {
  if (process.env.LIFECYCLE_EMAILS_DISABLED === '1') return { skipped: 'disabled' };
  if (running) return { skipped: 'already-running' };
  running = true;
  try {
    if (etHour(now, TZ) !== SEND_HOUR) return { skipped: 'off-hour' };
    const welcome = await sendWelcomes(now);
    const winback = await sendWinbacks(now);
    const weekly = etWeekday(now, TZ) === 'Sun' ? await sendWeeklyDigests(now) : 0;
    if (welcome || winback || weekly) {
      console.log(`[lifecycle] sent welcome=${welcome} winback=${winback} weekly=${weekly}`);
    }
    return { welcome, winback, weekly };
  } catch (e) {
    console.error('[lifecycle] run failed:', e.message);
    return { error: e.message };
  } finally {
    running = false;
  }
}

function startScheduler() {
  if (process.env.LIFECYCLE_EMAILS_DISABLED === '1') {
    console.log('[lifecycle] scheduler disabled (LIFECYCLE_EMAILS_DISABLED=1)');
    return;
  }
  setInterval(() => { runLifecycleEmails().catch(() => {}); }, CHECK_INTERVAL_MS);
  // Kick once shortly after boot in case we start during the send hour.
  setTimeout(() => { runLifecycleEmails().catch(() => {}); }, 10 * 1000);
  console.log(`[lifecycle] scheduler started — send hour ${SEND_HOUR}:00 ${TZ}`);
}

module.exports = { runLifecycleEmails, startScheduler, weeklyStatsFor };
