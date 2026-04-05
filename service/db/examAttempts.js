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

async function getExamAttempts(userId) {
  return examAttemptsCollection
    .find({ userId })
    .sort({ createdAt: -1 })
    .project({
      questions: 0, // Exclude full question data from list view
    })
    .toArray();
}

async function getExamAttemptCount(userId) {
  return examAttemptsCollection.countDocuments({ userId });
}

module.exports = {
  createExamAttempt,
  getExamAttempt,
  updateExamAttempt,
  getExamAttempts,
  getExamAttemptCount,
};
