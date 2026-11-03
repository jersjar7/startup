// Screenshots every tablet screen at 2x with headless Chrome, at the size
// each page declares (1180 by 820 landscape, 820 by 1180 portrait).
//   node render-tablet.mjs            # all of them
//   node render-tablet.mjs T04        # only names starting with T04
import { execFileSync } from 'node:child_process';
import { readdirSync, readFileSync, mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const chrome = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const html = fileURLToPath(new URL('./tablet-screens/html/', import.meta.url));
const png = fileURLToPath(new URL('./tablet-screens/png/', import.meta.url));
mkdirSync(png, { recursive: true });
const only = process.argv[2] ?? '';

for (const file of readdirSync(html).filter((f) => f.endsWith('.html') && f.startsWith(only)).sort()) {
  const src = readFileSync(html + file, 'utf8');
  const w = Number(src.match(/width:(\d+)px;height:(\d+)px;box-sizing/)[1]);
  const h = Number(src.match(/width:(\d+)px;height:(\d+)px;box-sizing/)[2]);
  execFileSync(chrome, [
    '--headless=new', '--hide-scrollbars', '--disable-gpu', '--allow-file-access-from-files',
    `--window-size=${w},${h}`, '--force-device-scale-factor=2',
    '--virtual-time-budget=4000',
    `--screenshot=${png}${file.replace(/\.html$/, '.png')}`, `file://${html}${file}`,
  ], { stdio: 'ignore' });
  console.log('rendered', file, `${w}x${h}`);
}
