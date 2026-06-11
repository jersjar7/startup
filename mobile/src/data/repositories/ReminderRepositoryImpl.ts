import type { ReminderRepository } from '@/domain/repositories/ReminderRepository';
import type { KeyValueStore } from '../sources/storage/KeyValueStore';

const KEY = 'reminder:hour';

export class ReminderRepositoryImpl implements ReminderRepository {
  constructor(private readonly store: KeyValueStore) {}

  async getHour(): Promise<number | null> {
    const raw = await this.store.get(KEY);
    if (raw === null) return null;
    const n = Number(raw);
    return Number.isFinite(n) ? n : null;
  }

  async setHour(hour: number | null): Promise<void> {
    if (hour === null) await this.store.remove(KEY);
    else await this.store.set(KEY, String(hour));
  }
}
