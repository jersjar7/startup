export default {
  context: 'This chapter tests kinematics, kinetics, energy methods, and momentum principles for particles and rigid bodies.',
  subtopics: [
    { id: 'particle-kinematics',  name: 'Kinematics of Particles' },
    { id: 'rigid-body-kinematics', name: 'Kinematics of Rigid Bodies' },
    { id: 'mass-moi',             name: 'Mass Moments of Inertia' },
    { id: 'kinetics-newton',      name: 'Kinetics: Force & Acceleration' },
    { id: 'work-energy',          name: 'Work, Energy & Power' },
    { id: 'impulse-momentum',     name: 'Impulse & Momentum' },
    { id: 'vibrations',           name: 'Vibrations & Natural Frequency' },
  ],
  formulas: [
    { latex: 'v = v_0 + at', label: 'Constant Acceleration', page: 'p. 66' },
    { latex: 's = v_0 t + \\frac{1}{2}at^2', label: 'Displacement', page: 'p. 66' },
    { latex: '\\sum F = ma', label: "Newton's Second Law", page: 'p. 67' },
    { latex: 'T_1 + U_{1\\to2} = T_2', label: 'Work-Energy Theorem', page: 'p. 68' },
    { latex: 'm_1v_1 + m_2v_2 = m_1v_1\' + m_2v_2\'', label: 'Conservation of Momentum', page: 'p. 68' },
    { latex: '\\omega_n = \\sqrt{k/m}', label: 'Natural Frequency', page: 'p. 69' },
  ],
  traps: [
    'Using kinematic equations when acceleration is NOT constant — they only work for uniform acceleration.',
    'Forgetting to include all forces (gravity, friction, normals) in ΣF = ma — draw the FBD first.',
    'Mixing up elastic and inelastic collisions — kinetic energy is only conserved in elastic collisions.',
    'Not converting angular units — ω must be in rad/s, not rpm, for most formulas.',
    'Confusing velocity and speed in projectile motion — velocity has direction.',
  ],
};
