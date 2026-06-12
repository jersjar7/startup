// Spaced-repetition interval scheduling for the WEB problemHistory rows.
//
// v1 (`nextInterval`) is the legacy binary model still served while
// SCHEDULER_V2 is off. v2 (`nextHistoryV2`) routes through the shared scheduler
// (service/shared/scheduler.js, parity-tested against the mobile mirror) so web
// and mobile schedule identically once flipped. Both are kept pure and DB-free
// so the rule is testable on its own; db/stats.js persists the result.

const shared = require('./shared/scheduler');

const MAX_INTERVAL_DAYS = 30;
const EASE_FACTOR = 2.5;

/**
 * v1 — next review interval in days (legacy binary model).
 * @param {number} prevInterval - the previous interval (days); 0/undefined treated as 1.
 * @param {boolean} isCorrect - whether the latest answer was correct.
 */
function nextInterval(prevInterval, isCorrect) {
  if (!isCorrect) return 1;
  const base = prevInterval && prevInterval > 0 ? prevInterval : 1;
  return Math.min(Math.round(base * EASE_FACTOR), MAX_INTERVAL_DAYS);
}

/**
 * v2 — next problemHistory scheduling fields via the shared 3-grade SM-2.
 * Seeds ease/reps/lapses from a possibly-legacy row, grades the answer
 * (web is binary, so isCorrect -> gotIt/forgot), and returns the fields to
 * persist plus the yyyy-mm-dd nextReview derived from dueAt.
 * @param {object|null} existing - the existing problemHistory row (or null).
 * @param {boolean} isCorrect
 * @param {number} now - epoch ms (injected for testability).
 */
function nextHistoryV2(existing, isCorrect, now) {
  const state = shared.seedState(existing || {});
  const grade = isCorrect ? 'gotIt' : 'forgot';
  const next = shared.nextSchedule(state, grade, now);
  return {
    interval: next.intervalDays,
    ease: next.ease,
    reps: next.reps,
    lapses: next.lapses,
    nextReview: new Date(next.dueAt).toISOString().split('T')[0],
  };
}

module.exports = { nextInterval, nextHistoryV2, MAX_INTERVAL_DAYS, EASE_FACTOR };
