import mathematics from './mathematics';
import statistics from './statistics';
import ethics from './ethics';
import economics from './economics';
import statics from './statics';
import dynamics from './dynamics';
import mechanicsMaterials from './mechanics-materials';
import materials from './materials';
import fluidMechanics from './fluid-mechanics';
import surveying from './surveying';
import waterResources from './water-resources';
import structural from './structural';
import geotechnical from './geotechnical';
import transportation from './transportation';
import construction from './construction';
import DIAGNOSTIC_IDS from './diagnostic-ids';

const CHAPTER_BANKS = {
  mathematics,
  statistics,
  ethics,
  economics,
  statics,
  dynamics,
  'mechanics-materials': mechanicsMaterials,
  materials,
  'fluid-mechanics': fluidMechanics,
  surveying,
  'water-resources': waterResources,
  structural,
  geotechnical,
  transportation,
  construction,
};

const CHAPTER_IDS = [
  'mathematics', 'statistics', 'ethics', 'economics', 'statics',
  'dynamics', 'mechanics-materials', 'materials', 'fluid-mechanics',
  'surveying', 'water-resources', 'structural', 'geotechnical',
  'transportation', 'construction',
];

// NCEES FE Civil exam weighted distribution (110 questions total)
const EXAM_DISTRIBUTION = {
  'mathematics':         9,
  'statistics':          4,
  'ethics':              4,
  'economics':           5,
  'statics':             8,
  'dynamics':            4,
  'mechanics-materials': 7,
  'materials':           5,
  'fluid-mechanics':     6,
  'surveying':           6,
  'water-resources':     10,
  'structural':          10,
  'geotechnical':        10,
  'transportation':      12,
  'construction':        10,
};

// Build a lookup map of diagnostic IDs for fast exclusion
const diagnosticIdSet = new Set(DIAGNOSTIC_IDS);

// Build the flat lookup of ALL exam-bank questions (keyed by id)
const ALL_PROBLEMS = {};
for (const chapterId of CHAPTER_IDS) {
  for (const p of CHAPTER_BANKS[chapterId]) {
    ALL_PROBLEMS[p.id] = p;
  }
}

/**
 * Number of questions a chapter contributes to the 110-question FE Civil exam,
 * per the NCEES specification. Used to weight readiness and focus-area scoring.
 */
export function getExamWeight(chapterId) {
  return EXAM_DISTRIBUTION[chapterId] || 0;
}

/**
 * Returns the fixed 30 diagnostic questions.
 * Always the same set — shuffled for presentation by the caller.
 */
export function getDiagnosticQuestions() {
  return DIAGNOSTIC_IDS.map(id => ALL_PROBLEMS[id]).filter(Boolean);
}

/**
 * Returns all exam-bank questions for a given chapter.
 */
export function getExamBankForChapter(chapterId) {
  return CHAPTER_BANKS[chapterId] || [];
}

/**
 * Selects 110 weighted questions from the non-diagnostic pool.
 * Uses Fisher-Yates shuffle for fair randomization.
 */
export function selectExamQuestions() {
  const selected = [];

  for (const chapterId of CHAPTER_IDS) {
    const target = EXAM_DISTRIBUTION[chapterId] || 5;
    // Exclude diagnostic questions from the simulation pool
    const pool = (CHAPTER_BANKS[chapterId] || [])
      .filter(p => !diagnosticIdSet.has(p.id));

    if (pool.length === 0) continue;

    const shuffled = fisherYatesShuffle([...pool]);
    selected.push(...shuffled.slice(0, target));
  }

  return fisherYatesShuffle(selected);
}

function fisherYatesShuffle(arr) {
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}
