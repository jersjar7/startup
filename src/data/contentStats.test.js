import { describe, it, expect } from 'vitest';
import { PROBLEM_COUNT, countChapterTestQuestions } from './contentStats';
import { getProblemPoolSize } from './problemPool';
import { CHAPTER_TESTS } from './chapter-tests/index';
import { TEST_LENGTH, TEST_VERSIONS } from './chapter-tests/lengths';

describe('problem count', () => {
  it('counts every chapter test question a student can be served', () => {
    // Each test asks the first TEST_LENGTH questions of a set; the spares
    // past that are never served, so they must not be counted.
    let served = 0;
    for (const [chapterId, len] of Object.entries(TEST_LENGTH)) {
      for (const v of TEST_VERSIONS) {
        expect(CHAPTER_TESTS[chapterId][v].length).toBeGreaterThanOrEqual(len);
        served += Math.min(len, CHAPTER_TESTS[chapterId][v].length);
      }
    }
    expect(countChapterTestQuestions()).toBe(served);
  });

  it('adds the chapter tests to the practice, lesson and exam problems', () => {
    expect(PROBLEM_COUNT).toBe(getProblemPoolSize() + countChapterTestQuestions());
  });

  it('has a length for every chapter that has a test, and no other', () => {
    expect(Object.keys(TEST_LENGTH).sort()).toEqual(Object.keys(CHAPTER_TESTS).sort());
  });
});
