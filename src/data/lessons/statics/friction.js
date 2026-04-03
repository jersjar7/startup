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
        { id: 'c1', text: '200 N' },
        { id: 'c2', text: '500 N' },
        { id: 'c3', text: '125 N' },
        { id: 'c4', text: '1,250 N' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'easy',
      eli5: 'On a flat floor, the normal force equals the weight (500 N). The maximum friction force before sliding is $\\mu_s \\times N = 0.40 \\times 500 = 200$ N. Answer B (500 N) uses the full weight as the friction force, which would require $\\mu_s = 1$. Answer C (125 N) divides weight by 4 instead of multiplying by 0.40. Answer D (1,250 N) divides the weight by the coefficient instead of multiplying.',
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
      eli5: 'Belt friction is exponential, not linear \u2014 that is the key insight. The tight side tension equals the slack side times $e^{\\mu\\theta}$. With $\\mu = 0.30$ and $\\theta = \\pi$ radians (180 degrees), you get $F_1 = 200 \\times e^{0.30\\pi} = 200 \\times 2.566 = 513$ N. Answer A (260 N) treats friction as a simple percentage add-on ($200 + 0.30 \\times 200 = 260$), ignoring the exponential. Answer C (320 N) uses 90 degrees ($\\pi/2$) instead of 180 degrees ($\\pi$) for the contact angle. Answer D assumes the belt cannot transmit any additional force through friction.',
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
      eli5: 'The tricky part is that the horizontal push $P$ does two things simultaneously: it has a component up the ramp ($P\\cos 25\\degree$) that helps push the block, but it also has a component into the ramp surface ($P\\sin 25\\degree$) that increases the normal force and therefore increases friction. You must account for both. Set up equilibrium along the ramp: the up-ramp component of $P$ must overcome the weight component down the ramp plus friction. Solving gives $P = 1{,}008$ N. Answer A (338 N) is just the weight component down the ramp ($800\\sin 25\\degree$), ignoring friction entirely. Answer B (773 N) forgets that $P$ increases the normal force, underestimating friction. Answer D (400 N) uses a flat-surface friction calculation ($\\mu \\times W$).',
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
  examProblems: [
    {
      id: 'stat-fri-ex1',
      type: 'computational',
      statement:
        'A 300 N box sits on a flat surface with $\\mu_s = 0.35$. A horizontal pull of 80 N is applied. What is the friction force acting on the box?',
      choices: [
        { id: 'c1', text: '80 N' },
        { id: 'c2', text: '105 N' },
        { id: 'c3', text: '300 N' },
        { id: 'c4', text: '0 N' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'easy',
      eli5: 'The maximum static friction is $\\mu_s N = 0.35 \\times 300 = 105$ N. The applied force is only 80 N, which is less than the maximum. Since the box is not on the verge of moving, friction matches the applied force exactly: $F = 80$ N. Answer B (105 N) is the maximum possible friction, but the box is not about to slide so friction does not reach that value. Answer C uses the full weight. Answer D incorrectly assumes no friction acts.',
      hint: 'Check whether the applied force exceeds $\\mu_s N$. If it does not, friction equals the applied force.',
      steps: [
        {
          text: 'Maximum static friction:',
          latex: 'F_{\\max} = \\mu_s N = 0.35 \\times 300 = 105 \\text{ N}',
        },
        {
          text: 'Applied force = 80 N < 105 N, so the box does not move.',
          latex: null,
        },
        {
          text: 'When the box is stationary and below the slip threshold, friction equals the applied force:',
          latex: 'F_{\\text{friction}} = 80 \\text{ N}',
        },
      ],
      handbookPage: 'p. 96, Friction',
      handbookFormula: 'F \\leq \\mu_s N',
      videoUrl: null,
      traps: [
        'Using $\\mu_s N$ as the friction force when the object is not on the verge of sliding',
        'Assuming friction always equals the maximum value -- it only does at impending motion',
      ],
      diagram: null,
    },
    {
      id: 'stat-fri-ex2',
      type: 'computational',
      statement:
        'A flat belt wraps 270 degrees around a fixed drum. The coefficient of friction is 0.25. If the tension on the slack side is 150 N, what is the maximum tension on the tight side before the belt slips? (Use $e^{1.18} = 3.25$.)',
      choices: [
        { id: 'c1', text: '487 N' },
        { id: 'c2', text: '263 N' },
        { id: 'c3', text: '188 N' },
        { id: 'c4', text: '150 N' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'medium',
      eli5: 'Belt friction uses the capstan equation: $F_1 = F_2 e^{\\mu\\theta}$. Convert 270 degrees to radians: $\\theta = 3\\pi/2 = 4.712$ rad. The exponent is $\\mu\\theta = 0.25 \\times 4.712 = 1.178$, and $e^{1.178} \\approx 3.25$. So $F_1 = 150 \\times 3.25 = 487$ N. Answer B (263 N) uses 90 degrees instead of 270 degrees for the wrap angle. Answer C (188 N) treats friction as a linear add-on ($150 + 0.25 \\times 150 = 187.5$). Answer D assumes no friction amplification at all.',
      hint: 'Convert the contact angle to radians (270 degrees = $3\\pi/2$), then apply the belt friction formula $F_1 = F_2 e^{\\mu\\theta}$.',
      steps: [
        {
          text: 'Identify: $F_2 = 150$ N (slack side), $\\mu = 0.25$, $\\theta = 270\\degree = \\frac{3\\pi}{2}$ radians.',
          latex: null,
        },
        {
          text: 'Compute the exponent:',
          latex: '\\mu\\theta = 0.25 \\times \\frac{3\\pi}{2} = 0.25 \\times 4.712 = 1.178',
        },
        {
          text: 'Apply the belt friction formula:',
          latex: 'F_1 = 150 \\times e^{1.178} = 150 \\times 3.25 = 487 \\text{ N}',
        },
        {
          text: 'The exponential amplification is substantial: a 270-degree wrap with $\\mu = 0.25$ multiplies the slack-side tension by about 3.25 times.',
          latex: null,
        },
      ],
      handbookPage: 'p. 96, Belt Friction',
      handbookFormula: 'F_1 = F_2\\, e^{\\mu\\theta}',
      videoUrl: null,
      traps: [
        'Using degrees instead of radians for the contact angle',
        'Adding friction linearly instead of using the exponential relationship',
      ],
      diagram: null,
    },
    {
      id: 'stat-fri-ex3',
      type: 'computational',
      statement:
        'A 600 N block rests on a 30-degree incline. The coefficient of static friction is 0.45. What minimum force, applied parallel to and up the incline, is needed to start the block sliding upward?',
      choices: [
        { id: 'c1', text: '533.8 N' },
        { id: 'c2', text: '300.0 N' },
        { id: 'c3', text: '270.0 N' },
        { id: 'c4', text: '233.8 N' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'medium',
      eli5: 'To push the block up, you must overcome both the weight component pulling it down the ramp and the friction resisting upward motion. Weight down the ramp: $W\\sin 30\\degree = 300$ N. Normal force: $N = W\\cos 30\\degree = 519.6$ N. Maximum friction: $\\mu_s N = 0.45 \\times 519.6 = 233.8$ N. The total force needed is $P = 300 + 233.8 = 533.8$ N. Answer B (300 N) only accounts for the gravity component and ignores friction. Answer D (233.8 N) is the friction force alone, forgetting that gravity also resists upward motion. Answer C (270 N) incorrectly uses $\\mu_s W$ as the friction force.',
      hint: 'Resolve the weight into components along and perpendicular to the surface. To push up the ramp, $P$ must overcome both the gravity component and friction.',
      steps: [
        {
          text: 'Weight components on the incline:',
          latex: 'W_{\\parallel} = 600\\sin 30\\degree = 300 \\text{ N}, \\quad W_{\\perp} = 600\\cos 30\\degree = 519.6 \\text{ N}',
        },
        {
          text: 'Normal force and maximum friction:',
          latex: 'N = 519.6 \\text{ N}, \\quad F = \\mu_s N = 0.45 \\times 519.6 = 233.8 \\text{ N}',
        },
        {
          text: 'For impending upward motion, the applied force $P$ must equal the gravity component plus friction (both act down the ramp):',
          latex: 'P = W_{\\parallel} + F = 300 + 233.8 = 533.8 \\text{ N}',
        },
        {
          text: 'Answer D (233.8 N) is only the friction force. Answer B (300 N) ignores friction entirely.',
          latex: null,
        },
      ],
      handbookPage: 'p. 96, Friction',
      handbookFormula: 'F \\leq \\mu_s N',
      videoUrl: null,
      traps: [
        'Forgetting to include the weight component down the ramp -- friction alone is not the total resistance',
        'Using the full weight (600 N) as the normal force instead of $W\\cos\\theta$',
      ],
      diagram: null,
    },
    {
      id: 'stat-fri-ex4',
      type: 'conceptual',
      statement:
        'A block sits on a rough incline. The angle of the incline is slowly increased until the block just begins to slide. At the moment of impending motion, which relationship correctly describes the angle $\\theta$ and the coefficient of static friction $\\mu_s$?',
      choices: [
        { id: 'c1', text: '$\\tan\\theta = \\mu_s$' },
        { id: 'c2', text: '$\\sin\\theta = \\mu_s$' },
        { id: 'c3', text: '$\\cos\\theta = \\mu_s$' },
        { id: 'c4', text: '$\\theta = \\mu_s$' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'hard',
      eli5: 'At impending motion on an incline, the friction force equals $\\mu_s N$. The weight component along the ramp is $W\\sin\\theta$ and the normal force is $N = W\\cos\\theta$. Setting friction equal to the gravity component: $\\mu_s W\\cos\\theta = W\\sin\\theta$. Cancel $W$: $\\mu_s = \\sin\\theta/\\cos\\theta = \\tan\\theta$. This angle is called the angle of repose. It is a classic result: the friction coefficient equals the tangent of the steepest angle at which the block can sit without sliding. Answer B ($\\sin\\theta = \\mu_s$) incorrectly omits the cosine in the normal force. Answer C ($\\cos\\theta = \\mu_s$) inverts the relationship. Answer D confuses the angle (in radians) with the coefficient.',
      hint: 'At impending motion, set $\\mu_s N = W\\sin\\theta$ and $N = W\\cos\\theta$. Divide to eliminate $W$ and $N$.',
      steps: [
        {
          text: 'At impending motion along the incline:',
          latex: '\\mu_s N = W\\sin\\theta',
        },
        {
          text: 'Normal force on an incline:',
          latex: 'N = W\\cos\\theta',
        },
        {
          text: 'Substitute and simplify:',
          latex: '\\mu_s W\\cos\\theta = W\\sin\\theta \\quad \\Rightarrow \\quad \\mu_s = \\frac{\\sin\\theta}{\\cos\\theta} = \\tan\\theta',
        },
        {
          text: 'This is called the angle of repose. It means the coefficient of static friction can be measured by simply tilting a surface until the object begins to slide.',
          latex: null,
        },
      ],
      handbookPage: 'p. 96, Friction',
      handbookFormula: 'F \\leq \\mu_s N',
      videoUrl: null,
      traps: [
        'Confusing sine and tangent -- the correct relationship is $\\tan\\theta = \\mu_s$, not $\\sin\\theta = \\mu_s$',
        'Forgetting that the normal force on an incline is $W\\cos\\theta$, not $W$',
      ],
      diagram: null,
    },
  ],
};
