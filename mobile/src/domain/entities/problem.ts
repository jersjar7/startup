import type { MobileTier, InteractionMode } from './tiers';

export interface Choice {
  readonly id: string;
  readonly text: string;
}

export interface Problem {
  readonly id: string;
  readonly chapterId: string;
  readonly tier: MobileTier;
  readonly interaction: InteractionMode;
  readonly statement: string;
  readonly choices: readonly Choice[];
  readonly correctChoiceId: string | null;
  readonly explanation: string;
  readonly handbookRef: string | null;
}
