import { useCallback, useEffect, useState } from 'react';
import { useUseCases } from '@/di/useUseCases';
import type { ChapterProgress } from '@/domain/usecases/GetChapterProgress';

// Practice surfaces the daily session status + the user's weakest chapters.
export function usePracticeViewModel() {
  const uc = useUseCases();
  const [loading, setLoading] = useState(true);
  const [dueCount, setDueCount] = useState(0);
  const [weak, setWeak] = useState<readonly ChapterProgress[]>([]);
  const [inProgress, setInProgress] = useState<readonly ChapterProgress[]>([]);

  const load = useCallback(async () => {
    const now = Date.now();
    const plan = await uc.computeStudyPlan.execute({ now });
    const session = await uc.getDailySession.execute({ now, cardTarget: plan?.dailyCardTarget ?? 9 });
    const chapters = await uc.getChapterProgress.execute();
    // "Continue" = chapters already in flight — the most likely intent.
    const continuing = [...chapters]
      .filter((c) => c.mastery.percent > 0 && c.mastery.state !== 'mastered')
      .sort((a, b) => b.mastery.percent - a.mastery.percent)
      .slice(0, 3);
    const continuingIds = new Set(continuing.map((c) => c.chapter.id));
    const weakest = [...chapters]
      .filter((c) => c.mastery.state !== 'mastered' && !continuingIds.has(c.chapter.id))
      .sort((a, b) => a.mastery.percent - b.mastery.percent)
      .slice(0, 3);
    setDueCount(session.items.length);
    setInProgress(continuing);
    setWeak(weakest);
    setLoading(false);
  }, [uc]);

  useEffect(() => {
    void load();
  }, [load]);

  return { loading, dueCount, weak, inProgress, reload: load };
}
