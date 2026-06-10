// Aggregate the per-chapter mobile classifications (mobile-analysis/out/*.json)
// into one validated dataset + rollup. Cross-checks every record against the
// source dump (mobile-analysis/in/*.json): same count, same ids, no dupes,
// needsPaper consistent with tier. Writes docs/mobile/problem-classification.json.

import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.cwd();
const IN = path.join(ROOT, 'mobile-analysis', 'in');
const OUT = path.join(ROOT, 'mobile-analysis', 'out');
const FINAL = path.join(ROOT, 'docs', 'mobile', 'problem-classification.json');

const CHAPTERS = [
  'mathematics', 'statistics', 'ethics', 'economics', 'statics', 'dynamics',
  'mechanics-materials', 'materials', 'fluid-mechanics', 'surveying',
  'water-resources', 'structural', 'geotechnical', 'transportation', 'construction',
];
const TIERS = ['concept', 'phone-calc', 'paper'];

const problems = [];
const errors = [];

for (const ch of CHAPTERS) {
  const src = JSON.parse(fs.readFileSync(path.join(IN, `${ch}.json`), 'utf8'));
  const srcById = new Map(src.map((p) => [p.id, p]));
  let cls;
  try { cls = JSON.parse(fs.readFileSync(path.join(OUT, `${ch}.json`), 'utf8')); }
  catch (e) { errors.push(`${ch}: output unreadable/invalid JSON — ${e.message}`); continue; }

  if (cls.length !== src.length) errors.push(`${ch}: count ${cls.length} != source ${src.length}`);
  const seen = new Set();
  for (const r of cls) {
    if (!r || !r.id) { errors.push(`${ch}: record missing id`); continue; }
    if (seen.has(r.id)) errors.push(`${ch}: duplicate id ${r.id}`);
    seen.add(r.id);
    if (!srcById.has(r.id)) { errors.push(`${ch}: id ${r.id} not in source`); continue; }
    if (!TIERS.includes(r.mobileTier)) errors.push(`${ch}/${r.id}: bad tier ${r.mobileTier}`);
    const wantsPaper = r.mobileTier === 'paper';
    if (Boolean(r.needsPaper) !== wantsPaper) errors.push(`${ch}/${r.id}: needsPaper ${r.needsPaper} vs tier ${r.mobileTier}`);
    const s = srcById.get(r.id);
    problems.push({
      id: r.id,
      chapter: ch,
      pool: s.pool,
      authoredType: s.type,
      difficulty: s.difficulty,
      mobileTier: r.mobileTier,
      interaction: r.interaction || null,
      cards: Array.isArray(r.cards) ? r.cards : [],
      needsPaper: Boolean(r.needsPaper),
      confidence: r.confidence || null,
      reviewFlag: Boolean(r.reviewFlag),
      reviewReason: r.reviewReason || null,
      note: r.note || null,
    });
  }
  for (const id of srcById.keys()) if (!seen.has(id)) errors.push(`${ch}: source id ${id} missing from output`);
}

// ---- rollups ---------------------------------------------------------------
const tally = (arr, f) => arr.reduce((m, x) => { const k = f(x); m[k] = (m[k] || 0) + 1; return m; }, {});
const primary = (r) => (r.interaction && r.interaction.primary) || 'none';

const byTier = tally(problems, (r) => r.mobileTier);
const byInteraction = tally(problems, primary);
const byConfidence = tally(problems, (r) => r.confidence || 'none');
const reviewFlags = problems.filter((r) => r.reviewFlag).length;
const totalCards = problems.reduce((n, r) => n + r.cards.length, 0);
const cardsByKind = tally(problems.flatMap((r) => r.cards), (c) => (c && c.kind) || 'unknown');

const perChapter = {};
for (const ch of CHAPTERS) {
  const rows = problems.filter((r) => r.chapter === ch);
  perChapter[ch] = {
    total: rows.length,
    ...Object.fromEntries(TIERS.map((t) => [t, rows.filter((r) => r.mobileTier === t).length])),
    cards: rows.reduce((n, r) => n + r.cards.length, 0),
    review: rows.filter((r) => r.reviewFlag).length,
  };
}

const phoneNative = byTier.concept + byTier['phone-calc'];

console.log('=== INTEGRITY ===');
console.log(`records: ${problems.length} (expect 1126)`);
console.log(errors.length ? `ERRORS (${errors.length}):\n - ` + errors.slice(0, 40).join('\n - ') : 'no integrity errors');
console.log('\n=== ROLLUP ===');
console.log('by tier:', byTier, `| phone-native total: ${phoneNative} (${Math.round(phoneNative / problems.length * 100)}%)`);
console.log('by primary interaction:', byInteraction);
console.log('by confidence:', byConfidence);
console.log(`reviewFlags: ${reviewFlags}`);
console.log(`mined cards: ${totalCards} (avg ${(totalCards / problems.length).toFixed(1)}/problem)`, 'by kind:', cardsByKind);
console.log('\n=== PER CHAPTER (total / concept / phone-calc / paper / cards / review) ===');
for (const ch of CHAPTERS) { const c = perChapter[ch]; console.log(`${ch.padEnd(20)} ${c.total}\t${c.concept}\t${c['phone-calc']}\t${c.paper}\t${c.cards}\t${c.review}`); }

if (!errors.length || process.argv.includes('--force')) {
  fs.writeFileSync(FINAL, JSON.stringify({
    generated: 'scripts/aggregate-tiers.mjs',
    total: problems.length,
    rollup: { byTier, phoneNative, byInteraction, byConfidence, reviewFlags, totalCards, cardsByKind, perChapter },
    problems,
  }, null, 1));
  console.log(`\nwrote ${path.relative(ROOT, FINAL)} (${problems.length} records)`);
} else {
  console.log('\nNOT writing final artifact — fix integrity errors first (or pass --force).');
}
