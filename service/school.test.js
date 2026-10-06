import { describe, it, expect } from 'vitest';
import {
  isSchoolResolved,
  normalizeSchoolName,
  academicDomain,
  groupingKey,
  validGraduationYear,
  MAX_NAME,
} from './school.js';

// The school is the only thing that makes a cohort report possible, so what is
// checked here is that one institution cannot quietly become several rows of
// that report, and that a bad answer is rejected rather than stored.

describe('resolution', () => {
  it('is unresolved until they answer or dismiss', () => {
    expect(isSchoolResolved(null)).toBe(false);
    expect(isSchoolResolved({})).toBe(false);
    expect(isSchoolResolved({ school: {} })).toBe(false);
  });

  it('counts an answer and a dismissal the same, so nobody is asked twice', () => {
    expect(isSchoolResolved({ school: { name: 'BYU' } })).toBe(true);
    expect(isSchoolResolved({ school: { dismissedAt: new Date() } })).toBe(true);
  });
});

describe('name normalisation', () => {
  it('collapses the spellings that would split one school into several', () => {
    const a = normalizeSchoolName('  Brigham Young   University ');
    const b = normalizeSchoolName('the university of Brigham Young');
    expect(a.key).toBe(b.key);
    // The display name keeps what the user typed, trimmed.
    expect(a.name).toBe('Brigham Young University');
  });

  it('ignores punctuation differences', () => {
    expect(normalizeSchoolName("Texas A&M").key)
      .toBe(normalizeSchoolName('Texas A&M,').key);
    expect(normalizeSchoolName("St. John's").key)
      .toBe(normalizeSchoolName('St Johns').key);
  });

  it('rejects an empty answer', () => {
    expect(normalizeSchoolName('')).toBeNull();
    expect(normalizeSchoolName('   ')).toBeNull();
    expect(normalizeSchoolName(null)).toBeNull();
  });

  it('caps the length so a paste cannot become a school name', () => {
    const long = normalizeSchoolName('x'.repeat(500));
    expect(long.name.length).toBe(MAX_NAME);
  });

  it('keeps a name made only of filler words groupable with itself', () => {
    const only = normalizeSchoolName('The University of');
    expect(only.key).toBeTruthy();
    expect(only.key).toBe(normalizeSchoolName('the university OF').key);
  });
});

describe('academic domain', () => {
  it('finds an academic address and ignores a personal one', () => {
    expect(academicDomain('j@byu.edu')).toBe('byu.edu');
    expect(academicDomain('j@gmail.com')).toBeNull();
    expect(academicDomain('j@miners.utep.edu')).toBe('miners.utep.edu');
  });

  it('falls back to a separately verified student address', () => {
    // 380 of 500 users signed up with Gmail, but 15 verified a .edu for the
    // student discount. That second address is what identifies their school.
    expect(academicDomain('j@gmail.com', 'j@byu.edu')).toBe('byu.edu');
  });

  it('accepts the international academic form', () => {
    expect(academicDomain('j@imperial.ac.uk')).toBe('imperial.ac.uk');
  });

  it('survives rubbish without throwing', () => {
    expect(academicDomain(null, undefined, '', 'notanemail')).toBeNull();
  });
});

describe('grouping', () => {
  it('prefers the domain, because an acronym and a full name both sit on it', () => {
    const byAcronym = { ...normalizeSchoolName('BYU'), domain: 'byu.edu' };
    const byFullName = { ...normalizeSchoolName('Brigham Young University'), domain: 'byu.edu' };
    expect(byAcronym.key).not.toBe(byFullName.key); // they really do differ
    expect(groupingKey(byAcronym)).toBe(groupingKey(byFullName)); // and still group
  });

  it('falls back to the name key when there is no academic address', () => {
    expect(groupingKey({ key: 'purdue' })).toBe('purdue');
    expect(groupingKey(null)).toBeNull();
  });
});

describe('graduation year', () => {
  const now = new Date('2026-10-06T00:00:00Z');

  it('accepts a plausible year', () => {
    expect(validGraduationYear(2027, now)).toBe(2027);
    expect(validGraduationYear('2027', now)).toBe(2027);
  });

  it('accepts no answer, because repeat takers have already graduated', () => {
    expect(validGraduationYear(null, now)).toBeNull();
    expect(validGraduationYear('', now)).toBeNull();
    expect(validGraduationYear(undefined, now)).toBeNull();
  });

  it('rejects a year that cannot be real', () => {
    // undefined is the invalid signal, distinct from null meaning "not given"
    expect(validGraduationYear(1850, now)).toBeUndefined();
    expect(validGraduationYear(2099, now)).toBeUndefined();
    expect(validGraduationYear('next year', now)).toBeUndefined();
    expect(validGraduationYear(2027.5, now)).toBeUndefined();
  });

  it('allows an incoming freshman but not an unborn one', () => {
    expect(validGraduationYear(2032, now)).toBe(2032);
    expect(validGraduationYear(2033, now)).toBeUndefined();
  });
});
