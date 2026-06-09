// Single source of truth for "how much content the platform has", derived live
// from the actual problem/lesson/chapter data — never a hardcoded literal.
// Client-side code imports these directly; build-time/server consumers (meta
// tags, SEO pages, og-image, emails) read the same counts via scripts/gen-stats.mjs.
import { getProblemPoolSize } from './problemPool';
import { LESSONS } from './lessons/index';
import { CHAPTERS } from './chapters';

function countLessons() {
  let n = 0;
  for (const ch of Object.values(LESSONS)) {
    for (const st of ch) n += (st.lessons || []).length;
  }
  return n;
}

export const PROBLEM_COUNT = getProblemPoolSize();
export const LESSON_COUNT = countLessons();
export const CHAPTER_COUNT = CHAPTERS.length;

// "1,126" — the canonical, comma-formatted label used throughout the copy.
export const PROBLEM_COUNT_LABEL = PROBLEM_COUNT.toLocaleString('en-US');
