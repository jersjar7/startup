import type { Mastery, MasteryState } from '@/domain/entities/mastery';
import type { MasteryPolicy } from '@/domain/services/MasteryPolicy';

// Thresholds for the labels shown in the UI. "mastered" is the strong band —
// it still never implies a pass, only that the concepts are locked in.
export class ConceptMasteryPolicy implements MasteryPolicy {
  label(percent: number): MasteryState {
    if (percent >= 80) return 'mastered';
    if (percent >= 50) return 'familiar';
    if (percent >= 20) return 'building';
    return 'new';
  }

  fromScore(score01: number): Mastery {
    const percent = Math.round(Math.max(0, Math.min(1, score01)) * 100);
    return { percent, state: this.label(percent) };
  }
}
