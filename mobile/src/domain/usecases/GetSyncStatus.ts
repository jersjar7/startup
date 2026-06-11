import type { UseCase } from './UseCase';
import type { ServerMasteryRepository } from '../repositories/ServerMasteryRepository';
import type { SyncOutboxRepository } from '../repositories/SyncOutboxRepository';

export interface SyncStatus {
  readonly lastSyncedAt: number | null;
  readonly pendingEvents: number;
}

// What the Profile sync row shows: when we last talked to the server and how
// much work is still queued locally.
export class GetSyncStatus implements UseCase<void, SyncStatus> {
  constructor(
    private readonly serverMastery: ServerMasteryRepository,
    private readonly outbox: SyncOutboxRepository,
  ) {}

  async execute(): Promise<SyncStatus> {
    return {
      lastSyncedAt: await this.serverMastery.lastSyncedAt(),
      pendingEvents: (await this.outbox.pending(1000)).length,
    };
  }
}
