import { describe, it, expect } from 'vitest';
import { OUTCOME_PRIORITY_UNTIL, outcomePriorityActive } from './outcomePriority.js';

// A temporary change that someone has to remember to undo is a permanent
// change. This is the guard that it really does expire.

describe('the outcome ask jumping the queue', () => {
  it('is on while the backlog drains', () => {
    expect(outcomePriorityActive(new Date('2026-10-08T12:00:00Z'))).toBe(true);
    expect(outcomePriorityActive(new Date('2026-10-20T23:59:00Z'))).toBe(true);
  });

  it('stops on its own, with nobody remembering', () => {
    expect(outcomePriorityActive(new Date('2026-10-21T00:01:00Z'))).toBe(false);
    expect(outcomePriorityActive(new Date('2027-01-01T12:00:00Z'))).toBe(false);
  });

  it('is two weeks, not a year', () => {
    const until = new Date(`${OUTCOME_PRIORITY_UNTIL}T00:00:00Z`);
    const from = new Date('2026-10-07T00:00:00Z');
    expect(Math.round((until - from) / 86400000)).toBe(14);
  });

  it('a restart does not extend it', () => {
    // The date is fixed in the file, not computed from boot time. Were it
    // relative, every deploy would start the fortnight again.
    expect(OUTCOME_PRIORITY_UNTIL).toMatch(/^\d{4}-\d{2}-\d{2}$/);
  });
});
