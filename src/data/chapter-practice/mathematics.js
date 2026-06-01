// Chapter practice: Mathematics (26 questions, 2 per lesson)

const PROBLEMS = [
  {
    id: 'math-slq-cp1',
    type: 'computational',
    statement: 'A straight property boundary is described by the line $3x - 4y + 10 = 0$. A survey monument sits at the point $(8, 6)$. What is the perpendicular distance from the monument to the boundary line?',
    choices: [
      {
        id: 'c1',
        text: '$10$'
      },
      {
        id: 'c2',
        text: '$2$'
      },
      {
        id: 'c3',
        text: '$1.4$'
      },
      {
        id: 'c4',
        text: '$50$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'The point-to-line distance formula is $d = |Ax_0 + By_0 + C| / \\sqrt{A^2 + B^2}$. Plug in: numerator $= |3(8) - 4(6) + 10| = |24 - 24 + 10| = 10$; denominator $= \\sqrt{9 + 16} = 5$; so $d = 10/5 = 2$. The value 10 is the numerator alone — forgetting to divide by the magnitude of the coefficient vector. The value 1.4 comes from dividing by $\\sqrt{2}$ instead of $\\sqrt{A^2+B^2}$. The value 50 forgets the square root in the denominator.',
    hint: 'Use the point-to-line distance formula and divide the absolute numerator by $\\sqrt{A^2 + B^2}$.',
    steps: [
      {
        text: 'Identify $A = 3$, $B = -4$, $C = 10$ and the point $(x_0, y_0) = (8, 6)$.',
        latex: null
      },
      {
        text: 'Apply the distance formula:',
        latex: 'd = \\frac{|3(8) - 4(6) + 10|}{\\sqrt{3^2 + (-4)^2}}'
      },
      {
        text: 'Compute:',
        latex: 'd = \\frac{|24 - 24 + 10|}{\\sqrt{25}} = \\frac{10}{5} = 2'
      }
    ],
    handbookPage: 'p. 36',
    handbookFormula: 'd = \\frac{|Ax_0 + By_0 + C|}{\\sqrt{A^2 + B^2}}',
    videoUrl: null,
    traps: [
      'Forgetting to divide by the magnitude of the coefficient vector',
      'Using $\\sqrt{2}$ instead of $\\sqrt{A^2 + B^2}$ in the denominator'
    ],
    diagram: null,
    lessonId: 'straight-lines-quadratics',
    chapterId: 'mathematics'
  },
  {
    id: 'math-slq-cp2',
    type: 'computational',
    statement: 'The profile of a sag vertical curve is modeled by $y = 2x^2 - 12x + 5$. What is the minimum elevation $y$ on the curve?',
    choices: [
      {
        id: 'c1',
        text: '$5$'
      },
      {
        id: 'c2',
        text: '$3$'
      },
      {
        id: 'c3',
        text: '$-13$'
      },
      {
        id: 'c4',
        text: '$-7$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'The vertex of a parabola occurs at $x = -b/(2a) = 12/4 = 3$. The minimum elevation is the $y$-value there: $y = 2(3)^2 - 12(3) + 5 = 18 - 36 + 5 = -13$. The value 3 is the vertex $x$-coordinate, not the elevation — a classic mix-up. The value 5 is the $y$-intercept (the value at $x = 0$), not the minimum. The value $-7$ drops the constant term.',
    hint: 'Find the vertex $x = -b/(2a)$ first, then substitute back to get the minimum $y$.',
    steps: [
      {
        text: 'Locate the vertex:',
        latex: 'x = -\\frac{b}{2a} = -\\frac{-12}{2(2)} = 3'
      },
      {
        text: 'Substitute back to find the minimum elevation:',
        latex: 'y = 2(3)^2 - 12(3) + 5 = 18 - 36 + 5 = -13'
      }
    ],
    handbookPage: 'p. 36',
    handbookFormula: 'x_{vertex} = -\\frac{b}{2a}',
    videoUrl: null,
    traps: [
      'Reporting the vertex x-coordinate instead of the minimum y-value',
      'Confusing the y-intercept (value at x = 0) with the minimum'
    ],
    diagram: null,
    lessonId: 'straight-lines-quadratics',
    chapterId: 'mathematics'
  },
  {
    id: 'math-log-cp1',
    type: 'computational',
    statement: 'Simplify $\\log_2(48) - \\log_2(3)$.',
    choices: [
      {
        id: 'c1',
        text: '$45$'
      },
      {
        id: 'c2',
        text: '$\\log_2(45)$'
      },
      {
        id: 'c3',
        text: '$16$'
      },
      {
        id: 'c4',
        text: '$4$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'The quotient rule turns a difference of logs into the log of a quotient: $\\log_2(48) - \\log_2(3) = \\log_2(48/3) = \\log_2(16)$. Since $2^4 = 16$, the answer is 4. The choice $\\log_2(45)$ is the result of wrongly subtracting the arguments ($48 - 3 = 45$) inside the log — there is no such identity. The value 45 is just that wrong subtraction. The value 16 is the argument itself, forgetting to take the log.',
    hint: 'A difference of logs with the same base becomes the log of a quotient.',
    steps: [
      {
        text: 'Apply the quotient rule:',
        latex: '\\log_2(48) - \\log_2(3) = \\log_2\\!\\left(\\frac{48}{3}\\right) = \\log_2(16)'
      },
      {
        text: 'Evaluate the logarithm:',
        latex: '\\log_2(16) = 4 \\quad (\\text{since } 2^4 = 16)'
      }
    ],
    handbookPage: 'p. 36',
    handbookFormula: '\\log_b\\!\\left(\\frac{x}{y}\\right) = \\log_b x - \\log_b y',
    videoUrl: null,
    traps: [
      'Subtracting the arguments (48 - 3) instead of dividing them',
      'Stopping at log_2(16) without evaluating to 4'
    ],
    diagram: null,
    lessonId: 'logarithms',
    chapterId: 'mathematics'
  },
  {
    id: 'math-log-cp2',
    type: 'computational',
    statement: 'A radioactive tracer used in a soil study has a half-life of $8$ days and decays according to $N = N_0\\left(\\tfrac{1}{2}\\right)^{t/8}$. After how many days will only $25\\%$ of the original amount remain?',
    choices: [
      {
        id: 'c1',
        text: '$12$ days'
      },
      {
        id: 'c2',
        text: '$16$ days'
      },
      {
        id: 'c3',
        text: '$32$ days'
      },
      {
        id: 'c4',
        text: '$4$ days'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Set $N/N_0 = 0.25 = (1/2)^{t/8}$. Since $0.25 = (1/2)^2$, the exponents must match: $t/8 = 2$, so $t = 16$ days. You can also reason it out: 25 percent is two half-lives, and each half-life is 8 days, so $2 \\times 8 = 16$. The value 12 averages 8 and 16 incorrectly. The value 32 is four half-lives (which gives 6.25 percent). The value 4 is only half of one half-life.',
    hint: 'Write 0.25 as a power of one-half, then match exponents.',
    steps: [
      {
        text: 'Set up the decay equation:',
        latex: '0.25 = \\left(\\frac{1}{2}\\right)^{t/8}'
      },
      {
        text: 'Express 0.25 as a power of one-half:',
        latex: '\\left(\\frac{1}{2}\\right)^{2} = \\left(\\frac{1}{2}\\right)^{t/8}'
      },
      {
        text: 'Match exponents and solve:',
        latex: '\\frac{t}{8} = 2 \\implies t = 16\\,\\text{days}'
      }
    ],
    handbookPage: 'p. 36',
    handbookFormula: 'N = N_0\\left(\\tfrac{1}{2}\\right)^{t/T_{1/2}}',
    videoUrl: null,
    traps: [
      'Counting only one half-life when 25 percent requires two',
      'Using four half-lives, which leaves 6.25 percent'
    ],
    diagram: null,
    lessonId: 'logarithms',
    chapterId: 'mathematics'
  },
  {
    id: 'math-rtt-cp1',
    type: 'computational',
    statement: 'A surveyor standing $60\\,\\text{m}$ from the base of a tower measures the angle of elevation to the top as $32°$. What is the height of the tower?',
    choices: [
      {
        id: 'c1',
        text: '$37.5\\,\\text{m}$'
      },
      {
        id: 'c2',
        text: '$31.8\\,\\text{m}$'
      },
      {
        id: 'c3',
        text: '$50.9\\,\\text{m}$'
      },
      {
        id: 'c4',
        text: '$96.0\\,\\text{m}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'The horizontal distance (60 m) is adjacent to the angle, and the tower height is opposite. Opposite over adjacent is tangent: $\\tan 32° = h/60$, so $h = 60\\tan 32° = 60(0.6249) = 37.5$ m. The value 31.8 uses sine of the distance ($60\\sin 32°$), 50.9 uses cosine, and 96.0 divides instead of multiplying ($60/\\tan 32°$).',
    hint: 'You know the adjacent side and want the opposite side — which ratio is that?',
    steps: [
      {
        text: 'The 60 m distance is adjacent to the angle; the height is opposite. Use tangent:',
        latex: '\\tan 32° = \\frac{h}{60}'
      },
      {
        text: 'Solve for h:',
        latex: 'h = 60\\tan 32° = 60(0.6249) = 37.5\\,\\text{m}'
      }
    ],
    handbookPage: 'p. 23',
    handbookFormula: '\\tan\\theta = \\frac{\\text{opp}}{\\text{adj}}',
    videoUrl: null,
    traps: [
      'Using sine or cosine instead of tangent',
      'Dividing by tangent instead of multiplying'
    ],
    diagram: null,
    lessonId: 'right-triangle-trig',
    chapterId: 'mathematics'
  },
  {
    id: 'math-rtt-cp2',
    type: 'computational',
    statement: 'A right-triangle bracing member has legs of $9\\,\\text{m}$ (vertical) and $12\\,\\text{m}$ (horizontal). What angle does the hypotenuse make with the horizontal leg?',
    choices: [
      {
        id: 'c1',
        text: '$53.1°$'
      },
      {
        id: 'c2',
        text: '$48.6°$'
      },
      {
        id: 'c3',
        text: '$36.9°$'
      },
      {
        id: 'c4',
        text: '$41.4°$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'The angle at the horizontal leg has the 9 m vertical leg opposite it and the 12 m horizontal leg adjacent. So $\\tan\\theta = 9/12 = 0.75$ and $\\theta = \\tan^{-1}(0.75) = 36.9°$. The value 53.1 is the complementary angle — what the hypotenuse makes with the vertical leg, computed by swapping opposite and adjacent. The value 48.6 uses $\\sin^{-1}(9/12)$ by mistake, and 41.4 uses $\\cos^{-1}(9/12)$.',
    hint: 'Relative to the horizontal leg, identify which side is opposite and which is adjacent, then use inverse tangent.',
    steps: [
      {
        text: 'At the horizontal leg, the 9 m leg is opposite and the 12 m leg is adjacent:',
        latex: '\\tan\\theta = \\frac{9}{12} = 0.75'
      },
      {
        text: 'Take the inverse tangent:',
        latex: '\\theta = \\tan^{-1}(0.75) = 36.9°'
      }
    ],
    handbookPage: 'p. 23',
    handbookFormula: '\\tan\\theta = \\frac{\\text{opp}}{\\text{adj}}',
    videoUrl: null,
    traps: [
      'Reporting the complement (53.1 degrees) measured from the vertical leg',
      'Using sine or cosine of the leg ratio instead of tangent'
    ],
    diagram: null,
    lessonId: 'right-triangle-trig',
    chapterId: 'mathematics'
  },
  {
    id: 'math-lsc-cp1',
    type: 'computational',
    statement: 'In a triangle, side $a = 18\\,\\text{m}$ is opposite angle $A = 40°$, and side $b = 14\\,\\text{m}$ is opposite angle $B$. What is angle $B$?',
    choices: [
      {
        id: 'c1',
        text: '$59.4°$'
      },
      {
        id: 'c2',
        text: '$52.7°$'
      },
      {
        id: 'c3',
        text: '$45.8°$'
      },
      {
        id: 'c4',
        text: '$30.0°$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'You have a complete side-angle pair ($a$, $A$) and another side ($b$), so Law of Sines solves for angle $B$: $\\sin B = b\\sin A / a = 14\\sin 40° / 18 = 14(0.6428)/18 = 0.4999$, giving $B = \\sin^{-1}(0.5) = 30.0°$. The smaller side ($14 < 18$) must face the smaller angle ($30° < 40°$), which is a good sanity check. The value 59.4 flips the ratio ($a\\sin A / b$). The value 52.7 drops the sine on angle $A$.',
    hint: 'You have a side-angle pair plus another side — set up the Law of Sines and solve for $\\sin B$.',
    steps: [
      {
        text: 'Set up the Law of Sines:',
        latex: '\\frac{a}{\\sin A} = \\frac{b}{\\sin B}'
      },
      {
        text: 'Solve for $\\sin B$:',
        latex: '\\sin B = \\frac{b\\sin A}{a} = \\frac{14\\sin 40°}{18} = \\frac{14(0.6428)}{18} = 0.500'
      },
      {
        text: 'Take the inverse sine:',
        latex: 'B = \\sin^{-1}(0.500) = 30.0°'
      }
    ],
    handbookPage: 'p. 38',
    handbookFormula: '\\frac{a}{\\sin A} = \\frac{b}{\\sin B}',
    videoUrl: null,
    traps: [
      'Flipping the ratio and computing $a\\sin A / b$',
      'Forgetting to take the inverse sine of the final ratio'
    ],
    diagram: null,
    lessonId: 'law-of-sines-cosines',
    chapterId: 'mathematics'
  },
  {
    id: 'math-lsc-cp2',
    type: 'computational',
    statement: 'A triangular truss panel has sides of $11\\,\\text{m}$, $13\\,\\text{m}$, and $20\\,\\text{m}$. What is the measure of the largest interior angle?',
    choices: [
      {
        id: 'c1',
        text: '$67.4°$'
      },
      {
        id: 'c2',
        text: '$112.6°$'
      },
      {
        id: 'c3',
        text: '$90.0°$'
      },
      {
        id: 'c4',
        text: '$98.2°$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'The largest angle is always opposite the longest side (20 m), so call it $C$. Rearrange the Law of Cosines: $\\cos C = (a^2 + b^2 - c^2)/(2ab) = (121 + 169 - 400)/(2 \\cdot 11 \\cdot 13) = -110/286 = -0.3846$. A negative cosine means an obtuse angle: $C = \\cos^{-1}(-0.3846) = 112.6°$. The value 67.4 is the supplement (forgetting the cosine is negative). The value 90.0 assumes a right angle. The value 98.2 drops the negative sign in the numerator partway through.',
    hint: 'The largest angle faces the longest side. Use the rearranged Law of Cosines and watch the sign of the cosine.',
    steps: [
      {
        text: 'The largest angle $C$ is opposite the longest side $c = 20$. Use $a = 11$, $b = 13$:',
        latex: '\\cos C = \\frac{a^2 + b^2 - c^2}{2ab}'
      },
      {
        text: 'Substitute:',
        latex: '\\cos C = \\frac{121 + 169 - 400}{2(11)(13)} = \\frac{-110}{286} = -0.3846'
      },
      {
        text: 'Take the inverse cosine (negative cosine gives an obtuse angle):',
        latex: 'C = \\cos^{-1}(-0.3846) = 112.6°'
      }
    ],
    handbookPage: 'p. 38',
    handbookFormula: '\\cos C = \\frac{a^2 + b^2 - c^2}{2ab}',
    videoUrl: null,
    traps: [
      'Dropping the negative sign and reporting the acute supplement',
      'Solving for an angle opposite a shorter side instead of the longest side'
    ],
    diagram: null,
    lessonId: 'law-of-sines-cosines',
    chapterId: 'mathematics'
  },
  {
    id: 'math-ucti-cp1',
    type: 'computational',
    statement: 'What is the exact value of $\\tan 225°$?',
    choices: [
      {
        id: 'c1',
        text: '$-1$'
      },
      {
        id: 'c2',
        text: '$\\sqrt{3}$'
      },
      {
        id: 'c3',
        text: '$1$'
      },
      {
        id: 'c4',
        text: '$\\frac{\\sqrt{2}}{2}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'The angle 225 degrees lands in Quadrant III, with reference angle $225° - 180° = 45°$. The reference value is $\\tan 45° = 1$. In Q3 both sine and cosine are negative, and tangent (sine over cosine) is positive, so $\\tan 225° = +1$. The value $-1$ wrongly makes it negative. The value $\\sqrt{3}$ is $\\tan 60°$. The value $\\sqrt{2}/2$ is $\\sin 45°$, not its tangent.',
    hint: 'Find the reference angle, then use the quadrant to set the sign of the tangent.',
    steps: [
      {
        text: 'Reference angle:',
        latex: '225° - 180° = 45°'
      },
      {
        text: 'In Q3, both sine and cosine are negative, so tangent is positive:',
        latex: '\\tan 225° = +\\tan 45° = 1'
      }
    ],
    handbookPage: 'p. 38',
    handbookFormula: '\\tan 45° = 1',
    videoUrl: null,
    traps: [
      'Assigning a negative sign — tangent is positive in Q3',
      'Confusing $\\tan 45°$ with $\\sin 45° = \\sqrt{2}/2$'
    ],
    diagram: null,
    lessonId: 'unit-circle-trig-identities',
    chapterId: 'mathematics'
  },
  {
    id: 'math-ucti-cp2',
    type: 'computational',
    statement: 'If $\\sin\\theta = \\frac{8}{17}$ and $\\theta$ lies in the second quadrant, what is $\\tan\\theta$?',
    choices: [
      {
        id: 'c1',
        text: '$-\\frac{8}{15}$'
      },
      {
        id: 'c2',
        text: '$\\frac{8}{15}$'
      },
      {
        id: 'c3',
        text: '$-\\frac{15}{8}$'
      },
      {
        id: 'c4',
        text: '$\\frac{8}{17}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Use the Pythagorean identity to get cosine: $\\cos^2\\theta = 1 - (8/17)^2 = 1 - 64/289 = 225/289$, so $\\cos\\theta = \\pm 15/17$. In Quadrant II cosine is negative, so $\\cos\\theta = -15/17$. Then $\\tan\\theta = \\sin\\theta/\\cos\\theta = (8/17)/(-15/17) = -8/15$. The value $+8/15$ ignores the quadrant and keeps it positive. The value $-15/8$ inverts the ratio (cos over sin). The value $8/17$ just repeats the sine.',
    hint: 'Find cosine from the Pythagorean identity, set its sign from the quadrant, then divide sine by cosine.',
    steps: [
      {
        text: 'Find cosine using the identity:',
        latex: '\\cos^2\\theta = 1 - \\left(\\tfrac{8}{17}\\right)^2 = 1 - \\tfrac{64}{289} = \\tfrac{225}{289}'
      },
      {
        text: 'In Q2, cosine is negative:',
        latex: '\\cos\\theta = -\\frac{15}{17}'
      },
      {
        text: 'Compute the tangent:',
        latex: '\\tan\\theta = \\frac{\\sin\\theta}{\\cos\\theta} = \\frac{8/17}{-15/17} = -\\frac{8}{15}'
      }
    ],
    handbookPage: 'p. 38',
    handbookFormula: '\\tan\\theta = \\frac{\\sin\\theta}{\\cos\\theta}',
    videoUrl: null,
    traps: [
      'Keeping cosine positive and ignoring that Q2 makes it negative',
      'Inverting the ratio to get cos/sin instead of sin/cos'
    ],
    diagram: null,
    lessonId: 'unit-circle-trig-identities',
    chapterId: 'mathematics'
  },
  {
    id: 'math-cc-cp1',
    type: 'computational',
    statement: 'A parabolic reflector has the equation $(x - 3)^2 = 8(y - 2)$. What are the coordinates of its focus?',
    choices: [
      {
        id: 'c1',
        text: '$(3, 2)$'
      },
      {
        id: 'c2',
        text: '$(3, 4)$'
      },
      {
        id: 'c3',
        text: '$(3, 10)$'
      },
      {
        id: 'c4',
        text: '$(3, 6)$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'A vertical parabola in the form $(x - h)^2 = 4p(y - k)$ has vertex $(h, k)$ and focus $(h, k + p)$. Here $4p = 8$, so $p = 2$, and the vertex is $(3, 2)$. The focus sits $p = 2$ units above the vertex: $(3, 2 + 2) = (3, 4)$. The point $(3, 2)$ is the vertex itself. The point $(3, 10)$ uses $p = 8$ (forgetting to divide by 4). The point $(3, 6)$ uses $p = 4$ (dividing by 2 instead of 4).',
    hint: 'Match to $(x-h)^2 = 4p(y-k)$, solve for $p$, then move $p$ units from the vertex toward the opening.',
    steps: [
      {
        text: 'Compare to standard form $(x-h)^2 = 4p(y-k)$: vertex is $(3, 2)$ and $4p = 8$.',
        latex: null
      },
      {
        text: 'Solve for the focal distance:',
        latex: '4p = 8 \\implies p = 2'
      },
      {
        text: 'The parabola opens upward, so the focus is $p$ units above the vertex:',
        latex: '(3,\\, 2 + 2) = (3, 4)'
      }
    ],
    handbookPage: 'p. 24',
    handbookFormula: '(x-h)^2 = 4p(y-k)',
    videoUrl: null,
    traps: [
      'Using p = 8 instead of solving 4p = 8 for p = 2',
      'Reporting the vertex instead of the focus'
    ],
    diagram: null,
    lessonId: 'circles-conics',
    chapterId: 'mathematics'
  },
  {
    id: 'math-cc-cp2',
    type: 'computational',
    statement: 'An elliptical arch is described by $\\frac{x^2}{25} + \\frac{y^2}{9} = 1$. What is the distance from the center to each focus?',
    choices: [
      {
        id: 'c1',
        text: '$\\sqrt{34} \\approx 5.83$'
      },
      {
        id: 'c2',
        text: '$8$'
      },
      {
        id: 'c3',
        text: '$16$'
      },
      {
        id: 'c4',
        text: '$4$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'hard',
    eli5: 'For an ellipse, the focal distance satisfies $c^2 = a^2 - b^2$, where $a^2$ is the larger denominator. Here $a^2 = 25$ and $b^2 = 9$, so $c^2 = 25 - 9 = 16$ and $c = 4$. The value $\\sqrt{34}$ adds the denominators instead of subtracting ($\\sqrt{25 + 9}$), which is the hyperbola relationship. The value 8 gives $2c$ (the distance between the two foci). The value 16 reports $c^2$ without taking the square root.',
    hint: 'Use $c^2 = a^2 - b^2$ with $a^2$ as the larger denominator. Subtract, do not add.',
    steps: [
      {
        text: 'Identify the larger denominator: $a^2 = 25$, $b^2 = 9$.',
        latex: null
      },
      {
        text: 'Apply the ellipse focal relationship:',
        latex: 'c^2 = a^2 - b^2 = 25 - 9 = 16'
      },
      {
        text: 'Take the square root:',
        latex: 'c = \\sqrt{16} = 4'
      }
    ],
    handbookPage: 'p. 24',
    handbookFormula: 'c^2 = a^2 - b^2',
    videoUrl: null,
    traps: [
      'Adding the denominators (the hyperbola relationship) instead of subtracting',
      'Reporting c^2 = 16 without taking the square root'
    ],
    diagram: null,
    lessonId: 'circles-conics',
    chapterId: 'mathematics'
  },
  {
    id: 'math-dr-cp1',
    type: 'computational',
    statement: 'Find the derivative of $f(x) = (3x^2 + 2)^4$.',
    choices: [
      {
        id: 'c1',
        text: '$4(3x^2 + 2)^3$'
      },
      {
        id: 'c2',
        text: '$4(6x)^3$'
      },
      {
        id: 'c3',
        text: '$24x(3x^2 + 2)^3$'
      },
      {
        id: 'c4',
        text: '$12x(3x^2 + 2)^3$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'easy',
    eli5: 'The power rule combined with the chain rule: bring the 4 down, reduce the exponent to 3, then multiply by the derivative of the inside ($6x$). That gives $4(3x^2 + 2)^3 \\cdot 6x = 24x(3x^2 + 2)^3$. The form $4(3x^2+2)^3$ forgets the chain rule (the inner derivative). The form $12x(3x^2+2)^3$ uses an inner derivative of $3x$ instead of $6x$. The form $4(6x)^3$ wrongly raises the inner derivative to the third power.',
    hint: 'Power rule on the outside, then multiply by the derivative of the inside.',
    steps: [
      {
        text: 'Apply the chain rule with outer power 4 and inner $u = 3x^2 + 2$:',
        latex: "f'(x) = 4(3x^2 + 2)^3 \\cdot \\frac{d}{dx}(3x^2 + 2)"
      },
      {
        text: 'The inner derivative is $6x$:',
        latex: "f'(x) = 4(3x^2 + 2)^3 \\cdot 6x = 24x(3x^2 + 2)^3"
      }
    ],
    handbookPage: 'p. 49',
    handbookFormula: '\\frac{d}{dx}[g(x)]^n = n[g(x)]^{n-1} g\'(x)',
    videoUrl: null,
    traps: [
      'Forgetting the chain rule and omitting the factor of 6x',
      'Using an inner derivative of 3x instead of 6x'
    ],
    diagram: null,
    lessonId: 'derivatives-rules',
    chapterId: 'mathematics'
  },
  {
    id: 'math-dr-cp2',
    type: 'computational',
    statement: 'Given $f(x) = \\sqrt{4x + 1}$, what is the value of $f\'(2)$?',
    choices: [
      {
        id: 'c1',
        text: '$\\frac{2}{3}$'
      },
      {
        id: 'c2',
        text: '$\\frac{1}{6}$'
      },
      {
        id: 'c3',
        text: '$\\frac{1}{3}$'
      },
      {
        id: 'c4',
        text: '$3$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Write the root as a power: $f(x) = (4x+1)^{1/2}$. The chain rule gives $f\'(x) = \\tfrac{1}{2}(4x+1)^{-1/2} \\cdot 4 = 2/\\sqrt{4x+1}$. At $x = 2$: $\\sqrt{4(2)+1} = \\sqrt{9} = 3$, so $f\'(2) = 2/3$. The value $1/6$ forgets the chain-rule factor of 4 (giving $1/(2\\sqrt{9})$). The value $1/3$ drops the factor of 4 differently. The value 3 is $\\sqrt{4x+1}$ itself at $x = 2$, not its derivative.',
    hint: 'Rewrite the square root as a power, apply the chain rule, then evaluate at $x = 2$.',
    steps: [
      {
        text: 'Rewrite and differentiate with the chain rule:',
        latex: "f'(x) = \\frac{1}{2}(4x+1)^{-1/2} \\cdot 4 = \\frac{2}{\\sqrt{4x+1}}"
      },
      {
        text: 'Evaluate at $x = 2$:',
        latex: "f'(2) = \\frac{2}{\\sqrt{4(2)+1}} = \\frac{2}{\\sqrt{9}} = \\frac{2}{3}"
      }
    ],
    handbookPage: 'p. 49',
    handbookFormula: '\\frac{d}{dx}\\sqrt{u} = \\frac{1}{2\\sqrt{u}}\\cdot\\frac{du}{dx}',
    videoUrl: null,
    traps: [
      'Forgetting the chain-rule factor of 4 from the inner function',
      'Reporting f(2) instead of the derivative f-prime(2)'
    ],
    diagram: null,
    lessonId: 'derivatives-rules',
    chapterId: 'mathematics'
  },
  {
    id: 'math-ad-cp1',
    type: 'computational',
    statement: 'A particle moves along a line with position $s(t) = t^3 - 6t^2 + 5$ (meters, seconds). What is its acceleration at $t = 3\\,\\text{s}$?',
    choices: [
      {
        id: 'c1',
        text: '$-9\\,\\text{m/s}^2$'
      },
      {
        id: 'c2',
        text: '$0\\,\\text{m/s}^2$'
      },
      {
        id: 'c3',
        text: '$18\\,\\text{m/s}^2$'
      },
      {
        id: 'c4',
        text: '$6\\,\\text{m/s}^2$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'Acceleration is the second derivative of position. First derivative (velocity): $v(t) = 3t^2 - 12t$. Second derivative (acceleration): $a(t) = 6t - 12$. At $t = 3$: $a(3) = 18 - 12 = 6$ m/s squared. The value $-9$ is the velocity at $t = 3$ ($v(3) = 27 - 36 = -9$) — the classic mistake of stopping at the first derivative. The value 0 is the velocity at the turning point, and 18 is $6t$ without the constant.',
    hint: 'Acceleration is the second derivative of position — differentiate twice.',
    steps: [
      {
        text: 'Velocity is the first derivative:',
        latex: 'v(t) = 3t^2 - 12t'
      },
      {
        text: 'Acceleration is the second derivative:',
        latex: 'a(t) = 6t - 12'
      },
      {
        text: 'Evaluate at $t = 3$:',
        latex: 'a(3) = 6(3) - 12 = 6\\,\\text{m/s}^2'
      }
    ],
    handbookPage: 'p. 46',
    handbookFormula: 'a(t) = \\frac{d^2 s}{dt^2}',
    videoUrl: null,
    traps: [
      'Stopping at velocity (the first derivative) instead of acceleration',
      'Forgetting the constant term when differentiating -12t'
    ],
    diagram: null,
    lessonId: 'applications-derivatives',
    chapterId: 'mathematics'
  },
  {
    id: 'math-ad-cp2',
    type: 'computational',
    statement: 'A rectangular detention basin is to be fenced on three sides, with the fourth side bordering a channel. If $240\\,\\text{m}$ of fencing is available, what is the maximum enclosable area?',
    choices: [
      {
        id: 'c1',
        text: '$3{,}600\\,\\text{m}^2$'
      },
      {
        id: 'c2',
        text: '$7{,}200\\,\\text{m}^2$'
      },
      {
        id: 'c3',
        text: '$14{,}400\\,\\text{m}^2$'
      },
      {
        id: 'c4',
        text: '$4{,}800\\,\\text{m}^2$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'Let $x$ be the length of the two sides perpendicular to the channel and $y$ the side parallel to it. The fence covers three sides: $2x + y = 240$, so $y = 240 - 2x$. Area $A = xy = x(240 - 2x) = 240x - 2x^2$. Maximize: $A\' = 240 - 4x = 0$ gives $x = 60$, then $y = 240 - 120 = 120$, and $A = 60 \\times 120 = 7{,}200$ m squared. The value 3,600 uses a square assumption. The value 14,400 ignores that one side is open (treats it as $120 \\times 120$). The value 4,800 miscomputes the dimensions.',
    hint: 'Only three sides use fence: write $2x + y = 240$, express area in one variable, then set the derivative to zero.',
    steps: [
      {
        text: 'Constraint with one side open:',
        latex: '2x + y = 240 \\implies y = 240 - 2x'
      },
      {
        text: 'Area as a function of x:',
        latex: 'A(x) = x(240 - 2x) = 240x - 2x^2'
      },
      {
        text: 'Maximize by setting the derivative to zero:',
        latex: "A'(x) = 240 - 4x = 0 \\implies x = 60"
      },
      {
        text: 'Find the dimensions and area:',
        latex: 'y = 240 - 120 = 120, \\quad A = 60 \\times 120 = 7{,}200\\,\\text{m}^2'
      }
    ],
    handbookPage: 'p. 46',
    handbookFormula: "A'(x) = 0 \\text{ for the optimum}",
    videoUrl: null,
    traps: [
      'Using a four-sided perimeter constraint instead of three sides',
      'Assuming a square gives the maximum area for the three-sided case'
    ],
    diagram: null,
    lessonId: 'applications-derivatives',
    chapterId: 'mathematics'
  },
  {
    id: 'math-ic-cp1',
    type: 'computational',
    statement: 'Evaluate $\\int_0^{\\pi/2} \\sin x\\,dx$.',
    choices: [
      {
        id: 'c1',
        text: '$0$'
      },
      {
        id: 'c2',
        text: '$-1$'
      },
      {
        id: 'c3',
        text: '$1$'
      },
      {
        id: 'c4',
        text: '$\\frac{\\pi}{2}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'easy',
    eli5: 'The antiderivative of $\\sin x$ is $-\\cos x$. Evaluate from 0 to $\\pi/2$: $[-\\cos x]_0^{\\pi/2} = -\\cos(\\pi/2) - (-\\cos 0) = -0 + 1 = 1$. The value $-1$ drops the negative sign on the antiderivative (using $+\\cos x$). The value 0 comes from evaluating only at one limit. The value $\\pi/2$ confuses the integral of sine with the width of the interval.',
    hint: 'The antiderivative of $\\sin x$ is $-\\cos x$ — mind the negative sign.',
    steps: [
      {
        text: 'Find the antiderivative:',
        latex: '\\int \\sin x\\,dx = -\\cos x'
      },
      {
        text: 'Evaluate at the limits:',
        latex: '\\left[-\\cos x\\right]_0^{\\pi/2} = -\\cos\\tfrac{\\pi}{2} - (-\\cos 0) = 0 + 1 = 1'
      }
    ],
    handbookPage: 'p. 50',
    handbookFormula: '\\int \\sin x\\,dx = -\\cos x + C',
    videoUrl: null,
    traps: [
      'Using +cos x as the antiderivative and getting -1',
      'Forgetting to evaluate at both limits'
    ],
    diagram: null,
    lessonId: 'integral-calculus',
    chapterId: 'mathematics'
  },
  {
    id: 'math-ic-cp2',
    type: 'computational',
    statement: 'What is the area of the region enclosed between the curves $y = 2x$ and $y = x^2$?',
    choices: [
      {
        id: 'c1',
        text: '$\\frac{4}{3}$'
      },
      {
        id: 'c2',
        text: '$\\frac{8}{3}$'
      },
      {
        id: 'c3',
        text: '$4$'
      },
      {
        id: 'c4',
        text: '$\\frac{2}{3}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'First find where the curves cross: $2x = x^2$ gives $x = 0$ and $x = 2$. Between them the line $2x$ is on top, so integrate (top minus bottom): $\\int_0^2 (2x - x^2)\\,dx = [x^2 - x^3/3]_0^2 = 4 - 8/3 = 4/3$. The value $8/3$ integrates $2x$ alone (the area under the line, not between the curves). The value 4 is the area under the line only without subtracting. The value $2/3$ integrates $x^2$ alone.',
    hint: 'Find the intersection points, then integrate (upper curve minus lower curve) between them.',
    steps: [
      {
        text: 'Find the intersection points:',
        latex: '2x = x^2 \\implies x = 0,\\ x = 2'
      },
      {
        text: 'Integrate the top curve minus the bottom curve:',
        latex: '\\int_0^2 (2x - x^2)\\,dx = \\left[x^2 - \\frac{x^3}{3}\\right]_0^2'
      },
      {
        text: 'Evaluate:',
        latex: '\\left(4 - \\frac{8}{3}\\right) - 0 = \\frac{4}{3}'
      }
    ],
    handbookPage: 'p. 50',
    handbookFormula: 'A = \\int_a^b [f(x) - g(x)]\\,dx',
    videoUrl: null,
    traps: [
      'Integrating only one curve instead of the difference',
      'Getting the intersection limits wrong'
    ],
    diagram: null,
    lessonId: 'integral-calculus',
    chapterId: 'mathematics'
  },
  {
    id: 'math-lr-cp1',
    type: 'computational',
    statement: 'Evaluate $\\lim_{x \\to 0}\\frac{e^{2x} - 1}{\\sin 3x}$.',
    choices: [
      {
        id: 'c1',
        text: '$\\frac{3}{2}$'
      },
      {
        id: 'c2',
        text: '$1$'
      },
      {
        id: 'c3',
        text: '$0$'
      },
      {
        id: 'c4',
        text: '$\\frac{2}{3}$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'Direct substitution gives $(1 - 1)/0 = 0/0$, an indeterminate form, so apply L\'Hopital\'s. Differentiate top and bottom: the top becomes $2e^{2x}$ and the bottom becomes $3\\cos 3x$. Now substitute $x = 0$: $2e^0 / (3\\cos 0) = 2(1)/(3(1)) = 2/3$. The value $3/2$ inverts the ratio. The value 1 forgets the chain-rule factors of 2 and 3. The value 0 wrongly evaluates before differentiating.',
    hint: 'It is $0/0$ — differentiate numerator and denominator, keeping the chain-rule factors.',
    steps: [
      {
        text: 'Direct substitution gives $0/0$. Apply L\'Hopital\'s:',
        latex: '\\lim_{x \\to 0}\\frac{2e^{2x}}{3\\cos 3x}'
      },
      {
        text: 'Evaluate at $x = 0$:',
        latex: '\\frac{2e^0}{3\\cos 0} = \\frac{2(1)}{3(1)} = \\frac{2}{3}'
      }
    ],
    handbookPage: 'p. 48',
    handbookFormula: "\\lim_{x \\to a}\\frac{f(x)}{g(x)} = \\lim_{x \\to a}\\frac{f'(x)}{g'(x)}",
    videoUrl: null,
    traps: [
      'Dropping the chain-rule factors of 2 and 3 when differentiating',
      'Inverting the ratio to get 3/2'
    ],
    diagram: null,
    lessonId: 'lhopitals-rule',
    chapterId: 'mathematics'
  },
  {
    id: 'math-lr-cp2',
    type: 'computational',
    statement: 'Evaluate $\\lim_{x \\to \\infty}\\frac{\\ln x}{\\sqrt{x}}$.',
    choices: [
      {
        id: 'c1',
        text: '$\\infty$'
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
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'As $x \\to \\infty$ both top and bottom go to infinity, so it is $\\infty/\\infty$ and L\'Hopital\'s applies. Derivative of $\\ln x$ is $1/x$; derivative of $\\sqrt{x} = x^{1/2}$ is $\\tfrac{1}{2}x^{-1/2}$. The ratio is $(1/x)/(\\tfrac{1}{2}x^{-1/2}) = \\tfrac{2}{\\sqrt{x}}$, which goes to 0 as $x \\to \\infty$. Any positive power of $x$ eventually beats $\\ln x$. The value $\\infty$ assumes the log wins (it does not). The value $1/2$ is the leftover coefficient without the limit.',
    hint: 'This is $\\infty/\\infty$. After one application, simplify the algebra and take the limit — roots beat logs.',
    steps: [
      {
        text: 'Form is $\\infty/\\infty$. Apply L\'Hopital\'s:',
        latex: '\\lim_{x \\to \\infty}\\frac{1/x}{\\tfrac{1}{2}x^{-1/2}}'
      },
      {
        text: 'Simplify the complex fraction:',
        latex: '= \\lim_{x \\to \\infty}\\frac{2}{\\sqrt{x}}'
      },
      {
        text: 'Evaluate the limit:',
        latex: '\\frac{2}{\\sqrt{\\infty}} = 0'
      }
    ],
    handbookPage: 'p. 48',
    handbookFormula: "\\lim_{x \\to a}\\frac{f(x)}{g(x)} = \\lim_{x \\to a}\\frac{f'(x)}{g'(x)}",
    videoUrl: null,
    traps: [
      'Assuming the logarithm grows faster than the square root',
      'Mishandling the derivative of the square root in the denominator'
    ],
    diagram: null,
    lessonId: 'lhopitals-rule',
    chapterId: 'mathematics'
  },
  {
    id: 'math-vbu-cp1',
    type: 'computational',
    statement: 'A force vector is $\\vec{A} = 4\\hat{i} - 4\\hat{j} + 2\\hat{k}$. What is the direction cosine $\\cos\\beta$ (the cosine of the angle between $\\vec{A}$ and the $y$-axis)?',
    choices: [
      {
        id: 'c1',
        text: '$\\frac{2}{3}$'
      },
      {
        id: 'c2',
        text: '$-\\frac{4}{9}$'
      },
      {
        id: 'c3',
        text: '$-\\frac{2}{3}$'
      },
      {
        id: 'c4',
        text: '$\\frac{1}{3}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'A direction cosine is a component divided by the vector magnitude: $\\cos\\beta = A_y / |\\vec{A}|$. The magnitude is $\\sqrt{4^2 + (-4)^2 + 2^2} = \\sqrt{16 + 16 + 4} = \\sqrt{36} = 6$. So $\\cos\\beta = -4/6 = -2/3$. The negative sign carries through because $A_y$ is negative. The value $+2/3$ drops that sign. The value $-4/9$ divides by the squared magnitude (36) by mistake. The value $1/3$ uses the $z$-component instead of the $y$-component.',
    hint: 'A direction cosine is the relevant component divided by the magnitude. Keep the sign of the component.',
    steps: [
      {
        text: 'Compute the magnitude:',
        latex: '|\\vec{A}| = \\sqrt{4^2 + (-4)^2 + 2^2} = \\sqrt{36} = 6'
      },
      {
        text: 'Direction cosine with the y-axis uses the y-component:',
        latex: '\\cos\\beta = \\frac{A_y}{|\\vec{A}|} = \\frac{-4}{6} = -\\frac{2}{3}'
      }
    ],
    handbookPage: 'p. 55',
    handbookFormula: '\\cos\\beta = \\frac{A_y}{|\\vec{A}|}',
    videoUrl: null,
    traps: [
      'Dropping the negative sign of the y-component',
      'Dividing by the squared magnitude instead of the magnitude'
    ],
    diagram: null,
    lessonId: 'vector-basics-unit-vectors',
    chapterId: 'mathematics'
  },
  {
    id: 'math-vbu-cp2',
    type: 'computational',
    statement: 'Two forces act at a joint: $\\vec{A} = 3\\hat{i} - 2\\hat{j} + 6\\hat{k}$ N and $\\vec{B} = 1\\hat{i} + 4\\hat{j} - 2\\hat{k}$ N. What is the magnitude of the resultant force $\\vec{A} + \\vec{B}$?',
    choices: [
      {
        id: 'c1',
        text: '$6\\,\\text{N}$'
      },
      {
        id: 'c2',
        text: '$10\\,\\text{N}$'
      },
      {
        id: 'c3',
        text: '$36\\,\\text{N}$'
      },
      {
        id: 'c4',
        text: '$8.5\\,\\text{N}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Add the vectors component by component first: $\\vec{A} + \\vec{B} = (3+1)\\hat{i} + (-2+4)\\hat{j} + (6-2)\\hat{k} = 4\\hat{i} + 2\\hat{j} + 4\\hat{k}$. Then take the magnitude: $\\sqrt{4^2 + 2^2 + 4^2} = \\sqrt{16 + 4 + 16} = \\sqrt{36} = 6$ N. The value 10 adds the individual magnitudes ($|\\vec{A}| = 7$, $|\\vec{B}| \\approx 4.6$) — magnitudes do not add directly. The value 36 forgets the square root. The value 8.5 adds magnitudes another way.',
    hint: 'Add components first to get the resultant, then take its magnitude — do not add magnitudes directly.',
    steps: [
      {
        text: 'Add the vectors component by component:',
        latex: '\\vec{A} + \\vec{B} = 4\\hat{i} + 2\\hat{j} + 4\\hat{k}'
      },
      {
        text: 'Take the magnitude of the resultant:',
        latex: '|\\vec{A} + \\vec{B}| = \\sqrt{4^2 + 2^2 + 4^2} = \\sqrt{36} = 6\\,\\text{N}'
      }
    ],
    handbookPage: 'p. 55',
    handbookFormula: '|\\vec{R}| = \\sqrt{R_x^2 + R_y^2 + R_z^2}',
    videoUrl: null,
    traps: [
      'Adding the individual magnitudes instead of adding components first',
      'Forgetting to take the square root of the sum of squares'
    ],
    diagram: null,
    lessonId: 'vector-basics-unit-vectors',
    chapterId: 'mathematics'
  },
  {
    id: 'math-dpa-cp1',
    type: 'computational',
    statement: 'A constant force $\\vec{F} = 40\\hat{i} - 20\\hat{j} + 10\\hat{k}$ N moves an object through a displacement $\\vec{d} = 2\\hat{i} + 3\\hat{j} - 1\\hat{k}$ m. How much work is done?',
    choices: [
      {
        id: 'c1',
        text: '$130\\,\\text{J}$'
      },
      {
        id: 'c2',
        text: '$150\\,\\text{J}$'
      },
      {
        id: 'c3',
        text: '$80\\,\\text{J}$'
      },
      {
        id: 'c4',
        text: '$10\\,\\text{J}$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'Work is the dot product of force and displacement: $W = \\vec{F} \\cdot \\vec{d} = (40)(2) + (-20)(3) + (10)(-1) = 80 - 60 - 10 = 10$ J. The negative products from the opposing components reduce the total. The value 130 mishandles the signs. The value 150 keeps everything positive ($80 + 60 + 10$). The value 80 uses only the first term.',
    hint: 'Work equals the dot product of force and displacement — keep every sign.',
    steps: [
      {
        text: 'Apply the dot product:',
        latex: 'W = \\vec{F} \\cdot \\vec{d} = (40)(2) + (-20)(3) + (10)(-1)'
      },
      {
        text: 'Compute each term and sum:',
        latex: 'W = 80 - 60 - 10 = 10\\,\\text{J}'
      }
    ],
    handbookPage: 'p. 55',
    handbookFormula: 'W = \\vec{F} \\cdot \\vec{d} = F_x d_x + F_y d_y + F_z d_z',
    videoUrl: null,
    traps: [
      'Treating all products as positive and ignoring the opposing signs',
      'Adding the products of mismatched components'
    ],
    diagram: null,
    lessonId: 'dot-product-angle',
    chapterId: 'mathematics'
  },
  {
    id: 'math-dpa-cp2',
    type: 'computational',
    statement: 'What is the vector projection of $\\vec{a} = 3\\hat{i} + 3\\hat{j} + 3\\hat{k}$ onto $\\vec{b} = 2\\hat{i} - 1\\hat{j} + 2\\hat{k}$?',
    choices: [
      {
        id: 'c1',
        text: '$6\\hat{i} - 3\\hat{j} + 6\\hat{k}$'
      },
      {
        id: 'c2',
        text: '$2\\hat{i} - 1\\hat{j} + 2\\hat{k}$'
      },
      {
        id: 'c3',
        text: '$3\\hat{i} + 3\\hat{j} + 3\\hat{k}$'
      },
      {
        id: 'c4',
        text: '$\\frac{9}{27}(2\\hat{i} - 1\\hat{j} + 2\\hat{k})$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'hard',
    eli5: 'The vector projection is $\\text{proj}_{\\vec{b}}\\vec{a} = \\frac{\\vec{a}\\cdot\\vec{b}}{|\\vec{b}|^2}\\vec{b}$. The dot product is $(3)(2) + (3)(-1) + (3)(2) = 6 - 3 + 6 = 9$. The squared magnitude is $|\\vec{b}|^2 = 2^2 + (-1)^2 + 2^2 = 9$. So the scalar coefficient is $9/9 = 1$, giving $1 \\cdot \\vec{b} = 2\\hat{i} - 1\\hat{j} + 2\\hat{k}$. The choice $6\\hat{i}-3\\hat{j}+6\\hat{k}$ forgets to divide and just scales $\\vec{b}$ by 3. The choice $3\\hat{i}+3\\hat{j}+3\\hat{k}$ is just $\\vec{a}$. The last choice divides by $3^3 = 27$ instead of $|\\vec{b}|^2 = 9$.',
    hint: 'Vector projection = (a dot b)/|b|^2 times b. Compute the scalar coefficient first.',
    steps: [
      {
        text: 'Compute the dot product:',
        latex: '\\vec{a}\\cdot\\vec{b} = (3)(2) + (3)(-1) + (3)(2) = 9'
      },
      {
        text: 'Compute the squared magnitude of b:',
        latex: '|\\vec{b}|^2 = 2^2 + (-1)^2 + 2^2 = 9'
      },
      {
        text: 'Form the projection:',
        latex: '\\text{proj}_{\\vec{b}}\\vec{a} = \\frac{9}{9}\\,\\vec{b} = 2\\hat{i} - 1\\hat{j} + 2\\hat{k}'
      }
    ],
    handbookPage: 'p. 55',
    handbookFormula: '\\text{proj}_{\\vec{b}}\\vec{a} = \\frac{\\vec{a}\\cdot\\vec{b}}{|\\vec{b}|^2}\\,\\vec{b}',
    videoUrl: null,
    traps: [
      'Dividing by |b| instead of |b| squared',
      'Returning the scalar projection or the original vector a instead of the vector projection'
    ],
    diagram: null,
    lessonId: 'dot-product-angle',
    chapterId: 'mathematics'
  },
  {
    id: 'math-cpa-cp1',
    type: 'computational',
    statement: 'Compute $\\vec{A} \\times \\vec{B}$ where $\\vec{A} = 1\\hat{i} + 2\\hat{j} + 3\\hat{k}$ and $\\vec{B} = 4\\hat{i} + 5\\hat{j} + 6\\hat{k}$.',
    choices: [
      {
        id: 'c1',
        text: '$-3\\hat{i} + 6\\hat{j} - 3\\hat{k}$'
      },
      {
        id: 'c2',
        text: '$3\\hat{i} - 6\\hat{j} + 3\\hat{k}$'
      },
      {
        id: 'c3',
        text: '$-3\\hat{i} - 6\\hat{j} - 3\\hat{k}$'
      },
      {
        id: 'c4',
        text: '$4\\hat{i} + 10\\hat{j} + 18\\hat{k}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Set up the determinant with $\\hat{i}, \\hat{j}, \\hat{k}$ on top. The $\\hat{i}$ term: $(2)(6) - (3)(5) = 12 - 15 = -3$. The $\\hat{j}$ term: $-[(1)(6) - (3)(4)] = -[6 - 12] = +6$. The $\\hat{k}$ term: $(1)(5) - (2)(4) = 5 - 8 = -3$. Result: $-3\\hat{i} + 6\\hat{j} - 3\\hat{k}$. The reversed-sign choice is $\\vec{B} \\times \\vec{A}$. The choice $-3\\hat{i}-6\\hat{j}-3\\hat{k}$ forgets the negative on the $\\hat{j}$ cofactor. The choice $4\\hat{i}+10\\hat{j}+18\\hat{k}$ multiplies components directly (not a cross product).',
    hint: 'Use the determinant expansion and remember the middle ($\\hat{j}$) term carries a minus sign.',
    steps: [
      {
        text: 'Set up the determinant:',
        latex: '\\vec{A} \\times \\vec{B} = \\begin{vmatrix} \\hat{i} & \\hat{j} & \\hat{k} \\\\ 1 & 2 & 3 \\\\ 4 & 5 & 6 \\end{vmatrix}'
      },
      {
        text: 'Expand each cofactor:',
        latex: '\\hat{i}[(2)(6)-(3)(5)] - \\hat{j}[(1)(6)-(3)(4)] + \\hat{k}[(1)(5)-(2)(4)]'
      },
      {
        text: 'Compute:',
        latex: '= -3\\hat{i} + 6\\hat{j} - 3\\hat{k}'
      }
    ],
    handbookPage: 'p. 55',
    handbookFormula: '\\vec{A} \\times \\vec{B} = \\begin{vmatrix} \\hat{i} & \\hat{j} & \\hat{k} \\\\ A_x & A_y & A_z \\\\ B_x & B_y & B_z \\end{vmatrix}',
    videoUrl: null,
    traps: [
      'Forgetting the negative sign on the j cofactor',
      'Multiplying matching components instead of taking the cross product'
    ],
    diagram: null,
    lessonId: 'cross-product-applications',
    chapterId: 'mathematics'
  },
  {
    id: 'math-cpa-cp2',
    type: 'computational',
    statement: 'Two adjacent edges of a parallelogram-shaped plate are $\\vec{A} = 3\\hat{i} + 0\\hat{j} + 4\\hat{k}$ m and $\\vec{B} = 0\\hat{i} + 5\\hat{j} + 0\\hat{k}$ m. What is the area of the parallelogram?',
    choices: [
      {
        id: 'c1',
        text: '$12.5\\,\\text{m}^2$'
      },
      {
        id: 'c2',
        text: '$15\\,\\text{m}^2$'
      },
      {
        id: 'c3',
        text: '$20\\,\\text{m}^2$'
      },
      {
        id: 'c4',
        text: '$25\\,\\text{m}^2$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'medium',
    eli5: 'The parallelogram area is the magnitude of the cross product. Cross product: $\\hat{i}[(0)(0)-(4)(5)] - \\hat{j}[(3)(0)-(4)(0)] + \\hat{k}[(3)(5)-(0)(0)] = -20\\hat{i} + 0\\hat{j} + 15\\hat{k}$. Magnitude: $\\sqrt{(-20)^2 + 0 + 15^2} = \\sqrt{400 + 225} = \\sqrt{625} = 25$ m squared. The value 12.5 halves it (that would be the triangle area). The value 15 uses only the $\\hat{k}$ component. The value 20 keeps only the $\\hat{i}$ contribution incorrectly.',
    hint: 'Parallelogram area is the magnitude of the cross product — do not halve it.',
    steps: [
      {
        text: 'Compute the cross product:',
        latex: '\\vec{A} \\times \\vec{B} = -20\\hat{i} + 0\\hat{j} + 15\\hat{k}'
      },
      {
        text: 'Take the magnitude:',
        latex: '|\\vec{A} \\times \\vec{B}| = \\sqrt{(-20)^2 + 15^2} = \\sqrt{625} = 25\\,\\text{m}^2'
      }
    ],
    handbookPage: 'p. 55',
    handbookFormula: 'A_{parallelogram} = |\\vec{A} \\times \\vec{B}|',
    videoUrl: null,
    traps: [
      'Halving the result (that gives the triangle area, not the parallelogram)',
      'Keeping only one component of the cross product before taking the magnitude'
    ],
    diagram: null,
    lessonId: 'cross-product-applications',
    chapterId: 'mathematics'
  }
];

export default PROBLEMS;
