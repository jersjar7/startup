import type { Mastery, ChapterMastery } from '@/domain/entities/mastery';
import type { MasteryRepository } from '@/domain/repositories/MasteryRepository';
import type { MasteryPolicy } from '@/domain/services/MasteryPolicy';
import type { ReviewRepository } from '@/domain/repositories/ReviewRepository';
import type { DiagnosticRepository } from '@/domain/repositories/DiagnosticRepository';
import type { ServerMasteryRepository } from '@/domain/repositories/ServerMasteryRepository';
import { isReviewableProblem } from '@/domain/entities/problem';
import type { ContentDataSource } from '../sources/content/ContentDataSource';

const MASTERED_AT_REPS = 4;

// Derives mastery from spaced-repetition progress on each chapter's items, taking
// the max with the diagnostic familiarity baseline (so day-1 is personalized but
// review progress overtakes it). Overall is NCEES-exam-weighted.
export class MasteryRepositoryImpl implements MasteryRepository {
  constructor(
    private readonly content: ContentDataSource,
    private readonly reviews: ReviewRepository,
    private readonly policy: MasteryPolicy,
    private readonly diagnostic: DiagnosticRepository,
    private readonly serverMastery: ServerMasteryRepository,
  ) {}

  // The shared number: post-sync, a chapter never reads lower here than on
  // the website (server already includes this phone's pushed work; local
  // covers what hasn't synced yet).
  private async serverScores(): Promise<Record<string, number>> {
    const cached = await this.serverMastery.get();
    if (!cached) return {};
    const out: Record<string, number> = {};
    for (const [ch, pct] of Object.entries(cached)) out[ch] = pct / 100;
    return out;
  }

  async byChapter(chapterId: string): Promise<ChapterMastery> {
    const server = (await this.serverScores())[chapterId] ?? 0;
    const score = Math.max(await this.chapterScore(chapterId), server);
    return { chapterId, ...this.policy.fromScore(score) };
  }

  async allChapters(): Promise<readonly ChapterMastery[]> {
    const out: ChapterMastery[] = [];
    for (const ch of this.content.chapters()) out.push(await this.byChapter(ch.id));
    return out;
  }

  async overall(): Promise<Mastery> {
    const familiarity = await this.diagnostic.getFamiliarity();
    const server = await this.serverScores();
    const schedules = new Map((await this.reviews.allSchedules()).map((s) => [s.itemId, s] as const));
    let weighted = 0;
    let totalWeight = 0;
    for (const ch of this.content.chapters()) {
      const w = ch.examWeight || 1;
      const local = this.scoreFor(ch.id, schedules, familiarity[ch.id] ?? 0);
      weighted += Math.max(local, server[ch.id] ?? 0) * w;
      totalWeight += w;
    }
    return this.policy.fromScore(totalWeight ? weighted / totalWeight : 0);
  }

  private async chapterScore(chapterId: string): Promise<number> {
    const schedules = new Map((await this.reviews.allSchedules()).map((s) => [s.itemId, s] as const));
    const familiarity = (await this.diagnostic.getFamiliarity())[chapterId] ?? 0;
    return this.scoreFor(chapterId, schedules, familiarity);
  }

  private scoreFor(
    chapterId: string,
    schedules: Map<string, { reps: number }>,
    familiarity: number,
  ): number {
    const itemIds = [
      ...this.content.cards().filter((c) => c.chapterId === chapterId).map((c) => c.id),
      ...this.content
        .problems()
        .filter((p) => p.chapterId === chapterId && isReviewableProblem(p))
        .map((p) => p.id),
    ];
    let reviewScore = 0;
    if (itemIds.length > 0) {
      let sum = 0;
      for (const id of itemIds) {
        const s = schedules.get(id);
        sum += s ? Math.min(1, s.reps / MASTERED_AT_REPS) : 0;
      }
      reviewScore = sum / itemIds.length;
    }
    return Math.max(reviewScore, familiarity);
  }
}
