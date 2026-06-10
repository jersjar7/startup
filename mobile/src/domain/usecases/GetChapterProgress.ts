import type { UseCase } from './UseCase';
import type { Chapter } from '../entities/chapter';
import type { ChapterMastery } from '../entities/mastery';
import type { ChapterRepository } from '../repositories/ChapterRepository';
import type { MasteryRepository } from '../repositories/MasteryRepository';

// A chapter joined with its current mastery — what the Mastery screen lists.
export interface ChapterProgress {
  readonly chapter: Chapter;
  readonly mastery: ChapterMastery;
}

export class GetChapterProgress implements UseCase<void, readonly ChapterProgress[]> {
  constructor(
    private readonly chapters: ChapterRepository,
    private readonly mastery: MasteryRepository,
  ) {}

  async execute(): Promise<readonly ChapterProgress[]> {
    const chapters = await this.chapters.listAll();
    const out: ChapterProgress[] = [];
    for (const chapter of chapters) {
      out.push({ chapter, mastery: await this.mastery.byChapter(chapter.id) });
    }
    return out;
  }
}
