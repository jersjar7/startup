import type { ReviewSchedule, ReviewGrade } from '../entities/review';

// Domain PORT: how an item's next due date is computed. Implemented in data/.
export interface SpacedRepetitionScheduler {
  start(itemId: string, now: number): ReviewSchedule;
  review(schedule: ReviewSchedule, grade: ReviewGrade, now: number): ReviewSchedule;
}
