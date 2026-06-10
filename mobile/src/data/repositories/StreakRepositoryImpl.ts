import type { Streak } from '@/domain/entities/streak';
import type { StreakRepository } from '@/domain/repositories/StreakRepository';
import type { KeyValueStore } from '../sources/storage/KeyValueStore';

const KEY = 'streak';
const EMPTY: Streak = { current: 0, lastStudiedDate: null };

export class StreakRepositoryImpl implements StreakRepository {
  constructor(private readonly store: KeyValueStore) {}

  async get(): Promise<Streak> {
    const raw = await this.store.get(KEY);
    if (!raw) return EMPTY;
    try {
      return JSON.parse(raw) as Streak;
    } catch {
      return EMPTY;
    }
  }

  async save(streak: Streak): Promise<void> {
    await this.store.set(KEY, JSON.stringify(streak));
  }
}
