// Spaced-repetition state for one schedulable item (a card or a problem id).

export type ReviewGrade = 'forgot' | 'fuzzy' | 'gotIt';

export interface ReviewSchedule {
  readonly itemId: string;
  readonly dueAt: number; // epoch ms
  readonly intervalDays: number;
  readonly ease: number;
  readonly reps: number;
  readonly lapses: number;
}
