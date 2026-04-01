import particleKinematics from './particle-kinematics';
import rigidBodyKinematicsMassMoi from './rigid-body-kinematics-mass-moi';
import forceAndAcceleration from './force-and-acceleration';
import workEnergyPower from './work-energy-power';
import impulseAndMomentum from './impulse-and-momentum';
import vibrationsNaturalFrequency from './vibrations-natural-frequency';

export default [
  { subtopicId: 'kinematics', lessons: [particleKinematics, rigidBodyKinematicsMassMoi] },
  { subtopicId: 'kinetics-and-energy', lessons: [forceAndAcceleration, workEnergyPower] },
  { subtopicId: 'momentum-and-vibrations', lessons: [impulseAndMomentum, vibrationsNaturalFrequency] },
];
