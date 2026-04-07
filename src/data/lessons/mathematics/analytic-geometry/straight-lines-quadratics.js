export default {
  "id": "straight-lines-quadratics",
  "name": "Straight Lines & Quadratics",
  "subtopicId": "analytic-geometry",
  "application": "Civil engineers work with straight lines constantly — from defining road alignments and grade slopes, to establishing property boundaries in surveying, to plotting stress-strain relationships in materials testing. The quadratic formula shows up any time a parabolic curve is involved: vertical curves in highway design, projectile trajectories in dynamics, and cable sag calculations. On the FE, expect direct questions asking you to find a slope, a distance between two points, or the roots of a quadratic. These are fast-solve questions if you know the formulas — free points.",
  "content": [
    {
      "type": "text",
      "body": "Three forms of a line equation show up in the handbook. Know when to use each one."
    },
    {
      "type": "heading",
      "body": "Slope-Intercept Form"
    },
    {
      "type": "formula",
      "latex": "y = mx + b",
      "label": "When you know slope and y-intercept"
    },
    {
      "type": "heading",
      "body": "Point-Slope Form"
    },
    {
      "type": "formula",
      "latex": "y - y_1 = m(x - x_1)",
      "label": "When you know slope and one point"
    },
    {
      "type": "heading",
      "body": "Slope from Two Points"
    },
    {
      "type": "formula",
      "latex": "m = \\frac{y_2 - y_1}{x_2 - x_1}"
    },
    {
      "type": "heading",
      "body": "Distance Between Two Points"
    },
    {
      "type": "formula",
      "latex": "d = \\sqrt{(x_2 - x_1)^2 + (y_2 - y_1)^2}"
    },
    {
      "type": "heading",
      "body": "Perpendicular Lines"
    },
    {
      "type": "text",
      "body": "Two lines are perpendicular if their slopes are negative reciprocals."
    },
    {
      "type": "formula",
      "latex": "m_1 = -\\frac{1}{m_2}"
    },
    {
      "type": "heading",
      "body": "Quadratic Formula"
    },
    {
      "type": "text",
      "body": "For $ax^2 + bx + c = 0$, the roots are:"
    },
    {
      "type": "formula",
      "latex": "x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}"
    },
    {
      "type": "callout",
      "variant": "tip",
      "body": "On the exam, if a quadratic looks messy, check the discriminant first. If $b^2 - 4ac < 0$, there are no real roots — you can eliminate answers immediately."
    },
    {
      "type": "callout",
      "variant": "warning",
      "body": "The distance formula and the quadratic formula are both in the handbook. Don't waste time memorizing — know where to find them and practice using them fast."
    }
  ],
  "illustration": null,
  "problems": [
    {
      "id": "math-slq-q1",
      "statement": "A surveyor records two elevation points along a proposed road centerline: Point A at station $0{+}00$ with elevation $120.0\\,\\text{ft}$ and Point B at station $3{+}00$ with elevation $126.0\\,\\text{ft}$. What is the grade (slope) of the road between the two points?",
      "choices": [
        {
          "id": "c1",
          "text": "1.5%"
        },
        {
          "id": "c2",
          "text": "2.0%"
        },
        {
          "id": "c3",
          "text": "3.0%"
        },
        {
          "id": "c4",
          "text": "6.0%"
        }
      ],
      "correctAnswerId": "c2",
      "difficulty": "easy",
      "eli5": "Station notation is just a way of writing distance in hundreds of feet — station 3+00 means 300 ft. Once you see that, it's just rise over run: 6 ft of rise over 300 ft of run = 0.02 = 2%. The trap is forgetting to convert stations to feet and using \"3\" instead of \"300,\" which gives you 200% — obviously wrong but easy to do under pressure.",
      "hint": "Convert the station numbers to feet before dividing.",
      "steps": [
        {
          "text": "Convert stations to feet: Station $0{+}00 = 0\\,\\text{ft}$, Station $3{+}00 = 300\\,\\text{ft}$.",
          "latex": null
        },
        {
          "text": "Apply the slope formula:",
          "latex": "m = \\frac{126.0 - 120.0}{300 - 0} = \\frac{6.0}{300} = 0.02"
        },
        {
          "text": "Convert to percent:",
          "latex": "0.02 \\times 100 = 2.0\\%"
        }
      ],
      "handbookPage": "p. 36",
      "handbookFormula": "m = \\frac{y_2 - y_1}{x_2 - x_1}",
      "videoUrl": null,
      "traps": [
        "Forgetting to convert station notation to feet",
        "Confusing rise/run with run/rise"
      ],
      "diagram": { "component": "RoadGrade", "props": { "run": 300, "rise": 6 } }
    },
    {
      "id": "math-slq-q2",
      "statement": "A property boundary runs from point $P(2, 3)$ to point $Q(8, 7)$. A utility easement must be laid perpendicular to this boundary through point $Q$. What is the slope of the easement line?",
      "choices": [
        {
          "id": "c1",
          "text": "$\\frac{2}{3}$"
        },
        {
          "id": "c2",
          "text": "$-\\frac{2}{3}$"
        },
        {
          "id": "c3",
          "text": "$\\frac{3}{2}$"
        },
        {
          "id": "c4",
          "text": "$-\\frac{3}{2}$"
        }
      ],
      "correctAnswerId": "c4",
      "difficulty": "medium",
      "eli5": "First find the slope of the boundary line — rise over run gives you 2/3. Then flip it and negate it for the perpendicular slope: 2/3 becomes -3/2. The most common mistake is only flipping without negating (getting 3/2) or only negating without flipping (getting -2/3). You have to do both — flip AND negate.",
      "hint": "Perpendicular means negative reciprocal — flip the fraction and change the sign.",
      "steps": [
        {
          "text": "Find the slope of boundary PQ:",
          "latex": "m_{PQ} = \\frac{7 - 3}{8 - 2} = \\frac{4}{6} = \\frac{2}{3}"
        },
        {
          "text": "Apply the perpendicular slope rule:",
          "latex": "m_\\perp = -\\frac{1}{m_{PQ}} = -\\frac{1}{2/3} = -\\frac{3}{2}"
        }
      ],
      "handbookPage": "p. 36",
      "handbookFormula": "m_1 = -\\frac{1}{m_2}",
      "videoUrl": null,
      "traps": [
        "Only negating without taking the reciprocal",
        "Only taking the reciprocal without negating"
      ],
      "diagram": null
    },
    {
      "id": "math-slq-q3",
      "statement": "A projectile is launched from a $5\\,\\text{m}$ high embankment with an initial vertical velocity of $12\\,\\text{m/s}$. Its height is modeled by $h(t) = -4.9t^2 + 12t + 5$. At what time does the projectile hit the ground?",
      "choices": [
        {
          "id": "c1",
          "text": "0.36 s"
        },
        {
          "id": "c2",
          "text": "2.45 s"
        },
        {
          "id": "c3",
          "text": "2.82 s"
        },
        {
          "id": "c4",
          "text": "3.10 s"
        }
      ],
      "correctAnswerId": "c3",
      "difficulty": "hard",
      "eli5": "Set the height equation equal to zero and use the quadratic formula. You'll get two roots — one negative and one positive. Negative time doesn't make physical sense, so throw it away. The sneaky part: the negative root (-0.36) shows up as choice A without the minus sign. If you forget to check which root is physically valid, you might pick it. Always ask yourself: does my answer make sense in the real world?",
      "hint": "Set $h(t) = 0$ and apply the quadratic formula. One of the two roots won't make physical sense.",
      "steps": [
        {
          "text": "Set $h(t) = 0$:",
          "latex": "-4.9t^2 + 12t + 5 = 0"
        },
        {
          "text": "Identify coefficients: $a = -4.9$, $b = 12$, $c = 5$.",
          "latex": null
        },
        {
          "text": "Compute the discriminant:",
          "latex": "b^2 - 4ac = 144 - 4(-4.9)(5) = 144 + 98 = 242"
        },
        {
          "text": "Apply the quadratic formula:",
          "latex": "t = \\frac{-12 \\pm \\sqrt{242}}{2(-4.9)} = \\frac{-12 \\pm 15.56}{-9.8}"
        },
        {
          "text": "Evaluate both roots:",
          "latex": "t = \\frac{-12 + 15.56}{-9.8} = -0.36\\,\\text{s} \\quad\\text{and}\\quad t = \\frac{-12 - 15.56}{-9.8} = 2.81\\,\\text{s}"
        },
        {
          "text": "Discard the negative root (time can't be negative):",
          "latex": "t \\approx 2.82\\,\\text{s}"
        }
      ],
      "handbookPage": "p. 36",
      "handbookFormula": "x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}",
      "videoUrl": null,
      "traps": [
        "Selecting the negative root (appears as choice A without the minus sign)",
        "Sign errors with the negative leading coefficient (a = -4.9)",
        "Forgetting the embankment adds 5 m to initial height"
      ],
      "diagram": null
    }
  ],
  examProblems: [
    {
      id: 'math-slq-ex1',
      type: 'computational',
      statement: 'A tunnel centerline runs from coordinates $(100, 200)$ to $(400, 500)$. What is the length of the tunnel in meters?',
      choices: [
        { id: 'c1', text: '300 m' },
        { id: 'c2', text: '424.3 m' },
        { id: 'c3', text: '500 m' },
        { id: 'c4', text: '600 m' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'easy',
      eli5: 'Use the distance formula. The horizontal run is 300, the vertical rise is 300. Plug into $d = \\sqrt{300^2 + 300^2} = \\sqrt{180{,}000} = 424.3$ m. Common mistake is adding the components ($300 + 300 = 600$) instead of using the distance formula.',
      hint: 'Use the distance formula between two points.',
      steps: [
        { text: 'Identify coordinates: $(x_1, y_1) = (100, 200)$, $(x_2, y_2) = (400, 500)$.', latex: null },
        { text: 'Apply the distance formula:', latex: 'd = \\sqrt{(400-100)^2 + (500-200)^2} = \\sqrt{300^2 + 300^2}' },
        { text: 'Simplify:', latex: 'd = \\sqrt{90000 + 90000} = \\sqrt{180000} = 424.3\\,\\text{m}' },
      ],
      handbookPage: 'p. 36',
      handbookFormula: 'd = \\sqrt{(x_2 - x_1)^2 + (y_2 - y_1)^2}',
      videoUrl: null,
      traps: ['Adding components instead of using the distance formula', 'Forgetting to take the square root'],
      diagram: null,
    },
    {
      id: 'math-slq-ex2',
      type: 'conceptual',
      statement: 'Two lines have slopes $m_1 = 3$ and $m_2 = -\\frac{1}{3}$. Which statement is correct?',
      choices: [
        { id: 'c1', text: 'The lines are parallel' },
        { id: 'c2', text: 'The lines are perpendicular' },
        { id: 'c3', text: 'The lines intersect but are neither parallel nor perpendicular' },
        { id: 'c4', text: 'The lines are coincident' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'easy',
      eli5: 'Two lines are perpendicular when their slopes are negative reciprocals. Check: $3 \\times (-1/3) = -1$. That confirms they are perpendicular. Parallel lines have equal slopes, and coincident means they are the same line.',
      hint: 'Check if the product of the slopes equals $-1$.',
      steps: [
        { text: 'For perpendicular lines, $m_1 \\times m_2 = -1$.', latex: null },
        { text: 'Check:', latex: '3 \\times \\left(-\\frac{1}{3}\\right) = -1 \\quad \\checkmark' },
        { text: 'Since the product is $-1$, the lines are perpendicular.', latex: null },
      ],
      handbookPage: 'p. 36',
      handbookFormula: 'm_1 = -\\frac{1}{m_2}',
      videoUrl: null,
      traps: ['Confusing perpendicular (product = -1) with parallel (equal slopes)'],
      diagram: null,
    },
    {
      id: 'math-slq-ex3',
      type: 'computational',
      statement: 'A retaining wall base runs from point $A(1, 4)$ to point $B(7, 12)$. A drainage line must pass through the midpoint of $AB$ with slope $m = -2$. What is the equation of the drainage line in slope-intercept form?',
      choices: [
        { id: 'c1', text: '$y = -2x + 16$' },
        { id: 'c2', text: '$y = -2x + 8$' },
        { id: 'c3', text: '$y = -2x + 24$' },
        { id: 'c4', text: '$y = -2x + 12$' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'medium',
      eli5: 'Two steps here: first find the midpoint of $AB$, then use point-slope form with the given slope. Midpoint is just the average of the coordinates: $((1+7)/2,\\,(4+12)/2) = (4, 8)$. Then plug into $y - 8 = -2(x - 4)$ and simplify to $y = -2x + 16$. The trap is using point A or B instead of the midpoint, which gives you one of the wrong answers.',
      hint: 'Find the midpoint of AB first, then apply the point-slope formula with the given slope.',
      steps: [
        { text: 'Find the midpoint of $AB$:', latex: 'M = \\left(\\frac{1+7}{2},\\, \\frac{4+12}{2}\\right) = (4,\\, 8)' },
        { text: 'Apply point-slope form with $m = -2$ through $(4, 8)$:', latex: 'y - 8 = -2(x - 4)' },
        { text: 'Convert to slope-intercept form:', latex: 'y = -2x + 8 + 8 = -2x + 16' },
      ],
      handbookPage: 'p. 36',
      handbookFormula: 'y - y_1 = m(x - x_1)',
      videoUrl: null,
      traps: ['Using an endpoint instead of the midpoint', 'Distributing the slope incorrectly when expanding point-slope form'],
      diagram: null,
    },
    {
      id: 'math-slq-ex4',
      type: 'conceptual',
      statement: 'A quadratic equation $ax^2 + bx + c = 0$ has a discriminant of $b^2 - 4ac = -16$. Which statement about the roots is correct?',
      choices: [
        { id: 'c1', text: 'There are two distinct real roots' },
        { id: 'c2', text: 'There is exactly one repeated real root' },
        { id: 'c3', text: 'There are no real roots' },
        { id: 'c4', text: 'The equation cannot be solved' },
      ],
      correctAnswerId: 'c3',
      difficulty: 'hard',
      eli5: 'The discriminant tells you everything about the nature of the roots. Positive means two distinct real roots, zero means one repeated root, negative means no real roots (complex conjugate pair). A negative discriminant means $\\sqrt{\\Delta}$ involves the square root of a negative number in the quadratic formula, which has no real solution. The equation can still be solved with complex numbers, so choice D is wrong — it is solvable, just not over the reals.',
      hint: 'Recall what the sign of the discriminant tells you about the number and type of roots.',
      steps: [
        { text: 'The discriminant is $\\Delta = b^2 - 4ac = -16 < 0$.', latex: null },
        { text: 'A negative discriminant means $\\sqrt{\\Delta}$ is imaginary:', latex: '\\sqrt{-16} = 4i' },
        { text: 'The quadratic formula produces complex conjugate roots — no real solutions exist.', latex: null },
      ],
      handbookPage: 'p. 36',
      handbookFormula: 'x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}',
      videoUrl: null,
      traps: ['Confusing "no real roots" with "no solution at all" — complex roots still exist', 'Thinking a negative discriminant means one root'],
      diagram: null,
    },
  ],
};
