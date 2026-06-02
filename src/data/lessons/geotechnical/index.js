import phaseRelations from './phase-relations';
import soilClassification from './soil-classification';
import effectiveStress from './effective-stress';
import consolidation from './consolidation';
import shearStrength from './shear-strength';
import bearingCapacity from './bearing-capacity';
import lateralEarthPressure from './lateral-earth-pressure';
import retainingWalls from './retaining-walls';
import permeabilitySeepage from './permeability-seepage';
import slopeStability from './slope-stability';
import compactionStabilization from './compaction-stabilization';
import deepFoundations from './deep-foundations';

export default [
  { subtopicId: 'soil-properties', lessons: [phaseRelations, soilClassification, effectiveStress] },
  { subtopicId: 'consolidation-strength', lessons: [consolidation, shearStrength] },
  { subtopicId: 'seepage-stability', lessons: [permeabilitySeepage, slopeStability] },
  { subtopicId: 'foundations-walls', lessons: [bearingCapacity, lateralEarthPressure, retainingWalls] },
  { subtopicId: 'deep-foundations-improvement', lessons: [deepFoundations, compactionStabilization] },
];
