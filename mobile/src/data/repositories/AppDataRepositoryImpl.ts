import type { AppDataRepository } from '@/domain/repositories/AppDataRepository';
import type { KeyValueStore } from '../sources/storage/KeyValueStore';

export class AppDataRepositoryImpl implements AppDataRepository {
  constructor(private readonly store: KeyValueStore) {}
  reset(): Promise<void> {
    return this.store.clear();
  }
}
