// Spaced-repetition interval scheduling (SM-2 variant).
//
// On a correct answer the interval grows by the ease factor (capped); on a
// miss it resets to 1 day so the problem comes back tomorrow. Kept pure and
// separate from the database layer so the scheduling rule is testable on its own.

const MAX_INTERVAL_DAYS = 30;
const EASE_FACTOR = 2.5;

/**
 * Next review interval in days.
 * @param {number} prevInterval - the previous interval (days); 0/undefined treated as 1.
 * @param {boolean} isCorrect - whether the latest answer was correct.
 */
function nextInterval(prevInterval, isCorrect) {
  if (!isCorrect) return 1;
  const base = prevInterval && prevInterval > 0 ? prevInterval : 1;
  return Math.min(Math.round(base * EASE_FACTOR), MAX_INTERVAL_DAYS);
}

module.exports = { nextInterval, MAX_INTERVAL_DAYS, EASE_FACTOR };
