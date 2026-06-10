import type { Mastery, ChapterMastery } from '../entities/mastery';

export interface MasteryRepository {
  overall(): Promise<Mastery>;
  byChapter(chapterId: string): Promise<ChapterMastery>;
  allChapters(): Promise<readonly ChapterMastery[]>;
}
