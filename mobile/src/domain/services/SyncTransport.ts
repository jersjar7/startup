import type { ReviewEvent } from '../entities/syncEvent';

// PORT for the sync wire protocol — implemented in data/ over the REST API.
export interface SyncTransport {
  push(events: readonly ReviewEvent[], device?: string | null): Promise<{ accepted: number; duplicates: number }>;
  pull(since: string | null): Promise<{ events: ReviewEvent[]; cursor: string | null }>;
}
