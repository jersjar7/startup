import type { UseCase } from './UseCase';
import type { StudyPlan } from '../entities/plan';
import type { MasteryRepository } from '../repositories/MasteryRepository';
import type { PacingPolicy } from '../services/PacingPolicy';

export interface PreviewStudyPlanInput {
  readonly minutesPerDay: number;
  readonly examDate: string;
  readonly now: number;
}

// Like ComputeStudyPlan, but from unsaved inputs — powers the live projection on
// the onboarding pace step before preferences are committed.
export class PreviewStudyPlan implements UseCase<PreviewStudyPlanInput, StudyPlan> {
  constructor(
    private readonly mastery: MasteryRepository,
    private readonly pacing: PacingPolicy,
  ) {}

  async execute(input: PreviewStudyPlanInput): Promise<StudyPlan> {
    const overall = await this.mastery.overall();
    return this.pacing.computePlan({
      minutesPerDay: input.minutesPerDay,
      examDate: input.examDate,
      now: input.now,
      currentMasteryPercent: overall.percent,
    });
  }
}
