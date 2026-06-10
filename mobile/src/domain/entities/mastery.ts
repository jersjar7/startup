// Mastery is "% of the concepts the FE tests that you've locked in" — NEVER a
// probability of passing (docs/mobile-app-north-star.md rule #3).

export type MasteryState = 'new' | 'building' | 'familiar' | 'mastered';

export interface Mastery {
  readonly percent: number; // 0..100
  readonly state: MasteryState;
}

export interface ChapterMastery extends Mastery {
  readonly chapterId: string;
}
