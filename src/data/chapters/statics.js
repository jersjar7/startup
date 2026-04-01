export default {
  context: 'This chapter tests your ability to analyze forces, moments, and equilibrium in rigid body systems.',
  subtopics: [
    { id: 'forces-and-equilibrium', name: 'Forces & Equilibrium',
      application: 'Every structural analysis starts with resolving forces into components and writing equilibrium equations. Whether you are finding the reactions of a simply supported bridge girder, combining dead load, live load, and wind on a building connection, or checking the overturning stability of a retaining wall, the process is the same: draw the free body diagram, resolve forces, and apply \u03a3F = 0 and \u03a3M = 0.' },
    { id: 'trusses-and-friction', name: 'Trusses & Friction',
      application: 'Civil engineers analyze trusses when designing roof systems, pedestrian bridges, and transmission towers. Method of joints gives you all member forces; method of sections lets you cut straight to the one member you need to size. Friction governs the sliding stability of retaining walls, the traction of vehicles on road surfaces, and belt-driven equipment loads.' },
    { id: 'section-properties', name: 'Section Properties',
      application: 'Centroids locate the neutral axis of composite beam cross-sections and the point of application of distributed loads. Moments of inertia control how much a beam bends and where it fails in flexure. You compute these for composite sections using the parallel axis theorem \u2014 built-up steel columns, reinforced concrete T-beams, and timber box beams all require combining individual shape properties about a common axis.' },
  ],
  formulas: [
    { latex: '\\sum F_x = 0,\\quad \\sum F_y = 0,\\quad \\sum M = 0', label: 'Equilibrium Equations', page: 'p. 94' },
    { latex: '\\bar{x} = \\frac{\\sum A_i x_i}{\\sum A_i}', label: 'Composite Centroid', page: 'p. 95' },
    { latex: 'I_x = \\bar{I}_x + Ad^2', label: 'Parallel Axis Theorem', page: 'p. 95' },
    { latex: 'F \\leq \\mu_s N', label: 'Static Friction', page: 'p. 96' },
    { latex: 'M = r \\times F', label: 'Moment of a Force', page: 'p. 94' },
  ],
  traps: [
    'Incorrect free body diagram \u2014 forgetting a reaction force or including an internal force on the wrong side of the cut.',
    'Wrong sign convention for moments \u2014 pick CW or CCW positive and stick with it throughout.',
    'In trusses, confusing method of joints (all forces at a joint) with method of sections (cutting through members).',
    'Forgetting the Ad\u00b2 term in the parallel axis theorem when computing composite moments of inertia.',
    'Assuming friction force equals \u03bcN before verifying impending motion \u2014 it could be less than the maximum.',
  ],
};
