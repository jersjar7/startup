import { describe, it, expect } from 'vitest';
const {
  LESSON_EXERCISE_COUNT, isEverCorrect, lessonState, lessonProgress, buildChapterProgress,
} = require('./progressState.js');
const content = require('./content.json');

const row = (problemId, timesCorrect = 0, timesIncorrect = 0) => ({ problemId, timesCorrect, timesIncorrect });

describe('isEverCorrect', () => {
  // "Ever got it right", not first try: problemHistory never records
  // first-attempt correctness, so this is what the data supports.
  it('counts a problem eventually answered correctly', () => {
    expect(isEverCorrect(row('a', 1, 4))).toBe(true);
  });
  it('does not count one only ever missed', () => {
    expect(isEverCorrect(row('a', 0, 3))).toBe(false);
  });
  it('handles a missing row', () => {
    expect(isEverCorrect(undefined)).toBe(false);
    expect(isEverCorrect(null)).toBe(false);
  });
});

describe('lessonState — the five states', () => {
  it('untouched when nothing was answered', () => {
    expect(lessonState(0, 0)).toBe('untouched');
  });

  // The state that must NOT collapse into "untouched": someone who tried and
  // got nothing right is exactly who should come back to this lesson.
  it('attempted when answered but none right yet', () => {
    expect(lessonState(0, 1)).toBe('attempted');
    expect(lessonState(0, 3)).toBe('attempted');
  });

  it('one-correct, two-correct, complete', () => {
    expect(lessonState(1, 3)).toBe('one-correct');
    expect(lessonState(2, 3)).toBe('two-correct');
    expect(lessonState(3, 3)).toBe('complete');
  });

  it('never reports beyond complete', () => {
    expect(lessonState(4, 3)).toBe('complete');
  });
});

describe('lessonProgress', () => {
  const ids = ['q1', 'q2', 'q3'];

  it('is untouched with no history at all', () => {
    expect(lessonProgress(ids, {})).toEqual({ correct: 0, answered: 0, total: 3, state: 'untouched' });
  });

  it('counts only problems belonging to the lesson', () => {
    // A row for some other lesson's problem must not leak in.
    const hist = { q1: row('q1', 1), 'other-q9': row('other-q9', 1) };
    expect(lessonProgress(ids, hist)).toMatchObject({ correct: 1, answered: 1, state: 'one-correct' });
  });

  it('separates attempted-none-right from untouched', () => {
    const hist = { q1: row('q1', 0, 2), q2: row('q2', 0, 1) };
    expect(lessonProgress(ids, hist)).toMatchObject({ correct: 0, answered: 2, state: 'attempted' });
  });

  it('reaches complete only when all three were ever right', () => {
    const hist = { q1: row('q1', 1), q2: row('q2', 2, 5), q3: row('q3', 1, 1) };
    expect(lessonProgress(ids, hist)).toMatchObject({ correct: 3, state: 'complete' });
  });
});

describe('buildChapterProgress', () => {
  const chapter = {
    id: 'ch', subtopics: [
      { id: 'sub1', lessons: [{ id: 'l1' }, { id: 'l2' }] },
      { id: 'sub2', lessons: [{ id: 'l3' }] },
    ],
  };
  const lessonsByKey = {
    'ch/l1': { id: 'l1', chapterId: 'ch', problems: [{ id: 'a1' }, { id: 'a2' }, { id: 'a3' }] },
    'ch/l2': { id: 'l2', chapterId: 'ch', problems: [{ id: 'b1' }, { id: 'b2' }, { id: 'b3' }] },
    'ch/l3': { id: 'l3', chapterId: 'ch', problems: [{ id: 'c1' }, { id: 'c2' }, { id: 'c3' }] },
  };
  const problemIndex = {
    a1: { chapterId: 'ch', lessonId: 'l1', pool: 'lesson' },
    p1: { chapterId: 'ch', lessonId: 'l1', pool: 'practice' },
    p2: { chapterId: 'ch', lessonId: 'l2', pool: 'practice' },
    x1: { chapterId: 'ch', lessonId: 'l1', pool: 'exam' },
    p9: { chapterId: 'other', lessonId: null, pool: 'practice' },
  };

  it('reports every lesson, including untouched ones', () => {
    const out = buildChapterProgress({ chapter, lessonsByKey, problemIndex, historyRows: [] });
    expect(Object.keys(out.lessons).sort()).toEqual(['l1', 'l2', 'l3']);
    expect(out.lessons.l1.state).toBe('untouched');
  });

  it('rolls subtopics up by COMPLETE lessons only', () => {
    const historyRows = [
      row('a1', 1), row('a2', 1), row('a3', 1),   // l1 complete
      row('b1', 1), row('b2', 1),                  // l2 two-correct
    ];
    const out = buildChapterProgress({ chapter, lessonsByKey, problemIndex, historyRows });
    expect(out.lessons.l1.state).toBe('complete');
    expect(out.lessons.l2.state).toBe('two-correct');
    expect(out.subtopics.sub1).toEqual({ complete: 1, total: 2, exercisesCorrect: 5, exercisesTotal: 6 });
    expect(out.subtopics.sub2).toEqual({ complete: 0, total: 1, exercisesCorrect: 0, exercisesTotal: 3 });
  });

  // The reason the row counts exercises instead of lessons: partial work in a
  // subtopic must never render as zero while the dots inside show progress.
  it('reports partial work that a whole-lesson count would hide', () => {
    const historyRows = [row('a1', 1), row('b1', 1), row('b2', 1)];
    const out = buildChapterProgress({ chapter, lessonsByKey, problemIndex, historyRows });
    expect(out.subtopics.sub1.complete).toBe(0);                 // no lesson finished
    expect(out.subtopics.sub1.exercisesCorrect).toBe(3);         // but three exercises are
    expect(out.subtopics.sub1.exercisesTotal).toBe(6);
  });

  it('counts practice separately, ignoring exam-bank and other chapters', () => {
    const historyRows = [row('p1', 1), row('x1', 1), row('p9', 1)];
    const out = buildChapterProgress({ chapter, lessonsByKey, problemIndex, historyRows });
    // p1 only: x1 is exam-bank, p9 belongs to another chapter.
    expect(out.practice).toEqual({ correct: 1, total: 2 });
  });

  it('keeps practice out of the lesson markers entirely', () => {
    // Practice problems reference a lessonId but must never move a lesson dot,
    // or "2 of 3" would stop meaning 2 of that lesson's 3 exercises.
    const out = buildChapterProgress({ chapter, lessonsByKey, problemIndex, historyRows: [row('p1', 1)] });
    expect(out.lessons.l1.state).toBe('untouched');
  });
});

// The guard that matters most. A silently incomplete index would render whole
// lessons as "untouched" — plausible-looking and wrong, with nothing to notice
// it. gen-content.mjs also fails the build on this; this checks the artifact
// that actually ships.
describe('the shipped problemIndex describes the real content', () => {
  const { problemIndex, lessons, problemsById } = content;

  it('indexes every problem exactly once', () => {
    expect(Object.keys(problemIndex).length).toBe(Object.keys(problemsById).length);
  });

  it('has the expected pool split', () => {
    const pools = {};
    for (const e of Object.values(problemIndex)) pools[e.pool] = (pools[e.pool] || 0) + 1;
    expect(pools).toEqual({ lesson: 405, practice: 248, exam: 473 });
  });

  it('resolves all 405 lesson exercises to their own lesson', () => {
    let seen = 0;
    for (const [key, lesson] of Object.entries(lessons)) {
      for (const p of lesson.problems || []) {
        const e = problemIndex[p.id];
        expect(e, `${p.id} (${key}) missing from problemIndex`).toBeTruthy();
        expect(e.pool).toBe('lesson');
        expect(e.lessonId).toBe(lesson.id);
        expect(e.chapterId).toBe(lesson.chapterId);
        seen += 1;
      }
    }
    expect(seen).toBe(405);
  });

  it('still has exactly 3 exercises in every lesson', () => {
    // The five-state marker is calibrated to 3. If this ever fails, the design
    // needs revisiting, not the test.
    const offenders = Object.entries(lessons)
      .filter(([, l]) => (l.problems || []).length !== LESSON_EXERCISE_COUNT)
      .map(([k, l]) => `${k}:${(l.problems || []).length}`);
    expect(offenders).toEqual([]);
    expect(Object.keys(lessons).length).toBe(135);
  });

  it('never lets one problem belong to two pools', () => {
    // Lesson / practice / exam share no ids, which is what lets practice have
    // its own row without double-counting.
    const byPool = { lesson: new Set(), practice: new Set(), exam: new Set() };
    for (const [id, e] of Object.entries(problemIndex)) byPool[e.pool].add(id);
    const l = byPool.lesson, p = byPool.practice, x = byPool.exam;
    expect([...l].filter((i) => p.has(i))).toEqual([]);
    expect([...l].filter((i) => x.has(i))).toEqual([]);
    expect([...p].filter((i) => x.has(i))).toEqual([]);
  });
});
