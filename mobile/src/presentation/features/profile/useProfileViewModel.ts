import { useCallback, useEffect, useState } from 'react';
import { useUseCases } from '@/di/useUseCases';
import type { Mastery } from '@/domain/entities/mastery';
import type { StudyPreferences } from '@/domain/entities/plan';

export function useProfileViewModel() {
  const uc = useUseCases();
  const [loading, setLoading] = useState(true);
  const [overall, setOverall] = useState<Mastery | null>(null);
  const [masteredCount, setMasteredCount] = useState(0);
  const [topicCount, setTopicCount] = useState(0);
  const [prefs, setPrefs] = useState<StudyPreferences | null>(null);
  const [reminderHour, setReminderHour] = useState<number | null>(null);

  const load = useCallback(async () => {
    const [o, chapters, p, reminder] = await Promise.all([
      uc.getOverallMastery.execute(),
      uc.getChapterProgress.execute(),
      uc.getStudyPreferences.execute(),
      uc.getReminder.execute(),
    ]);
    setOverall(o);
    setTopicCount(chapters.length);
    setMasteredCount(chapters.filter((c) => c.mastery.state === 'mastered').length);
    setPrefs(p);
    setReminderHour(reminder);
    setLoading(false);
  }, [uc]);

  useEffect(() => {
    void load();
  }, [load]);

  // Merge a partial preference change, persist, and reload.
  const update = useCallback(
    async (partial: Partial<StudyPreferences>) => {
      if (!prefs) return;
      await uc.setStudyPreferences.execute({ ...prefs, ...partial });
      await load();
    },
    [uc, prefs, load],
  );

  const setReminder = useCallback(
    async (hour: number | null) => {
      await uc.setReminder.execute({ hour });
      await load();
    },
    [uc, load],
  );

  return { loading, overall, masteredCount, topicCount, prefs, reminderHour, reload: load, update, setReminder };
}
