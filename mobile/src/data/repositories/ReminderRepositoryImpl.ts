import type { ReminderRepository } from '@/domain/repositories/ReminderRepository';
import type { KeyValueStore } from '../sources/storage/KeyValueStore';

const KEY = 'reminder:minutes';
const LEGACY_HOUR_KEY = 'reminder:hour';
const OFFERED_KEY = 'reminder:offered';

export class ReminderRepositoryImpl implements ReminderRepository {
  constructor(private readonly store: KeyValueStore) {}

  async getMinutes(): Promise<number | null> {
    const raw = await this.store.get(KEY);
    if (raw !== null) {
      const n = Number(raw);
      return Number.isFinite(n) ? n : null;
    }
    // Migrate the pre-custom-time format (whole hours).
    const legacy = await this.store.get(LEGACY_HOUR_KEY);
    if (legacy !== null) {
      const h = Number(legacy);
      if (Number.isFinite(h)) {
        const minutes = h * 60;
        await this.store.set(KEY, String(minutes));
        await this.store.remove(LEGACY_HOUR_KEY);
        return minutes;
      }
    }
    return null;
  }

  async wasOffered(): Promise<boolean> {
    return (await this.store.get(OFFERED_KEY)) === '1';
  }

  async markOffered(): Promise<void> {
    await this.store.set(OFFERED_KEY, '1');
  }

  async setMinutes(minutes: number | null): Promise<void> {
    if (minutes === null) await this.store.remove(KEY);
    else await this.store.set(KEY, String(minutes));
  }
}
