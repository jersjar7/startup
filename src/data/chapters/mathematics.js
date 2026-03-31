export default {
  context: 'This chapter tests your ability to apply calculus, linear algebra, and differential equations to engineering problems.',
  subtopics: [
    { id: 'analytic-geometry',    name: 'Analytic Geometry & Trigonometry' },
    { id: 'single-var-calc',      name: 'Single-Variable Calculus' },
    { id: 'multivariable-calc',   name: 'Multivariable Calculus' },
    { id: 'diff-equations',       name: 'Differential Equations' },
    { id: 'vector-operations',    name: 'Vector Operations' },
    { id: 'matrix-algebra',       name: 'Matrix & Linear Algebra' },
  ],
  formulas: [
    { latex: '\\frac{d}{dx}[f(g(x))] = f\'(g(x))\\cdot g\'(x)', label: 'Chain Rule', page: 'p. 27' },
    { latex: '\\int u\\,dv = uv - \\int v\\,du', label: 'Integration by Parts', page: 'p. 28' },
    { latex: '\\det(A) = a_{11}(a_{22}a_{33} - a_{23}a_{32}) - \\ldots', label: 'Determinant (3×3)', page: 'p. 33' },
    { latex: 'y\'\' + by\' + cy = 0 \\implies r^2 + br + c = 0', label: 'Characteristic Equation', page: 'p. 30' },
    { latex: '\\vec{A}\\cdot\\vec{B} = |A||B|\\cos\\theta', label: 'Dot Product', page: 'p. 26' },
    { latex: '\\vec{A}\\times\\vec{B} = |A||B|\\sin\\theta\\,\\hat{n}', label: 'Cross Product', page: 'p. 26' },
  ],
  traps: [
    'Forgetting the chain rule when differentiating composite functions — the FE loves nested trig/exponential combos.',
    'Mixing up dot product (scalar result) and cross product (vector result) — check what the question asks for.',
    'Using the wrong integration limits or forgetting to change limits when doing u-substitution.',
    'Sign errors in determinant expansion — practice the cofactor pattern methodically.',
    'Confusing homogeneous vs. non-homogeneous differential equation solution forms.',
  ],
};
