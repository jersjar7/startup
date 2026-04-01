export default {
  context: 'This chapter tests kinematics, kinetics, energy methods, and momentum principles for particles and rigid bodies.',
  subtopics: [
    { id: 'kinematics', name: 'Kinematics',
      application: 'Kinematics describes motion without worrying about forces — how fast, how far, what path. Civil engineers use it to derive stopping sight distance on highways, predict projectile trajectories for debris analysis, and calculate the motion of rotating machinery components.' },
    { id: 'kinetics-and-energy', name: 'Kinetics & Energy',
      application: 'Kinetics connects forces to the motion they cause. Civil engineers use Newton\'s second law to compute dynamic forces from earthquake ground acceleration on a building, impact forces on bridge barriers, and work-energy methods to size pump motors, design guardrails for crash energy absorption, and calculate power requirements for construction equipment.' },
    { id: 'momentum-and-vibrations', name: 'Momentum & Vibrations',
      application: 'Impulse-momentum methods handle short-duration forces like vehicle impacts on bridge piers and water jets on turbine blades. Vibration analysis ensures pedestrian bridges don\'t resonate with footfalls, buildings don\'t amplify earthquake motion, and machine foundations don\'t vibrate excessively.' },
  ],
  formulas: [
    { latex: 'v = v_0 + at', label: 'Constant Acceleration', page: 'p. 104' },
    { latex: 's = s_0 + v_0 t + \\frac{1}{2}at^2', label: 'Displacement', page: 'p. 104' },
    { latex: 'v^2 = v_0^2 + 2a(s - s_0)', label: 'Velocity-Position', page: 'p. 104' },
    { latex: '\\sum F = ma', label: "Newton's Second Law", page: 'p. 105' },
    { latex: 'T_1 + V_1 = T_2 + V_2', label: 'Conservation of Energy', page: 'p. 106' },
    { latex: 'm_1 v_1 + m_2 v_2 = m_1 v_1\' + m_2 v_2\'', label: 'Conservation of Momentum', page: 'p. 108' },
    { latex: '\\omega_n = \\sqrt{k/m}', label: 'Natural Frequency', page: 'p. 112' },
  ],
  traps: [
    'Using kinematic equations when acceleration is NOT constant — they only work for uniform acceleration.',
    'Forgetting to include all forces (gravity, friction, normals) in ΣF = ma — draw the FBD first.',
    'Mixing up elastic and inelastic collisions — kinetic energy is only conserved in elastic collisions.',
    'Not converting angular units — ω must be in rad/s, not rpm, for most formulas.',
    'Confusing velocity and speed in projectile motion — velocity has direction.',
  ],
};
