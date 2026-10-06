// How many days of history the analytics page asks for.
//
// Pulled out of db/analytics.js so it can be tested without a database. The
// interesting case is "all", which is a word rather than a number on purpose:
// a fixed ceiling would have silently started truncating all-time once the
// platform was a year old, and nothing on the page would have said so.

const MIN_WINDOW = 7;

/// Ten years. High enough that it is never the thing that truncates a real
/// window, low enough that a bad query cannot ask for a million buckets.
const MAX_WINDOW = 3650;

const DEFAULT_WINDOW = 30;

function isAllTime(days) {
  return String(days).toLowerCase() === 'all';
}

/// The window in days.
///
/// [firstAccountAt] is when the earliest real account was created, used only
/// for the all-time case. Null means there are no accounts yet, which is not
/// an error: it just means there is no history to show.
function resolveWindow(days, { firstAccountAt = null, now = Date.now() } = {}) {
  if (isAllTime(days)) {
    if (!firstAccountAt) return MIN_WINDOW;
    const started = new Date(firstAccountAt).getTime();
    if (Number.isNaN(started)) return MIN_WINDOW;
    // Rounded up, which already includes the launch day: from 3 June to
    // 6 October is 125.3 elapsed days and 126 calendar buckets. Adding another
    // day on top would paint one empty bucket before the platform existed.
    const span = Math.ceil((now - started) / 86400000);
    return clamp(span);
  }
  return clamp(Number(days) || DEFAULT_WINDOW);
}

function clamp(n) {
  return Math.min(Math.max(n, MIN_WINDOW), MAX_WINDOW);
}

module.exports = { resolveWindow, isAllTime, MIN_WINDOW, MAX_WINDOW, DEFAULT_WINDOW };
