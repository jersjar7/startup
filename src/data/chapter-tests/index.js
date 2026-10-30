// The chapter test bank: two versions (A and B) per chapter that share no
// question with each other or with any other bank, so a retake is new
// questions at the same level. See docs/CHAPTER-TESTS.md.
import mathematicsA from './mathematics-a';
import mathematicsB from './mathematics-b';
import statisticsA from './statistics-a';
import statisticsB from './statistics-b';
import ethicsA from './ethics-a';
import ethicsB from './ethics-b';
import economicsA from './economics-a';
import economicsB from './economics-b';
import staticsA from './statics-a';
import staticsB from './statics-b';
import dynamicsA from './dynamics-a';
import dynamicsB from './dynamics-b';
import mechanicsMaterialsA from './mechanics-materials-a';
import mechanicsMaterialsB from './mechanics-materials-b';
import materialsA from './materials-a';
import materialsB from './materials-b';
import fluidMechanicsA from './fluid-mechanics-a';
import fluidMechanicsB from './fluid-mechanics-b';
import surveyingA from './surveying-a';
import surveyingB from './surveying-b';
import waterResourcesA from './water-resources-a';
import waterResourcesB from './water-resources-b';
import structuralA from './structural-a';
import structuralB from './structural-b';
import geotechnicalA from './geotechnical-a';
import geotechnicalB from './geotechnical-b';
import transportationA from './transportation-a';
import transportationB from './transportation-b';
import constructionA from './construction-a';
import constructionB from './construction-b';

export const CHAPTER_TESTS = {
  'mathematics': { A: mathematicsA, B: mathematicsB },
  'statistics': { A: statisticsA, B: statisticsB },
  'ethics': { A: ethicsA, B: ethicsB },
  'economics': { A: economicsA, B: economicsB },
  'statics': { A: staticsA, B: staticsB },
  'dynamics': { A: dynamicsA, B: dynamicsB },
  'mechanics-materials': { A: mechanicsMaterialsA, B: mechanicsMaterialsB },
  'materials': { A: materialsA, B: materialsB },
  'fluid-mechanics': { A: fluidMechanicsA, B: fluidMechanicsB },
  'surveying': { A: surveyingA, B: surveyingB },
  'water-resources': { A: waterResourcesA, B: waterResourcesB },
  'structural': { A: structuralA, B: structuralB },
  'geotechnical': { A: geotechnicalA, B: geotechnicalB },
  'transportation': { A: transportationA, B: transportationB },
  'construction': { A: constructionA, B: constructionB },
};

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
