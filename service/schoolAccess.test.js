import { describe, it, expect } from 'vitest';
const {
  normalizeDomain, emailDomain, isLicensableDomain, verifiedSchoolEmails, verifiedSchoolDomains,
  licenseCoversDomain, isLicenseActive, licenseState, seatsLeft, decideSimAccess, publicSchool,
} = require('./schoolAccess.js');

// The rule behind school site licenses (ADR 0040), from facts in hand.

const NOW = new Date('2026-11-06T12:00:00Z');
const license = (over = {}) => ({
  _id: 'lic1',
  schoolName: 'Brigham Young University',
  domains: ['byu.edu'],
  startsAt: new Date('2026-08-01T00:00:00Z'),
  endsAt: new Date('2027-08-01T00:00:00Z'),
  seatCap: 500,
  seatsUsed: 10,
  contactName: 'Dr. Ames',
  contactEmail: 'ames@byu.edu',
  notes: 'paid by PO 123',
  ...over,
});
const codeVerified = (school, over = {}) => ({
  _id: 'u1', email: 'me@gmail.com', emailVerified: true,
  studentVerified: true, verifiedStudentEmail: school, ...over,
});

describe('domains', () => {
  it('normalizes case, spaces, a leading @ and a trailing dot', () => {
    expect(normalizeDomain('  @BYU.Edu. ')).toBe('byu.edu');
    expect(normalizeDomain('Student.BYU.edu')).toBe('student.byu.edu');
  });

  it('rejects things that are not domains', () => {
    for (const bad of ['', 'byu', 'byu..edu', '-byu.edu', 'byu edu', 'by u.edu', 'byu.edu/x', null, undefined]) {
      expect(normalizeDomain(bad)).toBe('');
    }
  });

  it('takes the domain of an address, lowercased', () => {
    expect(emailDomain('Jane.Doe@BYU.EDU')).toBe('byu.edu');
    expect(emailDomain('  a@student.byu.edu ')).toBe('student.byu.edu');
    expect(emailDomain('no-at-sign')).toBe('');
    expect(emailDomain('a@b@byu.edu')).toBe('');
    expect(emailDomain('@byu.edu')).toBe('');
  });

  it('only licenses academic domains', () => {
    expect(isLicensableDomain('byu.edu')).toBe(true);
    expect(isLicensableDomain('ox.ac.uk')).toBe(true);
    expect(isLicensableDomain('gmail.com')).toBe(false);
    expect(isLicensableDomain('byu.edu.evil.com')).toBe(false);
  });
});

describe('licenseCoversDomain: exact match only', () => {
  const l = license({ domains: ['byu.edu'] });

  it('matches regardless of case', () => {
    expect(licenseCoversDomain(l, 'BYU.EDU')).toBe(true);
    expect(licenseCoversDomain(license({ domains: ['BYU.edu'] }), 'byu.edu')).toBe(true);
  });

  it('does not admit a subdomain the license does not list', () => {
    expect(licenseCoversDomain(l, 'student.byu.edu')).toBe(false);
  });

  it('admits a subdomain the license lists', () => {
    expect(licenseCoversDomain(license({ domains: ['byu.edu', 'student.byu.edu'] }), 'student.byu.edu')).toBe(true);
  });

  it('never matches lookalikes', () => {
    for (const d of ['byu.edu.evil.com', 'evilbyu.edu', 'byu.edu.co', 'xbyu.edu', 'byu.ed', 'byu-edu.com']) {
      expect(licenseCoversDomain(l, d)).toBe(false);
    }
  });
});

describe('verified school addresses', () => {
  it('counts a code-verified school address', () => {
    expect(verifiedSchoolEmails(codeVerified('Jane@BYU.edu'))).toContain('jane@byu.edu');
  });

  it('counts a verified account address', () => {
    expect(verifiedSchoolDomains({ email: 'jane@byu.edu', emailVerified: true })).toEqual(['byu.edu']);
  });

  it('never counts an address that was only typed', () => {
    // A code was requested but never confirmed: the address sits in
    // studentCodeEmail, studentVerified is not true.
    const u = { email: 'me@gmail.com', emailVerified: false, studentCodeEmail: 'jane@byu.edu' };
    expect(verifiedSchoolEmails(u)).toEqual([]);
    expect(verifiedSchoolEmails({ email: 'jane@byu.edu', emailVerified: false })).toEqual([]);
    expect(verifiedSchoolEmails({ verifiedStudentEmail: 'jane@byu.edu', studentVerified: false })).toEqual([]);
  });

  it('handles a missing user', () => {
    expect(verifiedSchoolEmails(null)).toEqual([]);
  });
});

describe('license dates', () => {
  it('is active from startsAt up to (not including) endsAt', () => {
    const l = license();
    expect(isLicenseActive(l, NOW)).toBe(true);
    expect(isLicenseActive(l, l.startsAt)).toBe(true);
    expect(isLicenseActive(l, l.endsAt)).toBe(false);
    expect(isLicenseActive(l, new Date('2026-07-31T23:59:59Z'))).toBe(false);
  });

  it('is not active once ended early, or with bad dates', () => {
    expect(isLicenseActive(license({ endedAt: new Date('2026-10-01') }), NOW)).toBe(false);
    expect(isLicenseActive(license({ startsAt: null }), NOW)).toBe(false);
    expect(isLicenseActive(license({ endsAt: 'nonsense' }), NOW)).toBe(false);
  });

  it('names its state for the admin list', () => {
    expect(licenseState(license(), NOW)).toBe('active');
    expect(licenseState(license({ startsAt: new Date('2027-01-01') }), NOW)).toBe('scheduled');
    expect(licenseState(license({ endsAt: new Date('2026-11-01') }), NOW)).toBe('expired');
    expect(licenseState(license({ endedAt: new Date() }), NOW)).toBe('ended');
  });

  it('counts seats left, never below zero', () => {
    expect(seatsLeft(license({ seatCap: 500, seatsUsed: 10 }))).toBe(490);
    expect(seatsLeft(license({ seatCap: 5, seatsUsed: 7 }))).toBe(0);
  });
});

describe('decideSimAccess', () => {
  it('a purchase grants access, whatever the schools say', () => {
    const d = decideSimAccess({ purchased: true, user: codeVerified('a@gmail.com'), licenses: [], now: NOW });
    expect(d).toMatchObject({ access: true, via: 'purchase', needsClaim: false });
  });

  it('a code-verified address on a licensed domain grants access and asks for a seat', () => {
    const d = decideSimAccess({ user: codeVerified('jane@byu.edu'), licenses: [license()], now: NOW });
    expect(d).toMatchObject({ access: true, via: 'school', domain: 'byu.edu', needsClaim: true });
  });

  it('a seat already held needs no new claim', () => {
    const d = decideSimAccess({ user: codeVerified('jane@byu.edu'), licenses: [license()], claims: [{ licenseId: 'lic1' }], now: NOW });
    expect(d).toMatchObject({ access: true, via: 'school', needsClaim: false });
  });

  it('a verified account address on a licensed domain grants access', () => {
    const d = decideSimAccess({ user: { _id: 'u', email: 'Jane@BYU.edu', emailVerified: true }, licenses: [license()], now: NOW });
    expect(d).toMatchObject({ access: true, via: 'school' });
  });

  it('an unverified account address on a licensed domain does not, and says why', () => {
    const d = decideSimAccess({ user: { _id: 'u', email: 'jane@byu.edu', emailVerified: false }, licenses: [license()], now: NOW });
    expect(d).toMatchObject({ access: false, reason: 'unverified' });
    expect(d.license.schoolName).toBe('Brigham Young University');
  });

  it('the school on their profile points them at verification, never grants access', () => {
    const u = { _id: 'u', email: 'me@gmail.com', emailVerified: true, school: { name: 'Brigham Young University' } };
    const d = decideSimAccess({ user: u, licenses: [license()], hintDomains: ['byu.edu'], now: NOW });
    expect(d).toMatchObject({ access: false, reason: 'unverified', domain: 'byu.edu' });
  });

  it('a requested but unconfirmed school code does not', () => {
    const u = { _id: 'u', email: 'me@gmail.com', emailVerified: true, studentCodeEmail: 'jane@byu.edu' };
    expect(decideSimAccess({ user: u, licenses: [license()], now: NOW })).toMatchObject({ access: false, reason: 'none' });
  });

  it('a lookalike domain does not', () => {
    for (const addr of ['jane@byu.edu.evil.com', 'jane@evilbyu.edu', 'jane@student.byu.edu']) {
      const d = decideSimAccess({ user: codeVerified(addr), licenses: [license()], now: NOW });
      expect(d.access).toBe(false);
    }
  });

  it('a listed subdomain does', () => {
    const l = license({ domains: ['byu.edu', 'student.byu.edu'] });
    expect(decideSimAccess({ user: codeVerified('jane@student.byu.edu'), licenses: [l], now: NOW }).access).toBe(true);
  });

  it('an expired, ended or not-yet-started license does not', () => {
    for (const l of [
      license({ endsAt: new Date('2026-11-01') }),
      license({ endedAt: new Date('2026-10-01') }),
      license({ startsAt: new Date('2027-01-01') }),
    ]) {
      expect(decideSimAccess({ user: codeVerified('jane@byu.edu'), licenses: [l], now: NOW }).access).toBe(false);
    }
  });

  it('an expired license takes a held seat away too', () => {
    const l = license({ endsAt: new Date('2026-11-01') });
    const d = decideSimAccess({ user: codeVerified('jane@byu.edu'), licenses: [l], claims: [{ licenseId: 'lic1' }], now: NOW });
    expect(d.access).toBe(false);
  });

  it('a full license turns away a new student, and says so', () => {
    const l = license({ seatCap: 3, seatsUsed: 3 });
    const d = decideSimAccess({ user: codeVerified('jane@byu.edu'), licenses: [l], now: NOW });
    expect(d).toMatchObject({ access: false, reason: 'seats_full', domain: 'byu.edu' });
  });

  it('a full license keeps a student who already holds a seat', () => {
    const l = license({ seatCap: 3, seatsUsed: 3 });
    const d = decideSimAccess({ user: codeVerified('jane@byu.edu'), licenses: [l], claims: [{ licenseId: 'lic1' }], now: NOW });
    expect(d).toMatchObject({ access: true, needsClaim: false });
  });

  it('a lowered cap keeps the students already in', () => {
    const l = license({ seatCap: 1, seatsUsed: 4 });
    expect(decideSimAccess({ user: codeVerified('jane@byu.edu'), licenses: [l], claims: [{ licenseId: 'lic1' }], now: NOW }).access).toBe(true);
    expect(decideSimAccess({ user: codeVerified('new@byu.edu'), licenses: [l], now: NOW }).access).toBe(false);
  });

  it('falls through to a second license with room', () => {
    const full = license({ _id: 'a', seatCap: 1, seatsUsed: 1 });
    const open = license({ _id: 'b', seatCap: 10, seatsUsed: 1 });
    const d = decideSimAccess({ user: codeVerified('jane@byu.edu'), licenses: [full, open], now: NOW });
    expect(d).toMatchObject({ access: true, needsClaim: true });
    expect(d.license._id).toBe('b');
  });

  it('a refunded buyer at a licensed school gets in through the school', () => {
    // hasPurchased() is false after a refund (status 'refunded').
    const d = decideSimAccess({ purchased: false, user: codeVerified('jane@byu.edu'), licenses: [license()], now: NOW });
    expect(d).toMatchObject({ access: true, via: 'school' });
  });

  it('a refunded buyer at an unlicensed school has no access', () => {
    const d = decideSimAccess({ purchased: false, user: codeVerified('jane@utah.edu'), licenses: [license()], now: NOW });
    expect(d).toMatchObject({ access: false, reason: 'none' });
  });

  it('nobody, nothing', () => {
    expect(decideSimAccess()).toMatchObject({ access: false, reason: 'none' });
  });
});

describe('publicSchool', () => {
  it('never hands the browser the contact or the notes', () => {
    const p = publicSchool(license());
    expect(p).toEqual({ name: 'Brigham Young University', domains: ['byu.edu'], endsAt: license().endsAt });
    expect(JSON.stringify(p)).not.toMatch(/ames|PO 123/);
  });
});
