import { describe, it, expect } from 'vitest';
const { validEvent } = require('./routes/sync.js');

// The literal payload the Flutter game client sends
// (mobile/lib/features/games/game_sync.dart). If this test fails, the app's
// pushes are being rejected and game results stop reaching mastery.
const gameEvent = () => ({
  eventId: 'a3f19c02b4d54e6789ab01cd23ef4567',
  itemId: 'math-slq-q2:pf:1',
  chapterId: 'mathematics',
  grade: 'gotIt',
  source: 'ios',
  ts: 1757260000000,
  localDate: '2026-09-07',
});

describe('sync event contract (phone games)', () => {
  it('accepts what the game client sends', () => {
    expect(validEvent(gameEvent())).toBe(true);
  });

  it('accepts a missed round', () => {
    expect(validEvent({ ...gameEvent(), grade: 'forgot' })).toBe(true);
  });

  it('rejects a grade the app might invent', () => {
    expect(validEvent({ ...gameEvent(), grade: 'wrong' })).toBe(false);
  });

  it('rejects an unknown source', () => {
    expect(validEvent({ ...gameEvent(), source: 'game' })).toBe(false);
  });

  it('keeps the parent problem id readable from the item id', () => {
    expect(gameEvent().itemId.split(':')[0]).toBe('math-slq-q2');
  });
});
