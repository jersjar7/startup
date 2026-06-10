import type { UseCase } from './UseCase';
import type { StreakRepository } from '../repositories/StreakRepository';
import { recordDay, effectiveStreak } from '../entities/streak';

export interface RecordStudyDayInput {
  readonly now: number;
}

// Marks today as studied and returns the resulting streak count.
export class RecordStudyDay implements UseCase<RecordStudyDayInput, number> {
  constructor(private readonly streaks: StreakRepository) {}
  async execute({ now }: RecordStudyDayInput): Promise<number> {
    const next = recordDay(await this.streaks.get(), now);
    await this.streaks.save(next);
    return effectiveStreak(next, now);
  }
}
