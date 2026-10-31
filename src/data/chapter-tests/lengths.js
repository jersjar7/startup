// Kept apart from the questions on purpose: contentStats imports this to count
// the chapter tests, and the questions and their keys must never reach the
// website bundle (docs/CHAPTER-TESTS.md).

// Every chapter has two sets, A and B, that share no question.
export const TEST_VERSIONS = ['A', 'B'];

// Questions per test: the top of the chapter's NCEES range (src/data/chapters.js).
export const TEST_LENGTH = {
  'mathematics': 12,
  'statistics': 12,
  'ethics': 6,
  'economics': 8,
  'statics': 12,
  'dynamics': 6,
  'mechanics-materials': 11,
  'materials': 8,
  'fluid-mechanics': 9,
  'surveying': 9,
  'water-resources': 15,
  'structural': 15,
  'geotechnical': 15,
  'transportation': 14,
  'construction': 12,
};
