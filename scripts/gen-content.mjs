// Serialize the app's bundled study content into JSON the mobile app reads over
// the API (the website keeps this content in React modules; the phone can't run
// those). Uses the same esbuild-evaluate trick as content-counts.mjs so we read
// the SAME data the website ships. Regenerate whenever content changes.
//
//   node scripts/gen-content.mjs   ->   service/content.json
import { build } from 'esbuild';
import { createRequire } from 'module';
import { mkdtempSync, writeFileSync } from 'fs';
import { tmpdir } from 'os';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const require = createRequire(import.meta.url);
const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const p = (rel) => JSON.stringify(join(root, rel));

const entry = `
  import { CHAPTERS } from ${p('src/data/chapters.js')};
  import { CHAPTER_DETAILS } from ${p('src/data/chapters/index.js')};
  import { LESSONS } from ${p('src/data/lessons/index.js')};
  import { getExamBankForChapter } from ${p('src/data/exam-bank/index.js')};
  import { getChapterPracticeProblems } from ${p('src/data/chapter-practice/index.js')};

  // 1) Chapter -> subtopic -> lesson STRUCTURE (names only; powers the nav).
  const chapters = CHAPTERS.map((c) => {
    const det = CHAPTER_DETAILS[c.id] || {};
    const bySub = {};
    for (const g of (LESSONS[c.id] || [])) bySub[g.subtopicId] = g.lessons || [];
    const subtopics = (det.subtopics || []).map((st) => ({
      id: st.id,
      name: st.name,
      application: st.application || '',
      lessons: (bySub[st.id] || []).map((l) => ({ id: l.id, name: l.name, application: l.application || '' })),
    }));
    return { id: c.id, num: c.num, name: c.name, qs: c.qs, accent: c.accent, context: det.context || '', subtopics };
  });

  // 2) Full lessons, keyed "chapterId/lessonId" (teaching blocks + problems).
  const lessons = {};
  for (const [chId, groups] of Object.entries(LESSONS)) {
    for (const g of groups) {
      for (const l of (g.lessons || [])) {
        lessons[chId + '/' + l.id] = {
          id: l.id,
          name: l.name,
          chapterId: chId,
          subtopicId: l.subtopicId,
          application: l.application || '',
          content: l.content || [],
          illustration: l.illustration || null,
          problems: l.problems || [],
        };
      }
    }
  }

  // 3) Every problem by id (lesson + exam bank + chapter practice) so the
  //    spaced-review queue can resolve its stored ids to real problems.
  const problemsById = {};
  const addP = (x) => { if (x && x.id && !problemsById[x.id]) problemsById[x.id] = x; };
  for (const chId of Object.keys(LESSONS)) {
    for (const g of (LESSONS[chId] || [])) for (const l of (g.lessons || [])) for (const x of (l.problems || [])) addP(x);
    for (const x of getExamBankForChapter(chId)) addP(x);
    for (const x of getChapterPracticeProblems(chId)) addP(x);
  }

  export const content = { chapters, lessons, problemsById };
`;

const out = join(mkdtempSync(join(tmpdir(), 'gc-')), 'c.cjs');
await build({
  stdin: { contents: entry, resolveDir: root, loader: 'js' },
  bundle: true,
  format: 'cjs',
  platform: 'node',
  outfile: out,
  logLevel: 'silent',
});
delete require.cache[out];
const { content } = require(out);

const dest = join(root, 'service/content.json');
writeFileSync(dest, JSON.stringify(content));

const probs = Object.keys(content.problemsById).length;
const lessons = Object.keys(content.lessons).length;
console.log(`[gen-content] ${content.chapters.length} chapters · ${lessons} lessons · ${probs} problems -> service/content.json`);
