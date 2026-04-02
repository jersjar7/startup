import fluidProperties from './fluid-properties';
import hydrostaticPressure from './hydrostatic-pressure';
import hydrostaticForcesBuoyancy from './hydrostatic-forces-buoyancy';
import continuityBernoulli from './continuity-bernoulli';
import pipeFlowHeadLoss from './pipe-flow-head-loss';
import momentumEquation from './momentum-equation';
import flowMeasurement from './flow-measurement';
import dimensionalAnalysisSimilitude from './dimensional-analysis-similitude';

export default [
  { subtopicId: 'fluid-properties-statics', lessons: [fluidProperties, hydrostaticPressure, hydrostaticForcesBuoyancy] },
  { subtopicId: 'fluid-dynamics', lessons: [continuityBernoulli, pipeFlowHeadLoss, momentumEquation] },
  { subtopicId: 'flow-analysis-measurement', lessons: [flowMeasurement, dimensionalAnalysisSimilitude] },
];
