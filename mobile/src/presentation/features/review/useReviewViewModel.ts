import { useCallback, useEffect, useRef, useState } from 'react';
import { useUseCases } from '@/di/useUseCases';
import type { SessionItem } from '@/domain/entities/session';
import type { ReviewGrade } from '@/domain/entities/review';

type Phase = 'loading' | 'reviewing' | 'done';

interface ReviewState {
  phase: Phase;
  items: readonly SessionItem[];
  index: number;
}

// Sequences a bounded review session. Each card owns its own interaction state
// (reveal / pick) and calls advance() with a grade, which writes back through
// SubmitReview → the spaced-repetition scheduler and moves to the next item.
export function useReviewViewModel(chapterId?: string) {
  const uc = useUseCases();
  const [state, setState] = useState<ReviewState>({ phase: 'loading', items: [], index: 0 });
  const [streak, setStreak] = useState(0);
  const recorded = useRef(false);

  useEffect(() => {
    let active = true;
    void (async () => {
      const now = Date.now();
      const session = chapterId
        ? await uc.getChapterPractice.execute({ chapterId, count: 12, now })
        : await uc.getDailySession.execute({
            now,
            cardTarget: (await uc.computeStudyPlan.execute({ now }))?.dailyCardTarget ?? 9,
          });
      if (!active) return;
      setState({ phase: session.items.length > 0 ? 'reviewing' : 'done', items: session.items, index: 0 });
    })();
    return () => {
      active = false;
    };
  }, [uc, chapterId]);

  const advance = useCallback(
    async (grade: ReviewGrade) => {
      const now = Date.now();
      const current = state.items[state.index];
      if (current) {
        await uc.submitReview.execute({ itemId: current.id, chapterId: current.chapterId, grade, now });
      }
      // Count today as studied on the first graded item of the session.
      if (!recorded.current) {
        recorded.current = true;
        setStreak(await uc.recordStudyDay.execute({ now }));
      }
      setState((s) => {
        const next = s.index + 1;
        return next >= s.items.length ? { ...s, phase: 'done' } : { ...s, index: next };
      });
    },
    [state.items, state.index, uc],
  );

  return {
    phase: state.phase,
    items: state.items,
    index: state.index,
    current: state.items[state.index] ?? null,
    streak,
    advance,
  };
}
