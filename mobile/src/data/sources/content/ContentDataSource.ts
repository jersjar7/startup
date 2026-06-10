import type { Problem } from '@/domain/entities/problem';
import type { Card } from '@/domain/entities/card';
import type { Chapter } from '@/domain/entities/chapter';

// PORT for content. Today it's a bundled sample; later it can be the full
// generated bank or a remote API — repositories don't change.
export interface ContentDataSource {
  chapters(): readonly Chapter[];
  problems(): readonly Problem[];
  cards(): readonly Card[];
}
