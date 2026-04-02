import cpmFundamentals from './cpm-fundamentals';
import forwardBackwardPass from './forward-backward-pass';
import floatCriticalPath from './float-critical-path';
import earnedValueAnalysis from './earned-value-analysis';
import projectForecasting from './project-forecasting';
import deliveryMethods from './delivery-methods';
import constructionSafety from './construction-safety';

export default [
  { subtopicId: 'scheduling-cpm', lessons: [cpmFundamentals, forwardBackwardPass, floatCriticalPath] },
  { subtopicId: 'earned-value', lessons: [earnedValueAnalysis, projectForecasting] },
  { subtopicId: 'project-delivery', lessons: [deliveryMethods, constructionSafety] },
];
