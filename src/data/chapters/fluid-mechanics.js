export default {
  context: 'This chapter tests fluid properties, hydrostatics, Bernoulli\'s equation, pipe flow, and flow measurement.',
  subtopics: [
    { id: 'fluid-properties',  name: 'Fluid Properties' },
    { id: 'fluid-statics',     name: 'Fluid Statics & Hydrostatic Forces' },
    { id: 'continuity',        name: 'Continuity Equation' },
    { id: 'bernoulli',         name: 'Bernoulli & Energy Equation' },
    { id: 'pipe-flow',         name: 'Flow in Closed Conduits' },
    { id: 'momentum-eq',       name: 'Momentum Equation' },
    { id: 'dimensional-analysis', name: 'Dimensional Analysis & Similitude' },
    { id: 'flow-measurement',  name: 'Flow Measurement' },
    { id: 'reynolds-number',   name: 'Laminar vs. Turbulent Flow' },
  ],
  formulas: [
    { latex: 'A_1 v_1 = A_2 v_2', label: 'Continuity', page: 'p. 81' },
    { latex: '\\frac{P_1}{\\gamma} + \\frac{v_1^2}{2g} + z_1 = \\frac{P_2}{\\gamma} + \\frac{v_2^2}{2g} + z_2', label: "Bernoulli's Equation", page: 'p. 82' },
    { latex: 'h_f = f\\frac{L}{D}\\frac{v^2}{2g}', label: 'Darcy-Weisbach', page: 'p. 83' },
    { latex: 'Re = \\frac{\\rho v D}{\\mu} = \\frac{vD}{\\nu}', label: 'Reynolds Number', page: 'p. 81' },
    { latex: 'F = \\rho Q(v_2 - v_1)', label: 'Momentum Equation', page: 'p. 84' },
  ],
  traps: [
    'Forgetting to convert units — pressure in kPa, velocity in m/s, diameter in m (not mm or cm).',
    'Bernoulli only applies along a streamline for steady, incompressible, inviscid flow — adding friction requires the energy equation.',
    'Using the wrong friction factor — Moody diagram gives Darcy f, not Fanning f (which is 4× smaller).',
    'Forgetting the hydrostatic pressure acts at the centroid of the submerged surface, not the center of pressure.',
    'Re < 2000 = laminar, Re > 4000 = turbulent — the transition zone is 2000–4000.',
  ],
};
