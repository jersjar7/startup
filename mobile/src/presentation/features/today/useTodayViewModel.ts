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

// Orchestrates the Today screen by calling use cases only — it never touches a
// repository or knows where the data lives. Preferences are guaranteed by
// onboarding before this screen is ever reached.
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
    const plan = await uc.computeStudyPlan.execute({ now });
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
