export default {
  context: 'This chapter tests your ability to apply analytic geometry, single-variable calculus, and vector operations to engineering problems.',
  subtopics: [
    { id: 'analytic-geometry',    name: 'Analytic Geometry',
      application: 'As a civil engineer, you use analytic geometry constantly — computing slopes and grades for road profiles, finding distances between survey points, resolving force components with trig, solving oblique triangles for property boundaries, and working with conic sections in highway curve design. If a problem gives you coordinates, angles, or a line equation, this is your toolkit.' },
    { id: 'single-var-calc',      name: 'Single-Variable Calculus',
      application: 'As a civil engineer, you rely on calculus every time you compute the area under a load diagram, find where shear is zero (and moment is maximum) on a beam, or determine the rate of change of flow in a storm drain. Differentiation and integration are the backbone of structural analysis, earthwork volumes, and hydraulic design.' },
    { id: 'vector-operations',    name: 'Vector Operations',
      application: 'As a civil engineer, vectors are how you resolve forces on structural connections, compute the moment of a force about a point, and determine resultant loads on a structure. Dot products find the angle between forces; cross products give you moment arms in three dimensions.' },
  ],
  formulas: [
    { latex: 'm = \\frac{y_2 - y_1}{x_2 - x_1}', label: 'Slope from Two Points', page: 'p. 36' },
    { latex: 'd = \\sqrt{(x_2 - x_1)^2 + (y_2 - y_1)^2}', label: 'Distance Formula', page: 'p. 36' },
    { latex: 'x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}', label: 'Quadratic Formula', page: 'p. 36' },
    { latex: '\\frac{a}{\\sin A} = \\frac{b}{\\sin B} = \\frac{c}{\\sin C}', label: 'Law of Sines', page: 'p. 38' },
    { latex: 'c^2 = a^2 + b^2 - 2ab\\cos C', label: 'Law of Cosines', page: 'p. 38' },
    { latex: '\\frac{d}{dx}[f(g(x))] = f\'(g(x))\\cdot g\'(x)', label: 'Chain Rule', page: 'p. 49' },
    { latex: '\\int u\\,dv = uv - \\int v\\,du', label: 'Integration by Parts', page: 'p. 50' },
    { latex: '\\vec{A}\\cdot\\vec{B} = |A||B|\\cos\\theta', label: 'Dot Product', page: 'p. 94' },
    { latex: '\\vec{A}\\times\\vec{B} = |A||B|\\sin\\theta\\,\\hat{n}', label: 'Cross Product', page: 'p. 94' },
  ],
  traps: [
    'Forgetting to convert station notation to feet before computing slope.',
    'Mixing up sin and cos when resolving force components — cos is "cozy" with adjacent.',
    'No log rule for log(x + y) — only products, quotients, and powers have rules.',
    'Forgetting the chain rule when differentiating composite functions.',
    'Mixing up dot product (scalar result) and cross product (vector result).',
  ],
};
