import type { Streak } from '../entities/streak';

export interface StreakRepository {
  get(): Promise<Streak>;
  save(streak: Streak): Promise<void>;
}
