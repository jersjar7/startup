// A study streak — consecutive days with at least one review. Pure logic so it's
// trivially testable and shared by the use cases.

export interface Streak {
  readonly current: number;
  readonly lastStudiedDate: string | null; // ISO yyyy-mm-dd
}

const DAY = 24 * 60 * 60 * 1000;
const isoDay = (ms: number): string => new Date(ms).toISOString().slice(0, 10);

/** The streak as it counts *right now*: 0 if the last study day is older than yesterday. */
export function effectiveStreak(s: Streak, now: number): number {
  if (!s.lastStudiedDate) return 0;
  const today = isoDay(now);
  const yesterday = isoDay(now - DAY);
  return s.lastStudiedDate === today || s.lastStudiedDate === yesterday ? s.current : 0;
}

/** Record a study day: +1 if yesterday was the last day, unchanged if today, else reset to 1. */
export function recordDay(s: Streak, now: number): Streak {
  const today = isoDay(now);
  if (s.lastStudiedDate === today) return s;
  const yesterday = isoDay(now - DAY);
  const current = s.lastStudiedDate === yesterday ? s.current + 1 : 1;
  return { current, lastStudiedDate: today };
}
