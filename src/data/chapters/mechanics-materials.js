export default {
  context: 'This chapter tests internal forces, stress-strain analysis, deformations, and stability of structural members.',
  subtopics: [
    { id: 'stress-strain-fundamentals', name: 'Stress, Strain & Material Behavior',
      application: 'As a civil engineer, you compute stresses and deformations to check whether structural members are safe and serviceable \u2014 axial stress in columns, torsional shear in shafts, and material properties from stress-strain curves. These fundamentals underpin every structural calculation.' },
    { id: 'beams', name: 'Beams',
      application: 'As a civil engineer, you design beams by constructing shear and moment diagrams, computing bending and shear stresses from internal forces, and checking deflections against serviceability limits. From floor joists to bridge girders, beam analysis is the most frequently tested mechanics topic.' },
    { id: 'combined-loading-stability', name: 'Combined Loading & Stability',
      application: 'As a civil engineer, real members experience combined stresses \u2014 axial plus bending, shear plus torsion. You find principal stresses and maximum shear using Mohr\'s circle, and check slender columns against Euler buckling to prevent sudden stability failures.' },
  ],
  formulas: [
    { latex: '\\sigma = \\frac{P}{A}', label: 'Axial Stress', page: 'p. 130' },
    { latex: '\\delta = \\frac{PL}{AE}', label: 'Axial Deformation', page: 'p. 130' },
    { latex: '\\tau = \\frac{Tc}{J}', label: 'Torsional Shear', page: 'p. 133' },
    { latex: '\\sigma = \\frac{Mc}{I}', label: 'Flexural Stress', page: 'p. 135' },
    { latex: '\\tau = \\frac{VQ}{Ib}', label: 'Transverse Shear', page: 'p. 135' },
    { latex: '\\delta_{max} = \\frac{PL^3}{48EI}', label: 'Simply Supported Beam (midpoint load)', page: 'p. 140' },
    { latex: '\\sigma_{1,2} = \\frac{\\sigma_x+\\sigma_y}{2}\\pm\\sqrt{\\left(\\frac{\\sigma_x-\\sigma_y}{2}\\right)^2+\\tau_{xy}^2}', label: 'Principal Stresses', page: 'p. 131' },
    { latex: 'P_{cr} = \\frac{\\pi^2 EI}{(KL)^2}', label: "Euler's Buckling Load", page: 'p. 136' },
  ],
  traps: [
    'Using diameter instead of radius for c in \u03C3 = Mc/I and \u03C4 = Tc/J \u2014 c is the distance from the neutral axis.',
    'Forgetting to use the effective length factor K in Euler\'s buckling formula \u2014 K depends on end conditions.',
    'Sign errors in shear/moment diagrams \u2014 remember V = dM/dx and the relationship between loading and shear.',
    'Using I (area moment) instead of J (polar moment) for torsion problems, or vice versa.',
    'Not checking units \u2014 mixing MPa and kPa, or mm and m, is the #1 source of wrong answers.',
  ],
};
