import type { MobileTier, InteractionMode } from './tiers';
import { needsPaper } from './tiers';

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

/**
 * A problem usable as an on-phone review item (tap-the-trap MCQ): it has choices
 * and doesn't require paper to solve. Paper problems surface only as the hand-off.
 */
export const isReviewableProblem = (p: Problem): boolean =>
  !needsPaper(p.tier) && p.choices.length > 0;
