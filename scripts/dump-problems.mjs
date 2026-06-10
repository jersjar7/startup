// Dump every problem in the unified pool to per-chapter JSON, with the real
// fields needed to judge mobile fit (statement, choices, steps, eli5, traps,
// handbook refs, diagram). Feeds the per-chapter inspection agents.
//
// Usage: node scripts/dump-problems.mjs            -> writes mobile-analysis/in/<chapter>.json
//        node scripts/dump-problems.mjs --stdout   -> prints one chapter summary

import esbuild from 'esbuild';
import { pathToFileURL } from 'node:url';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const ROOT = process.cwd();
const DATA = path.join(ROOT, 'src', 'data');
const OUT = path.join(ROOT, 'mobile-analysis', 'in');

const ENTRY = `
import { LESSONS } from './lessons/index';
import { getExamBankForChapter } from './exam-bank/index';
import { getChapterPracticeProblems } from './chapter-practice/index';
const CHAPTER_IDS = ['mathematics','statistics','ethics','economics','statics','dynamics','mechanics-materials','materials','fluid-mechanics','surveying','water-resources','structural','geotechnical','transportation','construction'];
export function collect() {
  const seen = new Set(); const out = [];
  const push = (p, pool, chapter) => { if (p && p.id && !seen.has(p.id)) { seen.add(p.id); out.push({ p, pool, chapter }); } };
  for (const c of CHAPTER_IDS) {
    for (const s of LESSONS[c] || []) for (const l of s.lessons || []) for (const p of l.problems || []) push(p, 'lesson', c);
    for (const p of getExamBankForChapter(c)) push(p, 'exam', c);
    for (const p of getChapterPracticeProblems(c)) push(p, 'chapter', c);
  }
  return out;
}
`;

const trunc = (s, n) => { s = String(s == null ? '' : s); return s.length > n ? s.slice(0, n) + '…' : s; };

function slim({ p, pool, chapter }) {
  return {
    id: p.id,
    pool,
    chapter,
    type: p.type || null,
    difficulty: p.difficulty || null,
    statement: trunc(p.statement, 600),
    choices: Array.isArray(p.choices) ? p.choices.map((c) => trunc(c.text, 120)) : [],
    correct: p.correctAnswerId || null,
    eli5: trunc(p.eli5, 700),
    hint: trunc(p.hint, 300),
    steps: Array.isArray(p.steps)
      ? p.steps.map((s) => ({ text: trunc(s.text, 200), latex: trunc(s.latex, 200) }))
      : [],
    stepCount: Array.isArray(p.steps) ? p.steps.length : 0,
    traps: Array.isArray(p.traps) ? p.traps.map((t) => trunc(t, 200)) : [],
    handbookPage: p.handbookPage || null,
    handbookFormula: p.handbookFormula || null,
    diagram: p.diagram && typeof p.diagram === 'object' ? (p.diagram.component || true) : null,
    lessonId: p.lessonId || null,
  };
}

async function loadPool() {
  const res = await esbuild.build({
    stdin: { contents: ENTRY, resolveDir: DATA, sourcefile: 'pool-entry.js', loader: 'js' },
    bundle: true, format: 'esm', platform: 'node', write: false, logLevel: 'silent',
  });
  const tmp = path.join(os.tmpdir(), `dump-${process.pid}.mjs`);
  fs.writeFileSync(tmp, res.outputFiles[0].text);
  try { return (await import(pathToFileURL(tmp).href)).collect(); }
  finally { fs.rmSync(tmp, { force: true }); }
}

async function main() {
  const pool = await loadPool();
  const byChapter = {};
  for (const row of pool) (byChapter[row.chapter] ||= []).push(slim(row));

  fs.mkdirSync(OUT, { recursive: true });
  let total = 0;
  for (const [chapter, items] of Object.entries(byChapter)) {
    fs.writeFileSync(path.join(OUT, `${chapter}.json`), JSON.stringify(items, null, 1));
    total += items.length;
    process.stdout.write(`${chapter}: ${items.length}\n`);
  }
  process.stdout.write(`TOTAL: ${total} -> ${path.relative(ROOT, OUT)}/\n`);
}

main().catch((e) => { console.error(e); process.exit(1); });
