import { useCallback, useEffect, useState } from 'react';
import { useUseCases } from '@/di/useUseCases';
import { sound } from '@/core/sound';
import type { Mastery } from '@/domain/entities/mastery';
import type { StudyPreferences } from '@/domain/entities/plan';
import type { Account } from '@/domain/entities/account';

export function useProfileViewModel() {
  const uc = useUseCases();
  const [loading, setLoading] = useState(true);
  const [overall, setOverall] = useState<Mastery | null>(null);
  const [masteredCount, setMasteredCount] = useState(0);
  const [topicCount, setTopicCount] = useState(0);
  const [prefs, setPrefs] = useState<StudyPreferences | null>(null);
  const [reminderHour, setReminderHour] = useState<number | null>(null);
  const [soundEnabled, setSoundEnabled] = useState(true);
  const [account, setAccount] = useState<Account | null>(null);
  const [streak, setStreak] = useState(0);
  const [totalReps, setTotalReps] = useState(0);

  const load = useCallback(async () => {
    const [o, chapters, p, reminder, soundOn, acct, st, stats] = await Promise.all([
      uc.getOverallMastery.execute(),
      uc.getChapterProgress.execute(),
      uc.getStudyPreferences.execute(),
      uc.getReminder.execute(),
      uc.getSoundEnabled.execute(),
      uc.getAccount.execute(),
      uc.getStreak.execute({ now: Date.now() }),
      uc.getReviewStats.execute(),
    ]);
    setOverall(o);
    setTopicCount(chapters.length);
    setMasteredCount(chapters.filter((c) => c.mastery.state === 'mastered').length);
    setPrefs(p);
    setReminderHour(reminder);
    setSoundEnabled(soundOn);
    setAccount(acct);
    setStreak(st);
    setTotalReps(stats.totalReps);
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

  // Persist, update the live controller, and play a preview tick when enabling.
  const setSound = useCallback(
    (value: boolean) => {
      setSoundEnabled(value);
      sound.setEnabled(value);
      if (value) sound.correct();
      void uc.setSoundEnabled.execute(value);
    },
    [uc],
  );

  const signOut = useCallback(async () => {
    await uc.signOut.execute();
    await load();
  }, [uc, load]);

  return {
    loading,
    overall,
    masteredCount,
    topicCount,
    prefs,
    reminderHour,
    soundEnabled,
    account,
    streak,
    totalReps,
    reload: load,
    update,
    setReminder,
    setSound,
    signOut,
  };
}
