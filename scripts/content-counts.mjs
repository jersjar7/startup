// Node-side helper: evaluate the real content modules (the same code the app
// runs) to get live counts at build time. Used by gen-stats and gen-og.
import { build } from 'esbuild';
import { createRequire } from 'module';
import { mkdtempSync } from 'fs';
import { tmpdir } from 'os';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const require = createRequire(import.meta.url);
const root = join(dirname(fileURLToPath(import.meta.url)), '..');

export async function liveCounts() {
  const entry = `
    import { getProblemPoolSize } from ${JSON.stringify(join(root, 'src/data/problemPool.js'))};
    import { LESSONS } from ${JSON.stringify(join(root, 'src/data/lessons/index.js'))};
    import { CHAPTERS } from ${JSON.stringify(join(root, 'src/data/chapters.js'))};
    let lessons = 0;
    for (const ch of Object.values(LESSONS)) for (const st of ch) lessons += (st.lessons || []).length;
    export const counts = { problems: getProblemPoolSize(), lessons, chapters: CHAPTERS.length };
  `;
  const out = join(mkdtempSync(join(tmpdir(), 'cc-')), 'c.cjs');
  await build({ stdin: { contents: entry, resolveDir: root, loader: 'js' }, bundle: true, format: 'cjs', platform: 'node', outfile: out, logLevel: 'silent' });
  delete require.cache[out];
  const c = require(out).counts;
  return { ...c, problemsLabel: c.problems.toLocaleString('en-US') };
}
