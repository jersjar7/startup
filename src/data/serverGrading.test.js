// @vitest-environment node
import { describe, it, expect } from 'vitest';
import { readFileSync } from 'node:fs';
import { getAllProblems } from './problemPool.js';

// The server grades every desk answer from its own copy of the bank
// (service/grading.js, ADR 0038). An answer to a problem the server does not
// hold earns nothing, so that copy must hold every problem the website can
// ask, with the same answer. If this fails, run `node scripts/gen-content.mjs`.
const content = JSON.parse(readFileSync(new URL('../../service/content.json', import.meta.url), 'utf8'));

describe('the server can grade every problem the website asks', () => {
  it('has each one, with the same answer', () => {
    const missing = [];
    const differs = [];
    for (const p of getAllProblems()) {
      const s = content.problemsById[p.id];
      if (!s) missing.push(p.id);
      else if (s.correctAnswerId !== p.correctAnswerId) differs.push(p.id);
    }
    expect(missing).toEqual([]);
    expect(differs).toEqual([]);
  });
});
