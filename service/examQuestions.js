// The question set a paid exam attempt is drawn from and graded against, taken
// from the server's own copy of the exam bank.
//
// The server picks the 110 questions. Before this the browser picked them and
// posted them, correctAnswerId included, and /exam/start stored and scored
// whatever arrived: anyone could post their own answer key, a one-question
// exam, or only the easy questions (see docs/EXAM-SIMULATION.md, open issue 1).
//
// The pick follows the exam's chapter weights, never draws a diagnostic
// question, and puts questions this student has not seen on an earlier attempt
// first. With random picks, two exams shared about 29 of their 110 questions;
// with 443 eligible questions a student's first two exams share none, and a
// third repeats about five (Statics and Construction run out first).

const { DIAGNOSTIC_IDS } = require('./diagnosticIds.js');

const DIAGNOSTIC = new Set(DIAGNOSTIC_IDS);

// The ids a fresh attempt asks, by chapter weight. `seen` lists every question
// id from the student's earlier attempts (an id counts once per attempt it
// was on); fewer sightings come first, and ties are broken at random.
function pickExamQuestionIds(content, distribution, { seen = [], random = Math.random } = {}) {
  const times = new Map();
  for (const id of seen) times.set(id, (times.get(id) || 0) + 1);

  const pools = {};
  for (const [id, ix] of Object.entries(content.problemIndex)) {
    if (ix.pool !== 'exam' || DIAGNOSTIC.has(id) || !content.problemsById[id]) continue;
    (pools[ix.chapterId] ||= []).push(id);
  }

  const picked = [];
  for (const [chapterId, want] of Object.entries(distribution)) {
    const pool = shuffle(pools[chapterId] || [], random);
    // A stable sort keeps the shuffled order within each count.
    pool.sort((a, b) => (times.get(a) || 0) - (times.get(b) || 0));
    if (pool.length < want) {
      throw new Error(`Exam bank has ${pool.length} questions for ${chapterId}, needs ${want}`);
    }
    picked.push(...pool.slice(0, want));
  }
  return shuffle(picked, random);
}

// The stored copy of each question, answer key included. Only the server
// ever holds this; the browser gets it without correctAnswerId.
function buildExamQuestions(ids, content) {
  return ids.map((id) => {
    const index = content.problemIndex[id];
    const stored = content.problemsById[id];
    return {
      id,
      chapterId: index.chapterId,
      lessonId: index.lessonId,
      statement: stored.statement,
      choices: (stored.choices || []).map((c) => ({ ...c })),
      correctAnswerId: stored.correctAnswerId,
      type: stored.type,
      diagram: diagramFor(stored.diagram),
    };
  });
}

// What the browser is sent: the question without its answer.
function publicQuestion(q) {
  return {
    id: q.id,
    chapterId: q.chapterId,
    lessonId: q.lessonId,
    statement: q.statement,
    choices: (q.choices || []).map((c) => ({ id: c.id, text: c.text })),
    type: q.type,
    diagram: q.diagram || null,
  };
}

// The server's copy carries a figureId for the pre-rendered picture; the
// browser's never did. Stored without it, the attempt holds exactly the
// diagram the exam page draws.
function diagramFor(diagram) {
  if (!diagram) return null;
  const { figureId, ...rest } = diagram; // eslint-disable-line no-unused-vars
  return rest;
}

function shuffle(list, random) {
  const a = [...list];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

module.exports = { pickExamQuestionIds, buildExamQuestions, publicQuestion };
