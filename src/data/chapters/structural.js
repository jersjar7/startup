export default {
  context: 'This chapter tests structural analysis, load combinations, and the design of reinforced concrete and steel members.',
  subtopics: [
    { id: 'determinate-analysis', name: 'Analysis of Determinate Structures' },
    { id: 'deflection',           name: 'Deflection of Beams, Trusses & Frames' },
    { id: 'determinacy-stability', name: 'Determinacy & Stability Analysis' },
    { id: 'loads-paths',          name: 'Loads & Load Paths' },
    { id: 'load-combinations',    name: 'Load Combinations (ASD & LRFD)' },
    { id: 'influence-lines',      name: 'Influence Lines' },
    { id: 'rc-design',            name: 'Reinforced Concrete Design' },
    { id: 'steel-design',         name: 'Steel Design' },
  ],
  formulas: [
    { latex: 'M_n = A_s f_y (d - a/2)', label: 'RC Beam Moment Capacity', page: 'p. 143' },
    { latex: 'a = \\frac{A_s f_y}{0.85 f_c\' b}', label: 'Whitney Stress Block Depth', page: 'p. 143' },
    { latex: 'V_c = 2\\sqrt{f_c\'} \\cdot b_w \\cdot d', label: 'Concrete Shear Capacity', page: 'p. 144' },
    { latex: 'M_p = F_y Z_x', label: 'Steel Plastic Moment', page: 'p. 148' },
    { latex: '1.2D + 1.6L', label: 'LRFD Basic Combination', page: 'p. 136' },
    { latex: 'r + m \\geq 2j \\implies \\text{stable}', label: 'Truss Stability Check', page: 'p. 137' },
  ],
  traps: [
    'Using ASD factors when the problem asks for LRFD, or vice versa — read the load combination method carefully.',
    'Forgetting that d (effective depth) is NOT the same as the total beam height h — d = h − cover − bar offset.',
    'In influence lines, the ordinate at the point of interest equals 1 for reactions and shear, not the maximum load.',
    'Using Zx (plastic section modulus) vs. Sx (elastic section modulus) — LRFD steel uses Zx, ASD uses Sx.',
    'Not checking all ASCE 7 load combinations — the controlling case often isn\'t the one with the largest single load.',
  ],
};
