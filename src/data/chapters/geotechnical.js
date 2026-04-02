export default {
  context: 'This chapter covers soil classification, phase relations, effective stress, consolidation, shear strength, bearing capacity, lateral earth pressure, and retaining wall stability.',
  subtopics: [
    { id: 'soil-properties', name: 'Soil Properties & Classification',
      application: 'As a civil engineer, you classify soils using USCS and AASHTO systems, compute phase relations from lab data (water content, unit weight, void ratio), and construct effective stress profiles through layered soil with a water table. These fundamentals underpin every geotechnical design calculation.' },
    { id: 'consolidation-strength', name: 'Consolidation & Shear Strength',
      application: 'As a civil engineer, you predict how much a clay layer will settle under new loading using the consolidation e-log p curve, and you determine soil shear strength from triaxial tests to check foundation, slope, and retaining wall stability.' },
    { id: 'foundations-walls', name: 'Foundations & Earth Pressures',
      application: 'As a civil engineer, you compute bearing capacity to size foundations, calculate lateral earth pressures to design retaining walls, and check walls for overturning, sliding, and bearing failure. These are the most common geotechnical design tasks in practice.' },
  ],
  formulas: [
    { latex: '\\sigma\' = \\sigma - u', label: 'Effective Stress', page: 'p. 263' },
    { latex: 'Se = \\omega G_s', label: 'Phase Relation (master equation)', page: 'p. 259' },
    { latex: '\\gamma_{sat} = \\frac{(G_s + e)\\gamma_w}{1 + e}', label: 'Saturated Unit Weight', page: 'p. 259' },
    { latex: '\\Delta H = \\frac{H_0}{1+e_0} C_c \\log \\frac{p_0 + \\Delta p}{p_0}', label: 'NC Consolidation Settlement', page: 'p. 261' },
    { latex: '\\tau_f = c\' + \\sigma\' \\tan \\phi\'', label: 'Mohr-Coulomb Failure', page: 'p. 263' },
    { latex: 'q_{ult} = cN_c + \\gamma\' D_f N_q + 0.5\\gamma\' BN_\\gamma', label: "Terzaghi's Bearing Capacity", page: 'p. 264' },
    { latex: 'K_a = \\tan^2(45\\degree - \\phi/2)', label: 'Rankine Active Pressure', page: 'p. 263' },
    { latex: 'FS_{\\text{overturning}} = \\Sigma M_R / M_O', label: 'Retaining Wall Overturning', page: 'p. 264' },
  ],
  traps: [
    'Forgetting to subtract pore water pressure (u) to get effective stress \u2014 this is the single most tested concept.',
    'Using total unit weight below the water table instead of buoyant (submerged) unit weight: \u03B3\u2019 = \u03B3sat \u2212 \u03B3w.',
    'Confusing Cc (compression index) with Cr (recompression index) \u2014 use Cr when stress stays below preconsolidation.',
    'Active vs. passive earth pressure: active is when the wall moves AWAY from soil, passive is when wall pushes INTO soil.',
    'Not dividing ultimate bearing capacity by FS when the problem asks for allowable bearing pressure.',
  ],
};
