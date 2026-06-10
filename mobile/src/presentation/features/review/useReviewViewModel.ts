import { useCallback, useEffect, useState } from 'react';
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
export function useReviewViewModel() {
  const uc = useUseCases();
  const [state, setState] = useState<ReviewState>({ phase: 'loading', items: [], index: 0 });

  useEffect(() => {
    let active = true;
    void (async () => {
      const now = Date.now();
      const plan = await uc.computeStudyPlan.execute({ now });
      const session = await uc.getDailySession.execute({ now, cardTarget: plan?.dailyCardTarget ?? 9 });
      if (!active) return;
      setState({ phase: session.items.length > 0 ? 'reviewing' : 'done', items: session.items, index: 0 });
    })();
    return () => {
      active = false;
    };
  }, [uc]);

  const advance = useCallback(
    async (grade: ReviewGrade) => {
      const current = state.items[state.index];
      if (current) {
        await uc.submitReview.execute({ itemId: current.id, grade, now: Date.now() });
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
    advance,
  };
}
