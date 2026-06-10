import type { Chapter } from '@/domain/entities/chapter';
import type { ChapterRepository } from '@/domain/repositories/ChapterRepository';
import type { ContentDataSource } from '../sources/content/ContentDataSource';

export class ChapterRepositoryImpl implements ChapterRepository {
  constructor(private readonly content: ContentDataSource) {}

  async listAll(): Promise<readonly Chapter[]> {
    return this.content.chapters();
  }
}
