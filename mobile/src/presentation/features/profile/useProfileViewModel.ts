import { useCallback, useEffect, useState } from 'react';
import { useUseCases } from '@/di/useUseCases';
import { sound } from '@/core/sound';
import { displayStreakNumber } from '@/domain/entities/streak';
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
  const [reminderMinutes, setReminderMinutes] = useState<number | null>(null);
  const [soundEnabled, setSoundEnabled] = useState(true);
  const [account, setAccount] = useState<Account | null>(null);
  const [streak, setStreak] = useState(0);
  const [totalReps, setTotalReps] = useState(0);

  const load = useCallback(async () => {
    const now = Date.now();
    const [o, chapters, p, reminder, soundOn, acct, st, stats, week, plan] = await Promise.all([
      uc.getOverallMastery.execute(),
      uc.getChapterProgress.execute(),
      uc.getStudyPreferences.execute(),
      uc.getReminder.execute(),
      uc.getSoundEnabled.execute(),
      uc.getAccount.execute(),
      uc.getStreak.execute({ now }),
      uc.getReviewStats.execute(),
      uc.getWeekActivity.execute({ now }),
      uc.computeStudyPlan.execute({ now }),
    ]);
    // Same display rule as Today/WeekStrip — the streak may never disagree
    // with itself across screens.
    const session = await uc.getDailySession.execute({ now, cardTarget: plan?.dailyCardTarget ?? 9 });
    const todayStudied = week.length > 0 && week[week.length - 1].studied;
    const shownStreak = displayStreakNumber(st, todayStudied, session.items.length === 0);
    setOverall(o);
    setTopicCount(chapters.length);
    setMasteredCount(chapters.filter((c) => c.mastery.state === 'mastered').length);
    setPrefs(p);
    setReminderMinutes(reminder);
    setSoundEnabled(soundOn);
    setAccount(acct);
    setStreak(shownStreak);
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
    async (minutes: number | null) => {
      await uc.setReminder.execute({ minutes });
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
    reminderMinutes,
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
