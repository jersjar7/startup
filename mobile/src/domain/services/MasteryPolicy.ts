import type { Mastery, MasteryState } from '../entities/mastery';

// Domain PORT: maps a 0..1 competence score to a mastery %, and a % to a label.
// "Mastered" must mean solved-on-paper, not merely recognized.
export interface MasteryPolicy {
  fromScore(score01: number): Mastery;
  label(percent: number): MasteryState;
}
