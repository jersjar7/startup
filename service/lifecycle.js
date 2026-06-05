// Pure helpers for lifecycle-email scheduling. DB-free and timezone-aware so the
// "next morning" / weekday / inactivity logic is unit-testable on its own.

const TZ_DEFAULT = 'America/New_York';

// Calendar date (YYYY-MM-DD) of `d` in the given timezone.
function etDate(d, tz = TZ_DEFAULT) {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: tz, year: 'numeric', month: '2-digit', day: '2-digit',
  }).format(d);
}

// Hour (0–23) of `d` in the given timezone.
function etHour(d, tz = TZ_DEFAULT) {
  return Number(new Intl.DateTimeFormat('en-US', {
    timeZone: tz, hour: '2-digit', hourCycle: 'h23',
  }).format(d));
}

// Short weekday ('Sun'..'Sat') of `d` in the given timezone.
function etWeekday(d, tz = TZ_DEFAULT) {
  return new Intl.DateTimeFormat('en-US', { timeZone: tz, weekday: 'short' }).format(d);
}

// Welcome is due once the user has crossed into a later calendar day than they
// verified on — i.e. the morning AFTER verification, never the same moment.
function isWelcomeDue(verifiedAt, now, tz = TZ_DEFAULT) {
  if (!verifiedAt) return false;
  return etDate(new Date(verifiedAt), tz) < etDate(now, tz);
}

// Whole days between two instants (floored). Missing date => Infinity (treated
// as "infinitely inactive").
function daysSince(date, now) {
  if (!date) return Infinity;
  return Math.floor((now.getTime() - new Date(date).getTime()) / 86400000);
}

// Verify-email reminder is due the morning AFTER signup (same calendar rule as
// the welcome, but keyed on createdAt) — so someone who signs up but never
// verifies gets one nudge the next morning rather than silence.
function isVerifyReminderDue(createdAt, now, tz = TZ_DEFAULT) {
  if (!createdAt) return false;
  return etDate(new Date(createdAt), tz) < etDate(now, tz);
}

// Accounts left unverified this many days are purged (DB hygiene). The full
// account-deletion cascade runs, so no orphaned rows are left behind.
const STALE_UNVERIFIED_DAYS = 30;
function isStaleUnverified(createdAt, now, days = STALE_UNVERIFIED_DAYS) {
  return daysSince(createdAt, now) >= days;
}

// Whether the weekly digest should use the upbeat "active" copy vs the gentle
// re-engagement copy.
function digestIsActive({ weeklyXp = 0, problemsThisWeek = 0 } = {}) {
  return weeklyXp > 0 || problemsThisWeek > 0;
}

// Countdown milestones (days before the exam) we email at, plus exam day (0).
const EXAM_MILESTONES = [30, 14, 7, 3, 1, 0];

// Pick which milestone email to send today, given days-left and the milestones
// already sent. Returns { milestone, absorb } or null.
//   - Sends the milestone CLOSEST to the real days-left (smallest reached one),
//     so setting a date late doesn't fire "30 days" when only 5 remain.
//   - `absorb` is every reached-but-unsent milestone to mark done at once, so a
//     skipped larger milestone never fires on a later (smaller) day.
function examMilestoneToSend(daysLeft, sent = [], milestones = EXAM_MILESTONES) {
  if (daysLeft == null || daysLeft < 0) return null;
  const reached = milestones.filter((m) => m >= daysLeft && !sent.includes(m));
  if (reached.length === 0) return null;
  return { milestone: Math.min(...reached), absorb: reached };
}

module.exports = {
  TZ_DEFAULT, etDate, etHour, etWeekday, isWelcomeDue, daysSince, digestIsActive,
  EXAM_MILESTONES, examMilestoneToSend,
  isVerifyReminderDue, isStaleUnverified, STALE_UNVERIFIED_DAYS,
};
