import type { MobileTier, InteractionMode } from './tiers';

export type SessionItemKind = 'card' | 'problem';

export interface SessionItem {
  readonly id: string;
  readonly kind: SessionItemKind;
  readonly chapterId: string;
  readonly tier: MobileTier;
  readonly interaction: InteractionMode;
  readonly prompt: string;
  readonly answer: string;
}

/** The single "solve it on paper tonight" problem seeded into a daily session. */
export interface PaperHandoff {
  readonly problemId: string;
  readonly chapterId: string;
  readonly statement: string;
}

/** A bounded daily session — a defined set, never an infinite feed. */
export interface DailySession {
  readonly date: string; // ISO yyyy-mm-dd
  readonly items: readonly SessionItem[];
  readonly estimatedMinutes: number;
  readonly paperHandoff: PaperHandoff | null;
}
