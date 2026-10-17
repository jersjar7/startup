import { describe, it, expect } from 'vitest';
import { validateContact, overTheHourlyLimit, MAX_MESSAGE } from './contact.js';

describe('validateContact', () => {
  it('takes a signed-in message with the account address', () => {
    const r = validateContact({ message: '  Hi there ', source: 'app', build: '1144', email: 'other@x.com' }, 'me@byu.edu');
    expect(r).toEqual({
      ok: true,
      value: { email: 'me@byu.edu', name: null, message: 'Hi there', source: 'app', build: '1144', signedIn: true },
    });
  });

  it('needs an address from someone signed out, so a reply can go somewhere', () => {
    expect(validateContact({ message: 'Hi' }).ok).toBe(false);
    expect(validateContact({ message: 'Hi', email: 'not-an-address' }).ok).toBe(false);
    const r = validateContact({ message: 'Hi', email: ' Sam@School.EDU ', name: 'Sam' });
    expect(r.value).toMatchObject({ email: 'sam@school.edu', name: 'Sam', source: 'web', signedIn: false });
  });

  it('refuses an empty or overlong message', () => {
    expect(validateContact({ message: '   ' }, 'a@b.co').msg).toBe('Write a message first.');
    expect(validateContact({ message: 'x'.repeat(MAX_MESSAGE + 1) }, 'a@b.co').ok).toBe(false);
  });

  it('thanks a bot that filled the hidden field, and sends nothing', () => {
    expect(validateContact({ message: 'buy now', email: 'a@b.co', website: 'spam.example' })).toEqual({ ok: true, spam: true });
  });

  it('allows five an hour from one address', () => {
    expect(overTheHourlyLimit(4)).toBe(false);
    expect(overTheHourlyLimit(5)).toBe(true);
  });
});
