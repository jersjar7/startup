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
// What it derives: problem history (counts, desk attempts, maturity, the
// weak-spots review queue), both halves of chapter mastery, study days, XP
// from both surfaces, the session counts badges need, and the exam date.
// The log's kinds (step 2 of the migration): answer (the default), snapshot
// (an opening balance from before the log), session, diagnostic, quickstart,
// exam, profile, feedback, lesson-opened, concept-read.

const { composeMastery, computeStudyMastery, nextMaturity, calculateEarnedMastery } = require('./mastery.js');
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
 * @param {object} [input.diagnosticScores]  chapterId -> diagnosticScore, for logs written before the diagnostic and quick-start kinds existed
 */
function deriveAccount({ events = [], diagnosticScores = {} } = {}) {
  const history = {};   // problemId -> row (+ topicId)
  const studyDays = new Set();
  const byChapter = {}; // chapterId -> phone events
  const phoneByDay = {}; // localDate -> {gotIt, fuzzy, forgot}

  const diag = { ...diagnosticScores }; // chapterId -> the highest diagnostic or quick-start read
  let webXp = 0;
  const sessions = { practice: 0, review: 0, diagnostic: 0, quickstart: 0, exam: 0 };
  let examDate = null;
  const games = {};        // gameId -> { rounds: Set of 1-based rounds cleared, firstTry }
  const missedRounds = new Set();
  const xpByDay = {};      // localDate -> XP earned that day (web; phone added after its cap)
  const topicProgress = {}; // the old per-chapter ladder the website still keeps
  const topic = (id) => (topicProgress[id] ||= { attempted: 0, correct: 0, sessionsCompleted: 0, masteryLevel: 0, lastStudied: null });
  const earn = (day, xp) => { xpByDay[day] = (xpByDay[day] || 0) + (xp || 0); };

  for (const e of ordered(events)) {
    if (!e || !DAY_RE.test(e.localDate || '')) continue;
    const kind = e.kind || 'answer';
    const source = e.source === 'web' ? 'desk' : 'phone';
    const d = e.data || {};
    switch (kind) {
      case 'answer': {
        const isCorrect = e.grade !== 'forgot';
        const problemId = parentId(e.itemId);
        if (problemId) {
          const row = foldAnswer(history[problemId], { isCorrect, day: e.localDate, source });
          history[problemId] = { ...row, topicId: e.chapterId };
        }
        if (source === 'phone') {
          (byChapter[e.chapterId] ||= []).push(e);
          const c = (phoneByDay[e.localDate] ||= { gotIt: 0, fuzzy: 0, forgot: 0 });
          if (c[e.grade] !== undefined) c[e.grade] += 1;
          // The phone's own view: which rounds of which game are cleared,
          // and how many were cleared on the first try (no miss before).
          const parts = String(e.itemId || '').split(':');
          const round = parts.length === 3 ? Number(parts[2]) : NaN;
          if (Number.isInteger(round) && round >= 1) {
            const key = `${parts[1]}:${round}`;
            if (e.grade === 'forgot') missedRounds.add(key);
            else {
              const g = (games[parts[1]] ||= { rounds: new Set(), firstTry: 0 });
              if (!g.rounds.has(round)) { g.rounds.add(round); if (!missedRounds.has(key)) g.firstTry += 1; }
            }
          }
        }
        break;
      }
      case 'snapshot': {
        // An opening balance: a problem's row as it stood before the log
        // existed. Taken as the starting row, never folded twice.
        const problemId = parentId(e.itemId);
        if (problemId && !history[problemId]) {
          history[problemId] = {
            timesCorrect: d.timesCorrect || 0, timesIncorrect: d.timesIncorrect || 0,
            deskAttempts: d.deskAttempts ?? ((d.timesCorrect || 0) + (d.timesIncorrect || 0)),
            reviewActive: !!d.reviewActive, correctSinceMiss: d.correctSinceMiss || 0,
            nextReview: d.reviewActive ? d.nextReview || null : null,
            interval: d.interval || 0, lastCorrectAt: d.lastCorrectAt || null,
            lastSeen: e.localDate, topicId: e.chapterId,
          };
        }
        break;
      }
      case 'session': {
        webXp += d.xp || 0; earn(e.localDate, d.xp);
        if (d.type === 'review') {
          sessions.review += 1;
          for (const tid of d.topicIds || []) { const t = topic(tid); t.sessionsCompleted += 1; t.lastStudied = e.localDate; }
        } else {
          sessions.practice += 1;
          const tid = d.topicId || e.chapterId;
          if (tid) { const t = topic(tid); t.attempted += d.total || 0; t.correct += d.correct || 0; t.sessionsCompleted += 1; t.lastStudied = e.localDate; }
        }
        break;
      }
      case 'diagnostic':
        webXp += d.xp || 0; earn(e.localDate, d.xp);
        sessions.diagnostic += 1;
        for (const [ch, v] of Object.entries(d.chapterScores || {})) diag[ch] = Math.max(diag[ch] || 0, v || 0);
        break;
      case 'quickstart':
        webXp += d.xp || 0; earn(e.localDate, d.xp);
        sessions.quickstart += 1;
        if (e.chapterId) diag[e.chapterId] = Math.max(diag[e.chapterId] || 0, d.familiarity || 0);
        break;
      case 'exam':
        webXp += d.xp || 0; earn(e.localDate, d.xp);
        sessions.exam += 1;
        break;
      case 'profile':
        if ('examDate' in d) examDate = d.examDate;
        break;
      default:
        break; // lesson-opened, concept-read, feedback: they count as a day, nothing else yet
    }
    studyDays.add(e.localDate);
  }

  const chapters = new Set([...Object.keys(byChapter), ...Object.values(history).map((h) => h.topicId), ...Object.keys(diag)].filter(Boolean));
  const chapterMastery = {};
  for (const ch of chapters) {
    const rows = Object.values(history).filter((h) => h.topicId === ch);
    const cleared = clearedGames(ch, byChapter[ch] || []);
    chapterMastery[ch] = composeMastery({
      diagnosticScore: diag[ch] || 0,
      studyScore: computeStudyMastery(rows),
      gamesHalf: gamesHalf(ch, cleared),
      gamesCleared: cleared.length,
      gamesTotal: Object.keys(gamesIn(ch)).length,
    });
  }

  let phoneXpTotal = 0;
  for (const [day, c] of Object.entries(phoneByDay)) {
    const capped = Math.min(XP.phoneDailyCap, phoneXp(c));
    phoneXpTotal += capped;
    earn(day, capped);
  }
  for (const t of Object.values(topicProgress)) t.masteryLevel = calculateEarnedMastery(t);

  const days = [...studyDays].sort();
  return {
    history,
    chapterMastery,
    studyDays: days,
    daysStudied: days.length,
    lastSessionDate: days[days.length - 1] || null,
    phoneXp: phoneXpTotal,
    webXp,
    totalXp: phoneXpTotal + webXp,
    sessions,
    examDate,
    xpByDay,
    topicProgress,
    games: Object.fromEntries(Object.entries(games).map(([id, g]) => [id, { rounds: [...g.rounds].sort((a, b) => a - b), firstTry: g.firstTry }])),
    problemsAnswered: Object.keys(history).length,
  };
}

module.exports = { deriveAccount, foldAnswer, ordered, addDays };
