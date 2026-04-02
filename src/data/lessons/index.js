import mathematics from './mathematics/index';
import statistics from './statistics/index';
import ethics from './ethics/index';
import economics from './economics/index';
import statics from './statics/index';
import dynamics from './dynamics/index';
import mechanicsMaterials from './mechanics-materials/index';
import materials from './materials/index';
import fluidMechanics from './fluid-mechanics';
import surveying from './surveying';
import waterResources from './water-resources';
import structural from './structural';
import geotechnical from './geotechnical';
import transportation from './transportation';
import construction from './construction';

export const LESSONS = {
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

export function getLessonById(chapterId, lessonId) {
  const chapter = LESSONS[chapterId];
  if (!chapter) return null;
  for (const subtopic of chapter) {
    const found = subtopic.lessons.find((l) => l.id === lessonId);
    if (found) return found;
  }
  return null;
}
