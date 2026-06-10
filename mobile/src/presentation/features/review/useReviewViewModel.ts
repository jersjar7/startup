import { useCallback, useEffect, useState } from 'react';
import { useUseCases } from '@/di/useUseCases';
import type { SessionItem } from '@/domain/entities/session';
import type { ReviewGrade } from '@/domain/entities/review';

type Phase = 'loading' | 'reviewing' | 'done';

interface ReviewState {
  phase: Phase;
  items: readonly SessionItem[];
  index: number;
  revealed: boolean;
}

// Drives one bounded review session: reveal-gated retrieval, then a self-grade
// that writes back through SubmitReview → the spaced-repetition scheduler.
export function useReviewViewModel() {
  const uc = useUseCases();
  const [state, setState] = useState<ReviewState>({
    phase: 'loading',
    items: [],
    index: 0,
    revealed: false,
  });

  useEffect(() => {
    let active = true;
    void (async () => {
      const now = Date.now();
      const plan = await uc.computeStudyPlan.execute({ now });
      const session = await uc.getDailySession.execute({ now, cardTarget: plan?.dailyCardTarget ?? 9 });
      if (!active) return;
      setState({
        phase: session.items.length > 0 ? 'reviewing' : 'done',
        items: session.items,
        index: 0,
        revealed: false,
      });
    })();
    return () => {
      active = false;
    };
  }, [uc]);

  const reveal = useCallback(() => {
    setState((s) => ({ ...s, revealed: true }));
  }, []);

  const grade = useCallback(
    async (g: ReviewGrade) => {
      const current = state.items[state.index];
      if (current) {
        await uc.submitReview.execute({ itemId: current.id, grade: g, now: Date.now() });
      }
      setState((s) => {
        const next = s.index + 1;
        return next >= s.items.length
          ? { ...s, phase: 'done' }
          : { ...s, index: next, revealed: false };
      });
    },
    [state.items, state.index, uc],
  );

  return {
    phase: state.phase,
    items: state.items,
    index: state.index,
    revealed: state.revealed,
    current: state.items[state.index] ?? null,
    reveal,
    grade,
  };
}
