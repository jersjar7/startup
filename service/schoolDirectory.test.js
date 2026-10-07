import { describe, it, expect } from 'vitest';
import { searchSchools, canonicalSchool, fold, DIRECTORY } from './schoolDirectory.js';
import { normalizeSchoolName } from './school.js';

// Measured on production, 2026-10-07: 19 users had given a school and there
// were 19 distinct names. Nothing grouped with anything. These are the actual
// strings from that list, and they are the bar this has to clear.

const REAL = [
  'UCI',
  'University of California, Irvine',
  'CSULB',
  'Arizona state university',
  'Brigham Young University',
  'Boise State University',
  'Clemson University',
  'Florida International University',
  'Howard University',
  'Michigan State University',
  'Old Dominion University',
];

describe('the thing that was broken', () => {
  it('lands "UCI" and its full name on ONE institution', () => {
    // The whole reason this exists. These were two rows in the report.
    expect(searchSchools('UCI')[0]).toBe('University of California, Irvine');
    expect(searchSchools('University of California, Irvine')[0])
      .toBe('University of California, Irvine');
    expect(canonicalSchool('UCI')).toBe(canonicalSchool('University of California, Irvine'));
  });

  it('is something the old grouping key could never do', () => {
    // normalizeSchoolName strips "university", "of" and "at", so the short form
    // and the long form key to different things and can never meet. This is not
    // a criticism of that function; it is why a directory was needed.
    const a = normalizeSchoolName('UCI').key;
    const b = normalizeSchoolName('University of California, Irvine').key;
    expect(a).not.toBe(b);
    expect(canonicalSchool('UCI')).toBe(canonicalSchool('University of California, Irvine'));
  });

  it('finds every real name somebody actually typed', () => {
    for (const typed of REAL) {
      expect(searchSchools(typed).length, `"${typed}" suggested nothing`)
        .toBeGreaterThan(0);
    }
  });

  it('ignores the capitalisation people do not bother with', () => {
    expect(searchSchools('arizona state university')[0]).toBe('Arizona State University');
    expect(searchSchools('BYU')[0]).toBe(searchSchools('byu')[0]);
  });
});

describe('typing it', () => {
  it('suggests from a few letters, which is the point of a typeahead', () => {
    expect(searchSchools('irv')).toContain('University of California, Irvine');
    expect(searchSchools('clem')).toContain('Clemson University');
  });

  it('says nothing for one letter, which would match half the list', () => {
    expect(searchSchools('u')).toEqual([]);
    expect(searchSchools('')).toEqual([]);
    expect(searchSchools(null)).toEqual([]);
  });

  it('puts an exact match first, ahead of anything containing it', () => {
    const hits = searchSchools('Clemson University');
    expect(hits[0]).toBe('Clemson University');
  });

  it('handles the ampersand people type either way', () => {
    expect(searchSchools('texas a&m')[0]).toBe('Texas A&M University');
    expect(searchSchools('texas a and m')[0]).toBe('Texas A&M University');
  });

  it('matches initials even where no abbreviation was listed', () => {
    expect(searchSchools('ucsd')).toContain('University of California, San Diego');
  });

  it('never floods the field', () => {
    expect(searchSchools('university').length).toBeLessThanOrEqual(8);
  });
});

describe('what it must not do', () => {
  it('never invents a school for something that is not one', () => {
    // "NCSU 2012" is real: somebody typed their graduation year into the
    // school field. It must not silently become North Carolina State.
    expect(canonicalSchool('NCSU 2012')).toBeNull();
    expect(canonicalSchool('asdfghjkl')).toBeNull();
    expect(canonicalSchool('')).toBeNull();
  });

  it('returns nothing rather than a wrong guess, so free text takes over', () => {
    // A school that is genuinely not in the seed. The caller MUST still accept
    // what they typed; an incomplete list cannot be allowed to block anybody.
    expect(searchSchools('Universidad Nacional de Ingeniería')).toEqual([]);
  });
});

describe('the directory itself', () => {
  it('is a seed worth having, not a stub', () => {
    expect(DIRECTORY.length).toBeGreaterThanOrEqual(150);
  });

  it('has no duplicate institutions, which would defeat the purpose', () => {
    const names = DIRECTORY.map((d) => fold(d.name));
    expect(new Set(names).size).toBe(names.length);
  });

  it('has no alias claimed by two schools', () => {
    const seen = new Map();
    for (const school of DIRECTORY) {
      for (const alias of school.aka || []) {
        const key = fold(alias);
        expect(seen.has(key), `"${alias}" is claimed by ${seen.get(key)} and ${school.name}`)
          .toBe(false);
        seen.set(key, school.name);
      }
    }
  });

  it('never lists an alias identical to its own name', () => {
    for (const school of DIRECTORY) {
      for (const alias of school.aka || []) {
        expect(fold(alias)).not.toBe(fold(school.name));
      }
    }
  });
});
