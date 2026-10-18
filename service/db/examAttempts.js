const { examAttemptsCollection } = require('./connection');
const { ObjectId } = require('mongodb');

async function createExamAttempt(userId, attempt) {
  const result = await examAttemptsCollection.insertOne({
    userId,
    ...attempt,
    createdAt: new Date(),
  });
  return result.insertedId;
}

async function getExamAttempt(attemptId, userId) {
  return examAttemptsCollection.findOne({
    _id: new ObjectId(attemptId),
    userId,
  });
}

async function updateExamAttempt(attemptId, userId, update) {
  await examAttemptsCollection.updateOne(
    { _id: new ObjectId(attemptId), userId },
    { $set: update }
  );
}

// Completes an attempt only if nothing completed it first. Two submits in
// flight together both read the attempt as in progress; with a plain update
// both went on to award XP, a session and badges. Returns true for the one
// that won.
async function claimExamCompletion(attemptId, userId, update) {
  const res = await examAttemptsCollection.updateOne(
    { _id: new ObjectId(attemptId), userId, status: { $ne: 'completed' } },
    { $set: update }
  );
  return res.modifiedCount === 1;
}

async function getExamAttempts(userId) {
  return examAttemptsCollection
    .find({ userId })
    .sort({ createdAt: -1 })
    .project({
      questions: 0, // Exclude full question data from list view
    })
    .toArray();
}

// Every question id from the student's earlier attempts, once per attempt,
// so a new exam can lead with questions they have not seen.
async function getExamQuestionIdsSeen(userId) {
  const attempts = await examAttemptsCollection
    .find({ userId })
    .project({ 'questions.id': 1 })
    .toArray();
  return attempts.flatMap((a) => (a.questions || []).map((q) => q.id));
}

async function getExamAttemptCount(userId) {
  return examAttemptsCollection.countDocuments({ userId });
}

module.exports = {
  createExamAttempt,
  getExamAttempt,
  updateExamAttempt,
  claimExamCompletion,
  getExamAttempts,
  getExamAttemptCount,
  getExamQuestionIdsSeen,
};
