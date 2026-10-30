// Render one chapter test version for review.
//
//   node scripts/ct-render.mjs statics-a <outDir>
//
// Writes, in <outDir>:
//   <id>.png          each figure, rendered exactly as gen-figures.mjs does
//   questions.md      statements and choices only, no answers (for a blind solver)
//   key.json          the answer key, keyed by id (for the reviewer only)
import { chromium } from 'playwright';
import { mkdirSync, writeFileSync } from 'fs';
import { join } from 'path';
import { load, unitProblems, UNITS } from './ct-lib.mjs';

const [unit, outDir] = process.argv.slice(2);
if (!UNITS.includes(unit) || !outDir) { console.error('usage: node scripts/ct-render.mjs <unit> <outDir>'); process.exit(2); }
mkdirSync(outDir, { recursive: true });

const VARS = {
  '--charcoal': '#2C2C2C', '--ember': '#E8683A', '--cream': '#FFF9F0',
  '--cream-dark': '#F5EDE0', '--sunbeam': '#F5B731', '--forest': '#2D7A5F',
  '--error': '#D64045', '--info': '#3B82B8', '--ember-bg': '#FEF0EA',
  '--forest-bg': '#E8F5EE', '--sunbeam-bg': '#FEF7E0',
  '--gray-50': '#FAFAF8', '--gray-100': '#F0EDE6', '--gray-200': '#E0DDD5', '--gray-300': '#C4C0B7',
  '--gray-400': '#A09C93', '--gray-500': '#7A766D', '--gray-600': '#5C584F', '--gray-700': '#3D3A33',
  '--font-body': 'Inter, Helvetica, Arial, sans-serif', '--font-mono': "'JetBrains Mono', Menlo, monospace",
};
const inlineVars = (svg) => svg.replace(/var\((--[a-z0-9-]+)\)/g, (m, name) => VARS[name] ?? m);

const mod = await load();
const list = unitProblems(mod, unit);

const browser = await chromium.launch();
const page = await browser.newPage({ deviceScaleFactor: 2 });
const md = [`# ${unit}: questions only (no answers)\n`];
const key = {};
for (const x of list) {
  md.push(`## ${x.id}\n\n${x.statement}\n`);
  if (x.diagram) md.push(`Figure: ${join(outDir, `${x.id}.png`)}\n`);
  for (const c of x.choices || []) md.push(`- ${c.id}: ${c.text}`);
  md.push('');
  key[x.id] = { correctAnswerId: x.correctAnswerId, handbookPage: x.handbookPage, topic: x.topic, difficulty: x.difficulty };
  if (!x.diagram) continue;
  let svg;
  try { svg = mod.render(x.diagram.component, x.diagram.props); } catch (e) { console.log(`FAIL ${x.id}: ${e.message}`); continue; }
  if (!svg) { console.log(`MISSING ${x.id}: ${x.diagram.component}`); continue; }
  svg = inlineVars(svg);
  const vb = svg.match(/viewBox="0 0 ([\d.]+) ([\d.]+)"/);
  const w = vb ? Math.round(parseFloat(vb[1])) : 360;
  // Shown at the width a phone gives it, on the white question card.
  await page.setViewportSize({ width: Math.max(w, 360) + 32, height: 1200 });
  await page.setContent(`<!doctype html><html><head><meta charset="utf-8"><style>*{margin:0;padding:0}body{background:#fff;padding:16px}#w{width:${w}px}#w svg{width:100%;height:auto;display:block}</style></head><body><div id="w">${svg}</div></body></html>`, { waitUntil: 'networkidle' });
  await (await page.$('body')).screenshot({ path: join(outDir, `${x.id}.png`) });
}
await browser.close();
writeFileSync(join(outDir, 'questions.md'), md.join('\n'));
writeFileSync(join(outDir, 'key.json'), JSON.stringify(key, null, 2));
console.log(`${unit}: ${list.length} questions, ${list.filter((x) => x.diagram).length} figures -> ${outDir}`);
