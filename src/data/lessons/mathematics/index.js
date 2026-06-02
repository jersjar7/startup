// Analytic Geometry
import straightLinesQuadratics from './analytic-geometry/straight-lines-quadratics';
import logarithms from './analytic-geometry/logarithms';
import rightTriangleTrig from './analytic-geometry/right-triangle-trig';
import lawOfSinesCosines from './analytic-geometry/law-of-sines-cosines';
import unitCircleTrigIdentities from './analytic-geometry/unit-circle-trig-identities';
import circlesConics from './analytic-geometry/circles-conics';

// Single-Variable Calculus
import derivativesRules from './single-var-calc/derivatives-rules';
import applicationsDerivatives from './single-var-calc/applications-derivatives';
import integralCalculus from './single-var-calc/integral-calculus';
import lhopitalsRule from './single-var-calc/lhopitals-rule';

// Vector Operations
import vectorBasics from './vector-operations/vector-basics-unit-vectors';
import dotProduct from './vector-operations/dot-product-angle';
import crossProduct from './vector-operations/cross-product-applications';

// Computational Tools
import spreadsheetComputations from './computational-tools/spreadsheet-computations';
import structuredProgramming from './computational-tools/structured-programming';
import numericalMethods from './computational-tools/numerical-methods';

export default [
  {
    subtopicId: 'analytic-geometry',
    lessons: [
      straightLinesQuadratics,
      logarithms,
      rightTriangleTrig,
      lawOfSinesCosines,
      unitCircleTrigIdentities,
      circlesConics,
    ],
  },
  {
    subtopicId: 'single-var-calc',
    lessons: [
      derivativesRules,
      applicationsDerivatives,
      integralCalculus,
      lhopitalsRule,
    ],
  },
  {
    subtopicId: 'vector-operations',
    lessons: [
      vectorBasics,
      dotProduct,
      crossProduct,
    ],
  },
  {
    subtopicId: 'computational-tools',
    lessons: [
      spreadsheetComputations,
      structuredProgramming,
      numericalMethods,
    ],
  },
];
