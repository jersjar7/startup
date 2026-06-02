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

// Whether the weekly digest should use the upbeat "active" copy vs the gentle
// re-engagement copy.
function digestIsActive({ weeklyXp = 0, problemsThisWeek = 0 } = {}) {
  return weeklyXp > 0 || problemsThisWeek > 0;
}

module.exports = {
  TZ_DEFAULT, etDate, etHour, etWeekday, isWelcomeDue, daysSince, digestIsActive,
};
