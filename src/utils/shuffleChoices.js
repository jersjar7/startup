import { useMemo } from 'react';

const LABELS = ['A', 'B', 'C', 'D'];

function shuffle(arr) {
  const copy = [...arr];
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

export function useShuffledChoices(problem) {
  return useMemo(() => {
    if (!problem) return { choices: [], correctLabel: '' };

    const shuffled = shuffle(problem.choices).map((c, i) => ({
      ...c,
      label: LABELS[i],
    }));

    const correct = shuffled.find((c) => c.id === problem.correctAnswerId);

    return {
      choices: shuffled,
      correctLabel: correct?.label ?? '',
    };
  }, [problem?.id]);
}
