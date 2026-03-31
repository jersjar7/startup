export default {
  context: 'This chapter tests your ability to analyze forces, moments, and equilibrium in rigid body systems.',
  subtopics: [
    { id: 'force-resultants',  name: 'Resultants of Force Systems (2D & 3D)' },
    { id: 'equivalent-forces', name: 'Equivalent Force Systems & Couples' },
    { id: 'equilibrium',       name: 'Equilibrium of Rigid Bodies & FBDs' },
    { id: 'trusses-frames',    name: 'Frames & Trusses' },
    { id: 'centroids',         name: 'Centroid of Area & Composite Shapes' },
    { id: 'moments-of-inertia', name: 'Area Moments of Inertia' },
    { id: 'friction',          name: 'Static Friction & Impending Motion' },
  ],
  formulas: [
    { latex: '\\sum F_x = 0,\\quad \\sum F_y = 0,\\quad \\sum M = 0', label: 'Equilibrium Equations', page: 'p. 58' },
    { latex: '\\bar{x} = \\frac{\\sum A_i x_i}{\\sum A_i}', label: 'Composite Centroid', page: 'p. 62' },
    { latex: 'I_x = \\bar{I}_x + Ad^2', label: 'Parallel Axis Theorem', page: 'p. 63' },
    { latex: 'F_f = \\mu_s N', label: 'Static Friction', page: 'p. 58' },
    { latex: 'M = F \\times d', label: 'Moment of a Force', page: 'p. 58' },
  ],
  traps: [
    'Incorrect free body diagram — forgetting a reaction force or including an internal force on the wrong side of the cut.',
    'Wrong sign convention for moments — pick CW or CCW positive and stick with it throughout.',
    'In trusses, confusing method of joints (all forces at a joint) with method of sections (cutting through members).',
    'Forgetting the Ad² term in the parallel axis theorem when computing composite moments of inertia.',
    'Assuming friction force equals μN before verifying impending motion — it could be less than the maximum.',
  ],
};
