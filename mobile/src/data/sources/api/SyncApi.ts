import type { ReviewEvent } from '@/domain/entities/syncEvent';
import type { ApiClient } from './ApiClient';
import type { SyncTransport } from '@/domain/services/SyncTransport';

export interface SyncPullResult {
  events: ReviewEvent[];
  cursor: string | null;
}

// Thin wrapper over the sync endpoints (push is idempotent server-side).
export class SyncApi implements SyncTransport {
  constructor(private readonly api: ApiClient) {}

  push(events: readonly ReviewEvent[]): Promise<{ accepted: number; duplicates: number }> {
    return this.api.request('POST', '/api/sync/events', { events });
  }

  pull(since: string | null): Promise<SyncPullResult> {
    const q = since ? `?since=${encodeURIComponent(since)}` : '';
    return this.api.request('GET', `/api/sync/changes${q}`);
  }
}
