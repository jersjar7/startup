const { diagnosticResultsCollection, userStatsCollection } = require('./connection');

async function saveDiagnosticResult(email, result) {
  await diagnosticResultsCollection.insertOne({ email, ...result });
}

async function getDiagnosticHistory(email) {
  return diagnosticResultsCollection
    .find({ email })
    .sort({ attemptNumber: -1 })
    .toArray();
}

async function getLatestDiagnostic(email) {
  return diagnosticResultsCollection
    .findOne({ email }, { sort: { attemptNumber: -1 } });
}

async function getDiagnosticAttemptCount(email) {
  return diagnosticResultsCollection.countDocuments({ email });
}

async function getDiagnosticById(email, attemptNumber) {
  return diagnosticResultsCollection.findOne({ email, attemptNumber });
}

async function updateChapterMastery(email, chapterMastery, diagnosticCompleted, diagnosticAttempts) {
  await userStatsCollection.updateOne(
    { email },
    {
      $set: {
        chapterMastery,
        diagnosticCompleted,
        diagnosticAttempts,
      },
    },
    { upsert: true }
  );
}

async function getChapterMastery(email) {
  const stats = await userStatsCollection.findOne({ email });
  return {
    chapterMastery: stats?.chapterMastery || {},
    diagnosticCompleted: stats?.diagnosticCompleted || false,
    diagnosticAttempts: stats?.diagnosticAttempts || 0,
  };
}

module.exports = {
  saveDiagnosticResult,
  getDiagnosticHistory,
  getLatestDiagnostic,
  getDiagnosticAttemptCount,
  getDiagnosticById,
  updateChapterMastery,
  getChapterMastery,
};
