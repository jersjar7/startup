import type { ReviewEvent } from '@/domain/entities/syncEvent';
import type { SyncOutboxRepository } from '@/domain/repositories/SyncOutboxRepository';
import type { KeyValueStore } from '../sources/storage/KeyValueStore';

const OUTBOX_KEY = 'sync:outbox';
const CURSOR_KEY = 'sync:cursor';
const DEVICE_KEY = 'sync:deviceId';

export class SyncOutboxRepositoryImpl implements SyncOutboxRepository {
  constructor(private readonly store: KeyValueStore) {}

  private async read(): Promise<ReviewEvent[]> {
    const raw = await this.store.get(OUTBOX_KEY);
    if (!raw) return [];
    try {
      return JSON.parse(raw) as ReviewEvent[];
    } catch {
      return [];
    }
  }

  async enqueue(event: ReviewEvent): Promise<void> {
    const all = await this.read();
    all.push(event);
    await this.store.set(OUTBOX_KEY, JSON.stringify(all));
  }

  async pending(limit: number): Promise<readonly ReviewEvent[]> {
    return (await this.read()).slice(0, limit);
  }

  async ack(eventIds: readonly string[]): Promise<void> {
    const gone = new Set(eventIds);
    const left = (await this.read()).filter((e) => !gone.has(e.eventId));
    await this.store.set(OUTBOX_KEY, JSON.stringify(left));
  }

  async getCursor(): Promise<string | null> {
    return this.store.get(CURSOR_KEY);
  }

  async setCursor(cursor: string): Promise<void> {
    await this.store.set(CURSOR_KEY, cursor);
  }

  async getDeviceId(): Promise<string> {
    const existing = await this.store.get(DEVICE_KEY);
    if (existing) return existing;
    const id = `dev-${Math.random().toString(36).slice(2, 10)}${Math.random().toString(36).slice(2, 10)}`;
    await this.store.set(DEVICE_KEY, id);
    return id;
  }
}
