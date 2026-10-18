// @vitest-environment node
import { describe, it, expect } from 'vitest';
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { getExamBankForChapter, selectExamQuestions } from './index.js';

const require = createRequire(import.meta.url);
const { EXAM_DISTRIBUTION } = require('../../../service/examWeights.js');
const { buildExamQuestions } = require('../../../service/examQuestions.js');

// The server grades the paid exam from its own copy of each question
// (service/examQuestions.js), never from what the browser sends. That only
// works if every question the exam can pick is in the server's copy with the
// same answer and chapter.
const content = JSON.parse(
  readFileSync(new URL('../../../service/content.json', import.meta.url), 'utf8'),
);

describe('the server can grade every exam question', () => {
  it('has each one, with the same answer and chapter', () => {
    const missing = [];
    const differs = [];
    for (const chapterId of Object.keys(EXAM_DISTRIBUTION)) {
      for (const q of getExamBankForChapter(chapterId)) {
        const s = content.problemsById[q.id];
        const ix = content.problemIndex[q.id];
        if (!s || !ix) missing.push(q.id);
        else if (s.correctAnswerId !== q.correctAnswerId || ix.chapterId !== q.chapterId) differs.push(q.id);
      }
    }
    expect(missing).toEqual([]);
    expect(differs).toEqual([]);
  });

  it('shows the same question after a resume as before it', () => {
    // A resumed exam renders the server's stored copy; a fresh one renders
    // the browser's. Across many picks, every question must store exactly
    // what the browser drew.
    const differs = new Set();
    for (let run = 0; run < 60; run++) {
      const picked = selectExamQuestions();
      const { questions } = buildExamQuestions(picked, content, EXAM_DISTRIBUTION);
      questions.forEach((stored, k) => {
        const q = picked[k];
        const same =
          stored.statement === q.statement
          && JSON.stringify(stored.choices) === JSON.stringify(q.choices)
          && JSON.stringify(stored.diagram) === JSON.stringify(q.diagram || null)
          && (stored.type || null) === (q.type || null)
          && stored.lessonId === q.lessonId;
        if (!same) differs.add(q.id);
      });
    }
    expect([...differs]).toEqual([]);
  });

  it('accepts every exam the website picks', () => {
    // What ExamSession.jsx posts to /api/exam/start, 200 times over.
    for (let run = 0; run < 200; run++) {
      const posted = selectExamQuestions().map((q) => ({
        id: q.id,
        chapterId: q.chapterId,
        lessonId: q.lessonId,
        statement: q.statement,
        choices: q.choices,
        correctAnswerId: q.correctAnswerId,
        type: q.type,
        diagram: q.diagram || null,
      }));
      const { error } = buildExamQuestions(posted, content, EXAM_DISTRIBUTION);
      expect(error, `run ${run}`).toBeUndefined();
    }
  });
});
