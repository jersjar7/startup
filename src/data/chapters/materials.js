export default {
  context: 'This chapter covers the properties, testing, and mix design of concrete, steel, asphalt, aggregates, and timber.',
  subtopics: [
    { id: 'concrete',       name: 'Concrete: Mix Design & Properties' },
    { id: 'steel-metals',   name: 'Steel & Metals: Mechanical Properties' },
    { id: 'asphalt',        name: 'Asphalt: Mix Design & Testing' },
    { id: 'aggregates',     name: 'Aggregates: Gradation & Properties' },
    { id: 'wood-timber',    name: 'Wood & Timber' },
    { id: 'material-comparison', name: 'Physical & Mechanical Properties Comparison' },
  ],
  formulas: [
    { latex: 'w/c = \\frac{\\text{weight of water}}{\\text{weight of cement}}', label: 'Water-Cement Ratio', page: 'p. 168' },
    { latex: 'G_s = \\frac{\\gamma_s}{\\gamma_w}', label: 'Specific Gravity', page: 'p. 165' },
    { latex: '\\sigma_y,\\; \\sigma_u,\\; \\varepsilon_f', label: 'Yield/Ultimate/Fracture', page: 'p. 167' },
    { latex: '\\% \\text{passing} = \\frac{\\text{mass passing sieve}}{\\text{total mass}} \\times 100', label: 'Gradation (Sieve Analysis)', page: 'p. 165' },
  ],
  traps: [
    'Lower water-cement ratio means HIGHER strength — students often get this backwards.',
    'Confusing modulus of elasticity (stiffness) with strength (stress capacity) — they are independent properties.',
    'Forgetting that concrete is strong in compression but weak in tension — that\'s why we reinforce it.',
    'Mixing up Marshall and Superpave asphalt mix design methods — know which uses stability/flow vs. volumetrics.',
    'Not accounting for moisture absorption when computing specific gravity of aggregates.',
  ],
};
