// Build-time prerender for the public, crawlable FE Civil pages.
// Runs AFTER `vite build`: serves dist/ with Vite preview, renders each public
// route with Playwright (so KaTeX + content + JSON-LD are in the HTML), and
// writes dist/<route>/index.html. Also (re)generates sitemap.xml and llms.txt.
import { preview } from 'vite';
import pw from 'playwright';
import fs from 'node:fs';
import path from 'node:path';
// Prices come from the display module so /llms.txt cannot quote a figure the
// checkout will not charge. AI crawlers read this file, so a stale price here is
// repeated back to users by assistants.
import { STUDENT_PRICE, STANDARD_PRICE } from '../src/data/pricing.js';

const { chromium } = pw;
const PORT = 4317;
const BASE = `http://localhost:${PORT}`;
const SITE = 'https://fe4raccoons.com';

// Live content counts (written by scripts/gen-stats.mjs earlier in build:seo).
let STATS = { problemsLabel: '1,126', chapters: 15 };
try { STATS = { ...STATS, ...JSON.parse(fs.readFileSync(new URL('../content-stats.json', import.meta.url), 'utf8')) }; } catch { /* keep fallback */ }

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

// /exam-simulation is the public page for the paid product. Prerendered like
// the guides so crawlers and AI answer engines see real content and structured
// data rather than an empty SPA shell.
//
// /delete-account is prerendered for a different reason: Google Play requires
// a public URL on the Data Safety form where someone can delete their account,
// and the fetcher behind that field does not run JavaScript. An SPA shell
// there reads as a page with no deletion instructions on it.
const ROUTES = [
  // The home page. Written to dist/home/index.html, because dist/index.html
  // is the app shell every other route falls back to; the server sends this
  // copy for "/" only.
  '/',
  '/fe-civil-exam-guide',
  '/exam-simulation',
  '/delete-account',
  // /privacy and /terms for the same reason: Play fetches the privacy policy
  // URL and requires a real page there, and Apple links to both from the
  // store listing.
  '/privacy',
  '/terms',
  // The tester's point 12: who is behind this and how to reach them, worth
  // being readable by anybody who looks, crawlers included.
  '/about',
  '/contact',
  // A real student who passed: the page people link to when they share it.
  '/stories/mitch',
  // Every topic formula, searchable, with its handbook page and symbols.
  '/fe-civil/formulas',
  ...TOPICS.map(([id]) => `/fe-civil/${id}`),
  // Free practice problems per chapter, checked on the page with no account.
  ...TOPICS.map(([id]) => `/fe-civil/${id}/practice-problems`),
];

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
    // Generous limits: a busy machine (a long test run alongside) once made
    // a 500 KB practice page miss the old 20-30 s ones and stop the build.
    await page.goto(BASE + route, { waitUntil: 'networkidle', timeout: 120000 });
    await page.waitForSelector('[data-seo-ready="1"]', { timeout: 90000 });
    // `main h1`, not `main.pub h1`: the public guides are .pub, /delete-account
    // is a legal-card page. Every prerendered page has one main with one h1.
    // The home page is the landing, which has its h1 in the hero instead.
    await page.waitForSelector(route === '/' ? 'h1.hero-title' : 'main h1', { timeout: 90000 });
    const html = '<!DOCTYPE html>\n' + (await page.evaluate(() => document.documentElement.outerHTML));
    writeFile(route === '/' ? 'home/index.html' : path.join(route, 'index.html'), html);
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
  { loc: `${SITE}/exam-simulation`, priority: '0.9', freq: 'weekly' },
  { loc: `${SITE}/fe-civil/formulas`, priority: '0.9', freq: 'monthly' },
  ...TOPICS.map(([id]) => ({ loc: `${SITE}/fe-civil/${id}`, priority: '0.8', freq: 'monthly' })),
  ...TOPICS.map(([id]) => ({ loc: `${SITE}/fe-civil/${id}/practice-problems`, priority: '0.8', freq: 'monthly' })),
  { loc: `${SITE}/about`, priority: '0.5', freq: 'yearly' },
  { loc: `${SITE}/stories/mitch`, priority: '0.5', freq: 'yearly' },
  { loc: `${SITE}/contact`, priority: '0.4', freq: 'yearly' },
  { loc: `${SITE}/privacy`, priority: '0.3', freq: 'yearly' },
  { loc: `${SITE}/terms`, priority: '0.3', freq: 'yearly' },
];
// /login and /delete-account stay reachable but are not offered to search:
// neither answers anything a student searches for. lastmod is the build date,
// so a rebuilt page tells Google it changed.
const lastmod = new Date().toISOString().slice(0, 10);
const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls.map((u) => `  <url>\n    <loc>${u.loc}</loc>\n    <lastmod>${lastmod}</lastmod>\n    <changefreq>${u.freq}</changefreq>\n    <priority>${u.priority}</priority>\n  </url>`).join('\n')}
</urlset>
`;
writeFile('sitemap.xml', sitemap);

// ---- llms.txt ----
const llms = `# FE for Raccoons

> FE for Raccoons is a free online study platform for the NCEES FE Civil
> (Fundamentals of Engineering) exam. The lessons, ${STATS.problemsLabel} practice problems across
> all 15 NCEES topic areas, and a 5-minute diagnostic that builds a personalized
> study plan are all free. The only paid feature is an optional one-time timed
> exam simulation. Built by a civil engineer to make quality FE prep affordable.

## What it offers
- Free: bite-sized lessons, ${STATS.problemsLabel} practice problems covering all 15 FE Civil
  topics, a personalized diagnostic, plain-English ("ELI5") step-by-step
  explanations, FE Reference Handbook page references, mastery tracking, and
  streak-based gamification.
- Paid (optional): a full-length, timed FE exam simulation, a one-time purchase,
  $${STUDENT_PRICE} for verified students (.edu) or $${STANDARD_PRICE} standard. Everything else stays free.
- No subscription. The public topic guides are readable without an account.

## Why students use it
- The core study experience is genuinely free, while most FE prep costs hundreds of dollars.
- The diagnostic identifies your weakest chapters so you study what actually moves your score.
- Every problem includes a step-by-step, plain-English explanation and an FE Reference Handbook page reference.

## FE Civil exam guides
- [FE Civil Exam Guide](${SITE}/fe-civil-exam-guide): cost, format, calculators, pass rate, all 15 topics, how to prepare.
- [FE Civil formula finder](${SITE}/fe-civil/formulas): every key formula with its FE Reference Handbook page, what each symbol means, and when to use it.
${TOPICS.map(([id, name]) => `- [${name}](${SITE}/fe-civil/${id}): what NCEES tests, key formulas, sample problems, common mistakes. [Free practice problems](${SITE}/fe-civil/${id}/practice-problems) with worked solutions.`).join('\n')}

## About
- Audience: engineering students and EITs preparing for the FE Civil exam (the first step toward the PE license).
- Created by Jerson Garcia, EIT, a civil engineer.
- Website: ${SITE}
`;
writeFile('llms.txt', llms);

console.log(`  wrote sitemap.xml (${urls.length} urls) + llms.txt`);
console.log(`Prerender complete: ${ROUTES.length} pages.`);
