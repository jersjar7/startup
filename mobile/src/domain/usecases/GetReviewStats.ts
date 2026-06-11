import type { UseCase } from './UseCase';
import type { ReviewRepository } from '../repositories/ReviewRepository';

export interface ReviewStats {
  readonly itemsTracked: number;
  readonly totalReps: number;
}

// Lifetime study volume on this device — fuels the Profile stats row.
export class GetReviewStats implements UseCase<void, ReviewStats> {
  constructor(private readonly reviews: ReviewRepository) {}

  async execute(): Promise<ReviewStats> {
    const schedules = await this.reviews.allSchedules();
    return {
      itemsTracked: schedules.length,
      totalReps: schedules.reduce((sum, s) => sum + s.reps, 0),
    };
  }
}
