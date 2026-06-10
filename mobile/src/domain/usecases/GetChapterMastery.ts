import type { UseCase } from './UseCase';
import type { ChapterMastery } from '../entities/mastery';
import type { MasteryRepository } from '../repositories/MasteryRepository';

export class GetChapterMastery implements UseCase<string, ChapterMastery> {
  constructor(private readonly mastery: MasteryRepository) {}
  execute(chapterId: string): Promise<ChapterMastery> {
    return this.mastery.byChapter(chapterId);
  }
}
