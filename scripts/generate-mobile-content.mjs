// Generates the mobile app's bundled content from the real bank + the mobile
// classification. Emits reviewable tap-the-trap PROBLEMS (non-paper, has choices,
// has a correct answer) into mobile/src/data/sources/content/generated/.
//
// Run from repo root:  node scripts/generate-mobile-content.mjs

import esbuild from 'esbuild';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const ROOT = process.cwd();
const DATA = path.join(ROOT, 'src', 'data');
const OUT = path.join(ROOT, 'mobile', 'src', 'data', 'sources', 'content', 'generated');

const ENTRY = `
import { LESSONS } from './lessons/index';
import { getExamBankForChapter } from './exam-bank/index';
import { getChapterPracticeProblems } from './chapter-practice/index';
const CH = ['mathematics','statistics','ethics','economics','statics','dynamics','mechanics-materials','materials','fluid-mechanics','surveying','water-resources','structural','geotechnical','transportation','construction'];
export function collect() {
  const seen = new Set(); const out = [];
  const push = (p) => { if (p && p.id && !seen.has(p.id)) { seen.add(p.id); out.push(p); } };
  for (const c of CH) {
    for (const s of LESSONS[c] || []) for (const l of s.lessons || []) for (const p of l.problems || []) push(p);
    for (const p of getExamBankForChapter(c)) push(p);
    for (const p of getChapterPracticeProblems(c)) push(p);
  }
  return out;
}
`;

const TIER = { concept: 'concept', 'phone-calc': 'phoneCalc', paper: 'paper' };
const INTERACTION = {
  'tap-the-trap': 'tapTheTrap', 'formula-first': 'formulaFirst', 'recall-reveal': 'recallReveal',
  'setup-not-solve': 'setupNotSolve', mcq: 'mcq',
};

const CHAPTERS = [
  { id: 'mathematics', name: 'Mathematics', examWeight: 0.09 },
  { id: 'statistics', name: 'Probability & Statistics', examWeight: 0.05 },
  { id: 'ethics', name: 'Ethics', examWeight: 0.05 },
  { id: 'economics', name: 'Engineering Economics', examWeight: 0.05 },
  { id: 'statics', name: 'Statics', examWeight: 0.08 },
  { id: 'dynamics', name: 'Dynamics', examWeight: 0.07 },
  { id: 'mechanics-materials', name: 'Mechanics of Materials', examWeight: 0.08 },
  { id: 'materials', name: 'Materials', examWeight: 0.05 },
  { id: 'fluid-mechanics', name: 'Fluid Mechanics', examWeight: 0.07 },
  { id: 'surveying', name: 'Surveying', examWeight: 0.06 },
  { id: 'water-resources', name: 'Water Resources', examWeight: 0.09 },
  { id: 'structural', name: 'Structural', examWeight: 0.09 },
  { id: 'geotechnical', name: 'Geotechnical', examWeight: 0.09 },
  { id: 'transportation', name: 'Transportation', examWeight: 0.09 },
  { id: 'construction', name: 'Construction', examWeight: 0.07 },
];

async function loadPool() {
  const res = await esbuild.build({
    stdin: { contents: ENTRY, resolveDir: DATA, sourcefile: 'e.js', loader: 'js' },
    bundle: true, format: 'esm', platform: 'node', write: false, logLevel: 'silent',
  });
  const tmp = path.join(os.tmpdir(), `gen-${process.pid}.mjs`);
  fs.writeFileSync(tmp, res.outputFiles[0].text);
  try { return (await import(pathToFileURL(tmp).href)).collect(); }
  finally { fs.rmSync(tmp, { force: true }); }
}

const pool = await loadPool();
const byId = new Map(pool.map((p) => [p.id, p]));
const cls = JSON.parse(fs.readFileSync(path.join(ROOT, 'docs/mobile/problem-classification.json'), 'utf8'));

const problems = [];
for (const rec of cls.problems) {
  if (rec.mobileTier === 'paper') continue;
  const p = byId.get(rec.id);
  if (!p || !Array.isArray(p.choices) || p.choices.length === 0 || !p.correctAnswerId) continue;
  problems.push({
    id: p.id,
    chapterId: rec.chapter,
    tier: TIER[rec.mobileTier] || 'concept',
    interaction: INTERACTION[rec.interaction && rec.interaction.primary] || 'tapTheTrap',
    statement: p.statement,
    choices: p.choices.map((c) => ({ id: c.id, text: c.text })),
    correctChoiceId: p.correctAnswerId,
    explanation: p.eli5 || '',
    handbookRef: p.handbookPage || null,
  });
}

// Formula-recall cards: a mined "formula-first" prompt + the VERIFIED handbook
// formula as the answer. Grounded (no fabricated content). Non-paper only.
const cards = [];
for (const rec of cls.problems) {
  if (rec.mobileTier === 'paper') continue;
  const p = byId.get(rec.id);
  if (!p || !p.handbookFormula) continue;
  const fc = (rec.cards || []).find((c) => c.kind === 'formula-first');
  if (!fc || !fc.prompt) continue;
  cards.push({
    id: `${p.id}:fc`,
    problemId: p.id,
    chapterId: rec.chapter,
    kind: 'formulaFirst',
    prompt: fc.prompt,
    answer: `$${p.handbookFormula}$${p.handbookPage ? ` (${p.handbookPage})` : ''}`,
  });
}

const present = new Set([...problems.map((p) => p.chapterId), ...cards.map((c) => c.chapterId)]);
const chapters = CHAPTERS.filter((c) => present.has(c.id));

fs.mkdirSync(OUT, { recursive: true });
fs.writeFileSync(path.join(OUT, 'problems.json'), JSON.stringify(problems));
fs.writeFileSync(path.join(OUT, 'cards.json'), JSON.stringify(cards));
fs.writeFileSync(path.join(OUT, 'chapters.json'), JSON.stringify(chapters, null, 1));

const byChapter = {};
for (const p of problems) byChapter[p.chapterId] = (byChapter[p.chapterId] || 0) + 1;
console.log(`problems: ${problems.length}  cards: ${cards.length}  chapters: ${chapters.length}`);
console.log('per chapter:', byChapter);
