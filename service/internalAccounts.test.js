import { describe, it, expect } from 'vitest';
const { isExcluded, EXCLUDED_PATTERN, NOT_EXCLUDED, EXCLUDED_EMAILS } = require('./internalAccounts.js');

describe('internal account exclusion', () => {
  it('excludes the literal addresses', () => {
    for (const e of EXCLUDED_EMAILS) expect(isExcluded(e)).toBe(true);
  });

  // The whole point of this change. Plus-tagging is how test accounts get made
  // here, and a literal-string match let every one of them count as a real user
  // on the leaderboard, in the funnel and in the admin dashboard.
  it('excludes plus-aliases of an excluded address', () => {
    expect(isExcluded('admin+test1@oqupa.com')).toBe(true);
    expect(isExcluded('admin+test2@oqupa.com')).toBe(true);
    expect(isExcluded('admin+qa@oqupa.com')).toBe(true);
    expect(isExcluded('admin+anything-at-all@oqupa.com')).toBe(true);
  });

  it('is case-insensitive', () => {
    expect(isExcluded('Admin+Test1@Oqupa.com')).toBe(true);
    expect(isExcluded('  ADMIN@OQUPA.COM  ')).toBe(true);
  });

  it('does NOT exclude real users', () => {
    for (const e of [
      'someone@gmail.com',
      'admin@example.com',            // same local part, different domain
      'notadmin@oqupa.com',           // different local part
      'admin@oqupa.com.evil.com',     // domain must END there
      'xadmin+test@oqupa.com',
      'admin@sub.oqupa.com',
    ]) {
      expect(isExcluded(e), `${e} must not be excluded`).toBe(false);
    }
  });

  it('treats empty and rubbish input as not excluded', () => {
    for (const bad of ['', '   ', null, undefined, 0, {}]) expect(isExcluded(bad)).toBe(false);
  });

  // A plus-alias is only the same account when the LOCAL PART matches. Someone
  // else's address that merely contains a plus must not be swallowed.
  it('does not swallow unrelated plus-addresses', () => {
    expect(isExcluded('student+fe@gmail.com')).toBe(false);
    expect(isExcluded('qa-bot+x@example.com')).toBe(false);
  });

  it('exports a Mongo-usable negation', () => {
    expect(NOT_EXCLUDED).toHaveProperty('$not');
    expect(NOT_EXCLUDED.$not).toBeInstanceOf(RegExp);
    // Sanity: the pattern the query relies on agrees with the function.
    expect(EXCLUDED_PATTERN.test('admin+test1@oqupa.com')).toBe(true);
    expect(EXCLUDED_PATTERN.test('real.person@gmail.com')).toBe(false);
  });
});

describe('the team, added 2026-10-16', () => {
  const { isExcluded } = require('./internalAccounts.js');
  it('counts the founder\'s addresses and the marketing team as ours', () => {
    for (const e of ['admin@oqupa.com', 'Jersondevs@gmail.com', 'jerson.7@icloud.com', 'kuoppala.ellie@gmail.com']) {
      expect(isExcluded(e)).toBe(true);
    }
    expect(isExcluded('jersondevs+test2@gmail.com')).toBe(true); // an alias is the same inbox
  });
  it('and nobody else', () => {
    expect(isExcluded('ellie@byu.edu')).toBe(false);
    expect(isExcluded('jerson@byu.edu')).toBe(false);
  });
});

describe('who sees whom on the Daily', () => {
  const { dailyResultsQuery } = require('./db/daily.js');
  const { NOT_EXCLUDED } = require('./internalAccounts.js');
  it('a student sees students and themselves, never the team', () => {
    expect(dailyResultsQuery(2, 'sam@byu.edu')).toEqual({
      number: 2, $or: [{ email: NOT_EXCLUDED }, { email: 'sam@byu.edu' }],
    });
  });
  it('the team sees everyone, the team included', () => {
    expect(dailyResultsQuery(2, 'jersondevs@gmail.com')).toEqual({ number: 2 });
    expect(dailyResultsQuery(2, 'admin@oqupa.com')).toEqual({ number: 2 });
  });
});
