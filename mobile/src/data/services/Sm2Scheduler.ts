import type { ReviewSchedule, ReviewGrade } from '@/domain/entities/review';
import type { SpacedRepetitionScheduler } from '@/domain/services/SpacedRepetitionScheduler';
import { startSchedule, nextSchedule } from '@/shared/scheduler';

// Trimmed SM-2 (grades forgot/fuzzy/gotIt). The actual interval math lives in
// the shared scheduler module (mirror of service/shared/scheduler.js, parity-
// tested) so web and mobile schedule identically. This class only adapts the
// shared state shape to the domain's ReviewSchedule (which also carries itemId).
export class Sm2Scheduler implements SpacedRepetitionScheduler {
  start(itemId: string, now: number): ReviewSchedule {
    return { itemId, ...startSchedule(now) };
  }

  review(s: ReviewSchedule, grade: ReviewGrade, now: number): ReviewSchedule {
    return { itemId: s.itemId, ...nextSchedule(s, grade, now) };
  }
}
