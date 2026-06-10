import type { Chapter } from '../entities/chapter';

export interface ChapterRepository {
  listAll(): Promise<readonly Chapter[]>;
}
