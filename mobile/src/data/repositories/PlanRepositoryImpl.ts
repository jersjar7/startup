import type { StudyPreferences } from '@/domain/entities/plan';
import type { PlanRepository } from '@/domain/repositories/PlanRepository';
import type { KeyValueStore } from '../sources/storage/KeyValueStore';

const KEY = 'plan:preferences';

export class PlanRepositoryImpl implements PlanRepository {
  constructor(private readonly store: KeyValueStore) {}

  async getPreferences(): Promise<StudyPreferences | null> {
    const raw = await this.store.get(KEY);
    if (!raw) return null;
    try {
      return JSON.parse(raw) as StudyPreferences;
    } catch {
      return null;
    }
  }

  async savePreferences(prefs: StudyPreferences): Promise<void> {
    await this.store.set(KEY, JSON.stringify(prefs));
  }
}
