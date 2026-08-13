// Serialize the app's bundled study content into JSON the mobile app reads over
// the API (the website keeps this content in React modules; the phone can't run
// those). Uses the same esbuild-evaluate trick as content-counts.mjs so we read
// the SAME data the website ships. Regenerate whenever content changes.
//
//   node scripts/gen-content.mjs   ->   service/content.json
import { build } from 'esbuild';
import { createHash } from 'crypto';
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

  // 4) problemId -> WHERE IT LIVES. Nothing on a problem object records its own
  //    chapter or lesson, so the progress markers cannot resolve a stored
  //    problemId back to the lesson it belongs to without this. Built here, at
  //    generation time, from the same traversal that collects the problems, so
  //    it can never drift from the content it describes.
  //
  //    pool: 'lesson'   -> one of a lesson's 3 exercises
  //          'practice' -> the chapter-practice pool (own row, own fraction)
  //          'exam'     -> exam bank; diagnostic + simulation only, never a marker
  const problemIndex = {};
  const idx = (x, chapterId, lessonId, pool) => {
    if (x && x.id && !problemIndex[x.id]) {
      problemIndex[x.id] = { chapterId, lessonId: lessonId || null, pool };
    }
  };
  for (const chId of Object.keys(LESSONS)) {
    for (const g of (LESSONS[chId] || [])) {
      for (const l of (g.lessons || [])) {
        for (const x of (l.problems || [])) idx(x, chId, l.id, 'lesson');
      }
    }
    for (const x of getExamBankForChapter(chId)) idx(x, chId, x.lessonId || null, 'exam');
    for (const x of getChapterPracticeProblems(chId)) idx(x, chId, x.lessonId || null, 'practice');
  }

  export const content = { chapters, lessons, problemsById, problemIndex };
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

// Give every problem figure a stable id (hash of component + props) and collect
// the unique figures, so gen-figures.mjs can render each to SVG and the app can
// fetch it by figureId. problemsById and lessons share the same problem objects,
// so this one mutation reaches both.
function stableStr(v) {
  if (v && typeof v === 'object' && !Array.isArray(v)) {
    return '{' + Object.keys(v).sort().map((k) => JSON.stringify(k) + ':' + stableStr(v[k])).join(',') + '}';
  }
  if (Array.isArray(v)) return '[' + v.map(stableStr).join(',') + ']';
  return JSON.stringify(v);
}
const figures = {};
for (const p of Object.values(content.problemsById)) {
  const d = p.diagram;
  if (d && d.component) {
    const id = createHash('sha1').update(d.component + ':' + stableStr(d.props || {})).digest('hex').slice(0, 16);
    d.figureId = id;
    if (!figures[id]) figures[id] = { component: d.component, props: d.props || {} };
  }
}
content.figures = figures;

// Fail the BUILD, not the page, if the problem index ever stops describing the
// content. A silently incomplete index would render every affected lesson as
// "untouched" — plausible-looking and completely wrong, with nothing to notice
// it. See docs/progress-markers.md.
{
  const idxd = content.problemIndex;
  const problems = new Set(Object.keys(content.problemsById));
  const orphans = Object.keys(idxd).filter((id) => !problems.has(id));
  if (orphans.length) {
    throw new Error(`[gen-content] problemIndex has ${orphans.length} id(s) not in problemsById: ${orphans.slice(0, 5)}`);
  }
  const missing = [];
  const wrongSize = [];
  for (const [key, lesson] of Object.entries(content.lessons)) {
    const ps = lesson.problems || [];
    if (ps.length !== 3) wrongSize.push(`${key} has ${ps.length}`);
    for (const x of ps) {
      const e = idxd[x.id];
      if (!e || e.pool !== 'lesson' || e.lessonId !== lesson.id || e.chapterId !== lesson.chapterId) {
        missing.push(x.id);
      }
    }
  }
  if (missing.length) {
    throw new Error(`[gen-content] ${missing.length} lesson exercise(s) missing or mis-mapped in problemIndex: ${missing.slice(0, 5)}`);
  }
  // The five-state marker is calibrated to exactly 3 exercises per lesson. If
  // that ever stops being true the design needs revisiting, so say so loudly.
  if (wrongSize.length) {
    throw new Error(`[gen-content] every lesson must have exactly 3 exercises; offenders: ${wrongSize.slice(0, 5)}`);
  }
}

const dest = join(root, 'service/content.json');
writeFileSync(dest, JSON.stringify(content));

const probs = Object.keys(content.problemsById).length;
const lessons = Object.keys(content.lessons).length;
const figs = Object.keys(content.figures).length;
const pools = Object.values(content.problemIndex).reduce((a, e) => { a[e.pool] = (a[e.pool] || 0) + 1; return a; }, {});
console.log(`[gen-content] ${content.chapters.length} chapters · ${lessons} lessons · ${probs} problems · ${figs} figures -> service/content.json`);
console.log(`[gen-content] problemIndex: ${Object.keys(content.problemIndex).length} (lesson ${pools.lesson || 0} · practice ${pools.practice || 0} · exam ${pools.exam || 0})`);
