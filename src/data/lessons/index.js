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

export function getExamProblemsForChapter(chapterId) {
  const chapter = LESSONS[chapterId];
  if (!chapter) return [];
  const problems = [];
  for (const subtopic of chapter) {
    for (const lesson of subtopic.lessons) {
      if (lesson.examProblems) {
        problems.push(...lesson.examProblems.map(p => ({
          ...p,
          lessonId: lesson.id,
          lessonName: lesson.name,
          subtopicId: subtopic.subtopicId,
          chapterId,
        })));
      }
    }
  }
  return problems;
}

const CHAPTER_IDS = [
  'mathematics', 'statistics', 'ethics', 'economics', 'statics',
  'dynamics', 'mechanics-materials', 'materials', 'fluid-mechanics',
  'surveying', 'water-resources', 'structural', 'geotechnical',
  'transportation', 'construction',
];

export function selectDiagnosticQuestions(excludeIds = []) {
  const selected = [];
  const excludeSet = new Set(excludeIds);

  for (const chapterId of CHAPTER_IDS) {
    const pool = getExamProblemsForChapter(chapterId)
      .filter(p => !excludeSet.has(p.id));

    if (pool.length === 0) continue;

    // Try to get 1 computational + 1 conceptual
    const computational = pool.filter(p => p.type === 'computational');
    const conceptual = pool.filter(p => p.type === 'conceptual');

    const picks = [];
    if (computational.length > 0 && conceptual.length > 0) {
      picks.push(computational[Math.floor(Math.random() * computational.length)]);
      picks.push(conceptual[Math.floor(Math.random() * conceptual.length)]);
    } else {
      // Fallback: pick any 2 (or 1 if pool is small)
      const shuffled = [...pool].sort(() => Math.random() - 0.5);
      picks.push(...shuffled.slice(0, 2));
    }

    selected.push(...picks);
  }

  // Shuffle all selected questions so they're not grouped by chapter
  return selected.sort(() => Math.random() - 0.5);
}
