// PORT: the last server-reported chapter mastery (percent), cached at sync.
// The shared number — when present, mastery displays use max(local, server)
// so the same chapter never reads differently on the two surfaces post-sync.
export interface ServerMasteryRepository {
  get(): Promise<Record<string, number> | null>;
  save(masteryByChapter: Record<string, number>, syncedAt: number): Promise<void>;
  lastSyncedAt(): Promise<number | null>;
}
