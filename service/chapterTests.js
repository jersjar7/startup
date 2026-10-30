// Chapter tests: a timed test of one chapter, answers shown only at the end.
// Two versions per chapter (A and B), both free. See docs/CHAPTER-TESTS.md.
//
// The bank lives in service/chapter-tests.json, written by
// scripts/gen-content.mjs from src/data/chapter-tests. It is never part of
// content.json (which the app downloads) and never bundled into the website,
// so the browser sees a question's answer only after the test is handed in.
//
// Answers are merged with the exam simulation's rules (service/examProgress.js):
// autosave may clear an answer, submit can only add one.

const { mergeAutosave, mergeSubmission, sanitizeAnswers } = require('./examProgress.js');

let bank = null;
function loadBank() {
  if (!bank) bank = require('./chapter-tests.json');
  return bank;
}
// Tests pass their own bank.
function setBank(b) { bank = b; }

const SECONDS_PER_QUESTION = 3 * 60; // the real exam's pace: 110 questions in 5h20m is about 2.9 min

// The questions a version asks, in bank order. The first `length` questions
// are the test; the rest are spares a reviewer can swap in. Fixed, so a whole
// class assigned version A gets the same test.
function testQuestions(chapterId, version, b = loadBank()) {
  const ch = b.tests[chapterId];
  const length = b.length[chapterId];
  if (!ch || !length || !['A', 'B'].includes(version)) return null;
  return (ch[version] || []).slice(0, length);
}

function timeLimitSeconds(count) {
  return count * SECONDS_PER_QUESTION;
}

// What the browser may see while the test runs: no key, no notes, no solution.
function publicQuestion(q) {
  return {
    id: q.id,
    topic: q.topic,
    statement: q.statement,
    choices: q.choices.map((c) => ({ id: c.id, text: c.text })),
    diagram: q.diagram || null,
  };
}

// Everything, for the review after submit.
function reviewQuestion(q, chosen) {
  return {
    ...publicQuestion(q),
    chosen: chosen || null,
    correctAnswerId: q.correctAnswerId,
    correct: chosen === q.correctAnswerId,
    choiceNotes: q.choiceNotes || [],
    eli5: q.eli5 || '',
    steps: q.steps || [],
    traps: q.traps || [],
    handbookPage: q.handbookPage || null,
    handbookFormula: q.handbookFormula || null,
    difficulty: q.difficulty,
  };
}

// Score and the per-topic split. Unanswered counts as wrong, as on the FE.
function grade(questions, answers) {
  const a = sanitizeAnswers(answers);
  const byTopic = {};
  let correct = 0;
  for (const q of questions) {
    const ok = a[q.id] === q.correctAnswerId;
    if (ok) correct++;
    const t = (byTopic[q.topic] ||= { topic: q.topic, correct: 0, total: 0 });
    t.total++;
    if (ok) t.correct++;
  }
  const total = questions.length;
  return { correct, total, percent: total ? Math.round((correct / total) * 100) : 0, topics: Object.values(byTopic) };
}

// Only answers to this attempt's own questions are kept.
function onlyFor(questions, answers) {
  const ids = new Set(questions.map((q) => q.id));
  const out = {};
  for (const [k, v] of Object.entries(sanitizeAnswers(answers))) if (ids.has(k)) out[k] = v;
  return out;
}

function autosave(questions, stored, incoming) {
  return mergeAutosave(stored, onlyFor(questions, incoming));
}

function submission(questions, stored, incoming) {
  return mergeSubmission(stored, onlyFor(questions, incoming));
}

module.exports = {
  loadBank, setBank, testQuestions, timeLimitSeconds, publicQuestion, reviewQuestion,
  grade, autosave, submission, SECONDS_PER_QUESTION,
};
