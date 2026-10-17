const { dailyPuzzlesCollection, dailyResultsCollection } = require('./connection');
const { NOT_EXCLUDED, isExcluded } = require('../internalAccounts.js');

// The Daily's storage (see ../daily.js for what it is).

/** Every stored pick, oldest first. One a day, so this stays small. */
async function listDailyPuzzles() {
  return dailyPuzzlesCollection.find({}, { projection: { _id: 0 } }).sort({ number: 1 }).toArray();
}

async function getDailyPuzzle(number) {
  return dailyPuzzlesCollection.findOne({ number }, { projection: { _id: 0 } });
}

/**
 * Stores a pick unless one is already there, and returns whichever is stored.
 * Two phones asking at the same moment both get the first one written.
 */
async function insertDailyPuzzle(puzzle) {
  try {
    await dailyPuzzlesCollection.insertOne({ ...puzzle, createdAt: new Date() });
  } catch (err) {
    if (err.code !== 11000) throw err;
  }
  return getDailyPuzzle(puzzle.number);
}

/**
 * One try a day: the first result for an account and a Daily is kept and
 * any later one is ignored. Returns the stored row.
 */
async function insertDailyResult(row) {
  try {
    await dailyResultsCollection.insertOne({ ...row, createdAt: new Date() });
  } catch (err) {
    if (err.code !== 11000) throw err;
  }
  return dailyResultsCollection.findOne({ number: row.number, email: row.email }, { projection: { _id: 0 } });
}

async function getDailyResult(number, email) {
  return dailyResultsCollection.findOne({ number, email }, { projection: { _id: 0 } });
}

/**
 * Which results a viewer's board may hold: every student, plus themselves;
 * and for one of our own accounts, everyone, so the team sees the team.
 */
function dailyResultsQuery(number, email) {
  return isExcluded(email)
    ? { number }
    : { number, $or: [{ email: NOT_EXCLUDED }, { email }] };
}

/**
 * A day's results for the board. Our own accounts never count, except that
 * you always see yourself.
 */
async function listDailyResults(number, email) {
  // Our own accounts are hidden from students' boards, but see each other,
  // so the team can test a board with more than one name on it (owner,
  // 2026-10-16). A student never sees an internal row.
  return dailyResultsCollection.find(
    dailyResultsQuery(number, email),
    { projection: { _id: 0, rounds: 0 } },
  ).toArray();
}

/** Which Daily numbers an account has played. */
async function listDailyNumbers(email) {
  const rows = await dailyResultsCollection.find({ email }, { projection: { _id: 0, number: 1 } }).toArray();
  return rows.map((r) => r.number);
}

module.exports = {
  listDailyPuzzles,
  getDailyPuzzle,
  insertDailyPuzzle,
  insertDailyResult,
  getDailyResult,
  listDailyResults,
  dailyResultsQuery,
  listDailyNumbers,
};
