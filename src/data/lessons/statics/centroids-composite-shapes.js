export default {
  id: 'centroids-composite-shapes',
  name: 'Centroids of Composite Shapes',
  subtopicId: 'section-properties',
  application:
    'Centroids locate the neutral axis of beam cross-sections, the point of application of distributed loads, and the center of pressure on submerged surfaces. On the FE, you will decompose a composite shape into simple rectangles, triangles, or circles, look up each piece\u2019s area and centroid from the handbook tables (pp. 98\u2013100), and combine them using the weighted-average formula. The most common exam setup is a T-beam, an L-shape, or a plate with holes. If you can split a shape into pieces and take a weighted average, these are fast points.',
  content: [
    {
      type: 'text',
      body: 'The centroid of a composite area is the area-weighted average of the centroids of its parts. Split the shape into simple pieces, find each piece\u2019s area and centroid from the tables, then combine.',
    },
    { type: 'heading', body: 'Composite Centroid Formula' },
    {
      type: 'formula',
      latex: '\\bar{x} = \\frac{\\sum A_i\\, x_i}{\\sum A_i} \\qquad \\bar{y} = \\frac{\\sum A_i\\, y_i}{\\sum A_i}',
      label: 'Centroid of a Composite Area',
    },
    {
      type: 'text',
      body: '$A_i$ is the area of each piece, and $(x_i, y_i)$ is the centroid of that piece measured from a chosen reference axis. For holes or cutouts, use negative area.',
    },
    { type: 'heading', body: 'First Moment of Area' },
    {
      type: 'formula',
      latex: 'Q_x = \\sum A_i\\, y_i = \\bar{y}\\, A \\qquad Q_y = \\sum A_i\\, x_i = \\bar{x}\\, A',
      label: 'First Moment of Area',
    },
    {
      type: 'text',
      body: 'The first moment of area connects centroids to beam analysis. $Q$ appears in shear stress calculations ($\\tau = VQ/Ib$) in Mechanics of Materials. For now, know that $Q$ is the numerator of the centroid formula.',
    },
    { type: 'heading', body: 'Strategy for Composite Shapes' },
    {
      type: 'text',
      body: 'Step 1: Choose a reference axis (usually the bottom or left edge). Step 2: Split the shape into simple pieces (rectangles, triangles, circles). Step 3: For each piece, find area $A_i$ and centroid $(x_i, y_i)$ from the handbook tables. Step 4: Compute $\\sum A_i x_i$, $\\sum A_i y_i$, and $\\sum A_i$. Step 5: Divide.',
    },
    {
      type: 'callout',
      variant: 'tip',
      body: 'For shapes with holes, treat the hole as a piece with negative area. The formula still works \u2014 the hole\u2019s contribution subtracts from both the numerator and the denominator.',
    },
    {
      type: 'callout',
      variant: 'exam',
      body: 'The handbook (pp. 98\u2013100) provides centroid locations for triangles, rectangles, circles, semicircles, and parabolic segments. You do not need to integrate \u2014 just look up the centroid and multiply by the area.',
    },
    {
      type: 'callout',
      variant: 'warning',
      body: 'The most common mistake is measuring centroid distances from the wrong reference point. Pick one reference axis and stick with it for every piece. If you switch mid-problem, the weighted average will be wrong.',
    },
  ],
  illustration: null,
  problems: [
    {
      id: 'stat-ccs-q1',
      statement:
        'A T-shaped cross section has a top flange 120 mm wide and 20 mm thick, and a web 20 mm wide and 80 mm deep below the flange. What is the distance from the bottom of the section to the centroid?',
      choices: [
        { id: 'c1', text: '70.0 mm' },
        { id: 'c2', text: '50.0 mm' },
        { id: 'c3', text: '90.0 mm' },
        { id: 'c4', text: '65.0 mm' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'easy',
      eli5: 'Split the T into two rectangles: the web (20 \u00d7 80 mm, centroid at 40 mm from the bottom) and the flange (120 \u00d7 20 mm, centroid at 90 mm from the bottom). Take the area-weighted average: $(1{,}600 \\times 40 + 2{,}400 \\times 90) / 4{,}000 = 70$ mm. Answer B (50 mm) is the geometric midpoint of the total 100 mm height, ignoring that the flange has more area and sits higher. Answer C (90 mm) is the centroid of the flange alone. Answer D (65 mm) is the simple average of the two centroids, $(40 + 90)/2 = 65$, ignoring the different areas.',
      hint: 'Split the T into web and flange. Compute each area and centroid distance from the bottom, then take the weighted average.',
      steps: [
        {
          text: 'Web: 20 \u00d7 80 mm. Area and centroid from the bottom:',
          latex: 'A_1 = 1{,}600 \\text{ mm}^2, \\quad y_1 = 40 \\text{ mm}',
        },
        {
          text: 'Flange: 120 \u00d7 20 mm. Sits on top of the web (bottom of flange at 80 mm):',
          latex: 'A_2 = 2{,}400 \\text{ mm}^2, \\quad y_2 = 80 + 10 = 90 \\text{ mm}',
        },
        {
          text: 'Composite centroid:',
          latex: '\\bar{y} = \\frac{1{,}600 \\times 40 + 2{,}400 \\times 90}{1{,}600 + 2{,}400} = \\frac{64{,}000 + 216{,}000}{4{,}000} = \\frac{280{,}000}{4{,}000} = 70.0 \\text{ mm}',
        },
      ],
      handbookPage: 'p. 95, Centroid of Area; pp. 98\u2013100, Shape Properties',
      handbookFormula: '\\bar{y} = \\frac{\\sum A_i\\, y_i}{\\sum A_i}',
      videoUrl: null,
      traps: [
        'Using the geometric midpoint of the overall height instead of the area-weighted centroid',
        'Averaging the two centroid locations without weighting by area',
      ],
      diagram: { component: 'TSection', props: { flangeW: 120, flangeH: 20, webW: 20, webH: 80, showCentroid: false } },
    },
    {
      id: 'stat-ccs-q2',
      statement:
        'A 300 mm wide by 200 mm tall steel plate has a single 60 mm diameter circular hole drilled with its center at 150 mm from the left edge and 150 mm from the bottom. What is the y-coordinate of the centroid of the remaining plate, measured from the bottom?',
      choices: [
        { id: 'c1', text: '100.0 mm' },
        { id: 'c2', text: '97.5 mm' },
        { id: 'c3', text: '102.5 mm' },
        { id: 'c4', text: '95.0 mm' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'medium',
      eli5: 'Treat the hole as a piece with negative area. The full plate\u2019s centroid is at $y = 100$ mm (center). The hole is above center at $y = 150$ mm. Removing material above the centroid pulls the centroid downward. The math: $\\bar{y} = (60{,}000 \\times 100 - 2{,}827 \\times 150) / (60{,}000 - 2{,}827) = 97.5$ mm. Answer A (100 mm) ignores the hole entirely. Answer C (102.5 mm) adds the hole\u2019s effect instead of subtracting, pushing the centroid the wrong direction.',
      hint: 'Subtract the hole: use negative area for the circular cutout. Removing material above the original centroid shifts it downward.',
      steps: [
        {
          text: 'Full plate: $A = 300 \\times 200 = 60{,}000$ mm\u00b2, centroid at $y = 100$ mm.',
          latex: null,
        },
        {
          text: 'Hole: $A = \\pi(30)^2 = 2{,}827$ mm\u00b2, centroid at $y = 150$ mm.',
          latex: null,
        },
        {
          text: 'Composite centroid (subtract the hole):',
          latex: '\\bar{y} = \\frac{60{,}000 \\times 100 - 2{,}827 \\times 150}{60{,}000 - 2{,}827} = \\frac{6{,}000{,}000 - 424{,}050}{57{,}173} = \\frac{5{,}575{,}950}{57{,}173} = 97.5 \\text{ mm}',
        },
        {
          text: 'The hole is above the plate\u2019s center, so removing it shifts the centroid downward \u2014 consistent with our answer being less than 100 mm.',
          latex: null,
        },
      ],
      handbookPage: 'p. 95, Centroid of Area; pp. 98\u2013100, Shape Properties',
      handbookFormula: '\\bar{y} = \\frac{\\sum A_i\\, y_i}{\\sum A_i}',
      videoUrl: null,
      traps: [
        'Ignoring the hole and reporting the centroid of the full plate (100 mm)',
        'Adding the hole contribution instead of subtracting it \u2014 removing material above the centroid shifts it down, not up',
      ],
      diagram: { component: 'PlateWithHole', props: { plateW: 300, plateH: 200, holeDia: 60, holeX: 150, holeY: 150 } },
    },
    {
      id: 'stat-ccs-q3',
      statement:
        'A built-up steel section consists of three rectangles: a bottom flange (200 mm wide \u00d7 30 mm tall), a web (30 mm wide \u00d7 140 mm tall centered on the flange), and a top flange (150 mm wide \u00d7 30 mm tall centered on the web). The total height is 200 mm. What is the y-coordinate of the centroid measured from the bottom?',
      choices: [
        { id: 'c1', text: '100.0 mm' },
        { id: 'c2', text: '91.3 mm' },
        { id: 'c3', text: '108.7 mm' },
        { id: 'c4', text: '75.0 mm' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'hard',
      eli5: 'Split the section into three rectangles: bottom flange ($A = 6{,}000$, $y = 15$), web ($A = 4{,}200$, $y = 100$), and top flange ($A = 4{,}500$, $y = 185$). The bottom flange is the widest piece with the most area, so it pulls the centroid below the geometric center. The weighted average gives 91.3 mm. Answer A (100 mm) is the geometric center of the 200 mm height. Answer C (108.7 mm) measures from the top instead of the bottom. Answer D (75 mm) only accounts for two of the three rectangles.',
      hint: 'Three rectangles, three areas, three centroid locations. Take the weighted average from the bottom.',
      steps: [
        {
          text: 'Bottom flange: 200 \u00d7 30 mm.',
          latex: 'A_1 = 6{,}000 \\text{ mm}^2, \\quad y_1 = 15 \\text{ mm}',
        },
        {
          text: 'Web: 30 \u00d7 140 mm.',
          latex: 'A_2 = 4{,}200 \\text{ mm}^2, \\quad y_2 = 30 + 70 = 100 \\text{ mm}',
        },
        {
          text: 'Top flange: 150 \u00d7 30 mm.',
          latex: 'A_3 = 4{,}500 \\text{ mm}^2, \\quad y_3 = 30 + 140 + 15 = 185 \\text{ mm}',
        },
        {
          text: 'Sum of first moments:',
          latex: '\\sum A_i y_i = 6{,}000(15) + 4{,}200(100) + 4{,}500(185) = 90{,}000 + 420{,}000 + 832{,}500 = 1{,}342{,}500',
        },
        {
          text: 'Total area and centroid:',
          latex: '\\bar{y} = \\frac{1{,}342{,}500}{6{,}000 + 4{,}200 + 4{,}500} = \\frac{1{,}342{,}500}{14{,}700} = 91.3 \\text{ mm}',
        },
      ],
      handbookPage: 'p. 95, Centroid of Area; pp. 98\u2013100, Shape Properties',
      handbookFormula: '\\bar{y} = \\frac{\\sum A_i\\, y_i}{\\sum A_i}',
      videoUrl: null,
      traps: [
        'Using the geometric midpoint (100 mm) instead of the area-weighted centroid',
        'Forgetting one of the three pieces \u2014 especially the web, which is easy to overlook',
      ],
      diagram: { component: 'BuiltUpSection', props: { botW: 200, botH: 30, webW: 30, webH: 140, topW: 150, topH: 30 } },
    },
  ],
  examProblems: [
    {
      id: 'stat-ccs-ex1',
      type: 'computational',
      statement:
        'An L-shaped cross section is formed by two non-overlapping rectangles: a horizontal leg 80 mm wide and 20 mm tall at the bottom, and a vertical leg 20 mm wide and 80 mm tall sitting directly on top of it. The total height is 100 mm. What is the distance from the bottom of the section to the centroid ($\\bar{y}$)?',
      choices: [
        { id: 'c1', text: '35.0 mm' },
        { id: 'c2', text: '50.0 mm' },
        { id: 'c3', text: '40.0 mm' },
        { id: 'c4', text: '25.0 mm' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'easy',
      eli5: 'Split the L into two rectangles. The horizontal leg is 80 x 20 mm ($A_1 = 1{,}600$ mm$^2$, centroid at $y_1 = 10$ mm from the bottom). The vertical leg is 20 x 80 mm ($A_2 = 1{,}600$ mm$^2$, centroid at $y_2 = 20 + 40 = 60$ mm from the bottom). Since both areas are equal, the centroid is the simple average of 10 and 60: $\\bar{y} = (16{,}000 + 96{,}000)/3{,}200 = 35$ mm. Answer B (50 mm) is the geometric midpoint of the 100 mm total height. Answer C (40 mm) is a rough guess splitting the difference. Answer D (25 mm) underweights the vertical leg.',
      hint: 'Split the L into two non-overlapping rectangles. Measure each centroid from the same reference (bottom edge).',
      steps: [
        {
          text: 'Horizontal leg: 80 x 20 mm, centroid at $y = 10$ mm from bottom.',
          latex: 'A_1 = 1{,}600 \\text{ mm}^2, \\quad y_1 = 10 \\text{ mm}',
        },
        {
          text: 'Vertical leg (above horizontal leg): 20 x 80 mm, centroid at $y = 20 + 40 = 60$ mm.',
          latex: 'A_2 = 1{,}600 \\text{ mm}^2, \\quad y_2 = 60 \\text{ mm}',
        },
        {
          text: 'Composite centroid:',
          latex: '\\bar{y} = \\frac{1{,}600(10) + 1{,}600(60)}{1{,}600 + 1{,}600} = \\frac{16{,}000 + 96{,}000}{3{,}200} = \\frac{112{,}000}{3{,}200} = 35.0 \\text{ mm}',
        },
      ],
      handbookPage: 'p. 95, Centroid of Area',
      handbookFormula: '\\bar{y} = \\frac{\\sum A_i\\, y_i}{\\sum A_i}',
      videoUrl: null,
      traps: [
        'Double-counting the overlap region where the two legs intersect',
        'Measuring one rectangle centroid from a different reference than the other',
      ],
      diagram: null,
    },
    {
      id: 'stat-ccs-ex2',
      type: 'computational',
      statement:
        'A rectangular cross section is 200 mm wide and 300 mm tall. A 100 mm diameter circular hole is drilled with its center at the geometric center of the rectangle (100 mm from the left, 150 mm from the bottom). What is the $\\bar{y}$ coordinate of the centroid of the remaining shape, measured from the bottom?',
      choices: [
        { id: 'c1', text: '150.0 mm' },
        { id: 'c2', text: '147.3 mm' },
        { id: 'c3', text: '152.7 mm' },
        { id: 'c4', text: '142.5 mm' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'medium',
      eli5: 'The rectangle centroid is at $y = 150$ mm. The hole centroid is also at $y = 150$ mm (same as the rectangle center). When you remove material whose centroid is at the same height as the overall centroid, the centroid does not shift. The subtraction in the numerator and denominator both reference the same $y$ value, so $\\bar{y}$ stays at 150 mm. Answer B and C assume the hole shifts the centroid, but only an off-center hole does that. Answer D over-corrects as if the hole were near the top.',
      hint: 'Think about where the hole is located relative to the rectangle centroid. Does removing material at the centroid shift it?',
      steps: [
        {
          text: 'Rectangle: $A_1 = 200 \\times 300 = 60{,}000$ mm$^2$, centroid at $y_1 = 150$ mm.',
          latex: null,
        },
        {
          text: 'Hole: $A_2 = \\pi(50)^2 = 7{,}854$ mm$^2$, centroid at $y_2 = 150$ mm (same as rectangle center).',
          latex: null,
        },
        {
          text: 'Composite centroid:',
          latex: '\\bar{y} = \\frac{60{,}000(150) - 7{,}854(150)}{60{,}000 - 7{,}854} = \\frac{150(60{,}000 - 7{,}854)}{60{,}000 - 7{,}854} = 150.0 \\text{ mm}',
        },
        {
          text: 'The hole is centered on the rectangle, so removing it does not shift the centroid. Only an off-center hole changes $\\bar{y}$.',
          latex: null,
        },
      ],
      handbookPage: 'p. 95, Centroid of Area',
      handbookFormula: '\\bar{y} = \\frac{\\sum A_i\\, y_i}{\\sum A_i}',
      videoUrl: null,
      traps: [
        'Assuming any hole shifts the centroid -- a centered hole has no effect',
        'Forgetting to subtract the hole area from the denominator as well as the numerator',
      ],
      diagram: null,
    },
    {
      id: 'stat-ccs-ex3',
      type: 'computational',
      statement:
        'A channel section (C-shape) is formed by three rectangles: a web 10 mm wide and 160 mm tall, and two identical flanges each 60 mm wide and 20 mm tall attached at the top and bottom of the web, extending to the right. What is the horizontal distance $\\bar{x}$ from the left edge of the web to the centroid of the section?',
      choices: [
        { id: 'c1', text: '20.0 mm' },
        { id: 'c2', text: '30.0 mm' },
        { id: 'c3', text: '10.0 mm' },
        { id: 'c4', text: '35.0 mm' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'medium',
      eli5: 'Set the reference axis at the left edge of the web. The web is 10 mm wide, so its centroid is at $x = 5$ mm. Each flange extends 60 mm to the right from the left edge of the web, with centroid at $x = 30$ mm. Web area: $10 \\times 160 = 1{,}600$ mm$^2$. Each flange: $60 \\times 20 = 1{,}200$ mm$^2$ (two flanges total 2{,}400 mm$^2$). The weighted average gives $\\bar{x} = (8{,}000 + 72{,}000)/4{,}000 = 20$ mm. Answer B (30 mm) is the centroid of the flanges alone, ignoring the web. Answer C (10 mm) is the width of the web, not the centroid location. Answer D (35 mm) is the midpoint of the total 70 mm width.',
      hint: 'Set the reference at the left edge of the web. The flanges pull the centroid to the right.',
      steps: [
        {
          text: 'Reference: left edge of the web. Web: 10 mm wide, 160 mm tall.',
          latex: 'A_w = 1{,}600 \\text{ mm}^2, \\quad x_w = 5 \\text{ mm}',
        },
        {
          text: 'Two flanges, each 60 mm wide and 20 mm tall, extending to the right from the web.',
          latex: 'A_f = 2 \\times (60 \\times 20) = 2{,}400 \\text{ mm}^2, \\quad x_f = 30 \\text{ mm}',
        },
        {
          text: 'Composite centroid:',
          latex: '\\bar{x} = \\frac{1{,}600(5) + 2{,}400(30)}{1{,}600 + 2{,}400} = \\frac{8{,}000 + 72{,}000}{4{,}000} = 20.0 \\text{ mm}',
        },
      ],
      handbookPage: 'p. 95, Centroid of Area; pp. 98-100, Shape Properties',
      handbookFormula: '\\bar{x} = \\frac{\\sum A_i\\, x_i}{\\sum A_i}',
      videoUrl: null,
      traps: [
        'Forgetting that the web centroid is at half its width, not at the edge',
        'Measuring flange centroids from the wrong reference axis',
      ],
      diagram: null,
    },
    {
      id: 'stat-ccs-ex4',
      type: 'conceptual',
      statement:
        'A symmetric I-beam cross section has a circular hole drilled through the web, centered exactly at the centroid of the full I-beam. Compared to the undrilled section, how does the hole affect the centroid location?',
      choices: [
        { id: 'c1', text: 'The centroid stays in the same location' },
        { id: 'c2', text: 'The centroid shifts toward the top flange' },
        { id: 'c3', text: 'The centroid shifts toward the bottom flange' },
        { id: 'c4', text: 'The centroid shifts horizontally toward the hole' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'hard',
      eli5: 'Removing material at the centroid does not move the centroid. The centroid formula is $\\bar{y} = \\sum A_i y_i / \\sum A_i$. When you subtract a hole whose centroid is at $\\bar{y}$ of the original shape, the numerator loses $A_{hole} \\times \\bar{y}$ and the denominator loses $A_{hole}$. The ratio stays the same: $\\bar{y}_{new} = (A\\bar{y} - A_h\\bar{y})/(A - A_h) = \\bar{y}(A - A_h)/(A - A_h) = \\bar{y}$. Only a hole placed above or below the original centroid causes a shift. This is the same principle tested in the practice problems -- the key insight is whether the removed material is on-center or off-center.',
      hint: 'Think about what happens to the weighted-average formula when the hole centroid matches the overall centroid.',
      steps: [
        {
          text: 'Original centroid: $\\bar{y}$. Hole area: $A_h$, centered at $y_h = \\bar{y}$.',
          latex: null,
        },
        {
          text: 'New centroid after removing the hole:',
          latex: '\\bar{y}_{new} = \\frac{A\\bar{y} - A_h \\bar{y}}{A - A_h} = \\frac{\\bar{y}(A - A_h)}{A - A_h} = \\bar{y}',
        },
        {
          text: 'The centroid does not move. Removing material at the centroid preserves symmetry in the weighted average.',
          latex: null,
        },
        {
          text: 'If the hole were above or below the centroid, the centroid would shift toward the opposite side -- removing mass above pulls the centroid down, and vice versa.',
          latex: null,
        },
      ],
      handbookPage: 'p. 95, Centroid of Area',
      handbookFormula: '\\bar{y} = \\frac{\\sum A_i\\, y_i}{\\sum A_i}',
      videoUrl: null,
      traps: [
        'Assuming any hole must shift the centroid -- only off-center holes cause a shift',
        'Confusing the effect on the centroid with the effect on the moment of inertia (which always decreases when material is removed)',
      ],
      diagram: null,
    },
  ],
};
