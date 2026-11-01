// XP: the single source of truth for how much every event type is worth,
// across web and phone. Keep ALL values here so they stay intentional and
// consistent; never re-invent an XP number inline in a route.
//
// Principle (study-load panel): desk problem-solving is the gold standard.
// Phone retrieval is genuine learning but lighter, and capped per local day so
// couch card-grinding can't outscore desk work on the leaderboard. Wrong
// answers still earn a little (effort credit keeps people practicing honestly).

const XP = {
  // A problem answered at the desk (web practice + spaced review).
  problemCorrect: 10,
  problemIncorrect: 5,
  // Completion bonuses, by session type.
  sessionBonus: 25, // finishing a chapter practice session
  reviewBonus: 15, // finishing a spaced-review session
  // Quickstart / diagnostic (assessment, not graded study).
  diagnosticAttempted: 10,
  diagnosticCorrect: 5,
  // The full timed exam simulation (the big sit-down).
  examAttempt: 100,
  examCorrect: 2,
  // Phone events, derived from the sync log (lighter than the desk).
  phone: { gotIt: 5, fuzzy: 3, forgot: 2 },
  phoneDailyCap: 60, // max phone XP creditable per local day
};

// Helpers so routes never re-derive the math.
const sessionXp = (correct, incorrect) =>
  correct * XP.problemCorrect + incorrect * XP.problemIncorrect + XP.sessionBonus;

const reviewXp = (correct, incorrect) =>
  correct * XP.problemCorrect + incorrect * XP.problemIncorrect + XP.reviewBonus;

const diagnosticXp = (attempted, correct) =>
  attempted * XP.diagnosticAttempted + correct * XP.diagnosticCorrect;

const examXp = (correct) => XP.examAttempt + correct * XP.examCorrect;

// One desk answer's XP (ADR 0038). A problem earns XP only the first time it
// is answered on a day; a repeat that day is still recorded and still counts
// for review, it just earns nothing. An answer the server could not grade (an
// old build that sends only right or wrong) earns the attempt XP, never the
// correct XP, so a forged "right" is worth no more than a try. A problem the
// server does not hold earns nothing.
const deskAnswerXp = ({ isCorrect, graded, known, repeat }) => {
  if (!known || repeat) return 0;
  return graded && isCorrect ? XP.problemCorrect : XP.problemIncorrect;
};

// Phone XP for a day's grade tallies, BEFORE the daily cap is applied.
const phoneXp = (counts = {}) =>
  (counts.gotIt || 0) * XP.phone.gotIt +
  (counts.fuzzy || 0) * XP.phone.fuzzy +
  (counts.forgot || 0) * XP.phone.forgot;

module.exports = { XP, sessionXp, reviewXp, diagnosticXp, examXp, phoneXp, deskAnswerXp };
