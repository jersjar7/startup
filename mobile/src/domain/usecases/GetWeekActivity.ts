import type { UseCase } from './UseCase';
import type { StreakRepository } from '../repositories/StreakRepository';
import { weekActivity } from '../entities/streak';

export interface WeekDay {
  readonly date: string;
  readonly studied: boolean;
}

// The last 7 days of study activity — drives the Today week strip.
export class GetWeekActivity implements UseCase<{ now: number }, WeekDay[]> {
  constructor(private readonly streaks: StreakRepository) {}
  async execute({ now }: { now: number }): Promise<WeekDay[]> {
    return weekActivity(await this.streaks.get(), now);
  }
}
