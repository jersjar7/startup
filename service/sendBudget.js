// Email send budget — keeps us under Resend's plan caps.
// Every successful send (transactional AND lifecycle) is counted via recordSend().
// Lifecycle jobs check canSendLifecycle() before each send and stop at a safe line,
// always leaving daily headroom for transactional email (verification / reset /
// student code), which must never be blocked. Counters live in the mailMeta
// collection keyed by UTC day/month (Resend's quota resets at UTC midnight).
//
// The numbers and the reasoning behind them live in sendBudgetPolicy.js, which
// has no database import so the policy can be tested on its own.

const { mailMetaCollection } = require('./db/connection.js');
const {
  lifecycleAllowed, blockReason,
  DAILY_CAP, MONTHLY_CAP, DAILY_RESERVE, DAILY_LIFECYCLE_MAX, MONTHLY_SOFT,
} = require('./sendBudgetPolicy.js');

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

// Lifecycle jobs stop silently when the budget runs out, which made a real
// squeeze invisible: the batch just sent fewer emails and said nothing. Log the
// first block of each UTC day so "the digest went quiet" is diagnosable.
let loggedBlockFor = null;

// Is there budget for one more LIFECYCLE email right now, without eating the
// transactional daily reserve or the monthly cap?
async function canSendLifecycle(now = new Date()) {
  const { day, month } = await counts(now);
  const ok = lifecycleAllowed(day, month);
  if (!ok && loggedBlockFor !== dayKey(now)) {
    loggedBlockFor = dayKey(now);
    console.warn(`[sendBudget] lifecycle paused — ${blockReason(day, month)}`);
  }
  return ok;
}

module.exports = {
  recordSend, counts, canSendLifecycle,
  DAILY_CAP, MONTHLY_CAP, DAILY_RESERVE, DAILY_LIFECYCLE_MAX, MONTHLY_SOFT,
};
