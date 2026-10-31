import { describe, it, expect } from 'vitest';
import { validateWaitlist, summarize } from './waitlist.js';

describe('validateWaitlist', () => {
  it('cleans the address and keeps where the signup came from', () => {
    const r = validateWaitlist({ email: ' Sam@Firm.COM ', when: 'before-2027-04', place: 'top', utmSource: 'Reddit', utmMedium: 'post', referrer: 'https://www.reddit.com/r/PE_Exam' });
    expect(r.ok).toBe(true);
    expect(r.value).toMatchObject({ email: 'sam@firm.com', exam: 'pe-civil-wre', when: 'before-2027-04', place: 'top', utmSource: 'reddit', utmMedium: 'post', channel: 'utm: reddit' });
  });

  it('falls back to the referrer when the link was not tagged', () => {
    expect(validateWaitlist({ email: 'a@b.co', referrer: 'https://www.google.com/' }).value.channel).toBe('organic search: Google');
    expect(validateWaitlist({ email: 'a@b.co' }).value.channel).toBe('direct');
  });

  it('turns away a bad address and ignores answers it does not know', () => {
    expect(validateWaitlist({ email: 'nope' }).ok).toBe(false);
    expect(validateWaitlist(null).ok).toBe(false);
    const r = validateWaitlist({ email: 'a@b.co', when: 'someday', place: 'side', exam: 'pe-mech' });
    expect(r.value).toMatchObject({ when: null, place: null, exam: 'pe-civil-wre' });
  });

  it('thanks a bot that fills the hidden field and stores nothing', () => {
    expect(validateWaitlist({ email: 'a@b.co', website: 'spam.example' })).toEqual({ ok: true, spam: true });
  });
});

describe('summarize', () => {
  it('counts signups by source and timing without any addresses', () => {
    const now = new Date('2026-11-10T12:00:00Z');
    const s = summarize([
      { channel: 'utm: reddit', when: 'before-2027-04', createdAt: new Date('2026-11-09'), hasFeAccount: false },
      { channel: 'utm: reddit', when: null, createdAt: new Date('2026-10-01'), optedOut: true },
      { channel: 'organic search: Google', when: '2028-plus', createdAt: new Date('2026-11-08'), hasFeAccount: true },
    ], now);
    expect(s).toEqual({
      total: 3, subscribed: 2, lastWeek: 2, withFeAccount: 1,
      byChannel: { 'utm: reddit': 2, 'organic search: Google': 1 },
      byWhen: { 'Before April 2027': 1, 'Not answered': 1, '2028 or later': 1 },
    });
  });
});
