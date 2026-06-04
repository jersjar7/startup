export default {
  id: 'friction',
  name: 'Friction',
  subtopicId: 'trusses-and-friction',
  application:
    'Friction problems on the FE test whether you understand the difference between static and kinetic friction, can identify when impending motion occurs, and can apply the belt friction and screw-jack formulas. Civil engineers check friction when designing retaining walls against sliding, analyzing braking forces on highway grades, and sizing belt-driven equipment. The handbook (pp. 96\u201397) covers static friction ($F \\leq \\mu_s N$), screw-jack mechanics, and belt friction. Expect one friction problem on the exam \u2014 it is usually straightforward if you set up the normal force correctly.',
  content: [
    {
      type: 'text',
      body: 'Friction resists the tendency of two surfaces to slide relative to each other. The maximum static friction force depends on the normal force and the coefficient of static friction.',
    },
    { type: 'heading', body: 'Static Friction' },
    {
      type: 'formula',
      latex: 'F \\leq \\mu_s N',
      label: 'Static Friction Inequality',
    },
    {
      type: 'text',
      body: 'The friction force $F$ can be anything from zero up to $\\mu_s N$. It only equals $\\mu_s N$ at the point of impending motion. Until then, friction adjusts to match the applied force.',
    },
    {
      type: 'callout',
      variant: 'warning',
      body: 'Do not assume $F = \\mu_s N$ unless the problem says the object is about to move or asks for the maximum force before sliding. If the object is stationary and not on the verge of moving, friction could be less than $\\mu_s N$.',
    },
    { type: 'heading', body: 'Belt Friction' },
    {
      type: 'formula',
      latex: 'F_1 = F_2\\, e^{\\mu\\theta}',
      label: 'Belt Friction (Capstan Equation)',
    },
    {
      type: 'text',
      body: '$F_1$ is the tension on the tight side (direction of impending motion), $F_2$ is the tension on the slack side, $\\mu$ is the coefficient of friction, and $\\theta$ is the total angle of contact in radians. The exponential relationship means even a small $\\mu$ over many wraps creates enormous holding force.',
    },
    { type: 'heading', body: 'Screw Thread (Screw-Jack)' },
    {
      type: 'formula',
      latex: 'M = Pr\\tan(\\alpha \\pm \\phi)',
      label: 'Screw-Jack Moment',
    },
    {
      type: 'text',
      body: '$P$ is the axial load, $r$ is the mean thread radius, $\\alpha$ is the pitch angle, and $\\phi = \\arctan\\mu$ where $\\mu$ is the coefficient of friction. Use $+$ for tightening (raising the load) and $-$ for loosening (lowering the load).',
    },
    {
      type: 'callout',
      variant: 'tip',
      body: 'For belt friction, always identify which side is the tight side ($F_1$) \u2014 it is the side in the direction the belt is trying to slip. The angle $\\theta$ must be in radians, not degrees.',
    },
    {
      type: 'callout',
      variant: 'exam',
      body: 'The handbook (p. 96) gives the belt friction formula with $F_1$ as the force in the direction of impending motion. If the problem describes a pulley or capstan, identify the tight and slack sides before plugging in.',
    },
  ],
  illustration: null,
  problems: [
    {
      id: 'stat-fri-q1',
      statement:
        'A 500 N crate sits on a flat concrete floor. The coefficient of static friction between the crate and the floor is 0.40. What is the maximum horizontal force that can be applied to the crate before it begins to slide?',
      choices: [
        { id: 'c1', text: '1,250 N' },
        { id: 'c2', text: '500 N' },
        { id: 'c3', text: '125 N' },
        { id: 'c4', text: '200 N' },
      ],
      correctAnswerId: 'c4',
      difficulty: 'easy',
      eli5: 'On a flat floor, the normal force equals the weight (500 N). The maximum friction force before sliding is $\\mu_s \\times N = 0.40 \\times 500 = 200$ N. The 500 N choice uses the full weight as the friction force, which would require $\\mu_s = 1$. The 125 N choice divides weight by 4 instead of multiplying by 0.40. The 1,250 N choice divides the weight by the coefficient instead of multiplying.',
      hint: 'On a flat surface, the normal force equals the weight. Maximum friction = $\\mu_s \\times N$.',
      steps: [
        {
          text: 'Normal force on a flat surface:',
          latex: 'N = W = 500 \\text{ N}',
        },
        {
          text: 'Maximum static friction:',
          latex: 'F_{\\max} = \\mu_s N = 0.40 \\times 500 = 200 \\text{ N}',
        },
        {
          text: 'Any horizontal force less than 200 N will be resisted by friction. At exactly 200 N, the crate is on the verge of sliding.',
          latex: null,
        },
      ],
      handbookPage: 'p. 96, Friction',
      handbookFormula: 'F \\leq \\mu_s N',
      videoUrl: null,
      traps: [
        'Forgetting that the normal force equals the weight only on a flat surface \u2014 on an incline, $N = W\\cos\\theta$',
        'Dividing by $\\mu$ instead of multiplying \u2014 getting 1,250 N instead of 200 N',
      ],
      diagram: { component: 'BlockFlat', props: { weight: 500, mu: 0.40 } },
    },
    {
      id: 'stat-fri-q2',
      statement:
        'A flat belt wraps 180 degrees around a pulley. The coefficient of friction between the belt and pulley is 0.30. If the tension on the slack side is 200 N, what is the maximum tension on the tight side before the belt slips?',
      choices: [
        { id: 'c1', text: '260 N' },
        { id: 'c2', text: '513 N' },
        { id: 'c3', text: '320 N' },
        { id: 'c4', text: '200 N' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'medium',
      eli5: 'Belt friction is exponential, not linear \u2014 that is the key insight. The tight side tension equals the slack side times $e^{\\mu\\theta}$. With $\\mu = 0.30$ and $\\theta = \\pi$ radians (180 degrees), you get $F_1 = 200 \\times e^{0.30\\pi} = 200 \\times 2.566 = 513$ N. The 260 N option treats friction as a simple percentage add-on ($200 + 0.30 \\times 200 = 260$), ignoring the exponential. The 320 N option uses 90 degrees ($\\pi/2$) instead of 180 degrees ($\\pi$) for the contact angle. The 200 N option assumes the belt cannot transmit any additional force through friction.',
      hint: 'Convert the contact angle to radians before using the belt friction formula. 180 degrees = $\\pi$ radians.',
      steps: [
        {
          text: 'Identify: $F_2 = 200$ N (slack side), $\\mu = 0.30$, $\\theta = 180\\degree = \\pi$ radians.',
          latex: null,
        },
        {
          text: 'Apply the belt friction formula:',
          latex: 'F_1 = F_2\\, e^{\\mu\\theta} = 200 \\times e^{0.30 \\times \\pi}',
        },
        {
          text: 'Compute the exponent:',
          latex: 'e^{0.9425} = 2.566',
        },
        {
          text: 'Solve:',
          latex: 'F_1 = 200 \\times 2.566 = 513 \\text{ N}',
        },
        {
          text: 'TI-36X Pro: type $200 \\times e^{(0.30 \\times \\pi)}$ and press $=$.',
          latex: null,
        },
      ],
      handbookPage: 'p. 96, Belt Friction',
      handbookFormula: 'F_1 = F_2\\, e^{\\mu\\theta}',
      videoUrl: null,
      traps: [
        'Using degrees instead of radians for the contact angle \u2014 180 degrees must become $\\pi$ radians',
        'Adding friction linearly ($F_2 + \\mu F_2$) instead of using the exponential relationship',
      ],
      diagram: { component: 'BeltPulley', props: { mu: 0.30, slackT: 200, wrapDeg: 180 } },
    },
    {
      id: 'stat-fri-q3',
      statement:
        'A block weighing 800 N rests on a ramp inclined at 25 degrees. The coefficient of static friction is 0.50. A horizontal force $P$ is applied to push the block up the ramp. What is the minimum value of $P$ to start the block moving upward?',
      choices: [
        { id: 'c1', text: '338 N' },
        { id: 'c2', text: '773 N' },
        { id: 'c3', text: '1,008 N' },
        { id: 'c4', text: '400 N' },
      ],
      correctAnswerId: 'c3',
      difficulty: 'hard',
      eli5: 'The tricky part is that the horizontal push $P$ does two things simultaneously: it has a component up the ramp ($P\\cos 25\\degree$) that helps push the block, but it also has a component into the ramp surface ($P\\sin 25\\degree$) that increases the normal force and therefore increases friction. You must account for both. Set up equilibrium along the ramp: the up-ramp component of $P$ must overcome the weight component down the ramp plus friction. Solving gives $P = 1{,}008$ N. The 338 N choice is just the weight component down the ramp ($800\\sin 25\\degree$), ignoring friction entirely. The 773 N choice forgets that $P$ increases the normal force, underestimating friction. The 400 N choice uses a flat-surface friction calculation ($\\mu \\times W$).',
      hint: 'The horizontal force $P$ has components both along and perpendicular to the ramp. The perpendicular component increases the normal force, which increases friction.',
      steps: [
        {
          text: 'Resolve weight along and perpendicular to the ramp:',
          latex: 'W_x = 800\\sin 25\\degree = 338 \\text{ N (down ramp)}, \\quad W_y = 800\\cos 25\\degree = 725 \\text{ N (into surface)}',
        },
        {
          text: 'Resolve $P$ along and perpendicular to the ramp:',
          latex: 'P_x = P\\cos 25\\degree \\text{ (up ramp)}, \\quad P_y = P\\sin 25\\degree \\text{ (into surface)}',
        },
        {
          text: 'Normal force includes contributions from both weight and $P$:',
          latex: 'N = 725 + P\\sin 25\\degree',
        },
        {
          text: 'Friction opposing upward motion:',
          latex: 'F = 0.50(725 + P\\sin 25\\degree)',
        },
        {
          text: 'Equilibrium along the ramp:',
          latex: 'P\\cos 25\\degree = 338 + 0.50(725 + P\\sin 25\\degree)',
        },
        {
          text: 'Solve for $P$:',
          latex: 'P(0.906 - 0.211) = 338 + 362.5 = 700.5 \\quad \\Rightarrow \\quad P = \\frac{700.5}{0.695} = 1{,}008 \\text{ N}',
        },
      ],
      handbookPage: 'p. 96, Friction',
      handbookFormula: 'F \\leq \\mu_s N',
      videoUrl: null,
      traps: [
        'Forgetting that $P$ has a component perpendicular to the ramp that changes the normal force',
        'Using the weight as the normal force \u2014 on an incline with a horizontal push, $N$ depends on both $W$ and $P$',
      ],
      diagram: { component: 'BlockOnRamp', props: { weight: 800, angle: 25, mu: 0.50 } },
    },
  ],
};
