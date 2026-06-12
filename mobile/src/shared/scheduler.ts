// shared/scheduler.ts — mobile MIRROR of the canonical web scheduler
// (service/shared/scheduler.js). This is the bundled copy Metro ships; it must
// stay byte-for-behavior identical to the canonical module. A parity test in
// the web suite imports BOTH this file and the canonical one, runs the shared
// fixtures through each, and asserts identical output + the SAME
// SCHEDULER_VERSION. If you change scheduling, change BOTH files and bump the
// version in BOTH, or the parity test goes red.
//
// Kept dependency-free on purpose (no `@/` imports, no React Native) so the
// Node-based vitest runner can import it directly for that parity check.

export const SCHEDULER_VERSION = '2.1.0';

export const DAY_MS = 24 * 60 * 60 * 1000;
export const RELEARN_MS = 10 * 60 * 1000;
export const MIN_EASE = 1.3;
export const START_EASE = 2.5;
export const MAX_INTERVAL_DAYS = 60;
export const MAX_PROJECTION = 98;
export const CARDS_PER_MINUTE = 0.6;
export const PAPER_MINUTES = 6;
export const COVERAGE_RATE = 1.5;

export type ReviewGrade = 'forgot' | 'fuzzy' | 'gotIt';
export type PacingRegime = 'runway' | 'onPace' | 'crunch';

export interface ScheduleState {
  readonly intervalDays: number;
  readonly ease: number;
  readonly reps: number;
  readonly lapses: number;
  readonly dueAt: number;
}

export interface DailyPlan {
  readonly daysUntilExam: number | null;
  readonly studyDays: number | null;
  readonly regime: PacingRegime;
  readonly intensity: number;
  readonly minutesPerDay: number;
  readonly dailyCardTarget: number;
  readonly dailyPaperTarget: number;
  readonly dynamicCeiling: number;
  readonly reviewTarget: number;
  readonly budgetedNewTarget: number;
  readonly newDeferred: boolean;
  readonly softCap: boolean;
  readonly projection: {
    readonly currentPercent: number;
    readonly projectedPercent: number;
    readonly examDate: string | null;
    readonly coverageAnchored: boolean;
  } | null;
}

export interface DailyPlanInput {
  readonly now: number;
  readonly examDate?: string | null;
  readonly minutesPerDay?: number;
  readonly currentMasteryPercent?: number;
  readonly coveragePercent?: number;
  readonly dueCount?: number;
}

// Ease kept at 2 decimals so it never accumulates IEEE-754 noise. Must match
// service/shared/scheduler.js exactly.
function round2(n: number): number {
  return Math.round(n * 100) / 100;
}

export function startSchedule(now: number): ScheduleState {
  return { intervalDays: 0, ease: START_EASE, reps: 0, lapses: 0, dueAt: now };
}

export function nextSchedule(
  state: Partial<ScheduleState>,
  grade: ReviewGrade,
  now: number,
): ScheduleState {
  const ease0 = typeof state.ease === 'number' ? state.ease : START_EASE;
  const reps0 = state.reps || 0;
  const lapses0 = state.lapses || 0;
  const prevInterval = state.intervalDays || 0;

  if (grade === 'forgot') {
    return {
      intervalDays: 0,
      ease: round2(Math.max(MIN_EASE, ease0 - 0.2)),
      reps: 0,
      lapses: lapses0 + 1,
      dueAt: now + RELEARN_MS,
    };
  }

  const reps = reps0 + 1;
  const ease = grade === 'fuzzy' ? round2(Math.max(MIN_EASE, ease0 - 0.05)) : ease0;
  const grown =
    reps === 1
      ? 1
      : reps === 2
        ? 3
        : Math.round(Math.max(1, prevInterval) * (grade === 'fuzzy' ? 1.2 : ease));
  const intervalDays = Math.min(grown, MAX_INTERVAL_DAYS);

  return { intervalDays, ease, reps, lapses: lapses0, dueAt: now + intervalDays * DAY_MS };
}

// Seed a full schedule state from a possibly-legacy web row (interval-only).
// Mirrors service/shared/scheduler.js seedState exactly.
export function seedState(row: {
  intervalDays?: number;
  interval?: number;
  ease?: number;
  reps?: number;
  lapses?: number;
  timesIncorrect?: number;
}): { intervalDays: number; ease: number; reps: number; lapses: number } {
  const intervalDays = row.intervalDays != null ? row.intervalDays : row.interval || 0;
  return {
    intervalDays,
    ease: typeof row.ease === 'number' ? row.ease : START_EASE,
    reps: row.reps != null ? row.reps : intervalDays > 0 ? 3 : 0,
    lapses: row.lapses != null ? row.lapses : row.timesIncorrect || 0,
  };
}

export function daysUntil(examDate: string | null | undefined, now: number): number | null {
  if (!examDate) return null;
  const exam = Date.parse(`${examDate}T00:00:00`);
  if (Number.isNaN(exam)) return null;
  return Math.max(0, Math.ceil((exam - now) / DAY_MS));
}

export function regimeForStudyDays(studyDays: number | null): PacingRegime {
  if (studyDays == null) return 'onPace';
  if (studyDays >= 56) return 'runway';
  if (studyDays >= 14) return 'onPace';
  return 'crunch';
}

export function dynamicCeiling(
  regime: PacingRegime,
  dueCount: number,
  studyDays: number | null,
): number {
  const base = regime === 'crunch' ? 30 : regime === 'onPace' ? 12 : 8;
  const backlog = Math.max(0, dueCount || 0);
  const bump = studyDays && studyDays > 0 ? Math.ceil(backlog / studyDays) : 0;
  return base + bump;
}

export function reviewTargetFor(
  regime: PacingRegime,
  dueCount: number,
  studyDays: number | null,
): number {
  return Math.min(Math.max(0, dueCount || 0), dynamicCeiling(regime, dueCount, studyDays));
}

function clamp(n: number, lo: number, hi: number): number {
  return Math.max(lo, Math.min(hi, n));
}

export function computeDailyPlan(input: DailyPlanInput): DailyPlan {
  const now = input.now;
  const days = daysUntil(input.examDate, now);
  const studyDays = days == null ? null : Math.max(0, days - 1);
  const regime = regimeForStudyDays(studyDays);
  const intensity = regime === 'crunch' ? 1.3 : 1;

  const minutesPerDay = input.minutesPerDay || 20;
  const dailyCardTarget = clamp(Math.round(minutesPerDay * 0.6 * intensity), 5, 40);
  const dailyPaperTarget = regime === 'crunch' ? 2 : 1;
  const ceiling = dynamicCeiling(regime, input.dueCount || 0, studyDays);
  const reviewTarget = Math.min(Math.max(0, input.dueCount || 0), ceiling);

  // Minutes-budget governor: protect due reviews (and paper) first; defer new.
  const reviewMinutes = reviewTarget / CARDS_PER_MINUTE;
  const paperMinutes = dailyPaperTarget * PAPER_MINUTES;
  const minutesForNew = Math.max(0, minutesPerDay - reviewMinutes - paperMinutes);
  const budgetedNewTarget = Math.min(dailyCardTarget, Math.round(minutesForNew * CARDS_PER_MINUTE));
  const newDeferred = budgetedNewTarget < dailyCardTarget;

  let projection: DailyPlan['projection'] = null;
  if (typeof input.currentMasteryPercent === 'number') {
    const gainPerDay = minutesPerDay * 0.03;
    const sd = studyDays == null ? 0 : studyDays;
    let projected = clamp(input.currentMasteryPercent + sd * gainPerDay, 0, MAX_PROJECTION);
    const anchored = typeof input.coveragePercent === 'number';
    if (anchored) {
      const coverageCap = Math.min(MAX_PROJECTION, (input.coveragePercent as number) + sd * COVERAGE_RATE);
      projected = Math.min(projected, coverageCap);
    }
    projection = {
      currentPercent: Math.round(input.currentMasteryPercent),
      projectedPercent: Math.round(projected),
      examDate: input.examDate || null,
      coverageAnchored: anchored,
    };
  }

  return {
    daysUntilExam: days,
    studyDays,
    regime,
    intensity,
    minutesPerDay,
    dailyCardTarget,
    dailyPaperTarget,
    dynamicCeiling: ceiling,
    reviewTarget,
    budgetedNewTarget,
    newDeferred,
    softCap: true,
    projection,
  };
}
