export default {
  context: 'This chapter tests internal forces, stress-strain analysis, deformations, and stability of structural members.',
  subtopics: [
    { id: 'shear-moment',         name: 'Shear & Moment Diagrams' },
    { id: 'stresses-strains',     name: 'Stresses & Strains (Axial, Torsion, Bending, Shear)' },
    { id: 'stress-strain-diagram', name: 'Stress-Strain Diagrams & Material Behavior' },
    { id: 'deformations',         name: 'Deformations (Axial, Torsion, Beam Deflection)' },
    { id: 'combined-stress',      name: 'Combined Stresses & Principal Stresses' },
    { id: 'mohrs-circle',         name: "Mohr's Circle" },
    { id: 'column-buckling',      name: 'Column Buckling (Euler\'s Formula)' },
    { id: 'indeterminate',        name: 'Statically Indeterminate Members' },
  ],
  formulas: [
    { latex: '\\sigma = \\frac{P}{A}', label: 'Axial Stress', page: 'p. 72' },
    { latex: '\\sigma = \\frac{Mc}{I}', label: 'Flexural Stress', page: 'p. 75' },
    { latex: '\\tau = \\frac{Tc}{J}', label: 'Torsional Shear', page: 'p. 73' },
    { latex: '\\tau = \\frac{VQ}{Ib}', label: 'Transverse Shear', page: 'p. 75' },
    { latex: '\\delta = \\frac{PL}{AE}', label: 'Axial Deformation', page: 'p. 72' },
    { latex: 'P_{cr} = \\frac{\\pi^2 EI}{(KL)^2}', label: "Euler's Buckling Load", page: 'p. 77' },
    { latex: '\\sigma_{1,2} = \\frac{\\sigma_x+\\sigma_y}{2}\\pm\\sqrt{\\left(\\frac{\\sigma_x-\\sigma_y}{2}\\right)^2+\\tau_{xy}^2}', label: 'Principal Stresses', page: 'p. 76' },
  ],
  traps: [
    'Using diameter instead of radius for c in σ = Mc/I and τ = Tc/J — c is the distance from the neutral axis.',
    'Forgetting to use the effective length factor K in Euler\'s buckling formula — K depends on end conditions.',
    'Sign errors in shear/moment diagrams — remember V = dM/dx and the relationship between loading and shear.',
    'Using I (area moment) instead of J (polar moment) for torsion problems, or vice versa.',
    'Not checking units — mixing MPa and kPa, or mm and m, is the #1 source of wrong answers.',
  ],
};
