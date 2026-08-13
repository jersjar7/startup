// Progress markers: turning answer history into the five states shown on the
// chapter page. See docs/progress-markers.md for the decisions behind this.
//
// Deliberately PURE and database-free: everything here is a function of the
// content plus a list of history rows, so the whole rule set can be tested with
// fixtures and no Mongo.

// Every one of the 135 lessons has exactly 3 exercises, and the generator fails
// the build if that stops being true. The five-state marker is calibrated to it.
const LESSON_EXERCISE_COUNT = 3;

// "Got it right" means EVER got it right, not first try. problemHistory records
// timesCorrect / timesIncorrect, never first-attempt correctness, so "ever" is
// what the data actually supports. Consequence, accepted deliberately: markers
// only ever improve and a completed lesson stays completed forever. Completion
// is not readiness — mastery is the thing that tells that truth.
function isEverCorrect(row) {
  return !!row && (row.timesCorrect || 0) > 0;
}

// untouched    nothing answered            -> no marker
// attempted    answered, none right YET    -> hollow ember
// one-correct                              -> ember
// two-correct                              -> sunbeam
// complete     all of them                 -> forest
//
// `attempted` exists on purpose: someone who tried a lesson and got nothing
// right is exactly who should return to it, and collapsing that into "untouched"
// would hide the most useful row on the page.
function lessonState(correct, answered, total = LESSON_EXERCISE_COUNT) {
  if (!answered) return 'untouched';
  if (correct <= 0) return 'attempted';
  if (correct >= total) return 'complete';
  return correct === 1 ? 'one-correct' : 'two-correct';
}

function lessonProgress(problemIds, historyById, total = LESSON_EXERCISE_COUNT) {
  let correct = 0;
  let answered = 0;
  for (const id of problemIds) {
    const row = historyById[id];
    if (!row) continue;
    answered += 1;
    if (isEverCorrect(row)) correct += 1;
  }
  return { correct, answered, total, state: lessonState(correct, answered, total) };
}

/**
 * Everything the chapter page needs, from one chapter's history.
 *
 * @param chapter      content.chapters entry (subtopics -> lesson refs)
 * @param lessonsByKey content.lessons ("chapterId/lessonId" -> lesson)
 * @param problemIndex content.problemIndex (problemId -> {chapterId,lessonId,pool})
 * @param historyRows  problemHistory rows for this user AND this chapter
 */
function buildChapterProgress({ chapter, lessonsByKey, problemIndex, historyRows = [] }) {
  const historyById = {};
  for (const r of historyRows) if (r && r.problemId) historyById[r.problemId] = r;

  const lessons = {};
  const subtopics = {};

  for (const st of chapter.subtopics || []) {
    let complete = 0;
    const refs = st.lessons || [];
    for (const ref of refs) {
      const lesson = lessonsByKey[`${chapter.id}/${ref.id}`];
      const ids = (lesson?.problems || []).map((p) => p.id);
      const prog = lessonProgress(ids, historyById);
      lessons[ref.id] = prog;
      if (prog.state === 'complete') complete += 1;
    }
    // The subtopic fraction counts COMPLETE lessons only. Known and accepted:
    // a subtopic whose lessons all sit at 2 of 3 reads "0 of N", under-reporting
    // real work. Chosen for simplicity; switch to counting exercises if it grates.
    subtopics[st.id] = { complete, total: refs.length };
  }

  // Chapter practice is a SEPARATE pool sharing no ids with lessons, so it gets
  // a plain fraction and no marker: the five-state scale is calibrated to 3
  // items and practice sets run 11-29.
  let practiceTotal = 0;
  let practiceCorrect = 0;
  for (const [id, entry] of Object.entries(problemIndex)) {
    if (entry.pool !== 'practice' || entry.chapterId !== chapter.id) continue;
    practiceTotal += 1;
    if (isEverCorrect(historyById[id])) practiceCorrect += 1;
  }

  return {
    chapterId: chapter.id,
    lessons,
    subtopics,
    practice: { correct: practiceCorrect, total: practiceTotal },
  };
}

module.exports = {
  LESSON_EXERCISE_COUNT,
  isEverCorrect,
  lessonState,
  lessonProgress,
  buildChapterProgress,
};
