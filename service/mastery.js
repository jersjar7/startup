// Mastery level calculation and decay logic.
//
// Levels:
//   0 — Not Started   (no sessions)
//   1 — Introduced    (completed first session)
//   2 — Practicing    (50%+ accuracy)
//   3 — Familiar      (75%+ accuracy, 3+ sessions)
//   4 — Proficient    (reserved for Phase 3 quiz mode)
//   5 — Mastered      (reserved for Phase 3 spaced review)
//
// Decay: 14+ days idle = -1 level, 30+ days = -2 levels.
// Applied lazily on read, not persisted.

const MASTERY_NAMES = ['Not Started', 'Introduced', 'Practicing', 'Familiar', 'Proficient', 'Mastered'];

const DECAY_DAYS_1 = 14;
const DECAY_DAYS_2 = 30;

// Calculate earned mastery (0–3) from cumulative topic progress.
function calculateEarnedMastery({ sessionsCompleted = 0, attempted = 0, correct = 0 }) {
  if (sessionsCompleted === 0) return 0;

  const accuracy = attempted > 0 ? correct / attempted : 0;

  if (sessionsCompleted >= 3 && accuracy >= 0.75) return 3;
  if (accuracy >= 0.5) return 2;
  return 1;
}

// Apply time-based decay. Returns effective mastery level.
function applyDecay(earnedMastery, lastStudied) {
  if (!lastStudied || earnedMastery === 0) return earnedMastery;

  const daysSince = Math.floor((new Date() - new Date(lastStudied)) / 86400000);

  if (daysSince >= DECAY_DAYS_2) return Math.max(0, earnedMastery - 2);
  if (daysSince >= DECAY_DAYS_1) return Math.max(0, earnedMastery - 1);
  return earnedMastery;
}

// True if topic mastery is currently reduced by decay.
function isDecaying(earnedMastery, lastStudied) {
  return applyDecay(earnedMastery, lastStudied) < earnedMastery;
}

function masteryName(level) {
  return MASTERY_NAMES[level] || 'Not Started';
}

// ── Study-driven mastery (0–100) ────────────────────────────────────────────
// Methodology-first: rewards retrieval + spaced repetition + coverage, with
// diminishing returns. Each problem contributes evidence weighted by its
// spaced-repetition maturity (interval) and accuracy; chapter mastery saturates
// as evidence accrues. See docs/mastery-progress-model.md.
const STUDY_TAU = 25; // "Balanced": ~25 retained problems ≈ 63%, ~55 ≈ ~90%.

// Per-problem retention weight in [0, 1] from its problemHistory row.
function problemRetention({ timesCorrect = 0, timesIncorrect = 0, interval = 0 } = {}) {
  if (timesCorrect <= 0) return 0;
  const accuracy = timesCorrect / (timesCorrect + timesIncorrect);
  // Maturity: how well the problem has stuck across spaced reviews.
  const maturity = interval >= 21 ? 1.0 : interval >= 7 ? 0.7 : 0.4;
  return maturity * accuracy;
}

// Study mastery (0–100) for one chapter, from its problemHistory rows.
function computeStudyMastery(history = []) {
  let evidence = 0;
  for (const h of history) evidence += problemRetention(h);
  return Math.round(100 * (1 - Math.exp(-evidence / STUDY_TAU)));
}

module.exports = {
  calculateEarnedMastery, applyDecay, isDecaying, masteryName,
  computeStudyMastery, problemRetention, STUDY_TAU,
};
