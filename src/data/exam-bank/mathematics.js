// Exam bank: mathematics
// Auto-extracted from lesson files — 53 questions

const PROBLEMS = [
  {
    id: 'math-slq-ex1',
    type: 'computational',
    statement: 'A tunnel centerline runs from coordinates $(100, 200)$ to $(400, 500)$. What is the length of the tunnel in meters?',
    choices: [
      {
        id: 'c1',
        text: '300 m'
      },
      {
        id: 'c2',
        text: '424.3 m'
      },
      {
        id: 'c3',
        text: '500 m'
      },
      {
        id: 'c4',
        text: '600 m'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'Use the distance formula. The horizontal run is 300, the vertical rise is 300. Plug into $d = \\sqrt{300^2 + 300^2} = \\sqrt{180{,}000} = 424.3$ m. Common mistake is adding the components ($300 + 300 = 600$) instead of using the distance formula.',
    hint: 'Use the distance formula between two points.',
    steps: [
      {
        text: 'Identify coordinates: $(x_1, y_1) = (100, 200)$, $(x_2, y_2) = (400, 500)$.',
        latex: null
      },
      {
        text: 'Apply the distance formula:',
        latex: 'd = \\sqrt{(400-100)^2 + (500-200)^2} = \\sqrt{300^2 + 300^2}'
      },
      {
        text: 'Simplify:',
        latex: 'd = \\sqrt{90000 + 90000} = \\sqrt{180000} = 424.3\\,\\text{m}'
      }
    ],
    handbookPage: 'p. 36',
    handbookFormula: 'd = \\sqrt{(x_2 - x_1)^2 + (y_2 - y_1)^2}',
    videoUrl: null,
    traps: ['Adding components instead of using the distance formula', 'Forgetting to take the square root'],
    diagram: null,
    lessonId: 'straight-lines-quadratics',
    chapterId: 'mathematics'
  },
  {
    id: 'math-slq-ex2',
    type: 'conceptual',
    statement: 'Two lines have slopes $m_1 = 3$ and $m_2 = -\\frac{1}{3}$. Which statement is correct?',
    choices: [
      {
        id: 'c1',
        text: 'The lines are perpendicular'
      },
      {
        id: 'c2',
        text: 'The lines are parallel'
      },
      {
        id: 'c3',
        text: 'The lines intersect but are neither parallel nor perpendicular'
      },
      {
        id: 'c4',
        text: 'The lines are coincident'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Two lines are perpendicular when their slopes are negative reciprocals. Check: $3 \\times (-1/3) = -1$. That confirms they are perpendicular. Parallel lines have equal slopes, and coincident means they are the same line.',
    hint: 'Check if the product of the slopes equals $-1$.',
    steps: [
      {
        text: 'For perpendicular lines, $m_1 \\times m_2 = -1$.',
        latex: null
      },
      {
        text: 'Check:',
        latex: '3 \\times \\left(-\\frac{1}{3}\\right) = -1 \\quad \\checkmark'
      },
      {
        text: 'Since the product is $-1$, the lines are perpendicular.',
        latex: null
      }
    ],
    handbookPage: 'p. 36',
    handbookFormula: 'm_1 = -\\frac{1}{m_2}',
    videoUrl: null,
    traps: ['Confusing perpendicular (product = -1) with parallel (equal slopes)'],
    diagram: null,
    lessonId: 'straight-lines-quadratics',
    chapterId: 'mathematics'
  },
  {
    id: 'math-slq-ex3',
    type: 'computational',
    statement: 'A retaining wall base runs from point $A(1, 4)$ to point $B(7, 12)$. A drainage line must pass through the midpoint of $AB$ with slope $m = -2$. What is the equation of the drainage line in slope-intercept form?',
    choices: [
      {
        id: 'c1',
        text: '$y = -2x + 16$'
      },
      {
        id: 'c2',
        text: '$y = -2x + 8$'
      },
      {
        id: 'c3',
        text: '$y = -2x + 24$'
      },
      {
        id: 'c4',
        text: '$y = -2x + 12$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Two steps here: first find the midpoint of $AB$, then use point-slope form with the given slope. Midpoint is just the average of the coordinates: $((1+7)/2,\\,(4+12)/2) = (4, 8)$. Then plug into $y - 8 = -2(x - 4)$ and simplify to $y = -2x + 16$. The trap is using point A or B instead of the midpoint, which gives you one of the wrong answers.',
    hint: 'Find the midpoint of AB first, then apply the point-slope formula with the given slope.',
    steps: [
      {
        text: 'Find the midpoint of $AB$:',
        latex: 'M = \\left(\\frac{1+7}{2},\\, \\frac{4+12}{2}\\right) = (4,\\, 8)'
      },
      {
        text: 'Apply point-slope form with $m = -2$ through $(4, 8)$:',
        latex: 'y - 8 = -2(x - 4)'
      },
      {
        text: 'Convert to slope-intercept form:',
        latex: 'y = -2x + 8 + 8 = -2x + 16'
      }
    ],
    handbookPage: 'p. 36',
    handbookFormula: 'y - y_1 = m(x - x_1)',
    videoUrl: null,
    traps: [
      'Using an endpoint instead of the midpoint',
      'Distributing the slope incorrectly when expanding point-slope form'
    ],
    diagram: null,
    lessonId: 'straight-lines-quadratics',
    chapterId: 'mathematics'
  },
  {
    id: 'math-slq-ex4',
    type: 'conceptual',
    statement: 'A quadratic equation $ax^2 + bx + c = 0$ has a discriminant of $b^2 - 4ac = -16$. Which statement about the roots is correct?',
    choices: [
      {
        id: 'c1',
        text: 'There are two distinct real roots'
      },
      {
        id: 'c2',
        text: 'There is exactly one repeated real root'
      },
      {
        id: 'c3',
        text: 'There are no real roots'
      },
      {
        id: 'c4',
        text: 'The equation cannot be solved'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'The discriminant tells you everything about the nature of the roots. Positive means two distinct real roots, zero means one repeated root, negative means no real roots (complex conjugate pair). A negative discriminant means $\\sqrt{\\Delta}$ involves the square root of a negative number in the quadratic formula, which has no real solution. The equation can still be solved with complex numbers, so the choice claiming the equation cannot be solved is wrong — it is solvable, just not over the reals.',
    hint: 'Recall what the sign of the discriminant tells you about the number and type of roots.',
    steps: [
      {
        text: 'The discriminant is $\\Delta = b^2 - 4ac = -16 < 0$.',
        latex: null
      },
      {
        text: 'A negative discriminant means $\\sqrt{\\Delta}$ is imaginary:',
        latex: '\\sqrt{-16} = 4i'
      },
      {
        text: 'The quadratic formula produces complex conjugate roots — no real solutions exist.',
        latex: null
      }
    ],
    handbookPage: 'p. 36',
    handbookFormula: 'x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}',
    videoUrl: null,
    traps: [
      'Confusing "no real roots" with "no solution at all" — complex roots still exist',
      'Thinking a negative discriminant means one root'
    ],
    diagram: null,
    lessonId: 'straight-lines-quadratics',
    chapterId: 'mathematics'
  },
  {
    id: 'math-log-ex1',
    type: 'computational',
    statement: 'Solve for $x$: $3^x = 81$.',
    choices: [
      {
        id: 'c1',
        text: '$3$'
      },
      {
        id: 'c2',
        text: '$4$'
      },
      {
        id: 'c3',
        text: '$27$'
      },
      {
        id: 'c4',
        text: '$5$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'Rewrite the equation in log form: $x = \\log_3(81)$. You\'re asking \'3 to what power gives 81?\' Count: $3^1 = 3$, $3^2 = 9$, $3^3 = 27$, $3^4 = 81$. So $x = 4$. Alternatively, take $\\log$ of both sides and use the power rule to bring $x$ down. Either way, the answer is 4. The trap is confusing 81 with $3^3 = 27$.',
    hint: 'Rewrite the equation as a logarithm: $x = \\log_3(81)$.',
    steps: [
      {
        text: 'Rewrite in log form:',
        latex: 'x = \\log_3(81)'
      },
      {
        text: 'Recognize that $3^4 = 81$:',
        latex: 'x = 4'
      }
    ],
    handbookPage: 'p. 36',
    handbookFormula: '\\log_b(x) = c \\iff b^c = x',
    videoUrl: null,
    traps: ['Confusing powers of 3 — 3^3 = 27, not 81', 'Dividing 81 by 3 repeatedly but losing count'],
    diagram: null,
    lessonId: 'logarithms',
    chapterId: 'mathematics'
  },
  {
    id: 'math-log-ex2',
    type: 'computational',
    statement: 'Simplify: $\\ln(e^4) + \\ln(e^{-1})$.',
    choices: [
      {
        id: 'c1',
        text: '$3$'
      },
      {
        id: 'c2',
        text: '$4$'
      },
      {
        id: 'c3',
        text: '$5$'
      },
      {
        id: 'c4',
        text: '$-4$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Use the identity $\\ln(e^n) = n$ on each term. The first term gives 4, the second gives $-1$. Add them: $4 + (-1) = 3$. You could also combine first using the product rule: $\\ln(e^4 \\cdot e^{-1}) = \\ln(e^3) = 3$. Either path works. The trap is multiplying the exponents instead of adding them ($4 \\times -1 = -4$), which is the choice $-4$.',
    hint: 'Apply $\\ln(e^n) = n$ to each term, then add the results.',
    steps: [
      {
        text: 'Apply the identity to each term:',
        latex: '\\ln(e^4) = 4 \\quad\\text{and}\\quad \\ln(e^{-1}) = -1'
      },
      {
        text: 'Add:',
        latex: '4 + (-1) = 3'
      }
    ],
    handbookPage: 'p. 36',
    handbookFormula: '\\ln(e^n) = n',
    videoUrl: null,
    traps: [
      'Multiplying the exponents (4 times -1) instead of adding',
      'Dropping the negative sign on the second term'
    ],
    diagram: null,
    lessonId: 'logarithms',
    chapterId: 'mathematics'
  },
  {
    id: 'math-log-ex3',
    type: 'computational',
    statement: 'An investment doubles in value according to $2 = e^{0.06t}$, where $t$ is in years. How many years does it take to double?',
    choices: [
      {
        id: 'c1',
        text: '$8.3$ years'
      },
      {
        id: 'c2',
        text: '$11.6$ years'
      },
      {
        id: 'c3',
        text: '$16.7$ years'
      },
      {
        id: 'c4',
        text: '$33.3$ years'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Take the natural log of both sides to bring the exponent down: $\\ln(2) = 0.06t$. Then divide: $t = \\ln(2) / 0.06 = 0.6931 / 0.06 = 11.6$ years. The main mistake is using $\\log_{10}(2)$ instead of $\\ln(2)$ — those are different numbers. Since the base of the exponent is $e$, you need the natural log to cancel it.',
    hint: 'Take $\\ln$ of both sides to undo the exponential, then isolate $t$.',
    steps: [
      {
        text: 'Take natural log of both sides:',
        latex: '\\ln(2) = 0.06t'
      },
      {
        text: 'Solve for $t$:',
        latex: 't = \\frac{\\ln(2)}{0.06} = \\frac{0.6931}{0.06} = 11.6\\,\\text{years}'
      }
    ],
    handbookPage: 'p. 36',
    handbookFormula: '\\ln(e^x) = x',
    videoUrl: null,
    traps: [
      'Using log base 10 instead of natural log',
      'Dividing 0.06 by ln(2) instead of the other way around'
    ],
    diagram: null,
    lessonId: 'logarithms',
    chapterId: 'mathematics'
  },
  {
    id: 'math-log-ex4',
    type: 'conceptual',
    statement: 'Which of the following is a valid logarithmic identity?',
    choices: [
      {
        id: 'c1',
        text: '$\\log(x + y) = \\log x + \\log y$'
      },
      {
        id: 'c2',
        text: '$\\log(x - y) = \\log x - \\log y$'
      },
      {
        id: 'c3',
        text: '$\\log(x^c) = c \\cdot \\log x$'
      },
      {
        id: 'c4',
        text: '$\\log(xy) = \\log x \\cdot \\log y$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'The power rule says you can pull an exponent out as a coefficient: $\\log(x^c) = c \\cdot \\log x$. The other three choices are the most common log mistakes students make. There is NO log rule for sums ($x + y$) or differences ($x - y$) inside a log. And the product rule says $\\log(xy) = \\log x + \\log y$ (addition), not multiplication. If you remember only one thing: logs turn multiplication into addition and powers into multiplication — never sums into anything.',
    hint: 'Only products, quotients, and powers have log identities. Sums and differences inside a log cannot be split.',
    steps: [
      {
        text: 'The power rule states:',
        latex: '\\log(x^c) = c \\cdot \\log x'
      },
      {
        text: 'The sum choice is wrong: $\\log(x + y) \\neq \\log x + \\log y$ — no identity for sums.',
        latex: null
      },
      {
        text: 'The difference choice is wrong: $\\log(x - y) \\neq \\log x - \\log y$ — no identity for differences.',
        latex: null
      },
      {
        text: 'The product choice is wrong: the product rule gives addition, not multiplication: $\\log(xy) = \\log x + \\log y$.',
        latex: null
      }
    ],
    handbookPage: 'p. 36',
    handbookFormula: '\\log(x^c) = c\\,\\log x',
    videoUrl: null,
    traps: [
      'Confusing the product rule — log(xy) = log x + log y, not log x times log y',
      'Thinking log(x + y) can be split — there is no identity for sums inside a log'
    ],
    diagram: null,
    lessonId: 'logarithms',
    chapterId: 'mathematics'
  },
  {
    id: 'math-rtt-ex1',
    type: 'computational',
    statement: 'A ladder leans against a wall at an angle of $65°$ with the ground. If the foot of the ladder is $3.0\\,\\text{m}$ from the wall, how long is the ladder?',
    choices: [
      {
        id: 'c1',
        text: '6.4 m'
      },
      {
        id: 'c2',
        text: '3.3 m'
      },
      {
        id: 'c3',
        text: '2.7 m'
      },
      {
        id: 'c4',
        text: '7.1 m'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'You know the adjacent side (3.0 m from the wall) and the angle with the ground ($65°$), and you want the hypotenuse (the ladder). Adjacent over hypotenuse is cosine: $\\cos 65° = 3/L$, so $L = 3/\\cos 65° = 3/0.4226 = 7.1$ m. The trap is using sine instead of cosine, which would give you the wall height, not the ladder length.',
    hint: 'You know the side adjacent to the angle and need the hypotenuse. Which trig ratio connects those?',
    steps: [
      {
        text: 'The ground distance (3.0 m) is adjacent to the 65 degree angle. The ladder is the hypotenuse.',
        latex: null
      },
      {
        text: 'Use cosine:',
        latex: '\\cos 65° = \\frac{3.0}{L}'
      },
      {
        text: 'Solve for L:',
        latex: 'L = \\frac{3.0}{\\cos 65°} = \\frac{3.0}{0.4226} = 7.1\\,\\text{m}'
      }
    ],
    handbookPage: 'p. 23',
    handbookFormula: '\\cos\\theta = \\frac{\\text{adj}}{\\text{hyp}}',
    videoUrl: null,
    traps: ['Using sine instead of cosine', 'Multiplying by cos instead of dividing'],
    diagram: null,
    lessonId: 'right-triangle-trig',
    chapterId: 'mathematics'
  },
  {
    id: 'math-rtt-ex2',
    type: 'computational',
    statement: 'A guy wire attached to the top of a $20\\,\\text{m}$ antenna makes a $55°$ angle with the ground. What is the length of the guy wire?',
    choices: [
      {
        id: 'c1',
        text: '24.4 m'
      },
      {
        id: 'c2',
        text: '34.9 m'
      },
      {
        id: 'c3',
        text: '16.4 m'
      },
      {
        id: 'c4',
        text: '28.6 m'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'The antenna height (20 m) is opposite the $55°$ angle. The wire is the hypotenuse. Opposite over hypotenuse is sine: $\\sin 55° = 20/W$, so $W = 20/\\sin 55° = 20/0.8192 = 24.4$ m. The classic trap is using tangent, which connects opposite and adjacent, not opposite and hypotenuse.',
    hint: 'You know the opposite side and need the hypotenuse. SOH-CAH-TOA tells you which ratio to use.',
    steps: [
      {
        text: 'The antenna (20 m) is opposite the 55 degree angle at ground level. The wire is the hypotenuse.',
        latex: null
      },
      {
        text: 'Use sine:',
        latex: '\\sin 55° = \\frac{20}{W}'
      },
      {
        text: 'Solve for W:',
        latex: 'W = \\frac{20}{\\sin 55°} = \\frac{20}{0.8192} = 24.4\\,\\text{m}'
      }
    ],
    handbookPage: 'p. 23',
    handbookFormula: '\\sin\\theta = \\frac{\\text{opp}}{\\text{hyp}}',
    videoUrl: null,
    traps: [
      'Using tangent instead of sine',
      'Using cos instead of sin — that gives the ground distance, not the wire length'
    ],
    diagram: null,
    lessonId: 'right-triangle-trig',
    chapterId: 'mathematics'
  },
  {
    id: 'math-rtt-ex3',
    type: 'computational',
    statement: 'A ramp rises $1.5\\,\\text{m}$ over a horizontal distance of $12\\,\\text{m}$. What is the angle of incline of the ramp?',
    choices: [
      {
        id: 'c1',
        text: '$82.9°$'
      },
      {
        id: 'c2',
        text: '$12.5°$'
      },
      {
        id: 'c3',
        text: '$7.1°$'
      },
      {
        id: 'c4',
        text: '$0.125°$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'You know the opposite (rise = 1.5 m) and the adjacent (run = 12 m). That is tangent. Take the inverse tangent of $1.5/12 = 0.125$ to get $7.1°$. The $0.125°$ choice is the ratio itself without taking the inverse trig function. The $82.9°$ choice is $90°$ minus the correct answer — that would be the angle from the vertical, not the horizontal.',
    hint: 'You have the rise and the run. Which trig function relates opposite to adjacent?',
    steps: [
      {
        text: 'Identify: rise (opposite) = 1.5 m, run (adjacent) = 12 m.',
        latex: null
      },
      {
        text: 'Apply inverse tangent:',
        latex: '\\theta = \\tan^{-1}\\!\\left(\\frac{1.5}{12}\\right) = \\tan^{-1}(0.125)'
      },
      {
        text: 'Evaluate:',
        latex: '\\theta = 7.1°'
      }
    ],
    handbookPage: 'p. 23',
    handbookFormula: '\\tan\\theta = \\frac{\\text{opp}}{\\text{adj}}',
    videoUrl: null,
    traps: [
      'Reporting the ratio as the angle instead of taking inverse tangent',
      'Giving the complement (90 minus the angle) instead of the angle from horizontal'
    ],
    diagram: null,
    lessonId: 'right-triangle-trig',
    chapterId: 'mathematics'
  },
  {
    id: 'math-rtt-ex4',
    type: 'conceptual',
    statement: 'A force $F$ acts at angle $\\theta$ above the horizontal. An engineer writes $F_x = F\\sin\\theta$ and $F_y = F\\cos\\theta$. What error did the engineer make?',
    choices: [
      {
        id: 'c1',
        text: 'The formulas are correct as written'
      },
      {
        id: 'c2',
        text: 'The sin and cos are swapped — $F_x$ should use cos and $F_y$ should use sin'
      },
      {
        id: 'c3',
        text: 'Both components should use tangent'
      },
      {
        id: 'c4',
        text: 'The force should be divided by the trig functions, not multiplied'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'When the angle is measured from the horizontal, the horizontal component is adjacent to the angle, so it uses cosine. The vertical component is opposite the angle, so it uses sine. The engineer swapped them. This is the single most common trig error on the FE exam. Remember: cosine is "cozy" with the adjacent side, and the adjacent side is the one the angle is measured from. The correct formulas are $F_x = F\\cos\\theta$ and $F_y = F\\sin\\theta$.',
    hint: 'When the angle is measured FROM the horizontal, which component (horizontal or vertical) is adjacent to that angle?',
    steps: [
      {
        text: 'The angle $\\theta$ is measured from the horizontal axis.',
        latex: null
      },
      {
        text: 'The horizontal component is adjacent to $\\theta$, so it uses cosine:',
        latex: 'F_x = F\\cos\\theta'
      },
      {
        text: 'The vertical component is opposite $\\theta$, so it uses sine:',
        latex: 'F_y = F\\sin\\theta'
      },
      {
        text: 'The engineer swapped sin and cos.',
        latex: null
      }
    ],
    handbookPage: 'p. 23',
    handbookFormula: 'F_x = F\\cos\\theta,\\quad F_y = F\\sin\\theta',
    videoUrl: null,
    traps: [
      'Assuming the formulas look correct because the components have some trig function',
      'Forgetting that the reference direction of the angle determines which function to use'
    ],
    diagram: null,
    lessonId: 'right-triangle-trig',
    chapterId: 'mathematics'
  },
  {
    id: 'math-lsc-ex1',
    type: 'computational',
    statement: 'In triangle $PQR$, angle $P = 50°$, angle $Q = 65°$, and side $p = 24\\,\\text{m}$ (opposite angle $P$). What is the length of side $q$ (opposite angle $Q$)?',
    choices: [
      {
        id: 'c1',
        text: '$28.4\\,\\text{m}$'
      },
      {
        id: 'c2',
        text: '$20.3\\,\\text{m}$'
      },
      {
        id: 'c3',
        text: '$31.7\\,\\text{m}$'
      },
      {
        id: 'c4',
        text: '$22.1\\,\\text{m}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'You have a complete side-angle pair ($p$ and $P$) plus another angle ($Q$), so Law of Sines is your move. Set up the proportion and cross-multiply to solve for $q$. The bigger angle ($65°$ vs $50°$) should give a bigger side, so $q > 24$ is a quick sanity check. If your answer came out smaller, you probably flipped the fraction.',
    hint: 'You have a side-angle pair — which law works directly with that setup?',
    steps: [
      {
        text: 'Set up Law of Sines:',
        latex: '\\frac{p}{\\sin P} = \\frac{q}{\\sin Q}'
      },
      {
        text: 'Solve for $q$:',
        latex: 'q = 24 \\times \\frac{\\sin 65°}{\\sin 50°} = 24 \\times \\frac{0.9063}{0.7660}'
      },
      {
        text: 'Compute:',
        latex: 'q = 24 \\times 1.1832 = 28.4\\,\\text{m}'
      }
    ],
    handbookPage: 'p. 38',
    handbookFormula: '\\frac{a}{\\sin A} = \\frac{b}{\\sin B} = \\frac{c}{\\sin C}',
    videoUrl: null,
    traps: [
      'Flipping the sine ratio and dividing instead of multiplying',
      'Using cosine instead of sine in the Law of Sines'
    ],
    diagram: null,
    lessonId: 'law-of-sines-cosines',
    chapterId: 'mathematics'
  },
  {
    id: 'math-lsc-ex2',
    type: 'computational',
    statement: 'Two sides of a triangular parcel measure $a = 120\\,\\text{m}$ and $b = 95\\,\\text{m}$, with an included angle $C = 48°$. What is the length of the third side $c$?',
    choices: [
      {
        id: 'c1',
        text: '$90.4\\,\\text{m}$'
      },
      {
        id: 'c2',
        text: '$78.4\\,\\text{m}$'
      },
      {
        id: 'c3',
        text: '$105.3\\,\\text{m}$'
      },
      {
        id: 'c4',
        text: '$152.6\\,\\text{m}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Two sides and the angle between them (SAS) means Law of Cosines. Plug in, compute each piece, then take the square root. The included angle is less than $90°$, so $\\cos 48°$ is positive and the correction term subtracts from $a^2 + b^2$. If the angle were obtuse, $\\cos C$ would be negative and you would actually add — that is a subtlety to watch for.',
    hint: 'Two sides with their included angle — which formula generalizes the Pythagorean theorem?',
    steps: [
      {
        text: 'Apply Law of Cosines:',
        latex: 'c^2 = a^2 + b^2 - 2ab\\cos C'
      },
      {
        text: 'Substitute:',
        latex: 'c^2 = 120^2 + 95^2 - 2(120)(95)\\cos 48°'
      },
      {
        text: 'Compute:',
        latex: 'c^2 = 14400 + 9025 - 22800 \\times 0.6691 = 23425 - 15256 = 8169'
      },
      {
        text: 'Take the square root:',
        latex: 'c = \\sqrt{8169} \\approx 90.4\\,\\text{m}'
      }
    ],
    handbookPage: 'p. 38',
    handbookFormula: 'c^2 = a^2 + b^2 - 2ab\\cos C',
    videoUrl: null,
    traps: [
      'Adding the cosine correction instead of subtracting it',
      'Forgetting to take the square root at the end'
    ],
    diagram: null,
    lessonId: 'law-of-sines-cosines',
    chapterId: 'mathematics'
  },
  {
    id: 'math-lsc-ex3',
    type: 'computational',
    statement: 'A triangular truss has sides $a = 7.5\\,\\text{m}$, $b = 9.0\\,\\text{m}$, and $c = 5.0\\,\\text{m}$. What is angle $A$ (opposite side $a$)?',
    choices: [
      {
        id: 'c1',
        text: '$42.3°$'
      },
      {
        id: 'c2',
        text: '$81.4°$'
      },
      {
        id: 'c3',
        text: '$56.4°$'
      },
      {
        id: 'c4',
        text: '$67.8°$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'All three sides, no angles — SSS situation. Rearrange the Law of Cosines to isolate $\\cos A$. Plug in the sides, do the arithmetic, and take inverse cosine. The numerator here comes out positive, so the angle is acute (less than $90°$). If it had come out negative, the angle would be obtuse. Always let the sign of the cosine tell you the story.',
    hint: 'Rearrange the Law of Cosines to solve for the angle: $\\cos A = \\frac{b^2 + c^2 - a^2}{2bc}$.',
    steps: [
      {
        text: 'Rearrange for $\\cos A$:',
        latex: '\\cos A = \\frac{b^2 + c^2 - a^2}{2bc}'
      },
      {
        text: 'Substitute:',
        latex: '\\cos A = \\frac{81 + 25 - 56.25}{2(9)(5)} = \\frac{49.75}{90} = 0.5528'
      },
      {
        text: 'Take inverse cosine:',
        latex: 'A = \\cos^{-1}(0.5528) = 56.4°'
      }
    ],
    handbookPage: 'p. 38',
    handbookFormula: '\\cos A = \\frac{b^2 + c^2 - a^2}{2bc}',
    videoUrl: null,
    traps: [
      'Mixing up which side to subtract in the numerator — always subtract the side opposite the angle you want',
      'Squaring side lengths incorrectly (7.5² = 56.25, not 52.5)'
    ],
    diagram: null,
    lessonId: 'law-of-sines-cosines',
    chapterId: 'mathematics'
  },
  {
    id: 'math-lsc-ex4',
    type: 'conceptual',
    statement: 'A surveyor knows two angles and the side between them (ASA). Which is the most efficient approach to solve the triangle?',
    choices: [
      {
        id: 'c1',
        text: 'Apply the Law of Cosines directly'
      },
      {
        id: 'c2',
        text: 'Find the third angle, then use the Law of Sines'
      },
      {
        id: 'c3',
        text: 'Use the Pythagorean theorem'
      },
      {
        id: 'c4',
        text: 'Convert to an SAS case and apply the Law of Cosines'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'With ASA you know two angles — and since the angles in a triangle sum to 180°, the third angle is free. Now you have a complete side-angle pair, which is exactly what the Law of Sines needs. The Law of Cosines requires SAS or SSS, and the Pythagorean theorem only works for right triangles. The decision tree is simple: if you can form a side-angle pair, use Sines; if you have SAS or SSS, use Cosines.',
    hint: 'The three angles of a triangle sum to 180°. Once you know all three angles, which law uses a side-angle pair?',
    steps: [
      {
        text: 'Two known angles means you can find the third: $C = 180° - A - B$.',
        latex: null
      },
      {
        text: 'Now you have a complete side-angle pair (the given side and its opposite angle).',
        latex: null
      },
      {
        text: 'Apply the Law of Sines to find the remaining sides.',
        latex: '\\frac{a}{\\sin A} = \\frac{b}{\\sin B} = \\frac{c}{\\sin C}'
      }
    ],
    handbookPage: 'p. 38',
    handbookFormula: '\\frac{a}{\\sin A} = \\frac{b}{\\sin B} = \\frac{c}{\\sin C}',
    videoUrl: null,
    traps: [
      'Trying to use the Law of Cosines without having two sides',
      'Forgetting to compute the third angle first'
    ],
    diagram: null,
    lessonId: 'law-of-sines-cosines',
    chapterId: 'mathematics'
  },
  {
    id: 'math-ucti-ex1',
    type: 'computational',
    statement: 'What is the exact value of $\\sin 150°$?',
    choices: [
      {
        id: 'c1',
        text: '$-\\frac{1}{2}$'
      },
      {
        id: 'c2',
        text: '$-\\frac{\\sqrt{3}}{2}$'
      },
      {
        id: 'c3',
        text: '$\\frac{\\sqrt{3}}{2}$'
      },
      {
        id: 'c4',
        text: '$\\frac{1}{2}$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: '150° is in the second quadrant. Its reference angle is $180° - 150° = 30°$. Sine of 30° is $1/2$. In Q2, sine is positive (y-coordinates are positive above the x-axis), so $\\sin 150° = +1/2$. The trap is picking the negative version — sine is only negative in Q3 and Q4. Also don\'t confuse $\\sin 30°$ with $\\cos 30°$ which is $\\sqrt{3}/2$.',
    hint: 'Find the reference angle for 150°, then determine the sign from the quadrant.',
    steps: [
      {
        text: 'Reference angle:',
        latex: '180° - 150° = 30°'
      },
      {
        text: 'In Q2, sine is positive:',
        latex: '\\sin 150° = +\\sin 30° = \\frac{1}{2}'
      }
    ],
    handbookPage: 'p. 38',
    handbookFormula: '\\sin 30° = \\frac{1}{2}',
    videoUrl: null,
    traps: [
      'Applying a negative sign — sine is positive in Q2',
      'Using $\\cos 30° = \\sqrt{3}/2$ instead of $\\sin 30° = 1/2$'
    ],
    diagram: null,
    lessonId: 'unit-circle-trig-identities',
    chapterId: 'mathematics'
  },
  {
    id: 'math-ucti-ex2',
    type: 'computational',
    statement: 'If $\\cos\\theta = \\frac{7}{25}$ and $\\theta$ is in the fourth quadrant, what is $\\sin\\theta$?',
    choices: [
      {
        id: 'c1',
        text: '$\\frac{24}{25}$'
      },
      {
        id: 'c2',
        text: '$-\\frac{7}{25}$'
      },
      {
        id: 'c3',
        text: '$-\\frac{24}{25}$'
      },
      {
        id: 'c4',
        text: '$\\frac{18}{25}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Start with the Pythagorean identity: $\\sin^2\\theta = 1 - \\cos^2\\theta = 1 - 49/625 = 576/625$. Square root gives $\\pm 24/25$. Now check the quadrant: Q4 means y is negative, so sine is negative. The answer is $-24/25$ (the $-\\frac{24}{25}$ choice). The $\\frac{24}{25}$ choice is the positive root — that\'s Q1, not Q4. Always let the quadrant tell you the sign.',
    hint: 'Use $\\sin^2\\theta + \\cos^2\\theta = 1$, then pick the sign from the quadrant.',
    steps: [
      {
        text: 'Apply the Pythagorean identity:',
        latex: '\\sin^2\\theta = 1 - \\cos^2\\theta = 1 - \\frac{49}{625} = \\frac{576}{625}'
      },
      {
        text: 'Take the square root:',
        latex: '\\sin\\theta = \\pm\\frac{24}{25}'
      },
      {
        text: 'In Q4, sine is negative:',
        latex: '\\sin\\theta = -\\frac{24}{25}'
      }
    ],
    handbookPage: 'p. 38',
    handbookFormula: '\\sin^2\\theta + \\cos^2\\theta = 1',
    videoUrl: null,
    traps: [
      'Choosing the positive root and ignoring the quadrant',
      'Arithmetic error: 625 - 49 = 576, not 576/25'
    ],
    diagram: null,
    lessonId: 'unit-circle-trig-identities',
    chapterId: 'mathematics'
  },
  {
    id: 'math-ucti-ex3',
    type: 'computational',
    statement: 'If $\\cos\\theta = \\frac{3}{5}$ and $\\theta$ is in the first quadrant, what is the value of $\\cos 2\\theta$?',
    choices: [
      {
        id: 'c1',
        text: '$-\\frac{7}{25}$'
      },
      {
        id: 'c2',
        text: '$\\frac{6}{5}$'
      },
      {
        id: 'c3',
        text: '$\\frac{7}{25}$'
      },
      {
        id: 'c4',
        text: '$\\frac{9}{25}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Use the double-angle formula $\\cos 2\\theta = 2\\cos^2\\theta - 1$. Plug in: $2(9/25) - 1 = 18/25 - 25/25 = -7/25$. The choice $\\frac{6}{5}$ is wrong because it just doubles cos — that\'s not how double-angle works. The choice $\\frac{9}{25}$ uses $\\cos^2\\theta$ without the doubling and subtraction. The negative result is totally fine — it means $2\\theta$ lands in Q2 or Q3 where cosine is negative.',
    hint: 'The double-angle formula $\\cos 2\\theta = 2\\cos^2\\theta - 1$ only needs $\\cos\\theta$.',
    steps: [
      {
        text: 'Apply the double-angle formula:',
        latex: '\\cos 2\\theta = 2\\cos^2\\theta - 1'
      },
      {
        text: 'Substitute:',
        latex: '\\cos 2\\theta = 2\\left(\\frac{3}{5}\\right)^2 - 1 = 2 \\cdot \\frac{9}{25} - 1 = \\frac{18}{25} - \\frac{25}{25} = -\\frac{7}{25}'
      }
    ],
    handbookPage: 'p. 38',
    handbookFormula: '\\cos 2\\theta = 2\\cos^2\\theta - 1',
    videoUrl: null,
    traps: [
      'Just doubling the cosine value (2 times 3/5 = 6/5) instead of using the double-angle formula',
      'Using the wrong form of the double-angle identity'
    ],
    diagram: null,
    lessonId: 'unit-circle-trig-identities',
    chapterId: 'mathematics'
  },
  {
    id: 'math-ucti-ex4',
    type: 'conceptual',
    statement: 'In which quadrants is the tangent function positive?',
    choices: [
      {
        id: 'c1',
        text: 'Quadrants I and II'
      },
      {
        id: 'c2',
        text: 'Quadrants I and III'
      },
      {
        id: 'c3',
        text: 'Quadrants II and IV'
      },
      {
        id: 'c4',
        text: 'Quadrants I and IV'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'Tangent is sine divided by cosine. It\'s positive when both have the same sign. In Q1, both sin and cos are positive — positive/positive = positive. In Q3, both are negative — negative/negative = positive. In Q2 and Q4, they have opposite signs, so tangent is negative. The mnemonic \'All Students Take Calculus\' tells you which trig functions are positive in each quadrant: All (Q1), Sine (Q2), Tangent (Q3), Cosine (Q4).',
    hint: 'Tangent = sin/cos. In which quadrants do sine and cosine share the same sign?',
    steps: [
      {
        text: 'Recall $\\tan\\theta = \\frac{\\sin\\theta}{\\cos\\theta}$. It\'s positive when sin and cos have the same sign.',
        latex: null
      },
      {
        text: 'Q1: sin > 0, cos > 0 — tan > 0.',
        latex: null
      },
      {
        text: 'Q3: sin < 0, cos < 0 — tan > 0.',
        latex: null
      },
      {
        text: 'Q2 and Q4 have opposite signs for sin and cos, so tan < 0.',
        latex: null
      }
    ],
    handbookPage: 'p. 38',
    handbookFormula: '\\tan\\theta = \\frac{\\sin\\theta}{\\cos\\theta}',
    videoUrl: null,
    traps: [
      'Confusing tangent sign rules with sine or cosine sign rules',
      'Thinking tangent is positive wherever sine is positive'
    ],
    diagram: null,
    lessonId: 'unit-circle-trig-identities',
    chapterId: 'mathematics'
  },
  {
    id: 'math-cc-ex1',
    type: 'computational',
    statement: 'A circular water tank has an equation $(x + 2)^2 + (y - 7)^2 = 36$. What is the diameter of the tank?',
    choices: [
      {
        id: 'c1',
        text: '6'
      },
      {
        id: 'c2',
        text: '12'
      },
      {
        id: 'c3',
        text: '36'
      },
      {
        id: 'c4',
        text: '18'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'Read the standard form: the right side is $r^2$, so $r = \\sqrt{36} = 6$. The diameter is twice the radius, so 12. The choice 6 is the radius, not the diameter. The choice 36 is $r^2$. Always check whether the question asks for radius or diameter.',
    hint: 'The right side of the circle equation is $r^2$, not $r$. And diameter is twice the radius.',
    steps: [
      {
        text: 'Identify $r^2 = 36$ from the standard form:',
        latex: 'r = \\sqrt{36} = 6'
      },
      {
        text: 'Diameter is twice the radius:',
        latex: 'd = 2r = 2(6) = 12'
      }
    ],
    handbookPage: 'p. 24',
    handbookFormula: '(x-h)^2 + (y-k)^2 = r^2',
    videoUrl: null,
    traps: ['Giving the radius instead of the diameter', 'Giving $r^2$ as the answer'],
    diagram: null,
    lessonId: 'circles-conics',
    chapterId: 'mathematics'
  },
  {
    id: 'math-cc-ex2',
    type: 'computational',
    statement: 'Convert the equation $x^2 + y^2 + 8x - 6y = 0$ to standard form and find the center of the circle.',
    choices: [
      {
        id: 'c1',
        text: 'Center $(-4, 3)$'
      },
      {
        id: 'c2',
        text: 'Center $(4, -3)$'
      },
      {
        id: 'c3',
        text: 'Center $(-8, 6)$'
      },
      {
        id: 'c4',
        text: 'Center $(8, -6)$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Complete the square for both $x$ and $y$. For $x$: half of 8 is 4, squared is 16. For $y$: half of $-6$ is $-3$, squared is 9. Add both to each side. You get $(x+4)^2 + (y-3)^2 = 25$. The center is $(-4, 3)$ because $x + 4 = x - (-4)$. The choice with center $(4, -3)$ flips the signs — that is the most common error with completing the square.',
    hint: 'Complete the square for x and y separately. Remember the sign convention: $(x - h)$ means center coordinate $h$.',
    steps: [
      {
        text: 'Group and complete the square:',
        latex: '(x^2 + 8x + 16) + (y^2 - 6y + 9) = 0 + 16 + 9'
      },
      {
        text: 'Write in standard form:',
        latex: '(x + 4)^2 + (y - 3)^2 = 25'
      },
      {
        text: 'Read the center: $h = -4$, $k = 3$.',
        latex: null
      }
    ],
    handbookPage: 'p. 24',
    handbookFormula: '(x-h)^2 + (y-k)^2 = r^2',
    videoUrl: null,
    traps: [
      'Flipping the sign of h and k when reading from the standard form',
      'Forgetting to add the completing-the-square constants to both sides'
    ],
    diagram: null,
    lessonId: 'circles-conics',
    chapterId: 'mathematics'
  },
  {
    id: 'math-cc-ex3',
    type: 'computational',
    statement: 'An elliptical culvert has the equation $\\frac{x^2}{16} + \\frac{y^2}{9} = 1$. What is the length of the major axis?',
    choices: [
      {
        id: 'c1',
        text: '4'
      },
      {
        id: 'c2',
        text: '3'
      },
      {
        id: 'c3',
        text: '8'
      },
      {
        id: 'c4',
        text: '6'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'The larger denominator tells you which axis is major. Here $16 > 9$, so the major axis is along $x$. The semi-major axis is $a = \\sqrt{16} = 4$, but the FULL major axis is $2a = 8$. The choice "4" is the semi-major axis — the question asks for the full length. The choice "6" is the minor axis length ($2 \\times 3 = 6$).',
    hint: 'The semi-axis is the square root of the denominator. The full axis length is twice that.',
    steps: [
      {
        text: 'Identify the larger denominator: $a^2 = 16 > b^2 = 9$.',
        latex: null
      },
      {
        text: 'Find the semi-major axis:',
        latex: 'a = \\sqrt{16} = 4'
      },
      {
        text: 'Major axis length is $2a$:',
        latex: '2a = 2(4) = 8'
      }
    ],
    handbookPage: 'p. 24',
    handbookFormula: '\\frac{(x-h)^2}{a^2} + \\frac{(y-k)^2}{b^2} = 1',
    videoUrl: null,
    traps: ['Giving the semi-axis instead of the full axis length', 'Confusing major and minor axes'],
    diagram: null,
    lessonId: 'circles-conics',
    chapterId: 'mathematics'
  },
  {
    id: 'math-cc-ex4',
    type: 'conceptual',
    statement: 'A conic section has the general equation $Ax^2 + Bxy + Cy^2 + Dx + Ey + F = 0$. If $A = C$ and $B = 0$, what type of conic is it?',
    choices: [
      {
        id: 'c1',
        text: 'Parabola'
      },
      {
        id: 'c2',
        text: 'Ellipse'
      },
      {
        id: 'c3',
        text: 'Circle'
      },
      {
        id: 'c4',
        text: 'Hyperbola'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'When $A = C$ and $B = 0$, the $x^2$ and $y^2$ terms have the same coefficient and there is no $xy$ term. That is the definition of a circle — both axes are scaled the same, so the curve has equal "width" in every direction. An ellipse would have $A \\neq C$. A parabola has only one squared term (either $A$ or $C$ is zero). A hyperbola has opposite signs for $A$ and $C$.',
    hint: 'Think about what makes a circle different from an ellipse — it is the relationship between the coefficients of $x^2$ and $y^2$.',
    steps: [
      {
        text: 'When $A = C$ and $B = 0$, the equation becomes $A(x^2 + y^2) + Dx + Ey + F = 0$.',
        latex: null
      },
      {
        text: 'Dividing through by $A$ gives $x^2 + y^2 + \\ldots = 0$, which is a circle.',
        latex: null
      },
      {
        text: 'Equal coefficients on $x^2$ and $y^2$ with no $xy$ term defines a circle.',
        latex: null
      }
    ],
    handbookPage: 'p. 24',
    handbookFormula: '(x-h)^2 + (y-k)^2 = r^2',
    videoUrl: null,
    traps: [
      'Confusing circle (A = C) with ellipse (A ≠ C)',
      'Forgetting that B must be zero for the standard circle form'
    ],
    diagram: null,
    lessonId: 'circles-conics',
    chapterId: 'mathematics'
  },
  {
    id: 'math-dr-ex1',
    type: 'computational',
    statement: 'Find the derivative of $f(x) = \\ln(5x^2 + 1)$.',
    choices: [
      {
        id: 'c1',
        text: '$\\frac{1}{5x^2 + 1}$'
      },
      {
        id: 'c2',
        text: '$\\frac{10x}{5x^2 + 1}$'
      },
      {
        id: 'c3',
        text: '$\\frac{5x}{5x^2 + 1}$'
      },
      {
        id: 'c4',
        text: '$\\frac{2x}{5x^2 + 1}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'The derivative of $\\ln(u)$ is $1/u$ times $du/dx$ — chain rule. The outer derivative gives $1/(5x^2 + 1)$, and the inner derivative is $10x$. Multiply them together. The choice $\\frac{1}{5x^2+1}$ is what you get if you skip the chain rule entirely. The choice $\\frac{5x}{5x^2+1}$ misses the factor of 2 from differentiating $x^2$.',
    hint: 'The argument is not plain $x$ — what does the chain rule add?',
    steps: [
      {
        text: 'Identify the chain rule: outer function is $\\ln(u)$, inner function is $u = 5x^2 + 1$.',
        latex: null
      },
      {
        text: 'Derivative of the outer:',
        latex: '\\frac{1}{5x^2 + 1}'
      },
      {
        text: 'Multiply by derivative of the inner:',
        latex: '\\frac{1}{5x^2 + 1} \\cdot 10x = \\frac{10x}{5x^2 + 1}'
      }
    ],
    handbookPage: 'p. 49',
    handbookFormula: '\\frac{d}{dx}(\\ln u) = \\frac{1}{u} \\cdot \\frac{du}{dx}',
    videoUrl: null,
    traps: [
      'Forgetting the chain rule and omitting the inner derivative',
      'Getting the inner derivative wrong — $d/dx(5x^2) = 10x$, not $5x$'
    ],
    diagram: null,
    lessonId: 'derivatives-rules',
    chapterId: 'mathematics'
  },
  {
    id: 'math-dr-ex2',
    type: 'computational',
    statement: 'Find the derivative of $g(t) = t^3 \\sin(2t)$.',
    choices: [
      {
        id: 'c1',
        text: '$3t^2 \\sin(2t) + 2t^3 \\cos(2t)$'
      },
      {
        id: 'c2',
        text: '$3t^2 \\cos(2t)$'
      },
      {
        id: 'c3',
        text: '$6t^2 \\cos(2t)$'
      },
      {
        id: 'c4',
        text: '$3t^2 \\sin(2t) + t^3 \\cos(2t)$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Two functions multiplied means product rule. And $\\sin(2t)$ needs the chain rule for its derivative — you get $\\cos(2t) \\cdot 2$, not just $\\cos(2t)$. The choice $3t^2 \\sin(2t) + t^3 \\cos(2t)$ is the classic trap: it applies the product rule correctly but forgets the chain rule factor of 2 on the trig part. The choice $3t^2 \\cos(2t)$ only differentiates one factor. Always check: did I use BOTH product rule terms, and did I chain rule the inner function?',
    hint: 'Product rule first, then chain rule on $\\sin(2t)$.',
    steps: [
      {
        text: 'Identify $u = t^3$ and $v = \\sin(2t)$.',
        latex: null
      },
      {
        text: 'Derivatives: $du/dt = 3t^2$ and $dv/dt = 2\\cos(2t)$ (chain rule).',
        latex: null
      },
      {
        text: 'Apply the product rule:',
        latex: 'g\'(t) = t^3 \\cdot 2\\cos(2t) + \\sin(2t) \\cdot 3t^2'
      },
      {
        text: 'Simplify:',
        latex: 'g\'(t) = 3t^2 \\sin(2t) + 2t^3 \\cos(2t)'
      }
    ],
    handbookPage: 'p. 49',
    handbookFormula: '\\frac{d}{dx}(uv) = u\\frac{dv}{dx} + v\\frac{du}{dx}',
    videoUrl: null,
    traps: [
      'Forgetting the chain rule factor of 2 when differentiating $\\sin(2t)$',
      'Only differentiating one of the two factors'
    ],
    diagram: null,
    lessonId: 'derivatives-rules',
    chapterId: 'mathematics'
  },
  {
    id: 'math-dr-ex3',
    type: 'computational',
    statement: 'Find the derivative of $h(x) = \\frac{e^x}{x + 3}$.',
    choices: [
      {
        id: 'c1',
        text: '$\\frac{e^x(x + 2)}{(x + 3)^2}$'
      },
      {
        id: 'c2',
        text: '$\\frac{e^x}{(x + 3)^2}$'
      },
      {
        id: 'c3',
        text: '$\\frac{e^x(x + 4)}{(x + 3)^2}$'
      },
      {
        id: 'c4',
        text: '$\\frac{e^x}{x + 3} - \\frac{e^x}{(x + 3)^2}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Quotient rule: lo d-hi minus hi d-lo over lo-lo. The denominator ($x + 3$) times the derivative of the numerator ($e^x$) minus the numerator ($e^x$) times the derivative of the denominator (1), all over $(x + 3)^2$. Factor out $e^x$: you get $e^x(x + 3 - 1)/(x + 3)^2 = e^x(x + 2)/(x + 3)^2$. The choice $\\frac{e^x}{x+3} - \\frac{e^x}{(x+3)^2}$ is mathematically equivalent but unsimplified; the correct option here is the simplified form $\\frac{e^x(x+2)}{(x+3)^2}$. On the FE, always check whether your answer matches a simplified form in the choices.',
    hint: 'Apply the quotient rule, then factor $e^x$ from the numerator.',
    steps: [
      {
        text: 'Identify $u = e^x$ and $v = x + 3$.',
        latex: null
      },
      {
        text: 'Apply the quotient rule:',
        latex: 'h\'(x) = \\frac{(x+3)e^x - e^x \\cdot 1}{(x+3)^2}'
      },
      {
        text: 'Factor $e^x$ from the numerator:',
        latex: 'h\'(x) = \\frac{e^x(x + 3 - 1)}{(x+3)^2} = \\frac{e^x(x+2)}{(x+3)^2}'
      }
    ],
    handbookPage: 'p. 49',
    handbookFormula: '\\frac{d}{dx}\\!\\left(\\frac{u}{v}\\right) = \\frac{v\\,\\frac{du}{dx} - u\\,\\frac{dv}{dx}}{v^2}',
    videoUrl: null,
    traps: [
      'Flipping the subtraction in the quotient rule — it is $v\\,du - u\\,dv$, not $u\\,dv - v\\,du$',
      'Forgetting to factor and not matching any answer choice'
    ],
    diagram: null,
    lessonId: 'derivatives-rules',
    chapterId: 'mathematics'
  },
  {
    id: 'math-dr-ex4',
    type: 'conceptual',
    statement: 'The derivative of $\\sin(3x^2)$ requires which rule(s)?',
    choices: [
      {
        id: 'c1',
        text: 'Power rule only'
      },
      {
        id: 'c2',
        text: 'Chain rule applied once'
      },
      {
        id: 'c3',
        text: 'Product rule and chain rule'
      },
      {
        id: 'c4',
        text: 'Chain rule applied twice (nested)'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'There are two layers of composition here. The outermost function is $\\sin(\\cdot)$, and the inner function is $3x^2$. To differentiate $\\sin(u)$ you get $\\cos(u) \\cdot du/dx$. But $u = 3x^2$, and differentiating that uses the power rule (which is itself a form of chain rule applied to the $x^2$). So the chain rule fires once (for $\\sin \\to \\cos$ on the inner $3x^2$), and the inner derivative $3x^2 \\to 6x$ is just the power rule, not a second nested chain rule. There\'s no product of two separate functions of $x$, so the product rule doesn\'t apply here.',
    hint: 'Count the layers of composition: how many functions are nested inside each other?',
    steps: [
      {
        text: 'Outer function: $\\sin(u)$ where $u = 3x^2$.',
        latex: null
      },
      {
        text: 'First chain rule application: $\\cos(3x^2) \\cdot \\frac{d}{dx}(3x^2)$.',
        latex: null
      },
      {
        text: '  3. Differentiate the inner function with the power rule (not a second chain rule, since $3x^2$ is not itself a composition):   [LaTeX: \\frac{d}{dx}(3x^2) = 6x]',
        latex: '\\frac{d}{dx}(3x^2) = 6x'
      },
      {
        text: 'Full result:',
        latex: '\\frac{d}{dx}[\\sin(3x^2)] = 6x\\cos(3x^2)'
      }
    ],
    handbookPage: 'p. 49',
    handbookFormula: '\\frac{d}{dx}[f(g(x))] = f\'(g(x)) \\cdot g\'(x)',
    videoUrl: null,
    traps: [
      'Thinking a single chain rule application is enough — the inner function $3x^2$ also needs differentiation',
      'Confusing this with a product rule situation — $\\sin(3x^2)$ is a composition, not a product'
    ],
    diagram: null,
    lessonId: 'derivatives-rules',
    chapterId: 'mathematics'
  },
  {
    id: 'math-ad-ex1',
    type: 'computational',
    statement: 'Find the $x$-value at which $f(x) = x^3 - 6x^2 + 9x + 2$ has a local maximum.',
    choices: [
      {
        id: 'c1',
        text: '$x = 1$'
      },
      {
        id: 'c2',
        text: '$x = 3$'
      },
      {
        id: 'c3',
        text: '$x = 0$'
      },
      {
        id: 'c4',
        text: '$x = 2$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Take the derivative: $f\'(x) = 3x^2 - 12x + 9 = 3(x-1)(x-3)$. Setting it to zero gives $x = 1$ and $x = 3$. Now use the second derivative test: $f\'\'(x) = 6x - 12$. At $x = 1$: $f\'\'(1) = -6 < 0$ — concave down, so it\'s a max. At $x = 3$: $f\'\'(3) = 6 > 0$ — concave up, so it\'s a min. The question asks for the max, so $x = 1$.',
    hint: 'Set $f\'(x) = 0$ to find critical points, then use $f\'\'(x)$ to classify each one.',
    steps: [
      {
        text: 'Find the first derivative:',
        latex: 'f\'(x) = 3x^2 - 12x + 9 = 3(x-1)(x-3)'
      },
      {
        text: 'Critical points: $x = 1$ and $x = 3$.',
        latex: null
      },
      {
        text: 'Second derivative test:',
        latex: 'f\'\'(x) = 6x - 12'
      },
      {
        text: 'At $x = 1$: $f\'\'(1) = 6 - 12 = -6 < 0$ — local maximum.',
        latex: null
      }
    ],
    handbookPage: 'p. 46',
    handbookFormula: 'f\'(a) = 0 \\text{ and } f\'\'(a) < 0 \\implies \\text{maximum}',
    videoUrl: null,
    traps: [
      'Reporting the local minimum (x = 3) instead of the local maximum (x = 1)',
      'Forgetting to factor and making an error solving the quadratic'
    ],
    diagram: null,
    lessonId: 'applications-derivatives',
    chapterId: 'mathematics'
  },
  {
    id: 'math-ad-ex2',
    type: 'computational',
    statement: 'A civil engineer models the total cost of a drainage pipe as $C(d) = 500d + \\frac{20000}{d}$, where $d$ is the diameter in meters. What diameter minimizes the cost?',
    choices: [
      {
        id: 'c1',
        text: '$d = 40\\,\\text{m}$'
      },
      {
        id: 'c2',
        text: '$d = \\sqrt{40}\\,\\text{m} \\approx 6.32\\,\\text{m}$'
      },
      {
        id: 'c3',
        text: '$d = 20\\,\\text{m}$'
      },
      {
        id: 'c4',
        text: '$d = 4\\,\\text{m}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Rewrite $20000/d$ as $20000d^{-1}$, then differentiate: $C\'(d) = 500 - 20000d^{-2}$. Set to zero: $500 = 20000/d^2$, so $d^2 = 40$ and $d = \\sqrt{40} \\approx 6.32$. The second derivative is $40000/d^3$, which is positive for any positive $d$, confirming a minimum. The distractor $d = 40\\,\\text{m}$ comes from dividing 20000 by 500 without taking the square root.',
    hint: 'Rewrite $20000/d$ as $20000d^{-1}$ before differentiating, then set $C\'(d) = 0$.',
    steps: [
      {
        text: 'Differentiate:',
        latex: 'C\'(d) = 500 - \\frac{20000}{d^2}'
      },
      {
        text: 'Set to zero:',
        latex: '500 = \\frac{20000}{d^2} \\implies d^2 = \\frac{20000}{500} = 40'
      },
      {
        text: 'Solve:',
        latex: 'd = \\sqrt{40} \\approx 6.32\\,\\text{m}'
      },
      {
        text: 'Confirm minimum:',
        latex: 'C\'\'(d) = \\frac{40000}{d^3} > 0 \\text{ for } d > 0 \\implies \\text{minimum}'
      }
    ],
    handbookPage: 'p. 46',
    handbookFormula: 'f\'(a) = 0 \\text{ and } f\'\'(a) > 0 \\implies \\text{minimum}',
    videoUrl: null,
    traps: [
      'Forgetting to apply the power rule to $20{,}000/d$ — it is $-20{,}000/d^2$, not $-20{,}000$',
      'Dividing 20,000 by 500 to get 40 but forgetting to take the square root'
    ],
    diagram: null,
    lessonId: 'applications-derivatives',
    chapterId: 'mathematics'
  },
  {
    id: 'math-ad-ex3',
    type: 'computational',
    statement: 'Find the inflection point of $f(x) = 2x^3 - 9x^2 + 12x - 4$.',
    choices: [
      {
        id: 'c1',
        text: '$x = 1$'
      },
      {
        id: 'c2',
        text: '$x = 2$'
      },
      {
        id: 'c3',
        text: '$x = 1.5$'
      },
      {
        id: 'c4',
        text: '$x = 3$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'An inflection point is where the second derivative equals zero and changes sign. First derivative: $6x^2 - 18x + 12$. Second derivative: $12x - 18$. Set to zero: $x = 18/12 = 1.5$. Check sign change: $f\'\'(1) = -6 < 0$ and $f\'\'(2) = 6 > 0$ — yes, it changes sign. The choices $x = 1$ and $x = 2$ are the critical points where $f\'(x) = 0$ — the classic mistake of using the first derivative instead of the second.',
    hint: 'Set the second derivative (not the first) to zero.',
    steps: [
      {
        text: 'First derivative:',
        latex: 'f\'(x) = 6x^2 - 18x + 12'
      },
      {
        text: 'Second derivative:',
        latex: 'f\'\'(x) = 12x - 18'
      },
      {
        text: 'Set to zero:',
        latex: '12x - 18 = 0 \\implies x = 1.5'
      },
      {
        text: 'Verify sign change: $f\'\'(1) = -6$ and $f\'\'(2) = 6$ — sign changes, confirming inflection point.',
        latex: null
      }
    ],
    handbookPage: 'p. 46',
    handbookFormula: 'f\'\'(a) = 0 \\text{ and } f\'\'(x) \\text{ changes sign} \\implies \\text{inflection point}',
    videoUrl: null,
    traps: [
      'Using $f\'(x) = 0$ instead of $f\'\'(x) = 0$ — that gives critical points, not inflection points',
      'Arithmetic error in solving $12x = 18$'
    ],
    diagram: null,
    lessonId: 'applications-derivatives',
    chapterId: 'mathematics'
  },
  {
    id: 'math-ad-ex4',
    type: 'conceptual',
    statement: 'At a critical point where $f\'(a) = 0$, the second derivative test is inconclusive when:',
    choices: [
      {
        id: 'c1',
        text: '$f\'\'(a) > 0$'
      },
      {
        id: 'c2',
        text: '$f\'\'(a) < 0$'
      },
      {
        id: 'c3',
        text: '$f\'\'(a) = 0$'
      },
      {
        id: 'c4',
        text: '$f\'\'(a) \\neq 0$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'The second derivative test classifies critical points as max ($f\'\' < 0$), min ($f\'\' > 0$), or inconclusive ($f\'\' = 0$). When the second derivative is zero, the test fails — you can\'t tell if it\'s a max, min, or neither. Consider $f(x) = x^4$: $f\'(0) = 0$ and $f\'\'(0) = 0$, but it\'s a minimum. Meanwhile $f(x) = x^3$: $f\'(0) = 0$ and $f\'\'(0) = 0$, but it\'s neither a max nor a min. Same second derivative value, different conclusions — that\'s why it\'s called inconclusive.',
    hint: 'The second derivative test gives three outcomes depending on the sign of $f\'\'(a)$. What if the sign is neither positive nor negative?',
    steps: [
      {
        text: 'The second derivative test says:',
        latex: null
      },
      {
        text: '$f\'\'(a) > 0$ means local minimum (concave up).',
        latex: null
      },
      {
        text: '$f\'\'(a) < 0$ means local maximum (concave down).',
        latex: null
      },
      {
        text: '$f\'\'(a) = 0$ means the test is inconclusive — you need another method (first derivative test or higher-order derivatives).',
        latex: null
      }
    ],
    handbookPage: 'p. 46',
    handbookFormula: 'f\'\'(a) = 0 \\implies \\text{test is inconclusive}',
    videoUrl: null,
    traps: [
      'Thinking $f\'\'(a) = 0$ always means inflection point — it could be a flat max/min like $x^4$',
      'Confusing \'inconclusive\' with \'does not exist\''
    ],
    diagram: null,
    lessonId: 'applications-derivatives',
    chapterId: 'mathematics'
  },
  {
    id: 'math-ic-ex1',
    type: 'computational',
    statement: 'Evaluate $\\int_1^4 (2x + 3)\\,dx$.',
    choices: [
      {
        id: 'c1',
        text: '$24$'
      },
      {
        id: 'c2',
        text: '$27$'
      },
      {
        id: 'c3',
        text: '$21$'
      },
      {
        id: 'c4',
        text: '$30$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Integrate term by term: the antiderivative of $2x$ is $x^2$ and the antiderivative of $3$ is $3x$. Evaluate from 1 to 4: $(16 + 12) - (1 + 3) = 28 - 4 = 24$. The trap is forgetting to evaluate at the lower limit — if you only plug in $x = 4$ you get 28, which isn\'t even a choice, but arithmetic mistakes can land you elsewhere.',
    hint: 'Find the antiderivative, then evaluate at the upper and lower limits and subtract.',
    steps: [
      {
        text: 'Find the antiderivative:',
        latex: '\\int (2x + 3)\\,dx = x^2 + 3x'
      },
      {
        text: 'Evaluate at upper limit:',
        latex: 'F(4) = 16 + 12 = 28'
      },
      {
        text: 'Evaluate at lower limit:',
        latex: 'F(1) = 1 + 3 = 4'
      },
      {
        text: 'Subtract:',
        latex: '28 - 4 = 24'
      }
    ],
    handbookPage: 'p. 50',
    handbookFormula: '\\int_a^b f(x)\\,dx = F(b) - F(a)',
    videoUrl: null,
    traps: [
      'Forgetting to evaluate at the lower limit',
      'Antiderivative error — the antiderivative of $2x$ is $x^2$, not $2x^2$'
    ],
    diagram: null,
    lessonId: 'integral-calculus',
    chapterId: 'mathematics'
  },
  {
    id: 'math-ic-ex2',
    type: 'computational',
    statement: 'Evaluate $\\int_0^2 4xe^{x^2}\\,dx$.',
    choices: [
      {
        id: 'c1',
        text: '$2e^4$'
      },
      {
        id: 'c2',
        text: '$4(e^4 - 1)$'
      },
      {
        id: 'c3',
        text: '$e^4 - 1$'
      },
      {
        id: 'c4',
        text: '$2(e^4 - 1)$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'The $x$ out front and the $x^2$ in the exponent are screaming for u-substitution. Let $u = x^2$, so $du = 2x\\,dx$. The $4x\\,dx$ becomes $2\\,du$. The integral simplifies to $2\\int e^u\\,du = 2e^u$. Change limits: when $x = 0$, $u = 0$; when $x = 2$, $u = 4$. So you get $2(e^4 - e^0) = 2(e^4 - 1)$.',
    hint: 'The $x$ in $4x\\,dx$ and the $x^2$ in the exponent suggest $u = x^2$.',
    steps: [
      {
        text: 'Let $u = x^2$, then $du = 2x\\,dx$, so $4x\\,dx = 2\\,du$.',
        latex: null
      },
      {
        text: 'Change limits: $x = 0 \\to u = 0$; $x = 2 \\to u = 4$.',
        latex: null
      },
      {
        text: 'Rewrite the integral:',
        latex: '2\\int_0^4 e^u\\,du = 2\\left[e^u\\right]_0^4'
      },
      {
        text: 'Evaluate:',
        latex: '2(e^4 - e^0) = 2(e^4 - 1)'
      }
    ],
    handbookPage: 'p. 50',
    handbookFormula: '\\int e^u\\,du = e^u + C',
    videoUrl: null,
    traps: [
      'Forgetting to account for the factor of 2 when converting $4x\\,dx$ to $du$',
      'Not changing the limits of integration when substituting'
    ],
    diagram: null,
    lessonId: 'integral-calculus',
    chapterId: 'mathematics'
  },
  {
    id: 'math-ic-ex3',
    type: 'computational',
    statement: 'Evaluate $\\int_0^1 x\\,\\ln x\\,dx$. (Note: $\\lim_{x \\to 0^+} x\\ln x = 0$.)',
    choices: [
      {
        id: 'c1',
        text: '$-\\frac{1}{2}$'
      },
      {
        id: 'c2',
        text: '$\\frac{1}{4}$'
      },
      {
        id: 'c3',
        text: '$-\\frac{1}{4}$'
      },
      {
        id: 'c4',
        text: '$0$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'This is an integration by parts problem. LIATE says $\\ln x$ (Log) comes before $x$ (Algebraic), so let $u = \\ln x$ and $dv = x\\,dx$. Then $du = dx/x$ and $v = x^2/2$. The formula gives $(x^2/2)\\ln x - \\int x/2\\,dx = (x^2/2)\\ln x - x^2/4$. Evaluate from 0 to 1: at $x = 1$, $\\ln 1 = 0$ so the first term vanishes, leaving $-1/4$. At $x = 0$ both terms go to 0 (given in the hint). So the answer is $-1/4$.',
    hint: 'LIATE: $\\ln x$ is a log (L), which comes first — let $u = \\ln x$.',
    steps: [
      {
        text: 'Integration by parts: let $u = \\ln x$, $dv = x\\,dx$.',
        latex: null
      },
      {
        text: 'Then $du = \\frac{dx}{x}$ and $v = \\frac{x^2}{2}$.',
        latex: null
      },
      {
        text: 'Apply the formula:',
        latex: '\\left[\\frac{x^2}{2}\\ln x\\right]_0^1 - \\int_0^1 \\frac{x^2}{2} \\cdot \\frac{1}{x}\\,dx = \\left[\\frac{x^2}{2}\\ln x\\right]_0^1 - \\int_0^1 \\frac{x}{2}\\,dx'
      },
      {
        text: 'First term at $x = 1$: $\\frac{1}{2}\\ln 1 = 0$. At $x = 0$: $0$ (given).',
        latex: null
      },
      {
        text: 'Second term:',
        latex: '\\int_0^1 \\frac{x}{2}\\,dx = \\frac{1}{2} \\cdot \\frac{x^2}{2}\\Big|_0^1 = \\frac{1}{4}'
      },
      {
        text: 'Combine:',
        latex: '0 - \\frac{1}{4} = -\\frac{1}{4}'
      }
    ],
    handbookPage: 'p. 50',
    handbookFormula: '\\int u\\,dv = uv - \\int v\\,du',
    videoUrl: null,
    traps: [
      'Choosing $u$ and $dv$ backwards — if you let $u = x$, you would need to integrate $\\ln x$, which is harder',
      'Forgetting the negative sign from the by-parts formula'
    ],
    diagram: null,
    lessonId: 'integral-calculus',
    chapterId: 'mathematics'
  },
  {
    id: 'math-ic-ex4',
    type: 'conceptual',
    statement: 'When evaluating a definite integral, why is the constant of integration $+C$ not needed?',
    choices: [
      {
        id: 'c1',
        text: 'The constant is always zero for definite integrals'
      },
      {
        id: 'c2',
        text: 'The constant cancels when you subtract $F(a)$ from $F(b)$'
      },
      {
        id: 'c3',
        text: 'Definite integrals do not involve antiderivatives'
      },
      {
        id: 'c4',
        text: 'The constant is absorbed into the limits of integration'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'When you compute $F(b) - F(a)$, any constant $C$ appears in both terms: $(F(b) + C) - (F(a) + C) = F(b) - F(a)$. The $C$\'s cancel out perfectly. It\'s not that $C = 0$ or that it doesn\'t exist — it\'s that it subtracts away. This is a subtle but important distinction. The choice claiming definite integrals do not involve antiderivatives is flat wrong — definite integrals absolutely use antiderivatives (that\'s the Fundamental Theorem of Calculus). The choice claiming the constant is always zero is a common misconception.',
    hint: 'Write out $F(b) + C$ and $F(a) + C$ and subtract them — what happens to $C$?',
    steps: [
      {
        text: 'The antiderivative is $F(x) + C$.',
        latex: null
      },
      {
        text: 'Evaluate the definite integral:',
        latex: '(F(b) + C) - (F(a) + C) = F(b) - F(a)'
      },
      {
        text: 'The $+C$ terms cancel, so the constant does not affect the result.',
        latex: null
      }
    ],
    handbookPage: 'p. 50',
    handbookFormula: '\\int_a^b f(x)\\,dx = F(b) - F(a)',
    videoUrl: null,
    traps: [
      'Thinking $C = 0$ rather than understanding it cancels',
      'Believing definite integrals don\'t use antiderivatives'
    ],
    diagram: null,
    lessonId: 'integral-calculus',
    chapterId: 'mathematics'
  },
  {
    id: 'math-lr-ex1',
    type: 'computational',
    statement: 'Evaluate $\\lim_{x \\to 0}\\frac{1 - \\cos x}{x^2}$.',
    choices: [
      {
        id: 'c1',
        text: '$0$'
      },
      {
        id: 'c2',
        text: '$\\frac{1}{2}$'
      },
      {
        id: 'c3',
        text: '$1$'
      },
      {
        id: 'c4',
        text: 'Does not exist'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'Plug in $x = 0$: $(1 - 1)/0 = 0/0$ — indeterminate, so L\'Hopital\'s applies. Differentiate top and bottom: $\\sin x / 2x$. Plug in again: $0/0$ — still indeterminate! Apply a second time: $\\cos x / 2$. Now plug in: $\\cos 0 / 2 = 1/2$. Two rounds is typical for the FE. If you stopped after one round, you\'d get stuck — don\'t quit early.',
    hint: 'Direct substitution gives 0/0. You may need to apply the rule more than once.',
    steps: [
      {
        text: 'Direct substitution:',
        latex: '\\frac{1 - \\cos 0}{0^2} = \\frac{0}{0} \\text{ — indeterminate}'
      },
      {
        text: 'First round:',
        latex: '\\lim_{x \\to 0}\\frac{\\sin x}{2x}'
      },
      {
        text: 'Still 0/0. Second round:',
        latex: '\\lim_{x \\to 0}\\frac{\\cos x}{2}'
      },
      {
        text: 'Evaluate:',
        latex: '\\frac{\\cos 0}{2} = \\frac{1}{2}'
      }
    ],
    handbookPage: 'p. 48',
    handbookFormula: '\\lim_{x \\to a}\\frac{f(x)}{g(x)} = \\lim_{x \\to a}\\frac{f\'(x)}{g\'(x)}',
    videoUrl: null,
    traps: [
      'Stopping after one round when the result is still 0/0',
      'Differentiating incorrectly: $d/dx(1 - \\cos x) = \\sin x$, not $-\\sin x$'
    ],
    diagram: null,
    lessonId: 'lhopitals-rule',
    chapterId: 'mathematics'
  },
  {
    id: 'math-lr-ex2',
    type: 'computational',
    statement: 'Evaluate $\\lim_{x \\to \\infty}\\frac{3x^2 + 5}{e^x}$.',
    choices: [
      {
        id: 'c1',
        text: '$\\infty$'
      },
      {
        id: 'c2',
        text: '$3$'
      },
      {
        id: 'c3',
        text: '$0$'
      },
      {
        id: 'c4',
        text: '$5$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'As $x \\to \\infty$, both the top and bottom blow up: $\\infty / \\infty$. That\'s an indeterminate form, so L\'Hopital\'s applies. First round: $6x / e^x$ — still $\\infty/\\infty$. Second round: $6 / e^x$. Now the top is a constant and the bottom goes to infinity, so the limit is 0. The exponential always wins against any polynomial. This is a key fact for the FE.',
    hint: 'This is $\\infty/\\infty$ form. Apply L\'Hopital\'s until the numerator stops growing.',
    steps: [
      {
        text: 'Form check: $\\infty/\\infty$ — L\'Hopital\'s applies.',
        latex: null
      },
      {
        text: 'First round:',
        latex: '\\lim_{x \\to \\infty}\\frac{6x}{e^x} \\quad\\text{still } \\frac{\\infty}{\\infty}'
      },
      {
        text: 'Second round:',
        latex: '\\lim_{x \\to \\infty}\\frac{6}{e^x}'
      },
      {
        text: 'Evaluate: $6/\\infty = 0$.',
        latex: null
      }
    ],
    handbookPage: 'p. 48',
    handbookFormula: '\\lim_{x \\to a}\\frac{f(x)}{g(x)} = \\lim_{x \\to a}\\frac{f\'(x)}{g\'(x)}',
    videoUrl: null,
    traps: [
      'Assuming infinity/infinity always diverges — it can converge to zero',
      'Differentiating $e^x$ incorrectly (it is its own derivative)'
    ],
    diagram: null,
    lessonId: 'lhopitals-rule',
    chapterId: 'mathematics'
  },
  {
    id: 'math-lr-ex3',
    type: 'computational',
    statement: 'Evaluate $\\lim_{x \\to 0}\\frac{\\tan x - x}{x^3}$.',
    choices: [
      {
        id: 'c1',
        text: '$\\frac{1}{3}$'
      },
      {
        id: 'c2',
        text: '$0$'
      },
      {
        id: 'c3',
        text: '$1$'
      },
      {
        id: 'c4',
        text: '$\\frac{1}{2}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Plug in 0: $(0 - 0)/0 = 0/0$. First round: $(\\sec^2 x - 1)/3x^2$. At $x = 0$: $0/0$ again. Second round: use $\\sec^2 x - 1 = \\tan^2 x$ or just differentiate directly. The derivative of $\\sec^2 x - 1$ is $2\\sec^2 x \\tan x$, and the derivative of $3x^2$ is $6x$. Still $0/0$. Third round: differentiate again. Eventually you get $1/3$. This is a classic three-round L\'Hopital\'s problem.',
    hint: 'You\'ll need to apply L\'Hopital\'s Rule multiple times. Keep differentiating until the form resolves.',
    steps: [
      {
        text: 'Direct substitution: $0/0$. First round:',
        latex: '\\lim_{x \\to 0}\\frac{\\sec^2 x - 1}{3x^2}'
      },
      {
        text: 'Still $0/0$. Second round:',
        latex: '\\lim_{x \\to 0}\\frac{2\\sec^2 x \\tan x}{6x}'
      },
      {
        text: 'Still $0/0$. Third round:',
        latex: '\\lim_{x \\to 0}\\frac{2\\sec^4 x + 4\\sec^2 x \\tan^2 x}{6}'
      },
      {
        text: 'At $x = 0$: $\\sec 0 = 1$, $\\tan 0 = 0$:',
        latex: '\\frac{2(1) + 4(1)(0)}{6} = \\frac{2}{6} = \\frac{1}{3}'
      }
    ],
    handbookPage: 'p. 48',
    handbookFormula: '\\lim_{x \\to a}\\frac{f(x)}{g(x)} = \\lim_{x \\to a}\\frac{f\'(x)}{g\'(x)}',
    videoUrl: null,
    traps: [
      'Stopping too early — this problem requires three rounds',
      'Differentiating $\\sec^2(x)$ incorrectly — its derivative is $2\\sec^2(x)\\tan(x)$'
    ],
    diagram: null,
    lessonId: 'lhopitals-rule',
    chapterId: 'mathematics'
  },
  {
    id: 'math-lr-ex4',
    type: 'conceptual',
    statement: 'Which of the following is NOT an indeterminate form where L\'Hopital\'s Rule applies?',
    choices: [
      {
        id: 'c1',
        text: '$\\frac{1}{0}$'
      },
      {
        id: 'c2',
        text: '$\\frac{\\infty}{\\infty}$'
      },
      {
        id: 'c3',
        text: '$\\frac{0}{0}$'
      },
      {
        id: 'c4',
        text: 'All of the above are indeterminate forms'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'L\'Hopital\'s Rule only applies to two forms: $0/0$ and $\\infty/\\infty$. The form $1/0$ is NOT indeterminate — it means the function blows up to $\\pm\\infty$ or the limit doesn\'t exist. The rule explicitly requires an indeterminate form before you can differentiate. Applying L\'Hopital\'s when the form isn\'t indeterminate gives a wrong answer. This is the trap in problems like $\\lim_{x \\to 0} e^x/x$ — students apply the rule without checking and get 1, but the correct answer is DNE.',
    hint: 'L\'Hopital\'s Rule has exactly two qualifying forms. Any fraction with a nonzero numerator and zero denominator is not one of them.',
    steps: [
      {
        text: '$0/0$ is indeterminate — L\'Hopital\'s applies.',
        latex: null
      },
      {
        text: '$\\infty/\\infty$ is indeterminate — L\'Hopital\'s applies.',
        latex: null
      },
      {
        text: '$1/0$ is NOT indeterminate — it represents a function that blows up. The limit is $\\pm\\infty$ or DNE.',
        latex: null
      },
      {
        text: 'L\'Hopital\'s must NOT be applied to non-indeterminate forms.',
        latex: null
      }
    ],
    handbookPage: 'p. 48',
    handbookFormula: '\\lim_{x \\to a}\\frac{f(x)}{g(x)} = \\lim_{x \\to a}\\frac{f\'(x)}{g\'(x)} \\text{ (only for } \\frac{0}{0} \\text{ or } \\frac{\\infty}{\\infty}\\text{)}',
    videoUrl: null,
    traps: [
      'Thinking any fraction with zero in the denominator qualifies as indeterminate',
      'Applying L\'Hopital\'s to 1/0 and getting a wrong finite answer'
    ],
    diagram: null,
    lessonId: 'lhopitals-rule',
    chapterId: 'mathematics'
  },
  {
    id: 'math-vbu-ex1',
    type: 'computational',
    statement: 'A cable exerts a force along the direction $\\vec{d} = 6\\hat{i} + 2\\hat{j} - 3\\hat{k}$ meters. What is the magnitude of this direction vector?',
    choices: [
      {
        id: 'c1',
        text: '$5$'
      },
      {
        id: 'c2',
        text: '$7$'
      },
      {
        id: 'c3',
        text: '$11$'
      },
      {
        id: 'c4',
        text: '$\\sqrt{41} \\approx 6.4$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'Square each component, add them up, take the square root: $\\sqrt{36 + 4 + 9} = \\sqrt{49} = 7$. Don\'t forget to include the negative component — squaring it makes it positive anyway ($(-3)^2 = 9$). The trap is adding the raw components ($6 + 2 - 3 = 5$) instead of using the magnitude formula.',
    hint: 'The magnitude formula uses the square root of the sum of squares — not just the sum of components.',
    steps: [
      {
        text: 'Apply the magnitude formula:',
        latex: '|\\vec{d}| = \\sqrt{6^2 + 2^2 + (-3)^2}'
      },
      {
        text: 'Compute:',
        latex: '= \\sqrt{36 + 4 + 9} = \\sqrt{49} = 7'
      }
    ],
    handbookPage: 'p. 55',
    handbookFormula: '|\\vec{A}| = \\sqrt{A_x^2 + A_y^2 + A_z^2}',
    videoUrl: null,
    traps: [
      'Adding components directly (6 + 2 - 3 = 5) instead of using sum of squares',
      'Forgetting to square the negative component'
    ],
    diagram: null,
    lessonId: 'vector-basics-unit-vectors',
    chapterId: 'mathematics'
  },
  {
    id: 'math-vbu-ex2',
    type: 'computational',
    statement: 'Find the unit vector in the direction of $\\vec{v} = 2\\hat{i} - 6\\hat{j} + 3\\hat{k}$.',
    choices: [
      {
        id: 'c1',
        text: '$\\frac{2}{7}\\hat{i} - \\frac{6}{7}\\hat{j} + \\frac{3}{7}\\hat{k}$'
      },
      {
        id: 'c2',
        text: '$2\\hat{i} - 6\\hat{j} + 3\\hat{k}$'
      },
      {
        id: 'c3',
        text: '$\\frac{2}{11}\\hat{i} - \\frac{6}{11}\\hat{j} + \\frac{3}{11}\\hat{k}$'
      },
      {
        id: 'c4',
        text: '$\\frac{1}{3}\\hat{i} - 1\\hat{j} + \\frac{1}{2}\\hat{k}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'First find the magnitude: $\\sqrt{4 + 36 + 9} = \\sqrt{49} = 7$. Then divide each component by 7. The choice that just repeats 2i - 6j + 3k is the original vector — that\'s what you get if you skip the normalization. The choice dividing by 11 divides by the sum of components instead of the magnitude (7). Always verify: the unit vector\'s magnitude should equal 1.',
    hint: 'Compute the magnitude first, then divide every component by it.',
    steps: [
      {
        text: 'Magnitude:',
        latex: '|\\vec{v}| = \\sqrt{4 + 36 + 9} = \\sqrt{49} = 7'
      },
      {
        text: 'Unit vector:',
        latex: '\\hat{u} = \\frac{\\vec{v}}{|\\vec{v}|} = \\frac{2}{7}\\hat{i} - \\frac{6}{7}\\hat{j} + \\frac{3}{7}\\hat{k}'
      }
    ],
    handbookPage: 'p. 55',
    handbookFormula: '\\hat{u}_A = \\frac{\\vec{A}}{|\\vec{A}|}',
    videoUrl: null,
    traps: [
      'Dividing by the sum of absolute values of components instead of the magnitude',
      'Forgetting to normalize — reporting the raw vector as the unit vector'
    ],
    diagram: null,
    lessonId: 'vector-basics-unit-vectors',
    chapterId: 'mathematics'
  },
  {
    id: 'math-vbu-ex3',
    type: 'computational',
    statement: 'A 350 N force acts along the direction from point $A(1, -1, 2)$ to point $B(3, 3, -1)$. Express the force as a vector $\\vec{F}$.',
    choices: [
      {
        id: 'c1',
        text: '$\\frac{2}{\\sqrt{29}}\\hat{i} + \\frac{4}{\\sqrt{29}}\\hat{j} - \\frac{3}{\\sqrt{29}}\\hat{k}$ N'
      },
      {
        id: 'c2',
        text: '$700\\hat{i} + 1400\\hat{j} - 1050\\hat{k}$ N'
      },
      {
        id: 'c3',
        text: '$\\frac{350}{3}(2\\hat{i} + 4\\hat{j} - 3\\hat{k})$ N'
      },
      {
        id: 'c4',
        text: '$\\frac{700}{\\sqrt{29}}\\hat{i} + \\frac{1400}{\\sqrt{29}}\\hat{j} - \\frac{1050}{\\sqrt{29}}\\hat{k}$ N'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'Three steps: (1) direction vector $B - A = (2, 4, -3)$, (2) magnitude $= \\sqrt{4 + 16 + 9} = \\sqrt{29}$, (3) unit vector times 350. Each component of the unit vector gets multiplied by 350. The unit-vector-only choice ($\\frac{2}{\\sqrt{29}}\\hat{i} + \\frac{4}{\\sqrt{29}}\\hat{j} - \\frac{3}{\\sqrt{29}}\\hat{k}$) leaves off the 350 multiplier. The $700\\hat{i} + 1400\\hat{j} - 1050\\hat{k}$ choice multiplied 350 by the direction vector without normalizing first.',
    hint: 'Find the unit vector from A to B, then multiply by the force magnitude.',
    steps: [
      {
        text: 'Direction vector:',
        latex: '\\vec{AB} = (3-1)\\hat{i} + (3-(-1))\\hat{j} + (-1-2)\\hat{k} = 2\\hat{i} + 4\\hat{j} - 3\\hat{k}'
      },
      {
        text: 'Magnitude:',
        latex: '|\\vec{AB}| = \\sqrt{4 + 16 + 9} = \\sqrt{29}'
      },
      {
        text: 'Unit vector:',
        latex: '\\hat{u} = \\frac{1}{\\sqrt{29}}(2\\hat{i} + 4\\hat{j} - 3\\hat{k})'
      },
      {
        text: 'Force vector:',
        latex: '\\vec{F} = 350\\hat{u} = \\frac{700}{\\sqrt{29}}\\hat{i} + \\frac{1400}{\\sqrt{29}}\\hat{j} - \\frac{1050}{\\sqrt{29}}\\hat{k}'
      }
    ],
    handbookPage: 'p. 55',
    handbookFormula: '\\vec{F} = F\\,\\hat{u}',
    videoUrl: null,
    traps: [
      'Multiplying the force magnitude by the raw direction vector instead of the unit vector',
      'Subtracting A from B in the wrong order'
    ],
    diagram: null,
    lessonId: 'vector-basics-unit-vectors',
    chapterId: 'mathematics'
  },
  {
    id: 'math-vbu-ex4',
    type: 'conceptual',
    statement: 'A vector $\\vec{A}$ has components $A_x = -5$ and $A_y = 0$. Which statement is true?',
    choices: [
      {
        id: 'c1',
        text: 'The vector has magnitude $-5$'
      },
      {
        id: 'c2',
        text: 'The vector is a zero vector'
      },
      {
        id: 'c3',
        text: 'The vector points in the negative $x$-direction with magnitude 5'
      },
      {
        id: 'c4',
        text: 'The vector points in the positive $x$-direction with magnitude 5'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'Magnitude is always positive: $|\\vec{A}| = \\sqrt{(-5)^2 + 0^2} = 5$, not $-5$. The negative sign on the component tells you direction, not magnitude. The "magnitude is -5" choice is the most common mistake — magnitudes can never be negative. The "positive x-direction with magnitude 5" choice gets the magnitude right but the direction wrong. A negative $x$-component means the vector points in the negative $x$-direction. Separating magnitude from direction is fundamental to vector analysis.',
    hint: 'Magnitude is always non-negative — the sign of a component indicates direction, not size.',
    steps: [
      {
        text: 'Magnitude:',
        latex: '|\\vec{A}| = \\sqrt{(-5)^2 + 0^2} = \\sqrt{25} = 5'
      },
      {
        text: 'Since $A_x < 0$ and $A_y = 0$, the vector points along the negative $x$-axis.',
        latex: null
      },
      {
        text: 'Magnitude is 5 (positive), direction is $-\\hat{i}$.',
        latex: null
      }
    ],
    handbookPage: 'p. 55',
    handbookFormula: '|\\vec{A}| = \\sqrt{A_x^2 + A_y^2}',
    videoUrl: null,
    traps: [
      'Reporting a negative magnitude — magnitudes are always non-negative',
      'Confusing the sign of a component with the sign of the magnitude'
    ],
    diagram: null,
    lessonId: 'vector-basics-unit-vectors',
    chapterId: 'mathematics'
  },
  {
    id: 'math-dpa-ex1',
    type: 'computational',
    statement: 'Compute $\\vec{P} \\cdot \\vec{Q}$ where $\\vec{P} = 5\\hat{i} - 3\\hat{j} + 2\\hat{k}$ and $\\vec{Q} = -1\\hat{i} + 4\\hat{j} + 6\\hat{k}$.',
    choices: [
      {
        id: 'c1',
        text: '$-5$'
      },
      {
        id: 'c2',
        text: '$-29$'
      },
      {
        id: 'c3',
        text: '$5$'
      },
      {
        id: 'c4',
        text: '$29$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Multiply matching components and add: $(5)(-1) + (-3)(4) + (2)(6) = -5 - 12 + 12 = -5$. Watch the signs carefully — the negative components produce negative products. The $-12$ and $+12$ cancel, leaving just $-5$ from the first pair. A negative dot product means the vectors point in generally opposite directions (the angle between them is obtuse).',
    hint: 'Multiply x with x, y with y, z with z, then add all three products.',
    steps: [
      {
        text: 'Apply the component formula:',
        latex: '\\vec{P} \\cdot \\vec{Q} = (5)(-1) + (-3)(4) + (2)(6)'
      },
      {
        text: 'Compute each term:',
        latex: '= -5 - 12 + 12 = -5'
      }
    ],
    handbookPage: 'p. 55',
    handbookFormula: '\\vec{A} \\cdot \\vec{B} = A_xB_x + A_yB_y + A_zB_z',
    videoUrl: null,
    traps: [
      'Dropping the negative signs during multiplication',
      'Cross-multiplying components (x with y) instead of matching (x with x)'
    ],
    diagram: null,
    lessonId: 'dot-product-angle',
    chapterId: 'mathematics'
  },
  {
    id: 'math-dpa-ex2',
    type: 'computational',
    statement: 'Find the angle between $\\vec{A} = 2\\hat{i} + 2\\hat{j} + 1\\hat{k}$ and $\\vec{B} = 0\\hat{i} + 3\\hat{j} + 4\\hat{k}$.',
    choices: [
      {
        id: 'c1',
        text: '$45.6°$'
      },
      {
        id: 'c2',
        text: '$48.2°$'
      },
      {
        id: 'c3',
        text: '$38.2°$'
      },
      {
        id: 'c4',
        text: '$71.1°$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Three steps: (1) dot product: $(2)(0) + (2)(3) + (1)(4) = 0 + 6 + 4 = 10$, (2) magnitudes: $|\\vec{A}| = \\sqrt{4 + 4 + 1} = 3$ and $|\\vec{B}| = \\sqrt{0 + 9 + 16} = 5$, (3) $\\cos\\theta = 10/(3 \\times 5) = 10/15 = 0.6667$, so $\\theta = \\cos^{-1}(0.6667) \\approx 48.2°$. The trap is forgetting to compute both magnitudes and dividing by just one of them. Always do all three steps in order.',
    hint: 'Compute the dot product, both magnitudes, then use the angle formula.',
    steps: [
      {
        text: 'Dot product:',
        latex: '\\vec{A} \\cdot \\vec{B} = (2)(0) + (2)(3) + (1)(4) = 0 + 6 + 4 = 10'
      },
      {
        text: 'Magnitudes:',
        latex: '|\\vec{A}| = \\sqrt{4 + 4 + 1} = 3, \\quad |\\vec{B}| = \\sqrt{0 + 9 + 16} = 5'
      },
      {
        text: 'Angle formula:',
        latex: '\\cos\\theta = \\frac{10}{3 \\times 5} = \\frac{10}{15} = 0.6667'
      },
      {
        text: 'Solve:',
        latex: '\\theta = \\cos^{-1}(0.6667) = 48.2°'
      }
    ],
    handbookPage: 'p. 55',
    handbookFormula: '\\cos\\theta = \\frac{\\vec{A} \\cdot \\vec{B}}{|\\vec{A}||\\vec{B}|}',
    videoUrl: null,
    traps: [
      'Forgetting to divide by both magnitudes',
      'Arithmetic error in the dot product — every component pair matters'
    ],
    diagram: null,
    lessonId: 'dot-product-angle',
    chapterId: 'mathematics'
  },
  {
    id: 'math-dpa-ex3',
    type: 'computational',
    statement: 'A load $\\vec{F} = 200\\hat{i} + 400\\hat{j} + 100\\hat{k}$ N acts at a joint. A beam runs in the direction $\\vec{d} = 4\\hat{i} + 0\\hat{j} + 3\\hat{k}$. What is the scalar projection of the force onto the beam?',
    choices: [
      {
        id: 'c1',
        text: '$220$ N'
      },
      {
        id: 'c2',
        text: '$1100$ N'
      },
      {
        id: 'c3',
        text: '$140$ N'
      },
      {
        id: 'c4',
        text: '$500$ N'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'The scalar projection is $(\\vec{F} \\cdot \\vec{d}) / |\\vec{d}|$. Dot product: $(200)(4) + (400)(0) + (100)(3) = 800 + 0 + 300 = 1100$. Magnitude of $\\vec{d}$: $\\sqrt{16 + 0 + 9} = 5$. Projection: $1100/5 = 220$ N. The 1100 N choice is the raw dot product without dividing — the most common mistake. Always divide by the magnitude of the direction vector.',
    hint: 'Scalar projection = (F dot d) / |d|. Divide by the magnitude of the direction, not the force.',
    steps: [
      {
        text: 'Dot product:',
        latex: '\\vec{F} \\cdot \\vec{d} = (200)(4) + (400)(0) + (100)(3) = 1100'
      },
      {
        text: 'Magnitude of direction:',
        latex: '|\\vec{d}| = \\sqrt{16 + 0 + 9} = 5'
      },
      {
        text: 'Scalar projection:',
        latex: '\\frac{1100}{5} = 220 \\text{ N}'
      }
    ],
    handbookPage: 'p. 55',
    handbookFormula: '\\text{proj}_{\\vec{B}}\\vec{A} = \\frac{\\vec{A} \\cdot \\vec{B}}{|\\vec{B}|}',
    videoUrl: null,
    traps: ['Using the raw dot product without dividing by |d|', 'Dividing by |F| instead of |d|'],
    diagram: null,
    lessonId: 'dot-product-angle',
    chapterId: 'mathematics'
  },
  {
    id: 'math-dpa-ex4',
    type: 'conceptual',
    statement: 'Two vectors $\\vec{A}$ and $\\vec{B}$ have a dot product of zero. What can you conclude?',
    choices: [
      {
        id: 'c1',
        text: 'The vectors have equal magnitude'
      },
      {
        id: 'c2',
        text: 'The vectors are parallel'
      },
      {
        id: 'c3',
        text: 'One or both vectors are zero vectors, or the vectors are perpendicular'
      },
      {
        id: 'c4',
        text: 'The vectors point in opposite directions'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'hard',
    eli5: 'The dot product formula says $\\vec{A} \\cdot \\vec{B} = |A||B|\\cos\\theta$. This equals zero when $\\cos\\theta = 0$ (meaning $\\theta = 90°$, so perpendicular) OR when one of the magnitudes is zero (a zero vector). Most problems assume nonzero vectors, so the quick answer is \'perpendicular.\' But technically, the zero vector is dotted with anything and gives zero, so the complete answer includes that case. Parallel vectors have $\\cos\\theta = \\pm 1$, giving a nonzero dot product (unless one is the zero vector).',
    hint: 'The angle formula $A \\cdot B = |A||B|\\cos\\theta$ — when does this equal zero?',
    steps: [
      {
        text: 'From the angle formula: $\\vec{A} \\cdot \\vec{B} = |\\vec{A}||\\vec{B}|\\cos\\theta = 0$.',
        latex: null
      },
      {
        text: 'This happens when $|\\vec{A}| = 0$, or $|\\vec{B}| = 0$, or $\\cos\\theta = 0$ (i.e., $\\theta = 90°$).',
        latex: null
      },
      {
        text: 'If both vectors are nonzero, a zero dot product means they are perpendicular (orthogonal).',
        latex: null
      }
    ],
    handbookPage: 'p. 55',
    handbookFormula: '\\vec{A} \\cdot \\vec{B} = |\\vec{A}||\\vec{B}|\\cos\\theta',
    videoUrl: null,
    traps: [
      'Assuming zero dot product always means perpendicular — it could also mean a zero vector is involved',
      'Confusing zero dot product (perpendicular) with zero cross product (parallel)'
    ],
    diagram: null,
    lessonId: 'dot-product-angle',
    chapterId: 'mathematics'
  },
  {
    id: 'math-cpa-ex1',
    type: 'computational',
    statement: 'Compute $\\vec{A} \\times \\vec{B}$ where $\\vec{A} = 2\\hat{i} + 3\\hat{j} + 0\\hat{k}$ and $\\vec{B} = 0\\hat{i} + 0\\hat{j} + 4\\hat{k}$.',
    choices: [
      {
        id: 'c1',
        text: '$12\\hat{i} - 8\\hat{j} + 0\\hat{k}$'
      },
      {
        id: 'c2',
        text: '$-12\\hat{i} + 8\\hat{j} + 0\\hat{k}$'
      },
      {
        id: 'c3',
        text: '$0\\hat{i} + 0\\hat{j} + 8\\hat{k}$'
      },
      {
        id: 'c4',
        text: '$12\\hat{i} + 8\\hat{j} + 0\\hat{k}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Set up the 3x3 determinant with $\\hat{i}, \\hat{j}, \\hat{k}$ in the top row. The $\\hat{i}$ component: $(3)(4) - (0)(0) = 12$. The $\\hat{j}$ component: $-[(2)(4) - (0)(0)] = -8$. The $\\hat{k}$ component: $(2)(0) - (3)(0) = 0$. So the result is $12\\hat{i} - 8\\hat{j}$. The choice $-12\\hat{i} + 8\\hat{j} + 0\\hat{k}$ has the signs flipped — that\'s $\\vec{B} \\times \\vec{A}$. Remember the sign pattern: $+, -, +$ for $\\hat{i}, \\hat{j}, \\hat{k}$.',
    hint: 'Use the determinant formula. Watch the negative sign on the $\\hat{j}$ cofactor.',
    steps: [
      {
        text: 'Set up the determinant:',
        latex: '\\vec{A} \\times \\vec{B} = \\begin{vmatrix} \\hat{i} & \\hat{j} & \\hat{k} \\\\ 2 & 3 & 0 \\\\ 0 & 0 & 4 \\end{vmatrix}'
      },
      {
        text: '$\\hat{i}$: $(3)(4) - (0)(0) = 12$',
        latex: null
      },
      {
        text: '$\\hat{j}$: $-[(2)(4) - (0)(0)] = -8$',
        latex: null
      },
      {
        text: '$\\hat{k}$: $(2)(0) - (3)(0) = 0$',
        latex: null
      },
      {
        text: 'Result:',
        latex: '\\vec{A} \\times \\vec{B} = 12\\hat{i} - 8\\hat{j} + 0\\hat{k}'
      }
    ],
    handbookPage: 'p. 55',
    handbookFormula: '\\vec{A} \\times \\vec{B} = \\begin{vmatrix} \\hat{i} & \\hat{j} & \\hat{k} \\\\ A_x & A_y & A_z \\\\ B_x & B_y & B_z \\end{vmatrix}',
    videoUrl: null,
    traps: [
      'Forgetting the negative sign on the j cofactor',
      'Reversing the order and getting B x A (which flips all signs)'
    ],
    diagram: null,
    lessonId: 'cross-product-applications',
    chapterId: 'mathematics'
  },
  {
    id: 'math-cpa-ex2',
    type: 'computational',
    statement: 'A 100 N downward force ($\\vec{F} = 0\\hat{i} + 0\\hat{j} - 100\\hat{k}$ N) is applied at a point with position vector $\\vec{r} = 5\\hat{i} + 0\\hat{j} + 0\\hat{k}$ m from a pivot. What is the magnitude of the moment about the pivot?',
    choices: [
      {
        id: 'c1',
        text: '$0$ N$\\cdot$m'
      },
      {
        id: 'c2',
        text: '$100$ N$\\cdot$m'
      },
      {
        id: 'c3',
        text: '$250$ N$\\cdot$m'
      },
      {
        id: 'c4',
        text: '$500$ N$\\cdot$m'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'Moment = $\\vec{r} \\times \\vec{F}$. Set up the determinant: $\\hat{i}(0 \\cdot(-100) - 0 \\cdot 0) - \\hat{j}(5 \\cdot(-100) - 0 \\cdot 0) + \\hat{k}(5 \\cdot 0 - 0 \\cdot 0) = 0\\hat{i} + 500\\hat{j} + 0\\hat{k}$. The magnitude is 500 N$\\cdot$m. You can also reason geometrically: force and position vector are perpendicular, so $M = rF\\sin 90° = 5 \\times 100 = 500$.',
    hint: 'Compute $\\vec{r} \\times \\vec{F}$ using the determinant, then take the magnitude.',
    steps: [
      {
        text: 'Set up the determinant:',
        latex: '\\vec{r} \\times \\vec{F} = \\begin{vmatrix} \\hat{i} & \\hat{j} & \\hat{k} \\\\ 5 & 0 & 0 \\\\ 0 & 0 & -100 \\end{vmatrix}'
      },
      {
        text: '$\\hat{i}$: $(0)(-100) - (0)(0) = 0$',
        latex: null
      },
      {
        text: '$\\hat{j}$: $-[(5)(-100) - (0)(0)] = -(-500) = 500$',
        latex: null
      },
      {
        text: '$\\hat{k}$: $(5)(0) - (0)(0) = 0$',
        latex: null
      },
      {
        text: 'Magnitude:',
        latex: '|\\vec{M}| = \\sqrt{0^2 + 500^2 + 0^2} = 500 \\text{ N·m}'
      }
    ],
    handbookPage: 'p. 55',
    handbookFormula: '\\vec{M}_O = \\vec{r} \\times \\vec{F}',
    videoUrl: null,
    traps: [
      'Sign error on the j cofactor — the pattern is +, -, +',
      'Computing F x r instead of r x F (wrong order reverses the moment direction)'
    ],
    diagram: null,
    lessonId: 'cross-product-applications',
    chapterId: 'mathematics'
  },
  {
    id: 'math-cpa-ex3',
    type: 'computational',
    statement: 'Two edge vectors of a triangular surveying plot are $\\vec{u} = 3\\hat{i} + 1\\hat{j} + 0\\hat{k}$ m and $\\vec{v} = -1\\hat{i} + 4\\hat{j} + 0\\hat{k}$ m. What is the area of the triangle?',
    choices: [
      {
        id: 'c1',
        text: '$11$ m$^2$'
      },
      {
        id: 'c2',
        text: '$13$ m$^2$'
      },
      {
        id: 'c3',
        text: '$6.5$ m$^2$'
      },
      {
        id: 'c4',
        text: '$5$ m$^2$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'The cross product magnitude gives the parallelogram area, so divide by 2 for the triangle. Both vectors are in the $xy$-plane, so only the $\\hat{k}$ component survives: $(3)(4) - (1)(-1) = 12 + 1 = 13$. The cross product is $13\\hat{k}$, magnitude is 13. Triangle area = $13/2 = 6.5$ m$^2$. The 13 m$^2$ option is the parallelogram area — forgetting to halve is the most common mistake.',
    hint: 'Triangle area = $\\frac{1}{2}|\\vec{u} \\times \\vec{v}|$. Don\'t forget the $\\frac{1}{2}$.',
    steps: [
      {
        text: 'Cross product (both vectors in $xy$-plane, only $\\hat{k}$ survives):',
        latex: '\\vec{u} \\times \\vec{v} = [(3)(4) - (1)(-1)]\\hat{k} = 13\\hat{k}'
      },
      {
        text: 'Parallelogram area:',
        latex: '|\\vec{u} \\times \\vec{v}| = 13 \\text{ m}^2'
      },
      {
        text: 'Triangle area:',
        latex: '\\frac{13}{2} = 6.5 \\text{ m}^2'
      }
    ],
    handbookPage: 'p. 55',
    handbookFormula: '|\\vec{A} \\times \\vec{B}| = |\\vec{A}||\\vec{B}|\\sin\\theta',
    videoUrl: null,
    traps: [
      'Forgetting to divide by 2 — the cross product gives parallelogram area, not triangle area',
      'Sign error in the $\\hat{k}$ component: $(3)(4) - (1)(-1) = 13$, not 11'
    ],
    diagram: null,
    lessonId: 'cross-product-applications',
    chapterId: 'mathematics'
  },
  {
    id: 'math-cpa-ex4',
    type: 'conceptual',
    statement: 'If $\\vec{A} \\times \\vec{B} = \\vec{0}$ and neither vector is the zero vector, what can you conclude about $\\vec{A}$ and $\\vec{B}$?',
    choices: [
      {
        id: 'c1',
        text: 'The vectors are perpendicular'
      },
      {
        id: 'c2',
        text: 'The vectors are parallel (or anti-parallel)'
      },
      {
        id: 'c3',
        text: 'The vectors have equal magnitude'
      },
      {
        id: 'c4',
        text: 'The dot product is also zero'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'The cross product magnitude is $|A||B|\\sin\\theta$. For this to be zero with nonzero vectors, $\\sin\\theta$ must be zero, which happens at $\\theta = 0°$ (parallel) or $\\theta = 180°$ (anti-parallel). This is the opposite of the dot product test: dot product zero means perpendicular (cos = 0), cross product zero means parallel (sin = 0). Don\'t mix them up. The "perpendicular" choice is the dot product test, not the cross product test.',
    hint: 'The magnitude formula uses $\\sin\\theta$. When is sine zero?',
    steps: [
      {
        text: 'From the magnitude formula:',
        latex: '|\\vec{A} \\times \\vec{B}| = |\\vec{A}||\\vec{B}|\\sin\\theta = 0'
      },
      {
        text: 'Since $|\\vec{A}| \\neq 0$ and $|\\vec{B}| \\neq 0$, we need $\\sin\\theta = 0$.',
        latex: null
      },
      {
        text: '$\\sin\\theta = 0$ when $\\theta = 0°$ (parallel) or $\\theta = 180°$ (anti-parallel).',
        latex: null
      }
    ],
    handbookPage: 'p. 55',
    handbookFormula: '|\\vec{A} \\times \\vec{B}| = |\\vec{A}||\\vec{B}|\\sin\\theta',
    videoUrl: null,
    traps: [
      'Confusing cross product = 0 (parallel) with dot product = 0 (perpendicular)',
      'Forgetting that anti-parallel (180°) also gives a zero cross product'
    ],
    diagram: null,
    lessonId: 'cross-product-applications',
    chapterId: 'mathematics'
  },
  {
    id: 'math-spr-ex1',
    type: 'computational',
    statement: 'A spreadsheet cell contains =B2+B3/B4 with B2 = 10, B3 = 20, and B4 = 4. What value does the cell display?',
    choices: [
      { id: 'c1', text: '15' },
      { id: 'c2', text: '7.5' },
      { id: 'c3', text: '30' },
      { id: 'c4', text: '2.5' }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Spreadsheets follow order of operations: division before addition. Compute B3/B4 = 20/4 = 5 first, then add B2: 10 + 5 = 15. The 7.5 option is the mistake of doing (B2+B3)/B4 = 30/4. The 30 option ignores the division entirely.',
    hint: 'Division happens before addition — evaluate B3/B4 first.',
    steps: [
      { text: 'Precedence: division before addition. Evaluate B3/B4 = 20/4 = 5.', latex: null },
      { text: 'Add B2: 10 + 5 = 15.', latex: null }
    ],
    handbookPage: null,
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Computing (B2+B3)/B4 = 7.5 by adding before dividing',
      'Ignoring the division term and reporting 30'
    ],
    diagram: null,
    lessonId: 'spreadsheet-computations',
    chapterId: 'mathematics'
  },
  {
    id: 'math-spr-ex2',
    type: 'computational',
    statement: 'In a takeoff sheet, the unit price is stored once in cell D1 = 25. Cell E2 holds =B2*$D$1 with B2 = 8 (so E2 displays 200). The formula is copied down to E5, where B5 = 12. What value does E5 display?',
    choices: [
      { id: 'c1', text: '300' },
      { id: 'c2', text: '200' },
      { id: 'c3', text: '37' },
      { id: 'c4', text: '12' }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'The relative reference B2 shifts to B5 when copied down three rows, but the absolute reference $D$1 stays locked on the unit price. So E5 = B5*$D$1 = 12 × 25 = 300. The 200 choice assumes B did not shift. The 37 choice adds quantity + price. The 12 choice forgets to multiply by the unit price.',
    hint: 'B2 is relative (shifts to B5); $D$1 is absolute (stays on the unit price).',
    steps: [
      { text: 'Copying down three rows shifts the relative reference: B2 → B5.', latex: null },
      { text: 'The absolute reference $D$1 stays fixed on the unit price (25).', latex: null },
      { text: 'E5 = B5 × $D$1 = 12 × 25 = 300.', latex: null }
    ],
    handbookPage: null,
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Assuming the relative B reference does not move (200)',
      'Forgetting to lock the unit price so it drifts off the value'
    ],
    diagram: null,
    lessonId: 'spreadsheet-computations',
    chapterId: 'mathematics'
  },
  {
    id: 'math-spr-ex3',
    type: 'computational',
    statement: 'A column lists quantities in cells C2 through C6: 12, 15, 18, 9, and 6. A summary cell contains =SUM(C2:C6). What value does it display?',
    choices: [
      { id: 'c1', text: '60' },
      { id: 'c2', text: '54' },
      { id: 'c3', text: '48' },
      { id: 'c4', text: '12' }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'SUM(C2:C6) adds every value in the inclusive range C2 through C6: 12 + 15 + 18 + 9 + 6 = 60. Choices that drop an endpoint (54 omits the 6; 48 omits the 12) are the classic range-boundary mistakes. The choice 12 reads only the first cell.',
    hint: 'SUM over C2:C6 includes both endpoints — add all five values.',
    steps: [
      { text: 'The range C2:C6 includes all five cells.', latex: null },
      { text: '12 + 15 + 18 + 9 + 6 = 60.', latex: null }
    ],
    handbookPage: null,
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Dropping a boundary cell of the range (54 or 48)',
      'Reading only the first cell of the range'
    ],
    diagram: null,
    lessonId: 'spreadsheet-computations',
    chapterId: 'mathematics'
  },
  {
    id: 'math-prg-ex1',
    type: 'computational',
    statement: 'Trace this pseudocode: p = 1; FOR i = 1 TO 5: p = p * i. What is the value of p after the loop finishes?',
    choices: [
      { id: 'c1', text: '120' },
      { id: 'c2', text: '15' },
      { id: 'c3', text: '24' },
      { id: 'c4', text: '720' }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'The loop multiplies a running product by i for i = 1, 2, 3, 4, 5 — that is 5 factorial: 1×1×2×3×4×5 = 120. The 15 choice adds instead of multiplies (1+2+3+4+5). The 24 choice stops at i = 4 (4!). The 720 choice runs one extra pass to i = 6.',
    hint: 'A running product over i = 1..5 is 5 factorial.',
    steps: [
      { text: 'i = 1: p = 1. i = 2: p = 2. i = 3: p = 6.', latex: null },
      { text: 'i = 4: p = 24. i = 5: p = 120. Loop ends.', latex: null }
    ],
    handbookPage: null,
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Adding instead of multiplying (15)',
      'Off-by-one: stopping at 4! = 24 or running to 6! = 720'
    ],
    diagram: null,
    lessonId: 'structured-programming',
    chapterId: 'mathematics'
  },
  {
    id: 'math-prg-ex2',
    type: 'computational',
    statement: 'Trace this loop: count = 0; x = 80; WHILE x > 5: x = x / 2; count = count + 1. How many times does the loop body execute?',
    choices: [
      { id: 'c1', text: '4' },
      { id: 'c2', text: '3' },
      { id: 'c3', text: '5' },
      { id: 'c4', text: '16' }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Halve x while x > 5, counting each pass: 80→40 (1), 40→20 (2), 20→10 (3), 10→5 (4). Now x = 5, and 5 > 5 is false, so the loop stops. The body ran 4 times. The answer 3 stops one pass early; the answer 5 runs one extra pass even though 5 > 5 is false.',
    hint: 'Halve until x > 5 fails; remember 5 > 5 is false (strict inequality).',
    steps: [
      { text: '80 > 5 → x = 40, count = 1. 40 > 5 → x = 20, count = 2.', latex: null },
      { text: '20 > 5 → x = 10, count = 3. 10 > 5 → x = 5, count = 4.', latex: null },
      { text: '5 > 5 is FALSE → stop. The body executed 4 times.', latex: null }
    ],
    handbookPage: null,
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Counting a 5th pass even though 5 > 5 is false',
      'Stopping at count = 3 (off-by-one)'
    ],
    diagram: null,
    lessonId: 'structured-programming',
    chapterId: 'mathematics'
  },
  {
    id: 'math-num-ex1',
    type: 'computational',
    statement: 'Apply one iteration of Newton\'s method to $f(x) = x^2 - 5$, starting from $x_0 = 2$ (with $f\'(x) = 2x$). What is $x_1$?',
    choices: [
      { id: 'c1', text: '$2.25$' },
      { id: 'c2', text: '$1.75$' },
      { id: 'c3', text: '$2.00$' },
      { id: 'c4', text: '$2.50$' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'x₁ = x₀ − f(x₀)/f′(x₀). f(2) = 4 − 5 = −1; f′(2) = 4. So x₁ = 2 − (−1)/4 = 2 + 0.25 = 2.25 (approaching √5 ≈ 2.236). The 1.75 distractor subtracts 0.25 instead of adding it (mishandling the negative sign). The 2.00 distractor is just the start value x\u2080. The 2.50 distractor over-shoots \u221a5.',
    hint: 'x₁ = x₀ − f(x₀)/f′(x₀); mind the sign of f(x₀).',
    steps: [
      { text: 'Evaluate:', latex: 'f(2) = -1, \\quad f\'(2) = 4' },
      { text: 'Newton update:', latex: 'x_1 = 2 - \\frac{-1}{4} = 2.25' },
    ],
    handbookPage: 'p. 61',
    handbookFormula: 'x_{j+1} = x_j - f(x_j)/f\'(x_j)',
    videoUrl: null,
    traps: ['Mishandling the negative sign of f(x₀)', 'Dropping the derivative in the denominator'],
    diagram: { component: 'NewtonTangent', props: {} },
    lessonId: 'numerical-methods',
    chapterId: 'mathematics'
  },
];

export default PROBLEMS;
