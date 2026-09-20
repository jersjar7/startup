// "Days studied" — a CUMULATIVE count of the distinct calendar days a user has
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

module.exports = { calculateStreak };
