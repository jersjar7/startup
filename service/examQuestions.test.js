import { describe, it, expect } from 'vitest';
import { createRequire } from 'node:module';
import fs from 'node:fs';
import path from 'node:path';

const require = createRequire(import.meta.url);
const { pickExamQuestionIds, buildExamQuestions, publicQuestion } = require('./examQuestions.js');
const { EXAM_DISTRIBUTION } = require('./examWeights.js');
const { DIAGNOSTIC_IDS } = require('./diagnosticIds.js');
const content = require('./content.json');

const chapterOf = (id) => content.problemIndex[id].chapterId;
const pick = (seen = []) => pickExamQuestionIds(content, EXAM_DISTRIBUTION, { seen });

describe('pickExamQuestionIds', () => {
  it('gives every chapter its weight, from the exam bank, with no repeats', () => {
    for (let run = 0; run < 100; run++) {
      const ids = pick();
      expect(ids).toHaveLength(110);
      expect(new Set(ids).size).toBe(110);
      const counts = {};
      for (const id of ids) {
        expect(content.problemIndex[id].pool).toBe('exam');
        counts[chapterOf(id)] = (counts[chapterOf(id)] || 0) + 1;
      }
      expect(counts).toEqual(EXAM_DISTRIBUTION);
    }
  });

  it('never asks a diagnostic question', () => {
    const diagnostic = new Set(DIAGNOSTIC_IDS);
    for (let run = 0; run < 100; run++) {
      expect(pick().filter((id) => diagnostic.has(id))).toEqual([]);
    }
  });

  it('leads with questions the student has not seen', () => {
    const first = pick();
    const second = pick(first);
    expect(second.filter((id) => first.includes(id))).toEqual([]);

    // A third exam has to reuse some, and only where a chapter ran out.
    const third = pick([...first, ...second]);
    const reused = third.filter((id) => first.includes(id) || second.includes(id));
    expect(reused.length).toBeGreaterThan(0);
    expect(reused.length).toBeLessThan(15);
    const reusedChapters = new Set(reused.map(chapterOf));
    for (const chapterId of reusedChapters) {
      const pool = Object.keys(content.problemIndex).filter(
        (id) => content.problemIndex[id].pool === 'exam' && chapterOf(id) === chapterId && !DIAGNOSTIC_IDS.includes(id),
      );
      expect(pool.length, chapterId).toBeLessThan(3 * EXAM_DISTRIBUTION[chapterId]);
    }
  });

  it('when it must repeat, repeats the questions seen least often', () => {
    const seen = [];
    for (let k = 0; k < 4; k++) seen.push(...pick(seen));
    const times = {};
    for (const id of seen) times[id] = (times[id] || 0) + 1;
    const fifth = pick(seen);
    const pools = {};
    for (const [id, ix] of Object.entries(content.problemIndex)) {
      if (ix.pool === 'exam' && !DIAGNOSTIC_IDS.includes(id)) (pools[ix.chapterId] ||= []).push(id);
    }
    // Nothing left out of a chapter was seen fewer times than something taken.
    for (const [chapterId, pool] of Object.entries(pools)) {
      const taken = pool.filter((id) => fifth.includes(id)).map((id) => times[id] || 0);
      const left = pool.filter((id) => !fifth.includes(id)).map((id) => times[id] || 0);
      if (left.length) expect(Math.min(...left), chapterId).toBeGreaterThanOrEqual(Math.max(...taken));
    }
  });
});

describe('buildExamQuestions and publicQuestion', () => {
  it('stores the server\'s answer and sends the question without it', () => {
    const ids = pick();
    const stored = buildExamQuestions(ids, content);
    stored.forEach((q, k) => {
      const source = content.problemsById[ids[k]];
      expect(q.correctAnswerId).toBe(source.correctAnswerId);
      expect(q.statement).toBe(source.statement);
      expect(q.diagram?.figureId).toBeUndefined();
      const sent = publicQuestion(q);
      expect(JSON.stringify(sent)).not.toContain('correctAnswerId');
      expect(sent.choices.map((c) => c.id)).toEqual(source.choices.map((c) => c.id));
    });
  });
});

describe('the diagnostic list', () => {
  it('matches the website\'s copy', () => {
    const src = fs.readFileSync(path.join(__dirname, '..', 'src/data/exam-bank/diagnostic-ids.js'), 'utf8');
    const ids = [...src.matchAll(/'([a-z0-9-]+)'/g)].map((m) => m[1]);
    expect(ids).toEqual(DIAGNOSTIC_IDS);
  });
});
