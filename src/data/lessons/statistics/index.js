import centralTendency from './central-tendency';
import distributions from './distributions';
import expectedValue from './expected-value';
import estimation from './estimation';
import regression from './regression';
import hypothesisTesting from './hypothesis-testing';

export default [
  {
    subtopicId: 'descriptive-statistics',
    lessons: [centralTendency, regression],
  },
  {
    subtopicId: 'probability',
    lessons: [distributions, expectedValue],
  },
  {
    subtopicId: 'inferential-statistics',
    lessons: [estimation, hypothesisTesting],
  },
];
