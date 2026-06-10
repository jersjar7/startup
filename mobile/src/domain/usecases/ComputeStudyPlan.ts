import type { UseCase } from './UseCase';
import type { StudyPlan } from '../entities/plan';
import type { PlanRepository } from '../repositories/PlanRepository';
import type { MasteryRepository } from '../repositories/MasteryRepository';
import type { PacingPolicy } from '../services/PacingPolicy';

export interface ComputeStudyPlanInput {
  readonly now: number;
}

// Combines saved preferences + current mastery through the pacing policy.
// Returns null until the user has set a pace (exam date + minutes/day).
export class ComputeStudyPlan implements UseCase<ComputeStudyPlanInput, StudyPlan | null> {
  constructor(
    private readonly plans: PlanRepository,
    private readonly mastery: MasteryRepository,
    private readonly pacing: PacingPolicy,
  ) {}

  async execute({ now }: ComputeStudyPlanInput): Promise<StudyPlan | null> {
    const prefs = await this.plans.getPreferences();
    if (!prefs) return null;
    const overall = await this.mastery.overall();
    return this.pacing.computePlan({
      minutesPerDay: prefs.minutesPerDay,
      examDate: prefs.examDate,
      now,
      currentMasteryPercent: overall.percent,
    });
  }
}
