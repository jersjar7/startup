export default {
  context: 'This chapter tests structural analysis, load combinations, and the design of reinforced concrete and steel members.',
  subtopics: [
    { id: 'analysis-loads', name: 'Analysis & Load Combinations',
      application: 'As a civil engineer, you classify structures as determinate or indeterminate, compute influence lines for moving loads, and apply ASCE 7 load combinations to size every member. Getting the loads right is the first step — the rest of the design follows from the controlling factored demand.' },
    { id: 'rc-design', name: 'Reinforced Concrete Design',
      application: 'As a civil engineer, you design reinforced concrete beams, columns, slabs, and footings on most building and infrastructure projects. You compute required flexural reinforcement using the Whitney stress block, check shear capacity and add stirrups when needed, and verify that columns can carry the factored axial load.' },
    { id: 'steel-design', name: 'Steel Design',
      application: 'As a civil engineer, steel design means selecting W-shapes from the AISC manual to resist the required loads. You check beams for flexure and lateral-torsional buckling, columns for axial capacity and slenderness, and tension members for yielding and rupture on the net section.' },
  ],
  formulas: [
    { latex: 'r + m \\geq 2j', label: 'Truss Stability/Determinacy', page: 'p. 271' },
    { latex: '1.2D + 1.6L', label: 'LRFD Basic Combination', page: 'p. 272' },
    { latex: 'M_n = A_s f_y (d - a/2)', label: 'RC Beam Moment Capacity', page: 'p. 275' },
    { latex: 'a = \\frac{A_s f_y}{0.85 f_c\' b}', label: 'Whitney Stress Block Depth', page: 'p. 275' },
    { latex: 'V_c = 2\\lambda\\sqrt{f_c\'} \\cdot b_w \\cdot d', label: 'Concrete Shear Capacity', page: 'p. 276' },
    { latex: '\\phi P_{n(\\max)} = 0.80\\phi[0.85 f_c\'(A_g - A_{st}) + f_y A_{st}]', label: 'RC Column Max Capacity', page: 'p. 278' },
    { latex: 'M_p = F_y Z_x', label: 'Steel Plastic Moment', page: 'p. 281' },
    { latex: '\\phi_c P_n = \\phi_c F_{cr} A_g', label: 'Steel Column Strength', page: 'p. 288' },
    { latex: 'P_n = F_y A_g \\text{ (yield)}, \\quad P_n = F_u A_e \\text{ (rupture)}', label: 'Steel Tension Members', page: 'p. 283' },
  ],
  traps: [
    'Using ASD factors when the problem asks for LRFD, or vice versa — read the load combination method carefully.',
    'Forgetting that d (effective depth) is NOT the same as the total beam height h — d = h minus cover minus bar offset.',
    'Using Zx (plastic section modulus) vs. Sx (elastic section modulus) — LRFD steel uses Zx, ASD uses Sx.',
    'Not checking all ASCE 7 load combinations — the controlling case often is not the one with the largest single load.',
    'Picking the LARGER capacity as the controlling limit state — the SMALLER design strength governs because it represents the weaker failure mode.',
  ],
};
