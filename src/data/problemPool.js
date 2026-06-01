// Unified problem resolver across every client-side question pool.
//
// This is the single source of truth for looking up a problem by its id.
// The spaced-repetition review flow stores only problem ids server-side
// (in problemHistory); it resolves them here so due problems resurface from
// the exact content the student studied — lesson practice, exam bank, and
// chapter practice — with no separate database copy to drift out of sync.

import { LESSONS } from './lessons/index';
import { getExamBankForChapter } from './exam-bank/index';
import { getChapterPracticeProblems } from './chapter-practice/index';

const CHAPTER_IDS = [
  'mathematics', 'statistics', 'ethics', 'economics', 'statics',
  'dynamics', 'mechanics-materials', 'materials', 'fluid-mechanics',
  'surveying', 'water-resources', 'structural', 'geotechnical',
  'transportation', 'construction',
];

const POOL = new Map();

function add(problem) {
  if (problem && problem.id && !POOL.has(problem.id)) {
    POOL.set(problem.id, problem);
  }
}

for (const chapterId of CHAPTER_IDS) {
  // Lesson practice: LESSONS[chapter] -> subtopics -> lessons -> problems
  for (const subtopic of LESSONS[chapterId] || []) {
    for (const lesson of subtopic.lessons || []) {
      for (const p of lesson.problems || []) add(p);
    }
  }
  // Exam bank
  for (const p of getExamBankForChapter(chapterId)) add(p);
  // Chapter practice
  for (const p of getChapterPracticeProblems(chapterId)) add(p);
}

/**
 * Resolve a problem by its id across all pools.
 * Returns the problem object (lesson schema) or null if it no longer exists
 * (e.g. an id stored before a content refactor that removed it).
 */
export function getProblemById(id) {
  return POOL.get(id) || null;
}

/** Total number of uniquely-id'd problems across all pools. */
export function getProblemPoolSize() {
  return POOL.size;
}
