import type { Problem } from '../entities/problem';

export interface ProblemRepository {
  getById(id: string): Promise<Problem | null>;
  listByChapter(chapterId: string): Promise<readonly Problem[]>;
  listAll(): Promise<readonly Problem[]>;
}
