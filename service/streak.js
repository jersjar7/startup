// Streak calculation with freeze support.
// Users get 1 streak freeze per calendar week (resets Monday).
// If a user misses a day and has a freeze available, the streak is preserved.

function calculateStreak(currentStats, today) {
  let newStreak = currentStats.currentStreak || 0;
  let freezeUsedThisWeek = currentStats.freezeUsedThisWeek || null;

  if (currentStats.lastSessionDate === today) {
    // Already studied today — no change
    return {
      currentStreak: newStreak,
      longestStreak: Math.max(currentStats.longestStreak || 0, newStreak),
      freezeUsedThisWeek,
    };
  }

  const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];

  if (currentStats.lastSessionDate === yesterday) {
    // Consecutive day — increment
    newStreak = newStreak + 1;
  } else if (currentStats.lastSessionDate === null) {
    // First session ever
    newStreak = 1;
  } else {
    // Missed at least one day — check if freeze is available
    const dayBeforeYesterday = new Date(Date.now() - 2 * 86400000).toISOString().split('T')[0];
    const missedOnlyOneDay = currentStats.lastSessionDate === dayBeforeYesterday;
    const freezeAvailable = !isSameWeek(freezeUsedThisWeek, today);

    if (missedOnlyOneDay && freezeAvailable && newStreak > 0) {
      // Use freeze — preserve streak
      freezeUsedThisWeek = today;
      newStreak = newStreak + 1;
    } else {
      // Streak broken
      newStreak = 1;
    }
  }

  return {
    currentStreak: newStreak,
    longestStreak: Math.max(currentStats.longestStreak || 0, newStreak),
    freezeUsedThisWeek,
  };
}

// Check if two dates fall in the same ISO week
function isSameWeek(dateStr1, dateStr2) {
  if (!dateStr1 || !dateStr2) return false;
  const d1 = new Date(dateStr1);
  const d2 = new Date(dateStr2);
  const getWeek = (d) => {
    const jan1 = new Date(d.getFullYear(), 0, 1);
    const days = Math.floor((d - jan1) / 86400000);
    return Math.ceil((days + jan1.getDay() + 1) / 7);
  };
  return d1.getFullYear() === d2.getFullYear() && getWeek(d1) === getWeek(d2);
}

module.exports = { calculateStreak };
