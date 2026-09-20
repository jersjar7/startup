// The deriver (ADR 0018, step 1): one account's state from its event log.
//
// The log (reviewEvents) is the record. Everything a surface shows is a
// function of it, computed here and nowhere else. This module is pure: hand
// it the account's events (and, until the log carries them, the diagnostic
// scores it cannot derive yet) and it returns the state. It never touches
// the database, so it is tested against literal logs and can rebuild any
// account from scratch, which is also how the migration and the nightly
// drift check run (scripts/deriveCompare.js).
//
// What it derives today: problem history (counts, desk attempts, maturity,
// the weak-spots review queue), both halves of chapter mastery, study days,
// and phone XP. What it cannot yet: web XP (a session's bonus needs the
// session boundary the log does not record), badges, diagnostic scores.
// Step 2 of the migration adds those event kinds; the deriver grows with
// them and the compare script says when the two agree.

const { composeMastery, computeStudyMastery, nextMaturity } = require('./mastery.js');
const { clearedGames, gamesHalf, gamesIn } = require('./gamesHalf.js');
const { XP, phoneXp } = require('./xp.js');

const GRADUATE_AFTER = 2;
const REVIEW_STEP_DAYS = [1, 4];
const DAY_RE = /^\d{4}-\d{2}-\d{2}$/;

const parentId = (itemId) => String(itemId || '').split(':')[0];

function addDays(day, n) {
  const d = new Date(`${day}T00:00:00Z`);
  d.setUTCDate(d.getUTCDate() + n);
  return d.toISOString().slice(0, 10);
}

/** Events in the order they happened: by the student's day, then by time. */
function ordered(events) {
  return [...events].sort((a, b) =>
    (a.localDate || '').localeCompare(b.localDate || '') || (a.ts || 0) - (b.ts || 0));
}

/**
 * One answer folded into a problem's row, the same rules db/stats.js
 * upsertProblemHistory applies, with the student's day as "today".
 */
function foldAnswer(row, { isCorrect, day, source }) {
  const r = row || { timesCorrect: 0, timesIncorrect: 0, deskAttempts: 0, reviewActive: false, correctSinceMiss: 0, nextReview: null, interval: 0, lastCorrectAt: null };
  const timesCorrect = r.timesCorrect + (isCorrect ? 1 : 0);
  const timesIncorrect = r.timesIncorrect + (isCorrect ? 0 : 1);
  let reviewActive = r.reviewActive;
  let correctSinceMiss = r.correctSinceMiss;
  let nextReview = reviewActive ? r.nextReview : null;
  if (!isCorrect) {
    reviewActive = true;
    correctSinceMiss = 0;
    nextReview = addDays(day, REVIEW_STEP_DAYS[0]);
  } else if (reviewActive) {
    correctSinceMiss += 1;
    if (correctSinceMiss >= GRADUATE_AFTER) {
      reviewActive = false;
      nextReview = null;
    } else {
      nextReview = addDays(day, REVIEW_STEP_DAYS[correctSinceMiss] || REVIEW_STEP_DAYS[REVIEW_STEP_DAYS.length - 1]);
    }
  }
  const { interval, lastCorrectAt } = nextMaturity(r, { isCorrect, today: day, source });
  return {
    timesCorrect, timesIncorrect,
    deskAttempts: r.deskAttempts + (source === 'desk' ? 1 : 0),
    reviewActive, correctSinceMiss,
    nextReview: reviewActive && nextReview ? nextReview : null,
    interval, lastCorrectAt, lastSeen: day,
  };
}

/**
 * The account's state from its log.
 * @param {object} input
 * @param {Array} input.events   reviewEvents rows for the account
 * @param {object} [input.diagnosticScores]  chapterId -> diagnosticScore (not in the log yet)
 */
function deriveAccount({ events = [], diagnosticScores = {} } = {}) {
  const history = {};   // problemId -> row (+ topicId)
  const studyDays = new Set();
  const byChapter = {}; // chapterId -> phone events
  const phoneByDay = {}; // localDate -> {gotIt, fuzzy, forgot}

  for (const e of ordered(events)) {
    if (!e || !DAY_RE.test(e.localDate || '')) continue;
    const source = e.source === 'web' ? 'desk' : 'phone';
    const isCorrect = e.grade !== 'forgot';
    const problemId = parentId(e.itemId);
    if (problemId) {
      const row = foldAnswer(history[problemId], { isCorrect, day: e.localDate, source });
      history[problemId] = { ...row, topicId: e.chapterId };
    }
    studyDays.add(e.localDate);
    if (source === 'phone') {
      (byChapter[e.chapterId] ||= []).push(e);
      const c = (phoneByDay[e.localDate] ||= { gotIt: 0, fuzzy: 0, forgot: 0 });
      if (c[e.grade] !== undefined) c[e.grade] += 1;
    }
  }

  const chapters = new Set([...Object.keys(byChapter), ...Object.values(history).map((h) => h.topicId), ...Object.keys(diagnosticScores)].filter(Boolean));
  const chapterMastery = {};
  for (const ch of chapters) {
    const rows = Object.values(history).filter((h) => h.topicId === ch);
    const cleared = clearedGames(ch, byChapter[ch] || []);
    chapterMastery[ch] = composeMastery({
      diagnosticScore: diagnosticScores[ch] || 0,
      studyScore: computeStudyMastery(rows),
      gamesHalf: gamesHalf(ch, cleared),
      gamesCleared: cleared.length,
      gamesTotal: Object.keys(gamesIn(ch)).length,
    });
  }

  let phoneXpTotal = 0;
  for (const c of Object.values(phoneByDay)) phoneXpTotal += Math.min(XP.phoneDailyCap, phoneXp(c));

  const days = [...studyDays].sort();
  return {
    history,
    chapterMastery,
    studyDays: days,
    daysStudied: days.length,
    lastSessionDate: days[days.length - 1] || null,
    phoneXp: phoneXpTotal,
    problemsAnswered: Object.keys(history).length,
  };
}

module.exports = { deriveAccount, foldAnswer, ordered, addDays };
