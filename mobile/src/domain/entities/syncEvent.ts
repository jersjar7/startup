import type { ReviewGrade } from './review';

// One immutable review event — the unit of progress sync. State (schedules,
// streak, mastery) is derived from these; events themselves never change.
export interface ReviewEvent {
  readonly eventId: string; // client uuid — the idempotency key
  readonly itemId: string; // card (math-slq-q1:fc) or problem (math-slq-q1)
  readonly chapterId: string;
  readonly grade: ReviewGrade;
  readonly source: 'web' | 'ios' | 'android';
  readonly deviceId: string | null;
  readonly ts: number; // epoch ms
  readonly localDate: string; // YYYY-MM-DD in the DEVICE's timezone
}
