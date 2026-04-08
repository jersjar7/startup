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

const CHAPTER_PRACTICE = {
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

/**
 * Returns the chapter practice problems for a given chapter.
 * These are separate from lesson practice (3/lesson) and exam-bank questions.
 */
export function getChapterPracticeProblems(chapterId) {
  return CHAPTER_PRACTICE[chapterId] || [];
}

/**
 * Returns the count of available chapter practice problems.
 * Used by study.jsx to show/hide the "Practice All" button.
 */
export function getChapterPracticeCount(chapterId) {
  return (CHAPTER_PRACTICE[chapterId] || []).length;
}
