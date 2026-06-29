// "Days studied" — a CUMULATIVE count of the distinct calendar days a user has
// studied. Every new study day adds 1 and it NEVER resets. A gap doesn't erase
// your effort; the number only ever goes up. This deliberately replaces the old
// consecutive-day streak (with weekly freeze), which was a daily-habit mechanic
// that silently reset on the sporadic/weekly studier we want to encourage.
//
// Contract unchanged: callers pass the user's stats with the PREVIOUS
// lastSessionDate, call this, then set lastSessionDate to `today`. The same-day
// guard prevents double-counting multiple sessions on one day. Return shape is
// kept identical (currentStreak = the cumulative count; longestStreak retained
// for back-compat; freezeUsedThisWeek passed through, now unused) so none of the
// 6 callers need to change.
function calculateStreak(currentStats, today) {
  const count = currentStats.currentStreak || 0;
  const freezeUsedThisWeek = currentStats.freezeUsedThisWeek || null;

  // Already counted today — no change.
  if (currentStats.lastSessionDate === today) {
    return {
      currentStreak: count,
      longestStreak: Math.max(currentStats.longestStreak || 0, count),
      freezeUsedThisWeek,
    };
  }

  // Any new calendar day (consecutive OR after a gap) adds one. Never resets.
  const newCount = count + 1;
  return {
    currentStreak: newCount,
    longestStreak: Math.max(currentStats.longestStreak || 0, newCount),
    freezeUsedThisWeek,
  };
}

module.exports = { calculateStreak };
