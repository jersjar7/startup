// Screenshots every reference screen at 2x (780 by 1688) with headless Chrome.
//   node render.mjs
import { execFileSync } from 'node:child_process';
import { readdirSync, mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const chrome = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const html = fileURLToPath(new URL('./reference-screens/html/', import.meta.url));
const png = fileURLToPath(new URL('./reference-screens/png/', import.meta.url));
mkdirSync(png, { recursive: true });

for (const file of readdirSync(html).filter((f) => f.endsWith('.html')).sort()) {
  const out = png + file.replace(/\.html$/, '.png');
  execFileSync(chrome, [
    '--headless=new', '--hide-scrollbars', '--disable-gpu',
    '--window-size=390,844', '--force-device-scale-factor=2',
    '--virtual-time-budget=6000',
    `--screenshot=${out}`, `file://${html}${file}`,
  ], { stdio: 'ignore' });
  console.log('rendered', file);
}
