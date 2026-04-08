import mathematics from './mathematics/index';
import statistics from './statistics/index';
import ethics from './ethics/index';
import economics from './economics/index';
import statics from './statics/index';
import dynamics from './dynamics/index';
import mechanicsMaterials from './mechanics-materials/index';
import materials from './materials/index';
import fluidMechanics from './fluid-mechanics/index';
import surveying from './surveying/index';
import waterResources from './water-resources/index';
import structural from './structural/index';
import geotechnical from './geotechnical/index';
import transportation from './transportation/index';
import construction from './construction/index';

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

