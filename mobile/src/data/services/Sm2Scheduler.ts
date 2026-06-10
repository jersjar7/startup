import type { ReviewSchedule, ReviewGrade } from '@/domain/entities/review';
import type { SpacedRepetitionScheduler } from '@/domain/services/SpacedRepetitionScheduler';

const DAY = 24 * 60 * 60 * 1000;
const TEN_MIN = 10 * 60 * 1000;
const MIN_EASE = 1.3;

// A trimmed SM-2: three grades (forgot / fuzzy / gotIt). "forgot" resurfaces the
// item in ~10 min; success grows the interval by the ease factor.
export class Sm2Scheduler implements SpacedRepetitionScheduler {
  start(itemId: string, now: number): ReviewSchedule {
    return { itemId, dueAt: now, intervalDays: 0, ease: 2.5, reps: 0, lapses: 0 };
  }

  review(s: ReviewSchedule, grade: ReviewGrade, now: number): ReviewSchedule {
    if (grade === 'forgot') {
      return {
        ...s,
        reps: 0,
        lapses: s.lapses + 1,
        intervalDays: 0,
        ease: Math.max(MIN_EASE, s.ease - 0.2),
        dueAt: now + TEN_MIN,
      };
    }
    const reps = s.reps + 1;
    const ease = grade === 'fuzzy' ? Math.max(MIN_EASE, s.ease - 0.05) : s.ease;
    const intervalDays =
      reps === 1 ? 1 : reps === 2 ? 3 : Math.round(Math.max(1, s.intervalDays) * (grade === 'fuzzy' ? 1.2 : ease));
    return { ...s, reps, ease, intervalDays, dueAt: now + intervalDays * DAY };
  }
}
