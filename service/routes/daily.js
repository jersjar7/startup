const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { leaderName } = require('./leaderboard.js');
const { groupingKey } = require('../school.js');
const { shortSchoolName } = require('../schoolDirectory.js');
const {
  dayNumber, dateOfNumber, isOpenDate, usedThisCycle, pickGames,
  validateResult, summarize, streakOf,
} = require('../daily.js');

const router = express.Router();

/**
 * The stored pick for a Daily, making it (and any day before it that nobody
 * asked for) the first time it is asked for. Days are made in order, because
 * each one depends on what the cycle has already used.
 */
async function puzzleFor(number) {
  const stored = await DB.getDailyPuzzle(number);
  if (stored) return stored;
  const puzzles = await DB.listDailyPuzzles();
  const last = puzzles.length ? puzzles[puzzles.length - 1].number : number - 1;
  let made = null;
  for (let n = Math.min(last + 1, number); n <= number; n++) {
    if (puzzles.some((p) => p.number === n)) continue;
    const { games, newCycle } = pickGames({ number: n, used: usedThisCycle(puzzles) });
    made = await DB.insertDailyPuzzle({ number: n, date: dateOfNumber(n), games, newCycle });
    puzzles.push(made);
  }
  return made;
}

function mineOf(row) {
  return row ? { score: row.score, total: row.total, ms: row.ms, rounds: row.rounds } : null;
}

function schoolOf(user) {
  const key = groupingKey(user.school);
  if (!key) return { schoolKey: null, schoolName: null };
  return { schoolKey: key, schoolName: shortSchoolName(user.school.name) || user.school.name };
}

async function resultsFor(number, user) {
  const rows = await DB.listDailyResults(number, user.email);
  return summarize(rows, { email: user.email, ...schoolOf(user) });
}

// Today's Daily, by the phone's own calendar date.
router.get('/', verifyAuth, async (req, res) => {
  const date = req.query.date;
  if (!isOpenDate(date)) return res.status(400).send({ msg: 'That Daily is not open.' });
  const number = dayNumber(date);
  const [puzzle, mine, played] = await Promise.all([
    puzzleFor(number),
    DB.getDailyResult(number, req.user.email),
    DB.listDailyNumbers(req.user.email),
  ]);
  res.send({
    number,
    date,
    games: puzzle.games,
    total: puzzle.games.reduce((s, g) => s + g.rounds, 0),
    mine: mineOf(mine),
    streak: streakOf(played, number),
  });
});

// A finished Daily. Kept once; a second send returns the first.
router.post('/:number/result', verifyAuth, async (req, res) => {
  const number = Number(req.params.number);
  const date = req.body && req.body.date;
  if (!isOpenDate(date) || dayNumber(date) !== number) {
    return res.status(400).send({ msg: 'That Daily is closed.' });
  }
  const puzzle = await DB.getDailyPuzzle(number);
  if (!puzzle) return res.status(404).send({ msg: 'No such Daily.' });
  const checked = validateResult(req.body, puzzle);
  if (!checked.ok) return res.status(400).send({ msg: checked.msg });

  const row = await DB.insertDailyResult({
    number,
    date,
    email: req.user.email,
    name: leaderName(req.user),
    ...schoolOf(req.user),
    ...checked.value,
  });
  const [played, results] = await Promise.all([
    DB.listDailyNumbers(req.user.email),
    resultsFor(number, req.user),
  ]);
  res.send({ mine: mineOf(row), streak: streakOf(played, number), results });
});

// How everyone did.
router.get('/:number/results', verifyAuth, async (req, res) => {
  const number = Number(req.params.number);
  if (!Number.isInteger(number) || number < 1) return res.status(400).send({ msg: 'No such Daily.' });
  res.send(await resultsFor(number, req.user));
});

module.exports = router;
