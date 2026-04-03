export default {
  id: 'equilibrium-free-body-diagrams',
  name: 'Equilibrium & Free Body Diagrams',
  subtopicId: 'forces-and-equilibrium',
  application:
    'Every structural analysis on the FE starts the same way: draw the free body diagram, identify all forces and reactions, then write the equilibrium equations. Whether you are finding the reactions of a simply supported beam, checking a cantilever retaining wall, or analyzing forces at a bolted connection, the process is the same three equations: $\\sum F_x = 0$, $\\sum F_y = 0$, $\\sum M = 0$. The FE tests whether you can draw a correct FBD, identify the right number and type of support reactions, and solve for unknowns. Getting the FBD wrong means every calculation afterward is wrong.',
  content: [
    {
      type: 'text',
      body: 'Equilibrium means an object is not accelerating. For a rigid body in static equilibrium, the sum of all forces and the sum of all moments about any point must both be zero.',
    },
    { type: 'heading', body: 'Equilibrium Equations (2D)' },
    {
      type: 'formula',
      latex: '\\sum F_x = 0 \\qquad \\sum F_y = 0 \\qquad \\sum M_O = 0',
      label: '2D Equilibrium Equations',
    },
    {
      type: 'text',
      body: 'Three equations, three unknowns maximum. If a problem has more than three unknown reaction forces, it is statically indeterminate and requires additional equations (compatibility conditions from Mechanics of Materials).',
    },
    { type: 'heading', body: 'Free Body Diagrams' },
    {
      type: 'text',
      body: 'A free body diagram isolates the object from its supports and replaces each support with the reaction forces it provides. Getting this step right is the single most important skill in statics.',
    },
    {
      type: 'text',
      body: 'Common 2D supports: a roller provides 1 reaction (perpendicular to the surface), a pin provides 2 reactions ($R_x$ and $R_y$), and a fixed support provides 3 reactions ($R_x$, $R_y$, and a moment $M$).',
    },
    {
      type: 'callout',
      variant: 'exam',
      body: 'The FE will not tell you to draw an FBD \u2014 it will just ask for reactions or forces. But your first step should always be sketching one. Mark every external force, every support reaction, and every applied moment before writing any equations.',
    },
    { type: 'heading', body: 'Strategy for Solving' },
    {
      type: 'text',
      body: 'Start by summing moments about a point where two unknowns intersect \u2014 this eliminates them and gives you a single equation with one unknown. Then use the force sum equations to find the remaining reactions.',
    },
    {
      type: 'callout',
      variant: 'tip',
      body: 'When choosing a moment point, pick a location where as many unknown forces as possible pass through that point. Their moment arms become zero, simplifying the equation.',
    },
    {
      type: 'callout',
      variant: 'warning',
      body: 'A common FBD mistake: forgetting the direction of a roller reaction. A roller can only push, never pull. If your solution gives a negative roller reaction, recheck the problem setup \u2014 it usually means you drew the FBD wrong or made a sign error.',
    },
  ],
  illustration: null,
  problems: [
    {
      id: 'stat-efb-q1',
      statement:
        'A simply supported beam spans 8 m. A single concentrated load of 12 kN acts 3 m from the left support (A). Support A is a pin and support B is a roller. What is the vertical reaction at support B?',
      choices: [
        { id: 'c1', text: '4.5 kN' },
        { id: 'c2', text: '7.5 kN' },
        { id: 'c3', text: '6.0 kN' },
        { id: 'c4', text: '12.0 kN' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'easy',
      eli5: 'Sum moments about point A to eliminate both reactions at A. The only forces creating moments about A are the 12 kN load at 3 m and the roller reaction at B at 8 m. Set the sum to zero: $12 \\times 3 = B_y \\times 8$, so $B_y = 4.5$ kN. Answer B (7.5 kN) is the reaction at support A, not B \u2014 a classic trap where you solve correctly but report the wrong support. Answer C (6.0 kN) splits the load in half, which would only be right if the load were at midspan. Answer D puts the entire load on one support, ignoring equilibrium entirely.',
      hint: 'Sum moments about the pin support to eliminate two unknowns at once. Be sure to report the reaction at B, not A.',
      steps: [
        {
          text: 'FBD: pin at A ($A_x$, $A_y$), roller at B ($B_y$), 12 kN load at 3 m from A.',
          latex: null,
        },
        {
          text: 'Sum moments about A (eliminates $A_x$ and $A_y$):',
          latex: '\\sum M_A = 0',
        },
        {
          text: 'The 12 kN load acts 3 m from A (clockwise), and $B_y$ acts 8 m from A (counterclockwise):',
          latex: '12 \\times 3 - B_y \\times 8 = 0',
        },
        {
          text: 'Solve:',
          latex: 'B_y = \\frac{36}{8} = 4.5 \\text{ kN}',
        },
        {
          text: 'Check: $A_y = 12 - 4.5 = 7.5$ kN. Answer B is the reaction at A, not B.',
          latex: null,
        },
      ],
      handbookPage: 'p. 94, Equilibrium Requirements',
      handbookFormula: '\\sum F_x = 0 \\quad \\sum F_y = 0 \\quad \\sum M = 0',
      videoUrl: null,
      traps: [
        'Reporting the reaction at the wrong support \u2014 read the question carefully to see which support it asks for',
        'Splitting the load evenly between supports \u2014 this is only valid when the load is at midspan',
      ],
      diagram: { component: 'SimplySupportedBeam', props: { span: 8, loadPos: 3, load: 12 } },
    },
    {
      id: 'stat-efb-q2',
      statement:
        'A cantilever beam is 4 m long with a fixed support at the left end. It carries a uniformly distributed load of 3 kN/m over its entire length. What are the vertical reaction and the fixed-end moment at the support?',
      choices: [
        { id: 'c1', text: '$R_y = 12$ kN, $M = 24$ kN\\cdot m' },
        { id: 'c2', text: '$R_y = 12$ kN, $M = 48$ kN\\cdot m' },
        { id: 'c3', text: '$R_y = 6$ kN, $M = 12$ kN\\cdot m' },
        { id: 'c4', text: '$R_y = 12$ kN, $M = 12$ kN\\cdot m' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'medium',
      eli5: 'A distributed load of 3 kN/m over 4 m has a total force of $3 \\times 4 = 12$ kN, acting at the centroid of the load (midpoint of the beam = 2 m from the support). The vertical reaction equals the total load (12 kN). The fixed-end moment resists the moment of that resultant about the support: $M = 12 \\times 2 = 24$ kN\\cdot m. Answer B (48 kN\\cdot m) uses the full beam length (4 m) as the moment arm instead of the centroid distance (2 m). Answer C uses half the load as if only half the beam were loaded. Answer D gets the reaction right but uses 1 m instead of 2 m for the moment arm.',
      hint: 'Replace the distributed load with its resultant (total force at the centroid). Where does the centroid of a uniform load act?',
      steps: [
        {
          text: 'Total load:',
          latex: 'W = 3 \\times 4 = 12 \\text{ kN, acting at the centroid (2 m from the fixed end)}',
        },
        {
          text: 'Vertical equilibrium:',
          latex: 'R_y = W = 12 \\text{ kN (upward)}',
        },
        {
          text: 'Moment equilibrium about the support:',
          latex: 'M = W \\times \\bar{x} = 12 \\times 2 = 24 \\text{ kN\\cdot m}',
        },
        {
          text: 'Answer B (48 kN\\cdot m) uses the full length 4 m as the moment arm: $12 \\times 4 = 48$. The resultant acts at the centroid (2 m), not at the tip.',
          latex: null,
        },
      ],
      handbookPage: 'p. 94, Equilibrium Requirements',
      handbookFormula: '\\sum F_y = 0 \\quad \\sum M = 0',
      videoUrl: null,
      traps: [
        'Using the full beam length instead of the centroid distance for the moment arm of a distributed load',
        'Forgetting that a fixed support has a moment reaction in addition to force reactions',
      ],
      diagram: { component: 'CantileverBeam', props: { length: 4, loadIntensity: 3 } },
    },
    {
      id: 'stat-efb-q3',
      statement:
        'A beam AB is 10 m long, supported by a pin at A and a roller at B. It carries a 20 kN concentrated load at 4 m from A and a 10 kN\\cdot m counterclockwise couple applied at 7 m from A. What is the vertical reaction at A?',
      choices: [
        { id: 'c1', text: '12.0 kN' },
        { id: 'c2', text: '13.0 kN' },
        { id: 'c3', text: '11.0 kN' },
        { id: 'c4', text: '8.0 kN' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'hard',
      eli5: 'This problem has both a force and a couple (pure moment). The couple has no net force \u2014 it only shows up in the moment equation, not the force equations. Sum moments about A to find $B_y$ first: the 20 kN load at 4 m creates a clockwise moment of 80, and the CCW couple adds 10 in the opposite direction. So $B_y = (80 - 10)/10 = 7$ kN. Then from $\\sum F_y = 0$: $A_y = 20 - 7 = 13$ kN. Answer A (12.0 kN) ignores the couple entirely: $20 \\times 6 / 10 = 12$. Answer C (11.0 kN) gets the couple sign wrong, subtracting it from the wrong side.',
      hint: 'A couple contributes to the moment equation but not to the force equations. Sum moments about one support, then use $\\sum F_y = 0$ to find the other reaction.',
      steps: [
        {
          text: 'FBD: pin at A ($A_x$, $A_y$), roller at B ($B_y$), 20 kN downward at 4 m from A, 10 kN\\cdot m CCW couple at 7 m from A.',
          latex: null,
        },
        {
          text: 'Sum moments about A (CCW positive):',
          latex: '\\sum M_A = 0',
        },
        {
          text: 'The 20 kN load at 4 m creates a CW moment ($-$), $B_y$ at 10 m creates a CCW moment ($+$), and the couple is CCW ($+$):',
          latex: '-20(4) + B_y(10) + 10 = 0',
        },
        {
          text: 'Solve for $B_y$:',
          latex: '10\\,B_y = 80 - 10 = 70 \\quad \\Rightarrow \\quad B_y = 7.0 \\text{ kN}',
        },
        {
          text: 'Use vertical equilibrium to find $A_y$:',
          latex: 'A_y + B_y = 20 \\quad \\Rightarrow \\quad A_y = 20 - 7 = 13.0 \\text{ kN}',
        },
        {
          text: 'Answer A (12.0 kN) ignores the couple: $B_y = 80/10 = 8$, $A_y = 12$. The couple shifts 1 kN from B to A.',
          latex: null,
        },
      ],
      handbookPage: 'p. 94, Equilibrium Requirements; Moments',
      handbookFormula: '\\sum M = 0',
      videoUrl: null,
      traps: [
        'Ignoring the couple in the moment equation \u2014 it contributes directly regardless of where it is located on the beam',
        'Getting the sign of the couple wrong \u2014 a counterclockwise couple is positive if your convention is CCW positive',
      ],
      diagram: { component: 'BeamWithCouple', props: { span: 10, loadPos: 4, load: 20, couplePos: 7, couple: 10 } },
    },
  ],
  examProblems: [
    {
      id: 'stat-efb-ex1',
      type: 'computational',
      statement:
        'A simply supported beam spans 6 m with a pin at A (left) and a roller at B (right). A single 18 kN downward load acts at 2 m from A. What is the vertical reaction at A?',
      choices: [
        { id: 'c1', text: '12.0 kN' },
        { id: 'c2', text: '6.0 kN' },
        { id: 'c3', text: '9.0 kN' },
        { id: 'c4', text: '18.0 kN' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'easy',
      eli5: 'Sum moments about B to eliminate the reaction at B. The 18 kN load is 4 m from B, and $A_y$ is 6 m from B. So $A_y \\times 6 = 18 \\times 4$, giving $A_y = 12$ kN. Answer B (6 kN) is the reaction at B, not A -- a classic trap of solving correctly but reporting the wrong support. Answer C (9 kN) splits the load evenly, which only works when the load is at midspan. Answer D puts the full load on one support.',
      hint: 'Sum moments about B so the unknown $B_y$ drops out. Make sure you report $A_y$, not $B_y$.',
      steps: [
        {
          text: 'FBD: pin at A ($A_x$, $A_y$), roller at B ($B_y$), 18 kN at 2 m from A (4 m from B).',
          latex: null,
        },
        {
          text: 'Sum moments about B (eliminates $B_y$):',
          latex: '\\sum M_B = 0: \\quad A_y(6) - 18(4) = 0',
        },
        {
          text: 'Solve:',
          latex: 'A_y = \\frac{72}{6} = 12.0 \\text{ kN}',
        },
        {
          text: 'Check: $B_y = 18 - 12 = 6$ kN. Answer B is the reaction at B, not A.',
          latex: null,
        },
      ],
      handbookPage: 'p. 94, Equilibrium Requirements',
      handbookFormula: '\\sum F_n = 0 \\quad \\sum M_n = 0',
      videoUrl: null,
      traps: [
        'Reporting the reaction at B instead of A',
        'Splitting the load equally between supports when the load is not at midspan',
      ],
      diagram: null,
    },
    {
      id: 'stat-efb-ex2',
      type: 'computational',
      statement:
        'A simply supported beam AB is 12 m long (pin at A, roller at B). It carries a uniformly distributed load of 5 kN/m over the left half (from A to the midpoint at 6 m). What is the vertical reaction at B?',
      choices: [
        { id: 'c1', text: '7.5 kN' },
        { id: 'c2', text: '15.0 kN' },
        { id: 'c3', text: '22.5 kN' },
        { id: 'c4', text: '30.0 kN' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'medium',
      eli5: 'Replace the partial UDL with its resultant: $5 \\times 6 = 30$ kN acting at the centroid of the loaded region, which is 3 m from A. Sum moments about A: $B_y \\times 12 = 30 \\times 3$, so $B_y = 7.5$ kN. Answer B (15 kN) splits the total load in half, as if it were centered. Answer C (22.5 kN) is the reaction at A. Answer D (30 kN) puts the entire load on one support.',
      hint: 'Replace the distributed load with its resultant at the centroid of the loaded region (not the centroid of the entire beam).',
      steps: [
        {
          text: 'Resultant of the UDL:',
          latex: 'W = 5 \\times 6 = 30 \\text{ kN, acting at } \\bar{x} = 3 \\text{ m from A}',
        },
        {
          text: 'Sum moments about A:',
          latex: '\\sum M_A = 0: \\quad B_y(12) - 30(3) = 0',
        },
        {
          text: 'Solve:',
          latex: 'B_y = \\frac{90}{12} = 7.5 \\text{ kN}',
        },
        {
          text: 'Check: $A_y = 30 - 7.5 = 22.5$ kN. The load is closer to A, so A carries more -- consistent.',
          latex: null,
        },
      ],
      handbookPage: 'p. 94, Equilibrium Requirements',
      handbookFormula: '\\sum F_n = 0 \\quad \\sum M_n = 0',
      videoUrl: null,
      traps: [
        'Placing the resultant at the midpoint of the beam instead of at the centroid of the loaded portion',
        'Splitting the total load evenly between both supports',
      ],
      diagram: null,
    },
    {
      id: 'stat-efb-ex3',
      type: 'computational',
      statement:
        'A cantilever beam is 5 m long with a fixed support at the left end. It carries a triangular distributed load that varies linearly from 0 at the fixed end to 8 kN/m at the free end. What is the fixed-end moment reaction?',
      choices: [
        { id: 'c1', text: '66.7 kN\\cdot m' },
        { id: 'c2', text: '40.0 kN\\cdot m' },
        { id: 'c3', text: '20.0 kN\\cdot m' },
        { id: 'c4', text: '100.0 kN\\cdot m' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'medium',
      eli5: 'A triangular load has a resultant equal to half the base times the peak intensity: $W = \\frac{1}{2}(5)(8) = 20$ kN. The centroid of a triangle is at one-third from the wide end, which is $5 - 5/3 = 10/3$ m from the fixed end. The moment is $M = 20 \\times 10/3 = 66.7$ kN-m. Answer B (40 kN-m) places the resultant at the midpoint ($20 \\times 2 = 40$) instead of at the one-third point. Answer C (20 kN-m) places the resultant at 1 m from the support. Answer D (100 kN-m) treats the load as uniform at 8 kN/m over 5 m ($40 \\times 2.5 = 100$).',
      hint: 'The resultant of a triangular load is $\\frac{1}{2} \\times L \\times w_{max}$, and it acts at the centroid of the triangle (one-third from the wide end).',
      steps: [
        {
          text: 'Resultant of the triangular load:',
          latex: 'W = \\frac{1}{2}(5)(8) = 20 \\text{ kN}',
        },
        {
          text: 'Centroid location: one-third from the wide end (free tip), so two-thirds from the narrow end (support):',
          latex: '\\bar{x} = \\frac{2}{3}(5) = \\frac{10}{3} \\text{ m from the fixed end}',
        },
        {
          text: 'Fixed-end moment (moment equilibrium about the support):',
          latex: 'M = W \\times \\bar{x} = 20 \\times \\frac{10}{3} = 66.7 \\text{ kN\\cdot m}',
        },
        {
          text: 'Answer B (40 kN-m) uses the midpoint (2.5 m) as the centroid: $20 \\times 2 = 40$. Triangular load centroids are at the one-third point, not the midpoint.',
          latex: null,
        },
      ],
      handbookPage: 'p. 94, Equilibrium Requirements; p. 95, Centroids',
      handbookFormula: '\\sum M_n = 0',
      videoUrl: null,
      traps: [
        'Using the midpoint instead of the one-third point for the centroid of a triangular load',
        'Treating the triangular load as uniform at the peak intensity',
      ],
      diagram: null,
    },
    {
      id: 'stat-efb-ex4',
      type: 'conceptual',
      statement:
        'A 2D rigid body is supported by a pin and a roller. How many independent scalar equilibrium equations are available, and how many unknown reaction components can be solved?',
      choices: [
        { id: 'c1', text: '3 equations, 3 unknowns' },
        { id: 'c2', text: '2 equations, 2 unknowns' },
        { id: 'c3', text: '3 equations, 2 unknowns' },
        { id: 'c4', text: '6 equations, 6 unknowns' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'hard',
      eli5: 'In 2D statics, there are exactly three independent equilibrium equations: $\\sum F_x = 0$, $\\sum F_y = 0$, and $\\sum M = 0$. A pin provides two reaction components ($R_x$, $R_y$) and a roller provides one ($R_\\perp$), giving three unknowns total. Three equations and three unknowns means the system is statically determinate. Answer B forgets the moment equation. Answer C has the right equation count but undercounts unknowns (a pin alone has two). Answer D applies to 3D equilibrium, not 2D.',
      hint: 'Count the equations from 2D equilibrium and the unknowns from the support types: a pin gives 2 reactions, a roller gives 1.',
      steps: [
        {
          text: '2D equilibrium provides three independent scalar equations:',
          latex: '\\sum F_x = 0, \\quad \\sum F_y = 0, \\quad \\sum M = 0',
        },
        {
          text: 'A pin support provides two reaction components ($R_x$ and $R_y$). A roller provides one reaction component (perpendicular to the rolling surface).',
          latex: null,
        },
        {
          text: 'Total unknowns: $2 + 1 = 3$. Three equations and three unknowns means the structure is statically determinate.',
          latex: null,
        },
        {
          text: 'If there were more unknowns than equations, the structure would be statically indeterminate and you would need compatibility equations from Mechanics of Materials.',
          latex: null,
        },
      ],
      handbookPage: 'p. 94, Equilibrium Requirements',
      handbookFormula: '\\sum F_n = 0 \\quad \\sum M_n = 0',
      videoUrl: null,
      traps: [
        'Forgetting the moment equation and counting only two equilibrium equations',
        'Confusing 2D equilibrium (3 equations) with 3D equilibrium (6 equations)',
      ],
      diagram: null,
    },
  ],
};
