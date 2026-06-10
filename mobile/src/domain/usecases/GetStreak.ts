import type { UseCase } from './UseCase';
import type { StreakRepository } from '../repositories/StreakRepository';
import { effectiveStreak } from '../entities/streak';

export interface GetStreakInput {
  readonly now: number;
}

export class GetStreak implements UseCase<GetStreakInput, number> {
  constructor(private readonly streaks: StreakRepository) {}
  async execute({ now }: GetStreakInput): Promise<number> {
    return effectiveStreak(await this.streaks.get(), now);
  }
}
