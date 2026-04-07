export default {
  "id": "right-triangle-trig",
  "name": "Right Triangle Trigonometry",
  "subtopicId": "analytic-geometry",
  "application": "Civil engineers use right triangle trig constantly — resolving cable forces into horizontal and vertical components, computing slope distances on graded roads, sizing retaining wall footings, and laying out survey lines. On the FE exam, any time you see an angle paired with a force or a length, you're reaching for SOH-CAH-TOA. This is foundational for statics, surveying, and structural problems throughout the test.",
  "content": [
    {
      "type": "text",
      "body": "A right triangle gives you three ratios relative to an angle $\\theta$. Pick the ratio that connects what you know to what you need."
    },
    {
      "type": "diagram",
      "component": "RightTriangle",
      "props": {
        "angle": 35,
        "labels": true
      }
    },
    {
      "type": "heading",
      "body": "The Three Ratios"
    },
    {
      "type": "formula",
      "latex": "\\sin\\theta = \\frac{\\text{opp}}{\\text{hyp}}",
      "label": "SOH"
    },
    {
      "type": "formula",
      "latex": "\\cos\\theta = \\frac{\\text{adj}}{\\text{hyp}}",
      "label": "CAH"
    },
    {
      "type": "formula",
      "latex": "\\tan\\theta = \\frac{\\text{opp}}{\\text{adj}}",
      "label": "TOA"
    },
    {
      "type": "callout",
      "variant": "tip",
      "body": "Remember: cos is \"cozy\" with the adjacent side (the one touching the angle). If you have the hypotenuse and want the opposite side, that's sine."
    },
    {
      "type": "callout",
      "variant": "warning",
      "body": "The biggest exam trap is mixing up which component gets sin vs cos when resolving forces. Always confirm your calculator is in degree mode."
    }
  ],
  "illustration": null,
  "problems": [
    {
      "id": "math-rtt-q1",
      "statement": "A surveyor measures the angle of elevation to the top of a building as $35°$ from a point $50\\,\\text{m}$ away on level ground. What is the height of the building?",
      "choices": [
        {
          "id": "c1",
          "text": "35.0 m"
        },
        {
          "id": "c2",
          "text": "41.0 m"
        },
        {
          "id": "c3",
          "text": "28.7 m"
        },
        {
          "id": "c4",
          "text": "61.0 m"
        }
      ],
      "correctAnswerId": "c1",
      "difficulty": "easy",
      "eli5": "You are standing 50 m from a building and looking up at $35°$. You know the ground distance (adjacent) and want the height (opposite) — that is tangent. Multiply 50 by $\\tan(35°)$ and you are done. The trap is using sin or cos instead.",
      "hint": "You know the adjacent side and want the opposite — which trig ratio connects those two?",
      "steps": [
        {
          "text": "Identify the triangle: building height is opposite the 35° angle, the 50 m ground distance is adjacent.",
          "latex": null
        },
        {
          "text": "Pick the ratio that connects opposite and adjacent:",
          "latex": "\\tan 35° = \\frac{h}{50}"
        },
        {
          "text": "Solve for h:",
          "latex": "h = 50 \\times \\tan 35° = 50 \\times 0.7002 = 35.0\\,\\text{m}"
        }
      ],
      "handbookPage": "p. 23",
      "handbookFormula": "\\tan\\theta = \\frac{\\text{opp}}{\\text{adj}}",
      "videoUrl": null,
      "traps": [
        "Using sin or cos instead of tan",
        "Calculator in radian mode"
      ],
      "diagram": null
    },
    {
      "id": "math-rtt-q2",
      "statement": "A cable exerts a force of $12\\,\\text{kN}$ at $40°$ above the horizontal on a bridge anchor. What is the horizontal component of the force?",
      "choices": [
        {
          "id": "c1",
          "text": "7.71 kN"
        },
        {
          "id": "c2",
          "text": "9.19 kN"
        },
        {
          "id": "c3",
          "text": "15.66 kN"
        },
        {
          "id": "c4",
          "text": "12.00 kN"
        }
      ],
      "correctAnswerId": "c2",
      "difficulty": "medium",
      "eli5": "\"40 degrees above horizontal\" means the angle is measured FROM the horizontal axis. The horizontal component is the side touching the angle — that's adjacent — so you use cosine. The classic trap is using sin for horizontal because it \"feels\" right. Remember: cos is cozy with the adjacent side.",
      "hint": "The angle is measured from the horizontal axis — which side of the triangle is the horizontal component relative to that angle?",
      "steps": [
        {
          "text": "The angle is measured from horizontal, so the horizontal component is adjacent to the angle.",
          "latex": null
        },
        {
          "text": "Use cosine to find the adjacent (horizontal) component:",
          "latex": "F_x = F \\cos\\theta = 12 \\cos 40°"
        },
        {
          "text": "Calculate:",
          "latex": "F_x = 12 \\times 0.7660 = 9.19\\,\\text{kN}"
        }
      ],
      "handbookPage": "p. 23",
      "handbookFormula": "F_x = F\\cos\\theta",
      "videoUrl": null,
      "traps": [
        "Using sin instead of cos for the horizontal component",
        "Dividing by cos instead of multiplying"
      ],
      "diagram": { "component": "ForceComponents", "props": { "force": 12, "angle": 40, "unit": "kN" } }
    },
    {
      "id": "math-rtt-q3",
      "statement": "An engineer stands at point A and measures the angle of elevation to the top of a tower as $25°$. She walks $30\\,\\text{m}$ closer to the tower to point B and measures the angle of elevation as $42°$. What is the height of the tower?",
      "choices": [
        {
          "id": "c1",
          "text": "38.9 m"
        },
        {
          "id": "c2",
          "text": "29.0 m"
        },
        {
          "id": "c3",
          "text": "33.1 m"
        },
        {
          "id": "c4",
          "text": "14.0 m"
        }
      ],
      "correctAnswerId": "c2",
      "difficulty": "hard",
      "eli5": "This is a two-triangle problem. You set up tan equations from both positions — each has the same unknown height h but different distances. Write both equations, substitute one into the other, and solve for h. It looks nasty but it's just algebra after the two tan equations are set up. Don't try to shortcut — set up both equations first, then eliminate d.",
      "hint": "Set up a separate tan equation from each observation point. Both share the same unknown height — eliminate the distance variable.",
      "steps": [
        {
          "text": "Let h = tower height, d = horizontal distance from B to the base.",
          "latex": null
        },
        {
          "text": "From point B:",
          "latex": "\\tan 42° = \\frac{h}{d} \\quad\\Rightarrow\\quad d = \\frac{h}{\\tan 42°}"
        },
        {
          "text": "From point A (30 m farther):",
          "latex": "\\tan 25° = \\frac{h}{d + 30}"
        },
        {
          "text": "Substitute d and rearrange:",
          "latex": "h\\!\\left(1 - \\frac{\\tan 25°}{\\tan 42°}\\right) = 30\\tan 25°"
        },
        {
          "text": "Solve:",
          "latex": "h = \\frac{30 \\times 0.4663}{1 - \\frac{0.4663}{0.9004}} = \\frac{13.99}{0.4821} = 29.0\\,\\text{m}"
        }
      ],
      "handbookPage": "p. 23",
      "handbookFormula": "\\tan\\theta = \\frac{\\text{opp}}{\\text{adj}}",
      "videoUrl": null,
      "traps": [
        "Forgetting to add 30 m to the distance from A",
        "Rounding intermediate values too early"
      ],
      "diagram": { "component": "TwoPointElevation", "props": { "dist": 30, "angleA": 25, "angleB": 42 } }
    }
  ],
  examProblems: [
    {
      id: 'math-rtt-ex1',
      type: 'computational',
      statement: 'A ladder leans against a wall at an angle of $65°$ with the ground. If the foot of the ladder is $3.0\\,\\text{m}$ from the wall, how long is the ladder?',
      choices: [
        { id: 'c1', text: '6.4 m' },
        { id: 'c2', text: '7.1 m' },
        { id: 'c3', text: '2.7 m' },
        { id: 'c4', text: '3.3 m' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'easy',
      eli5: 'You know the adjacent side (3.0 m from the wall) and the angle with the ground ($65°$), and you want the hypotenuse (the ladder). Adjacent over hypotenuse is cosine: $\\cos 65° = 3/L$, so $L = 3/\\cos 65° = 3/0.4226 = 7.1$ m. The trap is using sine instead of cosine, which would give you the wall height, not the ladder length.',
      hint: 'You know the side adjacent to the angle and need the hypotenuse. Which trig ratio connects those?',
      steps: [
        { text: 'The ground distance (3.0 m) is adjacent to the 65 degree angle. The ladder is the hypotenuse.', latex: null },
        { text: 'Use cosine:', latex: '\\cos 65° = \\frac{3.0}{L}' },
        { text: 'Solve for L:', latex: 'L = \\frac{3.0}{\\cos 65°} = \\frac{3.0}{0.4226} = 7.1\\,\\text{m}' },
      ],
      handbookPage: 'p. 23',
      handbookFormula: '\\cos\\theta = \\frac{\\text{adj}}{\\text{hyp}}',
      videoUrl: null,
      traps: ['Using sine instead of cosine', 'Multiplying by cos instead of dividing'],
      diagram: null,
    },
    {
      id: 'math-rtt-ex2',
      type: 'computational',
      statement: 'A guy wire attached to the top of a $20\\,\\text{m}$ antenna makes a $55°$ angle with the ground. What is the length of the guy wire?',
      choices: [
        { id: 'c1', text: '24.4 m' },
        { id: 'c2', text: '34.9 m' },
        { id: 'c3', text: '16.4 m' },
        { id: 'c4', text: '28.6 m' },
      ],
      correctAnswerId: 'a1',
      difficulty: 'medium',
      eli5: 'The antenna height (20 m) is opposite the $55°$ angle. The wire is the hypotenuse. Opposite over hypotenuse is sine: $\\sin 55° = 20/W$, so $W = 20/\\sin 55° = 20/0.8192 = 24.4$ m. The classic trap is using tangent, which connects opposite and adjacent, not opposite and hypotenuse.',
      hint: 'You know the opposite side and need the hypotenuse. SOH-CAH-TOA tells you which ratio to use.',
      steps: [
        { text: 'The antenna (20 m) is opposite the 55 degree angle at ground level. The wire is the hypotenuse.', latex: null },
        { text: 'Use sine:', latex: '\\sin 55° = \\frac{20}{W}' },
        { text: 'Solve for W:', latex: 'W = \\frac{20}{\\sin 55°} = \\frac{20}{0.8192} = 24.4\\,\\text{m}' },
      ],
      handbookPage: 'p. 23',
      handbookFormula: '\\sin\\theta = \\frac{\\text{opp}}{\\text{hyp}}',
      videoUrl: null,
      traps: ['Using tangent instead of sine', 'Using cos instead of sin — that gives the ground distance, not the wire length'],
      diagram: null,
    },
    {
      id: 'math-rtt-ex3',
      type: 'computational',
      statement: 'A ramp rises $1.5\\,\\text{m}$ over a horizontal distance of $12\\,\\text{m}$. What is the angle of incline of the ramp?',
      choices: [
        { id: 'c1', text: '$7.1°$' },
        { id: 'c2', text: '$12.5°$' },
        { id: 'c3', text: '$82.9°$' },
        { id: 'c4', text: '$0.125°$' },
      ],
      correctAnswerId: 'c1',
      difficulty: 'medium',
      eli5: 'You know the opposite (rise = 1.5 m) and the adjacent (run = 12 m). That is tangent. Take the inverse tangent of $1.5/12 = 0.125$ to get $7.1°$. Choice D is the ratio itself without taking the inverse trig function. Choice C is $90°$ minus the correct answer — that would be the angle from the vertical, not the horizontal.',
      hint: 'You have the rise and the run. Which trig function relates opposite to adjacent?',
      steps: [
        { text: 'Identify: rise (opposite) = 1.5 m, run (adjacent) = 12 m.', latex: null },
        { text: 'Apply inverse tangent:', latex: '\\theta = \\tan^{-1}\\!\\left(\\frac{1.5}{12}\\right) = \\tan^{-1}(0.125)' },
        { text: 'Evaluate:', latex: '\\theta = 7.1°' },
      ],
      handbookPage: 'p. 23',
      handbookFormula: '\\tan\\theta = \\frac{\\text{opp}}{\\text{adj}}',
      videoUrl: null,
      traps: ['Reporting the ratio as the angle instead of taking inverse tangent', 'Giving the complement (90 minus the angle) instead of the angle from horizontal'],
      diagram: null,
    },
    {
      id: 'math-rtt-ex4',
      type: 'conceptual',
      statement: 'A force $F$ acts at angle $\\theta$ above the horizontal. An engineer writes $F_x = F\\sin\\theta$ and $F_y = F\\cos\\theta$. What error did the engineer make?',
      choices: [
        { id: 'c1', text: 'The formulas are correct as written' },
        { id: 'c2', text: 'The sin and cos are swapped — $F_x$ should use cos and $F_y$ should use sin' },
        { id: 'c3', text: 'Both components should use tangent' },
        { id: 'c4', text: 'The force should be divided by the trig functions, not multiplied' },
      ],
      correctAnswerId: 'c2',
      difficulty: 'hard',
      eli5: 'When the angle is measured from the horizontal, the horizontal component is adjacent to the angle, so it uses cosine. The vertical component is opposite the angle, so it uses sine. The engineer swapped them. This is the single most common trig error on the FE exam. Remember: cosine is "cozy" with the adjacent side, and the adjacent side is the one the angle is measured from. The correct formulas are $F_x = F\\cos\\theta$ and $F_y = F\\sin\\theta$.',
      hint: 'When the angle is measured FROM the horizontal, which component (horizontal or vertical) is adjacent to that angle?',
      steps: [
        { text: 'The angle $\\theta$ is measured from the horizontal axis.', latex: null },
        { text: 'The horizontal component is adjacent to $\\theta$, so it uses cosine:', latex: 'F_x = F\\cos\\theta' },
        { text: 'The vertical component is opposite $\\theta$, so it uses sine:', latex: 'F_y = F\\sin\\theta' },
        { text: 'The engineer swapped sin and cos.', latex: null },
      ],
      handbookPage: 'p. 23',
      handbookFormula: 'F_x = F\\cos\\theta,\\quad F_y = F\\sin\\theta',
      videoUrl: null,
      traps: ['Assuming the formulas look correct because the components have some trig function', 'Forgetting that the reference direction of the angle determines which function to use'],
      diagram: null,
    },
  ],
};
