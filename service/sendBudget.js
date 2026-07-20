// Email send budget — keeps us under Resend's FREE plan caps (100/day, 3000/month).
// Every successful send (transactional AND lifecycle) is counted via recordSend().
// Lifecycle jobs check canSendLifecycle() before each send and stop at a safe line,
// always leaving daily headroom for transactional email (verification / reset /
// student code), which must never be blocked. Counters live in the mailMeta
// collection keyed by UTC day/month (Resend's quota resets at UTC midnight).

const { mailMetaCollection } = require('./db/connection.js');

const DAILY_CAP = 100;            // Resend free: emails/day
const MONTHLY_CAP = 3000;         // Resend free: emails/month
const DAILY_RESERVE = 15;         // headroom kept for transactional email
const DAILY_LIFECYCLE_MAX = DAILY_CAP - DAILY_RESERVE;  // 85 — lifecycle stops here
const MONTHLY_SOFT = 2800;        // buffer under the monthly cap

const dayKey = (d = new Date()) => `day:${d.toISOString().slice(0, 10)}`;      // day:YYYY-MM-DD (UTC)
const monthKey = (d = new Date()) => `month:${d.toISOString().slice(0, 7)}`;   // month:YYYY-MM (UTC)

// Count one (or n) successful send(s). Never throws — a counter hiccup must not
// break the actual email flow.
async function recordSend(n = 1, now = new Date()) {
  try {
    await Promise.all([
      mailMetaCollection.updateOne({ _id: dayKey(now) }, { $inc: { count: n } }, { upsert: true }),
      mailMetaCollection.updateOne({ _id: monthKey(now) }, { $inc: { count: n } }, { upsert: true }),
    ]);
  } catch (e) {
    console.error('[sendBudget] recordSend failed:', e.message);
  }
}

async function counts(now = new Date()) {
  try {
    const [d, m] = await Promise.all([
      mailMetaCollection.findOne({ _id: dayKey(now) }),
      mailMetaCollection.findOne({ _id: monthKey(now) }),
    ]);
    return { day: d?.count || 0, month: m?.count || 0 };
  } catch (e) {
    console.error('[sendBudget] counts failed:', e.message);
    return { day: 0, month: 0 };
  }
}

// Is there budget for one more LIFECYCLE email right now, without eating the
// transactional daily reserve or the monthly cap?
async function canSendLifecycle(now = new Date()) {
  const { day, month } = await counts(now);
  return day < DAILY_LIFECYCLE_MAX && month < MONTHLY_SOFT;
}

module.exports = {
  recordSend, counts, canSendLifecycle,
  DAILY_CAP, MONTHLY_CAP, DAILY_RESERVE, DAILY_LIFECYCLE_MAX, MONTHLY_SOFT,
};
