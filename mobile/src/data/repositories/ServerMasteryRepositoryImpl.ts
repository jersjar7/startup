import type { ServerMasteryRepository } from '@/domain/repositories/ServerMasteryRepository';
import type { KeyValueStore } from '../sources/storage/KeyValueStore';

const KEY = 'sync:serverMastery';
const AT_KEY = 'sync:lastSyncedAt';

export class ServerMasteryRepositoryImpl implements ServerMasteryRepository {
  constructor(private readonly store: KeyValueStore) {}

  async get(): Promise<Record<string, number> | null> {
    const raw = await this.store.get(KEY);
    if (!raw) return null;
    try {
      return JSON.parse(raw) as Record<string, number>;
    } catch {
      return null;
    }
  }

  async save(masteryByChapter: Record<string, number>, syncedAt: number): Promise<void> {
    await this.store.set(KEY, JSON.stringify(masteryByChapter));
    await this.store.set(AT_KEY, String(syncedAt));
  }

  async lastSyncedAt(): Promise<number | null> {
    const raw = await this.store.get(AT_KEY);
    const n = raw === null ? NaN : Number(raw);
    return Number.isFinite(n) ? n : null;
  }
}
