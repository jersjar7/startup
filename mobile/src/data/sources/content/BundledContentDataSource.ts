import type { ContentDataSource } from './ContentDataSource';
import type { Chapter } from '@/domain/entities/chapter';
import type { Problem } from '@/domain/entities/problem';
import type { Card } from '@/domain/entities/card';
import { sampleCards } from './sampleContent';
import problemsJson from './generated/problems.json';
import chaptersJson from './generated/chapters.json';

// Real bank content, generated from docs/mobile/problem-classification.json by
// scripts/generate-mobile-content.mjs (reviewable tap-the-trap problems). Cards
// remain the hand-written sample set until verified card content is generated.
const problems = problemsJson as unknown as readonly Problem[];
const chapters = chaptersJson as unknown as readonly Chapter[];

// Reads content bundled into the app (offline-first). Swap for a remote/SQLite
// source without touching repositories or the domain.
export class BundledContentDataSource implements ContentDataSource {
  chapters(): readonly Chapter[] {
    return chapters;
  }
  problems(): readonly Problem[] {
    return problems;
  }
  cards(): readonly Card[] {
    return sampleCards;
  }
}
