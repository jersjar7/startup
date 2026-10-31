// Single source of truth for "how much content the platform has", derived live
// from the actual problem/lesson/chapter data, never a hardcoded literal.
// Client-side code imports these directly; build-time/server consumers (meta
// tags, SEO pages, og-image, emails) read the same counts via scripts/gen-stats.mjs.
import { getProblemPoolSize } from './problemPool';
import { LESSONS } from './lessons/index';
import { CHAPTERS } from './chapters';
import { TEST_LENGTH, TEST_VERSIONS } from './chapter-tests/lengths';

function countLessons() {
  let n = 0;
  for (const ch of Object.values(LESSONS)) {
    for (const st of ch) n += (st.lessons || []).length;
  }
  return n;
}

// Chapter test questions a student can be served: every set of every chapter.
// The bank holds a few spares past each test's length; those are not counted.
export function countChapterTestQuestions() {
  return Object.values(TEST_LENGTH).reduce((n, len) => n + len * TEST_VERSIONS.length, 0);
}

// Practice, lesson and exam problems plus the chapter tests: every problem a
// student can reach on the platform.
export const PROBLEM_COUNT = getProblemPoolSize() + countChapterTestQuestions();
export const LESSON_COUNT = countLessons();
export const CHAPTER_COUNT = CHAPTERS.length;

// "1,454": the canonical, comma-formatted label used throughout the copy.
export const PROBLEM_COUNT_LABEL = PROBLEM_COUNT.toLocaleString('en-US');
