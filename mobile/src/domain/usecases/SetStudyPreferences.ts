import type { UseCase } from './UseCase';
import type { StudyPreferences } from '../entities/plan';
import type { PlanRepository } from '../repositories/PlanRepository';
import type { AccountRepository } from '../repositories/AccountRepository';

// Saves locally, then writes the exam date back to the website profile when
// signed in — the date drives all pacing math on both surfaces, so it must
// never silently diverge. The write-back is best-effort (offline-safe).
export class SetStudyPreferences implements UseCase<StudyPreferences, void> {
  constructor(
    private readonly plans: PlanRepository,
    private readonly accounts: AccountRepository,
  ) {}

  async execute(prefs: StudyPreferences): Promise<void> {
    await this.plans.savePreferences(prefs);
    const account = await this.accounts.getAccount();
    if (account && account.examDate !== prefs.examDate) {
      await this.accounts.updateProfile({ examDate: prefs.examDate }).catch(() => undefined);
    }
  }
}
