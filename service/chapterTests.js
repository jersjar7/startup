// Chapter tests: a timed test of one chapter, answers shown only at the end.
// Two question sets per chapter (A and B), both free. Students never pick one:
// nextVersion() gives them the set they have seen least, so a second try is
// all new questions. See docs/CHAPTER-TESTS.md.
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

// An abandoned try counts only if it was genuinely sat: the exam simulation's
// rule (ADR 0001, MIN_GRADED_FRACTION in routes/exam.js). Below it the try is
// retired quietly, so opening a test to look at it never records a score.
const MIN_GRADED_FRACTION = 0.1;
function genuinelySat(questions, answers) {
  const ids = new Set(questions.map((q) => q.id));
  const answered = Object.entries(sanitizeAnswers(answers)).filter(([k, v]) => ids.has(k) && v).length;
  return answered >= Math.ceil(questions.length * MIN_GRADED_FRACTION);
}

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

// Choice order. Each try shows the choices in its own order, like practice and
// the exam simulation, so a repeat try cannot be answered from memory of a
// letter and the bank's lean toward B and C (written 2026-10-30: 69/95/95/69
// over A-D) does not reach the student. The order is derived from the try and
// the question, not stored: a refresh, going back to a question, and the
// review all show the same order. Choice ids never change, so grading does
// not depend on it.
function seededRandom(seed) {
  let h = 2166136261; // FNV-1a, then mulberry32
  for (let i = 0; i < seed.length; i++) { h ^= seed.charCodeAt(i); h = Math.imul(h, 16777619); }
  let a = h >>> 0;
  return () => {
    a = (a + 0x6D2B79F5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// Positions 0..n-1 in this try's order for this question.
function choiceOrder(q, attemptId) {
  const order = q.choices.map((_, i) => i);
  if (!attemptId) return order;
  const random = seededRandom(`${attemptId}:${q.id}`);
  for (let i = order.length - 1; i > 0; i--) {
    const j = Math.floor(random() * (i + 1));
    [order[i], order[j]] = [order[j], order[i]];
  }
  return order;
}

// What the browser may see while the test runs: no key, no notes, no solution.
function publicQuestion(q, attemptId) {
  return {
    id: q.id,
    topic: q.topic,
    statement: q.statement,
    choices: choiceOrder(q, attemptId).map((i) => ({ id: q.choices[i].id, text: q.choices[i].text })),
    diagram: q.diagram || null,
  };
}

// Everything, for the review after submit, in the order the student saw.
function reviewQuestion(q, chosen, attemptId) {
  const notes = q.choiceNotes || [];
  return {
    ...publicQuestion(q, attemptId),
    chosen: chosen || null,
    correctAnswerId: q.correctAnswerId,
    correct: chosen === q.correctAnswerId,
    choiceNotes: choiceOrder(q, attemptId).map((i) => notes[i] || ''),
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

// Which set a student gets next: the open one if a try is under way, else the
// set taken fewer times, else the one taken longest ago. A comes first.
// `versions` is [{ version, tries, lastStartedAt, open }].
function nextVersion(versions) {
  const open = versions.find((v) => v.open);
  if (open) return open.version;
  const sorted = [...versions].sort((x, y) =>
    x.tries - y.tries
    || (new Date(x.lastStartedAt || 0) - new Date(y.lastStartedAt || 0))
    || x.version.localeCompare(y.version));
  return sorted[0].version;
}

module.exports = {
  nextVersion, genuinelySat, MIN_GRADED_FRACTION, choiceOrder,
  loadBank, setBank, testQuestions, timeLimitSeconds, publicQuestion, reviewQuestion,
  grade, autosave, submission, SECONDS_PER_QUESTION,
};
