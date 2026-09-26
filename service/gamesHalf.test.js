import { describe, it, expect } from 'vitest';
import { clearedGames, gamesIn, parseGameItem } from './gamesHalf.js';

const ev = (itemId, grade = 'gotIt', source = 'ios') => ({ itemId, grade, source });

describe('cleared games', () => {
  it('knows every chapter of the catalog', () => {
    expect(Object.keys(gamesIn('mathematics')).length).toBe(48);
    expect(gamesIn('mathematics')['perpendicular-flip']).toBe(8);
    expect(gamesIn('nowhere')).toEqual({});
  });

  it('reads the game and round out of a phone item id', () => {
    expect(parseGameItem('math-slq-q2:perpendicular-flip:3')).toEqual({ problemId: 'math-slq-q2', gameId: 'perpendicular-flip', round: 3 });
    expect(parseGameItem('math-slq-q1:fc')).toBeNull();
    expect(parseGameItem('math-slq-q1')).toBeNull();
  });

  it('clears a game only when every round has a right answer', () => {
    const seven = Array.from({ length: 7 }, (_, i) => ev(`math-slq-q2:perpendicular-flip:${i + 1}`));
    expect(clearedGames('mathematics', seven)).toEqual([]);
    const eight = [...seven, ev('math-slq-q2:perpendicular-flip:8')];
    expect(clearedGames('mathematics', eight)).toEqual(['perpendicular-flip']);
    // A miss on a round does not clear it; a later right answer does.
    const withMiss = [...seven, ev('math-slq-q2:perpendicular-flip:8', 'forgot')];
    expect(clearedGames('mathematics', withMiss)).toEqual([]);
    expect(clearedGames('mathematics', [...withMiss, ev('math-slq-q2:perpendicular-flip:8')])).toEqual(['perpendicular-flip']);
  });

  it('ignores web events, cards and games from other chapters', () => {
    const eight = Array.from({ length: 8 }, (_, i) => ev(`math-slq-q2:perpendicular-flip:${i + 1}`, 'gotIt', 'web'));
    expect(clearedGames('mathematics', eight)).toEqual([]);
    expect(clearedGames('statistics', eight.map((e) => ({ ...e, source: 'ios' })))).toEqual([]);
  });

  it('knows how many games a chapter has', () => {
    expect(Object.keys(gamesIn('construction')).length).toBe(10);
    expect(Object.keys(gamesIn('mathematics')).length).toBe(48);
  });
});
