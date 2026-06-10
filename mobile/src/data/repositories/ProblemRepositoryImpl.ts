import type { Problem } from '@/domain/entities/problem';
import type { ProblemRepository } from '@/domain/repositories/ProblemRepository';
import type { ContentDataSource } from '../sources/content/ContentDataSource';

export class ProblemRepositoryImpl implements ProblemRepository {
  constructor(private readonly content: ContentDataSource) {}

  async getById(id: string): Promise<Problem | null> {
    return this.content.problems().find((p) => p.id === id) ?? null;
  }
  async listByChapter(chapterId: string): Promise<readonly Problem[]> {
    return this.content.problems().filter((p) => p.chapterId === chapterId);
  }
  async listAll(): Promise<readonly Problem[]> {
    return this.content.problems();
  }
}
