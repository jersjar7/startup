import axialStressStrainDeformation from './axial-stress-strain-deformation';
import torsion from './torsion';
import stressStrainDiagrams from './stress-strain-diagrams';
import shearMomentDiagrams from './shear-moment-diagrams';
import bendingShearStresses from './bending-shear-stresses';
import beamDeflections from './beam-deflections';
import combinedStressesMohrsCircle from './combined-stresses-mohrs-circle';
import columnBuckling from './column-buckling';

export default [
  { subtopicId: 'stress-strain-fundamentals', lessons: [axialStressStrainDeformation, torsion, stressStrainDiagrams] },
  { subtopicId: 'beams', lessons: [shearMomentDiagrams, bendingShearStresses, beamDeflections] },
  { subtopicId: 'combined-loading-stability', lessons: [combinedStressesMohrsCircle, columnBuckling] },
];
