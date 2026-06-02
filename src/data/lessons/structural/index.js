import determinacyStability from './determinacy-stability';
import loadCombinations from './load-combinations';
import influenceLines from './influence-lines';
import trussAnalysisMethods from './truss-analysis-methods';
import deflectionVirtualWork from './deflection-virtual-work';
import indeterminateStructures from './indeterminate-structures';
import rcFlexureShear from './rc-flexure-shear';
import rcColumns from './rc-columns';
import steelBeams from './steel-beams';
import steelColumns from './steel-columns';
import steelTension from './steel-tension';

export default [
  { subtopicId: 'analysis-loads', lessons: [determinacyStability, trussAnalysisMethods, deflectionVirtualWork, indeterminateStructures, loadCombinations, influenceLines] },
  { subtopicId: 'rc-design', lessons: [rcFlexureShear, rcColumns] },
  { subtopicId: 'steel-design', lessons: [steelBeams, steelColumns, steelTension] },
];
