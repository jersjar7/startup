// Adaptive study plan (docs/mobile/implementation-plan.md §10). Daily load scales
// with time-to-exam; the projection is honest about whether the chosen pace
// reaches strong mastery — never a pass probability.

export type PacingRegime = 'runway' | 'onPace' | 'crunch';

export interface MasteryProjection {
  readonly currentPercent: number;
  readonly projectedPercent: number; // at exam date, at the chosen pace
  readonly examDate: string;
}

export interface StudyPlan {
  readonly minutesPerDay: number;
  readonly daysUntilExam: number;
  readonly regime: PacingRegime;
  readonly dailyCardTarget: number;
  readonly dailyPaperTarget: number;
  readonly projection: MasteryProjection;
}

export interface StudyPreferences {
  readonly minutesPerDay: number;
  readonly examDate: string; // ISO yyyy-mm-dd
}
