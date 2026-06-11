import type { SoundRepository } from '@/domain/repositories/SoundRepository';
import type { KeyValueStore } from '../sources/storage/KeyValueStore';

const KEY = 'sound:enabled';

export class SoundRepositoryImpl implements SoundRepository {
  constructor(private readonly store: KeyValueStore) {}

  async getEnabled(): Promise<boolean> {
    const raw = await this.store.get(KEY);
    return raw === null ? true : raw === '1'; // default on
  }

  async setEnabled(value: boolean): Promise<void> {
    await this.store.set(KEY, value ? '1' : '0');
  }
}
