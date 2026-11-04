// Screenshots every road screen at 2x with headless Chrome, at its own size.
//
//   node render-road.mjs            # all of them
//   node render-road.mjs R02        # only names starting with R02
import { execFileSync } from 'node:child_process';
import { readdirSync, readFileSync, mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const chrome = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const html = fileURLToPath(new URL('./html/', import.meta.url));
const png = fileURLToPath(new URL('./png/', import.meta.url));
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
