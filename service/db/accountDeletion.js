const {
  userCollection,
  userStatsCollection,
  problemHistoryCollection,
  sessionLogCollection,
  diagnosticResultsCollection,
} = require('./connection');

async function deleteAllUserData(email) {
  await Promise.all([
    userCollection.deleteOne({ email }),
    userStatsCollection.deleteOne({ email }),
    problemHistoryCollection.deleteMany({ email }),
    sessionLogCollection.deleteMany({ email }),
    diagnosticResultsCollection.deleteMany({ email }),
  ]);
}

module.exports = { deleteAllUserData };
