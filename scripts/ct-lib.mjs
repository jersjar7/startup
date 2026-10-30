// Shared loader for the chapter test tools (ct-check, ct-render). Bundles the
// real source with esbuild, the same trick gen-content.mjs uses, so the tools
// read exactly what the site would ship.
import { build } from 'esbuild';
import { createRequire } from 'module';
import { mkdtempSync } from 'fs';
import { tmpdir } from 'os';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const require = createRequire(import.meta.url);
export const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const p = (rel) => JSON.stringify(join(root, rel));

export const UNITS = [
  'mathematics', 'statistics', 'ethics', 'economics', 'statics', 'dynamics',
  'mechanics-materials', 'materials', 'fluid-mechanics', 'surveying',
  'water-resources', 'structural', 'geotechnical', 'transportation', 'construction',
].flatMap((c) => [`${c}-a`, `${c}-b`]);

export async function load() {
  const entry = `
    import { renderToStaticMarkup } from 'react-dom/server';
    import { createElement } from 'react';
    import { DIAGRAM_REGISTRY } from ${p('src/components/diagrams/index.js')};
    import { CHAPTER_TESTS, TEST_LENGTH } from ${p('src/data/chapter-tests/index.js')};
    import { LESSONS } from ${p('src/data/lessons/index.js')};
    import { getExamBankForChapter } from ${p('src/data/exam-bank/index.js')};
    import { getChapterPracticeProblems } from ${p('src/data/chapter-practice/index.js')};
    export function render(component, props) {
      const C = DIAGRAM_REGISTRY[component];
      if (!C) return null;
      return renderToStaticMarkup(createElement(C, props || {}));
    }
    export function existing() {
      const out = [];
      for (const chId of Object.keys(LESSONS)) {
        for (const g of LESSONS[chId] || []) for (const l of g.lessons || []) for (const x of l.problems || []) out.push({ id: x.id, bank: 'lesson', statement: x.statement || '' });
        for (const x of getExamBankForChapter(chId)) out.push({ id: x.id, bank: 'exam', statement: x.statement || '' });
        for (const x of getChapterPracticeProblems(chId)) out.push({ id: x.id, bank: 'practice', statement: x.statement || '' });
      }
      return out;
    }
    export const registry = Object.keys(DIAGRAM_REGISTRY);
    export { CHAPTER_TESTS, TEST_LENGTH };
  `;
  const out = join(mkdtempSync(join(tmpdir(), 'ct-')), 'ct.cjs');
  await build({
    stdin: { contents: entry, resolveDir: root, loader: 'js' },
    bundle: true, format: 'cjs', platform: 'node', jsx: 'automatic',
    loader: { '.js': 'jsx' }, outfile: out, logLevel: 'silent',
  });
  return require(out);
}

export function unitProblems(mod, unit) {
  const v = unit.slice(-1).toUpperCase();
  const ch = unit.slice(0, -2);
  return (mod.CHAPTER_TESTS[ch] || {})[v] || [];
}

// Every $...$ (or $$...$$) segment of a string.
export function mathSegments(s) {
  if (typeof s !== 'string') return [];
  const out = [];
  const re = /\$\$([\s\S]+?)\$\$|\$([^$]+?)\$/g;
  let m;
  while ((m = re.exec(s))) out.push(m[1] ?? m[2]);
  return out;
}

const STOP = new Set('a an the of to and or in on at for is are be by with from that this what which as its it if into than then per each'.split(' '));
export function tokens(s) {
  return new Set(String(s).toLowerCase().replace(/\$[^$]*\$/g, ' ').replace(/[^a-z0-9.]+/g, ' ').split(' ').filter((w) => w && !STOP.has(w)));
}
export function jaccard(a, b) {
  let i = 0;
  for (const w of a) if (b.has(w)) i++;
  return i / (a.size + b.size - i || 1);
}
