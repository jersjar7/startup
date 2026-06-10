import type { Card } from '@/domain/entities/card';
import type { CardRepository } from '@/domain/repositories/CardRepository';
import type { ContentDataSource } from '../sources/content/ContentDataSource';

export class CardRepositoryImpl implements CardRepository {
  constructor(private readonly content: ContentDataSource) {}

  async getById(id: string): Promise<Card | null> {
    return this.content.cards().find((c) => c.id === id) ?? null;
  }
  async listByChapter(chapterId: string): Promise<readonly Card[]> {
    return this.content.cards().filter((c) => c.chapterId === chapterId);
  }
  async listByProblem(problemId: string): Promise<readonly Card[]> {
    return this.content.cards().filter((c) => c.problemId === problemId);
  }
  async listAll(): Promise<readonly Card[]> {
    return this.content.cards();
  }
}
