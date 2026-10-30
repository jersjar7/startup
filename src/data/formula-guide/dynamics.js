// Plain-language guide to the formulas on the FE Civil Dynamics page,
// in the same order as chapters/dynamics.js. Symbols checked against the FE
// Reference Handbook 10.5.
export default [
  {
    label: 'Constant Acceleration',
    aliases: ['constant acceleration', 'kinematics', 'velocity time', 'suvat'],
    use: 'Find speed after a given time when acceleration does not change.',
    symbols: [
      { tex: 'v', means: 'velocity at time t', units: 'ft/s or m/s' },
      { tex: 'v_0', means: 'initial velocity, at time zero', units: 'ft/s or m/s' },
      { tex: 'a', means: 'constant acceleration (g for free fall)', units: 'ft/s² or m/s²' },
      { tex: 't', means: 'time elapsed', units: 's' },
    ],
    trap: 'Only valid when acceleration is constant; for free fall pick a direction as positive and give g its sign.',
  },
  {
    label: 'Displacement',
    aliases: ['displacement', 'position', 'kinematics', 'distance traveled', 'free fall'],
    use: 'Find position after a given time when acceleration does not change.',
    symbols: [
      { tex: 's', means: 'position at time t, along the line of travel', units: 'ft or m' },
      { tex: 's_0', means: 'initial position, at time zero', units: 'ft or m' },
      { tex: 'v_0', means: 'initial velocity, at time zero', units: 'ft/s or m/s' },
      { tex: 'a', means: 'constant acceleration (g for free fall)', units: 'ft/s² or m/s²' },
      { tex: 't', means: 'time elapsed', units: 's' },
    ],
    trap: 'Only valid when acceleration is constant; use g = 32.2 ft/s² or 9.81 m/s² with the sign of your chosen direction.',
  },
  {
    label: 'Velocity-Position',
    aliases: ['velocity squared', 'stopping distance', 'kinematics', 'no time'],
    use: 'Relate speed and distance when time is not given, like a braking or stopping distance.',
    symbols: [
      { tex: 'v', means: 'velocity at position s', units: 'ft/s or m/s' },
      { tex: 'v_0', means: 'initial velocity, at position s_0', units: 'ft/s or m/s' },
      { tex: 'a', means: 'constant acceleration (negative when slowing down)', units: 'ft/s² or m/s²' },
      { tex: 's', means: 'final position', units: 'ft or m' },
      { tex: 's_0', means: 'initial position', units: 'ft or m' },
    ],
    trap: 'Convert mph or km/h to ft/s or m/s first (1 mph = 1.467 ft/s), and give deceleration a negative sign.',
  },
  {
    label: "Newton's Second Law",
    aliases: ['newtons second law', 'f equals ma', 'force mass acceleration', 'kinetics'],
    use: 'Find the acceleration a set of forces gives a body, or the force needed for a given acceleration.',
    symbols: [
      { tex: '\\sum F', means: 'sum of all forces acting on the body, in the direction of motion', units: 'lbf or N' },
      { tex: 'm', means: 'mass of the body', units: 'slug (lbf·s²/ft) or kg' },
      { tex: 'a', means: 'acceleration of the body', units: 'ft/s² or m/s²' },
    ],
    trap: 'In US units a weight in lbf is not a mass; divide by g = 32.2 ft/s² to get slugs.',
  },
  {
    label: 'Conservation of Energy',
    aliases: ['conservation of energy', 'kinetic energy', 'potential energy', 'work energy'],
    use: 'Relate speed and height (or spring stretch) at two points when no energy is lost to friction.',
    symbols: [
      { tex: 'T_1', means: 'kinetic energy at state 1, one half m v²', units: 'ft·lbf or J' },
      { tex: 'V_1', means: 'potential energy at state 1, from height (mgh) and springs (one half k s²)', units: 'ft·lbf or J' },
      { tex: 'T_2', means: 'kinetic energy at state 2', units: 'ft·lbf or J' },
      { tex: 'V_2', means: 'potential energy at state 2', units: 'ft·lbf or J' },
    ],
    trap: 'With friction or other non-conservative forces, add the work term U1→2 (negative for friction) to the right side.',
  },
  {
    label: 'Conservation of Momentum',
    aliases: ['conservation of momentum', 'impact', 'collision', 'linear momentum'],
    use: 'Find velocities after two bodies collide, when no outside force acts during the impact.',
    symbols: [
      { tex: 'm_1', means: 'mass of body 1', units: 'slug or kg' },
      { tex: 'm_2', means: 'mass of body 2', units: 'slug or kg' },
      { tex: 'v_1', means: 'velocity of body 1 just before impact', units: 'ft/s or m/s' },
      { tex: 'v_2', means: 'velocity of body 2 just before impact', units: 'ft/s or m/s' },
      { tex: "v_1'", means: 'velocity of body 1 just after impact', units: 'ft/s or m/s' },
      { tex: "v_2'", means: 'velocity of body 2 just after impact', units: 'ft/s or m/s' },
    ],
    trap: 'Velocities carry signs, so a body moving the other way is negative; momentum is conserved but kinetic energy is not, unless the impact is perfectly elastic (e = 1).',
  },
  {
    label: 'Natural Frequency',
    aliases: ['natural frequency', 'vibration', 'spring mass', 'omega n'],
    use: 'Find how fast an undamped spring and mass system vibrates on its own.',
    symbols: [
      { tex: '\\omega_n', means: 'undamped natural circular frequency', units: 'rad/s' },
      { tex: 'k', means: 'spring stiffness (spring constant)', units: 'lbf/ft or N/m' },
      { tex: 'm', means: 'vibrating mass', units: 'slug or kg' },
    ],
    trap: 'The answer is in rad/s; divide by 2π for cycles per second (Hz), and use mass, not weight, for m.',
  },
];
