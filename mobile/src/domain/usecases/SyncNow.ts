import type { UseCase } from './UseCase';
import type { ReviewEvent } from '../entities/syncEvent';
import type { AccountRepository } from '../repositories/AccountRepository';
import type { SyncOutboxRepository } from '../repositories/SyncOutboxRepository';
import type { ReviewRepository } from '../repositories/ReviewRepository';
import type { SpacedRepetitionScheduler } from '../services/SpacedRepetitionScheduler';
import type { SyncTransport } from '../services/SyncTransport';
import type { ServerMasteryRepository } from '../repositories/ServerMasteryRepository';

const BATCH = 100;

export interface SyncResult {
  readonly pushed: number;
  readonly applied: number;
  readonly skipped: boolean; // not signed in / offline
}

// One sync cycle: drain the outbox up, pull other-device + web events down,
// and fold them into the local schedule. Offline or signed-out is a no-op —
// the phone never blocks on the network (offline-first rule).
export class SyncNow implements UseCase<void, SyncResult> {
  constructor(
    private readonly accounts: AccountRepository,
    private readonly outbox: SyncOutboxRepository,
    private readonly api: SyncTransport,
    private readonly reviews: ReviewRepository,
    private readonly scheduler: SpacedRepetitionScheduler,
    private readonly serverMastery: ServerMasteryRepository,
  ) {}

  async execute(): Promise<SyncResult> {
    const account = await this.accounts.getAccount();
    if (!account) return { pushed: 0, applied: 0, skipped: true };

    try {
      // PUSH — batches, ack only what the server confirmed.
      let pushed = 0;
      for (;;) {
        const batch = await this.outbox.pending(BATCH);
        if (batch.length === 0) break;
        await this.api.push(batch);
        await this.outbox.ack(batch.map((e) => e.eventId));
        pushed += batch.length;
        if (batch.length < BATCH) break;
      }

      // PULL — apply foreign events (web/desk + other devices) to the local
      // schedule so this phone never re-drills what was just done elsewhere.
      const deviceId = await this.outbox.getDeviceId();
      let applied = 0;
      for (;;) {
        const { events, cursor } = await this.api.pull(await this.outbox.getCursor());
        const foreign = events.filter((e) => e.deviceId !== deviceId);
        for (const e of foreign) applied += await this.apply(e);
        if (cursor) await this.outbox.setCursor(cursor);
        if (events.length < 500) break;
      }
      // Cache the server's post-push mastery — the shared number both
      // surfaces display from here on.
      try {
        await this.serverMastery.save(await this.accounts.fetchRemoteMastery(), Date.now());
      } catch {
        // mastery cache is best-effort; the sync itself succeeded
      }
      return { pushed, applied, skipped: false };
    } catch {
      // Network/server hiccup: everything stays queued for the next cycle.
      return { pushed: 0, applied: 0, skipped: true };
    }
  }

  // A web event on problem X also schedules X's recall cards — the desk work
  // covered the concept, so the phone spaces it out instead of re-introducing
  // it the same day (sync-design.md cross-surface semantics).
  private async apply(e: ReviewEvent): Promise<number> {
    const targets = e.itemId.includes(':') ? [e.itemId] : [e.itemId, `${e.itemId}:fc`, `${e.itemId}:cc`];
    let n = 0;
    for (const id of targets) {
      const base = (await this.reviews.scheduleFor(id)) ?? this.scheduler.start(id, e.ts);
      await this.reviews.save(this.scheduler.review(base, e.grade, e.ts));
      n++;
    }
    return n;
  }
}
