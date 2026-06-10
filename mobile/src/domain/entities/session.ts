import type { MobileTier, InteractionMode } from './tiers';
import type { Choice } from './problem';

interface SessionItemBase {
  readonly id: string;
  readonly chapterId: string;
  readonly tier: MobileTier;
  readonly interaction: InteractionMode;
}

/** A retrieval micro-card: recall the answer, then reveal. */
export interface CardSessionItem extends SessionItemBase {
  readonly kind: 'card';
  readonly prompt: string;
  readonly answer: string;
}

/** A tap-the-trap MCQ: pick a choice, then see why (correct vs. the trap). */
export interface ProblemSessionItem extends SessionItemBase {
  readonly kind: 'problem';
  readonly statement: string;
  readonly choices: readonly Choice[];
  readonly correctChoiceId: string | null;
  readonly explanation: string;
}

export type SessionItem = CardSessionItem | ProblemSessionItem;

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
