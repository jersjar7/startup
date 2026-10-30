const { ObjectId } = require('mongodb');
const { chapterTestAttemptsCollection } = require('./connection');

// Chapter test attempts (see ../chapterTests.js). One document per try; the
// question ids are stored so a later change to the bank cannot change what a
// past attempt asked.

async function insertChapterTestAttempt(attempt) {
  const doc = { ...attempt, answers: {}, startedAt: new Date(), submittedAt: null };
  const { insertedId } = await chapterTestAttemptsCollection.insertOne(doc);
  return { ...doc, _id: insertedId };
}

function byId(id) {
  try { return new ObjectId(String(id)); } catch { return null; }
}

async function getChapterTestAttempt(id, email) {
  const _id = byId(id);
  if (!_id) return null;
  return chapterTestAttemptsCollection.findOne({ _id, email });
}

async function getOpenChapterTestAttempt(email, chapterId, version) {
  return chapterTestAttemptsCollection.findOne({ email, chapterId, version, submittedAt: null });
}

async function saveChapterTestAnswers(id, email, answers) {
  await chapterTestAttemptsCollection.updateOne({ _id: byId(id), email, submittedAt: null }, { $set: { answers } });
}

async function submitChapterTestAttempt(id, email, answers, result) {
  const r = await chapterTestAttemptsCollection.updateOne(
    { _id: byId(id), email, submittedAt: null },
    { $set: { answers, result, submittedAt: new Date() } },
  );
  return r.modifiedCount === 1;
}

// An abandoned try too short to count (CT.genuinelySat): closed with no
// result, so it never shows as a score and never counts as a try.
async function retireChapterTestAttempt(id, email) {
  await chapterTestAttemptsCollection.updateOne(
    { _id: byId(id), email, submittedAt: null },
    { $set: { submittedAt: new Date(), retired: true } },
  );
}

async function listChapterTestAttempts(email, chapterId) {
  return chapterTestAttemptsCollection
    .find({ email, chapterId }, { projection: { answers: 0, questionIds: 0 } })
    .sort({ startedAt: -1 })
    .limit(50)
    .toArray();
}

module.exports = {
  insertChapterTestAttempt, getChapterTestAttempt, getOpenChapterTestAttempt,
  saveChapterTestAnswers, submitChapterTestAttempt, retireChapterTestAttempt, listChapterTestAttempts,
};
