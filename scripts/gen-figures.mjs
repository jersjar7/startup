// Render the website's diagram components to PNG images for the mobile app.
//
// The diagrams use SVG <marker> arrowheads, which flutter_svg does NOT render —
// so an SVG export loses every arrow. Instead we render each diagram in a real
// headless browser (which handles markers, fonts, everything) and screenshot it
// to a transparent PNG. The result looks exactly like the website.
//
// React component (react-dom/server) -> SVG string (brand colors inlined) ->
// Chromium screenshot -> service/figures/<figureId>.png
//
//   node scripts/gen-content.mjs && node scripts/gen-figures.mjs
import { build } from 'esbuild';
import { chromium } from 'playwright';
import { createRequire } from 'module';
import { mkdtempSync, writeFileSync, readFileSync, mkdirSync, rmSync } from 'fs';
import { tmpdir } from 'os';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const require = createRequire(import.meta.url);
const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const p = (rel) => JSON.stringify(join(root, rel));

const VARS = {
  '--charcoal': '#2C2C2C', '--ember': '#E8683A', '--cream': '#FFF9F0',
  '--cream-dark': '#F5EDE0', '--sunbeam': '#F5B731', '--forest': '#2D7A5F',
  '--error': '#D64045', '--info': '#3B82B8', '--ember-bg': '#FEF0EA',
  '--forest-bg': '#E8F5EE', '--sunbeam-bg': '#FEF7E0',
  '--font-body': "-apple-system, Helvetica, Arial, sans-serif",
  '--font-mono': "Menlo, monospace",
};
const inlineVars = (svg) => svg.replace(/var\((--[a-z-]+)\)/g, (m, name) => VARS[name] ?? m);

const content = JSON.parse(readFileSync(join(root, 'service/content.json'), 'utf8'));
const figures = content.figures || {};

// 1) Render each diagram component to an SVG string.
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
await build({ stdin: { contents: entry, resolveDir: root, loader: 'js' }, bundle: true, format: 'cjs', platform: 'node', jsx: 'automatic', outfile: out, logLevel: 'silent' });
delete require.cache[out];
const { render } = require(out);

// 2) Rasterize each SVG in a headless browser to a transparent PNG.
const outDir = join(root, 'service/figures');
rmSync(outDir, { recursive: true, force: true });
mkdirSync(outDir, { recursive: true });

const SCALE = 3; // retina-crisp
const browser = await chromium.launch();
const page = await browser.newPage({ deviceScaleFactor: SCALE });

let done = 0;
const missing = new Set();
for (const [id, fig] of Object.entries(figures)) {
  const raw = render(fig.component, fig.props);
  if (!raw) { missing.add(fig.component); continue; }
  const svg = inlineVars(raw);
  const vb = svg.match(/viewBox="0 0 ([\d.]+) ([\d.]+)"/);
  const w = vb ? Math.round(parseFloat(vb[1])) : 360;
  await page.setViewportSize({ width: w + 8, height: 1000 });
  await page.setContent(
    `<!doctype html><html><head><meta charset="utf-8"><style>*{margin:0;padding:0}html,body{background:transparent}#w{width:${w}px}#w svg{width:100%;height:auto;display:block}</style></head><body><div id="w">${svg}</div></body></html>`,
    { waitUntil: 'networkidle' },
  );
  const el = await page.$('#w');
  await el.screenshot({ path: join(outDir, `${id}.png`), omitBackground: true });
  done++;
}
await browser.close();

console.log(`[gen-figures] ${done}/${Object.keys(figures).length} figures rendered to service/figures/*.png` + (missing.size ? ` · MISSING: ${[...missing].join(', ')}` : ''));
