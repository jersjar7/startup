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
