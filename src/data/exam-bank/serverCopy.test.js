// @vitest-environment node
import { describe, it, expect } from 'vitest';
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { getExamBankForChapter } from './index.js';

const require = createRequire(import.meta.url);
const { EXAM_DISTRIBUTION } = require('../../../service/examWeights.js');

// The server picks and grades the paid exam from its own copy of each question
// (service/examQuestions.js). That copy must hold every exam-bank question
// with the same answer and chapter as the website's.
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
});
