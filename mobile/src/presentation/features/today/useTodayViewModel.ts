import { useCallback, useEffect, useState } from 'react';
import { useUseCases } from '@/di/useUseCases';
import type { DailySession } from '@/domain/entities/session';
import type { StudyPlan } from '@/domain/entities/plan';
import type { Mastery } from '@/domain/entities/mastery';

interface TodayState {
  loading: boolean;
  mastery: Mastery | null;
  plan: StudyPlan | null;
  session: DailySession | null;
}

const DAY = 24 * 60 * 60 * 1000;
const DEFAULT_MINUTES = 20;
const DEFAULT_DAYS_OUT = 48;

// Orchestrates the Today screen's data by calling use cases only — it never
// touches a repository or knows where the data lives.
export function useTodayViewModel() {
  const uc = useUseCases();
  const [state, setState] = useState<TodayState>({
    loading: true,
    mastery: null,
    plan: null,
    session: null,
  });

  const load = useCallback(async () => {
    const now = Date.now();

    // First run: seed a default pace so a plan can be computed.
    let plan = await uc.computeStudyPlan.execute({ now });
    if (!plan) {
      await uc.setStudyPreferences.execute({
        minutesPerDay: DEFAULT_MINUTES,
        examDate: new Date(now + DEFAULT_DAYS_OUT * DAY).toISOString().slice(0, 10),
      });
      plan = await uc.computeStudyPlan.execute({ now });
    }

    const mastery = await uc.getOverallMastery.execute();
    const session = await uc.getDailySession.execute({
      now,
      cardTarget: plan?.dailyCardTarget ?? 9,
    });

    setState({ loading: false, mastery, plan, session });
  }, [uc]);

  useEffect(() => {
    void load();
  }, [load]);

  return { ...state, reload: load };
}
