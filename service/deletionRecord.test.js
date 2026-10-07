import { describe, it, expect } from 'vitest';
import {
  DELETION_REASONS,
  ageBucket,
  deletionRecord,
  isKnownReason,
} from './deletionRecord.js';

// Deleting an account removes every trace of the person, and that is not
// changing. This keeps a tally so the total stops dropping for reasons nobody
// can explain. The hard rule, and most of what is tested here: a row must never
// be able to point back at who it was.

const user = {
  email: 'someone@school.edu',
  firstName: 'Jerson',
  lastName: 'Garcia',
  _id: 'abc123',
  createdAt: new Date('2026-09-01'),
  emailVerified: true,
  acquisition: { channel: 'search', referrer: 'https://google.com/?q=fe+exam' },
};
const now = new Date('2026-10-06T12:00:00Z');

describe('a row can never identify anybody', () => {
  it('carries no email, name or id', () => {
    const r = deletionRecord(user, { reason: 'user', now });
    const asText = JSON.stringify(r);
    expect(asText).not.toContain('someone@school.edu');
    expect(asText).not.toContain('Jerson');
    expect(asText).not.toContain('Garcia');
    expect(asText).not.toContain('abc123');
    expect(asText).not.toContain('@');
  });

  it('keeps the channel but never the referring URL', () => {
    // "search" is a bucket. The referrer is a link that can carry a query.
    const r = deletionRecord(user, { reason: 'user', now });
    expect(r.source).toBe('search');
    expect(JSON.stringify(r)).not.toContain('google.com');
  });

  it('has only the fields it is supposed to have', () => {
    // A guard against someone adding a convenient field later. Every field here
    // survives a deletion, so the list is the whole agreement.
    expect(Object.keys(deletionRecord(user, { reason: 'user', now })).sort())
      .toEqual(['ageBucket', 'at', 'day', 'hadPurchased', 'reason', 'source', 'wasVerified']);
  });

  it('buckets the lifetime rather than storing it exactly', () => {
    // An exact lifetime plus an exact date is close to a fingerprint, and the
    // question is only ever "quickly or after months".
    expect(deletionRecord(user, { reason: 'user', now }).ageBucket)
      .toBe('under-three-months');
  });
});

describe('why it went', () => {
  it('separates somebody leaving from our own purge', () => {
    // Most deletions are the lifecycle job removing unverified signups after
    // thirty days. Counting those as people leaving would be wrong.
    expect(deletionRecord(user, { reason: 'user', now }).reason).toBe('user');
    expect(deletionRecord(user, { reason: 'stalePurge', now }).reason).toBe('stale-purge');
  });

  it('records an unfamiliar reason rather than dropping the row', () => {
    expect(deletionRecord(user, { reason: 'something-new', now }).reason)
      .toBe('something-new');
  });

  it('knows the reasons it was built for', () => {
    expect(isKnownReason('user')).toBe(true);
    expect(isKnownReason('stale-purge')).toBe(true);
    expect(isKnownReason('nonsense')).toBe(false);
    expect(Object.keys(DELETION_REASONS)).toHaveLength(2);
  });
});

describe('what the counts can answer', () => {
  it('separates signed-up-and-vanished from used-it-and-left', () => {
    expect(deletionRecord({ ...user, emailVerified: false }, { reason: 'user', now }).wasVerified)
      .toBe(false);
    expect(deletionRecord(user, { reason: 'user', now }).wasVerified).toBe(true);
  });

  it('flags a paying customer, which is rare enough to lose in a count', () => {
    expect(deletionRecord({ ...user, hasPurchased: true }, { reason: 'user', now }).hadPurchased)
      .toBe(true);
    expect(deletionRecord(user, { reason: 'user', now }).hadPurchased).toBe(false);
  });

  it('stamps the calendar day, so a daily count needs no date arithmetic', () => {
    expect(deletionRecord(user, { reason: 'user', now }).day).toBe('2026-10-06');
  });
});

describe('the age buckets', () => {
  const at = (iso) => ageBucket(new Date(iso), now);

  it('name the spans somebody would actually ask about', () => {
    expect(at('2026-10-06T01:00:00Z')).toBe('same-day');
    expect(at('2026-10-03')).toBe('under-a-week');
    expect(at('2026-09-20')).toBe('under-a-month');
    expect(at('2026-08-20')).toBe('under-three-months');
    expect(at('2026-01-01')).toBe('over-three-months');
  });

  it('say so plainly when the account had no creation date', () => {
    expect(ageBucket(null, now)).toBe('unknown');
    expect(ageBucket(undefined, now)).toBe('unknown');
    expect(ageBucket('not a date', now)).toBe('unknown');
  });

  it('does not invent a bucket for a date in the future', () => {
    expect(ageBucket(new Date('2027-01-01'), now)).toBe('unknown');
  });
});

describe('when there is no user', () => {
  it('writes nothing rather than an empty row', () => {
    expect(deletionRecord(null, { reason: 'user', now })).toBeNull();
    expect(deletionRecord(undefined, { reason: 'user', now })).toBeNull();
  });
});
