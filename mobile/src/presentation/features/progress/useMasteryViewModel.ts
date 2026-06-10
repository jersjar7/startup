import { useCallback, useEffect, useState } from 'react';
import { useUseCases } from '@/di/useUseCases';
import type { Mastery } from '@/domain/entities/mastery';
import type { ChapterProgress } from '@/domain/usecases/GetChapterProgress';

export function useMasteryViewModel() {
  const uc = useUseCases();
  const [loading, setLoading] = useState(true);
  const [overall, setOverall] = useState<Mastery | null>(null);
  const [chapters, setChapters] = useState<readonly ChapterProgress[]>([]);

  const load = useCallback(async () => {
    const [o, c] = await Promise.all([
      uc.getOverallMastery.execute(),
      uc.getChapterProgress.execute(),
    ]);
    setOverall(o);
    setChapters(c);
    setLoading(false);
  }, [uc]);

  useEffect(() => {
    void load();
  }, [load]);

  return { loading, overall, chapters, reload: load };
}
