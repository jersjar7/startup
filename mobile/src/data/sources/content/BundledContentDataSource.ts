import type { ContentDataSource } from './ContentDataSource';
import type { Chapter } from '@/domain/entities/chapter';
import type { Problem } from '@/domain/entities/problem';
import type { Card } from '@/domain/entities/card';
import { sampleChapters, sampleProblems, sampleCards } from './sampleContent';

// Reads content bundled into the app (offline-first). Swap for a remote/SQLite
// source without touching repositories or the domain.
export class BundledContentDataSource implements ContentDataSource {
  chapters(): readonly Chapter[] {
    return sampleChapters;
  }
  problems(): readonly Problem[] {
    return sampleProblems;
  }
  cards(): readonly Card[] {
    return sampleCards;
  }
}
