// A study streak — consecutive days with at least one review. Pure logic so it's
// trivially testable and shared by the use cases.

export interface Streak {
  readonly current: number;
  readonly lastStudiedDate: string | null; // ISO yyyy-mm-dd
  /** Recent study days (ISO dates, most recent last, capped) — feeds the week strip. */
  readonly recentDays?: readonly string[];
}

const RECENT_CAP = 14;
// LOCAL calendar day, never UTC — toISOString would roll the streak over at
// 5-7pm for US users and mark tomorrow as studied during evening sessions.
const isoDay = (ms: number): string => {
  const d = new Date(ms);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
};

// Previous local calendar day (DST-safe).
const isoYesterday = (ms: number): string => {
  const d = new Date(ms);
  return isoDay(new Date(d.getFullYear(), d.getMonth(), d.getDate() - 1).getTime());
};

/** The streak as it counts *right now*: 0 if the last study day is older than yesterday. */
export function effectiveStreak(s: Streak, now: number): number {
  if (!s.lastStudiedDate) return 0;
  return s.lastStudiedDate === isoDay(now) || s.lastStudiedDate === isoYesterday(now) ? s.current : 0;
}

/** Record a study day: +1 if yesterday was the last day, unchanged if today, else reset to 1. */
export function recordDay(s: Streak, now: number): Streak {
  const today = isoDay(now);
  if (s.lastStudiedDate === today) return s;
  const current = s.lastStudiedDate === isoYesterday(now) ? s.current + 1 : 1;
  const recentDays = [...(s.recentDays ?? []), today].slice(-RECENT_CAP);
  return { current, lastStudiedDate: today, recentDays };
}

/**
 * The ONE display rule for the streak number, shared by every screen: today
 * counts only once the daily queue is complete. The number may never exceed
 * what the week dots show.
 */
export function displayStreakNumber(effective: number, todayStudied: boolean, todayComplete: boolean): number {
  return todayStudied && !todayComplete ? Math.max(0, effective - 1) : effective;
}

/** The last 7 calendar days (today last), each marked studied or not. */
export function weekActivity(s: Streak, now: number): { date: string; studied: boolean }[] {
  const studied = new Set(s.recentDays ?? (s.lastStudiedDate ? [s.lastStudiedDate] : []));
  const out: { date: string; studied: boolean }[] = [];
  const base = new Date(now);
  for (let i = 6; i >= 0; i--) {
    // Step back whole local calendar days (DST-safe), not raw 24h blocks.
    const d = new Date(base.getFullYear(), base.getMonth(), base.getDate() - i);
    const date = isoDay(d.getTime());
    out.push({ date, studied: studied.has(date) });
  }
  return out;
}
