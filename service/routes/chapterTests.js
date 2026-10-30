const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const CT = require('../chapterTests.js');

// Chapter tests. Free, both versions, any number of tries. See
// ../chapterTests.js for the rules and docs/CHAPTER-TESTS.md for the bank.

const router = express.Router();
const GRACE_MS = 2 * 60 * 1000; // a slow network on the last second still counts

function questionsOf(attempt) {
  const all = CT.testQuestions(attempt.chapterId, attempt.version) || [];
  const byId = new Map(all.map((q) => [q.id, q]));
  return attempt.questionIds.map((id) => byId.get(id)).filter(Boolean);
}

function deadlineOf(attempt) {
  return new Date(attempt.startedAt).getTime() + attempt.limitSeconds * 1000;
}

function summary(a) {
  return {
    id: String(a._id),
    version: a.version,
    startedAt: a.startedAt,
    submittedAt: a.submittedAt,
    correct: a.result ? a.result.correct : null,
    total: a.result ? a.result.total : null,
    percent: a.result ? a.result.percent : null,
  };
}

async function finish(attempt, email, incoming) {
  const questions = questionsOf(attempt);
  const answers = CT.submission(questions, attempt.answers, incoming);
  const result = CT.grade(questions, answers);
  const late = Date.now() > deadlineOf(attempt) + GRACE_MS;
  await DB.submitChapterTestAttempt(attempt._id, email, answers, { ...result, late });
}

// What a chapter offers and this student's past tries.
router.get('/:chapterId', verifyAuth, async (req, res) => {
  const { chapterId } = req.params;
  const a = CT.testQuestions(chapterId, 'A');
  if (!a) return res.status(404).send({ msg: 'No chapter test for that chapter.' });
  const attempts = await DB.listChapterTestAttempts(req.user.email, chapterId);
  const versions = ['A', 'B'].map((version) => {
    const mine = attempts.filter((t) => t.version === version);
    const done = mine.filter((t) => t.submittedAt && t.result);
    const open = mine.find((t) => !t.submittedAt && Date.now() < deadlineOf(t) + GRACE_MS);
    const best = done.reduce((m, t) => (m && m.result.percent >= t.result.percent ? m : t), null);
    return {
      version,
      tries: done.length,
      best: best ? summary(best) : null,
      last: done[0] ? summary(done[0]) : null,
      openId: open ? String(open._id) : null,
    };
  });
  res.send({ chapterId, length: a.length, limitSeconds: CT.timeLimitSeconds(a.length), versions });
});

// Start (or carry on with) a try. A try left open past its time is graded on
// what was saved, then a new one starts.
router.post('/:chapterId/:version/start', verifyAuth, async (req, res) => {
  const { chapterId, version } = req.params;
  const questions = CT.testQuestions(chapterId, version);
  if (!questions) return res.status(404).send({ msg: 'No such chapter test.' });
  const email = req.user.email;
  let attempt = await DB.getOpenChapterTestAttempt(email, chapterId, version);
  if (attempt && Date.now() > deadlineOf(attempt) + GRACE_MS) {
    await finish(attempt, email, {});
    attempt = null;
  }
  if (!attempt) {
    attempt = await DB.insertChapterTestAttempt({
      email, chapterId, version,
      questionIds: questions.map((q) => q.id),
      limitSeconds: CT.timeLimitSeconds(questions.length),
    });
  }
  res.send({
    attemptId: String(attempt._id),
    chapterId, version,
    deadline: deadlineOf(attempt),
    limitSeconds: attempt.limitSeconds,
    answers: attempt.answers || {},
    questions: questionsOf(attempt).map(CT.publicQuestion),
  });
});

// Autosave while the test runs. A cleared answer is a real choice here.
router.put('/attempts/:id/answers', verifyAuth, async (req, res) => {
  const attempt = await DB.getChapterTestAttempt(req.params.id, req.user.email);
  if (!attempt) return res.status(404).send({ msg: 'Test not found.' });
  if (attempt.submittedAt) return res.status(409).send({ msg: 'This test was already handed in.' });
  const answers = CT.autosave(questionsOf(attempt), attempt.answers, req.body && req.body.answers);
  await DB.saveChapterTestAnswers(attempt._id, req.user.email, answers);
  res.send({ saved: Object.keys(answers).length });
});

// Hand in. Submit can only add answers (see examProgress.mergeSubmission).
router.post('/attempts/:id/submit', verifyAuth, async (req, res) => {
  const attempt = await DB.getChapterTestAttempt(req.params.id, req.user.email);
  if (!attempt) return res.status(404).send({ msg: 'Test not found.' });
  if (!attempt.submittedAt) await finish(attempt, req.user.email, req.body && req.body.answers);
  res.send({ attemptId: String(attempt._id) });
});

// The result and full review, only once handed in.
router.get('/attempts/:id', verifyAuth, async (req, res) => {
  const attempt = await DB.getChapterTestAttempt(req.params.id, req.user.email);
  if (!attempt) return res.status(404).send({ msg: 'Test not found.' });
  if (!attempt.submittedAt) return res.status(409).send({ msg: 'This test is still in progress.' });
  const answers = attempt.answers || {};
  res.send({
    ...summary(attempt),
    chapterId: attempt.chapterId,
    topics: attempt.result.topics,
    late: !!attempt.result.late,
    seconds: Math.round((new Date(attempt.submittedAt) - new Date(attempt.startedAt)) / 1000),
    questions: questionsOf(attempt).map((q) => CT.reviewQuestion(q, answers[q.id])),
  });
});

module.exports = router;
