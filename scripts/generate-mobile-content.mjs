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
  // examWeight = NCEES FE Civil question count (out of 110), same weights as the
  // web (service/examWeights.js), so the weighted "Concept mastery" number is
  // identical on both surfaces. Used as relative weights, so the scale is fine.
  { id: 'mathematics', name: 'Mathematics', examWeight: 13 },
  { id: 'statistics', name: 'Probability & Statistics', examWeight: 4 },
  { id: 'ethics', name: 'Ethics', examWeight: 4 },
  { id: 'economics', name: 'Engineering Economics', examWeight: 4 },
  { id: 'statics', name: 'Statics', examWeight: 8 },
  { id: 'dynamics', name: 'Dynamics', examWeight: 4 },
  { id: 'mechanics-materials', name: 'Mechanics of Materials', examWeight: 8 },
  { id: 'materials', name: 'Materials', examWeight: 4 },
  { id: 'fluid-mechanics', name: 'Fluid Mechanics', examWeight: 4 },
  { id: 'surveying', name: 'Surveying', examWeight: 4 },
  { id: 'water-resources', name: 'Water Resources', examWeight: 14 },
  { id: 'structural', name: 'Structural', examWeight: 13 },
  { id: 'geotechnical', name: 'Geotechnical', examWeight: 11 },
  { id: 'transportation', name: 'Transportation', examWeight: 10 },
  { id: 'construction', name: 'Construction', examWeight: 5 },
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

// Recall cards, all grounded (no fabricated content), non-paper only:
//  • formula-first → mined prompt + the VERIFIED handbook formula
//  • concept/trap  → mined tap-the-trap prompt + the VERIFIED eli5 explanation
const cards = [];
const trimEli5 = (s) => (s.length > 320 ? `${s.slice(0, 317).replace(/\s+\S*$/, '')}…` : s);
for (const rec of cls.problems) {
  if (rec.mobileTier === 'paper') continue;
  const p = byId.get(rec.id);
  if (!p) continue;
  const mined = rec.cards || [];

  const fc = mined.find((c) => c.kind === 'formula-first');
  if (fc && fc.prompt && p.handbookFormula) {
    cards.push({
      id: `${p.id}:fc`,
      problemId: p.id,
      chapterId: rec.chapter,
      kind: 'formulaFirst',
      prompt: fc.prompt,
      answer: `$${p.handbookFormula}$${p.handbookPage ? ` (${p.handbookPage})` : ''}`,
    });
  }

  const tc = mined.find((c) => c.kind === 'tap-the-trap');
  if (tc && tc.prompt && p.eli5) {
    cards.push({
      id: `${p.id}:cc`,
      problemId: p.id,
      chapterId: rec.chapter,
      kind: 'tapTheTrap',
      prompt: tc.prompt,
      answer: trimEli5(p.eli5),
    });
  }
}

// Hand-audited corrections (e.g. two-part prompts whose generated answer only
// covered one clause) — see scripts/card-answer-overrides.json.
const OVERRIDES_PATH = path.join(ROOT, 'scripts', 'card-answer-overrides.json');
if (fs.existsSync(OVERRIDES_PATH)) {
  const overrides = JSON.parse(fs.readFileSync(OVERRIDES_PATH, 'utf8'));
  let applied = 0;
  for (const card of cards) {
    const o = overrides[card.id];
    if (!o) continue;
    if (o.answer) card.answer = o.answer;
    if (o.prompt) card.prompt = o.prompt;
    applied++;
  }
  console.log(`applied ${applied} card overrides`);
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
