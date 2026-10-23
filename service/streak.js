// "Days studied": a CUMULATIVE count of the distinct calendar days a user has
// studied. Every new study day adds 1 and it NEVER resets. A gap doesn't erase
// your effort; the number only ever goes up. This deliberately replaces the old
// consecutive-day streak (with weekly freeze), which was a daily-habit mechanic
// that silently reset on the sporadic/weekly studier we want to encourage.
//
// Contract: callers pass the user's stats (with the PREVIOUS lastSessionDate
// and the studyDays list), call this, then set lastSessionDate to the
// returned one. `today` is the STUDENT's calendar day (studyDays.js dayFor):
// since 2026-09-20 every writer dates the day by the client's clock, so one
// evening is one day on every surface. A day already in the list never ticks
// again. Return shape: currentStreak = the cumulative count; longestStreak
// retained for back-compat; freezeUsedThisWeek passed through, now unused.
function calculateStreak(currentStats, today) {
  const count = currentStats.currentStreak || 0;
  const freezeUsedThisWeek = currentStats.freezeUsedThisWeek || null;
  const last = currentStats.lastSessionDate || null;
  // The day never moves backwards: an offline day synced late keeps the
  // newest day as the last one.
  const lastSessionDate = last && last > today ? last : today;

  // Already counted: today is the last day, or it is already in the list of
  // days (a phone round after a web session on the same evening, or an
  // offline day synced after a newer one).
  const days = Array.isArray(currentStats.studyDays) ? currentStats.studyDays : [];
  if (last === today || days.includes(today)) {
    return {
      currentStreak: count,
      longestStreak: Math.max(currentStats.longestStreak || 0, count),
      freezeUsedThisWeek,
      lastSessionDate,
    };
  }

  // Any new calendar day (consecutive OR after a gap) adds one. Never resets.
  const newCount = count + 1;
  return {
    currentStreak: newCount,
    longestStreak: Math.max(currentStats.longestStreak || 0, newCount),
    freezeUsedThisWeek,
    lastSessionDate,
  };
}

/// How many days in a row end on the last day studied, from the list of
/// study days ('YYYY-MM-DD', the student's own calendar). Only a greeting:
/// Profile says "5 days running" when this is 3 or more and the last day is
/// today or yesterday, and says nothing about a run that broke. The number
/// that counts stays the cumulative one above, which never resets (owner,
/// 2026-10-16).
function runToLastDay(studyDays) {
  const days = [...new Set(Array.isArray(studyDays) ? studyDays : [])].sort();
  if (days.length === 0) return 0;
  const at = (d) => Date.parse(`${d}T00:00:00Z`);
  let run = 1;
  for (let i = days.length - 1; i > 0; i--) {
    if (at(days[i]) - at(days[i - 1]) !== 86400000) break;
    run++;
  }
  return run;
}

module.exports = { calculateStreak, runToLastDay };
