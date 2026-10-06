import { describe, it, expect } from 'vitest';
import {
  canSeeCard,
  cardPayload,
  mayNameAccount,
  splitName,
} from './passCardAccess.js';

// The card is reached from an email link with no sign in, so the rules here are
// about what that link is allowed to do. Two of them are the whole reason the
// no-sign-in design is safe: the link can never show a card to somebody who did
// not pass, and it can never rename an account that already has a name.

const passed = (extra = {}) => ({
  email: 'a@b.com',
  examOutcome: { answeredAt: new Date('2026-10-20'), sat: true, passed: true },
  ...extra,
});

describe('who has a card', () => {
  it('somebody who passed', () => {
    expect(canSeeCard(passed())).toBe(true);
  });

  it('nobody who failed', () => {
    expect(canSeeCard({ examOutcome: { answeredAt: new Date(), sat: true, passed: false } }))
      .toBe(false);
  });

  it('nobody who did not sit it', () => {
    expect(canSeeCard({ examOutcome: { answeredAt: new Date(), sat: false, passed: null } }))
      .toBe(false);
  });

  it('nobody who has not answered, however the URL was reached', () => {
    // A guessed or edited link must not manufacture a card. The check is on the
    // recorded outcome, never on the query string that brought them here.
    expect(canSeeCard({ examOutcome: { sat: true, passed: true } })).toBe(false);
    expect(canSeeCard({})).toBe(false);
    expect(canSeeCard(null)).toBe(false);
  });
});

describe('what the page is given', () => {
  it('the name and the month, and nothing else', () => {
    const p = cardPayload(passed({ firstName: 'Jerson', lastName: 'Garcia' }));
    expect(Object.keys(p).sort()).toEqual(['answeredAt', 'firstName', 'hasName', 'lastName']);
  });

  it('never the email address', () => {
    // The whole no-sign-in design rests on the card carrying nothing private.
    const p = cardPayload(passed({ firstName: 'Jerson' }));
    expect(JSON.stringify(p)).not.toContain('@');
  });

  it('never any study record', () => {
    const p = cardPayload(passed({
      firstName: 'Jerson',
      mastery: { statics: 71 },
      examOutcome: { answeredAt: new Date(), sat: true, passed: true, attemptNumber: 2 },
    }));
    expect(JSON.stringify(p)).not.toMatch(/mastery|statics|attempt/i);
  });

  it('says plainly when there is no name to draw', () => {
    const p = cardPayload(passed());
    expect(p.hasName).toBe(false);
    expect(p.firstName).toBeNull();
  });

  it('is nothing at all for somebody with no card', () => {
    expect(cardPayload({ examOutcome: { answeredAt: new Date(), sat: true, passed: false } }))
      .toBeNull();
  });
});

describe('naming the account from the card page', () => {
  it('fills a blank, which is the common case', () => {
    // Account creation has never collected a name, so most people arrive here
    // with none.
    expect(mayNameAccount(passed(), 'Jerson Garcia')).toBe(true);
  });

  it('cannot rename an account that already has one', () => {
    // A forwarded email must not let somebody else rename the account.
    expect(mayNameAccount(passed({ firstName: 'Jerson' }), 'Someone Else')).toBe(false);
    expect(mayNameAccount(passed({ lastName: 'Garcia' }), 'Someone Else')).toBe(false);
  });

  it('cannot name an account that has no card', () => {
    expect(mayNameAccount({ examOutcome: { sat: true, passed: false } }, 'Jerson')).toBe(false);
  });

  it('refuses a name that is not one', () => {
    for (const bad of ['', '   ', '!!!', '1234', null, undefined]) {
      expect(mayNameAccount(passed(), bad)).toBe(false);
    }
  });
});

describe('one field on screen, two on the account', () => {
  it('splits at the first space', () => {
    expect(splitName('Jerson Garcia')).toEqual({ firstName: 'Jerson', lastName: 'Garcia' });
  });

  it('keeps a compound surname together', () => {
    expect(splitName('Jerson Garcia Lopez'))
      .toEqual({ firstName: 'Jerson', lastName: 'Garcia Lopez' });
  });

  it('takes a single name', () => {
    expect(splitName('Jerson')).toEqual({ firstName: 'Jerson', lastName: null });
  });

  it('keeps accents and hyphens, which are names', () => {
    expect(splitName('José Martínez-Ruiz'))
      .toEqual({ firstName: 'José', lastName: 'Martínez-Ruiz' });
  });

  it('strips what is not a name rather than storing it', () => {
    expect(splitName('<script>Jerson</script>')).toEqual({
      firstName: 'scriptJersonscript',
      lastName: null,
    });
  });

  it('is nothing when there is nothing', () => {
    expect(splitName('   ')).toBeNull();
    expect(splitName(null)).toBeNull();
  });
});
