import { describe, it, expect, beforeEach } from 'vitest';
const fs = require('fs');
const path = require('path');
const DB = require('./database.js');
const { resolveSimAccess, hasSimAccess } = require('./simAccess.js');
const { decideSimAccess } = require('./schoolAccess.js');
const { emailChangeUpdate } = require('./emailChange.js');

// The one entitlement check (ADR 0040), with the database stood in.

const DAY = 24 * 60 * 60 * 1000;
let calls;
let licenses;
let purchased;

beforeEach(() => {
  calls = { find: 0, claims: 0, claim: 0 };
  purchased = false;
  licenses = [{
    _id: 'lic1', schoolName: 'BYU', domains: ['byu.edu'], seatCap: 2, seatsUsed: 0,
    startsAt: new Date(Date.now() - DAY), endsAt: new Date(Date.now() + DAY),
  }];
  Object.assign(DB, {
    hasPurchased: async () => purchased,
    findLicensesForDomains: async (d) => { calls.find += 1; return licenses.filter((l) => l.domains.some((x) => d.includes(x))); },
    getClaimsForUser: async () => { calls.claims += 1; return []; },
    claimSeat: async (l) => { calls.claim += 1; l.seatsUsed += 1; return true; },
  });
});

const student = (over = {}) => ({ _id: 'u1', email: 'me@gmail.com', emailVerified: true, studentVerified: true, verifiedStudentEmail: 'me@byu.edu', ...over });

describe('resolveSimAccess', () => {
  it('a purchase answers without looking at schools', async () => {
    purchased = true;
    expect(await resolveSimAccess(student(), { claim: true })).toMatchObject({ access: true, via: 'purchase' });
    expect(calls).toEqual({ find: 0, claims: 0, claim: 0 });
  });

  it('claim: false answers "would have it" and spends no seat', async () => {
    expect(await hasSimAccess(student())).toBe(true);
    expect(calls.claim).toBe(0);
    expect(licenses[0].seatsUsed).toBe(0);
  });

  it('claim: true takes the seat', async () => {
    expect(await resolveSimAccess(student(), { claim: true })).toMatchObject({ access: true, via: 'school', needsClaim: false });
    expect(calls.claim).toBe(1);
  });

  it('a student with only non-school addresses costs no query', async () => {
    expect(await hasSimAccess({ _id: 'u2', email: 'a@gmail.com', emailVerified: true })).toBe(false);
    expect(calls.find).toBe(0);
  });

  it('a lost race for the last seat ends as seats_full', async () => {
    DB.claimSeat = async () => { calls.claim += 1; licenses[0].seatsUsed = licenses[0].seatCap; return false; };
    const d = await resolveSimAccess(student(), { claim: true });
    expect(d).toMatchObject({ access: false, reason: 'seats_full' });
  });

  it('no user, no access', async () => {
    expect(await hasSimAccess(null)).toBe(false);
  });
});

describe('account changes', () => {
  it('changing the account address drops access that rode on it until it is verified again', () => {
    const lic = licenses[0];
    const before = { _id: 'u', email: 'sam@byu.edu', emailVerified: true };
    expect(decideSimAccess({ user: before, licenses: [lic] }).access).toBe(true);
    const after = { ...before, ...emailChangeUpdate('sam@byu.edu.evil.com') };
    expect(decideSimAccess({ user: after, licenses: [lic] }).access).toBe(false);
    const moved = { ...before, ...emailChangeUpdate('sam2@byu.edu') };
    expect(decideSimAccess({ user: moved, licenses: [lic] })).toMatchObject({ access: false, reason: 'unverified' });
  });

  it('account deletion releases the seat claim, giving the seat back', () => {
    const src = fs.readFileSync(path.join(__dirname, 'db/accountDeletion.js'), 'utf8');
    expect(src).toContain('releaseClaimsForDeletedUser(userId)');
  });

  it('license access never writes a purchase or the purchase flag', () => {
    for (const f of ['simAccess.js', 'schoolAccess.js', 'db/schoolLicenses.js']) {
      const src = fs.readFileSync(path.join(__dirname, f), 'utf8');
      expect(src, f).not.toMatch(/recordPurchase|purchasesCollection|examSimAccess:\s*true/);
    }
  });
});
