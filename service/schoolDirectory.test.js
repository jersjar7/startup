import { describe, it, expect } from 'vitest';
import {
  searchSchools, canonicalSchool, fold, DIRECTORY, schoolForDomain, shortSchoolName,
} from './schoolDirectory.js';
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
  it('is a real directory, not a stub', () => {
    expect(DIRECTORY.length).toBeGreaterThanOrEqual(2000);
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

// The hand-written seed was replaced by 2,360 US institutions from the public
// university-domains dataset, with the curated abbreviations layered on top
// because that dataset has none and "UCI" is what people type.
describe('the real dataset', () => {
  it('is thousands of institutions, not hundreds', () => {
    expect(DIRECTORY.length).toBeGreaterThan(2000);
  });

  it('kept every curated abbreviation, which the dataset does not have', () => {
    for (const [typed, expected] of [
      ['UCI', 'University of California, Irvine'],
      ['CSULB', 'California State University, Long Beach'],
      ['BYU', 'Brigham Young University'],
      ['Cal Poly', 'California Polytechnic State University, San Luis Obispo'],
      ['NCSU', 'North Carolina State University'],
      ['Virginia Tech', 'Virginia Polytechnic Institute and State University'],
    ]) {
      expect(searchSchools(typed)[0], `"${typed}" no longer resolves`).toBe(expected);
    }
  });

  it('reaches schools the hand-written list never had', () => {
    expect(searchSchools('marywood').length).toBeGreaterThan(0);
    expect(searchSchools('gallaudet').length).toBeGreaterThan(0);
  });
});

describe('naming a school from an email domain', () => {
  it('resolves a .edu address without asking anybody', () => {
    // Only 69 of 500 accounts had a knowable school. This is the cheapest way
    // to raise that: the domain is already on the account.
    expect(schoolForDomain('byu.edu')).toBe('Brigham Young University');
    expect(schoolForDomain('mit.edu')).toBe('Massachusetts Institute of Technology');
  });

  it('climbs to the parent domain, so a department still resolves', () => {
    expect(schoolForDomain('eng.berkeley.edu')).toBe('University of California, Berkeley');
    expect(schoolForDomain('students.uwf.edu')).toBe('University of West Florida');
  });

  it('says nothing for an address that is not a school', () => {
    // 380 of 500 signed up with a personal address. Guessing here would invent
    // institutions, which is the thing this whole file exists to stop.
    for (const d of ['gmail.com', 'outlook.com', '', null, undefined, '.', 'edu']) {
      expect(schoolForDomain(d)).toBeNull();
    }
  });

  it('is not confused by case or stray dots', () => {
    expect(schoolForDomain('BYU.EDU')).toBe('Brigham Young University');
    expect(schoolForDomain('.byu.edu.')).toBe('Brigham Young University');
  });
});

describe('one institution, one bucket', () => {
  it('never lists a school whose name is another school\'s alias', () => {
    // The dataset shipped "Virginia Tech" as its own institution alongside
    // "Virginia Polytechnic Institute and State University", so students at one
    // university would have landed in two buckets, which is the exact failure
    // this directory exists to prevent. Merged on 2026-10-07; this is the guard
    // that the next dataset refresh cannot reintroduce it.
    const owner = new Map();
    for (const school of DIRECTORY) {
      for (const alias of school.aka || []) owner.set(fold(alias), school.name);
    }
    for (const school of DIRECTORY) {
      const clash = owner.get(fold(school.name));
      expect(
        clash === undefined || fold(clash) === fold(school.name),
        `"${school.name}" is also an alias of "${clash}"`,
      ).toBe(true);
    }
  });

  it('kept the merged school reachable by both name and domain', () => {
    expect(searchSchools('Virginia Tech')[0])
      .toBe('Virginia Polytechnic Institute and State University');
    expect(schoolForDomain('vt.edu'))
      .toBe('Virginia Polytechnic Institute and State University');
  });
});

describe('typing it and resolving it from a domain agree', () => {
  // The two sources name campuses differently: the curated list says
  // "Texas A&M University", the dataset said "Texas A&M University - College
  // Station". Left alone, a student who typed the name and a student whose
  // .edu address resolved would land in different buckets at the same
  // university, which is the failure this whole directory exists to prevent.
  //
  // Eleven campuses were merged one at a time rather than by a rule, because a
  // rule would have merged "University of Alabama" with "University of Alabama
  // at Birmingham", which are different universities.
  it('gives one name whether it was typed or inferred', () => {
    for (const [typed, domain] of [
      ['Texas A&M', 'tamu.edu'],
      ['University of Michigan', 'umich.edu'],
      ['UA', 'ua.edu'],
      ['UT Austin', 'utexas.edu'],
      ['UVA', 'virginia.edu'],
      ['Ohio State University', 'osu.edu'],
      ['University of Maryland', 'umd.edu'],
    ]) {
      const byTyping = searchSchools(typed)[0];
      const byDomain = schoolForDomain(domain);
      expect(byDomain, `${domain} resolved to nothing`).toBeTruthy();
      expect(byTyping, `"${typed}" and ${domain} disagree`).toBe(byDomain);
    }
  });

  it('keeps universities that merely share a name apart', () => {
    // Alabama and UAB are different institutions. So are Michigan and Michigan
    // Dearborn. A merge rule based on name prefixes would have collapsed them.
    expect(schoolForDomain('ua.edu')).not.toBe(schoolForDomain('uab.edu'));
    expect(schoolForDomain('ua.edu')).not.toBe(schoolForDomain('uah.edu'));
    expect(schoolForDomain('umich.edu')).not.toBe(schoolForDomain('umdearborn.edu'));
    expect(schoolForDomain('umich.edu')).not.toBe(schoolForDomain('umflint.edu'));
  });
});

describe('a short form for a small screen', () => {
  // Some institutions run to fifty characters, and a row on a phone ellipsizes
  // them down to the first two words, which identifies nothing. This is for
  // display only: the full name stays the stored value and the grouping key.
  it('uses the abbreviation people actually say', () => {
    expect(shortSchoolName('Brigham Young University')).toBe('BYU');
    expect(shortSchoolName('University of California, Irvine')).toBe('UCI');
    expect(shortSchoolName('Massachusetts Institute of Technology')).toBe('MIT');
    expect(shortSchoolName('California State University, Long Beach')).toBe('CSULB');
  });

  it('will not shorten to two letters, which identify nothing', () => {
    // "VT" is a real alias and a terrible label on its own.
    expect(shortSchoolName('Virginia Polytechnic Institute and State University'))
      .toBe('Virginia Tech');
  });

  it('leaves a name alone when shortening saves almost nothing', () => {
    expect(shortSchoolName('Clemson University')).toBe('Clemson University');
    expect(shortSchoolName('Purdue University')).toBe('Purdue University');
  });

  it('returns an unknown school exactly as given', () => {
    // Somebody typed a university the directory has never heard of. It must
    // come back untouched, not blank and not guessed at.
    expect(shortSchoolName('Universidad Nacional de Ingenieria'))
      .toBe('Universidad Nacional de Ingenieria');
  });

  it('is nothing when there is nothing', () => {
    expect(shortSchoolName('')).toBeNull();
    expect(shortSchoolName(null)).toBeNull();
  });

  it('never changes what is stored or grouped on', () => {
    // The guard that this stays cosmetic: the canonical name is unaffected.
    expect(canonicalSchool('BYU')).toBe('Brigham Young University');
    expect(canonicalSchool('Brigham Young University')).toBe('Brigham Young University');
  });
});
