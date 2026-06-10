import type { Card } from '../entities/card';

export interface CardRepository {
  getById(id: string): Promise<Card | null>;
  listByChapter(chapterId: string): Promise<readonly Card[]>;
  listByProblem(problemId: string): Promise<readonly Card[]>;
  listAll(): Promise<readonly Card[]>;
}
