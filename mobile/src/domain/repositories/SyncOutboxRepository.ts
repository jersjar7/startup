import type { ReviewEvent } from '../entities/syncEvent';

// PORT for the offline-first sync queue: every review lands here first, the
// network drains it later. Also owns the pull cursor and this device's id.
export interface SyncOutboxRepository {
  enqueue(event: ReviewEvent): Promise<void>;
  pending(limit: number): Promise<readonly ReviewEvent[]>;
  ack(eventIds: readonly string[]): Promise<void>;
  getCursor(): Promise<string | null>;
  setCursor(cursor: string): Promise<void>;
  getDeviceId(): Promise<string>;
}
