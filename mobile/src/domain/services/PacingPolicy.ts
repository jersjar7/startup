import type { StudyPlan } from '../entities/plan';

export interface PacingInput {
  readonly minutesPerDay: number;
  readonly examDate: string; // ISO yyyy-mm-dd
  readonly now: number;
  readonly currentMasteryPercent: number;
}

// Domain PORT: turns time-left + pace + current mastery into a regime, a daily
// target, and an honest projection. Implemented in data/.
export interface PacingPolicy {
  computePlan(input: PacingInput): StudyPlan;
}
