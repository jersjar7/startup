// Build-time prerender for the public, crawlable FE Civil pages.
// Runs AFTER `vite build`: serves dist/ with Vite preview, renders each public
// route with Playwright (so KaTeX + content + JSON-LD are in the HTML), and
// writes dist/<route>/index.html. Also (re)generates sitemap.xml and llms.txt.
import { preview } from 'vite';
import pw from 'playwright';
import fs from 'node:fs';
import path from 'node:path';

const { chromium } = pw;
const PORT = 4317;
const BASE = `http://localhost:${PORT}`;
const SITE = 'https://fe4raccoons.com';

const TOPICS = [
  ['mathematics', 'Mathematics & Computational Tools'],
  ['statistics', 'Probability & Statistics'],
  ['ethics', 'Ethics & Professional Practice'],
  ['economics', 'Engineering Economics'],
  ['statics', 'Statics'],
  ['dynamics', 'Dynamics'],
  ['mechanics-materials', 'Mechanics of Materials'],
  ['materials', 'Materials'],
  ['fluid-mechanics', 'Fluid Mechanics'],
  ['surveying', 'Surveying'],
  ['water-resources', 'Water Resources & Environmental'],
  ['structural', 'Structural Analysis & Design'],
  ['geotechnical', 'Geotechnical Engineering'],
  ['transportation', 'Transportation Engineering'],
  ['construction', 'Construction'],
];

const ROUTES = ['/fe-civil-exam-guide', ...TOPICS.map(([id]) => `/fe-civil/${id}`)];

function writeFile(rel, contents) {
  const full = path.join('dist', rel);
  fs.mkdirSync(path.dirname(full), { recursive: true });
  fs.writeFileSync(full, contents);
}

const server = await preview({ preview: { port: PORT, strictPort: true } });
const browser = await chromium.launch();
const page = await browser.newPage();

try {
  for (const route of ROUTES) {
    await page.goto(BASE + route, { waitUntil: 'networkidle' });
    await page.waitForSelector('[data-seo-ready="1"]', { timeout: 20000 });
    await page.waitForSelector('main.pub h1', { timeout: 20000 });
    const html = '<!DOCTYPE html>\n' + (await page.evaluate(() => document.documentElement.outerHTML));
    writeFile(path.join(route, 'index.html'), html);
    const bytes = Buffer.byteLength(html);
    console.log(`  prerendered ${route}  (${(bytes / 1024).toFixed(0)} KB)`);
  }
} finally {
  await browser.close();
  await server.httpServer.close();
}

// ---- sitemap.xml ----
const urls = [
  { loc: `${SITE}/`, priority: '1.0', freq: 'weekly' },
  { loc: `${SITE}/fe-civil-exam-guide`, priority: '0.9', freq: 'weekly' },
  ...TOPICS.map(([id]) => ({ loc: `${SITE}/fe-civil/${id}`, priority: '0.8', freq: 'monthly' })),
  { loc: `${SITE}/login`, priority: '0.4', freq: 'monthly' },
];
const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls.map((u) => `  <url>\n    <loc>${u.loc}</loc>\n    <changefreq>${u.freq}</changefreq>\n    <priority>${u.priority}</priority>\n  </url>`).join('\n')}
</urlset>
`;
writeFile('sitemap.xml', sitemap);

// ---- llms.txt ----
const llms = `# FE for Raccoons

> Free study platform for the NCEES FE Civil (Fundamentals of Engineering) exam.
> 1,126 practice problems across all 15 NCEES topic areas, bite-sized lessons with
> plain-English ("ELI5") explanations, FE Reference Handbook page references, and a
> timed full-length exam simulation.

## FE Civil exam guides
- [FE Civil Exam Guide](${SITE}/fe-civil-exam-guide): format, all 15 topics, how to prepare.
${TOPICS.map(([id, name]) => `- [${name}](${SITE}/fe-civil/${id}): what NCEES tests, key formulas, sample problems, common mistakes.`).join('\n')}

## About
- Audience: engineering students and graduates preparing for the FE Civil exam (the first step toward the PE license).
- Free practice across every chapter; an optional one-time paid pass unlocks the full timed exam simulation.
`;
writeFile('llms.txt', llms);

console.log(`  wrote sitemap.xml (${urls.length} urls) + llms.txt`);
console.log(`Prerender complete: ${ROUTES.length} pages.`);
