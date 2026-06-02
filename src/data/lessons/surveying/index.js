import anglesDistancesBearings from './angles-distances-bearings';
import leveling from './leveling';
import traverseComputations from './traverse-computations';
import areaComputations from './area-computations';
import earthworkVolumes from './earthwork-volumes';
import horizontalCurves from './horizontal-curves';
import verticalCurves from './vertical-curves';
import coordinateGeometry from './coordinate-geometry';

export default [
  { subtopicId: 'measurement-leveling', lessons: [anglesDistancesBearings, leveling] },
  { subtopicId: 'area-volume-traverse', lessons: [traverseComputations, areaComputations, earthworkVolumes, coordinateGeometry] },
  { subtopicId: 'curves', lessons: [horizontalCurves, verticalCurves] },
];
