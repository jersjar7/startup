import type { InteractionMode } from './tiers';

// A phone-native retrieval micro-card mined from a problem's traps/handbook/eli5.
// id convention: `${problemId}:card:${n}` so a problem can surface several cards
// on independent spaced schedules.
export interface Card {
  readonly id: string;
  readonly problemId: string;
  readonly chapterId: string;
  readonly kind: InteractionMode;
  readonly prompt: string;
  readonly answer: string;
}
