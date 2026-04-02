import determinacyStability from './determinacy-stability';
import loadCombinations from './load-combinations';
import influenceLines from './influence-lines';
import rcFlexureShear from './rc-flexure-shear';
import rcColumns from './rc-columns';
import steelBeams from './steel-beams';
import steelColumns from './steel-columns';
import steelTension from './steel-tension';

export default [
  { subtopicId: 'analysis-loads', lessons: [determinacyStability, loadCombinations, influenceLines] },
  { subtopicId: 'rc-design', lessons: [rcFlexureShear, rcColumns] },
  { subtopicId: 'steel-design', lessons: [steelBeams, steelColumns, steelTension] },
];
