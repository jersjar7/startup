import type { UseCase } from './UseCase';
import type { ReviewGrade } from '../entities/review';
import type { ReviewRepository } from '../repositories/ReviewRepository';
import type { SyncOutboxRepository } from '../repositories/SyncOutboxRepository';
import type { SpacedRepetitionScheduler } from '../services/SpacedRepetitionScheduler';
import { localIsoDay } from '../entities/streak';

export interface SubmitReviewInput {
  readonly itemId: string;
  readonly chapterId: string;
  readonly grade: ReviewGrade;
  readonly now: number;
}

// Updates the local schedule AND appends the event to the sync outbox — the
// outbox is what the server derives the shared state from.
export class SubmitReview implements UseCase<SubmitReviewInput, void> {
  constructor(
    private readonly reviews: ReviewRepository,
    private readonly scheduler: SpacedRepetitionScheduler,
    private readonly outbox: SyncOutboxRepository,
    private readonly source: 'ios' | 'android' | 'web',
  ) {}

  async execute({ itemId, chapterId, grade, now }: SubmitReviewInput): Promise<void> {
    const existing = await this.reviews.scheduleFor(itemId);
    const base = existing ?? this.scheduler.start(itemId, now);
    await this.reviews.save(this.scheduler.review(base, grade, now));

    const deviceId = await this.outbox.getDeviceId();
    await this.outbox.enqueue({
      eventId: `${now.toString(36)}-${Math.random().toString(36).slice(2, 12)}`,
      itemId,
      chapterId,
      grade,
      source: this.source,
      deviceId,
      ts: now,
      localDate: localIsoDay(now),
    });
  }
}
