// Exam bank: statics
// Auto-extracted from lesson files — 24 questions

const PROBLEMS = [
  {
    id: 'stat-fsr-ex1',
    type: 'computational',
    statement: 'A guy wire anchoring a utility pole exerts a 2,600 N force directed along a line that runs 5 m horizontally and 12 m vertically. What is the horizontal component of the force?',
    choices: [
      {
        id: 'c1',
        text: '500 N'
      },
      {
        id: 'c2',
        text: '2,400 N'
      },
      {
        id: 'c3',
        text: '1,300 N'
      },
      {
        id: 'c4',
        text: '1,000 N'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'When a force direction is given by geometry (rise and run), use the geometry-based resolution: find the hypotenuse $R = \\sqrt{5^2 + 12^2} = 13$ m, then $F_x = (5/13) \\times 2{,}600 = 1{,}000$ N. This is a 5-12-13 right triangle, which the FE loves. Choice B uses the vertical leg ratio ($12/13 \\times 2{,}600 = 2{,}400$), which gives the vertical component instead. Choice C just halves the force. Choice A divides the horizontal run by something unrelated.',
    hint: 'The 5-12-13 triangle is a common Pythagorean triple. Use $F_x = (x/R) \\times F$.',
    steps: [
      {
        text: 'Find the hypotenuse:',
        latex: 'R = \\sqrt{5^2 + 12^2} = \\sqrt{169} = 13\\,\\text{m}'
      },
      {
        text: 'Horizontal component:',
        latex: 'F_x = \\frac{5}{13} \\times 2{,}600 = 1{,}000\\,\\text{N}'
      },
      {
        text: 'Choice B gives the vertical component: $F_y = (12/13) \\times 2{,}600 = 2{,}400$ N. Read the question carefully to report the correct component.',
        latex: null
      }
    ],
    handbookPage: 'p. 94',
    handbookFormula: 'F_x = \\frac{x}{R}\\,F',
    videoUrl: null,
    traps: [
      'Swapping the horizontal and vertical legs — the horizontal leg goes with the horizontal component',
      'Failing to recognize the 5-12-13 triangle and wasting time computing the hypotenuse'
    ],
    diagram: null,
    lessonId: 'force-systems-resultants',
    chapterId: 'statics'
  },
  {
    id: 'stat-fsr-ex2',
    type: 'computational',
    statement: 'Two forces act at a gusset plate connection: $F_1 = 300$ N directed horizontally to the right, and $F_2 = 400$ N directed vertically upward. What is the magnitude and direction of the resultant force?',
    choices: [
      {
        id: 'c1',
        text: '$500$ N at $53.1\\degree$ from the horizontal'
      },
      {
        id: 'c2',
        text: '$700$ N at $45\\degree$ from the horizontal'
      },
      {
        id: 'c3',
        text: '$500$ N at $36.9\\degree$ from the horizontal'
      },
      {
        id: 'c4',
        text: '$350$ N at $53.1\\degree$ from the horizontal'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'This is a 3-4-5 triangle in disguise. $R_x = 300$ N, $R_y = 400$ N. The resultant magnitude is $R = \\sqrt{300^2 + 400^2} = \\sqrt{250{,}000} = 500$ N. The angle is $\\theta = \\arctan(400/300) = \\arctan(1.333) = 53.1\\degree$ from the horizontal. Choice B adds the magnitudes directly ($300 + 400 = 700$) — you cannot add non-collinear forces by simple addition. Choice C gets the magnitude right but uses $\\arctan(300/400) = 36.9\\degree$, which is the angle from the vertical, not the horizontal. Choice D averages the forces and gets the direction right.',
    hint: 'This is a familiar Pythagorean triple. The angle is measured from the x-axis using $\\arctan(R_y/R_x)$.',
    steps: [
      {
        text: 'Sum the components:',
        latex: 'R_x = 300\\,\\text{N},\\quad R_y = 400\\,\\text{N}'
      },
      {
        text: 'Resultant magnitude:',
        latex: 'R = \\sqrt{300^2 + 400^2} = \\sqrt{90{,}000 + 160{,}000} = \\sqrt{250{,}000} = 500\\,\\text{N}'
      },
      {
        text: 'Direction:',
        latex: '\\theta = \\arctan\\!\\left(\\frac{400}{300}\\right) = \\arctan(1.333) = 53.1\\degree\\text{ from horizontal}'
      },
      {
        text: 'Choice C uses $\\arctan(300/400) = 36.9\\degree$, which is the complement — the angle from the vertical axis, not the horizontal.',
        latex: null
      }
    ],
    handbookPage: 'p. 94',
    handbookFormula: 'R = \\sqrt{R_x^2 + R_y^2}',
    videoUrl: null,
    traps: [
      'Adding force magnitudes directly instead of using vector addition',
      'Swapping the numerator and denominator in the arctan — $R_y/R_x$ gives the angle from the x-axis'
    ],
    diagram: null,
    lessonId: 'force-systems-resultants',
    chapterId: 'statics'
  },
  {
    id: 'stat-fsr-ex3',
    type: 'conceptual',
    statement: 'A couple consists of two 50 N forces separated by 2 m. If the couple is moved to a different location on the same rigid body without changing the force magnitudes or their separation distance, the moment of the couple about any point will:',
    choices: [
      {
        id: 'c1',
        text: 'Change depending on the new location'
      },
      {
        id: 'c2',
        text: 'Remain exactly 100 N$\\cdot$m'
      },
      {
        id: 'c3',
        text: 'Become zero because it moved away from the original point'
      },
      {
        id: 'c4',
        text: 'Double because it now acts at a greater distance from the reference point'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'A couple is a free vector — its moment is the same about any point on the body. The moment equals $F \\times d = 50 \\times 2 = 100$ N$\\cdot$m, and it does not depend on where the couple is placed or which reference point you choose. This is a defining property of couples that separates them from single forces. Choice A treats the couple like a single force (whose moment depends on the reference point). Choice C confuses a couple with a force that must pass through a point. Choice D has no physical basis.',
    hint: 'A couple is a special case in statics — its moment is independent of the reference point.',
    steps: [
      {
        text: 'A couple consists of two equal, opposite, parallel forces.',
        latex: null
      },
      {
        text: 'The moment of a couple:',
        latex: 'M = F \\times d = 50 \\times 2 = 100\\,\\text{N}\\cdot\\text{m}'
      },
      {
        text: 'Key property: the moment of a couple is the same about every point. It is a free vector — it can be moved anywhere on the body without changing its effect.',
        latex: null
      }
    ],
    handbookPage: 'p. 94',
    handbookFormula: 'M = Fd',
    videoUrl: null,
    traps: [
      'Thinking a couple\'s moment depends on the reference point like a single force does'
    ],
    diagram: null,
    lessonId: 'force-systems-resultants',
    chapterId: 'statics'
  },
  {
    id: 'stat-fsr-ex4',
    type: 'computational',
    statement: 'A beam extends 4 m horizontally from a wall. A 600 N downward force acts at the free end, and a 200 N upward force acts at the midpoint (2 m from the wall). What is the net moment about the wall support?',
    choices: [
      {
        id: 'c1',
        text: '1,600 N$\\cdot$m clockwise'
      },
      {
        id: 'c2',
        text: '2,000 N$\\cdot$m clockwise'
      },
      {
        id: 'c3',
        text: '2,400 N$\\cdot$m clockwise'
      },
      {
        id: 'c4',
        text: '800 N$\\cdot$m counterclockwise'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Two forces create moments about the wall. The 600 N downward force at 4 m produces a clockwise moment of $600 \\times 4 = 2{,}400$ N$\\cdot$m. The 200 N upward force at 2 m opposes it with a counterclockwise moment of $200 \\times 2 = 400$ N$\\cdot$m. The net moment is $2{,}400 - 400 = 2{,}000$ N$\\cdot$m clockwise. Choice A (1,600) incorrectly subtracts the force magnitudes first ($600 - 200 = 400$) then multiplies by 4 m. Choice C (2,400) only counts the 600 N force and ignores the upward force entirely. Choice D (800) subtracts the magnitudes wrong and flips the direction.',
    hint: 'Compute each moment separately (force times its distance from the wall), determine each direction (CW or CCW), then combine with the correct signs.',
    steps: [
      {
        text: 'Moment from the 600 N downward force at the free end (4 m from wall):',
        latex: 'M_1 = 600 \\times 4 = 2{,}400\\,\\text{N}\\cdot\\text{m (CW)}'
      },
      {
        text: 'Moment from the 200 N upward force at midpoint (2 m from wall):',
        latex: 'M_2 = 200 \\times 2 = 400\\,\\text{N}\\cdot\\text{m (CCW)}'
      },
      {
        text: 'Net moment (taking CW as positive):',
        latex: 'M_{net} = 2{,}400 - 400 = 2{,}000\\,\\text{N}\\cdot\\text{m (CW)}'
      }
    ],
    handbookPage: 'p. 94',
    handbookFormula: 'M_O = \\sum (F \\times d)',
    videoUrl: null,
    traps: [
      'Only counting the larger force and ignoring the 200 N upward force (gives 2,400 instead of 2,000)',
      'Subtracting force magnitudes before multiplying by distance instead of computing each moment separately'
    ],
    diagram: null,
    lessonId: 'force-systems-resultants',
    chapterId: 'statics'
  },
  {
    id: 'stat-efb-ex1',
    type: 'computational',
    statement: 'A simply supported beam spans 6 m with a pin at A (left) and a roller at B (right). A single 18 kN downward load acts at 2 m from A. What is the vertical reaction at A?',
    choices: [
      {
        id: 'c1',
        text: '18.0 kN'
      },
      {
        id: 'c2',
        text: '6.0 kN'
      },
      {
        id: 'c3',
        text: '9.0 kN'
      },
      {
        id: 'c4',
        text: '12.0 kN'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'Sum moments about B to eliminate the reaction at B. The 18 kN load is 4 m from B, and $A_y$ is 6 m from B. So $A_y \\times 6 = 18 \\times 4$, giving $A_y = 12$ kN. Answer B (6 kN) is the reaction at B, not A -- a classic trap of solving correctly but reporting the wrong support. Answer C (9 kN) splits the load evenly, which only works when the load is at midspan. Answer A puts the full load on one support.',
    hint: 'Sum moments about B so the unknown $B_y$ drops out. Make sure you report $A_y$, not $B_y$.',
    steps: [
      {
        text: 'FBD: pin at A ($A_x$, $A_y$), roller at B ($B_y$), 18 kN at 2 m from A (4 m from B).',
        latex: null
      },
      {
        text: 'Sum moments about B (eliminates $B_y$):',
        latex: '\\sum M_B = 0: \\quad A_y(6) - 18(4) = 0'
      },
      {
        text: 'Solve:',
        latex: 'A_y = \\frac{72}{6} = 12.0 \\text{ kN}'
      },
      {
        text: 'Check: $B_y = 18 - 12 = 6$ kN. Answer B is the reaction at B, not A.',
        latex: null
      }
    ],
    handbookPage: 'p. 94, Equilibrium Requirements',
    handbookFormula: '\\sum F_n = 0 \\quad \\sum M_n = 0',
    videoUrl: null,
    traps: [
      'Reporting the reaction at B instead of A',
      'Splitting the load equally between supports when the load is not at midspan'
    ],
    diagram: null,
    lessonId: 'equilibrium-free-body-diagrams',
    chapterId: 'statics'
  },
  {
    id: 'stat-efb-ex2',
    type: 'computational',
    statement: 'A simply supported beam AB is 12 m long (pin at A, roller at B). It carries a uniformly distributed load of 5 kN/m over the left half (from A to the midpoint at 6 m). What is the vertical reaction at B?',
    choices: [
      {
        id: 'c1',
        text: '7.5 kN'
      },
      {
        id: 'c2',
        text: '15.0 kN'
      },
      {
        id: 'c3',
        text: '22.5 kN'
      },
      {
        id: 'c4',
        text: '30.0 kN'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Replace the partial UDL with its resultant: $5 \\times 6 = 30$ kN acting at the centroid of the loaded region, which is 3 m from A. Sum moments about A: $B_y \\times 12 = 30 \\times 3$, so $B_y = 7.5$ kN. Answer B (15 kN) splits the total load in half, as if it were centered. Answer C (22.5 kN) is the reaction at A. Answer D (30 kN) puts the entire load on one support.',
    hint: 'Replace the distributed load with its resultant at the centroid of the loaded region (not the centroid of the entire beam).',
    steps: [
      {
        text: 'Resultant of the UDL:',
        latex: 'W = 5 \\times 6 = 30 \\text{ kN, acting at } \\bar{x} = 3 \\text{ m from A}'
      },
      {
        text: 'Sum moments about A:',
        latex: '\\sum M_A = 0: \\quad B_y(12) - 30(3) = 0'
      },
      {
        text: 'Solve:',
        latex: 'B_y = \\frac{90}{12} = 7.5 \\text{ kN}'
      },
      {
        text: 'Check: $A_y = 30 - 7.5 = 22.5$ kN. The load is closer to A, so A carries more -- consistent.',
        latex: null
      }
    ],
    handbookPage: 'p. 94, Equilibrium Requirements',
    handbookFormula: '\\sum F_n = 0 \\quad \\sum M_n = 0',
    videoUrl: null,
    traps: [
      'Placing the resultant at the midpoint of the beam instead of at the centroid of the loaded portion',
      'Splitting the total load evenly between both supports'
    ],
    diagram: null,
    lessonId: 'equilibrium-free-body-diagrams',
    chapterId: 'statics'
  },
  {
    id: 'stat-efb-ex3',
    type: 'computational',
    statement: 'A cantilever beam is 5 m long with a fixed support at the left end. It carries a triangular distributed load that varies linearly from 0 at the fixed end to 8 kN/m at the free end. What is the fixed-end moment reaction?',
    choices: [
      {
        id: 'c1',
        text: '20.0 kN\\cdot m'
      },
      {
        id: 'c2',
        text: '40.0 kN\\cdot m'
      },
      {
        id: 'c3',
        text: '66.7 kN\\cdot m'
      },
      {
        id: 'c4',
        text: '100.0 kN\\cdot m'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'A triangular load has a resultant equal to half the base times the peak intensity: $W = \\frac{1}{2}(5)(8) = 20$ kN. The centroid of a triangle is at one-third from the wide end, which is $5 - 5/3 = 10/3$ m from the fixed end. The moment is $M = 20 \\times 10/3 = 66.7$ kN-m. Answer B (40 kN-m) places the resultant at the midpoint ($20 \\times 2 = 40$) instead of at the one-third point. Answer A (20 kN-m) places the resultant at 1 m from the support. Answer D (100 kN-m) treats the load as uniform at 8 kN/m over 5 m ($40 \\times 2.5 = 100$).',
    hint: 'The resultant of a triangular load is $\\frac{1}{2} \\times L \\times w_{max}$, and it acts at the centroid of the triangle (one-third from the wide end).',
    steps: [
      {
        text: 'Resultant of the triangular load:',
        latex: 'W = \\frac{1}{2}(5)(8) = 20 \\text{ kN}'
      },
      {
        text: 'Centroid location: one-third from the wide end (free tip), so two-thirds from the narrow end (support):',
        latex: '\\bar{x} = \\frac{2}{3}(5) = \\frac{10}{3} \\text{ m from the fixed end}'
      },
      {
        text: 'Fixed-end moment (moment equilibrium about the support):',
        latex: 'M = W \\times \\bar{x} = 20 \\times \\frac{10}{3} = 66.7 \\text{ kN}{\\cdot}\\text{m}'
      },
      {
        text: 'Answer B (40 kN-m) uses the midpoint (2.5 m) as the centroid: $20 \\times 2 = 40$. Triangular load centroids are at the one-third point, not the midpoint.',
        latex: null
      }
    ],
    handbookPage: 'p. 94, Equilibrium Requirements; p. 95, Centroids',
    handbookFormula: '\\sum M_n = 0',
    videoUrl: null,
    traps: [
      'Using the midpoint instead of the one-third point for the centroid of a triangular load',
      'Treating the triangular load as uniform at the peak intensity'
    ],
    diagram: null,
    lessonId: 'equilibrium-free-body-diagrams',
    chapterId: 'statics'
  },
  {
    id: 'stat-efb-ex4',
    type: 'conceptual',
    statement: 'A 2D rigid body is supported by a pin and a roller. How many independent scalar equilibrium equations are available, and how many unknown reaction components can be solved?',
    choices: [
      {
        id: 'c1',
        text: '2 equations, 2 unknowns'
      },
      {
        id: 'c2',
        text: '3 equations, 3 unknowns'
      },
      {
        id: 'c3',
        text: '3 equations, 2 unknowns'
      },
      {
        id: 'c4',
        text: '6 equations, 6 unknowns'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'In 2D statics, there are exactly three independent equilibrium equations: $\\sum F_x = 0$, $\\sum F_y = 0$, and $\\sum M = 0$. A pin provides two reaction components ($R_x$, $R_y$) and a roller provides one ($R_\\perp$), giving three unknowns total. Three equations and three unknowns means the system is statically determinate. Answer A forgets the moment equation. Answer C has the right equation count but undercounts unknowns (a pin alone has two). Answer D applies to 3D equilibrium, not 2D.',
    hint: 'Count the equations from 2D equilibrium and the unknowns from the support types: a pin gives 2 reactions, a roller gives 1.',
    steps: [
      {
        text: '2D equilibrium provides three independent scalar equations:',
        latex: '\\sum F_x = 0, \\quad \\sum F_y = 0, \\quad \\sum M = 0'
      },
      {
        text: 'A pin support provides two reaction components ($R_x$ and $R_y$). A roller provides one reaction component (perpendicular to the rolling surface).',
        latex: null
      },
      {
        text: 'Total unknowns: $2 + 1 = 3$. Three equations and three unknowns means the structure is statically determinate.',
        latex: null
      },
      {
        text: 'If there were more unknowns than equations, the structure would be statically indeterminate and you would need compatibility equations from Mechanics of Materials.',
        latex: null
      }
    ],
    handbookPage: 'p. 94, Equilibrium Requirements',
    handbookFormula: '\\sum F_n = 0 \\quad \\sum M_n = 0',
    videoUrl: null,
    traps: [
      'Forgetting the moment equation and counting only two equilibrium equations',
      'Confusing 2D equilibrium (3 equations) with 3D equilibrium (6 equations)'
    ],
    diagram: null,
    lessonId: 'equilibrium-free-body-diagrams',
    chapterId: 'statics'
  },
  {
    id: 'stat-tjs-ex1',
    type: 'computational',
    statement: 'A simple triangular truss has joints at A (left, pin support), B (right, roller support), and C (top). The horizontal span AB is 8 m and C is 3 m above the midpoint of AB. A 24 kN downward load acts at C. By symmetry, each support reaction is 12 kN. Using the method of joints at joint A, what is the force in member AB?',
    choices: [
      {
        id: 'c1',
        text: '24.0 kN, tension'
      },
      {
        id: 'c2',
        text: '12.0 kN, tension'
      },
      {
        id: 'c3',
        text: '20.0 kN, compression'
      },
      {
        id: 'c4',
        text: '16.0 kN, tension'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'At joint A, the pin reaction is 12 kN upward. Member AC goes from A(0,0) to C(4,3), so its direction cosines are $(4/5, 3/5)$. From $\\sum F_y = 0$: $12 + F_{AC}(3/5) = 0$, so $F_{AC} = -20$ kN (compression). Then from $\\sum F_x = 0$: $F_{AB} + F_{AC}(4/5) = 0$, giving $F_{AB} = -(-20)(4/5) = 16$ kN (tension). Answer B (12 kN) confuses the support reaction with the member force. Answer C (20 kN compression) is actually the force in member AC, not AB. Answer A (24 kN) is the total load, not a member force.',
    hint: 'At joint A, find the force in AC first using $\\sum F_y = 0$, then use $\\sum F_x = 0$ to find the force in AB.',
    steps: [
      {
        text: 'By symmetry, $A_y = B_y = 12$ kN. Member AC: A(0,0) to C(4,3), length = 5, direction cosines $(4/5, 3/5)$.',
        latex: null
      },
      {
        text: 'At joint A, $\\sum F_y = 0$ (assume tension, pulling away from A):',
        latex: '12 + F_{AC}\\left(\\frac{3}{5}\\right) = 0 \\quad \\Rightarrow \\quad F_{AC} = -20 \\text{ kN (compression)}'
      },
      {
        text: '$\\sum F_x = 0$:',
        latex: 'F_{AB} + F_{AC}\\left(\\frac{4}{5}\\right) = 0 \\quad \\Rightarrow \\quad F_{AB} + (-20)\\left(\\frac{4}{5}\\right) = 0'
      },
      {
        text: 'Solve:',
        latex: 'F_{AB} = 16.0 \\text{ kN (tension)}'
      }
    ],
    handbookPage: 'p. 97, Plane Truss: Method of Joints',
    handbookFormula: '\\sum F_H = 0 \\quad \\sum F_V = 0',
    videoUrl: null,
    traps: [
      'Reporting the reaction (12 kN) as the member force in AB',
      'Confusing the force in AC (20 kN) with the force in AB (16 kN)'
    ],
    diagram: null,
    lessonId: 'trusses-joints-sections',
    chapterId: 'statics'
  },
  {
    id: 'stat-tjs-ex2',
    type: 'computational',
    statement: 'A Pratt truss has four equal panels of 4 m each (total span 16 m) and a height of 3 m. It is simply supported with a pin at the left and a roller at the right. A single 36 kN downward load is applied at the second bottom chord joint (8 m from the left). Using the method of sections, cut through the truss and determine the force in the top chord member directly above the loaded joint.',
    choices: [
      {
        id: 'c1',
        text: '24.0 kN, compression'
      },
      {
        id: 'c2',
        text: '18.0 kN, compression'
      },
      {
        id: 'c3',
        text: '36.0 kN, compression'
      },
      {
        id: 'c4',
        text: '24.0 kN, tension'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'First find reactions: $\\sum M_A = 0$ gives $R_B = 36(8)/16 = 18$ kN, and $R_A = 18$ kN. Cut through the panel just to the right of the load. On the left portion, sum moments about the bottom chord joint at the cut (12 m from A) to isolate the top chord force. $R_A(12) - 36(4) = F_{top}(3)$, so $F_{top} = (216 - 144)/3 = 24$ kN. Since we assumed tension and got positive, but the top chord must push inward -- actually, checking the sign convention: $\\sum M = 0$ about the bottom joint at 12 m: $18(12) - 36(4) + F_{top}(3) = 0$, so $F_{top} = -(216-144)/3 = -24$ kN, meaning compression. Answer B (18 kN) is the support reaction. Answer D gets the magnitude right but the wrong sense (tension vs. compression).',
    hint: 'Cut through the truss and sum moments about the bottom chord joint at the cut location to isolate the top chord force.',
    steps: [
      {
        text: 'Find reactions by symmetry of geometry (load at midspan):',
        latex: 'R_A = R_B = \\frac{36}{2} = 18 \\text{ kN}'
      },
      {
        text: 'Cut through the panel between 8 m and 12 m (cuts top chord, diagonal, and bottom chord). Analyze the left portion.',
        latex: null
      },
      {
        text: 'Sum moments about the bottom chord joint at 12 m (eliminates bottom chord and diagonal forces):',
        latex: '\\sum M = 0: \\quad 18(12) - 36(4) + F_{top}(3) = 0'
      },
      {
        text: 'Solve:',
        latex: 'F_{top} = \\frac{-(216 - 144)}{3} = \\frac{-72}{3} = -24 \\text{ kN}'
      },
      {
        text: 'Negative with tension assumption means compression: $F_{top} = 24.0$ kN (C).',
        latex: null
      }
    ],
    handbookPage: 'p. 97, Plane Truss: Method of Sections',
    handbookFormula: '\\sum F_H = 0 \\quad \\sum F_V = 0 \\quad \\sum M = 0',
    videoUrl: null,
    traps: [
      'Confusing a support reaction with a member force',
      'Getting the correct magnitude but wrong sense (tension vs. compression) -- top chords in a loaded truss are typically in compression'
    ],
    diagram: null,
    lessonId: 'trusses-joints-sections',
    chapterId: 'statics'
  },
  {
    id: 'stat-tjs-ex3',
    type: 'computational',
    statement: 'A Pratt truss spans 12 m with three equal 4 m panels and a height of 3 m. It is simply supported (pin at A, roller at D). Bottom joints: A (0 m), B (4 m), C (8 m), D (12 m). Top joints: E (above B), F (above C). Vertical members connect B-E and C-F. A single 36 kN downward load acts at joint E. Using the method of sections, what is the force in diagonal member BF?',
    choices: [
      {
        id: 'c1',
        text: '16.0 kN, tension'
      },
      {
        id: 'c2',
        text: '20.0 kN, tension'
      },
      {
        id: 'c3',
        text: '20.0 kN, compression'
      },
      {
        id: 'c4',
        text: '12.0 kN, tension'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Find reactions: $\\sum M_A = 0$ gives $R_D = 36(4)/12 = 12$ kN, so $R_A = 24$ kN. Cut through EF, BF, and BC, then take the right portion (joints C, D, F) which has only $R_D = 12$ kN upward. Member BF goes from B(4,0) to F(8,3), so its length is 5 and its vertical direction cosine is $3/5$. Vertical equilibrium: $12 - F_{BF}(3/5) = 0$, giving $F_{BF} = 20$ kN in tension. Answer A (16 kN) miscalculates the reaction or the direction cosine. Answer C (20 kN compression) gets the magnitude right but the wrong sense -- the diagonal in this panel resists the vertical shear by pulling, not pushing. Answer D (12 kN) confuses the support reaction with the member force.',
    hint: 'Cut through EF, BF, and BC. Take the right portion with only one external force. Use $\\sum F_y = 0$ to isolate the diagonal.',
    steps: [
      {
        text: 'Find reactions:',
        latex: '\\sum M_A = 0: \\quad 36(4) = R_D(12) \\quad \\Rightarrow \\quad R_D = 12 \\text{ kN}, \\quad R_A = 24 \\text{ kN}'
      },
      {
        text: 'Cut through EF, BF, and BC. Take the right portion (joints C, D, F). Only external force: $R_D = 12$ kN upward.',
        latex: null
      },
      {
        text: 'Member BF runs from B(4,0) to F(8,3). Length = 5. Direction cosines: $(4/5,\\, 3/5)$. Vertical equilibrium on the right portion (assume BF tension):',
        latex: '\\sum F_y = 0: \\quad 12 - F_{BF}\\left(\\frac{3}{5}\\right) = 0'
      },
      {
        text: 'Solve:',
        latex: 'F_{BF} = \\frac{12}{3/5} = 20.0 \\text{ kN (tension)}'
      },
      {
        text: 'Positive result confirms our tension assumption. The diagonal BF is in tension.',
        latex: null
      }
    ],
    handbookPage: 'p. 97, Plane Truss: Method of Sections',
    handbookFormula: '\\sum F_H = 0 \\quad \\sum F_V = 0 \\quad \\sum M = 0',
    videoUrl: null,
    traps: [
      'Using the wrong side of the cut -- the right side has only one external force, making it simpler',
      'Forgetting to resolve the diagonal force into components before applying equilibrium'
    ],
    diagram: null,
    lessonId: 'trusses-joints-sections',
    chapterId: 'statics'
  },
  {
    id: 'stat-tjs-ex4',
    type: 'conceptual',
    statement: 'A planar truss has 9 members, 6 joints, and is supported by a pin and a roller. Which statement is correct about this truss?',
    choices: [
      {
        id: 'c1',
        text: 'It is unstable'
      },
      {
        id: 'c2',
        text: 'It is statically indeterminate by one degree'
      },
      {
        id: 'c3',
        text: 'It is statically determinate ($m = 2j - r$)'
      },
      {
        id: 'c4',
        text: 'It is statically indeterminate by two degrees'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'The determinacy check for a 2D truss is $m + r = 2j$, where $m$ is the number of members, $r$ is the number of reaction components, and $j$ is the number of joints. A pin gives 2 reactions and a roller gives 1, so $r = 3$. Check: $9 + 3 = 12$ and $2(6) = 12$. Since $m + r = 2j$, the truss is statically determinate. If $m + r > 2j$, it would be indeterminate. If $m + r < 2j$, it would be unstable (or improperly constrained). Answer B would require $m + r = 13$ (one extra member or reaction). Answer A would require $m + r < 12$.',
    hint: 'Use $m + r = 2j$ for determinacy. Count reactions: a pin gives 2, a roller gives 1.',
    steps: [
      {
        text: 'Count: $m = 9$ members, $j = 6$ joints, pin + roller gives $r = 2 + 1 = 3$ reactions.',
        latex: null
      },
      {
        text: 'Apply the determinacy criterion:',
        latex: 'm + r = 9 + 3 = 12 \\qquad 2j = 2(6) = 12'
      },
      {
        text: 'Since $m + r = 2j$, the truss is statically determinate.',
        latex: null
      },
      {
        text: 'If $m + r > 2j$: indeterminate by $(m + r - 2j)$ degrees. If $m + r < 2j$: potentially unstable.',
        latex: null
      }
    ],
    handbookPage: 'p. 97, Statically Determinate Truss',
    handbookFormula: 'm + r = 2j',
    videoUrl: null,
    traps: [
      'Forgetting to count reaction components as part of the check',
      'Miscounting the support reactions -- a pin has 2 components, not 1'
    ],
    diagram: null,
    lessonId: 'trusses-joints-sections',
    chapterId: 'statics'
  },
  {
    id: 'stat-fri-ex1',
    type: 'computational',
    statement: 'A 300 N box sits on a flat surface with $\\mu_s = 0.35$. A horizontal pull of 80 N is applied. What is the friction force acting on the box?',
    choices: [
      {
        id: 'c1',
        text: '80 N'
      },
      {
        id: 'c2',
        text: '105 N'
      },
      {
        id: 'c3',
        text: '300 N'
      },
      {
        id: 'c4',
        text: '0 N'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'The maximum static friction is $\\mu_s N = 0.35 \\times 300 = 105$ N. The applied force is only 80 N, which is less than the maximum. Since the box is not on the verge of moving, friction matches the applied force exactly: $F = 80$ N. Answer B (105 N) is the maximum possible friction, but the box is not about to slide so friction does not reach that value. Answer C uses the full weight. Answer D incorrectly assumes no friction acts at all.',
    hint: 'Check whether the applied force exceeds $\\mu_s N$. If it does not, friction equals the applied force.',
    steps: [
      {
        text: 'Maximum static friction:',
        latex: 'F_{\\max} = \\mu_s N = 0.35 \\times 300 = 105 \\text{ N}'
      },
      {
        text: 'Applied force = 80 N < 105 N, so the box does not move.',
        latex: null
      },
      {
        text: 'When the box is stationary and below the slip threshold, friction equals the applied force:',
        latex: 'F_{\\text{friction}} = 80 \\text{ N}'
      }
    ],
    handbookPage: 'p. 96, Friction',
    handbookFormula: 'F \\leq \\mu_s N',
    videoUrl: null,
    traps: [
      'Using $\\mu_s N$ as the friction force when the object is not on the verge of sliding',
      'Assuming friction always equals the maximum value -- it only does at impending motion'
    ],
    diagram: null,
    lessonId: 'friction',
    chapterId: 'statics'
  },
  {
    id: 'stat-fri-ex2',
    type: 'computational',
    statement: 'A flat belt wraps 270 degrees around a fixed drum. The coefficient of friction is 0.25. If the tension on the slack side is 150 N, what is the maximum tension on the tight side before the belt slips? (Use $e^{1.18} = 3.25$.)',
    choices: [
      {
        id: 'c1',
        text: '263 N'
      },
      {
        id: 'c2',
        text: '487 N'
      },
      {
        id: 'c3',
        text: '188 N'
      },
      {
        id: 'c4',
        text: '150 N'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Belt friction uses the capstan equation: $F_1 = F_2 e^{\\mu\\theta}$. Convert 270 degrees to radians: $\\theta = 3\\pi/2 = 4.712$ rad. The exponent is $\\mu\\theta = 0.25 \\times 4.712 = 1.178$, and $e^{1.178} \\approx 3.25$. So $F_1 = 150 \\times 3.25 = 487$ N. Answer A (263 N) uses 90 degrees instead of 270 degrees for the wrap angle. Answer C (188 N) treats friction as a linear add-on ($150 + 0.25 \\times 150 = 187.5$). Answer D assumes no friction amplification at all.',
    hint: 'Convert the contact angle to radians (270 degrees = $3\\pi/2$), then apply the belt friction formula $F_1 = F_2 e^{\\mu\\theta}$.',
    steps: [
      {
        text: 'Identify: $F_2 = 150$ N (slack side), $\\mu = 0.25$, $\\theta = 270\\degree = \\frac{3\\pi}{2}$ radians.',
        latex: null
      },
      {
        text: 'Compute the exponent:',
        latex: '\\mu\\theta = 0.25 \\times \\frac{3\\pi}{2} = 0.25 \\times 4.712 = 1.178'
      },
      {
        text: 'Apply the belt friction formula:',
        latex: 'F_1 = 150 \\times e^{1.178} = 150 \\times 3.25 = 487 \\text{ N}'
      },
      {
        text: 'The exponential amplification is substantial: a 270-degree wrap with $\\mu = 0.25$ multiplies the slack-side tension by about 3.25 times.',
        latex: null
      }
    ],
    handbookPage: 'p. 96, Belt Friction',
    handbookFormula: 'F_1 = F_2\\, e^{\\mu\\theta}',
    videoUrl: null,
    traps: [
      'Using degrees instead of radians for the contact angle',
      'Adding friction linearly instead of using the exponential relationship'
    ],
    diagram: null,
    lessonId: 'friction',
    chapterId: 'statics'
  },
  {
    id: 'stat-fri-ex3',
    type: 'computational',
    statement: 'A 600 N block rests on a 30-degree incline. The coefficient of static friction is 0.45. What minimum force, applied parallel to and up the incline, is needed to start the block sliding upward?',
    choices: [
      {
        id: 'c1',
        text: '270.0 N'
      },
      {
        id: 'c2',
        text: '300.0 N'
      },
      {
        id: 'c3',
        text: '533.8 N'
      },
      {
        id: 'c4',
        text: '233.8 N'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'To push the block up, you must overcome both the weight component pulling it down the ramp and the friction resisting upward motion. Weight down the ramp: $W\\sin 30\\degree = 300$ N. Normal force: $N = W\\cos 30\\degree = 519.6$ N. Maximum friction: $\\mu_s N = 0.45 \\times 519.6 = 233.8$ N. The total force needed is $P = 300 + 233.8 = 533.8$ N. Answer B (300 N) only accounts for the gravity component and ignores friction. Answer D (233.8 N) is the friction force alone, forgetting that gravity also resists upward motion. Answer A (270 N) incorrectly uses $\\mu_s W$ as the friction force.',
    hint: 'Resolve the weight into components along and perpendicular to the surface. To push up the ramp, $P$ must overcome both the gravity component and friction.',
    steps: [
      {
        text: 'Weight components on the incline:',
        latex: 'W_{\\parallel} = 600\\sin 30\\degree = 300 \\text{ N}, \\quad W_{\\perp} = 600\\cos 30\\degree = 519.6 \\text{ N}'
      },
      {
        text: 'Normal force and maximum friction:',
        latex: 'N = 519.6 \\text{ N}, \\quad F = \\mu_s N = 0.45 \\times 519.6 = 233.8 \\text{ N}'
      },
      {
        text: 'For impending upward motion, the applied force $P$ must equal the gravity component plus friction (both act down the ramp):',
        latex: 'P = W_{\\parallel} + F = 300 + 233.8 = 533.8 \\text{ N}'
      },
      {
        text: 'Answer D (233.8 N) is only the friction force. Answer B (300 N) ignores friction entirely.',
        latex: null
      }
    ],
    handbookPage: 'p. 96, Friction',
    handbookFormula: 'F \\leq \\mu_s N',
    videoUrl: null,
    traps: [
      'Forgetting to include the weight component down the ramp -- friction alone is not the total resistance',
      'Using the full weight (600 N) as the normal force instead of $W\\cos\\theta$'
    ],
    diagram: null,
    lessonId: 'friction',
    chapterId: 'statics'
  },
  {
    id: 'stat-fri-ex4',
    type: 'conceptual',
    statement: 'A block sits on a rough incline. The angle of the incline is slowly increased until the block just begins to slide. At the moment of impending motion, which relationship correctly describes the angle $\\theta$ and the coefficient of static friction $\\mu_s$?',
    choices: [
      {
        id: 'c1',
        text: '$\\tan\\theta = \\mu_s$'
      },
      {
        id: 'c2',
        text: '$\\sin\\theta = \\mu_s$'
      },
      {
        id: 'c3',
        text: '$\\cos\\theta = \\mu_s$'
      },
      {
        id: 'c4',
        text: '$\\theta = \\mu_s$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'At impending motion on an incline, the friction force equals $\\mu_s N$. The weight component along the ramp is $W\\sin\\theta$ and the normal force is $N = W\\cos\\theta$. Setting friction equal to the gravity component: $\\mu_s W\\cos\\theta = W\\sin\\theta$. Cancel $W$: $\\mu_s = \\sin\\theta/\\cos\\theta = \\tan\\theta$. This angle is called the angle of repose. It is a classic result: the friction coefficient equals the tangent of the steepest angle at which the block can sit without sliding. Answer B ($\\sin\\theta = \\mu_s$) incorrectly omits the cosine in the normal force. Answer C ($\\cos\\theta = \\mu_s$) inverts the relationship. Answer D confuses the angle (in radians) with the coefficient.',
    hint: 'At impending motion, set $\\mu_s N = W\\sin\\theta$ and $N = W\\cos\\theta$. Divide to eliminate $W$ and $N$.',
    steps: [
      {
        text: 'At impending motion along the incline:',
        latex: '\\mu_s N = W\\sin\\theta'
      },
      {
        text: 'Normal force on an incline:',
        latex: 'N = W\\cos\\theta'
      },
      {
        text: 'Substitute and simplify:',
        latex: '\\mu_s W\\cos\\theta = W\\sin\\theta \\quad \\Rightarrow \\quad \\mu_s = \\frac{\\sin\\theta}{\\cos\\theta} = \\tan\\theta'
      },
      {
        text: 'This is called the angle of repose. It means the coefficient of static friction can be measured by simply tilting a surface until the object begins to slide.',
        latex: null
      }
    ],
    handbookPage: 'p. 96, Friction',
    handbookFormula: 'F \\leq \\mu_s N',
    videoUrl: null,
    traps: [
      'Confusing sine and tangent -- the correct relationship is $\\tan\\theta = \\mu_s$, not $\\sin\\theta = \\mu_s$',
      'Forgetting that the normal force on an incline is $W\\cos\\theta$, not $W$'
    ],
    diagram: null,
    lessonId: 'friction',
    chapterId: 'statics'
  },
  {
    id: 'stat-ccs-ex1',
    type: 'computational',
    statement: 'An L-shaped cross section is formed by two non-overlapping rectangles: a horizontal leg 80 mm wide and 20 mm tall at the bottom, and a vertical leg 20 mm wide and 80 mm tall sitting directly on top of it. The total height is 100 mm. What is the distance from the bottom of the section to the centroid ($\\bar{y}$)?',
    choices: [
      {
        id: 'c1',
        text: '25.0 mm'
      },
      {
        id: 'c2',
        text: '50.0 mm'
      },
      {
        id: 'c3',
        text: '40.0 mm'
      },
      {
        id: 'c4',
        text: '35.0 mm'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'Split the L into two rectangles. The horizontal leg is 80 x 20 mm ($A_1 = 1{,}600$ mm$^2$, centroid at $y_1 = 10$ mm from the bottom). The vertical leg is 20 x 80 mm ($A_2 = 1{,}600$ mm$^2$, centroid at $y_2 = 20 + 40 = 60$ mm from the bottom). Since both areas are equal, the centroid is the simple average of 10 and 60: $\\bar{y} = (16{,}000 + 96{,}000)/3{,}200 = 35$ mm. Answer B (50 mm) is the geometric midpoint of the 100 mm total height. Answer C (40 mm) is a rough guess splitting the difference. Answer A (25 mm) underweights the vertical leg.',
    hint: 'Split the L into two non-overlapping rectangles. Measure each centroid from the same reference (bottom edge).',
    steps: [
      {
        text: 'Horizontal leg: 80 x 20 mm, centroid at $y = 10$ mm from bottom.',
        latex: 'A_1 = 1{,}600 \\text{ mm}^2, \\quad y_1 = 10 \\text{ mm}'
      },
      {
        text: 'Vertical leg (above horizontal leg): 20 x 80 mm, centroid at $y = 20 + 40 = 60$ mm.',
        latex: 'A_2 = 1{,}600 \\text{ mm}^2, \\quad y_2 = 60 \\text{ mm}'
      },
      {
        text: 'Composite centroid:',
        latex: '\\bar{y} = \\frac{1{,}600(10) + 1{,}600(60)}{1{,}600 + 1{,}600} = \\frac{16{,}000 + 96{,}000}{3{,}200} = \\frac{112{,}000}{3{,}200} = 35.0 \\text{ mm}'
      }
    ],
    handbookPage: 'p. 95, Centroid of Area',
    handbookFormula: '\\bar{y} = \\frac{\\sum A_i\\, y_i}{\\sum A_i}',
    videoUrl: null,
    traps: [
      'Double-counting the overlap region where the two legs intersect',
      'Measuring one rectangle centroid from a different reference than the other'
    ],
    diagram: null,
    lessonId: 'centroids-composite-shapes',
    chapterId: 'statics'
  },
  {
    id: 'stat-ccs-ex2',
    type: 'computational',
    statement: 'A rectangular cross section is 200 mm wide and 300 mm tall. A 100 mm diameter circular hole is drilled with its center at the geometric center of the rectangle (100 mm from the left, 150 mm from the bottom). What is the $\\bar{y}$ coordinate of the centroid of the remaining shape, measured from the bottom?',
    choices: [
      {
        id: 'c1',
        text: '150.0 mm'
      },
      {
        id: 'c2',
        text: '147.3 mm'
      },
      {
        id: 'c3',
        text: '152.7 mm'
      },
      {
        id: 'c4',
        text: '142.5 mm'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'The rectangle centroid is at $y = 150$ mm. The hole centroid is also at $y = 150$ mm (same as the rectangle center). When you remove material whose centroid is at the same height as the overall centroid, the centroid does not shift. The subtraction in the numerator and denominator both reference the same $y$ value, so $\\bar{y}$ stays at 150 mm. Answer B and C assume the hole shifts the centroid, but only an off-center hole does that. Answer D over-corrects as if the hole were near the top.',
    hint: 'Think about where the hole is located relative to the rectangle centroid. Does removing material at the centroid shift it?',
    steps: [
      {
        text: 'Rectangle: $A_1 = 200 \\times 300 = 60{,}000$ mm$^2$, centroid at $y_1 = 150$ mm.',
        latex: null
      },
      {
        text: 'Hole: $A_2 = \\pi(50)^2 = 7{,}854$ mm$^2$, centroid at $y_2 = 150$ mm (same as rectangle center).',
        latex: null
      },
      {
        text: 'Composite centroid:',
        latex: '\\bar{y} = \\frac{60{,}000(150) - 7{,}854(150)}{60{,}000 - 7{,}854} = \\frac{150(60{,}000 - 7{,}854)}{60{,}000 - 7{,}854} = 150.0 \\text{ mm}'
      },
      {
        text: 'The hole is centered on the rectangle, so removing it does not shift the centroid. Only an off-center hole changes $\\bar{y}$.',
        latex: null
      }
    ],
    handbookPage: 'p. 95, Centroid of Area',
    handbookFormula: '\\bar{y} = \\frac{\\sum A_i\\, y_i}{\\sum A_i}',
    videoUrl: null,
    traps: [
      'Assuming any hole shifts the centroid -- a centered hole has no effect',
      'Forgetting to subtract the hole area from the denominator as well as the numerator'
    ],
    diagram: null,
    lessonId: 'centroids-composite-shapes',
    chapterId: 'statics'
  },
  {
    id: 'stat-ccs-ex3',
    type: 'computational',
    statement: 'A channel section (C-shape) is formed by three rectangles: a web 10 mm wide and 160 mm tall, and two identical flanges each 60 mm wide and 20 mm tall attached at the top and bottom of the web, extending to the right. What is the horizontal distance $\\bar{x}$ from the left edge of the web to the centroid of the section?',
    choices: [
      {
        id: 'c1',
        text: '10.0 mm'
      },
      {
        id: 'c2',
        text: '30.0 mm'
      },
      {
        id: 'c3',
        text: '20.0 mm'
      },
      {
        id: 'c4',
        text: '35.0 mm'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Set the reference axis at the left edge of the web. The web is 10 mm wide, so its centroid is at $x = 5$ mm. Each flange extends 60 mm to the right from the left edge of the web, with centroid at $x = 30$ mm. Web area: $10 \\times 160 = 1{,}600$ mm$^2$. Each flange: $60 \\times 20 = 1{,}200$ mm$^2$ (two flanges total 2{,}400 mm$^2$). The weighted average gives $\\bar{x} = (8{,}000 + 72{,}000)/4{,}000 = 20$ mm. Answer B (30 mm) is the centroid of the flanges alone, ignoring the web. Answer A (10 mm) is the width of the web, not the centroid location. Answer D (35 mm) is the midpoint of the total 70 mm width.',
    hint: 'Set the reference at the left edge of the web. The flanges pull the centroid to the right.',
    steps: [
      {
        text: 'Reference: left edge of the web. Web: 10 mm wide, 160 mm tall.',
        latex: 'A_w = 1{,}600 \\text{ mm}^2, \\quad x_w = 5 \\text{ mm}'
      },
      {
        text: 'Two flanges, each 60 mm wide and 20 mm tall, extending to the right from the web.',
        latex: 'A_f = 2 \\times (60 \\times 20) = 2{,}400 \\text{ mm}^2, \\quad x_f = 30 \\text{ mm}'
      },
      {
        text: 'Composite centroid:',
        latex: '\\bar{x} = \\frac{1{,}600(5) + 2{,}400(30)}{1{,}600 + 2{,}400} = \\frac{8{,}000 + 72{,}000}{4{,}000} = 20.0 \\text{ mm}'
      }
    ],
    handbookPage: 'p. 95, Centroid of Area; pp. 98-100, Shape Properties',
    handbookFormula: '\\bar{x} = \\frac{\\sum A_i\\, x_i}{\\sum A_i}',
    videoUrl: null,
    traps: [
      'Forgetting that the web centroid is at half its width, not at the edge',
      'Measuring flange centroids from the wrong reference axis'
    ],
    diagram: null,
    lessonId: 'centroids-composite-shapes',
    chapterId: 'statics'
  },
  {
    id: 'stat-ccs-ex4',
    type: 'conceptual',
    statement: 'A symmetric I-beam cross section has a circular hole drilled through the web, centered exactly at the centroid of the full I-beam. Compared to the undrilled section, how does the hole affect the centroid location?',
    choices: [
      {
        id: 'c1',
        text: 'The centroid stays in the same location'
      },
      {
        id: 'c2',
        text: 'The centroid shifts toward the top flange'
      },
      {
        id: 'c3',
        text: 'The centroid shifts toward the bottom flange'
      },
      {
        id: 'c4',
        text: 'The centroid shifts horizontally toward the hole'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'Removing material at the centroid does not move the centroid. The centroid formula is $\\bar{y} = \\sum A_i y_i / \\sum A_i$. When you subtract a hole whose centroid is at $\\bar{y}$ of the original shape, the numerator loses $A_{hole} \\times \\bar{y}$ and the denominator loses $A_{hole}$. The ratio stays the same: $\\bar{y}_{new} = (A\\bar{y} - A_h\\bar{y})/(A - A_h) = \\bar{y}(A - A_h)/(A - A_h) = \\bar{y}$. Only a hole placed above or below the original centroid causes a shift. This is the same principle tested in the practice problems -- the key insight is whether the removed material is on-center or off-center.',
    hint: 'Think about what happens to the weighted-average formula when the hole centroid matches the overall centroid.',
    steps: [
      {
        text: 'Original centroid: $\\bar{y}$. Hole area: $A_h$, centered at $y_h = \\bar{y}$.',
        latex: null
      },
      {
        text: 'New centroid after removing the hole:',
        latex: '\\bar{y}_{new} = \\frac{A\\bar{y} - A_h \\bar{y}}{A - A_h} = \\frac{\\bar{y}(A - A_h)}{A - A_h} = \\bar{y}'
      },
      {
        text: 'The centroid does not move. Removing material at the centroid preserves symmetry in the weighted average.',
        latex: null
      },
      {
        text: 'If the hole were above or below the centroid, the centroid would shift toward the opposite side -- removing mass above pulls the centroid down, and vice versa.',
        latex: null
      }
    ],
    handbookPage: 'p. 95, Centroid of Area',
    handbookFormula: '\\bar{y} = \\frac{\\sum A_i\\, y_i}{\\sum A_i}',
    videoUrl: null,
    traps: [
      'Assuming any hole must shift the centroid -- only off-center holes cause a shift',
      'Confusing the effect on the centroid with the effect on the moment of inertia (which always decreases when material is removed)'
    ],
    diagram: null,
    lessonId: 'centroids-composite-shapes',
    chapterId: 'statics'
  },
  {
    id: 'stat-ami-ex1',
    type: 'computational',
    statement: 'A rectangular cross-section has a width of 200 mm and a height of 400 mm. What is the moment of inertia about the centroidal horizontal axis?',
    choices: [
      {
        id: 'c1',
        text: '$533 \\times 10^6\\,\\text{mm}^4$'
      },
      {
        id: 'c2',
        text: '$2667 \\times 10^6\\,\\text{mm}^4$'
      },
      {
        id: 'c3',
        text: '$1067 \\times 10^6\\,\\text{mm}^4$'
      },
      {
        id: 'c4',
        text: '$4267 \\times 10^6\\,\\text{mm}^4$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'easy',
    eli5: 'For a rectangle, $I = bh^3/12$ about the centroidal axis. Plug in $b = 200$ and $h = 400$: $I = 200(400)^3/12 = 200(64{,}000{,}000)/12 = 1{,}066{,}666{,}667$ mm$^4$ which rounds to $1067 \\times 10^6$. The trap is using $bh^3/3$ (which is about the base, not the centroid) or swapping $b$ and $h$.',
    hint: 'Use $I = bh^3/12$ for a rectangle about its centroidal axis.',
    steps: [
      {
        text: 'For a rectangle about the centroidal axis:',
        latex: 'I = \\frac{bh^3}{12}'
      },
      {
        text: 'Substitute $b = 200$ mm, $h = 400$ mm:',
        latex: 'I = \\frac{200 \\times 400^3}{12} = \\frac{200 \\times 64{,}000{,}000}{12}'
      },
      {
        text: 'Calculate:',
        latex: 'I = \\frac{12{,}800{,}000{,}000}{12} = 1{,}067 \\times 10^6\\,\\text{mm}^4'
      }
    ],
    handbookPage: 'p. 94',
    handbookFormula: 'I_x = \\frac{bh^3}{12}',
    videoUrl: null,
    traps: [
      'Using $bh^3/3$ (moment about the base) instead of $bh^3/12$ (about centroid)',
      'Swapping $b$ and $h$ dimensions'
    ],
    diagram: null,
    lessonId: 'area-moments-of-inertia',
    chapterId: 'statics'
  },
  {
    id: 'stat-ami-ex2',
    type: 'conceptual',
    statement: 'When using the parallel axis theorem to find the moment of inertia of a composite section, the transfer term $Ad^2$ represents:',
    choices: [
      {
        id: 'c1',
        text: 'The moment of inertia about the shape\'s own centroid'
      },
      {
        id: 'c2',
        text: 'The additional inertia due to the offset from the composite centroid'
      },
      {
        id: 'c3',
        text: 'The polar moment of inertia'
      },
      {
        id: 'c4',
        text: 'The product of inertia'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'The parallel axis theorem says $I_{total} = I_{centroid} + Ad^2$. The $Ad^2$ term accounts for the fact that the shape\'s centroid is offset from the axis you care about. $A$ is the shape\'s area, and $d$ is the distance between centroids. It is always added — never subtracted.',
    hint: 'Think about what happens when an axis is shifted away from the centroid.',
    steps: [
      {
        text: 'The parallel axis theorem: $I = \\bar{I} + Ad^2$.',
        latex: null
      },
      {
        text: '$\\bar{I}$ is the moment about the shape\'s own centroid.',
        latex: null
      },
      {
        text: '$Ad^2$ is the additional inertia due to the distance $d$ from the shape\'s centroid to the reference axis.',
        latex: null
      }
    ],
    handbookPage: 'p. 94',
    handbookFormula: 'I = \\bar{I} + Ad^2',
    videoUrl: null,
    traps: ['Confusing the transfer term with the centroidal moment itself'],
    diagram: null,
    lessonId: 'area-moments-of-inertia',
    chapterId: 'statics'
  },
  {
    id: 'stat-ami-ex3',
    type: 'computational',
    statement: 'A solid circular cross-section has a diameter of 200 mm. What is the polar moment of inertia $J$ about the centroidal axis?',
    choices: [
      {
        id: 'c1',
        text: '$157.1 \\times 10^6\\,\\text{mm}^4$'
      },
      {
        id: 'c2',
        text: '$78.5 \\times 10^6\\,\\text{mm}^4$'
      },
      {
        id: 'c3',
        text: '$39.3 \\times 10^6\\,\\text{mm}^4$'
      },
      {
        id: 'c4',
        text: '$314.2 \\times 10^6\\,\\text{mm}^4$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'The polar moment of inertia for a circle is $J = \\pi r^4/2$, or equivalently $J = \\pi d^4/32$. With $d = 200$ mm, $J = \\pi(200)^4/32 = \\pi(1.6 \\times 10^9)/32 = 157.1 \\times 10^6$ mm$^4$. Another way to get there: $I_x = \\pi r^4/4 = 78.5 \\times 10^6$, then $J = 2I_x = 157.1 \\times 10^6$. Choice B is just $I_x$ (the moment about one axis, not the polar moment). Choice C halves $I_x$ — probably from using $\\pi r^4/8$ by mistake. Choice D doubles the correct answer.',
    hint: 'Remember that $J = I_x + I_y$, and for a circle $I_x = I_y$.',
    steps: [
      {
        text: 'Find the radius:',
        latex: 'r = \\frac{d}{2} = \\frac{200}{2} = 100\\,\\text{mm}'
      },
      {
        text: 'Moment of inertia about one centroidal axis:',
        latex: 'I_x = \\frac{\\pi r^4}{4} = \\frac{\\pi (100)^4}{4} = 78.54 \\times 10^6\\,\\text{mm}^4'
      },
      {
        text: 'For a circle, $I_x = I_y$ by symmetry. The polar moment is their sum:',
        latex: 'J = I_x + I_y = 2 \\times 78.54 \\times 10^6 = 157.1 \\times 10^6\\,\\text{mm}^4'
      },
      {
        text: 'Equivalently, the direct formula gives the same result:',
        latex: 'J = \\frac{\\pi d^4}{32} = \\frac{\\pi (200)^4}{32} = 157.1 \\times 10^6\\,\\text{mm}^4'
      }
    ],
    handbookPage: 'pp. 98–100',
    handbookFormula: 'J = \\frac{\\pi r^4}{2}',
    videoUrl: null,
    traps: [
      'Reporting $I_x$ instead of $J$ -- the polar moment is twice $I_x$ for a circle',
      'Using diameter instead of radius in the formula $\\pi r^4/2$'
    ],
    diagram: null,
    lessonId: 'area-moments-of-inertia',
    chapterId: 'statics'
  },
  {
    id: 'stat-ami-ex4',
    type: 'computational',
    statement: 'An I-shaped composite section has a top flange (200 mm wide $\\times$ 20 mm thick), a web (20 mm wide $\\times$ 160 mm tall), and a bottom flange (200 mm wide $\\times$ 20 mm thick). The total height is 200 mm. By symmetry, the centroid is at mid-height (100 mm from the bottom). What is the moment of inertia $I_x$ about the centroidal horizontal axis?',
    choices: [
      {
        id: 'c1',
        text: '$71.9 \\times 10^6\\,\\text{mm}^4$'
      },
      {
        id: 'c2',
        text: '$113.3 \\times 10^6\\,\\text{mm}^4$'
      },
      {
        id: 'c3',
        text: '$7.09 \\times 10^6\\,\\text{mm}^4$'
      },
      {
        id: 'c4',
        text: '$6.83 \\times 10^6\\,\\text{mm}^4$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'Split the I-section into three rectangles and apply the parallel axis theorem to each. The web is centered on the composite centroid, so its $d = 0$ and there is no transfer term. Each flange has $d = 90$ mm (from its own centroid at 10 mm or 190 mm to the composite centroid at 100 mm). The web contributes mostly through its own centroidal $I$ ($bh^3/12$), while the flanges contribute mostly through their $Ad^2$ terms. Add all three to get $71.9 \\times 10^6$ mm$^4$. Choice B treats the section as a solid $200 \\times 200$ rectangle ($bh^3/12 = 113.3 \\times 10^6$), which is wrong for a composite section. Choice C adds only the centroidal $I$ values of all three pieces without the $Ad^2$ transfer terms. Choice D is just the web\'s centroidal $I$ alone.',
    hint: 'The web centroid coincides with the composite centroid ($d = 0$). Each flange centroid is 90 mm from the composite centroid.',
    steps: [
      {
        text: 'Web (20 $\\times$ 160 mm), centered at $y = 100$ mm, so $d = 0$:',
        latex: 'I_{web} = \\frac{20 \\times 160^3}{12} + 0 = 6.827 \\times 10^6\\,\\text{mm}^4'
      },
      {
        text: 'Bottom flange (200 $\\times$ 20 mm), centroid at $y = 10$ mm, $d = 90$ mm:',
        latex: 'I_{bot} = \\frac{200 \\times 20^3}{12} + (200 \\times 20)(90)^2 = 0.133 \\times 10^6 + 32.4 \\times 10^6 = 32.53 \\times 10^6\\,\\text{mm}^4'
      },
      {
        text: 'Top flange is symmetric to the bottom flange:',
        latex: 'I_{top} = I_{bot} = 32.53 \\times 10^6\\,\\text{mm}^4'
      },
      {
        text: 'Total:',
        latex: 'I_x = 6.83 + 32.53 + 32.53 \\approx 71.9 \\times 10^6\\,\\text{mm}^4'
      },
      {
        text: 'Note how the flanges\' $Ad^2$ terms dominate — that is why wide flanges far from the centroid make beams stiff.',
        latex: null
      }
    ],
    handbookPage: 'pp. 94–95',
    handbookFormula: 'I_x = \\bar{I}_{xc} + Ad^2',
    videoUrl: null,
    traps: [
      'Forgetting the $Ad^2$ transfer terms for the flanges',
      'Using the full 200 mm height in a single $bh^3/12$ as if it were a solid rectangle'
    ],
    diagram: null,
    lessonId: 'area-moments-of-inertia',
    chapterId: 'statics'
  },
];

export default PROBLEMS;
