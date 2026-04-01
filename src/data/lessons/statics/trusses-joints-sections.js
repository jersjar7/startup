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
};
