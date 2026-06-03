// Exam bank: water-resources
// Auto-extracted from lesson files — 36 questions

const PROBLEMS = [
  {
    id: 'wr-ocf-ex1',
    type: 'conceptual',
    statement: 'Manning\'s equation uses the factor $K = 1.486$ in US Customary units and $K = 1.0$ in SI units. What happens to the computed discharge if an engineer accidentally uses $K = 1.0$ with US Customary inputs?',
    choices: [
      {
        id: 'c1',
        text: 'The discharge is overestimated by about 49%'
      },
      {
        id: 'c2',
        text: 'The discharge is underestimated by about 33%'
      },
      {
        id: 'c3',
        text: 'The discharge is unaffected because units cancel'
      },
      {
        id: 'c4',
        text: 'The discharge is underestimated by about 50%'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'If you use $K = 1.0$ instead of 1.486, you get $Q_{wrong} = Q_{correct}/1.486$, which means your answer is about 67% of the correct value. That is an underestimate of about 33%. This is a classic FE trap because forgetting the conversion factor does not produce an obviously wrong answer. Choice A reverses the direction of the error. Choice C ignores the factor entirely. Choice D confuses the percentage.',
    hint: 'Compare $Q$ with $K = 1.0$ to $Q$ with $K = 1.486$. The ratio tells you how far off you are.',
    steps: [
      {
        text: 'Correct discharge uses $K = 1.486$:',
        latex: 'Q_{correct} = \\frac{1.486}{n} A R_H^{2/3} S^{1/2}'
      },
      {
        text: 'Wrong discharge uses $K = 1.0$:',
        latex: 'Q_{wrong} = \\frac{1.0}{n} A R_H^{2/3} S^{1/2}'
      },
      {
        text: 'Ratio:',
        latex: '\\frac{Q_{wrong}}{Q_{correct}} = \\frac{1.0}{1.486} = 0.673'
      },
      {
        text: 'The error is about $1 - 0.673 = 0.327 \\approx 33\\%$ underestimate.',
        latex: null
      }
    ],
    handbookPage: 'p. 297',
    handbookFormula: 'Q = \\frac{K}{n} A R_H^{2/3} S^{1/2}',
    videoUrl: null,
    traps: ['Thinking the units cancel out automatically', 'Confusing underestimate with overestimate'],
    diagram: null,
    lessonId: 'open-channel-flow',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-ocf-ex2',
    type: 'computational',
    statement: 'A trapezoidal earth channel ($n = 0.022$) has a bottom width of $b = 3\\,\\text{m}$, side slopes of 2H:1V, and a flow depth of $y = 1.5\\,\\text{m}$ on a slope of $S = 0.0004$. What is the discharge?',
    choices: [
      {
        id: 'c1',
        text: '$3.2\\,\\text{m}^3/\\text{s}$'
      },
      {
        id: 'c2',
        text: '$7.1\\,\\text{m}^3/\\text{s}$'
      },
      {
        id: 'c3',
        text: '$7.8\\,\\text{m}^3/\\text{s}$'
      },
      {
        id: 'c4',
        text: '$9.5\\,\\text{m}^3/\\text{s}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'For a trapezoid with 2:1 side slopes: $A = (b + zy)y = (3 + 2 \\times 1.5)(1.5) = 6 \\times 1.5 = 9.0$ m$^2$. $P = b + 2y\\sqrt{1 + z^2} = 3 + 2(1.5)\\sqrt{1 + 4} = 3 + 3\\sqrt{5} = 3 + 6.708 = 9.708$ m. $R_H = 9.0/9.708 = 0.927$ m. SI units so $K = 1.0$. $Q = (1/0.022)(9.0)(0.927)^{2/3}(0.0004)^{1/2} = 45.45 \\times 9.0 \\times 0.951 \\times 0.02 = 7.8$ m$^3$/s. Choice A omits the side slopes from the area. Choice B uses $K = 1.486$ (wrong for SI). Choice D uses the bottom width alone for the wetted perimeter.',
    hint: 'For a trapezoid: $A = (b + zy)y$ and $P = b + 2y\\sqrt{1+z^2}$. Use $K = 1.0$ for SI.',
    steps: [
      {
        text: 'Flow area (trapezoid, $z = 2$):',
        latex: 'A = (b + zy)y = (3 + 2 \\times 1.5)(1.5) = 6 \\times 1.5 = 9.0\\,\\text{m}^2'
      },
      {
        text: 'Wetted perimeter:',
        latex: 'P = b + 2y\\sqrt{1+z^2} = 3 + 2(1.5)\\sqrt{5} = 3 + 6.708 = 9.708\\,\\text{m}'
      },
      {
        text: 'Hydraulic radius:',
        latex: 'R_H = \\frac{9.0}{9.708} = 0.927\\,\\text{m}'
      },
      {
        text: 'Manning\'s equation (SI, $K = 1.0$):',
        latex: 'Q = \\frac{1.0}{0.022}(9.0)(0.927)^{2/3}(0.0004)^{1/2}'
      },
      {
        text: 'Compute:',
        latex: 'Q = 45.45 \\times 9.0 \\times 0.951 \\times 0.02 = 7.8\\,\\text{m}^3/\\text{s}'
      }
    ],
    handbookPage: 'p. 297',
    handbookFormula: 'Q = \\frac{K}{n} A R_H^{2/3} S^{1/2}',
    videoUrl: null,
    traps: [
      'Forgetting to include the side slopes when computing area and wetted perimeter',
      'Using K = 1.486 with SI units'
    ],
    diagram: {
      component: 'TrapezoidalChannel',
      props: {
        b: 3,
        y: 1.5,
        z: 2,
        unit: 'm'
      }
    },
    lessonId: 'open-channel-flow',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-ocf-ex3',
    type: 'conceptual',
    statement: 'For a circular storm sewer flowing completely full, the hydraulic radius $R_H$ equals:',
    choices: [
      {
        id: 'c1',
        text: '$D/2$'
      },
      {
        id: 'c2',
        text: '$D/4$'
      },
      {
        id: 'c3',
        text: '$D$'
      },
      {
        id: 'c4',
        text: '$\\pi D/4$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: '$R_H = A/P$. For a full circle: $A = \\pi D^2/4$ and $P = \\pi D$. So $R_H = (\\pi D^2/4)/(\\pi D) = D/4$. Many students pick $D/2$ because they confuse hydraulic radius with the geometric radius. The hydraulic radius is area divided by wetted perimeter, not the pipe radius. Choice A is the geometric radius. Choice C is the diameter itself. Choice D is the area divided by $D$, not by $\\pi D$.',
    hint: 'Hydraulic radius = $A/P$. For a full pipe, $A = \\pi D^2/4$ and $P = \\pi D$.',
    steps: [
      {
        text: 'Full pipe area:',
        latex: 'A = \\frac{\\pi D^2}{4}'
      },
      {
        text: 'Full pipe wetted perimeter:',
        latex: 'P = \\pi D'
      },
      {
        text: 'Hydraulic radius:',
        latex: 'R_H = \\frac{A}{P} = \\frac{\\pi D^2/4}{\\pi D} = \\frac{D}{4}'
      }
    ],
    handbookPage: 'p. 297',
    handbookFormula: 'R_H = \\frac{A}{P}',
    videoUrl: null,
    traps: ['Confusing hydraulic radius (D/4) with geometric radius (D/2)'],
    diagram: null,
    lessonId: 'open-channel-flow',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-ocf-ex4',
    type: 'computational',
    statement: 'A rectangular concrete channel ($n = 0.013$) must carry $Q = 50\\,\\text{ft}^3/\\text{s}$ on a slope of $S = 0.0009$. If the channel is $6\\,\\text{ft}$ wide, what is the approximate normal depth?',
    choices: [
      {
        id: 'c1',
        text: '2.1 ft'
      },
      {
        id: 'c2',
        text: '1.6 ft'
      },
      {
        id: 'c3',
        text: '3.1 ft'
      },
      {
        id: 'c4',
        text: '4.0 ft'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'This requires trial and error. Manning\'s: $Q = (1.486/n)\\,A\\,R_H^{2/3}\\,S^{1/2}$. Try $y = 2.1$ ft: $A = 6 \\times 2.1 = 12.6$ ft$^2$, $P = 6 + 2(2.1) = 10.2$ ft, $R_H = 12.6/10.2 = 1.235$ ft. $Q = (1.486/0.013)(12.6)(1.235)^{2/3}(0.0009)^{1/2} = 114.3 \\times 12.6 \\times 1.151 \\times 0.03 = 49.8$ cfs. That is essentially 50 cfs, so the normal depth is approximately 2.1 ft. Choice B underestimates by using $K = 1.0$ instead of 1.486. Choice C overestimates area. Choice D assumes $R_H = y$.',
    hint: 'Set up Manning\'s equation and solve for depth by trial. Remember $K = 1.486$ for USCS.',
    steps: [
      {
        text: 'Manning\'s equation rearranged:',
        latex: '50 = \\frac{1.486}{0.013}(6y)\\left(\\frac{6y}{6+2y}\\right)^{2/3}(0.0009)^{1/2}'
      },
      {
        text: 'Simplify constants:',
        latex: '50 = 114.3 \\times 0.03 \\times 6y \\left(\\frac{6y}{6+2y}\\right)^{2/3} = 3.429 \\times 6y \\left(\\frac{6y}{6+2y}\\right)^{2/3}'
      },
      {
        text: 'Trial at $y = 2.0$ ft:',
        latex: 'A = 12.0,\\; R_H = \\frac{12.0}{10.0} = 1.200,\\; Q = 3.429 \\times 12.0 \\times 1.129 = 46.5'
      },
      {
        text: 'Trial at $y = 2.1$ ft:',
        latex: 'A = 12.6,\\; R_H = \\frac{12.6}{10.2} = 1.235,\\; Q = 3.429 \\times 12.6 \\times 1.151 = 49.8'
      },
      {
        text: 'At $y = 2.1$ ft, $Q \\approx 50$ cfs. Normal depth $\\approx 2.1\\,\\text{ft}$.',
        latex: null
      }
    ],
    handbookPage: 'p. 297',
    handbookFormula: 'Q = \\frac{K}{n} A R_H^{2/3} S^{1/2}',
    videoUrl: null,
    traps: [
      'Forgetting the USCS factor $K = 1.486$ shifts the answer significantly',
      'Assuming $R_H$ equals the depth $y$ instead of computing $A/P$'
    ],
    diagram: {
      component: 'RectangularChannel',
      props: {
        b: 6,
        y: 2.1,
        unit: 'ft'
      }
    },
    lessonId: 'open-channel-flow',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-ecf-ex1',
    type: 'computational',
    statement: 'A rectangular channel is 3 m wide with a flow rate of $12\\,\\text{m}^3/\\text{s}$. What is the critical depth?',
    choices: [
      {
        id: 'c1',
        text: '0.87 m'
      },
      {
        id: 'c2',
        text: '1.18 m'
      },
      {
        id: 'c3',
        text: '1.54 m'
      },
      {
        id: 'c4',
        text: '2.04 m'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'For a rectangular channel, critical depth is $y_c = (q^2/g)^{1/3}$ where $q = Q/b$ is the unit discharge. $q = 12/3 = 4$ m$^2$/s. $y_c = (16/9.81)^{1/3} = (1.631)^{1/3} = 1.18$ m. The trap is using $Q$ instead of $q$ (forgetting to divide by width).',
    hint: 'Use $y_c = (q^2/g)^{1/3}$ where $q = Q/b$.',
    steps: [
      {
        text: 'Unit discharge:',
        latex: 'q = \\frac{Q}{b} = \\frac{12}{3} = 4\\,\\text{m}^2/\\text{s}'
      },
      {
        text: 'Critical depth for rectangular channel:',
        latex: 'y_c = \\left(\\frac{q^2}{g}\\right)^{1/3} = \\left(\\frac{16}{9.81}\\right)^{1/3}'
      },
      {
        text: 'Calculate:',
        latex: 'y_c = (1.631)^{1/3} = 1.18\\,\\text{m}'
      }
    ],
    handbookPage: 'p. 289',
    handbookFormula: 'y_c = \\left(\\frac{q^2}{g}\\right)^{1/3}',
    videoUrl: null,
    traps: ['Using total discharge $Q$ instead of unit discharge $q$', 'Forgetting to take the cube root'],
    diagram: null,
    lessonId: 'energy-critical-flow',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-ecf-ex2',
    type: 'conceptual',
    statement: 'At critical flow conditions in an open channel, the Froude number equals:',
    choices: [
      {
        id: 'c1',
        text: '0'
      },
      {
        id: 'c2',
        text: '0.5'
      },
      {
        id: 'c3',
        text: '1.0'
      },
      {
        id: 'c4',
        text: 'Greater than 1.0'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'easy',
    eli5: 'The Froude number is the ratio of flow velocity to wave speed. At critical flow, $Fr = 1$ exactly. $Fr < 1$ is subcritical (tranquil) flow. $Fr > 1$ is supercritical (rapid) flow. This is one of those definitions you just need to know -- it shows up frequently on the FE.',
    hint: 'Recall the definition of the Froude number and what critical flow means.',
    steps: [
      {
        text: 'The Froude number:',
        latex: 'Fr = \\frac{V}{\\sqrt{gy}}'
      },
      {
        text: 'At critical flow, by definition, $Fr = 1.0$.',
        latex: null
      },
      {
        text: 'This means the flow velocity equals the wave propagation speed.',
        latex: null
      }
    ],
    handbookPage: 'p. 289',
    handbookFormula: 'Fr = \\frac{V}{\\sqrt{gy}}',
    videoUrl: null,
    traps: ['Confusing Froude number with Reynolds number'],
    diagram: null,
    lessonId: 'energy-critical-flow',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-ecf-ex3',
    type: 'computational',
    statement: 'A hydraulic jump forms in a rectangular channel. The upstream supercritical depth is $y_1 = 0.3\\,\\text{m}$ and the upstream Froude number is $Fr_1 = 4.0$. What is the conjugate (downstream) depth $y_2$?',
    choices: [
      {
        id: 'c1',
        text: '1.20 m'
      },
      {
        id: 'c2',
        text: '1.55 m'
      },
      {
        id: 'c3',
        text: '3.60 m'
      },
      {
        id: 'c4',
        text: '0.85 m'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Use the conjugate depth formula: $y_2 = (y_1/2)(-1 + \\sqrt{1 + 8Fr_1^2}) = (0.3/2)(-1 + \\sqrt{1 + 8 \\times 16}) = 0.15 \\times (-1 + \\sqrt{129}) = 0.15 \\times (-1 + 11.36) = 0.15 \\times 10.36 = 1.55$ m. The downstream subcritical depth is about 5 times the upstream depth. Choice A uses $Fr_1 = 3$ instead of 4. Choice C multiplies $y_1$ by $Fr_1^2$ directly. Choice D forgets the factor of 8 inside the radical.',
    hint: 'Use $y_2 = \\frac{y_1}{2}\\left(-1 + \\sqrt{1 + 8Fr_1^2}\\right)$ and plug in directly.',
    steps: [
      {
        text: 'Conjugate depth formula:',
        latex: 'y_2 = \\frac{y_1}{2}\\left(-1 + \\sqrt{1 + 8Fr_1^2}\\right)'
      },
      {
        text: 'Substitute values:',
        latex: 'y_2 = \\frac{0.3}{2}\\left(-1 + \\sqrt{1 + 8(4.0)^2}\\right)'
      },
      {
        text: 'Simplify inside the radical:',
        latex: 'y_2 = 0.15\\left(-1 + \\sqrt{1 + 128}\\right) = 0.15\\left(-1 + \\sqrt{129}\\right)'
      },
      {
        text: 'Compute:',
        latex: 'y_2 = 0.15(-1 + 11.36) = 0.15 \\times 10.36 = 1.55\\,\\text{m}'
      }
    ],
    handbookPage: 'p. 297',
    handbookFormula: 'y_2 = \\frac{y_1}{2}\\left(-1 + \\sqrt{1 + 8Fr_1^2}\\right)',
    videoUrl: null,
    traps: [
      'Omitting the factor of 8 multiplying $Fr^2$ inside the radical',
      'Forgetting the $-1$ term inside the parentheses'
    ],
    diagram: {
      component: 'HydraulicJump',
      props: {
        y1: 0.3,
        Fr1: 4
      }
    },
    lessonId: 'energy-critical-flow',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-ecf-ex4',
    type: 'conceptual',
    statement: 'In a rectangular open channel, flow transitions from subcritical to supercritical. Which of the following best describes what happens to the specific energy and depth?',
    choices: [
      {
        id: 'c1',
        text: 'Specific energy decreases to a minimum at critical depth, then increases as depth continues to decrease'
      },
      {
        id: 'c2',
        text: 'Specific energy increases continuously as depth decreases'
      },
      {
        id: 'c3',
        text: 'Specific energy stays constant while the Froude number increases past 1'
      },
      {
        id: 'c4',
        text: 'Depth increases past critical depth while velocity decreases'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'The specific energy diagram is a curve with two branches. As you move from subcritical (deep, slow) toward critical depth, the specific energy drops to a minimum. If the flow continues to supercritical (shallow, fast), the kinetic energy term grows rapidly and E increases again. So there is a minimum at the critical point. Choice B ignores the minimum and says it only goes up. Choice C describes a transition at constant energy, which would mean the channel changes between two alternate depths, not a smooth transition. Choice D describes the wrong direction of change.',
    hint: 'Think about the specific energy diagram: it has an upper limb (subcritical), a lower limb (supercritical), and a minimum at critical depth.',
    steps: [
      {
        text: 'Specific energy:',
        latex: 'E = y + \\frac{Q^2}{2gA^2}'
      },
      {
        text: 'At critical depth, $E$ is at its minimum value $E_{min}$.',
        latex: null
      },
      {
        text: 'On the subcritical limb (above $y_c$), decreasing $y$ decreases $E$ toward $E_{min}$.',
        latex: null
      },
      {
        text: 'On the supercritical limb (below $y_c$), decreasing $y$ further increases $E$ because the velocity head dominates.',
        latex: null
      }
    ],
    handbookPage: 'p. 296',
    handbookFormula: 'E = y + \\frac{V^2}{2g}',
    videoUrl: null,
    traps: [
      'Assuming specific energy is always monotonically related to depth',
      'Confusing the specific energy diagram with the depth-discharge relationship'
    ],
    diagram: null,
    lessonId: 'energy-critical-flow',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-psw-ex1',
    type: 'conceptual',
    statement: 'In the Hazen-Williams equation, the roughness coefficient $C$ for a new PVC pipe is 150, while a 20-year-old cast iron pipe has $C = 100$. Which statement correctly describes how $C$ relates to pipe performance?',
    choices: [
      {
        id: 'c1',
        text: '$C$ only affects velocity, not discharge, because area is independent of roughness'
      },
      {
        id: 'c2',
        text: 'Higher $C$ means a rougher pipe interior and greater head loss for the same flow'
      },
      {
        id: 'c3',
        text: 'Higher $C$ has the same meaning as higher Manning\'s $n$ — both indicate smoother surfaces'
      },
      {
        id: 'c4',
        text: 'Higher $C$ means a smoother pipe interior and greater flow capacity for the same head loss'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'In Hazen-Williams, $C$ appears directly in the numerator: $v = k\\,C\\,R_H^{0.63}\\,S^{0.54}$. A larger $C$ means higher velocity and more flow for the same pipe and gradient. This is the opposite of Manning\'s $n$, where higher $n$ means rougher and slower. Choice A forgets that $Q = vA$, so anything that increases $v$ also increases $Q$. Choice B reverses the meaning. Choice C confuses Hazen-Williams $C$ with Manning\'s $n$ — they work in opposite directions.',
    hint: 'Look at where $C$ appears in the Hazen-Williams equation — is it in the numerator or denominator?',
    steps: [
      {
        text: 'Hazen-Williams velocity:',
        latex: 'v = k_1 C R_H^{0.63} S_v^{0.54}'
      },
      {
        text: '$C$ is in the numerator, so larger $C$ gives larger $v$ and therefore larger $Q = vA$.',
        latex: null
      },
      {
        text: 'Higher $C$ = smoother pipe = less friction = more flow.',
        latex: null
      }
    ],
    handbookPage: 'p. 297',
    handbookFormula: 'v = k_1 C R_H^{0.63} S_v^{0.54}',
    videoUrl: null,
    traps: [
      'Confusing Hazen-Williams C (higher = smoother) with Manning\'s n (higher = rougher)'
    ],
    diagram: null,
    lessonId: 'pipe-systems-weirs',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-psw-ex2',
    type: 'computational',
    statement: 'A contracted rectangular weir has a crest length of $L = 4.0\\text{ ft}$ and a head of $H = 1.2\\text{ ft}$ above the crest. Using the contracted weir formula with $C = 3.33$, what is the discharge?',
    choices: [
      {
        id: 'c1',
        text: '$17.5\\text{ ft}^3\\text{/s}$'
      },
      {
        id: 'c2',
        text: '$16.5\\text{ ft}^3\\text{/s}$'
      },
      {
        id: 'c3',
        text: '$21.9\\text{ ft}^3\\text{/s}$'
      },
      {
        id: 'c4',
        text: '$9.1\\text{ ft}^3\\text{/s}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'For a contracted rectangular weir: $Q = C(L - 0.2H)H^{3/2}$. Effective length $= L - 0.2H = 4.0 - 0.24 = 3.76$ ft. $H^{3/2} = (1.2)^{3/2} = 1.2 \\times \\sqrt{1.2} = 1.2 \\times 1.095 = 1.315$. $Q = 3.33 \\times 3.76 \\times 1.315 = 16.5$ cfs. Choice A uses the suppressed formula $Q = CLH^{3/2} = 3.33 \\times 4.0 \\times 1.315 = 17.5$ without the contraction correction. Choice C uses $H^{5/2}$ instead of $H^{3/2}$. Choice D uses the SI coefficient $C = 1.84$.',
    hint: 'For a contracted weir: $Q = C(L - 0.2H)H^{3/2}$. Subtract the contraction correction from the crest length before multiplying.',
    steps: [
      {
        text: 'Contracted rectangular weir (USCS, $C = 3.33$):',
        latex: 'Q = C(L - 0.2H)H^{3/2}'
      },
      {
        text: 'Effective length:',
        latex: 'L_{eff} = 4.0 - 0.2(1.2) = 4.0 - 0.24 = 3.76\\text{ ft}'
      },
      {
        text: 'Head exponent:',
        latex: 'H^{3/2} = (1.2)^{3/2} = 1.2\\sqrt{1.2} = 1.315'
      },
      {
        text: 'Discharge:',
        latex: 'Q = 3.33 \\times 3.76 \\times 1.315 = 16.5\\text{ ft}^3\\text{/s}'
      }
    ],
    handbookPage: 'p. 297',
    handbookFormula: 'Q = C(L - 0.2H)H^{3/2}',
    videoUrl: null,
    traps: [
      'Using the suppressed weir formula (no contraction correction) when the problem says contracted',
      'Using H^(5/2) — that exponent is for V-notch weirs, not rectangular'
    ],
    diagram: {
      component: 'RectangularWeir',
      props: {
        L: 4,
        H: 1.2,
        unit: 'ft',
        contracted: true
      }
    },
    lessonId: 'pipe-systems-weirs',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-psw-ex3',
    type: 'conceptual',
    statement: 'A 90-degree V-notch weir and a suppressed rectangular weir are both measuring discharge with the same head $H$ above their respective crests. If $H$ doubles, which statement is correct about the increase in discharge?',
    choices: [
      {
        id: 'c1',
        text: 'The rectangular weir discharge increases more because it has a wider opening'
      },
      {
        id: 'c2',
        text: 'Both discharges increase by the same factor because weir equations are linear in $H$'
      },
      {
        id: 'c3',
        text: 'The V-notch discharge increases by a factor of $2^{5/2} \\approx 5.66$, while the rectangular increases by $2^{3/2} \\approx 2.83$'
      },
      {
        id: 'c4',
        text: 'The V-notch discharge increases by a factor of $2^{3/2}$ and the rectangular by $2^{5/2}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'V-notch: $Q = CH^{5/2}$, so doubling $H$ multiplies $Q$ by $2^{5/2} = 4\\sqrt{2} = 5.66$. Rectangular: $Q = CLH^{3/2}$, so doubling $H$ multiplies $Q$ by $2^{3/2} = 2\\sqrt{2} = 2.83$. The V-notch is more sensitive to head changes because it has a higher exponent. This is why V-notch weirs are preferred for measuring low flows — small changes in head produce larger, more measurable changes in discharge. Choice A confuses geometry with the exponent sensitivity. Choice B ignores the nonlinear exponents. Choice D swaps the exponents.',
    hint: 'Compare the exponents on $H$ in each weir formula. How does $Q$ scale when $H$ doubles?',
    steps: [
      {
        text: 'Rectangular weir: $Q \\propto H^{3/2}$. Doubling $H$:',
        latex: '\\frac{Q_{new}}{Q_{old}} = 2^{3/2} = 2.83'
      },
      {
        text: 'V-notch weir: $Q \\propto H^{5/2}$. Doubling $H$:',
        latex: '\\frac{Q_{new}}{Q_{old}} = 2^{5/2} = 5.66'
      },
      {
        text: 'The V-notch weir is more sensitive to changes in head.',
        latex: null
      }
    ],
    handbookPage: 'p. 297',
    handbookFormula: 'Q = CLH^{3/2}; \\quad Q = CH^{5/2}',
    videoUrl: null,
    traps: [
      'Swapping the exponents between rectangular (3/2) and V-notch (5/2)',
      'Thinking weir discharge is linearly proportional to head'
    ],
    diagram: null,
    lessonId: 'pipe-systems-weirs',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-psw-ex4',
    type: 'computational',
    statement: 'A 10-inch diameter new cast iron pipe ($C = 130$) is $800\\text{ ft}$ long with a head loss of $h_f = 4.0\\text{ ft}$. Using $Q = k_1 C A R_H^{0.63} S_v^{0.54}$ with $k_1 = 1.318$ and $R_H = D/4$ for a full pipe, what is the discharge?',
    choices: [
      {
        id: 'c1',
        text: '$2.0\\text{ ft}^3\\text{/s}$'
      },
      {
        id: 'c2',
        text: '$3.1\\text{ ft}^3\\text{/s}$'
      },
      {
        id: 'c3',
        text: '$1.3\\text{ ft}^3\\text{/s}$'
      },
      {
        id: 'c4',
        text: '$0.73\\text{ ft}^3\\text{/s}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: '$D = 10$ in. $= 0.833$ ft. $A = \\pi(0.833)^2/4 = 0.545$ ft$^2$. $R_H = D/4 = 0.208$ ft. $S = h_f/L = 4.0/800 = 0.005$. $v = 1.318 \\times 130 \\times (0.208)^{0.63} \\times (0.005)^{0.54}$. $(0.208)^{0.63} = 0.372$. $(0.005)^{0.54} = 0.0572$. $v = 171.3 \\times 0.372 \\times 0.0572 = 3.65$ fps. $Q = v \\times A = 3.65 \\times 0.545 = 2.0$ cfs. Choice B uses $R_H = D/2$ instead of $D/4$, which inflates the hydraulic radius and gives a higher $Q$. Choice C accidentally uses the SI factor $k_1 = 0.849$ instead of 1.318. Choice D forgets to convert inches to feet for the diameter.',
    hint: 'Convert the diameter to feet first. Then find $R_H = D/4$, $A = \\pi D^2/4$, and $S_v = h_f/L$.',
    steps: [
      {
        text: 'Convert diameter:',
        latex: 'D = 10\\text{ in.} = 0.833\\text{ ft}'
      },
      {
        text: 'Pipe properties (flowing full):',
        latex: 'A = \\frac{\\pi(0.833)^2}{4} = 0.545\\text{ ft}^2, \\quad R_H = \\frac{D}{4} = 0.208\\text{ ft}'
      },
      {
        text: 'Energy slope:',
        latex: 'S_v = \\frac{h_f}{L} = \\frac{4.0}{800} = 0.005'
      },
      {
        text: 'Evaluate fractional powers:',
        latex: '(0.208)^{0.63} = 0.372, \\quad (0.005)^{0.54} = 0.0572'
      },
      {
        text: 'Velocity:',
        latex: 'v = 1.318 \\times 130 \\times 0.372 \\times 0.0572 = 3.65\\text{ fps}'
      },
      {
        text: 'Discharge:',
        latex: 'Q = vA = 3.65 \\times 0.545 = 2.0\\text{ ft}^3\\text{/s}'
      }
    ],
    handbookPage: 'p. 297',
    handbookFormula: 'Q = k_1 C A R_H^{0.63} S_v^{0.54}',
    videoUrl: null,
    traps: [
      'Using $R_H = D/2$ (geometric radius) instead of $R_H = D/4$ (hydraulic radius)',
      'Forgetting to convert the diameter from inches to feet before computing $A$ and $R_H$'
    ],
    diagram: null,
    lessonId: 'pipe-systems-weirs',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-rr-ex1',
    type: 'computational',
    statement: 'A 30-acre parking lot has a runoff coefficient of $C = 0.70$. The 10-year design rainfall intensity for the site\'s time of concentration is $I = 5.5\\text{ in./hr}$. What is the peak runoff using the Rational Method?',
    choices: [
      {
        id: 'c1',
        text: '$165.0\\text{ cfs}$'
      },
      {
        id: 'c2',
        text: '$115.5\\text{ cfs}$'
      },
      {
        id: 'c3',
        text: '$57.8\\text{ cfs}$'
      },
      {
        id: 'c4',
        text: '$11.6\\text{ cfs}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: '$Q = CIA = 0.70 \\times 5.5 \\times 30 = 115.5$ cfs. Straight plug-and-chug with no unit conversion needed since 1 acre-in./hr is approximately 1 cfs. Choice A ignores $C$ and computes $Q = IA = 5.5 \\times 30 = 165$. Choice C divides by 2 for no valid reason. Choice D converts acres to hectares unnecessarily.',
    hint: 'Q = CIA. The units work out directly — no conversion factor needed.',
    steps: [
      {
        text: 'Apply the Rational Method:',
        latex: 'Q = CIA = 0.70 \\times 5.5 \\times 30'
      },
      {
        text: 'Compute:',
        latex: 'Q = 115.5\\text{ cfs}'
      }
    ],
    handbookPage: 'p. 290',
    handbookFormula: 'Q = CIA',
    videoUrl: null,
    traps: [
      'Trying to convert units — the Rational Method is set up so 1 acre-in./hr is approximately 1 cfs'
    ],
    diagram: null,
    lessonId: 'rainfall-runoff',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-rr-ex2',
    type: 'computational',
    statement: 'A watershed has a curve number of $CN = 75$. A storm produces $P = 6.0\\text{ in.}$ of total rainfall. What is the runoff depth using the SCS/NRCS method?',
    choices: [
      {
        id: 'c1',
        text: '$2.67\\text{ in.}$'
      },
      {
        id: 'c2',
        text: '$6.00\\text{ in.}$'
      },
      {
        id: 'c3',
        text: '$3.28\\text{ in.}$'
      },
      {
        id: 'c4',
        text: '$4.50\\text{ in.}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'First find $S$: $S = 1000/CN - 10 = 1000/75 - 10 = 13.33 - 10 = 3.33$ in. Initial abstraction $= 0.2S = 0.667$ in. Since $P = 6.0 > 0.667$, runoff occurs. $Q = (P - 0.2S)^2/(P + 0.8S) = (6.0 - 0.667)^2/(6.0 + 2.667) = (5.333)^2/8.667 = 28.44/8.667 = 3.28$ in. Choice A uses $(P - S)$ instead of $(P - 0.2S)$ in the numerator. Choice B assumes all rainfall becomes runoff. Choice D uses $P \\times CN/100$ which is not the SCS formula.',
    hint: 'First compute $S = 1000/CN - 10$, then check that $P > 0.2S$, then plug into $Q = (P - 0.2S)^2/(P + 0.8S)$.',
    steps: [
      {
        text: 'Maximum retention:',
        latex: 'S = \\frac{1{,}000}{CN} - 10 = \\frac{1{,}000}{75} - 10 = 3.33\\text{ in.}'
      },
      {
        text: 'Check initial abstraction:',
        latex: '0.2S = 0.667\\text{ in.} < P = 6.0\\text{ in. } \\checkmark'
      },
      {
        text: 'SCS runoff equation:',
        latex: 'Q = \\frac{(P - 0.2S)^2}{P + 0.8S} = \\frac{(6.0 - 0.667)^2}{6.0 + 2.667}'
      },
      {
        text: 'Compute:',
        latex: 'Q = \\frac{(5.333)^2}{8.667} = \\frac{28.44}{8.667} = 3.28\\text{ in.}'
      }
    ],
    handbookPage: 'p. 290',
    handbookFormula: 'Q = \\frac{(P - 0.2S)^2}{P + 0.8S}',
    videoUrl: null,
    traps: [
      'Using P instead of (P - 0.2S) in the numerator — you must subtract the initial abstraction',
      'Reporting Q in cfs — the SCS equation gives runoff depth in inches, not discharge'
    ],
    diagram: null,
    lessonId: 'rainfall-runoff',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-rr-ex3',
    type: 'conceptual',
    statement: 'A watershed has a curve number of $CN = 98$ (impervious). Another has $CN = 55$ (forest on sandy soil). Which statement is correct about the SCS retention parameter $S$?',
    choices: [
      {
        id: 'c1',
        text: 'Higher CN gives higher $S$, meaning the watershed retains more rainfall and produces less runoff'
      },
      {
        id: 'c2',
        text: 'Higher CN gives lower $S$, meaning the watershed retains less rainfall and produces more runoff'
      },
      {
        id: 'c3',
        text: '$S$ is independent of CN — it depends only on soil type'
      },
      {
        id: 'c4',
        text: 'Both watersheds have the same $S$ because $S$ only varies with storm duration'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: '$S = 1000/CN - 10$. For $CN = 98$: $S = 1000/98 - 10 = 0.20$ in. (almost no retention). For $CN = 55$: $S = 1000/55 - 10 = 8.18$ in. (lots of retention). Higher $CN$ means a more impervious surface, so less water is retained in the soil and more becomes runoff. Choice A reverses the relationship. Choice C ignores that $S$ is computed directly from $CN$. Choice D confuses $S$ with storm parameters.',
    hint: 'Look at the formula $S = 1000/CN - 10$. What happens to $S$ when CN increases toward 100?',
    steps: [
      {
        text: 'Retention for CN = 98:',
        latex: 'S = \\frac{1{,}000}{98} - 10 = 0.20\\text{ in.}'
      },
      {
        text: 'Retention for CN = 55:',
        latex: 'S = \\frac{1{,}000}{55} - 10 = 8.18\\text{ in.}'
      },
      {
        text: 'Higher CN means lower S — less water retained, more runoff.',
        latex: null
      }
    ],
    handbookPage: 'p. 290',
    handbookFormula: 'S = \\frac{1{,}000}{CN} - 10',
    videoUrl: null,
    traps: [
      'Thinking higher CN means more retention — it is the opposite: higher CN = more impervious = more runoff'
    ],
    diagram: null,
    lessonId: 'rainfall-runoff',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-rr-ex4',
    type: 'conceptual',
    statement: 'In the hydrologic mass balance equation $P + Q_{in} - Q_{out} + Q_g - E_s - T_s - I = \\Delta S_s$, a detention pond receives stormwater inflow but has no groundwater contribution, no evaporation, no transpiration, and no infiltration. During a storm, the inflow exceeds the outflow. Which statement is correct?',
    choices: [
      {
        id: 'c1',
        text: 'Storage is increasing because $Q_{in} > Q_{out}$ and all other terms are zero, so $\\Delta S_s > 0$'
      },
      {
        id: 'c2',
        text: 'Storage is decreasing because the pond is releasing water through the outlet'
      },
      {
        id: 'c3',
        text: 'Storage is unchanged because the mass balance always equals zero'
      },
      {
        id: 'c4',
        text: 'Storage depends on precipitation, not inflow and outflow'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'With $P = 0$ (rain falls on the watershed, not directly counted here), $Q_g = 0$, $E_s = 0$, $T_s = 0$, and $I = 0$, the balance simplifies to $Q_{in} - Q_{out} = \\Delta S$. Since $Q_{in} > Q_{out}$, $\\Delta S > 0$, meaning storage is increasing. The pond is filling up, which is exactly the purpose of detention — temporarily store peak flows to reduce downstream flooding. Choice B is wrong because although water is leaving, more is entering. Choice C confuses mass balance with zero change. Choice D ignores that inflow/outflow are the dominant terms for a pond.',
    hint: 'Simplify the mass balance by setting all zero terms to zero. What sign does $\\Delta S_s$ have when $Q_{in} > Q_{out}$?',
    steps: [
      {
        text: 'Simplify with all zero terms removed:',
        latex: 'Q_{in} - Q_{out} = \\Delta S_s'
      },
      {
        text: 'Since $Q_{in} > Q_{out}$:',
        latex: '\\Delta S_s = Q_{in} - Q_{out} > 0'
      },
      {
        text: 'Positive $\\Delta S_s$ means storage is increasing — the pond is filling.',
        latex: null
      }
    ],
    handbookPage: 'p. 290',
    handbookFormula: 'P + Q_{in} - Q_{out} + Q_g - E_s - T_s - I = \\Delta S_s',
    videoUrl: null,
    traps: [
      'Confusing "outflow exists" with "storage decreasing" — storage increases whenever inflow exceeds outflow',
      'Assuming the mass balance equation always equals zero — it equals the change in storage, not zero'
    ],
    diagram: null,
    lessonId: 'rainfall-runoff',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-hw-ex1',
    type: 'conceptual',
    statement: 'A 1-hour unit hydrograph has a peak of $400\\text{ cfs}$ and a time base of $6\\text{ hours}$. If the storm duration changes to 2 hours (but the same watershed), what happens to the unit hydrograph?',
    choices: [
      {
        id: 'c1',
        text: 'The peak doubles to 800 cfs because the storm is twice as long'
      },
      {
        id: 'c2',
        text: 'A different unit hydrograph must be derived — the 1-hour UH cannot be used directly for a 2-hour storm'
      },
      {
        id: 'c3',
        text: 'The peak stays at 400 cfs because the unit hydrograph is independent of storm duration'
      },
      {
        id: 'c4',
        text: 'The time base halves to 3 hours because the storm is shorter relative to the watershed'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'A unit hydrograph is defined for a specific storm duration. A 1-hour UH gives the response to 1 inch of excess rainfall applied over 1 hour. For a 2-hour storm, you need a 2-hour UH, which has a different shape (typically a lower peak and longer time base). You can derive the 2-hour UH from the 1-hour UH using S-curve or superposition methods, but you cannot just reuse the 1-hour UH. Choice A confuses scaling by rainfall depth with changing duration. Choice C ignores the duration dependency. Choice D inverts the relationship.',
    hint: 'A unit hydrograph is defined for a specific rainfall duration. Changing the duration requires a new UH.',
    steps: [
      {
        text: 'A unit hydrograph is tied to a specific storm duration.',
        latex: null
      },
      {
        text: 'The 1-hour UH gives the response to 1 inch of excess rain over 1 hour.',
        latex: null
      },
      {
        text: 'For a 2-hour storm, a 2-hour UH must be derived (via S-curve or superposition).',
        latex: null
      }
    ],
    handbookPage: 'p. 292',
    handbookFormula: '\\text{Unit hydrograph: 1 unit of rainfall over specified duration}',
    videoUrl: null,
    traps: [
      'Confusing scaling by rainfall depth (multiply ordinates) with changing the storm duration (requires a new UH)'
    ],
    diagram: null,
    lessonId: 'hydrograph-watershed',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-hw-ex2',
    type: 'computational',
    statement: 'A 1-hour unit hydrograph for a watershed has a peak discharge of $300\\text{ cfs}$. A storm produces $2.5\\text{ in.}$ of excess rainfall in 1 hour. What is the peak discharge of the direct runoff hydrograph?',
    choices: [
      {
        id: 'c1',
        text: '$120\\text{ cfs}$'
      },
      {
        id: 'c2',
        text: '$300\\text{ cfs}$'
      },
      {
        id: 'c3',
        text: '$750\\text{ cfs}$'
      },
      {
        id: 'c4',
        text: '$600\\text{ cfs}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'The unit hydrograph represents the response to 1 inch of excess rainfall. To get the hydrograph for 2.5 inches, multiply every ordinate by 2.5. Peak $= 300 \\times 2.5 = 750$ cfs. The time axis does not change — only the magnitudes scale. Choice A divides instead of multiplying ($300/2.5 = 120$). Choice B does not scale at all (assumes 1 inch). Choice D multiplies by 2 instead of 2.5.',
    hint: 'The unit hydrograph gives the response to 1 inch of excess rainfall. Scale linearly for other amounts.',
    steps: [
      {
        text: 'UH peak for 1 inch of excess rainfall:',
        latex: 'Q_{UH,peak} = 300\\text{ cfs}'
      },
      {
        text: 'Scale by excess rainfall depth:',
        latex: 'Q_{peak} = P \\times Q_{UH,peak} = 2.5 \\times 300 = 750\\text{ cfs}'
      }
    ],
    handbookPage: 'p. 292',
    handbookFormula: '\\text{Unit hydrograph: 1 unit of rainfall over specified duration}',
    videoUrl: null,
    traps: [
      'Dividing by the rainfall depth instead of multiplying',
      'Trying to adjust the time axis — only ordinates scale, not the time base'
    ],
    diagram: null,
    lessonId: 'hydrograph-watershed',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-hw-ex3',
    type: 'conceptual',
    statement: 'For the Rational Method, the design storm duration is set equal to the time of concentration ($t_c$). What happens to the peak discharge $Q$ if a storm duration shorter than $t_c$ is used?',
    choices: [
      {
        id: 'c1',
        text: '$Q$ increases because shorter storms have higher rainfall intensities from the IDF curve'
      },
      {
        id: 'c2',
        text: '$Q$ decreases because not all of the watershed area contributes flow to the outlet simultaneously'
      },
      {
        id: 'c3',
        text: '$Q$ stays the same because the runoff coefficient and area do not change'
      },
      {
        id: 'c4',
        text: '$Q$ doubles for every halving of storm duration'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'At duration = t_c, the entire watershed contributes flow to the outlet simultaneously, which maximizes Q. If the storm is shorter than t_c, parts of the watershed that are farther away have not had time to contribute their runoff to the outlet. Even though a shorter storm has higher intensity (from the IDF curve), the reduced contributing area more than offsets it. The Rational Method specifically uses duration = t_c to capture the maximum peak. Choice A is partially true (shorter storms are more intense) but misses that not all area contributes. Choice C ignores the time dimension. Choice D has no physical basis.',
    hint: 'Think about what $t_c$ represents — the travel time from the farthest point. What happens if the storm ends before that water arrives?',
    steps: [
      {
        text: 'At $t_c$, the entire watershed contributes flow simultaneously.',
        latex: null
      },
      {
        text: 'If storm $< t_c$, distant areas have not contributed yet, reducing $Q$.',
        latex: null
      },
      {
        text: 'This is why the Rational Method sets storm duration $= t_c$ for maximum $Q$.',
        latex: null
      }
    ],
    handbookPage: 'p. 290',
    handbookFormula: 'Q = CIA',
    videoUrl: null,
    traps: [
      'Thinking shorter storms always produce higher Q because of higher intensity — the reduced contributing area matters more'
    ],
    diagram: null,
    lessonId: 'hydrograph-watershed',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-hw-ex4',
    type: 'computational',
    statement: 'A detention pond receives a constant inflow of $I = 120\\text{ cfs}$ during the peak of a storm. The pond outlet discharges $O = 45\\text{ cfs}$. After $2\\text{ hours}$, how much water has accumulated in the pond?',
    choices: [
      {
        id: 'c1',
        text: '$540{,}000\\text{ ft}^3$'
      },
      {
        id: 'c2',
        text: '$75\\text{ cfs}$'
      },
      {
        id: 'c3',
        text: '$864{,}000\\text{ ft}^3$'
      },
      {
        id: 'c4',
        text: '$324{,}000\\text{ ft}^3$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: '$I - O = \\Delta S/\\Delta t$, so $\\Delta S/\\Delta t = 120 - 45 = 75$ cfs $= 75$ ft$^3$/s. Over 2 hours: $\\Delta S = 75 \\times (2 \\times 3600) = 75 \\times 7200 = 540{,}000$ ft$^3$. You must convert hours to seconds because the flow rates are in cfs (ft$^3$ per second). Choice B gives the storage rate (75 cfs) but not the accumulated volume. Choice C uses $I \\times t$ without subtracting outflow ($120 \\times 7200 = 864{,}000$). Choice D uses $O \\times t$ ($45 \\times 7200 = 324{,}000$).',
    hint: 'Use $I - O = \\Delta S/\\Delta t$. Find the net storage rate first, then multiply by time (convert hours to seconds).',
    steps: [
      {
        text: 'Net storage rate:',
        latex: '\\frac{\\Delta S}{\\Delta t} = I - O = 120 - 45 = 75\\text{ cfs}'
      },
      {
        text: 'Convert time to seconds:',
        latex: '\\Delta t = 2\\text{ hr} \\times 3{,}600\\text{ s/hr} = 7{,}200\\text{ s}'
      },
      {
        text: 'Accumulated storage:',
        latex: '\\Delta S = 75 \\times 7{,}200 = 540{,}000\\text{ ft}^3'
      }
    ],
    handbookPage: 'p. 290',
    handbookFormula: 'I - O = \\frac{\\Delta S}{\\Delta t}',
    videoUrl: null,
    traps: [
      'Forgetting to convert hours to seconds when flow rates are in cfs',
      'Reporting the storage rate (75 cfs) instead of the accumulated volume'
    ],
    diagram: null,
    lessonId: 'hydrograph-watershed',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-gw-ex1',
    type: 'conceptual',
    statement: 'An aquifer has a hydraulic conductivity of $K = 2 \\times 10^{-4}\\text{ m/s}$, a hydraulic gradient of $i = 0.01$, and an effective porosity of $n = 0.25$. A technician reports the groundwater velocity as $2 \\times 10^{-6}\\text{ m/s}$. What error did the technician make?',
    choices: [
      {
        id: 'c1',
        text: 'The technician multiplied by porosity instead of dividing, making the answer too small'
      },
      {
        id: 'c2',
        text: 'The technician reported the Darcy velocity ($q = Ki$) instead of the seepage velocity ($v = q/n$), which is 4 times larger'
      },
      {
        id: 'c3',
        text: 'The technician used the correct formula but forgot to square the gradient'
      },
      {
        id: 'c4',
        text: 'There is no error — this is the correct seepage velocity'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: 'Darcy velocity: $q = Ki = 2 \\times 10^{-4} \\times 0.01 = 2 \\times 10^{-6}$ m/s. That is what the technician reported. But the actual seepage velocity is $v = q/n = 2 \\times 10^{-6}/0.25 = 8 \\times 10^{-6}$ m/s, which is 4 times larger. The Darcy velocity treats the entire cross-section as if water flows through all of it, but water only moves through the pore spaces. Dividing by porosity corrects for this. Choice A describes multiplying by $n$, which would give an even smaller value ($5 \\times 10^{-7}$). Choice C has no basis. Choice D is wrong because $2 \\times 10^{-6}$ is the Darcy velocity, not the seepage velocity.',
    hint: 'Compute both $q = Ki$ and $v = q/n$. Which one matches the reported value?',
    steps: [
      {
        text: 'Darcy velocity:',
        latex: 'q = Ki = (2 \\times 10^{-4})(0.01) = 2 \\times 10^{-6}\\text{ m/s}'
      },
      {
        text: 'Seepage velocity:',
        latex: 'v = \\frac{q}{n} = \\frac{2 \\times 10^{-6}}{0.25} = 8 \\times 10^{-6}\\text{ m/s}'
      },
      {
        text: 'The reported value matches $q$, not $v$. The seepage velocity is 4 times larger.',
        latex: null
      }
    ],
    handbookPage: 'p. 292',
    handbookFormula: 'v = \\frac{q}{n}',
    videoUrl: null,
    traps: [
      'Confusing Darcy velocity with seepage velocity — seepage velocity is always larger because water only flows through pores'
    ],
    diagram: null,
    lessonId: 'groundwater-wells',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-gw-ex2',
    type: 'computational',
    statement: 'A confined aquifer has transmissivity $T = 0.002\\text{ m}^2\\text{/s}$. A pumping well shows piezometric heads of $h_1 = 42\\text{ m}$ at $r_1 = 0.3\\text{ m}$ and $h_2 = 50\\text{ m}$ at $r_2 = 150\\text{ m}$. What is the pumping rate using the Thiem equation?',
    choices: [
      {
        id: 'c1',
        text: '$0.032\\text{ m}^3\\text{/s}$'
      },
      {
        id: 'c2',
        text: '$0.008\\text{ m}^3\\text{/s}$'
      },
      {
        id: 'c3',
        text: '$0.016\\text{ m}^3\\text{/s}$'
      },
      {
        id: 'c4',
        text: '$0.0036\\text{ m}^3\\text{/s}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Thiem equation for a confined aquifer: $Q = 2\\pi T(h_2 - h_1)/\\ln(r_2/r_1)$. $Q = 2\\pi(0.002)(50 - 42)/\\ln(150/0.3) = 2\\pi(0.002)(8)/\\ln(500) = 0.1005/6.215 = 0.016$ m$^3$/s. Choice A uses $h^2$ differences (Dupuit formula for unconfined) instead of linear $h$. Choice B uses $\\pi$ instead of $2\\pi$ (missing the factor of 2). Choice D uses log base 10 instead of natural log.',
    hint: 'For a confined aquifer, use Thiem: $Q = 2\\pi T(h_2 - h_1)/\\ln(r_2/r_1)$. Use linear heads (not squared).',
    steps: [
      {
        text: 'Thiem equation (confined):',
        latex: 'Q = \\frac{2\\pi T(h_2 - h_1)}{\\ln(r_2/r_1)}'
      },
      {
        text: 'Substitute:',
        latex: 'Q = \\frac{2\\pi(0.002)(50 - 42)}{\\ln(150/0.3)}'
      },
      {
        text: 'Numerator:',
        latex: '2\\pi(0.002)(8) = 0.1005'
      },
      {
        text: 'Denominator:',
        latex: '\\ln(500) = 6.215'
      },
      {
        text: 'Pumping rate:',
        latex: 'Q = \\frac{0.1005}{6.215} = 0.016\\text{ m}^3\\text{/s}'
      }
    ],
    handbookPage: 'p. 293',
    handbookFormula: 'Q = \\frac{2\\pi T(h_2 - h_1)}{\\ln(r_2/r_1)}',
    videoUrl: null,
    traps: [
      'Using Dupuit ($h^2$ differences) for a confined aquifer — Thiem uses linear $h$',
      'Using log base 10 instead of natural log — $\\ln(500) = 6.215$, not $\\log(500) = 2.699$'
    ],
    diagram: {
      component: 'ConfinedWell',
      props: {
        h1: 42,
        h2: 50,
        b: 20,
        r1: 0.3,
        r2: 150,
        unit: 'm'
      }
    },
    lessonId: 'groundwater-wells',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-gw-ex3',
    type: 'conceptual',
    statement: 'A well pumps from an unconfined aquifer using Dupuit\'s formula: $Q = \\pi K(h_2^2 - h_1^2)/\\ln(r_2/r_1)$. A student mistakenly applies the Thiem equation (linear $h$) instead. Compared to the correct answer, the student\'s computed $Q$ will be:',
    choices: [
      {
        id: 'c1',
        text: 'Too high, because using linear heads overestimates the driving force'
      },
      {
        id: 'c2',
        text: 'Too low, because $(h_2 - h_1) < (h_2^2 - h_1^2)/h_{avg}$ when the drawdown is large relative to the saturated thickness'
      },
      {
        id: 'c3',
        text: 'The same, because both formulas give identical results'
      },
      {
        id: 'c4',
        text: 'It depends only on whether $r_1 < r_2$ or $r_1 > r_2$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Dupuit uses $h^2$ differences: $h_2^2 - h_1^2 = (h_2 + h_1)(h_2 - h_1)$. The Thiem equation uses $h_2 - h_1$. The Dupuit formula effectively multiplies the head difference by the average saturated thickness $(h_2 + h_1)$, which accounts for the fact that the flow area decreases as the water table drops near the well. Using linear $h$ underestimates this effect, giving a lower $Q$. The two formulas only agree when drawdown is very small compared to the total saturated thickness. Choice A reverses the direction. Choice C is wrong for unconfined aquifers. Choice D has no physical basis.',
    hint: 'Factor $h_2^2 - h_1^2 = (h_2 + h_1)(h_2 - h_1)$. Compare this to just $(h_2 - h_1)$.',
    steps: [
      {
        text: 'Dupuit numerator:',
        latex: 'h_2^2 - h_1^2 = (h_2 + h_1)(h_2 - h_1)'
      },
      {
        text: 'Thiem numerator:',
        latex: 'h_2 - h_1'
      },
      {
        text: 'Dupuit has the extra factor $(h_2 + h_1)$, so using Thiem underestimates $Q$.',
        latex: null
      }
    ],
    handbookPage: 'p. 292',
    handbookFormula: 'Q = \\frac{\\pi K(h_2^2 - h_1^2)}{\\ln(r_2/r_1)}',
    videoUrl: null,
    traps: [
      'Thinking linear and quadratic head formulas give the same result — they only agree for very small drawdowns'
    ],
    diagram: null,
    lessonId: 'groundwater-wells',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-gw-ex4',
    type: 'computational',
    statement: 'Groundwater flows through a sand layer with $K = 8 \\times 10^{-4}\\text{ m/s}$. The hydraulic gradient is $i = 0.015$ and the effective porosity is $n = 0.35$. A contamination source is $630\\text{ m}$ upgradient. How long will it take the contamination front to reach the monitoring well? (Assume advection only.)',
    choices: [
      {
        id: 'c1',
        text: '$5{,}100\\text{ hours}$'
      },
      {
        id: 'c2',
        text: '$14{,}600\\text{ hours}$'
      },
      {
        id: 'c3',
        text: '$1{,}460\\text{ hours}$'
      },
      {
        id: 'c4',
        text: '$18{,}400\\text{ hours}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'First find the Darcy velocity: $q = Ki = 8 \\times 10^{-4} \\times 0.015 = 1.2 \\times 10^{-5}$ m/s. Then the seepage velocity: $v = q/n = 1.2 \\times 10^{-5}/0.35 = 3.43 \\times 10^{-5}$ m/s. Travel time $= \\text{distance}/\\text{velocity} = 630/3.43 \\times 10^{-5} = 1.837 \\times 10^7$ seconds. Convert to hours: $1.837 \\times 10^7/3600 = 5{,}100$ hours (about 213 days). Contaminants travel at the seepage velocity, not the Darcy velocity. Choice B uses the Darcy velocity (not dividing by porosity), giving 14,600 hours — about 3 times too long. Choice C divides by 10 instead of converting properly (likely a decimal error). Choice D reports the raw seconds value without converting to hours.',
    hint: 'Find the seepage velocity ($v = Ki/n$), then compute $t = \\text{distance}/v$. Convert seconds to hours.',
    steps: [
      {
        text: 'Darcy velocity:',
        latex: 'q = Ki = (8 \\times 10^{-4})(0.015) = 1.2 \\times 10^{-5}\\text{ m/s}'
      },
      {
        text: 'Seepage velocity:',
        latex: 'v = \\frac{q}{n} = \\frac{1.2 \\times 10^{-5}}{0.35} = 3.43 \\times 10^{-5}\\text{ m/s}'
      },
      {
        text: 'Travel time:',
        latex: 't = \\frac{630}{3.43 \\times 10^{-5}} = 1.837 \\times 10^7\\text{ s}'
      },
      {
        text: 'Convert to hours:',
        latex: 't = \\frac{1.837 \\times 10^7}{3{,}600} = 5{,}100\\text{ hours}'
      }
    ],
    handbookPage: 'p. 292',
    handbookFormula: 'v = \\frac{q}{n} = \\frac{Ki}{n}',
    videoUrl: null,
    traps: [
      'Using Darcy velocity instead of seepage velocity — contamination moves at the actual pore velocity, which is faster',
      'Forgetting to convert seconds to hours in the final answer'
    ],
    diagram: null,
    lessonId: 'groundwater-wells',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-wq-ex1',
    type: 'computational',
    statement: 'A wastewater sample has an ultimate BOD of $L_0 = 250\\text{ mg/L}$ and a decay rate of $k = 0.23\\text{ day}^{-1}$ (base $e$). What is the BOD exerted at day 3 ($BOD_3$)?',
    choices: [
      {
        id: 'c1',
        text: '$250\\text{ mg/L}$'
      },
      {
        id: 'c2',
        text: '$125\\text{ mg/L}$'
      },
      {
        id: 'c3',
        text: '$63\\text{ mg/L}$'
      },
      {
        id: 'c4',
        text: '$188\\text{ mg/L}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'easy',
    eli5: '$BOD_3 = L_0(1 - e^{-kt}) = 250(1 - e^{-0.23 \\times 3}) = 250(1 - e^{-0.69}) = 250(1 - 0.502) = 250 \\times 0.498 = 125$ mg/L. About half the ultimate BOD has been exerted by day 3. Choice A gives the ultimate BOD, not the 3-day value. Choice C is roughly $BOD_1$ (one day exertion). Choice D is the $BOD_5$ value, not $BOD_3$.',
    hint: 'Use $BOD_t = L_0(1 - e^{-kt})$ with $t = 3$ days.',
    steps: [
      {
        text: 'BOD exertion formula:',
        latex: 'BOD_3 = L_0(1 - e^{-kt}) = 250(1 - e^{-0.23 \\times 3})'
      },
      {
        text: 'Compute exponent:',
        latex: 'e^{-0.69} = 0.502'
      },
      {
        text: 'BOD at day 3:',
        latex: 'BOD_3 = 250(1 - 0.502) = 250 \\times 0.498 = 125\\text{ mg/L}'
      }
    ],
    handbookPage: 'p. 321',
    handbookFormula: 'BOD_t = L_0(1 - e^{-kt})',
    videoUrl: null,
    traps: [
      'Confusing BOD exerted with BOD remaining — the remaining is L0 x e^(-kt) = 125, which happens to equal the exerted value at this point'
    ],
    diagram: null,
    lessonId: 'water-quality',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-wq-ex2',
    type: 'conceptual',
    statement: 'In the Streeter-Phelps dissolved oxygen sag model, the critical point (minimum DO) occurs where:',
    choices: [
      {
        id: 'c1',
        text: 'The BOD has been completely consumed'
      },
      {
        id: 'c2',
        text: 'The dissolved oxygen reaches zero'
      },
      {
        id: 'c3',
        text: 'The rate of deoxygenation (BOD consumption) equals the rate of reaeration from the atmosphere'
      },
      {
        id: 'c4',
        text: 'The stream velocity reaches its minimum value'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'The DO sag curve has two competing processes: deoxygenation (organisms consuming oxygen as they decompose BOD) and reaeration (atmospheric oxygen dissolving into the water). Upstream of the critical point, deoxygenation dominates and DO drops. At the critical point, the two rates are exactly equal — DO stops dropping. Downstream of it, reaeration dominates and DO recovers. Choice A is wrong because significant BOD may remain at the critical point. Choice B is wrong because DO rarely reaches zero in practice. Choice D confuses velocity with the oxygen balance.',
    hint: 'The oxygen deficit is increasing when deoxygenation exceeds reaeration, and decreasing when reaeration exceeds deoxygenation. The minimum DO is where they balance.',
    steps: [
      {
        text: 'Deoxygenation rate: $k_d \\cdot L$ (BOD consuming oxygen).',
        latex: null
      },
      {
        text: 'Reaeration rate: $k_r \\cdot D$ (atmosphere replenishing oxygen).',
        latex: null
      },
      {
        text: 'At the critical point: $k_d L = k_r D$, so $dD/dt = 0$ and the deficit stops growing.',
        latex: null
      }
    ],
    handbookPage: 'p. 321',
    handbookFormula: 'DO = DO_{sat} - D',
    videoUrl: null,
    traps: [
      'Thinking DO must reach zero at the critical point — it is simply the minimum, which may still be well above zero'
    ],
    diagram: null,
    lessonId: 'water-quality',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-wq-ex3',
    type: 'computational',
    statement: 'A lab measures $BOD_5 = 150\\text{ mg/L}$ with a rate constant of $k = 0.15\\text{ day}^{-1}$ (base $e$). What is the ultimate BOD ($L_0$)?',
    choices: [
      {
        id: 'c1',
        text: '$150\\text{ mg/L}$'
      },
      {
        id: 'c2',
        text: '$284\\text{ mg/L}$'
      },
      {
        id: 'c3',
        text: '$225\\text{ mg/L}$'
      },
      {
        id: 'c4',
        text: '$750\\text{ mg/L}$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'Rearrange: $L_0 = BOD_5/(1 - e^{-kt}) = 150/(1 - e^{-0.15 \\times 5}) = 150/(1 - e^{-0.75}) = 150/(1 - 0.472) = 150/0.528 = 284$ mg/L. At this slower decay rate, the 5-day test captures only about 53% of the ultimate BOD, so $L_0$ is nearly double the $BOD_5$. Choice A assumes $BOD_5 = L_0$. Choice C uses $L_0 = 1.5 \\times BOD_5$ (a rough approximation, but not correct here). Choice D multiplies by 5.',
    hint: 'Rearrange $BOD_t = L_0(1 - e^{-kt})$ to solve for $L_0$.',
    steps: [
      {
        text: 'Rearrange:',
        latex: 'L_0 = \\frac{BOD_5}{1 - e^{-kt}}'
      },
      {
        text: 'Substitute:',
        latex: 'L_0 = \\frac{150}{1 - e^{-0.15 \\times 5}} = \\frac{150}{1 - e^{-0.75}}'
      },
      {
        text: 'Compute:',
        latex: 'L_0 = \\frac{150}{1 - 0.472} = \\frac{150}{0.528} = 284\\text{ mg/L}'
      }
    ],
    handbookPage: 'p. 321',
    handbookFormula: 'BOD_t = L_0(1 - e^{-kt})',
    videoUrl: null,
    traps: [
      'Assuming BOD5 equals the ultimate BOD — the 5-day test only captures a fraction of the total',
      'Using the wrong base for k — make sure k is base e, not base 10'
    ],
    diagram: null,
    lessonId: 'water-quality',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-wq-ex4',
    type: 'conceptual',
    statement: 'A BOD rate constant at 20\\degree\\text{C} is $k_{20} = 0.20\\text{ day}^{-1}$. Using $k_T = k_{20}\\theta^{(T-20)}$ with $\\theta = 1.056$ for temperatures above 20\\degree\\text{C}, what is the effect on $k$ at $T = 30\\degree\\text{C}$?',
    choices: [
      {
        id: 'c1',
        text: '$k$ increases to about $0.34\\text{ day}^{-1}$ because higher temperature accelerates biological decomposition'
      },
      {
        id: 'c2',
        text: '$k$ decreases to about $0.12\\text{ day}^{-1}$ because warmer water holds less dissolved oxygen'
      },
      {
        id: 'c3',
        text: '$k$ stays at $0.20\\text{ day}^{-1}$ because the rate constant is independent of temperature'
      },
      {
        id: 'c4',
        text: '$k$ increases to about $0.40\\text{ day}^{-1}$ because the exponent is $(T - 20) = 10$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: '$k_{30} = k_{20} \\times \\theta^{(T-20)} = 0.20 \\times 1.056^{10} = 0.20 \\times 1.724 = 0.345$, approximately $0.34$ day$^{-1}$. Higher temperature speeds up microbial metabolism, so organic matter decomposes faster and the BOD rate constant increases. While it is true that warmer water holds less DO (which affects the oxygen balance), the rate constant itself increases with temperature. Choice B confuses the effect on DO saturation with the effect on $k$. Choice C ignores temperature dependence entirely. Choice D overestimates by using a larger $\\theta$ value or miscalculating the power.',
    hint: 'Plug in $T = 30$ to get the exponent $(30 - 20) = 10$. Then compute $1.056^{10}$.',
    steps: [
      {
        text: 'Temperature correction:',
        latex: 'k_{30} = k_{20} \\cdot \\theta^{(T-20)} = 0.20 \\times 1.056^{10}'
      },
      {
        text: 'Compute the power:',
        latex: '1.056^{10} = 1.724'
      },
      {
        text: 'Corrected rate constant:',
        latex: 'k_{30} = 0.20 \\times 1.724 = 0.345 \\approx 0.34\\text{ day}^{-1}'
      }
    ],
    handbookPage: 'p. 322',
    handbookFormula: 'k_T = k_{20} \\theta^{(T-20)}',
    videoUrl: null,
    traps: [
      'Confusing the effect on k (increases) with the effect on DO saturation (decreases) at higher temperatures',
      'Using (20 - T) instead of (T - 20) in the exponent, which gives a smaller k for higher T'
    ],
    diagram: null,
    lessonId: 'water-quality',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-wt-ex1',
    type: 'computational',
    statement: 'A secondary clarifier treats a flow of $Q = 1.5\\text{ MGD}$. The tank is circular with a diameter of $50\\text{ ft}$. What is the overflow rate?',
    choices: [
      {
        id: 'c1',
        text: '$1{,}528\\text{ gpd/ft}^2$'
      },
      {
        id: 'c2',
        text: '$382\\text{ gpd/ft}^2$'
      },
      {
        id: 'c3',
        text: '$30{,}000\\text{ gpd/ft}^2$'
      },
      {
        id: 'c4',
        text: '$764\\text{ gpd/ft}^2$'
      }
    ],
    correctAnswerId: 'c4',
    difficulty: 'easy',
    eli5: 'Overflow rate $= Q/A$. $A = \\pi(50)^2/4 = 1{,}963$ ft$^2$. $Q = 1.5$ MGD $= 1{,}500{,}000$ gpd. $v_o = 1{,}500{,}000/1{,}963 = 764$ gpd/ft$^2$. This falls within the typical range for secondary clarifiers (400--800 gpd/ft$^2$). Choice A uses the radius instead of diameter. Choice B divides by twice the area (uses $D$ instead of $D^2$ incorrectly). Choice C forgets to square the diameter in the area calculation.',
    hint: 'Overflow rate = $Q/A_{surface}$. Convert MGD to gpd and compute the circular area.',
    steps: [
      {
        text: 'Surface area:',
        latex: 'A = \\frac{\\pi D^2}{4} = \\frac{\\pi(50)^2}{4} = 1{,}963\\text{ ft}^2'
      },
      {
        text: 'Convert flow:',
        latex: 'Q = 1.5\\text{ MGD} = 1{,}500{,}000\\text{ gpd}'
      },
      {
        text: 'Overflow rate:',
        latex: 'v_o = \\frac{Q}{A} = \\frac{1{,}500{,}000}{1{,}963} = 764\\text{ gpd/ft}^2'
      }
    ],
    handbookPage: 'p. 339',
    handbookFormula: 'v_o = Q/A_{surface}',
    videoUrl: null,
    traps: [
      'Forgetting to convert MGD to gpd — 1 MGD = 1,000,000 gpd',
      'Using the diameter without squaring it in the area formula'
    ],
    diagram: null,
    lessonId: 'water-treatment',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-wt-ex2',
    type: 'conceptual',
    statement: 'A settling basin has an overflow rate of $v_o = 600\\text{ gpd/ft}^2$. Particle A has a settling velocity of $800\\text{ gpd/ft}^2$ and Particle B has a settling velocity of $400\\text{ gpd/ft}^2$. Which particles are removed?',
    choices: [
      {
        id: 'c1',
        text: 'Both particles are completely removed because both are heavier than water'
      },
      {
        id: 'c2',
        text: 'Particle A is completely removed; Particle B is only partially removed'
      },
      {
        id: 'c3',
        text: 'Neither particle is removed because the overflow rate is positive'
      },
      {
        id: 'c4',
        text: 'Particle B is completely removed; Particle A is only partially removed'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'The overflow rate acts as a threshold: any particle with $v_s > v_o$ will settle to the bottom before being carried out, so it is completely removed. Particle A: $v_s = 800 > 600$, so it settles faster than the upward flow velocity and is fully captured. Particle B: $v_s = 400 < 600$, so some of these particles will be carried over the weir. The fraction removed is roughly $v_s/v_o = 400/600 = 67\\%$. Choice A ignores the overflow rate criterion. Choice C misunderstands what overflow rate means. Choice D reverses the comparison.',
    hint: 'A particle is completely removed if its settling velocity exceeds the overflow rate ($v_s > v_o$).',
    steps: [
      {
        text: 'Particle A: $v_s = 800 > v_o = 600$, so it is completely removed.',
        latex: null
      },
      {
        text: 'Particle B: $v_s = 400 < v_o = 600$, so it is only partially removed.',
        latex: null
      },
      {
        text: 'Fraction of B removed:',
        latex: '\\frac{v_s}{v_o} = \\frac{400}{600} = 0.67 \\text{ (67\\%)}'
      }
    ],
    handbookPage: 'p. 339',
    handbookFormula: 'v_o = Q/A_{surface}',
    videoUrl: null,
    traps: [
      'Reversing the comparison — particles with v_s > v_o are removed, not the other way around'
    ],
    diagram: null,
    lessonId: 'water-treatment',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-wt-ex3',
    type: 'computational',
    statement: 'An aeration basin treats $Q = 5{,}000\\text{ m}^3\\text{/day}$ of wastewater with influent BOD $S_0 = 180\\text{ mg/L}$. The basin volume is $V = 3{,}000\\text{ m}^3$ and MLSS is $X_A = 2{,}500\\text{ mg/L}$. What is the food-to-microorganism (F:M) ratio?',
    choices: [
      {
        id: 'c1',
        text: '$1.20\\text{ day}^{-1}$'
      },
      {
        id: 'c2',
        text: '$0.30\\text{ day}^{-1}$'
      },
      {
        id: 'c3',
        text: '$0.12\\text{ day}^{-1}$'
      },
      {
        id: 'c4',
        text: '$0.036\\text{ day}^{-1}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: '$F{:}M = Q \\times S_0/(V \\times X_A) = (5{,}000 \\times 180)/(3{,}000 \\times 2{,}500) = 900{,}000/7{,}500{,}000 = 0.12$ day$^{-1}$. The mg/L units cancel between $S_0$ and $X_A$, leaving m$^3$/day divided by m$^3$, which gives day$^{-1}$. This F:M is below the conventional range (0.2--0.4), suggesting extended aeration. Choice A inverts some terms. Choice B divides only by $V$ (ignores $X_A$). Choice D squares the volume in the denominator.',
    hint: 'F:M = $(Q \\times S_0)/(V \\times X_A)$. Make sure all units are consistent.',
    steps: [
      {
        text: 'F:M ratio formula:',
        latex: 'F{:}M = \\frac{Q \\cdot S_0}{V \\cdot X_A}'
      },
      {
        text: 'Substitute:',
        latex: 'F{:}M = \\frac{5{,}000 \\times 180}{3{,}000 \\times 2{,}500}'
      },
      {
        text: 'Compute:',
        latex: 'F{:}M = \\frac{900{,}000}{7{,}500{,}000} = 0.12\\text{ day}^{-1}'
      }
    ],
    handbookPage: 'p. 333',
    handbookFormula: '\\text{F:M} = Q_0 S_0 / (\\text{Vol} \\cdot X_A)',
    videoUrl: null,
    traps: [
      'Forgetting to include MLSS (X_A) in the denominator',
      'Getting confused by units — mg/L cancels between S_0 and X_A, leaving 1/time'
    ],
    diagram: null,
    lessonId: 'water-treatment',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-wt-ex4',
    type: 'conceptual',
    statement: 'An activated sludge plant operator reports an SRT ($\\theta_c$) of $8\\text{ hours}$ and an HRT ($\\theta$) of $10\\text{ days}$. Is this plausible?',
    choices: [
      {
        id: 'c1',
        text: 'No — SRT is always much longer than HRT. The values are likely swapped.'
      },
      {
        id: 'c2',
        text: 'Yes — SRT can be shorter than HRT if the sludge is wasted rapidly'
      },
      {
        id: 'c3',
        text: 'Yes — SRT and HRT are independent parameters that can take any values'
      },
      {
        id: 'c4',
        text: 'No — SRT and HRT must always be equal in a properly designed system'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'SRT (solids residence time) measures how long bacteria stay in the system — typically 4--15 days for conventional activated sludge. HRT (hydraulic residence time) measures how long water stays in the aeration basin — typically 4--8 hours. SRT is always much longer than HRT because we recycle the sludge (solids) back to the aeration basin, keeping the bacteria in the system far longer than the water. The reported values ($\\theta_c = 8$ hr, $\\theta = 10$ days) are clearly swapped. Choice B is wrong because rapid wasting still gives SRT of at least a few days. Choice C ignores the physical constraint that sludge recycle makes SRT $>$ HRT. Choice D is wrong because they are never equal in practice.',
    hint: 'Think about typical values: SRT is in days (4-15), HRT is in hours (4-8). Which parameter should be larger?',
    steps: [
      {
        text: 'Typical SRT: 4–15 days (solids are recycled in the system).',
        latex: null
      },
      {
        text: 'Typical HRT: 4–8 hours (water passes through relatively quickly).',
        latex: null
      },
      {
        text: 'SRT should always be much longer than HRT. The reported values are swapped.',
        latex: null
      }
    ],
    handbookPage: 'p. 333',
    handbookFormula: '\\theta_c = \\frac{V X_A}{Q_w X_w + Q_e X_e}; \\quad \\theta = \\frac{V}{Q}',
    videoUrl: null,
    traps: [
      'Confusing SRT (days) with HRT (hours) — they differ by orders of magnitude',
      'Thinking SRT and HRT should be equal — sludge recycle makes SRT much longer'
    ],
    diagram: null,
    lessonId: 'water-treatment',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-dwt-ex1',
    type: 'computational',
    statement: 'A rapid sand filter bed measures $24\\text{ ft}$ by $12\\text{ ft}$ and treats a flow of $Q = 1{,}728\\text{ gpm}$. What is the filtration (loading) rate?',
    choices: [
      { id: 'c1', text: '$6.0\\text{ gpm/ft}^2$' },
      { id: 'c2', text: '$3.0\\text{ gpm/ft}^2$' },
      { id: 'c3', text: '$0.17\\text{ gpm/ft}^2$' },
      { id: 'c4', text: '$60\\text{ gpm/ft}^2$' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Filtration rate = Q/A_plan. Area = 24 × 12 = 288 ft². v_s = 1,728/288 = 6.0 gpm/ft², within the typical rapid-sand range of 2--10 gpm/ft². Choice B halves the area. Choice C inverts the ratio. Choice D drops a zero.',
    hint: 'Filtration rate = flow / plan area (length × width).',
    steps: [
      { text: 'Plan area:', latex: 'A_{plan} = 24 \\times 12 = 288\\text{ ft}^2' },
      { text: 'Filtration rate:', latex: 'v_s = \\frac{1{,}728}{288} = 6.0\\text{ gpm/ft}^2' },
    ],
    handbookPage: 'p. 341',
    handbookFormula: 'v_s = Q/A_{plan}',
    videoUrl: null,
    traps: [
      'Using bed depth or volume instead of plan area',
      'Inverting to A/Q',
    ],
    diagram: { component: 'FilterBed', props: {} },
    lessonId: 'drinking-water-treatment',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-dwt-ex2',
    type: 'computational',
    statement: 'Water with a chlorine demand of $1.8\\text{ mg/L}$ must be dosed to leave a free residual of $0.5\\text{ mg/L}$. For a flow of $Q = 2.0\\text{ MGD}$, what is the chlorine feed rate? (Use $\\text{lb/day} = \\text{mg/L} \\times \\text{MGD} \\times 8.34$.)',
    choices: [
      { id: 'c1', text: '$38.4\\text{ lb/day}$' },
      { id: 'c2', text: '$30.0\\text{ lb/day}$' },
      { id: 'c3', text: '$15.0\\text{ lb/day}$' },
      { id: 'c4', text: '$21.7\\text{ lb/day}$' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Dose = demand + residual = 1.8 + 0.5 = 2.3 mg/L. Feed rate = 2.3 × 2.0 × 8.34 = 38.4 lb/day. Choice B uses a 2.3 × 2.0 product without the 8.34 factor scaled wrong. Choice C halves it. Choice D uses only the demand (1.8) × flow × 8.34.',
    hint: 'Dose = demand + residual, then lb/day = dose × MGD × 8.34.',
    steps: [
      { text: 'Applied dose:', latex: '\\text{Dose} = 1.8 + 0.5 = 2.3\\text{ mg/L}' },
      { text: 'Feed rate:', latex: '2.3 \\times 2.0 \\times 8.34 = 38.4\\text{ lb/day}' },
    ],
    handbookPage: 'p. 346',
    handbookFormula: '\\text{Dose} = \\text{Demand} + \\text{Residual}',
    videoUrl: null,
    traps: [
      'Feeding only the demand and omitting the target residual',
      'Forgetting the 8.34 lb/(mg/L·MG) conversion',
    ],
    diagram: null,
    lessonId: 'drinking-water-treatment',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-wqs-ex1',
    type: 'computational',
    statement: 'A groundwater sample contains $\\text{Ca}^{2+} = 70\\text{ mg/L}$ and $\\text{Mg}^{2+} = 20\\text{ mg/L}$. Using equivalent weights of $20$ (Ca²⁺) and $12.15$ (Mg²⁺), what is the total hardness as CaCO₃?',
    choices: [
      { id: 'c1', text: '$257\\text{ mg/L as CaCO}_3$' },
      { id: 'c2', text: '$90\\text{ mg/L as CaCO}_3$' },
      { id: 'c3', text: '$175\\text{ mg/L as CaCO}_3$' },
      { id: 'c4', text: '$200\\text{ mg/L as CaCO}_3$' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Convert each ion by 50/EW. Ca: 70 × 2.5 = 175. Mg: 20 × (50/12.15) = 20 × 4.12 = 82. Total = 175 + 82 = 257 mg/L as CaCO₃ (very hard). Choice B adds raw ion values (70 + 20). Choice C counts only calcium. Choice D is a partial conversion.',
    hint: 'Multiply each ion by 50/EW (Ca → 2.5, Mg → 4.12), then add.',
    steps: [
      { text: 'Calcium as CaCO₃:', latex: '70 \\times 2.5 = 175' },
      { text: 'Magnesium as CaCO₃:', latex: '20 \\times \\frac{50}{12.15} = 82' },
      { text: 'Total hardness:', latex: '175 + 82 = 257\\text{ mg/L as CaCO}_3' },
    ],
    handbookPage: null,
    handbookFormula: '\\text{Hardness as CaCO}_3 = \\sum C_i \\times 50/EW_i',
    videoUrl: null,
    traps: [
      'Adding raw ion concentrations without converting to CaCO₃',
      'Using the calcium multiplier (2.5) for magnesium',
    ],
    diagram: null,
    lessonId: 'water-quality-standards',
    chapterId: 'water-resources'
  },
  {
    id: 'wr-pwd-ex1',
    type: 'computational',
    statement: 'A pump delivers $Q = 0.08\\text{ m}^3\\text{/s}$ against a head of $H = 25\\text{ m}$ at an efficiency of $\\eta = 0.80$. What brake power is required? (Use $\\rho g = 9{,}810\\text{ N/m}^3$.)',
    choices: [
      { id: 'c1', text: '$24.5\\text{ kW}$' },
      { id: 'c2', text: '$19.6\\text{ kW}$' },
      { id: 'c3', text: '$15.7\\text{ kW}$' },
      { id: 'c4', text: '$30.7\\text{ kW}$' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Fluid power = γQH = 9,810 × 0.08 × 25 = 19,620 W ≈ 19.6 kW. Brake power = 19.6/0.80 = 24.5 kW. Choice B is fluid power (no efficiency). Choice C multiplies by 0.80 instead of dividing. Choice D applies the efficiency twice.',
    hint: 'Fluid power = γQH; brake power = fluid power / η.',
    steps: [
      { text: 'Fluid power:', latex: '\\gamma Q H = 9{,}810 \\times 0.08 \\times 25 = 19{,}620\\text{ W}' },
      { text: 'Brake power:', latex: '\\frac{19{,}620}{0.80} = 24{,}525\\text{ W} \\approx 24.5\\text{ kW}' },
    ],
    handbookPage: 'p. 191',
    handbookFormula: '\\dot W = \\gamma Q H / \\eta',
    videoUrl: null,
    traps: [
      'Forgetting to divide by efficiency',
      'Multiplying by η instead of dividing',
    ],
    diagram: { component: 'PumpSystem', props: {} },
    lessonId: 'pumps-water-distribution',
    chapterId: 'water-resources'
  },
];

export default PROBLEMS;
