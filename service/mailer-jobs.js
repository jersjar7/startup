// Lifecycle-email scheduler. A lightweight self-scheduling loop (no external
// cron) that, during the morning send hour, dispatches welcome / win-back /
// weekly-digest emails. All sends are guarded by per-user timestamps, so the
// loop is idempotent — running it twice in the same hour (or after a restart)
// never double-sends.

const { userCollection, userStatsCollection, sessionLogCollection, examAttemptsCollection } = require('./db/connection.js');
const { generateToken, hashToken } = require('./crypto.js');
const { deleteAllUserData } = require('./db/accountDeletion.js');
const {
  sendWelcomeEmail, sendWeeklyDigestEmail, sendWinbackEmail, sendExamCountdownEmail,
  sendVerifyReminderEmail, sendSimFollowupEmail,
} = require('./email.js');
const {
  TZ_DEFAULT, etHour, etWeekday, isWelcomeDue, daysSince, digestIsActive, examMilestoneToSend,
  isVerifyReminderDue, isStaleUnverified,
} = require('./lifecycle.js');
const { daysUntilExam } = require('./profile.js');
const { canSendLifecycle } = require('./sendBudget.js');

const TZ = process.env.LIFECYCLE_TZ || TZ_DEFAULT;
const SEND_HOUR = Number(process.env.LIFECYCLE_HOUR) || 8;
const appUrl = process.env.APP_URL || 'https://fe4raccoons.com';
const MAX_PER_RUN = 300;
const SEND_GAP_MS = 250; // stay well under Resend's per-second rate limit
const INACTIVE_DAYS = 7;
const CHECK_INTERVAL_MS = 30 * 60 * 1000;

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const unsubUrl = (token) => `${appUrl}/api/email/unsubscribe/${token}`;

// Spread the weekly digest evenly across the 7 weekdays instead of one big Sunday
// batch — each user has a stable "digest day" from a hash of their email, so we
// stay under Resend's free 100/day cap and everyone still gets exactly one/week.
const WEEKDAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
function digestDay(email) {
  let h = 5381;
  const s = String(email).toLowerCase();
  for (let i = 0; i < s.length; i++) h = ((h << 5) + h + s.charCodeAt(i)) >>> 0;
  return h % 7;
}

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
    diagnosticCompleted: stats?.diagnosticCompleted === true,
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
    if (!(await canSendLifecycle(now))) break; // out of daily/monthly send budget
    try {
      // Adaptive: if they already took the diagnostic, send the next-step email
      // (their weakest chapter) instead of nagging them to take it again.
      const stats = await weeklyStatsFor(u.email);
      const token = await ensureUnsubToken(u);
      await sendWelcomeEmail(u.email, {
        unsubUrl: unsubUrl(token),
        diagnosticDone: stats.diagnosticCompleted,
        focusChapter: stats.focusChapter,
      });
      await userCollection.updateOne({ email: u.email }, { $set: { welcomeSentAt: new Date() } });
      sent += 1;
      await sleep(SEND_GAP_MS);
    } catch (e) {
      console.error('[lifecycle] welcome failed for', u.email, e.message);
    }
  }
  return sent;
}

// Morning-after nudge for accounts that signed up but never verified. Sent once
// (guarded by verifyReminderSentAt), with a freshly issued verification token.
async function sendVerifyReminders(now) {
  const users = await userCollection.find({
    emailVerified: { $ne: true },
    verifyReminderSentAt: { $exists: false },
    lifecycleOptOut: { $ne: true },
  }).limit(MAX_PER_RUN).toArray();

  let sent = 0;
  for (const u of users) {
    if (!isVerifyReminderDue(u.createdAt, now, TZ)) continue;
    if (!(await canSendLifecycle(now))) break; // out of daily/monthly send budget
    try {
      const rawToken = generateToken();
      await userCollection.updateOne(
        { email: u.email },
        { $set: { verificationToken: hashToken(rawToken), verificationSentAt: new Date(), verifyReminderSentAt: new Date() } },
      );
      await sendVerifyReminderEmail(u.email, rawToken);
      sent += 1;
      await sleep(SEND_GAP_MS);
    } catch (e) {
      console.error('[lifecycle] verify reminder failed for', u.email, e.message);
    }
  }
  return sent;
}

// DB hygiene: delete accounts left unverified past the stale window. Full
// cascade so no orphaned rows remain. Anyone who verifies first drops out of the
// query, so only genuinely-abandoned signups are removed.
async function purgeStaleUnverified(now) {
  const users = await userCollection.find({
    emailVerified: { $ne: true },
  }).limit(MAX_PER_RUN).toArray();

  let purged = 0;
  for (const u of users) {
    if (!isStaleUnverified(u.createdAt, now)) continue;
    try {
      await deleteAllUserData(u.email, u.userId);
      purged += 1;
    } catch (e) {
      console.error('[lifecycle] purge failed for', u.email, e.message);
    }
  }
  return purged;
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
    if (!(await canSendLifecycle(now))) break; // out of daily/monthly send budget
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
  const todayIdx = WEEKDAYS.indexOf(etWeekday(now, TZ));
  const users = await userCollection.find({
    emailVerified: true,
    lifecycleOptOut: { $ne: true },
  }).limit(MAX_PER_RUN).toArray();

  let sent = 0;
  for (const u of users) {
    if (digestDay(u.email) !== todayIdx) continue;                     // only this user's assigned digest day
    if (u.lastWeeklyAt && daysSince(u.lastWeeklyAt, now) < 6) continue; // already sent this week
    if (!(await canSendLifecycle(now))) break;                         // out of daily/monthly send budget
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

async function sendExamCountdowns(now) {
  const users = await userCollection.find({
    emailVerified: true,
    examDate: { $exists: true, $ne: null },
    lifecycleOptOut: { $ne: true },
  }).limit(MAX_PER_RUN).toArray();

  let sent = 0;
  for (const u of users) {
    const daysLeft = daysUntilExam(u.examDate, now);
    const pick = examMilestoneToSend(daysLeft, u.examMilestonesSent || []);
    if (!pick) continue;
    if (!(await canSendLifecycle(now))) break; // out of daily/monthly send budget
    // Pitch the exam simulation to non-buyers who are ~2-4 weeks out (a milestone
    // send always lands inside 12-30 days). Once per user, guarded by simPitchedAt.
    const pitchSim = !u.examSimAccess && !u.simPitchedAt && daysLeft >= 12 && daysLeft <= 30;
    try {
      const stats = await weeklyStatsFor(u.email);
      const token = await ensureUnsubToken(u);
      await sendExamCountdownEmail(u.email, {
        daysLeft,
        readiness: stats.masteryTo,
        focusChapter: stats.focusChapter,
        unsubUrl: unsubUrl(token),
        simPitch: pitchSim,
        trackToken: token,
      });
      const merged = Array.from(new Set([...(u.examMilestonesSent || []), ...pick.absorb]));
      const update = { examMilestonesSent: merged };
      if (pitchSim) update.simPitchedAt = now;
      await userCollection.updateOne({ email: u.email }, { $set: update });
      sent += 1;
      await sleep(SEND_GAP_MS);
    } catch (e) {
      console.error('[lifecycle] exam countdown failed for', u.email, e.message);
    }
  }
  return sent;
}

// Post-purchase simulator follow-up. Sent once per buyer (guarded by
// simFollowupSentAt). Prefers the "first exam" recap once they've completed a
// sim; otherwise nudges ~48h after purchase. Gated by SIM_FOLLOWUP_ENABLED so
// the copy can be approved before any buyer receives it.
async function sendSimFollowups(now) {
  const users = await userCollection.find({
    examSimAccess: true,
    simFollowupSentAt: { $exists: false },
    lifecycleOptOut: { $ne: true },
  }).limit(MAX_PER_RUN).toArray();

  let sent = 0;
  for (const u of users) {
    const uid = u._id.toString();
    const done = await examAttemptsCollection.findOne({ userId: uid, status: 'completed' });
    let variant = null;
    let scorePct = null;
    if (done) {
      variant = 'firstExam';
      scorePct = done.overallPercentage != null ? Math.round(done.overallPercentage) : null;
    } else if (u.examSimPurchaseDate && daysSince(u.examSimPurchaseDate, now) >= 2) {
      variant = 'nudge';
    }
    if (!variant) continue;
    if (!(await canSendLifecycle(now))) break; // out of daily/monthly send budget
    try {
      const stats = await weeklyStatsFor(u.email);
      const token = await ensureUnsubToken(u);
      await sendSimFollowupEmail(u.email, {
        variant, scorePct, focusChapter: stats.focusChapter, unsubUrl: unsubUrl(token),
      });
      await userCollection.updateOne(
        { email: u.email },
        { $set: { simFollowupSentAt: new Date(), simFollowupVariant: variant } },
      );
      sent += 1;
      await sleep(SEND_GAP_MS);
    } catch (e) {
      console.error('[lifecycle] sim followup failed for', u.email, e.message);
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
    // Priority order: when the daily/monthly budget is tight, higher-priority
    // emails send first and lower-priority ones defer to the next day. (The
    // weekly digest now runs EVERY day, sending only each user's shard.)
    const welcome = await sendWelcomes(now);
    const verify = await sendVerifyReminders(now);
    const simFollow = process.env.SIM_FOLLOWUP_ENABLED === '1' ? await sendSimFollowups(now) : 0;
    const exam = await sendExamCountdowns(now);
    const weekly = await sendWeeklyDigests(now);
    const winback = await sendWinbacks(now);
    const purged = await purgeStaleUnverified(now);
    if (welcome || verify || winback || exam || weekly || simFollow || purged) {
      console.log(`[lifecycle] sent welcome=${welcome} verify=${verify} winback=${winback} exam=${exam} weekly=${weekly} simFollow=${simFollow} purged=${purged}`);
    }
    return { welcome, verify, winback, exam, weekly, simFollow, purged };
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
