export default {
  "id": "unit-circle-trig-identities",
  "name": "Unit Circle & Trig Identities",
  "subtopicId": "analytic-geometry",
  "application": "Trig identities show up on the FE whenever a problem needs simplification before you can solve it — combining force components at different angles, converting between sin and cos in vibration equations, or simplifying expressions in calculus-based derivations. The unit circle ties angles to coordinates, giving you exact values for common angles without a calculator. On the FE exam, knowing your reference angles and a handful of identities saves real time.",
  "content": [
    {
      "type": "text",
      "body": "The unit circle maps every angle $\\theta$ to coordinates $(\\cos\\theta, \\sin\\theta)$ on a circle of radius 1. Memorize the key angles: $0°$, $30°$, $45°$, $60°$, $90°$ and their values — everything else follows by symmetry across quadrants."
    },
    {
      "type": "heading",
      "body": "Pythagorean Identity"
    },
    {
      "type": "formula",
      "latex": "\\sin^2\\theta + \\cos^2\\theta = 1"
    },
    {
      "type": "heading",
      "body": "Double-Angle Formulas"
    },
    {
      "type": "formula",
      "latex": "\\sin 2\\theta = 2\\sin\\theta\\cos\\theta"
    },
    {
      "type": "formula",
      "latex": "\\cos 2\\theta = \\cos^2\\theta - \\sin^2\\theta"
    },
    {
      "type": "callout",
      "variant": "tip",
      "body": "Don't memorize all identities — know the Pythagorean identity cold, and recognize when a double-angle or sum formula is being tested."
    }
  ],
  "illustration": null,
  "problems": [
    {
      "id": "math-uci-q1",
      "statement": "What is the exact value of $\\cos 60°$?",
      "choices": [
        {
          "id": "c1",
          "text": "1/2"
        },
        {
          "id": "c2",
          "text": "√3/2"
        },
        {
          "id": "c3",
          "text": "√2/2"
        },
        {
          "id": "c4",
          "text": "1"
        }
      ],
      "correctAnswerId": "c1",
      "difficulty": "easy",
      "eli5": "The unit circle point at $60°$ is $(1/2,\\, \\sqrt{3}/2)$. Cosine is always the x-coordinate, sine is the y-coordinate. The trap is mixing them up — $\\sqrt{3}/2$ (the \u221a3/2 choice) is the sine of $60°$, not the cosine. If you remember that $\\cos 60° = 1/2$ and $\\sin 60° = \\sqrt{3}/2$, you have the most commonly tested pair down.",
      "hint": "On the unit circle, cosine is the x-coordinate and sine is the y-coordinate at any angle.",
      "steps": [
        {
          "text": "Recall the unit circle: at 60°, the coordinates are (1/2, √3/2).",
          "latex": null
        },
        {
          "text": "Cosine is the x-coordinate:",
          "latex": "\\cos 60° = \\frac{1}{2}"
        }
      ],
      "handbookPage": "p. 23",
      "handbookFormula": "\\cos 60° = \\frac{1}{2}",
      "videoUrl": null,
      "traps": [
        "Confusing sin and cos (picking $\\sqrt{3}/2$)",
        "Mixing up 45° and 60° values"
      ],
      "diagram": null
    },
    {
      "id": "math-uci-q2",
      "statement": "If $\\sin\\theta = \\frac{3}{5}$ and $\\theta$ is in the second quadrant, what is $\\cos\\theta$?",
      "choices": [
        {
          "id": "c1",
          "text": "4/5"
        },
        {
          "id": "c2",
          "text": "-4/5"
        },
        {
          "id": "c3",
          "text": "-3/5"
        },
        {
          "id": "c4",
          "text": "3/4"
        }
      ],
      "correctAnswerId": "c2",
      "difficulty": "medium",
      "eli5": "Plug $\\sin\\theta$ into the Pythagorean identity and solve for $\\cos\\theta$. You get $\\pm 4/5$. Now the quadrant matters — in Q2, $x$ is negative, so cosine is negative. The trap is forgetting the quadrant and picking the positive root. Always check which quadrant you are in after solving.",
      "hint": "Use $\\sin^2\\theta + \\cos^2\\theta = 1$ to find $|\\cos\\theta|$, then decide the sign based on the quadrant.",
      "steps": [
        {
          "text": "Apply the Pythagorean identity:",
          "latex": "\\cos^2\\theta = 1 - \\sin^2\\theta = 1 - \\frac{9}{25} = \\frac{16}{25}"
        },
        {
          "text": "Take the square root:",
          "latex": "\\cos\\theta = \\pm\\frac{4}{5}"
        },
        {
          "text": "In Q2, cosine is negative:",
          "latex": "\\cos\\theta = -\\frac{4}{5}"
        }
      ],
      "handbookPage": "p. 23",
      "handbookFormula": "\\sin^2\\theta + \\cos^2\\theta = 1",
      "videoUrl": null,
      "traps": [
        "Forgetting the sign from the quadrant",
        "Confusing sin and cos values"
      ],
      "diagram": null
    },
    {
      "id": "math-uci-q3",
      "statement": "If $\\sin\\theta = \\frac{5}{13}$ and $\\theta$ is in the first quadrant, what is the value of $\\sin 2\\theta$?",
      "choices": [
        {
          "id": "c1",
          "text": "10/13"
        },
        {
          "id": "c2",
          "text": "25/169"
        },
        {
          "id": "c3",
          "text": "120/169"
        },
        {
          "id": "c4",
          "text": "60/169"
        }
      ],
      "correctAnswerId": "c3",
      "difficulty": "hard",
      "eli5": "This is a two-step problem. Step 1: use the Pythagorean identity to find $\\cos\\theta = 12/13$. Step 2: plug both into the double-angle formula $\\sin 2\\theta = 2\\sin\\theta\\cos\\theta$. The most common mistake is thinking \"double angle\" means \"just double the sine\" — it does not. You need both $\\sin\\theta$ and $\\cos\\theta$. The second trap is forgetting the 2 out front.",
      "hint": "The double-angle formula needs both $\\sin\\theta$ and $\\cos\\theta$ — find the missing one first with the Pythagorean identity.",
      "steps": [
        {
          "text": "Find cos θ using the Pythagorean identity:",
          "latex": "\\cos\\theta = \\sqrt{1 - \\frac{25}{169}} = \\sqrt{\\frac{144}{169}} = \\frac{12}{13}"
        },
        {
          "text": "Apply the double-angle formula:",
          "latex": "\\sin 2\\theta = 2\\sin\\theta\\cos\\theta"
        },
        {
          "text": "Calculate:",
          "latex": "\\sin 2\\theta = 2 \\times \\frac{5}{13} \\times \\frac{12}{13} = \\frac{120}{169}"
        }
      ],
      "handbookPage": "p. 23",
      "handbookFormula": "\\sin 2\\theta = 2\\sin\\theta\\cos\\theta",
      "videoUrl": null,
      "traps": [
        "Just doubling $\\sin\\theta$ without multiplying by $\\cos\\theta$",
        "Forgetting the factor of 2"
      ],
      "diagram": null
    }
  ],
};
