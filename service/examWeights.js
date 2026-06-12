// NCEES FE Civil exam weighting — the single backend source of truth for how
// much each chapter counts toward the 110-question exam. Mirrors the frontend
// copy in src/data/exam-bank/index.js (kept in sync by hand; identical values).
// Used to weight chapter mastery into one honest, coverage-anchored number.

const EXAM_DISTRIBUTION = {
  mathematics: 13, // incl. Computational Tools
  statistics: 4,
  ethics: 4,
  economics: 4,
  statics: 8,
  dynamics: 4,
  'mechanics-materials': 8,
  materials: 4,
  'fluid-mechanics': 4,
  surveying: 4,
  'water-resources': 14, // Hydraulics & Hydrologic + Environmental
  structural: 13, // Structural Analysis + Structural Design
  geotechnical: 11,
  transportation: 10,
  construction: 5,
};
// Sum = 110 — matches the NCEES FE Civil total.

const TOTAL_WEIGHT = Object.values(EXAM_DISTRIBUTION).reduce((a, b) => a + b, 0);

// "Touched enough to count as covered" — above a bare diagnostic blip. Crude on
// purpose (study-load plan §Q1); refine with telemetry later.
const COVERAGE_THRESHOLD = 20;

function getExamWeight(chapterId) {
  return EXAM_DISTRIBUTION[chapterId] || 0;
}

// One NCEES-weighted mastery number (0–100) across ALL chapters. Untouched
// chapters count as 0, so the number is coverage-anchored by construction: a
// half-covered user is honestly dragged down. chapterMastery is the userStats
// map { chapterId: { totalMastery } }.
function weightedMastery(chapterMastery = {}) {
  let weighted = 0;
  for (const chapterId of Object.keys(EXAM_DISTRIBUTION)) {
    const m = (chapterMastery[chapterId] && chapterMastery[chapterId].totalMastery) || 0;
    weighted += m * EXAM_DISTRIBUTION[chapterId];
  }
  return Math.round(weighted / (TOTAL_WEIGHT || 1));
}

// Weighted % of the exam the user has actually covered (chapters past the
// threshold). Breadth, not depth — bounds how much mastery a projection may
// honestly claim.
function coveragePercent(chapterMastery = {}, threshold = COVERAGE_THRESHOLD) {
  let covered = 0;
  for (const chapterId of Object.keys(EXAM_DISTRIBUTION)) {
    const m = (chapterMastery[chapterId] && chapterMastery[chapterId].totalMastery) || 0;
    if (m >= threshold) covered += EXAM_DISTRIBUTION[chapterId];
  }
  return Math.round((100 * covered) / (TOTAL_WEIGHT || 1));
}

module.exports = {
  EXAM_DISTRIBUTION,
  TOTAL_WEIGHT,
  COVERAGE_THRESHOLD,
  getExamWeight,
  weightedMastery,
  coveragePercent,
};
