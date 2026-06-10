import type { UseCase } from './UseCase';
import type { StudyPreferences } from '../entities/plan';
import type { PlanRepository } from '../repositories/PlanRepository';

// null = onboarding not completed yet (no pace set). Used by the root gate.
export class GetStudyPreferences implements UseCase<void, StudyPreferences | null> {
  constructor(private readonly plans: PlanRepository) {}
  execute(): Promise<StudyPreferences | null> {
    return this.plans.getPreferences();
  }
}
