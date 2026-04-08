export default {
  id: 'force-systems-resultants',
  name: 'Force Systems & Resultants',
  subtopicId: 'forces-and-equilibrium',
  application:
    'Civil engineers resolve force systems every time they combine dead load, live load, and wind on a structural connection, or find the net effect of soil pressure on a retaining wall. The FE tests whether you can break a force into x and y components, find the resultant of multiple concurrent forces, and compute the moment of a force about a point. These are the building blocks \u2014 every equilibrium, truss, and beam problem starts here. The handbook gives you the formulas on p. 94, but the exam tests whether you can apply them quickly with direction cosines, geometry-based resolution, and the cross product.',
  content: [
    {
      type: 'text',
      body: 'Statics problems start with forces. A force is a vector \u2014 it has magnitude, direction, and a point of application. Everything in this lesson is about breaking forces apart and putting them back together.',
    },
    { type: 'heading', body: 'Resolution of a Force into Components' },
    {
      type: 'formula',
      latex: 'F_x = F\\cos\\theta_x \\qquad F_y = F\\cos\\theta_y',
      label: 'Direction Cosine Resolution',
    },
    {
      type: 'text',
      body: 'When the angle is measured from the x-axis, $F_x = F\\cos\\theta$ and $F_y = F\\sin\\theta$. When geometry is given instead of an angle, use the rise-over-run approach.',
    },
    { type: 'heading', body: 'Resolution by Geometry' },
    {
      type: 'formula',
      latex: 'F_x = \\frac{x}{R}\\,F \\qquad F_y = \\frac{y}{R}\\,F \\qquad R = \\sqrt{x^2 + y^2}',
      label: 'Geometry-Based Resolution',
    },
    {
      type: 'text',
      body: 'Here $x$ and $y$ are the horizontal and vertical legs of the triangle formed by the force direction, and $R$ is the hypotenuse. This is often faster than finding the angle first.',
    },
    { type: 'heading', body: 'Resultant of a Force System' },
    {
      type: 'formula',
      latex: 'R = \\sqrt{R_x^2 + R_y^2}',
      label: 'Resultant Magnitude',
    },
    {
      type: 'formula',
      latex: '\\theta_R = \\arctan\\!\\left(\\frac{R_y}{R_x}\\right)',
      label: 'Resultant Direction',
    },
    {
      type: 'text',
      body: 'Sum all x-components to get $R_x = \\sum F_{x,i}$ and all y-components to get $R_y = \\sum F_{y,i}$. The resultant magnitude and direction follow from the Pythagorean theorem.',
    },
    { type: 'heading', body: 'Moments and Couples' },
    {
      type: 'formula',
      latex: '\\mathbf{M} = \\mathbf{r} \\times \\mathbf{F}',
      label: 'Moment of a Force',
    },
    {
      type: 'text',
      body: 'The moment of a force about a point equals the cross product of the position vector $\\mathbf{r}$ (from the point to anywhere on the force\u2019s line of action) and the force $\\mathbf{F}$. In 2D, this simplifies to $M = Fd$, where $d$ is the perpendicular distance from the point to the line of action.',
    },
    {
      type: 'text',
      body: 'A couple is two equal, opposite, parallel forces separated by a distance. The moment of a couple is the same about any point \u2014 it equals $M = Fd$ where $d$ is the distance between the two forces.',
    },
    {
      type: 'callout',
      variant: 'tip',
      body: 'On the FE, when a force acts at an angle, it is often faster to compute the moment by splitting the force into components first and summing moments of each component separately, rather than finding the perpendicular distance to the line of action.',
    },
    {
      type: 'callout',
      variant: 'warning',
      body: 'Sign convention for moments: pick one direction (CW or CCW) as positive and stick with it for the entire problem. Mixing conventions is the fastest way to get the wrong answer.',
    },
    {
      type: 'callout',
      variant: 'exam',
      body: 'The handbook (p. 94) gives the cross product components: $M_x = yF_z - zF_y$, $M_y = zF_x - xF_z$, $M_z = xF_y - yF_x$. On the FE Civil, almost all statics problems are 2D, so you only need $M_z = xF_y - yF_x$.',
    },
  ],
  illustration: null,
  problems: [
    {
      id: 'stat-fsr-q1',
      statement:
        'A cable attached to a bridge anchor exerts a force of 500 N at 35 degrees above the horizontal. What are the horizontal and vertical components of the force?',
      choices: [
        { id: 'c1', text: '$F_x = 354$ N, $F_y = 354$ N' },
        { id: 'c2', text: '$F_x = 287$ N, $F_y = 410$ N' },
        { id: 'c3', text: '$F_x = 410$ N, $F_y = 287$ N' },
        { id: 'c4', text: '$F_x = 500$ N, $F_y = 500$ N' },
      ],
      correctAnswerId: 'c3',
      difficulty: 'easy',
      eli5: 'The angle is measured from the horizontal, so the horizontal component uses cosine and the vertical uses sine. The most common trap is flipping them \u2014 Answer B swaps sin and cos. Answer A uses cos(45) for both, which would only be right at 45 degrees. Answer D does not resolve the force at all and just reports the full magnitude for both components.',
      hint: 'The angle is from the horizontal axis \u2014 which trig function goes with the adjacent side (horizontal)?',
      steps: [
        {
          text: 'Identify: Force = 500 N, angle = 35 degrees above horizontal.',
          latex: null,
        },
        {
          text: 'Horizontal component (adjacent to the angle):',
          latex: 'F_x = 500\\cos 35\\degree = 500 \\times 0.8192 = 409.6 \\approx 410 \\text{ N}',
        },
        {
          text: 'Vertical component (opposite the angle):',
          latex: 'F_y = 500\\sin 35\\degree = 500 \\times 0.5736 = 286.8 \\approx 287 \\text{ N}',
        },
        {
          text: 'Answer B swaps the components \u2014 it uses sine for horizontal and cosine for vertical.',
          latex: null,
        },
      ],
      handbookPage: 'p. 94, Resolution of a Force',
      handbookFormula: 'F_x = F\\cos\\theta_x \\quad F_y = F\\cos\\theta_y',
      videoUrl: null,
      traps: [
        'Swapping sine and cosine \u2014 cosine always goes with the adjacent side (the axis the angle is measured from)',
        'Forgetting to set your calculator to degree mode \u2014 radian mode gives completely wrong trig values',
      ],
      diagram: { component: 'ForceAtAngle', props: { force: 500, angle: 35 } },
    },
    {
      id: 'stat-fsr-q2',
      statement:
        'A cable anchored to a retaining wall runs to a deadman anchor. The cable exerts a force of 1,300 N along a line that runs 5 m horizontally and 12 m vertically from the wall to the anchor point. What are the horizontal and vertical components of the cable force?',
      choices: [
        { id: 'c1', text: '$F_x = 500$ N, $F_y = 1{,}200$ N' },
        { id: 'c2', text: '$F_x = 1{,}200$ N, $F_y = 500$ N' },
        { id: 'c3', text: '$F_x = 650$ N, $F_y = 650$ N' },
        { id: 'c4', text: '$F_x = 260$ N, $F_y = 1{,}040$ N' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'medium',
      eli5: 'When geometry gives you the direction instead of an angle, use the rise-over-run approach: find $R = \\sqrt{x^2 + y^2}$, then $F_x = (x/R) \\times F$ and $F_y = (y/R) \\times F$. The 5-12-13 triangle is one of the FE\u2019s favorite right triangles \u2014 recognize it instantly. Answer B swaps the components (applies the vertical leg to the horizontal direction). Answer C splits the force evenly, which would only be correct at 45 degrees. Answer D uses the wrong denominator (divides by 25 and 5 instead of 13).',
      hint: 'You do not need to find the angle. Use the geometry directly: $F_x = (x/R) \\times F$ where $R$ is the distance from the wall to the anchor point.',
      steps: [
        {
          text: 'The cable runs 5 m horizontal and 12 m vertical. Find the hypotenuse distance:',
          latex: 'R = \\sqrt{5^2 + 12^2} = \\sqrt{25 + 144} = \\sqrt{169} = 13 \\text{ m}',
        },
        {
          text: 'Horizontal component:',
          latex: 'F_x = \\frac{5}{13} \\times 1{,}300 = 500 \\text{ N}',
        },
        {
          text: 'Vertical component:',
          latex: 'F_y = \\frac{12}{13} \\times 1{,}300 = 1{,}200 \\text{ N}',
        },
        {
          text: 'Answer B swaps the legs \u2014 it applies the vertical leg (12) to the horizontal component and vice versa.',
          latex: null,
        },
      ],
      handbookPage: 'p. 94, Resolution of a Force',
      handbookFormula: 'F_x = \\frac{x}{R}\\,F \\quad F_y = \\frac{y}{R}\\,F',
      videoUrl: null,
      traps: [
        'Swapping the x and y legs when geometry is given \u2014 the horizontal leg goes with the horizontal component',
        'Using the force magnitude as the denominator instead of the hypotenuse distance R',
      ],
      diagram: { component: 'CableGeometry', props: { horiz: 5, vert: 12, force: 1300 } },
    },
    {
      id: 'stat-fsr-q3',
      statement:
        'A construction crane has a 10 m boom that makes a 40-degree angle with the horizontal. A 5,000 N load hangs vertically from the boom tip. What is the moment of the load about the boom\u2019s pivot point at the base?',
      choices: [
        { id: 'c1', text: '50,000 N\u00b7m' },
        { id: 'c2', text: '38,300 N\u00b7m' },
        { id: 'c3', text: '32,100 N\u00b7m' },
        { id: 'c4', text: '25,000 N\u00b7m' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'hard',
      eli5: 'The load hangs straight down from the boom tip \u2014 it is a vertical force. To find the moment about the pivot, you need the perpendicular distance from the pivot to the force\u2019s line of action. Since the force is vertical, that perpendicular distance is the horizontal distance from the pivot to the tip, which is the boom length times cosine of the boom angle. Answer A uses the full boom length as if the perpendicular distance equals the boom length (only true if the boom were horizontal). Answer C uses sine instead of cosine, which gives the vertical projection of the boom \u2014 that is perpendicular to the boom, not to the force.',
      hint: 'The force is vertical (gravity). The perpendicular distance to a vertical force is a horizontal distance. How far horizontally is the boom tip from the pivot?',
      steps: [
        {
          text: 'The load (5,000 N) acts vertically downward from the boom tip.',
          latex: null,
        },
        {
          text: 'The horizontal distance from the pivot to the tip is the perpendicular distance to the vertical force:',
          latex: 'd = 10\\cos 40\\degree = 10 \\times 0.766 = 7.66 \\text{ m}',
        },
        {
          text: 'Compute the moment:',
          latex: 'M = F \\times d = 5{,}000 \\times 7.66 = 38{,}300 \\text{ N}{\\cdot}\\text{m (clockwise)}',
        },
        {
          text: 'Answer A (50,000) forgets the angle entirely: $5{,}000 \\times 10 = 50{,}000$. This would only be correct if the boom were perfectly horizontal.',
          latex: null,
        },
        {
          text: 'Answer C (32,100) uses $\\sin 40\\degree$ instead of $\\cos 40\\degree$, giving the vertical projection of the boom rather than the horizontal projection.',
          latex: null,
        },
      ],
      handbookPage: 'p. 94, Moments',
      handbookFormula: '\\mathbf{M} = \\mathbf{r} \\times \\mathbf{F}',
      videoUrl: null,
      traps: [
        'Using the boom length directly as the moment arm instead of computing the perpendicular distance',
        'Confusing sin and cos when finding the horizontal vs. vertical projection of the boom',
      ],
      diagram: { component: 'CraneBoom', props: { length: 10, angle: 40, load: 5000 } },
    },
  ],
};
