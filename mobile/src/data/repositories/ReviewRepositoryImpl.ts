import type { ReviewSchedule } from '@/domain/entities/review';
import type { ReviewRepository } from '@/domain/repositories/ReviewRepository';
import { isReviewableProblem } from '@/domain/entities/problem';
import type { KeyValueStore } from '../sources/storage/KeyValueStore';
import type { ContentDataSource } from '../sources/content/ContentDataSource';

const KEY = 'review:schedules';

// Persists per-item spaced-repetition state in the key-value store. Never-seen
// cards count as due, so a fresh user gets a full first session.
export class ReviewRepositoryImpl implements ReviewRepository {
  constructor(
    private readonly store: KeyValueStore,
    private readonly content: ContentDataSource,
  ) {}

  async dueItems(now: number, limit: number): Promise<readonly string[]> {
    const map = await this.load();
    const due = Object.values(map)
      .filter((s) => s.dueAt <= now)
      .sort((a, b) => a.dueAt - b.dueAt)
      .map((s) => s.itemId);
    if (due.length >= limit) return due.slice(0, limit);

    const seen = new Set(Object.keys(map));
    const pool = [
      ...this.content.cards().map((c) => c.id),
      ...this.content.problems().filter(isReviewableProblem).map((p) => p.id),
    ];
    const fresh = pool.filter((id) => !seen.has(id));
    return [...due, ...fresh].slice(0, limit);
  }

  async scheduleFor(itemId: string): Promise<ReviewSchedule | null> {
    return (await this.load())[itemId] ?? null;
  }

  async save(schedule: ReviewSchedule): Promise<void> {
    const map = await this.load();
    map[schedule.itemId] = schedule;
    await this.store.set(KEY, JSON.stringify(map));
  }

  async allSchedules(): Promise<readonly ReviewSchedule[]> {
    return Object.values(await this.load());
  }

  private async load(): Promise<Record<string, ReviewSchedule>> {
    const raw = await this.store.get(KEY);
    if (!raw) return {};
    try {
      return JSON.parse(raw) as Record<string, ReviewSchedule>;
    } catch {
      return {};
    }
  }
}
