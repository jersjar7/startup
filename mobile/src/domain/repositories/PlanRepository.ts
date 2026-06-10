import type { StudyPreferences } from '../entities/plan';

export interface PlanRepository {
  getPreferences(): Promise<StudyPreferences | null>;
  savePreferences(prefs: StudyPreferences): Promise<void>;
}
