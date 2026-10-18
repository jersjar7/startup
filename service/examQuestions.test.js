import { describe, it, expect } from 'vitest';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const { buildExamQuestions } = require('./examQuestions.js');
const { EXAM_DISTRIBUTION } = require('./examWeights.js');
const content = require('./content.json');

// A real exam's worth of questions, as the browser would post them: the
// right number from each chapter, every one from the exam bank.
function honestPick() {
  const byChapter = {};
  for (const [id, ix] of Object.entries(content.problemIndex)) {
    if (ix.pool !== 'exam') continue;
    (byChapter[ix.chapterId] ||= []).push(id);
  }
  const out = [];
  for (const [chapterId, n] of Object.entries(EXAM_DISTRIBUTION)) {
    for (const id of byChapter[chapterId].slice(0, n)) {
      const q = content.problemsById[id];
      out.push({ ...q, chapterId, choices: [...q.choices].reverse() });
    }
  }
  return out;
}

describe('buildExamQuestions', () => {
  it('every chapter has enough exam questions for its slots', () => {
    const counts = {};
    for (const ix of Object.values(content.problemIndex)) {
      if (ix.pool === 'exam') counts[ix.chapterId] = (counts[ix.chapterId] || 0) + 1;
    }
    for (const [chapterId, n] of Object.entries(EXAM_DISTRIBUTION)) {
      expect(counts[chapterId] || 0, chapterId).toBeGreaterThanOrEqual(n);
    }
  });

  it('accepts an honest exam and keeps the order its choices were shown in', () => {
    const picked = honestPick();
    const { questions, error } = buildExamQuestions(picked, content, EXAM_DISTRIBUTION);
    expect(error).toBeUndefined();
    expect(questions).toHaveLength(110);
    expect(questions[0].choices.map((c) => c.id)).toEqual(picked[0].choices.map((c) => c.id));
  });

  it('grades against the server\'s answer, whatever the browser claims', () => {
    const picked = honestPick().map((q) => ({
      ...q,
      correctAnswerId: 'forged',
      statement: 'forged',
      choices: q.choices.map((c) => ({ ...c, text: 'forged' })),
    }));
    const { questions } = buildExamQuestions(picked, content, EXAM_DISTRIBUTION);
    for (const q of questions) {
      const stored = content.problemsById[q.id];
      expect(q.correctAnswerId).toBe(stored.correctAnswerId);
      expect(q.statement).toBe(stored.statement);
      expect(q.choices.every((c) => c.text !== 'forged')).toBe(true);
    }
  });

  it('turns away a short exam, a padded one, repeats and made-up questions', () => {
    const picked = honestPick();
    expect(buildExamQuestions(picked.slice(0, 1), content, EXAM_DISTRIBUTION).error).toBeTruthy();
    expect(buildExamQuestions([...picked, picked[0]], content, EXAM_DISTRIBUTION).error).toBeTruthy();

    const repeated = [...picked];
    repeated[1] = repeated[0];
    expect(buildExamQuestions(repeated, content, EXAM_DISTRIBUTION).error).toBeTruthy();

    const invented = [...picked];
    invented[0] = { ...invented[0], id: 'not-a-question' };
    expect(buildExamQuestions(invented, content, EXAM_DISTRIBUTION).error).toBeTruthy();
  });

  it('turns away lesson questions and an exam that skips the chapter weights', () => {
    const picked = honestPick();
    const lessonId = Object.keys(content.problemIndex).find((id) => content.problemIndex[id].pool === 'lesson');
    const withLesson = [...picked];
    withLesson[0] = { ...content.problemsById[lessonId] };
    expect(buildExamQuestions(withLesson, content, EXAM_DISTRIBUTION).error).toBeTruthy();

    // Swap one question for an unused one from another chapter: still 110,
    // but the weights are off.
    const used = new Set(picked.map((q) => q.id));
    const other = Object.keys(content.problemIndex).find(
      (id) => content.problemIndex[id].pool === 'exam'
        && !used.has(id)
        && content.problemIndex[id].chapterId !== picked[0].chapterId,
    );
    const skewed = [...picked];
    skewed[0] = { ...content.problemsById[other] };
    expect(buildExamQuestions(skewed, content, EXAM_DISTRIBUTION).error).toBeTruthy();
  });

  it('falls back to the server\'s choice order when the browser\'s does not match', () => {
    const picked = honestPick();
    picked[0] = { ...picked[0], choices: [{ id: 'zz' }] };
    const { questions } = buildExamQuestions(picked, content, EXAM_DISTRIBUTION);
    expect(questions[0].choices.map((c) => c.id)).toEqual(
      content.problemsById[picked[0].id].choices.map((c) => c.id),
    );
  });
});
