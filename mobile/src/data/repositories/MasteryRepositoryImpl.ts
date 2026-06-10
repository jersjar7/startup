import type { Mastery, ChapterMastery } from '@/domain/entities/mastery';
import type { MasteryRepository } from '@/domain/repositories/MasteryRepository';
import type { MasteryPolicy } from '@/domain/services/MasteryPolicy';
import type { ReviewRepository } from '@/domain/repositories/ReviewRepository';
import type { ContentDataSource } from '../sources/content/ContentDataSource';

const MASTERED_AT_REPS = 4;

// Derives mastery from spaced-repetition progress on each chapter's cards,
// weighted by NCEES exam weight for the overall figure.
export class MasteryRepositoryImpl implements MasteryRepository {
  constructor(
    private readonly content: ContentDataSource,
    private readonly reviews: ReviewRepository,
    private readonly policy: MasteryPolicy,
  ) {}

  async byChapter(chapterId: string): Promise<ChapterMastery> {
    return { chapterId, ...this.policy.fromScore(await this.chapterScore(chapterId)) };
  }

  async allChapters(): Promise<readonly ChapterMastery[]> {
    const out: ChapterMastery[] = [];
    for (const ch of this.content.chapters()) out.push(await this.byChapter(ch.id));
    return out;
  }

  async overall(): Promise<Mastery> {
    let weighted = 0;
    let totalWeight = 0;
    for (const ch of this.content.chapters()) {
      const w = ch.examWeight || 1;
      weighted += (await this.chapterScore(ch.id)) * w;
      totalWeight += w;
    }
    return this.policy.fromScore(totalWeight ? weighted / totalWeight : 0);
  }

  private async chapterScore(chapterId: string): Promise<number> {
    const cardIds = this.content
      .cards()
      .filter((c) => c.chapterId === chapterId)
      .map((c) => c.id);
    if (cardIds.length === 0) return 0;
    const byId = new Map((await this.reviews.allSchedules()).map((s) => [s.itemId, s] as const));
    let sum = 0;
    for (const id of cardIds) {
      const s = byId.get(id);
      sum += s ? Math.min(1, s.reps / MASTERED_AT_REPS) : 0;
    }
    return sum / cardIds.length;
  }
}
