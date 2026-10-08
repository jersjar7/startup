// How much of the daily email allowance lifecycle mail is allowed to spend.
//
// Kept separate from sendBudget.js because that module opens the Mongo
// connection at import time; this one is pure arithmetic and can be tested
// directly. Same split as collectedSales.js.
//
// The rule: verification, password-reset and student-code email go out through
// sendEmail with NO budget check, because they must never be blocked. So the
// only thing standing between a new signup and a rejected verification email is
// lifecycle mail stopping early enough to leave room under the plan's daily cap.

// Resend Pro since 2026-10-07: 50,000 emails a month and NO daily limit.
//
// These numbers are no longer the provider's limits, they are ours. The daily
// one stays as a blast radius: a bug that mails every user in a loop should
// still hit a wall rather than spend the month's allowance in an hour. 1,000 a
// day against 539 accounts is roughly two emails per person per day, which no
// correct run will ever reach.
//
// The free tier's 100 a day was the real constraint before this: the weekly
// digest alone took 56 of it, the morning batch hit the 65 lifecycle ceiling
// most days, and the exam outcome ask got four sends out of a 65-person
// backlog because it sits last. That is what the money bought.
const DAILY_CAP = 1000;           // ours, not Resend's: a blast radius
const MONTHLY_CAP = 50000;        // Resend Pro: emails/month

// Headroom kept for transactional email.
//
// Sized from real demand, not a guess. The lifecycle batch runs at 08:00 ET,
// which is the MIDDLE of the UTC day the counter buckets by, so whatever the
// batch does not spend has to cover every signup from then until 00:00 UTC —
// the entire US daytime, when signups actually happen. On 2026-09-09 that tail
// needed 25 (23 signups plus resets and resends) against a reserve of 15, and
// the day closed at 103 sends against a 100/day plan cap.
//
// 35 covers that worst observed day with margin. It costs lifecycle volume (the
// daily shard of the weekly digest defers first), which is the right trade: a
// digest can slip a day, a verification email cannot.
// Still held back for verification and password reset, which must never fail
// because marketing filled the day. Verification does not actually check this
// budget, only records against it, so the reserve is belt and braces.
const DAILY_RESERVE = 100;
const DAILY_LIFECYCLE_MAX = DAILY_CAP - DAILY_RESERVE;  // 900 — lifecycle stops here
const MONTHLY_SOFT = 45000;       // buffer under the monthly cap

// Is there room for one more LIFECYCLE email, given what has already gone out
// today and this month?
function lifecycleAllowed(day, month) {
  return day < DAILY_LIFECYCLE_MAX && month < MONTHLY_SOFT;
}

// Why lifecycle stopped, for the log. Null when it did not stop.
function blockReason(day, month) {
  if (day >= DAILY_LIFECYCLE_MAX) {
    return `daily lifecycle limit reached (${day}/${DAILY_LIFECYCLE_MAX}, holding ${DAILY_RESERVE} back for verification and reset email)`;
  }
  if (month >= MONTHLY_SOFT) return `monthly soft cap reached (${month}/${MONTHLY_SOFT})`;
  return null;
}

module.exports = {
  lifecycleAllowed, blockReason,
  DAILY_CAP, MONTHLY_CAP, DAILY_RESERVE, DAILY_LIFECYCLE_MAX, MONTHLY_SOFT,
};
