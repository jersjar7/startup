import stressStrainMaterialBehavior from './stress-strain-material-behavior';
import hardnessImpactFatigue from './hardness-impact-fatigue';
import thermalProcessingPhaseDiagrams from './thermal-processing-phase-diagrams';
import concreteMixDesign from './concrete-mix-design';
import concreteCuringStrength from './concrete-curing-strength';
import compositeMaterials from './composite-materials';
import corrosionMaterialSelection from './corrosion-material-selection';
import aggregateProperties from './aggregate-properties';
import asphaltMixDesign from './asphalt-mix-design';
import woodMasonry from './wood-masonry';

export default [
  { subtopicId: 'mechanical-properties', lessons: [stressStrainMaterialBehavior, hardnessImpactFatigue, thermalProcessingPhaseDiagrams] },
  { subtopicId: 'concrete-technology', lessons: [concreteMixDesign, concreteCuringStrength] },
  { subtopicId: 'construction-materials', lessons: [aggregateProperties, asphaltMixDesign, woodMasonry] },
  { subtopicId: 'composites-selection', lessons: [compositeMaterials, corrosionMaterialSelection] },
];
