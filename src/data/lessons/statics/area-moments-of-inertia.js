export default {
  id: 'area-moments-of-inertia',
  name: 'Area Moments of Inertia',
  subtopicId: 'section-properties',
  application:
    'The moment of inertia (second moment of area) controls how much a beam bends and where it fails in flexure. On the FE, you will look up $I$ for simple shapes from the handbook tables, then combine them using the parallel axis theorem for composite sections. This comes up in beam bending stress ($\\sigma = My/I$), beam deflection, and column buckling. The parallel axis theorem is the single most important formula in this lesson \u2014 forgetting the $Ad^2$ term is the most common mistake on the exam.',
  content: [
    {
      type: 'text',
      body: 'The moment of inertia measures how an area\u2019s material is distributed relative to an axis. The farther the material from the axis, the larger the moment of inertia and the stiffer the beam.',
    },
    { type: 'heading', body: 'Moment of Inertia (Second Moment of Area)' },
    {
      type: 'formula',
      latex: 'I_x = \\int y^2\\, dA \\qquad I_y = \\int x^2\\, dA',
      label: 'Definition of Moment of Inertia',
    },
    {
      type: 'text',
      body: 'For standard shapes, the handbook tables (pp. 98\u2013100) provide $I$ directly. For a rectangle about its centroidal axis: $I_{xc} = bh^3/12$. For a circle: $I_{xc} = \\pi r^4/4$.',
    },
    { type: 'heading', body: 'Parallel Axis Theorem' },
    {
      type: 'formula',
      latex: 'I_x = \\bar{I}_{xc} + A d^2',
      label: 'Parallel Axis Theorem',
    },
    {
      type: 'text',
      body: '$\\bar{I}_{xc}$ is the moment of inertia about the shape\u2019s own centroidal axis, $A$ is the area, and $d$ is the perpendicular distance from the centroidal axis to the new axis. This theorem lets you move $I$ from one axis to a parallel one.',
    },
    {
      type: 'callout',
      variant: 'warning',
      body: 'The parallel axis theorem only works from a centroidal axis to a non-centroidal axis (or vice versa). You cannot go directly from one non-centroidal axis to another \u2014 you must pass through the centroid first.',
    },
    { type: 'heading', body: 'Polar Moment of Inertia' },
    {
      type: 'formula',
      latex: 'J = I_x + I_y',
      label: 'Polar Moment of Inertia',
    },
    {
      type: 'text',
      body: 'The polar moment $J$ is the sum of $I_x$ and $I_y$ about the same point. It appears in torsion problems ($\\tau = Tr/J$).',
    },
    { type: 'heading', body: 'Radius of Gyration' },
    {
      type: 'formula',
      latex: 'r = \\sqrt{\\frac{I}{A}}',
      label: 'Radius of Gyration',
    },
    {
      type: 'text',
      body: 'The radius of gyration is the distance from the axis at which the entire area could be concentrated to produce the same moment of inertia. It appears in column buckling formulas.',
    },
    {
      type: 'callout',
      variant: 'tip',
      body: 'For composite sections: find the composite centroid first (Lesson 5), then apply the parallel axis theorem to each piece about the composite centroidal axis, and sum. You need the centroid before you can compute the composite $I$.',
    },
    {
      type: 'callout',
      variant: 'exam',
      body: 'The handbook tables (pp. 98\u2013100) give $I$ about centroidal axes for every standard shape. Do not compute integrals on the FE \u2014 look up the value and apply the parallel axis theorem if needed.',
    },
  ],
  illustration: null,
  problems: [
    {
      id: 'stat-ami-q1',
      statement:
        'A rectangular cross section is 150 mm wide and 300 mm tall. What is the moment of inertia about its centroidal horizontal axis ($I_{xc}$)?',
      choices: [
        { id: 'c1', text: '$3.375 \\times 10^8$ mm$^4$' },
        { id: 'c2', text: '$1.350 \\times 10^9$ mm$^4$' },
        { id: 'c3', text: '$8.44 \\times 10^7$ mm$^4$' },
        { id: 'c4', text: '$6.75 \\times 10^8$ mm$^4$' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'easy',
      eli5: 'For a rectangle, the centroidal moment of inertia is $bh^3/12$. The key is using the correct dimension for $h$ \u2014 it is the dimension perpendicular to the axis you are computing about. For $I_x$, $h$ is the height (300 mm) and $b$ is the width (150 mm). Answer B ($1.35 \\times 10^9$) uses $bh^3/3$ instead of $bh^3/12$ \u2014 that is the moment of inertia about the base, not the centroid. Answer C ($8.44 \\times 10^7$) swaps $b$ and $h$, computing $b^3h/12$ (moment of inertia about the vertical centroidal axis instead). Answer D doubles the correct value.',
      hint: 'For a rectangle, $I_{xc} = bh^3/12$. Make sure $h$ is the dimension perpendicular to the axis.',
      steps: [
        {
          text: 'Rectangle: $b = 150$ mm (width), $h = 300$ mm (height). For $I_x$, $h$ is perpendicular to the x-axis.',
          latex: null,
        },
        {
          text: 'Apply the centroidal formula:',
          latex: 'I_{xc} = \\frac{bh^3}{12} = \\frac{150 \\times 300^3}{12} = \\frac{150 \\times 27{,}000{,}000}{12} = 3.375 \\times 10^8 \\text{ mm}^4',
        },
        {
          text: 'Answer B uses $bh^3/3 = 1.35 \\times 10^9$, which is the moment of inertia about the base edge, not the centroid.',
          latex: null,
        },
        {
          text: 'Answer C uses $b^3h/12 = 150^3 \\times 300/12 = 8.44 \\times 10^7$, which is $I_y$ (about the vertical axis), not $I_x$.',
          latex: null,
        },
      ],
      handbookPage: 'pp. 98\u2013100, Shape Properties Table (Rectangle)',
      handbookFormula: 'I_{xc} = \\frac{bh^3}{12}',
      videoUrl: null,
      traps: [
        'Using $bh^3/3$ (about the base) instead of $bh^3/12$ (about the centroid)',
        'Swapping width and height \u2014 $h$ must be the dimension perpendicular to the axis of interest',
      ],
      diagram: { component: 'RectangleInertia', props: { width: 150, height: 300 } },
    },
    {
      id: 'stat-ami-q2',
      statement:
        'A rectangular cross section is 50 mm wide and 100 mm tall. Using the parallel axis theorem, what is the moment of inertia about the bottom edge of the rectangle?',
      choices: [
        { id: 'c1', text: '$4.17 \\times 10^6$ mm$^4$' },
        { id: 'c2', text: '$16.67 \\times 10^6$ mm$^4$' },
        { id: 'c3', text: '$12.50 \\times 10^6$ mm$^4$' },
        { id: 'c4', text: '$8.33 \\times 10^6$ mm$^4$' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'medium',
      eli5: 'The parallel axis theorem says $I = I_c + Ad^2$. First find the centroidal moment of inertia: $I_c = 50 \\times 100^3/12 = 4.17 \\times 10^6$. Then add the transfer term: $Ad^2 = (50 \\times 100)(50^2) = 12.50 \\times 10^6$. Total: $16.67 \\times 10^6$ mm\u2074. Answer A ($4.17 \\times 10^6$) is just $I_c$ \u2014 it forgets the $Ad^2$ transfer term entirely. Answer C ($12.50 \\times 10^6$) is the $Ad^2$ term alone without the centroidal $I_c$. These two errors are the most common parallel axis theorem mistakes on the FE.',
      hint: 'The distance $d$ from the centroid to the base is half the height. Do not forget either term \u2014 both $I_c$ and $Ad^2$ contribute.',
      steps: [
        {
          text: 'Centroidal moment of inertia:',
          latex: 'I_c = \\frac{bh^3}{12} = \\frac{50 \\times 100^3}{12} = 4.17 \\times 10^6 \\text{ mm}^4',
        },
        {
          text: 'Distance from centroid to the base:',
          latex: 'd = \\frac{h}{2} = 50 \\text{ mm}',
        },
        {
          text: 'Transfer term:',
          latex: 'Ad^2 = (50 \\times 100)(50^2) = 5{,}000 \\times 2{,}500 = 12.50 \\times 10^6 \\text{ mm}^4',
        },
        {
          text: 'Apply the parallel axis theorem:',
          latex: 'I_{\\text{base}} = I_c + Ad^2 = 4.17 \\times 10^6 + 12.50 \\times 10^6 = 16.67 \\times 10^6 \\text{ mm}^4',
        },
        {
          text: 'Verification: the direct formula gives the same result: $bh^3/3 = 50 \\times 100^3/3 = 16.67 \\times 10^6$.',
          latex: null,
        },
      ],
      handbookPage: 'p. 95, Parallel Axis Theorem; pp. 98\u2013100, Shape Properties',
      handbookFormula: 'I_x = \\bar{I}_{xc} + Ad^2',
      videoUrl: null,
      traps: [
        'Forgetting the $Ad^2$ term and reporting only the centroidal value ($4.17 \\times 10^6$)',
        'Forgetting the centroidal $I_c$ term and reporting only $Ad^2$ ($12.50 \\times 10^6$)',
      ],
      diagram: { component: 'ParallelAxisRect', props: { width: 50, height: 100 } },
    },
    {
      id: 'stat-ami-q3',
      statement:
        'A T-shaped cross section has a top flange 120 mm wide \u00d7 20 mm thick and a web 20 mm wide \u00d7 80 mm deep below the flange. The composite centroid is at 70 mm from the bottom (found in the previous lesson). What is the moment of inertia of the composite section about its centroidal x-axis?',
      choices: [
        { id: 'c1', text: '$3.33 \\times 10^6$ mm$^4$' },
        { id: 'c2', text: '$0.93 \\times 10^6$ mm$^4$' },
        { id: 'c3', text: '$2.40 \\times 10^6$ mm$^4$' },
        { id: 'c4', text: '$1.67 \\times 10^6$ mm$^4$' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'hard',
      eli5: 'For each piece, compute its own centroidal $I$ and then transfer it to the composite centroidal axis using the parallel axis theorem. The web\u2019s centroid is 30 mm below the composite centroid, and the flange\u2019s centroid is 20 mm above it. Add both transferred moments: $I = (I_{c,web} + A_{web} d_{web}^2) + (I_{c,flange} + A_{flange} d_{flange}^2) = 2.29 \\times 10^6 + 1.04 \\times 10^6 = 3.33 \\times 10^6$ mm\u2074. Answer B ($0.93 \\times 10^6$) adds only the centroidal $I$ values without the $Ad^2$ transfer terms \u2014 the single most common parallel axis theorem mistake. Answer C ($2.40 \\times 10^6$) includes only the $Ad^2$ terms without the centroidal $I$ values.',
      hint: 'Apply the parallel axis theorem to each piece separately: $I_{piece} = I_{c,piece} + A_{piece} \\times d_{piece}^2$, where $d$ is the distance from that piece\u2019s centroid to the composite centroid.',
      steps: [
        {
          text: 'Web (20 \u00d7 80 mm): centroid at $y = 40$ mm, distance to composite centroid: $d = 70 - 40 = 30$ mm.',
          latex: 'I_{web} = \\frac{20 \\times 80^3}{12} + (1{,}600)(30^2) = 853{,}333 + 1{,}440{,}000 = 2{,}293{,}333 \\text{ mm}^4',
        },
        {
          text: 'Flange (120 \u00d7 20 mm): centroid at $y = 90$ mm, distance to composite centroid: $d = 90 - 70 = 20$ mm.',
          latex: 'I_{flange} = \\frac{120 \\times 20^3}{12} + (2{,}400)(20^2) = 80{,}000 + 960{,}000 = 1{,}040{,}000 \\text{ mm}^4',
        },
        {
          text: 'Total composite moment of inertia:',
          latex: 'I_x = 2{,}293{,}333 + 1{,}040{,}000 = 3{,}333{,}333 \\approx 3.33 \\times 10^6 \\text{ mm}^4',
        },
        {
          text: 'Answer B adds only the centroidal values: $853{,}333 + 80{,}000 = 933{,}333$. This misses the $Ad^2$ terms, which account for most of the composite $I$.',
          latex: null,
        },
      ],
      handbookPage: 'p. 95, Parallel Axis Theorem; pp. 98\u2013100, Shape Properties',
      handbookFormula: 'I_x = \\bar{I}_{xc} + Ad^2',
      videoUrl: null,
      traps: [
        'Adding only the centroidal moments of inertia without the $Ad^2$ transfer terms',
        'Using the distance from each piece to the base instead of to the composite centroid',
      ],
      diagram: { component: 'TSection', props: { flangeW: 120, flangeH: 20, webW: 20, webH: 80, centroidY: 70, showAxis: true } },
    },
  ],
  examProblems: [
    {
      id: 'stat-ami-ex1',
      type: 'computational',
      statement: 'A rectangular cross-section has a width of 200 mm and a height of 400 mm. What is the moment of inertia about the centroidal horizontal axis?',
      choices: [
        { id: 'c1', text: '$533 \\times 10^6\\,\\text{mm}^4$' },
        { id: 'c2', text: '$1067 \\times 10^6\\,\\text{mm}^4$' },
        { id: 'c3', text: '$2667 \\times 10^6\\,\\text{mm}^4$' },
        { id: 'c4', text: '$4267 \\times 10^6\\,\\text{mm}^4$' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'easy',
      eli5: 'For a rectangle, I = bh^3/12 about the centroidal axis. Plug in b=200 and h=400: I = 200(400)^3/12 = 200(64,000,000)/12 = 1,066,666,667 mm^4 which rounds to 1067 x 10^6. The trap is using bh^3/3 (which is about the base, not the centroid) or swapping b and h.',
      hint: 'Use $I = bh^3/12$ for a rectangle about its centroidal axis.',
      steps: [
        { text: 'For a rectangle about the centroidal axis:', latex: 'I = \\frac{bh^3}{12}' },
        { text: 'Substitute $b = 200$ mm, $h = 400$ mm:', latex: 'I = \\frac{200 \\times 400^3}{12} = \\frac{200 \\times 64{,}000{,}000}{12}' },
        { text: 'Calculate:', latex: 'I = \\frac{12{,}800{,}000{,}000}{12} = 1{,}067 \\times 10^6\\,\\text{mm}^4' },
      ],
      handbookPage: 'p. 94',
      handbookFormula: 'I_x = \\frac{bh^3}{12}',
      videoUrl: null,
      traps: ['Using bh^3/3 (moment about the base) instead of bh^3/12 (about centroid)', 'Swapping b and h dimensions'],
      diagram: null,
    },
    {
      id: 'stat-ami-ex2',
      type: 'conceptual',
      statement: 'When using the parallel axis theorem to find the moment of inertia of a composite section, the transfer term $Ad^2$ represents:',
      choices: [
        { id: 'c1', text: 'The moment of inertia about the shape\'s own centroid' },
        { id: 'c2', text: 'The additional inertia due to the offset from the composite centroid' },
        { id: 'c3', text: 'The polar moment of inertia' },
        { id: 'c4', text: 'The product of inertia' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'easy',
      eli5: 'The parallel axis theorem says I_total = I_centroid + Ad^2. The Ad^2 term accounts for the fact that the shape\'s centroid is offset from the axis you care about. A is the shape\'s area, and d is the distance between centroids. It is always added — never subtracted.',
      hint: 'Think about what happens when an axis is shifted away from the centroid.',
      steps: [
        { text: 'The parallel axis theorem: $I = \\bar{I} + Ad^2$.', latex: null },
        { text: '$\\bar{I}$ is the moment about the shape\'s own centroid.', latex: null },
        { text: '$Ad^2$ is the additional inertia due to the distance $d$ from the shape\'s centroid to the reference axis.', latex: null },
      ],
      handbookPage: 'p. 94',
      handbookFormula: 'I = \\bar{I} + Ad^2',
      videoUrl: null,
      traps: ['Confusing the transfer term with the centroidal moment itself'],
      diagram: null,
    },
  ],
};
