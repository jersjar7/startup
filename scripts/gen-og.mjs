// Regenerates the Open Graph share image (public/og-image.png) from the LIVE
// content counts, so the card people see when they share fe4raccoons.com always
// reflects the real numbers — never a stale hardcode. Runs as part of build:seo
// (before `vite build`, so the fresh PNG gets copied into dist/). Resilient: if
// rendering can't run (no browser), it warns and leaves the existing image so a
// build is never broken.
import { readFileSync, writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { liveCounts } from './content-counts.mjs';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');

async function render(html, outPng) {
  const { chromium } = await import('playwright');
  const browser = await chromium.launch();
  try {
    const page = await browser.newPage({ viewport: { width: 1200, height: 630 } });
    await page.setContent(html, { waitUntil: 'networkidle' });
    await page.waitForTimeout(300); // let webfonts settle
    await page.screenshot({ path: outPng, clip: { x: 0, y: 0, width: 1200, height: 630 } });
  } finally {
    await browser.close();
  }
}

(async () => {
  try {
    const c = await liveCounts();
    const probs = c.problems.toLocaleString('en-US');
    const tpl = join(root, 'public/og-image.html');
    let html = readFileSync(tpl, 'utf8')
      .replace(/(<span class="stat-num">)[^<]*(<\/span><span class="stat-label">chapters<\/span>)/, `$1${c.chapters}$2`)
      .replace(/(<span class="stat-num">)[^<]*(<\/span><span class="stat-label">lessons<\/span>)/, `$1${c.lessons}$2`)
      .replace(/(<span class="stat-num">)[^<]*(<\/span><span class="stat-label">problems<\/span>)/, `$1${probs}$2`);
    writeFileSync(tpl, html); // keep the source template in sync with live counts
    await render(html, join(root, 'public/og-image.png'));
    console.log(`[gen-og] og-image.png → ${c.chapters} chapters · ${c.lessons} lessons · ${probs} problems`);
  } catch (e) {
    console.warn('[gen-og] skipped (kept existing og-image.png): ' + e.message);
    process.exit(0); // never break the build over the share image
  }
})();
