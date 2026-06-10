import type { UseCase } from './UseCase';
import type { StudyPreferences } from '../entities/plan';
import type { PlanRepository } from '../repositories/PlanRepository';

export class SetStudyPreferences implements UseCase<StudyPreferences, void> {
  constructor(private readonly plans: PlanRepository) {}
  execute(prefs: StudyPreferences): Promise<void> {
    return this.plans.savePreferences(prefs);
  }
}
