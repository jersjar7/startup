import { describe, it, expect } from 'vitest';
import fs from 'node:fs';
import path from 'node:path';
import { emailChangeProblem, emailChangeUpdate, MAX_EMAIL } from './emailChange.js';

// Until 2026-10-07 an email address could never be changed, and "resend
// verification" mailed the same broken one, so anybody who mistyped theirs at
// signup was stuck for good. One real account has been in that state since
// 2 October on enail.sc.edu, a typo for email.sc.edu with no MX record.

const normalize = (s) => String(s || '').trim().toLowerCase();
const ask = (over = {}) => emailChangeProblem({
  current: 'old@school.edu',
  next: 'new@school.edu',
  password: 'hunter2',
  normalize,
  ...over,
});

describe('what is refused, and what it says', () => {
  it('allows a real change', () => {
    expect(ask()).toBeNull();
  });

  it('will not move an account without the password', () => {
    // Five minutes at an unlocked laptop is otherwise enough to move somebody's
    // account to your own address and take it over.
    expect(ask({ password: '' })).toMatch(/password/i);
    expect(ask({ password: undefined })).toMatch(/password/i);
  });

  it('asks for an address when none was given', () => {
    expect(ask({ next: '' })).toMatch(/enter the new email/i);
    expect(ask({ next: '   ' })).toMatch(/enter the new email/i);
  });

  it('refuses something that is not an address', () => {
    for (const bad of ['nope', 'a@b', 'a b@c.com', '@school.edu', 'a@@b.com']) {
      expect(ask({ next: bad }), `"${bad}" was accepted`).toMatch(/does not look like/i);
    }
  });

  it('takes the addresses people actually have', () => {
    for (const ok of [
      'a.b@school.edu',
      'first+tag@gmail.com',
      'someone@mail.fresnostate.edu',
      'x@uni.ac.uk',
    ]) {
      expect(ask({ next: ok }), `"${ok}" was refused`).toBeNull();
    }
  });

  it('says so plainly when it is the address they already have', () => {
    expect(ask({ next: 'old@school.edu' })).toMatch(/already your email/i);
    // Case and padding are the same address, not a change.
    expect(ask({ next: '  OLD@School.edu ' })).toMatch(/already your email/i);
  });

  it('refuses an address longer than the standard allows', () => {
    expect(ask({ next: `${'a'.repeat(MAX_EMAIL)}@b.com` })).toMatch(/too long/i);
  });
});

describe('what the account becomes', () => {
  it('is unverified again, whatever it was before', () => {
    // The new address is unproven. Carrying the old flag across would mean we
    // never find out this one is wrong either, which is the bug being fixed.
    const u = emailChangeUpdate('new@school.edu');
    expect(u.email).toBe('new@school.edu');
    expect(u.emailVerified).toBe(false);
    expect(u.verifiedAt).toBeNull();
  });

  it('lets the one-off verification reminder fire again', () => {
    // Somebody who already had their single reminder would otherwise never be
    // nudged about the address they just fixed.
    expect(emailChangeUpdate('new@school.edu').verifyReminderSentAt).toBeNull();
  });

  it('keeps the unsubscribe and outcome tokens', () => {
    // They are capabilities tied to the person, not the address. Rotating them
    // would break the links in any email already sitting in their inbox.
    const u = emailChangeUpdate('new@school.edu');
    expect(u).not.toHaveProperty('unsubToken');
    expect(u).not.toHaveProperty('outcomeToken');
  });

  it('records when it happened', () => {
    const now = new Date('2026-10-07T12:00:00Z');
    expect(emailChangeUpdate('new@school.edu', { now }).emailChangedAt).toBe(now);
  });
});

describe('the rename must reach everything the deletion reaches', () => {
  // The address is the KEY in nine collections. A rename that misses one
  // orphans that part of somebody's history and nothing would report it. These
  // two lists are maintained by hand, so this compares them.
  const read = (f) => fs.readFileSync(path.join(import.meta.dirname, 'db', f), 'utf8');
  const collectionsIn = (src) =>
    new Set((src.match(/([a-zA-Z]+)Collection\.(?:deleteOne|deleteMany|updateMany)\(\{ email \}/g) || [])
      .map((m) => m.split('Collection')[0]));

  it('covers every email-keyed collection the deletion cascade does', () => {
    const deleted = collectionsIn(read('accountDeletion.js'));
    const renamed = new Set(
      (read('accountEmail.js').match(/\['([a-zA-Z]+)',/g) || [])
        .map((m) => m.slice(2, -2)),
    );
    // The user document is handled separately in both files.
    deleted.delete('user');
    const missing = [...deleted].filter((c) => !renamed.has(c));
    expect(missing, `renames miss: ${missing.join(', ')}`).toEqual([]);
  });
});
