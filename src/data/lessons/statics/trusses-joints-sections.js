export default {
  id: 'trusses-joints-sections',
  name: 'Trusses: Method of Joints & Sections',
  subtopicId: 'trusses-and-friction',
  application:
    'Trusses are one of the highest-frequency statics topics on the FE Civil. You will see roof trusses, bridge trusses, and transmission towers. The exam tests two methods: method of joints (write equilibrium at each joint to find all member forces) and method of sections (cut through the truss and use equilibrium on one side to find specific member forces). It also tests whether you can spot zero-force members instantly. The handbook (p. 97) defines both methods and the zero-force member rules. Knowing when to use joints vs. sections saves critical time on exam day.',
  content: [
    {
      type: 'text',
      body: 'A truss is a structure made of straight, two-force members connected at joints. Each member carries only axial force (tension or compression). All loads and reactions act at the joints.',
    },
    { type: 'heading', body: 'Zero-Force Members' },
    {
      type: 'text',
      body: 'Two rules identify zero-force members without any calculation. Rule 1: if only two members meet at an unloaded joint, both are zero-force members. Rule 2: if three members meet at an unloaded joint and two are collinear, the third member is a zero-force member.',
    },
    {
      type: 'callout',
      variant: 'exam',
      body: 'The FE loves to test zero-force member identification. Before doing any calculations, scan the truss for joints that match these two rules. It can eliminate unknowns and simplify the entire analysis.',
    },
    { type: 'heading', body: 'Method of Joints' },
    {
      type: 'formula',
      latex: '\\sum F_H = 0 \\qquad \\sum F_V = 0',
      label: 'Equilibrium at Each Joint',
    },
    {
      type: 'text',
      body: 'Isolate each joint as a free body. The forces acting on the joint are the member forces (along each member) and any external loads or reactions. Write two equilibrium equations per joint. Start at a joint with at most two unknown member forces.',
    },
    { type: 'heading', body: 'Method of Sections' },
    {
      type: 'text',
      body: 'Cut through the truss so that the cut passes through the member whose force you need. Draw a free body diagram of one side of the cut. You have three equilibrium equations ($\\sum F_x = 0$, $\\sum F_y = 0$, $\\sum M = 0$), so you can solve for up to three unknown member forces.',
    },
    {
      type: 'callout',
      variant: 'tip',
      body: 'Method of sections is faster when you need just one or two member forces in the middle of the truss. Method of joints is better when you need all member forces. On the FE, sections is almost always the faster path since the problem only asks for one member.',
    },
    {
      type: 'callout',
      variant: 'warning',
      body: 'When assuming member forces, assume tension (pulling away from the joint). If the answer comes out negative, the member is in compression. Be consistent \u2014 mixing conventions leads to sign errors.',
    },
  ],
  illustration: null,
  problems: [
    {
      id: 'stat-tjs-q1',
      statement:
        'In a truss, joint C is where three members meet. Members AC and CE are collinear (both along the same horizontal line), and member CD connects vertically downward. No external load or reaction is applied at joint C. What can you conclude about the force in member CD?',
      choices: [
        { id: 'c1', text: 'CD is a zero-force member' },
        { id: 'c2', text: 'CD carries the same force as AC' },
        { id: 'c3', text: 'CD carries half the force of CE' },
        { id: 'c4', text: 'Cannot determine without calculating reactions' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'easy',
      eli5: 'This is a direct application of zero-force member Rule 2: when three members meet at an unloaded joint and two of them are collinear, the third is a zero-force member. AC and CE lie along the same horizontal line (collinear), so CD (the non-collinear member) carries zero force. No calculation needed. Answer B and C assume CD shares load with the other members, but collinear members pass their force straight through the joint. Answer D overthinks it \u2014 the zero-force rule gives the answer by inspection.',
      hint: 'Three members meet at an unloaded joint. Two are collinear. What does the zero-force member rule say about the third?',
      steps: [
        {
          text: 'Joint C has three members: AC, CE (collinear along the horizontal), and CD (non-collinear, vertical).',
          latex: null,
        },
        {
          text: 'No external load or support reaction is applied at joint C.',
          latex: null,
        },
        {
          text: 'Zero-force member Rule 2: when three members meet at an unloaded joint and two are collinear, the third is a zero-force member.',
          latex: null,
        },
        {
          text: 'Therefore CD is a zero-force member:',
          latex: 'F_{CD} = 0',
        },
      ],
      handbookPage: 'p. 97, Statically Determinate Truss',
      handbookFormula: null,
      videoUrl: null,
      traps: [
        'Skipping the zero-force check and jumping straight into calculations',
        'Assuming a member must carry load just because it is connected to the truss',
      ],
      diagram: { component: 'ZeroForceJoint', props: {} },
    },
    {
      id: 'stat-tjs-q2',
      statement:
        'A symmetric triangular truss has joints at A (bottom left, pin support), B (bottom right, roller support), and C (top center). The span AB is 6 m and C is 4 m directly above the midpoint of AB. A 10 kN downward load is applied at joint C. Using the method of joints at joint A, what is the force in member AC?',
      choices: [
        { id: 'c1', text: '6.25 kN, compression' },
        { id: 'c2', text: '5.0 kN, tension' },
        { id: 'c3', text: '7.5 kN, compression' },
        { id: 'c4', text: '3.75 kN, tension' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'medium',
      eli5: 'At joint A, two member forces and the 5 kN upward reaction must balance. Since AB is horizontal, it has no vertical component \u2014 so member AC must carry the entire vertical load. The vertical component of the AC force equals 5 kN, and since AC runs from A(0,0) to C(3,4) (a 3-4-5 triangle), the full force is $5 \\div (4/5) = 6.25$ kN. The negative sign in the tension convention means AC is in compression (pushing toward the joint). Answer B (5 kN) confuses the vertical component with the total member force. Answer D (3.75 kN) is actually the force in member AB, not AC.',
      hint: 'At joint A, only member AC has a vertical component. Set $\\sum F_y = 0$ at joint A to find the force in AC directly.',
      steps: [
        {
          text: 'Find reactions. By symmetry (load at midpoint):',
          latex: 'A_y = B_y = 5 \\text{ kN}, \\quad A_x = 0',
        },
        {
          text: 'Member AC runs from A(0,0) to C(3,4). Length = 5 (3-4-5 triangle). Direction cosines: $(3/5,\\, 4/5)$.',
          latex: null,
        },
        {
          text: 'At joint A, assume $F_{AC}$ is tension (pulling away from A along AC). Vertical equilibrium:',
          latex: '\\sum F_y = 0:\\quad 5 + F_{AC}\\!\\left(\\frac{4}{5}\\right) = 0',
        },
        {
          text: 'Solve:',
          latex: 'F_{AC} = -\\frac{25}{4} = -6.25 \\text{ kN}',
        },
        {
          text: 'Negative means our tension assumption was wrong \u2014 AC is in compression. Force = 6.25 kN (C).',
          latex: null,
        },
      ],
      handbookPage: 'p. 97, Plane Truss: Method of Joints',
      handbookFormula: '\\sum F_H = 0 \\quad \\sum F_V = 0',
      videoUrl: null,
      traps: [
        'Reporting the vertical component (5 kN) as the total member force instead of dividing by the direction cosine',
        'Mixing up which member force the problem asks for \u2014 AC vs. AB',
      ],
      diagram: { component: 'TriangularTruss', props: { span: 6, height: 4, load: 10 } },
    },
    {
      id: 'stat-tjs-q3',
      statement:
        'A truss spans 9 m with three equal 3 m panels. Bottom chord joints are A (left, pin support), B (3 m), C (6 m), and D (right, roller support at 9 m). Top chord joints are E (directly above B, height 4 m) and F (directly above C, height 4 m). A single 24 kN downward load acts at joint F. Using the method of sections, what is the force in bottom chord member BC?',
      choices: [
        { id: 'c1', text: '6 kN, tension' },
        { id: 'c2', text: '8 kN, tension' },
        { id: 'c3', text: '6 kN, compression' },
        { id: 'c4', text: '16 kN, tension' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'hard',
      eli5: 'Method of sections lets you cut straight to the member you need without solving the entire truss. Cut through EF, EC, and BC, then take the left portion (joints A, B, E). To isolate the force in BC, sum moments about point E \u2014 both the EF and EC forces pass through E, so their moments vanish. The only forces with nonzero moments about E are the 8 kN support reaction at A and the unknown BC force. The reaction at A (8 kN upward) is 3 m to the left of E, creating a 24 kN\\cdot m clockwise moment. Member BC is 4 m below E. Setting the moments equal: $F_{BC} \\times 4 = 24$, so $F_{BC} = 6$ kN tension. Answer B (8 kN) confuses the support reaction with the member force. Answer D (16 kN) is the reaction at D.',
      hint: 'Cut through the three members and sum moments about point E, where two of the three cut forces intersect.',
      steps: [
        {
          text: 'Find reactions:',
          latex: '\\sum M_A = 0:\\quad 24(6) = D_y(9) \\quad \\Rightarrow \\quad D_y = 16 \\text{ kN},\\quad A_y = 8 \\text{ kN}',
        },
        {
          text: 'Cut through members EF, EC, and BC. Analyze the left portion (joints A, B, E).',
          latex: null,
        },
        {
          text: 'Sum moments about E to eliminate $F_{EF}$ and $F_{EC}$ (both pass through E at (3, 4)):',
          latex: '\\sum M_E = 0',
        },
        {
          text: '$A_y = 8$ kN upward at A(0,0), which is 3 m left of E. This creates a CW moment about E:',
          latex: 'M_{A_y} = 8 \\times 3 = 24 \\text{ kN\\cdot m (CW)}',
        },
        {
          text: '$F_{BC}$ acts horizontally at height $y = 0$, which is 4 m below E. It creates a CCW moment:',
          latex: 'M_{BC} = F_{BC} \\times 4 \\text{ (CCW)}',
        },
        {
          text: 'Set the sum to zero and solve:',
          latex: 'F_{BC} \\times 4 = 24 \\quad \\Rightarrow \\quad F_{BC} = 6 \\text{ kN (tension)}',
        },
      ],
      handbookPage: 'p. 97, Plane Truss: Method of Sections',
      handbookFormula: '\\sum F_H = 0 \\quad \\sum F_V = 0 \\quad \\sum M = 0',
      videoUrl: null,
      traps: [
        'Confusing support reactions with member forces \u2014 the 8 kN reaction is not the answer',
        'Summing moments about the wrong point \u2014 choose a point where two unknown cut forces intersect to get one equation with one unknown',
      ],
      diagram: { component: 'PrattTruss', props: { panels: 3, panelWidth: 3, height: 4, load: 24, loadPanel: 2 } },
    },
  ],
  examProblems: [
    {
      id: 'stat-tjs-ex1',
      type: 'computational',
      statement:
        'A simple triangular truss has joints at A (left, pin support), B (right, roller support), and C (top). The horizontal span AB is 8 m and C is 3 m above the midpoint of AB. A 24 kN downward load acts at C. By symmetry, each support reaction is 12 kN. Using the method of joints at joint A, what is the force in member AB?',
      choices: [
        { id: 'c1', text: '16.0 kN, tension' },
        { id: 'c2', text: '12.0 kN, tension' },
        { id: 'c3', text: '20.0 kN, compression' },
        { id: 'c4', text: '24.0 kN, tension' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'easy',
      eli5: 'At joint A, the pin reaction is 12 kN upward. Member AC goes from A(0,0) to C(4,3), so its direction cosines are $(4/5, 3/5)$. From $\\sum F_y = 0$: $12 + F_{AC}(3/5) = 0$, so $F_{AC} = -20$ kN (compression). Then from $\\sum F_x = 0$: $F_{AB} + F_{AC}(4/5) = 0$, giving $F_{AB} = -(-20)(4/5) = 16$ kN (tension). Answer B (12 kN) confuses the support reaction with the member force. Answer C (20 kN compression) is actually the force in member AC, not AB.',
      hint: 'At joint A, find the force in AC first using $\\sum F_y = 0$, then use $\\sum F_x = 0$ to find the force in AB.',
      steps: [
        {
          text: 'By symmetry, $A_y = B_y = 12$ kN. Member AC: A(0,0) to C(4,3), length = 5, direction cosines $(4/5, 3/5)$.',
          latex: null,
        },
        {
          text: 'At joint A, $\\sum F_y = 0$ (assume tension, pulling away from A):',
          latex: '12 + F_{AC}\\left(\\frac{3}{5}\\right) = 0 \\quad \\Rightarrow \\quad F_{AC} = -20 \\text{ kN (compression)}',
        },
        {
          text: '$\\sum F_x = 0$:',
          latex: 'F_{AB} + F_{AC}\\left(\\frac{4}{5}\\right) = 0 \\quad \\Rightarrow \\quad F_{AB} + (-20)\\left(\\frac{4}{5}\\right) = 0',
        },
        {
          text: 'Solve:',
          latex: 'F_{AB} = 16.0 \\text{ kN (tension)}',
        },
      ],
      handbookPage: 'p. 97, Plane Truss: Method of Joints',
      handbookFormula: '\\sum F_H = 0 \\quad \\sum F_V = 0',
      videoUrl: null,
      traps: [
        'Reporting the reaction (12 kN) as the member force in AB',
        'Confusing the force in AC (20 kN) with the force in AB (16 kN)',
      ],
      diagram: null,
    },
    {
      id: 'stat-tjs-ex2',
      type: 'computational',
      statement:
        'A Pratt truss has four equal panels of 4 m each (total span 16 m) and a height of 3 m. It is simply supported with a pin at the left and a roller at the right. A single 36 kN downward load is applied at the second bottom chord joint (8 m from the left). Using the method of sections, cut through the truss and determine the force in the top chord member directly above the loaded joint.',
      choices: [
        { id: 'c1', text: '24.0 kN, compression' },
        { id: 'c2', text: '18.0 kN, compression' },
        { id: 'c3', text: '36.0 kN, compression' },
        { id: 'c4', text: '24.0 kN, tension' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'medium',
      eli5: 'First find reactions: $\\sum M_A = 0$ gives $R_B = 36(8)/16 = 18$ kN, and $R_A = 18$ kN. Cut through the panel just to the right of the load. On the left portion, sum moments about the bottom chord joint at the cut (12 m from A) to isolate the top chord force. $R_A(12) - 36(4) = F_{top}(3)$, so $F_{top} = (216 - 144)/3 = 24$ kN. Since we assumed tension and got positive, but the top chord must push inward -- actually, checking the sign convention: $\\sum M = 0$ about the bottom joint at 12 m: $18(12) - 36(4) + F_{top}(3) = 0$, so $F_{top} = -(216-144)/3 = -24$ kN, meaning compression. Answer B (18 kN) is the support reaction. Answer D gets the magnitude right but the wrong sense (tension vs. compression).',
      hint: 'Cut through the truss and sum moments about the bottom chord joint at the cut location to isolate the top chord force.',
      steps: [
        {
          text: 'Find reactions by symmetry of geometry (load at midspan):',
          latex: 'R_A = R_B = \\frac{36}{2} = 18 \\text{ kN}',
        },
        {
          text: 'Cut through the panel between 8 m and 12 m (cuts top chord, diagonal, and bottom chord). Analyze the left portion.',
          latex: null,
        },
        {
          text: 'Sum moments about the bottom chord joint at 12 m (eliminates bottom chord and diagonal forces):',
          latex: '\\sum M = 0: \\quad 18(12) - 36(4) + F_{top}(3) = 0',
        },
        {
          text: 'Solve:',
          latex: 'F_{top} = \\frac{-(216 - 144)}{3} = \\frac{-72}{3} = -24 \\text{ kN}',
        },
        {
          text: 'Negative with tension assumption means compression: $F_{top} = 24.0$ kN (C).',
          latex: null,
        },
      ],
      handbookPage: 'p. 97, Plane Truss: Method of Sections',
      handbookFormula: '\\sum F_H = 0 \\quad \\sum F_V = 0 \\quad \\sum M = 0',
      videoUrl: null,
      traps: [
        'Confusing a support reaction with a member force',
        'Getting the correct magnitude but wrong sense (tension vs. compression) -- top chords in a loaded truss are typically in compression',
      ],
      diagram: null,
    },
    {
      id: 'stat-tjs-ex3',
      type: 'computational',
      statement:
        'A Pratt truss spans 12 m with three equal 4 m panels and a height of 3 m. It is simply supported (pin at A, roller at D). Bottom joints: A (0 m), B (4 m), C (8 m), D (12 m). Top joints: E (above B), F (above C). Vertical members connect B-E and C-F. A single 36 kN downward load acts at joint E. Using the method of sections, what is the force in diagonal member BF?',
      choices: [
        { id: 'c1', text: '20.0 kN, tension' },
        { id: 'c2', text: '16.0 kN, tension' },
        { id: 'c3', text: '20.0 kN, compression' },
        { id: 'c4', text: '12.0 kN, tension' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'medium',
      eli5: 'Find reactions: $\\sum M_A = 0$ gives $R_D = 36(4)/12 = 12$ kN, so $R_A = 24$ kN. Cut through EF, BF, and BC, then take the right portion (joints C, D, F) which has only $R_D = 12$ kN upward. Member BF goes from B(4,0) to F(8,3), so its length is 5 and its vertical direction cosine is $3/5$. Vertical equilibrium: $12 - F_{BF}(3/5) = 0$, giving $F_{BF} = 20$ kN in tension. Answer B (16 kN) miscalculates the reaction or the direction cosine. Answer C (20 kN compression) gets the magnitude right but the wrong sense -- the diagonal in this panel resists the vertical shear by pulling, not pushing. Answer D (12 kN) confuses the support reaction with the member force.',
      hint: 'Cut through EF, BF, and BC. Take the right portion with only one external force. Use $\\sum F_y = 0$ to isolate the diagonal.',
      steps: [
        {
          text: 'Find reactions:',
          latex: '\\sum M_A = 0: \\quad 36(4) = R_D(12) \\quad \\Rightarrow \\quad R_D = 12 \\text{ kN}, \\quad R_A = 24 \\text{ kN}',
        },
        {
          text: 'Cut through EF, BF, and BC. Take the right portion (joints C, D, F). Only external force: $R_D = 12$ kN upward.',
          latex: null,
        },
        {
          text: 'Member BF runs from B(4,0) to F(8,3). Length = 5. Direction cosines: $(4/5,\\, 3/5)$. Vertical equilibrium on the right portion (assume BF tension):',
          latex: '\\sum F_y = 0: \\quad 12 - F_{BF}\\left(\\frac{3}{5}\\right) = 0',
        },
        {
          text: 'Solve:',
          latex: 'F_{BF} = \\frac{12}{3/5} = 20.0 \\text{ kN (tension)}',
        },
        {
          text: 'Positive result confirms our tension assumption. The diagonal BF is in tension.',
          latex: null,
        },
      ],
      handbookPage: 'p. 97, Plane Truss: Method of Sections',
      handbookFormula: '\\sum F_H = 0 \\quad \\sum F_V = 0 \\quad \\sum M = 0',
      videoUrl: null,
      traps: [
        'Using the wrong side of the cut -- the right side has only one external force, making it simpler',
        'Forgetting to resolve the diagonal force into components before applying equilibrium',
      ],
      diagram: null,
    },
    {
      id: 'stat-tjs-ex4',
      type: 'conceptual',
      statement:
        'A planar truss has 9 members, 6 joints, and is supported by a pin and a roller. Which statement is correct about this truss?',
      choices: [
        { id: 'c1', text: 'It is statically determinate ($m = 2j - r$)' },
        { id: 'c2', text: 'It is statically indeterminate by one degree' },
        { id: 'c3', text: 'It is unstable' },
        { id: 'c4', text: 'It is statically indeterminate by two degrees' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'hard',
      eli5: 'The determinacy check for a 2D truss is $m + r = 2j$, where $m$ is the number of members, $r$ is the number of reaction components, and $j$ is the number of joints. A pin gives 2 reactions and a roller gives 1, so $r = 3$. Check: $9 + 3 = 12$ and $2(6) = 12$. Since $m + r = 2j$, the truss is statically determinate. If $m + r > 2j$, it would be indeterminate. If $m + r < 2j$, it would be unstable (or improperly constrained). Answer B would require $m + r = 13$ (one extra member or reaction). Answer C would require $m + r < 12$.',
      hint: 'Use $m + r = 2j$ for determinacy. Count reactions: a pin gives 2, a roller gives 1.',
      steps: [
        {
          text: 'Count: $m = 9$ members, $j = 6$ joints, pin + roller gives $r = 2 + 1 = 3$ reactions.',
          latex: null,
        },
        {
          text: 'Apply the determinacy criterion:',
          latex: 'm + r = 9 + 3 = 12 \\qquad 2j = 2(6) = 12',
        },
        {
          text: 'Since $m + r = 2j$, the truss is statically determinate.',
          latex: null,
        },
        {
          text: 'If $m + r > 2j$: indeterminate by $(m + r - 2j)$ degrees. If $m + r < 2j$: potentially unstable.',
          latex: null,
        },
      ],
      handbookPage: 'p. 97, Statically Determinate Truss',
      handbookFormula: 'm + r = 2j',
      videoUrl: null,
      traps: [
        'Forgetting to count reaction components as part of the check',
        'Miscounting the support reactions -- a pin has 2 components, not 1',
      ],
      diagram: null,
    },
  ],
};
