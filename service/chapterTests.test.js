import { describe, it, expect } from 'vitest';
const CT = require('./chapterTests.js');
const bankFile = require('./chapter-tests.json');

const q = (id, key, topic = 'T') => ({
  id, topic, statement: 's', choices: [{ id: 'c1', text: '1' }, { id: 'c2', text: '2' }, { id: 'c3', text: '3' }, { id: 'c4', text: '4' }],
  correctAnswerId: key, choiceNotes: ['a', 'b', 'c', 'd'], eli5: 'e', steps: [{ text: 's' }], traps: ['t'], handbookPage: 'p. 1',
});

describe('chapter test bank', () => {
  it('has two versions of every chapter, each long enough for its test', () => {
    for (const [ch, len] of Object.entries(bankFile.length)) {
      for (const v of ['A', 'B']) {
        expect(bankFile.tests[ch][v].length, `${ch} ${v}`).toBeGreaterThanOrEqual(len);
        expect(CT.testQuestions(ch, v, bankFile)).toHaveLength(len);
      }
    }
  });

  it('shares no question between versions or chapters', () => {
    const ids = Object.values(bankFile.tests).flatMap((t) => [...t.A, ...t.B].map((x) => x.id));
    expect(new Set(ids).size).toBe(ids.length);
  });

  it('is not in the content the app downloads', () => {
    const content = require('./content.json');
    expect(Object.keys(content.problemsById).some((id) => id.startsWith('ct-'))).toBe(false);
  });
});

describe('what the browser sees', () => {
  it('gets no key, notes or solution while the test runs', () => {
    const p = CT.publicQuestion(q('x', 'c2'));
    expect(p).not.toHaveProperty('correctAnswerId');
    expect(p).not.toHaveProperty('choiceNotes');
    expect(p).not.toHaveProperty('steps');
    expect(JSON.stringify(p)).not.toContain('"a"');
  });

  it('gets everything in the review', () => {
    const r = CT.reviewQuestion(q('x', 'c2'), 'c3');
    expect(r).toMatchObject({ correctAnswerId: 'c2', chosen: 'c3', correct: false });
    expect(r.steps).toHaveLength(1);
  });
});

describe('grading', () => {
  it('counts unanswered as wrong and splits by topic', () => {
    const qs = [q('a', 'c1', 'X'), q('b', 'c2', 'X'), q('c', 'c3', 'Y'), q('d', 'c4', 'Y')];
    const g = CT.grade(qs, { a: 'c1', b: 'c1', c: 'c3' });
    expect(g).toMatchObject({ correct: 2, total: 4, percent: 50 });
    expect(g.topics).toEqual([{ topic: 'X', correct: 1, total: 2 }, { topic: 'Y', correct: 1, total: 2 }]);
  });
});

describe('answers', () => {
  const qs = [q('a', 'c1'), q('b', 'c2')];
  it('autosave can clear an answer', () => {
    expect(CT.autosave(qs, { a: 'c1' }, { a: null })).toEqual({ a: null });
  });
  it('submit can only add, never clear', () => {
    expect(CT.submission(qs, { a: 'c1' }, { a: null, b: 'c2' })).toEqual({ a: 'c1', b: 'c2' });
  });
  it('ignores answers to questions this test did not ask', () => {
    expect(CT.autosave(qs, {}, { zzz: 'c1', a: 'c3' })).toEqual({ a: 'c3' });
  });
});

describe('which set comes next', () => {
  const v = (version, tries, lastStartedAt = null, open = false) => ({ version, tries, lastStartedAt, open });
  it('starts with A', () => {
    expect(CT.nextVersion([v('A', 0), v('B', 0)])).toBe('A');
  });
  it('gives all new questions on the second try', () => {
    expect(CT.nextVersion([v('A', 1, '2026-10-01'), v('B', 0)])).toBe('B');
  });
  it('then goes back to the set seen longest ago', () => {
    expect(CT.nextVersion([v('A', 1, '2026-10-01'), v('B', 1, '2026-10-05')])).toBe('A');
    expect(CT.nextVersion([v('A', 2, '2026-10-09'), v('B', 1, '2026-10-05')])).toBe('B');
  });
  it('carries on with a try that is still open', () => {
    expect(CT.nextVersion([v('A', 0), v('B', 3, '2026-10-05', true)])).toBe('B');
  });
});
