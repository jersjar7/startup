// Renders the exam simulation product pictures from public/exam-sim-product.html
// in the three shapes Google accepts for a product (1:1, 4:3, 16:9). They are
// the Product image on /exam-simulation. Run by hand after changing the template:
//   node scripts/gen-sim-image.mjs
import { chromium } from 'playwright';
import { join, dirname } from 'path';
import { fileURLToPath, pathToFileURL } from 'url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const src = pathToFileURL(join(root, 'scripts/sim-image/template.html')).href;
const SHAPES = [
  { shape: 'square', name: 'exam-sim-1x1.png', width: 1200, height: 1200 },
  { shape: 'four', name: 'exam-sim-4x3.png', width: 1200, height: 900 },
  { shape: 'wide', name: 'exam-sim-16x9.png', width: 1600, height: 900 },
];

const browser = await chromium.launch();
try {
  for (const s of SHAPES) {
    const page = await browser.newPage({ viewport: { width: s.width, height: s.height } });
    await page.goto(`${src}?shape=${s.shape}`, { waitUntil: 'networkidle' });
    await page.evaluate(() => document.fonts.ready);
    await page.screenshot({ path: join(root, 'public', s.name) });
    await page.close();
    console.log(`wrote public/${s.name}`);
  }
} finally {
  await browser.close();
}
