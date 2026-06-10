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

  const load = useCallback(async () => {
    const [o, chapters, p] = await Promise.all([
      uc.getOverallMastery.execute(),
      uc.getChapterProgress.execute(),
      uc.getStudyPreferences.execute(),
    ]);
    setOverall(o);
    setTopicCount(chapters.length);
    setMasteredCount(chapters.filter((c) => c.mastery.state === 'mastered').length);
    setPrefs(p);
    setLoading(false);
  }, [uc]);

  useEffect(() => {
    void load();
  }, [load]);

  return { loading, overall, masteredCount, topicCount, prefs, reload: load };
}
