// Exam bank: transportation
// Auto-extracted from lesson files — 35 questions

const PROBLEMS = [
  {
    id: 'trans-ssd-ex1',
    type: 'computational',
    statement: 'A road has a design speed of $45 \\text{ mph}$ on a level grade. Using $t = 2.5 \\text{ s}$ and $a = 11.2 \\text{ ft/sec}^2$, what is the braking distance component of the SSD?',
    choices: [
      {
        id: 'c1',
        text: '$194 \\text{ ft}$'
      },
      {
        id: 'c2',
        text: '$165 \\text{ ft}$'
      },
      {
        id: 'c3',
        text: '$359 \\text{ ft}$'
      },
      {
        id: 'c4',
        text: '$388 \\text{ ft}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Braking distance $= V^2 / [30(a/32.2 \\pm G)]$. On a level grade $G = 0$, so it simplifies to $V^2 / [30(a/32.2)] = 45^2 / [30(11.2/32.2)] = 2{,}025 / [30 \\times 0.3478] = 2{,}025 / 10.43 = 194.1$ ft. The 165 ft choice used $a = 11.2$ directly in the denominator without dividing by 32.2: $2{,}025/(30 \\times 0.3733)$ is wrong. The 359 ft choice added the reaction distance when the question only asks for braking. The 388 ft choice divided by $2 \\times 0.3478 \\times 7.5$ incorrectly.',
    hint: 'Braking distance only: $V^2 / [30(a/32.2)]$. Do not add the reaction distance.',
    steps: [
      {
        text: 'Deceleration fraction:',
        latex: '\\frac{a}{32.2} = \\frac{11.2}{32.2} = 0.3478'
      },
      {
        text: 'Braking distance:',
        latex: 'd_b = \\frac{V^2}{30 \\times 0.3478} = \\frac{45^2}{10.43} = \\frac{2{,}025}{10.43} = 194 \\text{ ft}'
      }
    ],
    handbookPage: 'p. 300',
    handbookFormula: 'SSD = 1.47 V t + \\frac{V^2}{30\\left(\\frac{a}{32.2} \\pm G\\right)}',
    videoUrl: null,
    traps: [
      'Adding the reaction distance when the problem only asks for the braking component'
    ],
    diagram: null,
    lessonId: 'stopping-sight-distance',
    chapterId: 'transportation'
  },
  {
    id: 'trans-ssd-ex2',
    type: 'conceptual',
    statement: 'A designer is computing SSD for a road with a $6\\%$ upgrade. Compared to a level road at the same design speed, what happens to the SSD?',
    choices: [
      {
        id: 'c1',
        text: 'SSD increases because gravity resists braking on an uphill grade'
      },
      {
        id: 'c2',
        text: 'SSD decreases because gravity assists braking on an uphill grade'
      },
      {
        id: 'c3',
        text: 'SSD is unchanged because grade does not affect braking distance'
      },
      {
        id: 'c4',
        text: 'SSD decreases because drivers react faster going uphill'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'On an uphill grade, gravity pulls the vehicle backward, helping the brakes slow it down. In the formula, a positive $G$ makes the denominator $30(a/32.2 + G)$ larger, which makes the braking distance fraction smaller. The reaction distance is unchanged (grade does not affect perception-reaction time), but the braking distance is shorter. The choice claiming SSD increases reverses the effect of uphill. The "unchanged" choice ignores the grade term entirely. The "drivers react faster" choice wrongly claims grade affects reaction time.',
    hint: 'In the SSD formula, $G$ is positive for uphill. What does a larger denominator do to the braking distance?',
    steps: [
      {
        text: 'Uphill: $G = +0.06$. Denominator becomes $30(a/32.2 + 0.06)$, which is larger than the level case.',
        latex: null
      },
      {
        text: 'Larger denominator means smaller braking distance $d_b = V^2 / [30(a/32.2 + G)]$.',
        latex: null
      },
      {
        text: 'Reaction distance is unaffected by grade, so total SSD decreases.',
        latex: null
      }
    ],
    handbookPage: 'p. 300',
    handbookFormula: 'SSD = 1.47 V t + \\frac{V^2}{30\\left(\\frac{a}{32.2} \\pm G\\right)}',
    videoUrl: null,
    traps: [
      'Confusing uphill with downhill -- uphill is positive $G$ and makes stopping easier, not harder'
    ],
    diagram: null,
    lessonId: 'stopping-sight-distance',
    chapterId: 'transportation'
  },
  {
    id: 'trans-ssd-ex3',
    type: 'computational',
    statement: 'The major road at an intersection has a design speed of $50 \\text{ mph}$. The time gap for a vehicle turning from the minor road is $t_g = 7.5 \\text{ sec}$. What is the intersection sight distance (ISD)?',
    choices: [
      {
        id: 'c1',
        text: '$735 \\text{ ft}$'
      },
      {
        id: 'c2',
        text: '$375 \\text{ ft}$'
      },
      {
        id: 'c3',
        text: '$551 \\text{ ft}$'
      },
      {
        id: 'c4',
        text: '$110 \\text{ ft}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: '$ISD = 1.47 \\times V_{\\text{major}} \\times t_g = 1.47 \\times 50 \\times 7.5 = 551.25$, which rounds to 551 ft. The 375 ft choice used mph directly without converting: $50 \\times 7.5 = 375$. The 735 ft choice used $t_g = 10$ sec instead of 7.5 sec. The 110 ft choice forgot to multiply by $t_g$: $1.47 \\times 50 \\times 1.5 = 110$.',
    hint: '$ISD = 1.47 \\times V_{\\text{major}} \\times t_g$. Same conversion factor (1.47) as in the SSD formula.',
    steps: [
      {
        text: 'Intersection sight distance:',
        latex: 'ISD = 1.47 \\times V_{\\text{major}} \\times t_g = 1.47 \\times 50 \\times 7.5 = 551 \\text{ ft}'
      }
    ],
    handbookPage: 'p. 300',
    handbookFormula: 'ISD = 1.47 \\, V_{\\text{major}} \\, t_g',
    videoUrl: null,
    traps: [
      'Forgetting the 1.47 conversion factor and multiplying mph directly by the time gap'
    ],
    diagram: null,
    lessonId: 'stopping-sight-distance',
    chapterId: 'transportation'
  },
  {
    id: 'trans-ssd-ex4',
    type: 'conceptual',
    statement: 'A roadway carries $1{,}800 \\text{ veh/hr}$ with a peak 15-minute count of $500 \\text{ veh}$. An engineer reports the PHF as $0.90$ and the peak flow rate as $1{,}620 \\text{ veh/hr}$. What error did the engineer make?',
    choices: [
      {
        id: 'c1',
        text: 'The engineer multiplied V by PHF instead of dividing -- the correct flow rate is 2,000 veh/hr'
      },
      {
        id: 'c2',
        text: 'The PHF calculation is wrong -- it should be 1.11, not 0.90'
      },
      {
        id: 'c3',
        text: 'The engineer forgot to multiply by 4 -- the correct flow rate is 7,200 veh/hr'
      },
      {
        id: 'c4',
        text: 'No error was made -- 1,620 veh/hr is correct'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: '$PHF = V/(4 \\times V_{15}) = 1{,}800/(4 \\times 500) = 1{,}800/2{,}000 = 0.90$. That part is correct. The peak flow rate $= V/PHF = 1{,}800/0.90 = 2{,}000$ veh/hr (equivalently, $4 \\times V_{15} = 2{,}000$). The engineer computed $1{,}800 \\times 0.90 = 1{,}620$, which is $V$ times $PHF$ instead of $V$ divided by $PHF$. The flow rate should always be greater than or equal to the hourly volume, never less. Getting $1{,}620 < 1{,}800$ should have been a red flag. The choice claiming the PHF should be 1.11 is wrong because 0.90 is the correct PHF. The choice multiplying by 4 to get 7,200 veh/hr gives a nonsensical rate. The "no error was made" choice accepts the error.',
    hint: 'The peak flow rate equals $V/PHF$, not $V \\times PHF$. The result should always be greater than or equal to $V$.',
    steps: [
      {
        text: 'PHF check:',
        latex: 'PHF = \\frac{1{,}800}{4 \\times 500} = \\frac{1{,}800}{2{,}000} = 0.90 \\; \\checkmark'
      },
      {
        text: 'Correct flow rate:',
        latex: '\\text{Flow rate} = \\frac{V}{PHF} = \\frac{1{,}800}{0.90} = 2{,}000 \\text{ veh/hr}'
      },
      {
        text: 'The engineer computed $1{,}800 \\times 0.90 = 1{,}620$ (multiplied instead of dividing).',
        latex: null
      }
    ],
    handbookPage: 'p. 300',
    handbookFormula: 'PHF = \\frac{V}{4 \\times V_{15}}',
    videoUrl: null,
    traps: [
      'Multiplying by PHF instead of dividing -- the peak flow rate must be >= the hourly volume',
      'Accepting a flow rate lower than the hourly volume without question'
    ],
    diagram: null,
    lessonId: 'stopping-sight-distance',
    chapterId: 'transportation'
  },
  {
    id: 'trans-vc-ex1',
    type: 'computational',
    statement: 'A crest vertical curve connects a $+2\\%$ grade to a $-4\\%$ grade with a curve length $L = 600 \\text{ ft}$. What is the K-value (rate of vertical curvature)?',
    choices: [
      {
        id: 'c1',
        text: '$100$'
      },
      {
        id: 'c2',
        text: '$300$'
      },
      {
        id: 'c3',
        text: '$50$'
      },
      {
        id: 'c4',
        text: '$6$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: '$A = |g_2 - g_1| \\times 100 = |-0.04 - 0.02| \\times 100 = 0.06 \\times 100 = 6$. $K = L/A = 600/6 = 100$ ft per percent change. The 300 choice used $A = 2$ (only the magnitude of one grade, $L/2 = 300$). The 50 choice used $A = 12$ ($L/12 = 50$). The 6 choice confused $K$ with $A$ (it is just the algebraic difference, not the rate).',
    hint: '$K = L/A$, where $A = |g_2 - g_1| \\times 100$. Compute $A$ in percent first.',
    steps: [
      {
        text: 'Algebraic difference:',
        latex: 'A = |g_2 - g_1| \\times 100 = |-0.04 - 0.02| \\times 100 = 6'
      },
      {
        text: 'Rate of curvature:',
        latex: 'K = \\frac{L}{A} = \\frac{600}{6} = 100'
      }
    ],
    handbookPage: 'p. 301',
    handbookFormula: 'K = \\frac{L}{A}',
    videoUrl: null,
    traps: [
      'Confusing $K$ with $A$ -- $K$ is the ratio $L/A$, not the algebraic difference itself'
    ],
    diagram: {
      component: 'VerticalCurveProfile',
      props: {
        g1: 2,
        g2: -4,
        L: 600,
        elevPVC: 100
      }
    },
    lessonId: 'vertical-curves',
    chapterId: 'transportation'
  },
  {
    id: 'trans-vc-ex2',
    type: 'conceptual',
    statement: 'When computing the minimum length of a sag vertical curve, the headlight criterion is used instead of the driver eye height criterion used for crest curves. Why?',
    choices: [
      {
        id: 'c1',
        text: 'Sag curves are always shorter than crest curves, so a less restrictive criterion is needed'
      },
      {
        id: 'c2',
        text: 'On a sag curve at night, the line of sight is not blocked by the road surface -- the limiting factor is how far the headlights illuminate the road ahead'
      },
      {
        id: 'c3',
        text: 'The driver eye height is irrelevant on sag curves because the driver can always see over the curve'
      },
      {
        id: 'c4',
        text: 'Headlights are only used at night, so the sag curve criterion applies only to nighttime design'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'On a crest curve, the road surface itself blocks the driver from seeing objects beyond the hill -- so the sight distance depends on eye height and object height. On a sag curve, you can see over the valley during the day with no obstruction. But at night, you can only see as far as your headlights illuminate. The headlight beam angle (about 1 degree upward) and the mounting height determine how far down the sag the beam reaches. The "sag curves are always shorter" choice is wrong because that is simply untrue. The "driver can always see over the curve" choice is incomplete -- it only addresses daytime. The "applies only to nighttime design" choice is wrong because the nighttime case is precisely what governs the design.',
    hint: 'Think about what limits visibility on a sag curve versus a crest curve.',
    steps: [
      {
        text: 'Crest: Road surface blocks line of sight. Criterion uses driver eye height (3.5 ft) and object height (2.0 ft).',
        latex: null
      },
      {
        text: 'Sag: Road surface does not block line of sight during the day. At night, headlight beam range is the limiting factor.',
        latex: null
      },
      {
        text: 'The sag formula uses headlight height (2.0 ft) and 1-degree upward beam angle, giving $L = AS^2/(400 + 3.5S)$.',
        latex: null
      }
    ],
    handbookPage: 'p. 302',
    handbookFormula: 'L = \\frac{A S^2}{400 + 3.5S}',
    videoUrl: null,
    traps: ['Thinking the driver eye height criterion applies to both crest and sag curves'],
    diagram: null,
    lessonId: 'vertical-curves',
    chapterId: 'transportation'
  },
  {
    id: 'trans-vc-ex3',
    type: 'computational',
    statement: 'A sag vertical curve has $A = 6$ and required SSD $= 400 \\text{ ft}$. Using the headlight criterion with $S \\leq L$, what is the minimum curve length?',
    choices: [
      {
        id: 'c1',
        text: '$600 \\text{ ft}$'
      },
      {
        id: 'c2',
        text: '$444 \\text{ ft}$'
      },
      {
        id: 'c3',
        text: '$533 \\text{ ft}$'
      },
      {
        id: 'c4',
        text: '$400 \\text{ ft}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: '$L = AS^2/(400 + 3.5S) = 6 \\times 400^2/(400 + 3.5 \\times 400) = 6 \\times 160{,}000/(400 + 1{,}400) = 960{,}000/1{,}800 = 533$ ft. Verify: $S = 400 < L = 533$, so $S \\leq L$ is satisfied. The 444 ft option used the crest formula: $6 \\times 160{,}000/2{,}158 = 444$. The 600 ft option used $2S - \\text{constant}$. The 400 ft option confused $L$ with $S$.',
    hint: 'Sag headlight formula: $L = AS^2/(400 + 3.5S)$. Make sure you use the sag denominator, not the crest constant.',
    steps: [
      {
        text: 'Sag headlight formula ($S \\leq L$):',
        latex: 'L = \\frac{A S^2}{400 + 3.5S} = \\frac{6 \\times 400^2}{400 + 3.5(400)}'
      },
      {
        text: 'Calculate:',
        latex: 'L = \\frac{960{,}000}{1{,}800} = 533 \\text{ ft}'
      },
      {
        text: 'Verify: $S = 400 < L = 533$ \\checkmark',
        latex: null
      }
    ],
    handbookPage: 'p. 302',
    handbookFormula: 'L = \\frac{A S^2}{400 + 3.5S}',
    videoUrl: null,
    traps: [
      'Using the crest constant (2,158) instead of the sag denominator $(400 + 3.5S)$',
      'Forgetting to verify $S \\leq L$ after computing $L$'
    ],
    diagram: null,
    lessonId: 'vertical-curves',
    chapterId: 'transportation'
  },
  {
    id: 'trans-vc-ex4',
    type: 'conceptual',
    statement: 'A crest vertical curve is designed using the $S \\leq L$ formula, but after computing $L$, the engineer finds that $S > L$. What should the engineer do?',
    choices: [
      {
        id: 'c1',
        text: 'Recompute using the $S > L$ formula: $L = 2S - 2{,}158/A$'
      },
      {
        id: 'c2',
        text: 'Accept the result because the $S \\leq L$ formula always gives a conservative (longer) answer'
      },
      {
        id: 'c3',
        text: 'Average the results from both formulas for a more accurate answer'
      },
      {
        id: 'c4',
        text: 'Double the computed $L$ to ensure adequate sight distance'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'The two formulas are derived under different geometric assumptions. The $S \\leq L$ formula assumes the sight line stays within the curve limits, and the $S > L$ formula assumes the sight line extends beyond the curve ends. If you use $S \\leq L$ and get $L < S$, the assumption is violated, so the result is not valid. You must switch to $L = 2S - 2{,}158/A$. The "accept the conservative result" choice is wrong — the $S \\leq L$ formula does not always give a longer curve. In fact, when $S > L$ actually holds, the $S \\leq L$ formula can give a shorter $L$. The "average both formulas" choice has no theoretical basis. The "double the computed $L$" choice is arbitrary.',
    hint: 'The two crest formulas come from two different geometric cases. You must use the one that matches your result.',
    steps: [
      {
        text: 'Assume $S \\leq L$, compute $L = AS^2/2{,}158$. If the result gives $L < S$, the assumption is violated.',
        latex: null
      },
      {
        text: 'Switch to the $S > L$ formula:',
        latex: 'L = 2S - \\frac{2{,}158}{A}'
      },
      {
        text: 'The correct answer is the one where the assumption matches the result.',
        latex: null
      }
    ],
    handbookPage: 'p. 302',
    handbookFormula: 'L = 2S - \\frac{2{,}158}{A}',
    videoUrl: null,
    traps: [
      'Accepting a result where the assumption is violated without switching formulas',
      'Thinking the $S \\leq L$ formula is always conservative'
    ],
    diagram: null,
    lessonId: 'vertical-curves',
    chapterId: 'transportation'
  },
  {
    id: 'trans-hc-ex1',
    type: 'computational',
    statement: 'A horizontal curve has a radius $R = 1{,}146 \\text{ ft}$. What is the degree of curve $D$?',
    choices: [
      {
        id: 'c1',
        text: '$5\\degree$'
      },
      {
        id: 'c2',
        text: '$0.20\\degree$'
      },
      {
        id: 'c3',
        text: '$10\\degree$'
      },
      {
        id: 'c4',
        text: '$2.5\\degree$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: '$D = 5{,}729.58/R = 5{,}729.58/1{,}146 = 5.0$ degrees. This is the inverse of $R = 5{,}729.58/D$. The 0.20 choice divided $R$ by 5,729.58 instead of the other way around. The 10 choice used $R = 573$ (off by a factor of 2). The 2.5 choice doubled $R$ in the denominator.',
    hint: 'D = 5,729.58 / R. Just the inverse of the R-D relationship.',
    steps: [
      {
        text: 'Degree of curve:',
        latex: 'D = \\frac{5{,}729.58}{R} = \\frac{5{,}729.58}{1{,}146} = 5.0\\degree'
      }
    ],
    handbookPage: 'p. 302',
    handbookFormula: 'R = \\frac{5{,}729.58}{D}',
    videoUrl: null,
    traps: ['Dividing R by the constant instead of the constant by R'],
    diagram: null,
    lessonId: 'horizontal-curves',
    chapterId: 'transportation'
  },
  {
    id: 'trans-hc-ex2',
    type: 'conceptual',
    statement: 'On a horizontal curve, the tangent distance formula is $T = R \\tan(I/2)$. If an engineer mistakenly uses $\\tan(I)$ instead of $\\tan(I/2)$, what is the effect on the computed tangent distance?',
    choices: [
      {
        id: 'c1',
        text: 'The computed T will be too small, leading to an underestimate of the tangent length'
      },
      {
        id: 'c2',
        text: 'The computed T will be too large, leading to an overestimate of the tangent length'
      },
      {
        id: 'c3',
        text: 'No effect because $\\tan(I) = 2\\tan(I/2)$ for all angles'
      },
      {
        id: 'c4',
        text: 'The effect depends on whether $I$ is greater or less than $90\\degree$'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'For any angle $I$ between 0 and 180 degrees (realistic for curves), $\\tan(I) > \\tan(I/2)$ since the tangent function is increasing on $(0\\degree, 90\\degree)$ and $I/2 < I$. So using $\\tan(I)$ gives a larger number, making $T$ too large. The "too small / underestimate" choice gets the direction wrong. The "no effect because $\\tan(I) = 2\\tan(I/2)$" choice states a false identity -- $\\tan(I)$ is NOT equal to $2\\tan(I/2)$ in general. The "depends on whether $I$ is greater or less than $90\\degree$" choice is wrong because for typical highway intersection angles (well under $90\\degree$), the effect is always an overestimate.',
    hint: 'For angles between 0 and 90 degrees, how does tan(I) compare to tan(I/2)?',
    steps: [
      {
        text: 'For typical curve intersection angles ($0 < I < 90\\degree$), $\\tan(I/2)$ uses a smaller argument than $\\tan(I)$, and both arguments stay in the range where tangent is increasing and positive.',
        latex: null
      },
      {
        text: 'Since tangent is increasing on $(0\\degree, 90\\degree)$, $\\tan(I) > \\tan(I/2)$ for typical intersection angles.',
        latex: null
      },
      {
        text: 'Therefore $R\\tan(I) > R\\tan(I/2)$, and the computed T is too large.',
        latex: null
      }
    ],
    handbookPage: 'p. 302',
    handbookFormula: 'T = R \\tan(I/2)',
    videoUrl: null,
    traps: ['Assuming tan(I) = 2 tan(I/2), which is not a valid trigonometric identity'],
    diagram: null,
    lessonId: 'horizontal-curves',
    chapterId: 'transportation'
  },
  {
    id: 'trans-hc-ex3',
    type: 'computational',
    statement: 'A horizontal curve has $R = 800 \\text{ ft}$ and intersection angle $I = 50\\degree$. What is the curve length $L$?',
    choices: [
      {
        id: 'c1',
        text: '$373 \\text{ ft}$'
      },
      {
        id: 'c2',
        text: '$466 \\text{ ft}$'
      },
      {
        id: 'c3',
        text: '$698 \\text{ ft}$'
      },
      {
        id: 'c4',
        text: '$1{,}396 \\text{ ft}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: '$L = R \\times I \\times (\\pi/180) = 800 \\times 50 \\times (\\pi/180) = 800 \\times 0.8727 = 698$ ft. The 373 ft choice is the tangent distance $T = R\\tan(I/2) = 800 \\times \\tan(25\\degree) = 373$, not the curve length. The 466 ft choice incorrectly used a modified radian conversion. The 1,396 ft choice doubled the curve length for no reason: $2 \\times 698$.',
    hint: 'L = R x I x (pi/180). Make sure I is in degrees and you convert to radians.',
    steps: [
      {
        text: 'Curve length:',
        latex: 'L = R \\cdot I \\cdot \\frac{\\pi}{180} = 800 \\times 50 \\times \\frac{\\pi}{180} = 800 \\times 0.8727 = 698 \\text{ ft}'
      }
    ],
    handbookPage: 'p. 302',
    handbookFormula: 'L = R \\, I \\, \\frac{\\pi}{180}',
    videoUrl: null,
    traps: [
      'Confusing curve length L with tangent distance T',
      'Forgetting to convert the intersection angle from degrees to radians'
    ],
    diagram: {
      component: 'HorizontalCurve',
      props: {
        R: 800,
        I: 50
      }
    },
    lessonId: 'horizontal-curves',
    chapterId: 'transportation'
  },
  {
    id: 'trans-hc-ex4',
    type: 'conceptual',
    statement: 'A curve with design speed $V = 55 \\text{ mph}$, radius $R = 900 \\text{ ft}$, and superelevation $e = 6\\%$ is analyzed. If the side friction demand exceeds the available friction factor $f$, what does this indicate about the design?',
    choices: [
      {
        id: 'c1',
        text: 'The curve radius is too tight for the design speed and superelevation -- vehicles may slide outward'
      },
      {
        id: 'c2',
        text: 'The curve is overdesigned and the radius should be reduced'
      },
      {
        id: 'c3',
        text: 'The superelevation is too high and should be lowered'
      },
      {
        id: 'c4',
        text: 'The design is acceptable because friction demand varies with weather'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'From $0.01e + f = V^2/(15R)$, the required side friction is $f = V^2/(15R) - 0.01e = 55^2/(15 \\times 900) - 0.06 = 3{,}025/13{,}500 - 0.06 = 0.224 - 0.06 = 0.164$. Typical max $f$ values for 55 mph are around 0.13--0.14. If the demand (0.164) exceeds the supply, vehicles cannot maintain the curve at that speed without skidding outward. The fix is a larger radius, lower speed, or higher superelevation. The choice to reduce the radius makes the problem worse (smaller R raises V^2/15R). The choice to reduce superelevation also worsens friction demand. The choice claiming the design is acceptable dismisses a real safety concern.',
    hint: 'When friction demand exceeds supply, the centripetal force requirement exceeds what the tires and road can provide.',
    steps: [
      {
        text: 'Required friction: $f = V^2/(15R) - 0.01e$. If this exceeds available $f$, the vehicle cannot hold the curve.',
        latex: null
      },
      {
        text: 'A larger radius R reduces $V^2/(15R)$, reducing friction demand.',
        latex: null
      },
      {
        text: 'If friction demand > supply, vehicles tend to slide outward (understeer), which is a safety hazard.',
        latex: null
      }
    ],
    handbookPage: 'p. 303',
    handbookFormula: '0.01e + f = \\frac{V^2}{15R}',
    videoUrl: null,
    traps: [
      'Thinking a smaller radius fixes the problem -- it makes friction demand worse',
      'Assuming friction surplus means overdesign when in fact it means adequate design margin'
    ],
    diagram: null,
    lessonId: 'horizontal-curves',
    chapterId: 'transportation'
  },
  {
    id: 'trans-st-ex1',
    type: 'computational',
    statement: 'An approach has a speed of $40 \\text{ mph}$ on a level grade. Using $t = 1.0 \\text{ s}$ and $a = 10 \\text{ ft/sec}^2$, what is the yellow interval?',
    choices: [
      {
        id: 'c1',
        text: '$3.9 \\text{ sec}$'
      },
      {
        id: 'c2',
        text: '$3.0 \\text{ sec}$'
      },
      {
        id: 'c3',
        text: '$6.9 \\text{ sec}$'
      },
      {
        id: 'c4',
        text: '$2.9 \\text{ sec}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Convert 40 mph to ft/sec: $40 \\times 1.467 = 58.7$ ft/sec. Then $y = t + v/(2a) = 1.0 + 58.7/(2 \\times 10) = 1.0 + 58.7/20 = 1.0 + 2.93 = 3.93$, which rounds to 3.9 sec. The 3.0 sec choice used mph directly: $1.0 + 40/20 = 3.0$. The 6.9 sec choice used $v/a$ instead of $v/(2a)$: $1.0 + 58.7/10 = 6.87$. The 2.9 sec choice forgot the reaction time: $58.7/20 = 2.93$.',
    hint: 'Convert to ft/sec first, then y = t + v/(2a). Do not forget the factor of 2.',
    steps: [
      {
        text: 'Convert speed:',
        latex: 'v = 40 \\times 1.467 = 58.7 \\text{ ft/sec}'
      },
      {
        text: 'Yellow interval:',
        latex: 'y = 1.0 + \\frac{58.7}{2 \\times 10} = 1.0 + 2.93 = 3.9 \\text{ sec}'
      }
    ],
    handbookPage: 'p. 300',
    handbookFormula: 'y = t + \\frac{v}{2a \\pm 64.4G}',
    videoUrl: null,
    traps: ['Using mph instead of ft/sec in the formula'],
    diagram: null,
    lessonId: 'signal-timing',
    chapterId: 'transportation'
  },
  {
    id: 'trans-st-ex2',
    type: 'conceptual',
    statement: 'The all-red clearance interval formula is $r = (W + l)/v$. Why is the vehicle length $l$ included in the numerator?',
    choices: [
      {
        id: 'c1',
        text: 'The vehicle length accounts for the acceleration distance needed to enter the intersection'
      },
      {
        id: 'c2',
        text: 'The vehicle must travel the full intersection width plus its own length to completely clear the far side before conflicting traffic enters'
      },
      {
        id: 'c3',
        text: 'The vehicle length is a safety buffer added to account for driver hesitation'
      },
      {
        id: 'c4',
        text: 'The vehicle length adjusts for the distance between the stop bar and the curb line'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'When the signal turns red, a vehicle that just entered must cross the entire intersection width $W$ before the conflicting phase starts. But the vehicle is not a point -- the rear bumper must also clear the far side. So the total clearance distance is $W$ (intersection width) plus $l$ (vehicle length). If you only used $W$, the tail end of the vehicle would still be in the intersection when cross traffic gets the green. The acceleration-distance choice confuses clearance with acceleration. The driver-hesitation safety-buffer choice has no basis in the formula derivation. The stop-bar-to-curb choice misidentifies what $l$ represents.',
    hint: 'Think about what it means for a vehicle to "completely clear" the intersection -- where does its rear bumper need to be?',
    steps: [
      {
        text: 'The vehicle enters at the near curb and must exit past the far curb.',
        latex: null
      },
      {
        text: 'The front bumper travels $W$, but the rear bumper is still $l$ feet behind.',
        latex: null
      },
      {
        text: 'Total distance to fully clear: $W + l$, giving $r = (W + l)/v$.',
        latex: null
      }
    ],
    handbookPage: 'p. 300',
    handbookFormula: 'r = \\frac{W + l}{v}',
    videoUrl: null,
    traps: [
      'Thinking the vehicle length is a safety factor rather than a geometric requirement'
    ],
    diagram: null,
    lessonId: 'signal-timing',
    chapterId: 'transportation'
  },
  {
    id: 'trans-st-ex3',
    type: 'computational',
    statement: 'An intersection approach has speed $45 \\text{ mph}$ on a $3\\%$ downgrade. Using $t = 1.0 \\text{ s}$ and $a = 10 \\text{ ft/sec}^2$, what is the yellow interval?',
    choices: [
      {
        id: 'c1',
        text: '$3.5 \\text{ sec}$'
      },
      {
        id: 'c2',
        text: '$4.3 \\text{ sec}$'
      },
      {
        id: 'c3',
        text: '$4.7 \\text{ sec}$'
      },
      {
        id: 'c4',
        text: '$3.3 \\text{ sec}$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Convert 45 mph: $v = 45 \\times 1.467 = 66.0$ ft/sec. On a 3% downgrade, gravity opposes braking, reducing effective deceleration. The denominator becomes $2a - 64.4(0.03) = 20 - 1.932 = 18.07$. $y = 1.0 + 66.0/18.07 = 1.0 + 3.65 = 4.65$, approximately 4.7 sec. The 4.3 sec option used a level grade ($G = 0$): $1.0 + 66.0/20 = 4.3$. The 3.5 sec option used mph instead of ft/sec: $1.0 + 45/18.07 = 3.5$. The 3.3 sec option used both mph and level grade: $1.0 + 45/20 = 3.25$.',
    hint: 'Downgrade reduces effective deceleration. The denominator becomes 2a - 64.4G where G = 0.03 for a 3% downgrade.',
    steps: [
      {
        text: 'Convert speed:',
        latex: 'v = 45 \\times 1.467 = 66.0 \\text{ ft/sec}'
      },
      {
        text: 'Effective deceleration term (downgrade):',
        latex: '2a - 64.4G = 2(10) - 64.4(0.03) = 20 - 1.93 = 18.07'
      },
      {
        text: 'Yellow interval:',
        latex: 'y = 1.0 + \\frac{66.0}{18.07} = 1.0 + 3.65 = 4.7 \\text{ sec}'
      }
    ],
    handbookPage: 'p. 300',
    handbookFormula: 'y = t + \\frac{v}{2a \\pm 64.4G}',
    videoUrl: null,
    traps: [
      'Ignoring the grade adjustment and using a level-grade denominator',
      'Reversing the grade sign -- downhill reduces effective deceleration, making yellow longer'
    ],
    diagram: null,
    lessonId: 'signal-timing',
    chapterId: 'transportation'
  },
  {
    id: 'trans-st-ex4',
    type: 'conceptual',
    statement: 'A traffic engineer designs a signal with a yellow interval of $3.0 \\text{ sec}$ for an approach with design speed $50 \\text{ mph}$. Using $t = 1.0 \\text{ s}$ and $a = 10 \\text{ ft/sec}^2$, is this yellow time adequate?',
    choices: [
      {
        id: 'c1',
        text: 'No -- the required yellow is 4.7 sec; using 3.0 sec creates a dilemma zone where drivers can neither stop nor clear the intersection'
      },
      {
        id: 'c2',
        text: 'Yes -- 3.0 sec is the standard minimum yellow for all approach speeds'
      },
      {
        id: 'c3',
        text: 'Yes -- the 3.0 sec yellow is adequate because drivers will slow down on approach'
      },
      {
        id: 'c4',
        text: 'No -- but the shortfall can be made up by extending the all-red interval'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'Compute the required yellow: v = 50 x 1.467 = 73.3 ft/sec. y = 1.0 + 73.3/(2 x 10) = 1.0 + 3.67 = 4.67, approximately 4.7 sec. The actual yellow of 3.0 sec is 1.7 sec too short. This creates a "dilemma zone" -- a region where a driver is too close to stop safely but too far to clear the intersection during the yellow. This is a serious safety problem. The "3.0 sec is the standard minimum for all speeds" option is wrong because yellow time is speed-dependent. The "adequate because drivers will slow down" option assumes drivers slow down, but the design must accommodate the design speed. The "make up the shortfall with the all-red interval" option is wrong because the all-red serves a different purpose (clearance of vehicles already in the intersection, not stopping decisions).',
    hint: 'Compute the required yellow and compare. What happens when yellow is shorter than needed?',
    steps: [
      {
        text: 'Required yellow:',
        latex: 'y = 1.0 + \\frac{73.3}{20} = 1.0 + 3.67 = 4.7 \\text{ sec}'
      },
      {
        text: 'Provided: 3.0 sec. Deficit: $4.7 - 3.0 = 1.7$ sec.',
        latex: null
      },
      {
        text: 'A deficit creates a dilemma zone where drivers at certain distances can neither stop nor clear safely.',
        latex: null
      }
    ],
    handbookPage: 'p. 300',
    handbookFormula: 'y = t + \\frac{v}{2a \\pm 64.4G}',
    videoUrl: null,
    traps: [
      'Assuming a fixed minimum yellow works for all speeds',
      'Thinking the all-red interval can compensate for an inadequate yellow'
    ],
    diagram: null,
    lessonId: 'signal-timing',
    chapterId: 'transportation'
  },
  {
    id: 'trans-tf-ex1',
    type: 'computational',
    statement: 'A freeway has free-flow speed $S_f = 60 \\text{ mph}$ and jam density $D_j = 200 \\text{ veh/mi/ln}$. What is the optimum density at maximum flow?',
    choices: [
      {
        id: 'c1',
        text: '$100 \\text{ veh/mi/ln}$'
      },
      {
        id: 'c2',
        text: '$200 \\text{ veh/mi/ln}$'
      },
      {
        id: 'c3',
        text: '$50 \\text{ veh/mi/ln}$'
      },
      {
        id: 'c4',
        text: '$150 \\text{ veh/mi/ln}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'At maximum flow, the optimum density is exactly half the jam density: $D_o = D_j/2 = 200/2 = 100$ veh/mi/ln. This comes straight from the Greenshields model. The choice 200 is the jam density itself, not the optimum. The choice 50 divides the jam density by 4 instead of 2. The choice 150 is three-quarters of the jam density, which has no significance in the model.',
    hint: 'At maximum flow, both speed and density are half their extreme values.',
    steps: [
      {
        text: 'Optimum density at max flow:',
        latex: 'D_o = \\frac{D_j}{2} = \\frac{200}{2} = 100 \\text{ veh/mi/ln}'
      }
    ],
    handbookPage: 'p. 306',
    handbookFormula: 'D_o = \\frac{D_j}{2}',
    videoUrl: null,
    traps: ['Using $D_j$ directly as the optimum density instead of dividing by 2'],
    diagram: null,
    lessonId: 'traffic-flow',
    chapterId: 'transportation'
  },
  {
    id: 'trans-tf-ex2',
    type: 'conceptual',
    statement: 'In the Greenshields model, what happens to flow as density increases from zero toward jam density?',
    choices: [
      {
        id: 'c1',
        text: 'Flow increases linearly until it reaches jam density'
      },
      {
        id: 'c2',
        text: 'Flow increases to a maximum at half the jam density, then decreases back to zero'
      },
      {
        id: 'c3',
        text: 'Flow remains constant regardless of density'
      },
      {
        id: 'c4',
        text: 'Flow decreases monotonically from free-flow conditions to jam density'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'The Greenshields model produces a parabolic flow-density curve. At zero density, flow is zero (no cars). As density increases, flow rises to a peak at $D = D_j/2$, then falls back to zero at jam density (cars are bumper-to-bumper, speed = 0). The "increases linearly until jam density" option incorrectly assumes a linear relationship. The "flow remains constant" option ignores the speed-density tradeoff. The "decreases monotonically from free-flow to jam density" option describes a monotonically decreasing function, but flow actually starts at zero when there are no vehicles.',
    hint: 'The flow-density curve from the Greenshields model is a parabola. Where is its peak?',
    steps: [
      {
        text: 'At $D = 0$: $V = S_f \\times 0 = 0$ (no vehicles, no flow).',
        latex: null
      },
      {
        text: 'At $D = D_j/2$: flow reaches its maximum $V_m = D_j S_f / 4$.',
        latex: null
      },
      {
        text: 'At $D = D_j$: $S = 0$ (jam), so $V = 0 \\times D_j = 0$.',
        latex: null
      }
    ],
    handbookPage: 'p. 306',
    handbookFormula: 'V = S \\times D',
    videoUrl: null,
    traps: [
      'Assuming flow increases linearly with density instead of following a parabolic curve'
    ],
    diagram: null,
    lessonId: 'traffic-flow',
    chapterId: 'transportation'
  },
  {
    id: 'trans-tf-ex3',
    type: 'computational',
    statement: 'A 2-mile road segment has an ADT of $12{,}000 \\text{ veh/day}$ and recorded $8$ crashes over a 3-year period. What is the crash rate per million vehicle-miles traveled (RMVM)?',
    choices: [
      {
        id: 'c1',
        text: '$109.6$'
      },
      {
        id: 'c2',
        text: '$0.91$'
      },
      {
        id: 'c3',
        text: '$0.30$'
      },
      {
        id: 'c4',
        text: '$1.10$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: '$VMT = ADT \\times \\text{days} \\times \\text{length} = 12{,}000 \\times (365 \\times 3) \\times 2 = 12{,}000 \\times 1{,}095 \\times 2 = 26{,}280{,}000$ vehicle-miles. $RMVM = A \\times 1{,}000{,}000 / VMT = 8 \\times 1{,}000{,}000 / 26{,}280{,}000 = 0.304$ which rounds to 0.30. The 0.91 distractor used only 1 year instead of 3: $VMT = 8{,}760{,}000$, $RMVM = 8{,}000{,}000/8{,}760{,}000 = 0.91$. The 109.6 distractor mis-scales the result (omits the segment length and misapplies the million factor). The 1.10 distractor underestimates VMT by using a reduced length and/or period.',
    hint: '$VMT = ADT \\times \\text{total days} \\times \\text{segment length}$. Use the full study period, not just one year.',
    steps: [
      {
        text: 'Total vehicle-miles traveled:',
        latex: 'VMT = 12{,}000 \\times (365 \\times 3) \\times 2 = 12{,}000 \\times 1{,}095 \\times 2 = 26{,}280{,}000'
      },
      {
        text: 'Crash rate:',
        latex: 'RMVM = \\frac{8 \\times 1{,}000{,}000}{26{,}280{,}000} = 0.30 \\text{ crashes/MVM}'
      }
    ],
    handbookPage: 'p. 307',
    handbookFormula: 'RMVM = \\frac{A \\times 1{,}000{,}000}{VMT}',
    videoUrl: null,
    traps: [
      'Using only one year of data when the study covers multiple years',
      'Forgetting to include the segment length in VMT'
    ],
    diagram: null,
    lessonId: 'traffic-flow',
    chapterId: 'transportation'
  },
  {
    id: 'trans-tf-ex4',
    type: 'conceptual',
    statement: 'An engineer computes the RMEV for two intersections. Intersection A has RMEV $= 3.5$ and Intersection B has RMEV $= 1.8$. The ADT at Intersection A is twice the ADT at Intersection B. Which statement is correct?',
    choices: [
      {
        id: 'c1',
        text: 'Intersection A has a higher crash rate per vehicle exposure, so it may warrant safety improvements first'
      },
      {
        id: 'c2',
        text: 'Intersection A is safer because it carries more traffic'
      },
      {
        id: 'c3',
        text: 'The two intersections cannot be compared because they have different ADTs'
      },
      {
        id: 'c4',
        text: 'Intersection B is more dangerous because a lower RMEV means more severe crashes'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'RMEV already normalizes crashes by exposure (per million entering vehicles), so different ADTs are already accounted for. A higher RMEV means more crashes per million vehicles, regardless of total volume. Intersection A at 3.5 has nearly double the crash rate of B at 1.8, making it the stronger candidate for safety review. The "safer because it carries more traffic" choice confuses volume with safety. The "cannot be compared" choice is wrong because RMEV exists precisely to enable such comparisons. The "lower RMEV means more severe crashes" choice reverses the meaning of RMEV.',
    hint: 'RMEV already accounts for traffic volume differences. Higher RMEV = higher crash rate per vehicle.',
    steps: [
      {
        text: 'RMEV = crashes per million entering vehicles. It normalizes by exposure, so different ADTs are already handled.',
        latex: null
      },
      {
        text: 'Intersection A: 3.5 crashes/MEV > Intersection B: 1.8 crashes/MEV.',
        latex: null
      },
      {
        text: 'Higher RMEV means worse crash performance per vehicle, so A may need safety attention first.',
        latex: null
      }
    ],
    handbookPage: 'p. 307',
    handbookFormula: 'RMEV = \\frac{A \\times 1{,}000{,}000}{V}',
    videoUrl: null,
    traps: [
      'Thinking higher volume means more dangerous regardless of the rate',
      'Believing different ADTs make RMEV comparisons invalid'
    ],
    diagram: null,
    lessonId: 'traffic-flow',
    chapterId: 'transportation'
  },
  {
    id: 'trans-cl-ex1',
    type: 'computational',
    statement: 'A freeway segment has a free-flow speed of $110\\,\\text{km/h}$, 3 lanes per direction, and a peak-hour volume of 5400 vehicles. If the peak-hour factor (PHF) is 0.90, what is the peak 15-minute flow rate per lane?',
    choices: [
      {
        id: 'c1',
        text: '1800 veh/h/ln'
      },
      {
        id: 'c2',
        text: '2000 veh/h/ln'
      },
      {
        id: 'c3',
        text: '2400 veh/h/ln'
      },
      {
        id: 'c4',
        text: '6000 veh/h/ln'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'The peak 15-min flow rate adjusts the hourly volume for the peaking within the hour: $V_p = V/(PHF \\times N) = 5400/(0.90 \\times 3) = 5400/2.7 = 2000$ veh/h/ln. The PHF accounts for the fact that traffic does not flow uniformly throughout the hour. Common trap is forgetting to divide by the number of lanes.',
    hint: 'Use $V_p = V/(PHF \\times N)$ where $N$ is the number of lanes.',
    steps: [
      {
        text: 'Peak 15-minute flow rate per lane:',
        latex: 'V_p = \\frac{V}{PHF \\times N}'
      },
      {
        text: 'Substitute:',
        latex: 'V_p = \\frac{5400}{0.90 \\times 3} = \\frac{5400}{2.7}'
      },
      {
        text: 'Calculate:',
        latex: 'V_p = 2000\\,\\text{veh/h/ln}'
      }
    ],
    handbookPage: 'p. 296',
    handbookFormula: 'V_p = \\frac{V}{PHF \\times N \\times f_{HV} \\times f_p}',
    videoUrl: null,
    traps: [
      'Forgetting to divide by the number of lanes',
      'Using PHF as a multiplier instead of dividing by it'
    ],
    diagram: null,
    lessonId: 'capacity-los',
    chapterId: 'transportation'
  },
  {
    id: 'trans-cl-ex2',
    type: 'conceptual',
    statement: 'On a freeway operating at Level of Service (LOS) F, which condition is most likely occurring?',
    choices: [
      {
        id: 'c1',
        text: 'Free-flow conditions with high speeds'
      },
      {
        id: 'c2',
        text: 'Stable flow with some speed reductions'
      },
      {
        id: 'c3',
        text: 'Forced or breakdown flow with stop-and-go conditions'
      },
      {
        id: 'c4',
        text: 'Near-capacity flow with minor delays'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'easy',
    eli5: 'LOS grades go from A (best, free flow) to F (worst, breakdown). LOS F means demand exceeds capacity — you get queuing, stop-and-go traffic, and long delays. LOS A-C is good, D is approaching unstable, E is at capacity, F is breakdown. This is one of those definitions the FE loves to test.',
    hint: 'LOS uses a grading scale A through F — what does F represent?',
    steps: [
      {
        text: 'LOS A: Free flow, high speeds, low density.',
        latex: null
      },
      {
        text: 'LOS E: At capacity, unstable flow.',
        latex: null
      },
      {
        text: 'LOS F: Forced/breakdown flow — demand exceeds capacity, stop-and-go conditions.',
        latex: null
      }
    ],
    handbookPage: 'p. 296',
    handbookFormula: null,
    videoUrl: null,
    traps: ['Confusing LOS E (at capacity) with LOS F (breakdown)'],
    diagram: null,
    lessonId: 'capacity-los',
    chapterId: 'transportation'
  },
  {
    id: 'trans-cl-ex3',
    type: 'computational',
    statement: 'A 3-lane directional freeway carries $V = 3{,}500\\,\\text{veh/hr}$ with $PHF = 0.92$, $15\\%$ trucks ($P_T = 0.15$), and rolling terrain ($E_T = 3.0$). The mean speed is $55\\,\\text{mph}$. What is the density?',
    choices: [
      {
        id: 'c1',
        text: '$30.0\\,\\text{pc/mi/ln}$'
      },
      {
        id: 'c2',
        text: '$23.1\\,\\text{pc/mi/ln}$'
      },
      {
        id: 'c3',
        text: '$26.5\\,\\text{pc/mi/ln}$'
      },
      {
        id: 'c4',
        text: '$27.6\\,\\text{pc/mi/ln}$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Three steps. First, $f_{HV} = 1/(1 + 0.15(3.0 - 1)) = 1/1.30 = 0.769$. Second, $v_p = 3{,}500/(0.92 \\times 3 \\times 0.769) = 3{,}500/2.122 = 1{,}650$ pc/h/ln. Third, $D = 1{,}650/55 = 30.0$ pc/mi/ln (LOS D). The 23.1 option dropped $f_{HV}$ entirely. The 26.5 option used level-terrain $E_T = 2.0$ instead of rolling terrain $E_T = 3.0$. The 27.6 option forgot PHF.',
    hint: 'Compute fHV first (rolling terrain uses $E_T = 3.0$), then $v_p$, then $D = v_p / S$.',
    steps: [
      {
        text: 'Heavy-vehicle factor:',
        latex: 'f_{HV} = \\frac{1}{1 + 0.15(3.0 - 1)} = \\frac{1}{1.30} = 0.769'
      },
      {
        text: 'Demand flow rate:',
        latex: 'v_p = \\frac{3{,}500}{0.92 \\times 3 \\times 0.769} = \\frac{3{,}500}{2.122} = 1{,}650\\,\\text{pc/h/ln}'
      },
      {
        text: 'Density:',
        latex: 'D = \\frac{v_p}{S} = \\frac{1{,}650}{55} = 30.0\\,\\text{pc/mi/ln}'
      }
    ],
    handbookPage: 'pp. 305-306',
    handbookFormula: 'D = \\frac{v_p}{S}, \\quad v_p = \\frac{V}{PHF \\times N \\times f_{HV}}',
    videoUrl: null,
    traps: [
      'Using level-terrain $E_T = 2.0$ when the problem states rolling terrain ($E_T = 3.0$)',
      'Dropping $f_{HV}$ from the flow-rate equation'
    ],
    diagram: null,
    lessonId: 'capacity-los',
    chapterId: 'transportation'
  },
  {
    id: 'trans-cl-ex4',
    type: 'conceptual',
    statement: 'A freeway analysis produces a density of $34\\,\\text{pc/mi/ln}$. If the heavy-vehicle adjustment factor $f_{HV}$ was accidentally set to $1.0$ instead of its true value of $0.85$, what would happen to the computed density and LOS?',
    choices: [
      {
        id: 'c1',
        text: 'The computed density would be lower than actual, potentially understating congestion'
      },
      {
        id: 'c2',
        text: 'The computed density would be higher than actual, overstating congestion'
      },
      {
        id: 'c3',
        text: 'Density would be unchanged because $f_{HV}$ only affects speed'
      },
      {
        id: 'c4',
        text: 'The LOS would improve because passenger cars flow more smoothly'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: '$f_{HV}$ appears in the denominator of $v_p = V/(PHF \\times N \\times f_{HV})$. If you set $f_{HV} = 1.0$ when it should be 0.85, the denominator gets bigger, making $v_p$ smaller. A smaller $v_p$ means a smaller density $D = v_p/S$, which could shift the LOS one or two grades better than reality. You would think the road is less congested than it actually is. The real-world effect of trucks is that they take up more road space, so ignoring their impact makes the analysis unconservative.',
    hint: '$f_{HV}$ is in the denominator of $v_p$. What happens to $v_p$ when you make the denominator bigger?',
    steps: [
      {
        text: '$v_p = V/(PHF \\times N \\times f_{HV})$. Setting $f_{HV} = 1.0 > 0.85$ increases the denominator.',
        latex: null
      },
      {
        text: 'Larger denominator means smaller $v_p$, which means smaller $D = v_p/S$.',
        latex: null
      },
      {
        text: 'Smaller density maps to a better LOS grade, underestimating the actual congestion.',
        latex: null
      }
    ],
    handbookPage: 'p. 305',
    handbookFormula: 'v_p = \\frac{V}{PHF \\times N \\times f_{HV}}',
    videoUrl: null,
    traps: [
      'Thinking a higher fHV makes density worse -- fHV is in the denominator, so a higher value reduces vp',
      'Confusing the direction of the error -- ignoring trucks underestimates congestion, not overestimates it'
    ],
    diagram: null,
    lessonId: 'capacity-los',
    chapterId: 'transportation'
  },
  {
    id: 'trans-pd-ex1',
    type: 'computational',
    statement: 'A flexible pavement has: surface $a_1 = 0.44$, $D_1 = 5 \\text{ in}$; base $a_2 = 0.14$, $D_2 = 10 \\text{ in}$, $m_2 = 0.90$; subbase $a_3 = 0.11$, $D_3 = 8 \\text{ in}$, $m_3 = 0.90$. What is the structural number?',
    choices: [
      {
        id: 'c1',
        text: '$4.26$'
      },
      {
        id: 'c2',
        text: '$4.58$'
      },
      {
        id: 'c3',
        text: '$3.46$'
      },
      {
        id: 'c4',
        text: '$0.69$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: '$SN = a_1D_1 + a_2D_2m_2 + a_3D_3m_3 = 0.44(5) + 0.14(10)(0.90) + 0.11(8)(0.90) = 2.20 + 1.26 + 0.792 = 4.252$, which rounds to 4.26. The 4.58 choice used $m = 1.0$ for all layers: $2.20 + 1.40 + 0.88 = 4.48$ (a near-miss distractor for ignoring drainage coefficients). The 3.46 choice forgot the subbase entirely: $2.20 + 1.26$. The 0.69 choice summed only the coefficients.',
    hint: 'Multiply each layer: coefficient x thickness x drainage, then add them all up.',
    steps: [
      {
        text: 'Surface:',
        latex: 'a_1 D_1 = 0.44 \\times 5 = 2.20'
      },
      {
        text: 'Base:',
        latex: 'a_2 D_2 m_2 = 0.14 \\times 10 \\times 0.90 = 1.26'
      },
      {
        text: 'Subbase:',
        latex: 'a_3 D_3 m_3 = 0.11 \\times 8 \\times 0.90 = 0.792'
      },
      {
        text: 'Total:',
        latex: 'SN = 2.20 + 1.26 + 0.792 = 4.25 \\approx 4.26'
      }
    ],
    handbookPage: 'p. 308',
    handbookFormula: 'SN = a_1 D_1 + a_2 D_2 m_2 + a_3 D_3 m_3',
    videoUrl: null,
    traps: ['Ignoring the drainage coefficients and using m = 1.0 for all layers'],
    diagram: {
      component: 'PavementStack',
      props: {
        surface: {
          a: 0.44,
          D: 5,
          label: 'HMA Surface'
        },
        base: {
          a: 0.14,
          D: 10,
          m: 0.9,
          label: 'Crushed Stone Base'
        },
        subbase: {
          a: 0.11,
          D: 8,
          m: 0.9,
          label: 'Granular Subbase'
        }
      }
    },
    lessonId: 'pavement-design',
    chapterId: 'transportation'
  },
  {
    id: 'trans-pd-ex2',
    type: 'conceptual',
    statement: 'In the AASHTO flexible pavement design, the drainage coefficient $m$ for base and subbase layers accounts for:',
    choices: [
      {
        id: 'c1',
        text: 'The compaction level achieved during construction'
      },
      {
        id: 'c2',
        text: 'The expected moisture conditions and quality of drainage, which reduce the effective structural contribution of granular layers'
      },
      {
        id: 'c3',
        text: 'The traffic loading applied to each individual layer'
      },
      {
        id: 'c4',
        text: 'The temperature susceptibility of asphalt layers'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'The drainage coefficient $m$ adjusts for how well water drains from the granular base and subbase layers. Poor drainage means water sits in the layer, weakening it and reducing its effective structural contribution. Values of $m < 1.0$ penalize layers with poor drainage; $m = 1.0$ means good drainage. The surface course (layer 1) always uses $m = 1.0$ by convention because asphalt is relatively impermeable. The compaction-level choice describes a construction quality issue, not drainage. The traffic-loading choice is captured by ESALs, not by m. The temperature-susceptibility choice applies to asphalt, not granular layers.',
    hint: 'The drainage coefficient modifies granular layer contributions based on moisture and drainage quality.',
    steps: [
      {
        text: 'Drainage coefficients $m$ apply to base and subbase (granular layers), not the surface.',
        latex: null
      },
      {
        text: 'Good drainage: $m \\approx 1.0$. Poor drainage: $m < 1.0$ (e.g., $m = 0.80$).',
        latex: null
      },
      {
        text: 'A lower $m$ reduces the effective SN contribution, requiring thicker layers.',
        latex: null
      }
    ],
    handbookPage: 'p. 308',
    handbookFormula: 'SN = a_1 D_1 + a_2 D_2 m_2 + a_3 D_3 m_3',
    videoUrl: null,
    traps: [
      'Thinking m applies to the asphalt surface layer -- the surface always uses m = 1.0'
    ],
    diagram: null,
    lessonId: 'pavement-design',
    chapterId: 'transportation'
  },
  {
    id: 'trans-pd-ex3',
    type: 'computational',
    statement: 'A road receives $500$ passes/year of a $32{,}000 \\text{ lb}$ tandem-axle load and $200$ passes/year of a $20{,}000 \\text{ lb}$ single-axle load. The LEF for a 32,000 lb tandem axle is $1.11$ and the LEF for a 20,000 lb single axle is $1.51$. How many total annual ESALs do these loads produce?',
    choices: [
      {
        id: 'c1',
        text: '$555$'
      },
      {
        id: 'c2',
        text: '$700$'
      },
      {
        id: 'c3',
        text: '$857$'
      },
      {
        id: 'c4',
        text: '$1{,}310$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'For each load type, multiply passes by LEF, then add: Tandem: $500 \\times 1.11 = 555$. Single: $200 \\times 1.51 = 302$. Total $= 555 + 302 = 857$ ESALs. The 700 option assumed LEF $= 1.0$ for both: $500 + 200 = 700$. The 555 option only counted the tandem axle and forgot the single. The 1,310 option used the wrong LEFs (swapped single and tandem column values).',
    hint: 'ESALs = sum of (passes x LEF) for each load type. Make sure to read the correct column.',
    steps: [
      {
        text: 'Tandem-axle ESALs:',
        latex: '500 \\times 1.11 = 555'
      },
      {
        text: 'Single-axle ESALs:',
        latex: '200 \\times 1.51 = 302'
      },
      {
        text: 'Total:',
        latex: '555 + 302 = 857 \\text{ ESALs}'
      }
    ],
    handbookPage: 'p. 308',
    handbookFormula: 'ESALs = \\sum (\\text{passes}_i \\times LEF_i)',
    videoUrl: null,
    traps: [
      'Swapping the single-axle and tandem-axle LEF columns in the table',
      'Assuming LEF = 1.0 for all loads'
    ],
    diagram: null,
    lessonId: 'pavement-design',
    chapterId: 'transportation'
  },
  {
    id: 'trans-pd-ex4',
    type: 'conceptual',
    statement: 'Two pavement sections have the same required Structural Number ($SN = 4.0$). Section A uses a thicker asphalt surface with a thinner granular base. Section B uses a thinner asphalt surface with a thicker granular base. Which statement is most accurate?',
    choices: [
      {
        id: 'c1',
        text: 'Both designs are structurally equivalent per the SN equation, but Section A will likely perform better because asphalt has a higher layer coefficient than granular base'
      },
      {
        id: 'c2',
        text: 'Section B is always the better design because granular base is less expensive'
      },
      {
        id: 'c3',
        text: 'The two sections cannot have the same SN with different layer thicknesses'
      },
      {
        id: 'c4',
        text: 'Section A is overdesigned because thicker asphalt exceeds the SN requirement'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'The SN equation allows different thickness combinations to reach the same total SN. Since asphalt has $a_1 = 0.44$ (much higher than granular base $a_2 = 0.14$), each inch of asphalt provides about 3 times the structural benefit of an inch of base. Section A with more asphalt gets the same SN with less total pavement thickness, and higher-quality materials on top generally provide better performance. Section B may be cheaper in materials but needs much more total thickness. Both satisfy the design SN, so they are structurally equivalent by the AASHTO method. The "granular base is always cheaper/better" choice ignores performance differences. The "cannot have the same SN with different thicknesses" choice misunderstands the SN equation. The "Section A is overdesigned" choice is wrong because both sections hit exactly $SN = 4.0$.',
    hint: 'Multiple layer combinations can produce the same SN. Compare the layer coefficients to understand the tradeoff.',
    steps: [
      {
        text: 'Example: Section A with $D_1 = 6$ in asphalt: $0.44 \\times 6 = 2.64$. Needs $1.36$ more SN from base.',
        latex: null
      },
      {
        text: 'Section B with $D_1 = 3$ in asphalt: $0.44 \\times 3 = 1.32$. Needs $2.68$ more SN from base.',
        latex: null
      },
      {
        text: 'Both reach SN = 4.0, but the asphalt layer coefficient ($a_1 = 0.44$) is much higher than the base ($a_2 = 0.14$), so Section A uses less total material.',
        latex: null
      }
    ],
    handbookPage: 'p. 308',
    handbookFormula: 'SN = a_1 D_1 + a_2 D_2 m_2 + a_3 D_3 m_3',
    videoUrl: null,
    traps: [
      'Thinking only one layer combination can satisfy a given SN',
      'Ignoring the difference in layer coefficients when comparing designs'
    ],
    diagram: null,
    lessonId: 'pavement-design',
    chapterId: 'transportation'
  },
  {
    id: 'trans-ew-ex1',
    type: 'computational',
    statement: 'Two cross sections are $50 \\text{ ft}$ apart with areas $A_1 = 180 \\text{ ft}^2$ and $A_2 = 220 \\text{ ft}^2$. What is the earthwork volume using the average end area method, in cubic yards?',
    choices: [
      {
        id: 'c1',
        text: '$370 \\text{ yd}^3$'
      },
      {
        id: 'c2',
        text: '$10{,}000 \\text{ yd}^3$'
      },
      {
        id: 'c3',
        text: '$741 \\text{ yd}^3$'
      },
      {
        id: 'c4',
        text: '$333 \\text{ yd}^3$'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: '$V = L(A_1 + A_2)/2 = 50(180 + 220)/2 = 50 \\times 400/2 = 50 \\times 200 = 10{,}000$ ft$^3$. Convert: $10{,}000/27 = 370$ yd$^3$. The 10,000 yd$^3$ option is in ft$^3$, not yd$^3$ -- forgot to divide by 27. The 741 yd$^3$ option forgot to divide by 2 in the average: $50 \\times 400/27 = 741$. The 333 yd$^3$ option used only $A_1$: $50 \\times 180/27 = 333$.',
    hint: 'Average the two areas, multiply by L, then divide by 27 for yd^3.',
    steps: [
      {
        text: 'Average end area volume:',
        latex: 'V = \\frac{50(180 + 220)}{2} = \\frac{50 \\times 400}{2} = 10{,}000 \\text{ ft}^3'
      },
      {
        text: 'Convert to yd^3:',
        latex: 'V = \\frac{10{,}000}{27} = 370 \\text{ yd}^3'
      }
    ],
    handbookPage: 'p. 309',
    handbookFormula: 'V = \\frac{L(A_1 + A_2)}{2}',
    videoUrl: null,
    traps: ['Reporting the answer in ft^3 instead of yd^3 -- always divide by 27'],
    diagram: {
      component: 'EarthworkSection',
      props: {
        A1: 180,
        A2: 220,
        L: 50
      }
    },
    lessonId: 'earthwork',
    chapterId: 'transportation'
  },
  {
    id: 'trans-ew-ex2',
    type: 'conceptual',
    statement: 'The average end area method always overestimates the true volume compared to the prismoidal formula (when the two end areas are not equal). Why?',
    choices: [
      {
        id: 'c1',
        text: 'The average end area method uses a larger distance $L$ than the prismoidal formula'
      },
      {
        id: 'c2',
        text: 'The average end area method assumes a linear transition between the two cross sections, but the actual shape tapers, so the true mid-section area is smaller than the average of the two ends'
      },
      {
        id: 'c3',
        text: 'The prismoidal formula ignores the mid-section, so it always underestimates'
      },
      {
        id: 'c4',
        text: 'The overestimate occurs only when both areas are very large'
      }
    ],
    correctAnswerId: 'c2',
    difficulty: 'medium',
    eli5: 'The average end area method takes $(A_1 + A_2)/2$ as the representative cross section for the entire segment. But when $A_1$ and $A_2$ differ, the actual mid-section area $A_m$ is typically less than $(A_1 + A_2)/2$ because the cross section tapers non-linearly. The prismoidal formula accounts for this by weighting the mid-section $4\\times$. Mathematically, $(A_1 + 4A_m + A_2)/6 \\leq (A_1 + A_2)/2$ when $A_m < (A_1 + A_2)/2$, which is the typical case. The "larger distance $L$" choice is wrong -- both methods use the same $L$. The "prismoidal ignores the mid-section" choice is backwards -- the prismoidal formula uses $A_m$ and is more accurate. The "only when both areas are very large" choice is wrong because the overestimate depends on the difference between the areas, not their absolute size.',
    hint: 'Compare the representative area used by each method. How does the actual mid-section compare to the simple average?',
    steps: [
      {
        text: 'Average end area uses $(A_1 + A_2)/2$ as the representative area.',
        latex: null
      },
      {
        text: 'Prismoidal uses $(A_1 + 4A_m + A_2)/6$, which weights the actual mid-section.',
        latex: null
      },
      {
        text: 'When $A_1 \\neq A_2$, the actual $A_m < (A_1 + A_2)/2$, so the prismoidal gives a smaller (more accurate) volume.',
        latex: null
      }
    ],
    handbookPage: 'p. 309',
    handbookFormula: 'V = \\frac{L(A_1 + A_2)}{2}',
    videoUrl: null,
    traps: [
      'Thinking both methods use different distances L -- they use the same station spacing'
    ],
    diagram: null,
    lessonId: 'earthwork',
    chapterId: 'transportation'
  },
  {
    id: 'trans-ew-ex3',
    type: 'computational',
    statement: 'Two stations $100 \\text{ ft}$ apart have areas $A_1 = 100 \\text{ ft}^2$ and $A_2 = 400 \\text{ ft}^2$, with mid-section $A_m = 200 \\text{ ft}^2$. What is the prismoidal correction (difference between average end area volume and prismoidal volume)?',
    choices: [
      {
        id: 'c1',
        text: '$926 \\text{ yd}^3$'
      },
      {
        id: 'c2',
        text: '$0 \\text{ yd}^3$'
      },
      {
        id: 'c3',
        text: '$123 \\text{ yd}^3$'
      },
      {
        id: 'c4',
        text: '$62 \\text{ yd}^3$'
      }
    ],
    correctAnswerId: 'c3',
    difficulty: 'medium',
    eli5: 'Average end area: $V_{avg} = 100(100 + 400)/2 = 25{,}000$ ft$^3$ $= 926$ yd$^3$. Prismoidal: $V_{prism} = 100(100 + 4 \\times 200 + 400)/6 = 100 \\times 1{,}300/6 = 21{,}667$ ft$^3$ $= 802$ yd$^3$. Correction $= 926 - 802 = 123$ yd$^3$. The 0 yd\u00b3 option assumes both methods give the same answer. The 926 yd\u00b3 option is the average end area volume itself, not the correction. The 62 yd\u00b3 option halved the correction for no reason.',
    hint: 'Compute both volumes, then subtract. The prismoidal correction is always positive (average end area overestimates).',
    steps: [
      {
        text: 'Average end area:',
        latex: 'V_{\\text{avg}} = \\frac{100(100 + 400)}{2} = 25{,}000 \\text{ ft}^3 = 926 \\text{ yd}^3'
      },
      {
        text: 'Prismoidal:',
        latex: 'V_{\\text{prism}} = \\frac{100(100 + 4 \\times 200 + 400)}{6} = \\frac{130{,}000}{6} = 21{,}667 \\text{ ft}^3 = 802 \\text{ yd}^3'
      },
      {
        text: 'Correction:',
        latex: '926 - 802 = 123 \\text{ yd}^3'
      }
    ],
    handbookPage: 'p. 309',
    handbookFormula: 'V = \\frac{L(A_1 + 4A_m + A_2)}{6}',
    videoUrl: null,
    traps: [
      'Confusing the prismoidal correction with the prismoidal volume itself',
      'Forgetting to convert both volumes to the same units before subtracting'
    ],
    diagram: {
      component: 'EarthworkSection',
      props: {
        A1: 100,
        A2: 400,
        Am: 200,
        L: 100
      }
    },
    lessonId: 'earthwork',
    chapterId: 'transportation'
  },
  {
    id: 'trans-ew-ex4',
    type: 'conceptual',
    statement: 'A project has a cut section producing $5{,}000 \\text{ yd}^3$ of excavation and a fill section requiring $5{,}000 \\text{ yd}^3$ of embankment. An engineer assumes the cut material can directly fill the embankment with no waste or borrow. What critical factor has the engineer overlooked?',
    choices: [
      {
        id: 'c1',
        text: 'Shrinkage and swell factors -- excavated soil changes volume when disturbed and recompacted, so equal bank volumes do not mean equal compacted volumes'
      },
      {
        id: 'c2',
        text: 'The two sections may be different soil types, but volume is unaffected by soil type'
      },
      {
        id: 'c3',
        text: 'The hauling cost, which is the only consideration in mass haul analysis'
      },
      {
        id: 'c4',
        text: 'The average end area method was used, which always gives exact volumes'
      }
    ],
    correctAnswerId: 'c1',
    difficulty: 'hard',
    eli5: 'When soil is excavated, it expands (swells) because of loosening. When it is placed as fill and compacted, it shrinks below the original bank volume (shrinkage). So 5,000 yd$^3$ of bank cut does not produce 5,000 yd$^3$ of compacted fill. Depending on the soil, you might get only 4,250 yd$^3$ of compacted fill from 5,000 yd$^3$ of bank cut (about 15% shrinkage for typical clay). The engineer would need to borrow additional material. The "different soil types but volume unaffected" choice acknowledges soil differences but incorrectly claims volume is unaffected. The "hauling cost is the only consideration" choice ignores the volume balance issue. The "average end area always gives exact volumes" choice is wrong because that method overestimates, not gives exact volumes.',
    hint: 'Excavated soil does not maintain its original volume when placed and compacted as fill.',
    steps: [
      {
        text: 'Bank volume (in-place) is measured before excavation.',
        latex: null
      },
      {
        text: 'Loose volume (after excavation) is typically larger due to swell.',
        latex: null
      },
      {
        text: 'Compacted volume (as fill) is typically smaller than bank volume due to shrinkage. Equal bank volumes of cut and fill do NOT mean balanced earthwork.',
        latex: null
      }
    ],
    handbookPage: 'p. 309',
    handbookFormula: 'V = \\frac{L(A_1 + A_2)}{2}',
    videoUrl: null,
    traps: [
      'Assuming bank volume equals compacted volume -- shrinkage and swell must be applied',
      'Ignoring the distinction between bank, loose, and compacted volumes in mass haul balancing'
    ],
    diagram: null,
    lessonId: 'earthwork',
    chapterId: 'transportation'
  },
  {
    id: 'trans-td-ex1',
    type: 'computational',
    statement: 'Zone $i$ produces $P_i = 600$ trips. The trips can go to Zone A ($A_A = 400$, $F = 0.4$) or Zone B ($A_B = 100$, $F = 0.6$), with $K = 1$. How many trips go from Zone $i$ to Zone A?',
    choices: [
      { id: 'c1', text: '$436\\text{ trips}$' },
      { id: 'c2', text: '$164\\text{ trips}$' },
      { id: 'c3', text: '$480\\text{ trips}$' },
      { id: 'c4', text: '$300\\text{ trips}$' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'Weights A·F: Zone A = 400(0.4) = 160; Zone B = 100(0.6) = 60; sum = 220. Fraction to A = 160/220 = 0.727, so T = 600 × 0.727 = 436 trips. The 164-trip option is the trips to Zone B (60/220 × 600). The 480-trip option uses attractions only (400/500). The 300-trip option splits evenly.',
    hint: 'Weight each destination by A×F, normalize by the total, multiply by Pi.',
    steps: [
      { text: 'Zone weights:', latex: 'A_A F = 400(0.4) = 160, \\quad A_B F = 100(0.6) = 60' },
      { text: 'Fraction to Zone A:', latex: '\\frac{160}{220} = 0.727' },
      { text: 'Trips:', latex: 'T = 600 \\times 0.727 = 436\\text{ trips}' },
    ],
    handbookPage: 'p. 306',
    handbookFormula: 'T_{ij} = P_i[A_j F_{ij} K_{ij}/\\sum A_j F_{ij} K_{ij}]',
    videoUrl: null,
    traps: [
      'Distributing by attractions alone, ignoring friction factors',
      'Failing to normalize by the sum over all zones',
    ],
    diagram: { component: 'GravityModelZones', props: {} },
    lessonId: 'travel-demand',
    chapterId: 'transportation'
  },
  {
    id: 'trans-rp-ex1',
    type: 'conceptual',
    statement: 'Compared with flexible pavement, a rigid (PCC) pavement is generally LESS sensitive to subgrade strength. Why?',
    choices: [
      { id: 'c1', text: 'The stiff slab distributes load over a wide area by beam action' },
      { id: 'c2', text: 'Concrete is weaker in bending than asphalt' },
      { id: 'c3', text: 'Rigid pavement transmits all load directly beneath the wheel' },
      { id: 'c4', text: 'Rigid pavement has no subgrade' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'medium',
    eli5: 'A rigid slab bends like a beam and spreads each wheel load over a large area of subgrade, so the foundation strength matters less than for flexible pavement. The "concrete is weaker in bending than asphalt" choice is false (concrete carries the bending). The "transmits all load directly beneath the wheel" choice is the opposite of slab behavior. The "rigid pavement has no subgrade" choice is incorrect — there is always a subgrade.',
    hint: 'How does a stiff slab spread load, and what does that imply about subgrade dependence?',
    steps: [
      { text: 'A rigid slab acts as a beam over the subgrade.', latex: null },
      { text: 'Beam action distributes load over a wide area.', latex: null },
      { text: 'So subgrade strength matters less than for flexible pavement.', latex: null },
    ],
    handbookPage: null,
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Assuming rigid pavement depends heavily on subgrade like flexible does',
      'Thinking a slab concentrates load beneath the wheel',
    ],
    diagram: { component: 'RigidPavementJoint', props: {} },
    lessonId: 'rigid-pavement',
    chapterId: 'transportation'
  },
  {
    id: 'trans-tcd-ex1',
    type: 'conceptual',
    statement: 'Under the MUTCD, a green sign giving the distance to the next town is which category of traffic control device?',
    choices: [
      { id: 'c1', text: 'Guide sign' },
      { id: 'c2', text: 'Regulatory sign' },
      { id: 'c3', text: 'Warning sign' },
      { id: 'c4', text: 'Signal indication' },
    ],
    correctAnswerId: 'c1',
    difficulty: 'easy',
    eli5: 'Green signs that give directions, distances, and destinations are GUIDE signs. Regulatory signs (white/red) state laws; warning signs (yellow diamonds) alert to conditions; a signal indication is a traffic light, not a sign.',
    hint: 'Green color + giving directions/distances = which category?',
    steps: [
      { text: 'Guide signs provide directions and distances and are green.', latex: null },
      { text: 'The sign described matches that purpose and color.', latex: null },
      { text: 'So it is a guide sign.', latex: null },
    ],
    handbookPage: null,
    handbookFormula: null,
    videoUrl: null,
    traps: [
      'Confusing guide (green) with regulatory or warning signs',
      'Calling a sign a signal indication',
    ],
    diagram: { component: 'SignShapes', props: {} },
    lessonId: 'traffic-control-devices',
    chapterId: 'transportation'
  },
];

export default PROBLEMS;
