// Render the website's diagram components to static SVG so the mobile app can
// show problem figures (it can't run the React components). Reads the figure
// list from service/content.json (gen-content stamps each figure with an id),
// renders each via react-dom/server, inlines the brand colors (flutter_svg
// can't resolve CSS var()), and writes service/figures.json { figureId: svg }.
//
//   node scripts/gen-content.mjs && node scripts/gen-figures.mjs
import { build } from 'esbuild';
import { createRequire } from 'module';
import { mkdtempSync, writeFileSync, readFileSync } from 'fs';
import { tmpdir } from 'os';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const require = createRequire(import.meta.url);
const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const p = (rel) => JSON.stringify(join(root, rel));

// Brand tokens -> concrete values (must match app_colors.dart / the web).
const VARS = {
  '--charcoal': '#2C2C2C',
  '--ember': '#E8683A',
  '--cream': '#FFF9F0',
  '--cream-dark': '#F5EDE0',
  '--sunbeam': '#F5B731',
  '--forest': '#2D7A5F',
  '--error': '#D64045',
  '--info': '#3B82B8',
  '--ember-bg': '#FEF0EA',
  '--forest-bg': '#E8F5EE',
  '--sunbeam-bg': '#FEF7E0',
  '--font-body': "-apple-system, Helvetica, Arial, sans-serif",
  '--font-mono': "Menlo, monospace",
};
const inlineVars = (svg) => svg.replace(/var\((--[a-z-]+)\)/g, (m, name) => VARS[name] ?? m);

const content = JSON.parse(readFileSync(join(root, 'service/content.json'), 'utf8'));
const figures = content.figures || {};

const entry = `
  import { renderToStaticMarkup } from 'react-dom/server';
  import { createElement } from 'react';
  import { DIAGRAM_REGISTRY } from ${p('src/components/diagrams/index.js')};
  export function render(component, props) {
    const C = DIAGRAM_REGISTRY[component];
    if (!C) return null;
    return renderToStaticMarkup(createElement(C, props || {}));
  }
`;

const out = join(mkdtempSync(join(tmpdir(), 'gf-')), 'r.cjs');
await build({
  stdin: { contents: entry, resolveDir: root, loader: 'js' },
  bundle: true,
  format: 'cjs',
  platform: 'node',
  jsx: 'automatic',
  outfile: out,
  logLevel: 'silent',
});
delete require.cache[out];
const { render } = require(out);

const result = {};
const missing = new Set();
const unresolved = new Set();
for (const [id, fig] of Object.entries(figures)) {
  let svg = render(fig.component, fig.props);
  if (!svg) {
    missing.add(fig.component);
    continue;
  }
  svg = inlineVars(svg);
  const rem = svg.match(/var\((--[a-z-]+)\)/g);
  if (rem) rem.forEach((r) => unresolved.add(r));
  result[id] = svg;
}

writeFileSync(join(root, 'service/figures.json'), JSON.stringify(result));
console.log(
  `[gen-figures] ${Object.keys(result).length}/${Object.keys(figures).length} figures rendered` +
    (missing.size ? ` · MISSING components: ${[...missing].join(', ')}` : '') +
    (unresolved.size ? ` · UNRESOLVED vars: ${[...unresolved].join(', ')}` : ''),
);
