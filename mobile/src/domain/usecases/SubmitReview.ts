import type { UseCase } from './UseCase';
import type { ReviewGrade } from '../entities/review';
import type { ReviewRepository } from '../repositories/ReviewRepository';
import type { SpacedRepetitionScheduler } from '../services/SpacedRepetitionScheduler';

export interface SubmitReviewInput {
  readonly itemId: string;
  readonly grade: ReviewGrade;
  readonly now: number;
}

export class SubmitReview implements UseCase<SubmitReviewInput, void> {
  constructor(
    private readonly reviews: ReviewRepository,
    private readonly scheduler: SpacedRepetitionScheduler,
  ) {}

  async execute({ itemId, grade, now }: SubmitReviewInput): Promise<void> {
    const existing = await this.reviews.scheduleFor(itemId);
    const base = existing ?? this.scheduler.start(itemId, now);
    await this.reviews.save(this.scheduler.review(base, grade, now));
  }
}
