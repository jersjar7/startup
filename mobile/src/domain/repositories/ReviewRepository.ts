import type { ReviewSchedule } from '../entities/review';

export interface ReviewRepository {
  /** Item ids due at or before `now`, newest-content first when nothing is due. */
  dueItems(now: number, limit: number): Promise<readonly string[]>;
  scheduleFor(itemId: string): Promise<ReviewSchedule | null>;
  save(schedule: ReviewSchedule): Promise<void>;
  allSchedules(): Promise<readonly ReviewSchedule[]>;
}
