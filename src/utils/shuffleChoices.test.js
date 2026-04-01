import { describe, it, expect } from 'vitest';
import { renderHook } from '@testing-library/react';
import { useShuffledChoices } from './shuffleChoices';

describe('useShuffledChoices', () => {
  const problem = {
    id: 'p1',
    correctAnswerId: 'c2',
    choices: [
      { id: 'c1', text: 'Option 1' },
      { id: 'c2', text: 'Option 2' },
      { id: 'c3', text: 'Option 3' },
      { id: 'c4', text: 'Option 4' },
    ],
  };

  it('returns empty choices and empty label when problem is null', () => {
    const { result } = renderHook(() => useShuffledChoices(null));
    expect(result.current.choices).toEqual([]);
    expect(result.current.correctLabel).toBe('');
  });

  it('returns all 4 choices with labels A-D', () => {
    const { result } = renderHook(() => useShuffledChoices(problem));
    expect(result.current.choices).toHaveLength(4);
    const labels = result.current.choices.map((c) => c.label);
    expect(labels).toEqual(['A', 'B', 'C', 'D']);
  });

  it('preserves all original choice IDs', () => {
    const { result } = renderHook(() => useShuffledChoices(problem));
    const ids = result.current.choices.map((c) => c.id).sort();
    expect(ids).toEqual(['c1', 'c2', 'c3', 'c4']);
  });

  it('assigns correctLabel to the label of the correct answer', () => {
    const { result } = renderHook(() => useShuffledChoices(problem));
    const correctChoice = result.current.choices.find((c) => c.id === 'c2');
    expect(result.current.correctLabel).toBe(correctChoice.label);
  });

  it('preserves choice text', () => {
    const { result } = renderHook(() => useShuffledChoices(problem));
    const texts = result.current.choices.map((c) => c.text).sort();
    expect(texts).toEqual(['Option 1', 'Option 2', 'Option 3', 'Option 4']);
  });

  it('returns stable result for same problem ID', () => {
    const { result, rerender } = renderHook(({ p }) => useShuffledChoices(p), {
      initialProps: { p: problem },
    });
    const first = result.current.choices.map((c) => c.id);
    rerender({ p: problem });
    const second = result.current.choices.map((c) => c.id);
    expect(first).toEqual(second);
  });
});
