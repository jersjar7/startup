import forceSystemsResultants from './force-systems-resultants';
import equilibriumFreeBodyDiagrams from './equilibrium-free-body-diagrams';
import trussesJointsSections from './trusses-joints-sections';
import friction from './friction';
import centroidsCompositeShapes from './centroids-composite-shapes';
import areaMomentsOfInertia from './area-moments-of-inertia';
import framesMachines from './frames-machines';

export default [
  { subtopicId: 'forces-and-equilibrium', lessons: [forceSystemsResultants, equilibriumFreeBodyDiagrams] },
  { subtopicId: 'trusses-and-friction', lessons: [trussesJointsSections, friction, framesMachines] },
  { subtopicId: 'section-properties', lessons: [centroidsCompositeShapes, areaMomentsOfInertia] },
];
