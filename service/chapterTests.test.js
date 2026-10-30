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

describe('an abandoned try', () => {
  const qs = Array.from({ length: 15 }, (_, i) => q('q' + i, 'c1'));
  it('counts only if at least a tenth of it was answered (ADR 0001)', () => {
    expect(CT.genuinelySat(qs, {})).toBe(false);
    expect(CT.genuinelySat(qs, { q0: 'c1' })).toBe(false);          // 1 of 15: a look, not a sitting
    expect(CT.genuinelySat(qs, { q0: 'c1', q1: null })).toBe(false); // a cleared answer is no answer
    expect(CT.genuinelySat(qs, { q0: 'c1', q1: 'c2' })).toBe(true);  // 2 of 15
  });
  it('ignores answers to questions the try did not ask', () => {
    expect(CT.genuinelySat(qs, { zzz: 'c1', yyy: 'c2' })).toBe(false);
  });
});

describe('choice order', () => {
  const bank = Object.values(bankFile.tests).flatMap((t) => [...t.A, ...t.B]);
  it('is the same every time for one try (refresh, going back, review)', () => {
    const x = bank[0];
    expect(CT.publicQuestion(x, 'try1').choices).toEqual(CT.publicQuestion(x, 'try1').choices);
    expect(CT.reviewQuestion(x, null, 'try1').choices).toEqual(CT.publicQuestion(x, 'try1').choices);
  });
  it('keeps each note with its own choice', () => {
    const x = bank[0];
    const r = CT.reviewQuestion(x, null, 'try1');
    r.choices.forEach((c, i) => {
      expect(r.choiceNotes[i]).toBe(x.choiceNotes[x.choices.findIndex((o) => o.id === c.id)]);
    });
  });
  it('differs between tries', () => {
    const differs = bank.slice(0, 20).filter((x) =>
      CT.publicQuestion(x, 'try1').choices.map((c) => c.id).join() !== CT.publicQuestion(x, 'try2').choices.map((c) => c.id).join());
    expect(differs.length).toBeGreaterThan(12);
  });
  it('spreads the correct answer evenly over A-D across many tries', () => {
    const pos = [0, 0, 0, 0];
    for (let t = 0; t < 40; t++) {
      for (const x of bank) pos[CT.publicQuestion(x, `t${t}`).choices.findIndex((c) => c.id === x.correctAnswerId)]++;
    }
    const total = pos.reduce((a, b) => a + b);
    pos.forEach((n) => expect(Math.abs(n / total - 0.25)).toBeLessThan(0.01));
  });
});
