// Mobile content-tiering report.
//
// Classifies every problem in the unified client-side pool (the exact same
// unique set getProblemPoolSize() counts) into the mobile tiers defined by
// docs/mobile-app-north-star.md:
//
//   phone  — phone-native: concept retrieval or light (<=2 step) computation,
//            doable on a screen without reaching for paper.
//   paper  — the honest hand-off: multi-step (>=3) computation that needs
//            paper. Surfaced on the phone, flagged "grab paper", never faked.
//
// It also reports, per problem:
//   cardSeed — has a populated `traps` array or a handbook reference, so a
//              phone-native retrieval micro-card can be MINED from it (no
//              greenfield authoring) regardless of tier.
//   spatial  — carries a diagram (small-screen caveat).
//   inferred — had no authored `type` field (mostly lesson problems); tier was
//              inferred from step depth alone -> lower confidence.
//
// This is a FIRST-PASS, mechanical map. Two things still need human/LLM review
// (see the North Star doc): (1) borderline computationals — a 2-step problem
// with a log/trig term still needs paper; step-count undercounts load; and
// (2) the authored conceptual/computational tag itself is unaudited.
//
// Usage:  node scripts/classify-problems.mjs            (prints the report)
//         node scripts/classify-problems.mjs --write    (also writes the doc)

import esbuild from 'esbuild';
import { pathToFileURL } from 'node:url';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const ROOT = process.cwd();
const DATA = path.join(ROOT, 'src', 'data');

// Replicate problemPool.js aggregation, but keep each problem's source pool +
// chapter and de-dup by id in the SAME order, so the count matches the app.
const ENTRY = `
import { LESSONS } from './lessons/index';
import { getExamBankForChapter } from './exam-bank/index';
import { getChapterPracticeProblems } from './chapter-practice/index';

const CHAPTER_IDS = [
  'mathematics','statistics','ethics','economics','statics','dynamics',
  'mechanics-materials','materials','fluid-mechanics','surveying',
  'water-resources','structural','geotechnical','transportation','construction',
];

export function collect() {
  const seen = new Set();
  const out = [];
  const push = (p, pool, chapter) => {
    if (p && p.id && !seen.has(p.id)) { seen.add(p.id); out.push({ p, pool, chapter }); }
  };
  for (const chapterId of CHAPTER_IDS) {
    for (const subtopic of LESSONS[chapterId] || [])
      for (const lesson of subtopic.lessons || [])
        for (const p of lesson.problems || []) push(p, 'lesson', chapterId);
    for (const p of getExamBankForChapter(chapterId)) push(p, 'exam', chapterId);
    for (const p of getChapterPracticeProblems(chapterId)) push(p, 'chapter', chapterId);
  }
  return out;
}
`;

const CHAPTERS = [
  'mathematics', 'statistics', 'ethics', 'economics', 'statics', 'dynamics',
  'mechanics-materials', 'materials', 'fluid-mechanics', 'surveying',
  'water-resources', 'structural', 'geotechnical', 'transportation', 'construction',
];

// --- the classifier under test ----------------------------------------------
export function classifyProblem(p) {
  const stepCount = Array.isArray(p.steps) ? p.steps.length : 0;
  const type = typeof p.type === 'string' ? p.type : null;
  const isConceptual = type === 'conceptual';
  const tagged = type === 'conceptual' || type === 'computational';

  // Tier: conceptual is always phone-native; otherwise depth decides.
  let tier;
  if (isConceptual) tier = 'phone';
  else tier = stepCount <= 2 ? 'phone' : 'paper';

  const cardSeed =
    (Array.isArray(p.traps) && p.traps.length > 0) ||
    Boolean(p.handbookFormula) ||
    Boolean(p.handbookPage);
  const spatial = Boolean(p.diagram && typeof p.diagram === 'object');

  // Computational items landing in 'phone' on step-count alone are exactly the
  // ones an LLM cognitive-load recheck should re-examine (may move to paper).
  const borderline = tier === 'phone' && !isConceptual && stepCount >= 1;

  return { tier, type: type || 'untyped', stepCount, isConceptual, tagged, cardSeed, spatial, borderline };
}

async function loadPool() {
  const res = await esbuild.build({
    stdin: { contents: ENTRY, resolveDir: DATA, sourcefile: 'pool-entry.js', loader: 'js' },
    bundle: true,
    format: 'esm',
    platform: 'node',
    write: false,
    logLevel: 'silent',
  });
  const tmp = path.join(os.tmpdir(), `pool-${process.pid}.mjs`);
  fs.writeFileSync(tmp, res.outputFiles[0].text);
  try {
    const mod = await import(pathToFileURL(tmp).href);
    return mod.collect();
  } finally {
    fs.rmSync(tmp, { force: true });
  }
}

function blank() {
  return { total: 0, phone: 0, paper: 0, conceptual: 0, cardSeed: 0, spatial: 0, inferred: 0, borderline: 0 };
}

function pct(n, d) { return d ? `${Math.round((n / d) * 100)}%` : '—'; }

function render(rows, totals, byPool) {
  const L = [];
  L.push('# Mobile content tiers — first-pass classification\n');
  L.push(`_Generated by \`scripts/classify-problems.mjs\`. ${totals.total} unique problems ` +
         `(matches \`getProblemPoolSize()\`)._\n`);
  L.push('Tiers per `docs/mobile-app-north-star.md`. **phone** = concept retrieval or ' +
         '≤2-step computation (doable on a screen). **paper** = ≥3-step computation, ' +
         'surfaced as an honest "grab paper" hand-off. **card-seed** = has `traps`/handbook ' +
         'refs, so a phone retrieval micro-card can be mined from it regardless of tier.\n');

  const head = '| Chapter | Total | Phone | Paper | Conceptual | Card-seed | Spatial | Untyped* |';
  const sep  = '|---|--:|--:|--:|--:|--:|--:|--:|';
  L.push(head); L.push(sep);
  for (const c of CHAPTERS) {
    const r = rows[c]; if (!r || !r.total) continue;
    L.push(`| ${c} | ${r.total} | ${r.phone} | ${r.paper} | ${r.conceptual} | ${r.cardSeed} | ${r.spatial} | ${r.inferred} |`);
  }
  L.push(`| **TOTAL** | **${totals.total}** | **${totals.phone}** (${pct(totals.phone, totals.total)}) | ` +
         `**${totals.paper}** (${pct(totals.paper, totals.total)}) | **${totals.conceptual}** | ` +
         `**${totals.cardSeed}** | **${totals.spatial}** | **${totals.inferred}** |`);
  L.push('');
  L.push('\\* **Untyped** = no authored `conceptual`/`computational` tag (mostly lesson ' +
         'problems); tier inferred from step depth alone — lower confidence.\n');

  L.push('## By source pool\n');
  L.push('| Pool | Total | Phone | Paper | Untyped |'); L.push('|---|--:|--:|--:|--:|');
  for (const [pool, r] of Object.entries(byPool))
    L.push(`| ${pool} | ${r.total} | ${r.phone} | ${r.paper} | ${r.inferred} |`);
  L.push('');

  L.push('## Review queue (not yet trustworthy)\n');
  L.push(`- **${totals.borderline}** computational items landed in *phone* on step-count ` +
         `alone — the LLM cognitive-load recheck should re-examine these (a 2-step log/trig ` +
         `problem still needs paper). Some will move to *paper*.`);
  L.push(`- **${totals.inferred}** problems carry no authored type tag — tier is inferred.`);
  L.push(`- **${totals.cardSeed}** problems can seed a phone retrieval micro-card (drafted by ` +
         `LLM, **human-verified** before shipping).`);
  L.push('');
  return L.join('\n');
}

async function main() {
  const pool = await loadPool();
  const rows = Object.fromEntries(CHAPTERS.map((c) => [c, blank()]));
  const byPool = { lesson: blank(), exam: blank(), chapter: blank() };
  const totals = blank();

  for (const { p, pool: src, chapter } of pool) {
    const c = classifyProblem(p);
    for (const bucket of [rows[chapter] || (rows[chapter] = blank()), byPool[src], totals]) {
      bucket.total++;
      bucket[c.tier]++;
      if (c.isConceptual) bucket.conceptual++;
      if (c.cardSeed) bucket.cardSeed++;
      if (c.spatial) bucket.spatial++;
      if (!c.tagged) bucket.inferred++;
      if (c.borderline) bucket.borderline++;
    }
  }

  const report = render(rows, totals, byPool);
  process.stdout.write(report + '\n');
  if (process.argv.includes('--write')) {
    const out = path.join(ROOT, 'docs', 'mobile-content-tiers.md');
    fs.writeFileSync(out, report);
    process.stdout.write(`\nwrote ${path.relative(ROOT, out)}\n`);
  }
}

main().catch((e) => { console.error(e); process.exit(1); });
