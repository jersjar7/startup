import type { DiagnosticRepository } from '@/domain/repositories/DiagnosticRepository';
import type { KeyValueStore } from '../sources/storage/KeyValueStore';

const KEY = 'diagnostic:familiarity';

export class DiagnosticRepositoryImpl implements DiagnosticRepository {
  constructor(private readonly store: KeyValueStore) {}

  async getFamiliarity(): Promise<Record<string, number>> {
    const raw = await this.store.get(KEY);
    if (!raw) return {};
    try {
      return JSON.parse(raw) as Record<string, number>;
    } catch {
      return {};
    }
  }

  async save(familiarity: Record<string, number>): Promise<void> {
    await this.store.set(KEY, JSON.stringify(familiarity));
  }
}
