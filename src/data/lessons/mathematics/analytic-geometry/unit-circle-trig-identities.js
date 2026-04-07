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
      "eli5": "The unit circle point at $60°$ is $(1/2,\\, \\sqrt{3}/2)$. Cosine is always the x-coordinate, sine is the y-coordinate. The trap is mixing them up — $\\sqrt{3}/2$ (Choice B) is the sine of $60°$, not the cosine. If you remember that $\\cos 60° = 1/2$ and $\\sin 60° = \\sqrt{3}/2$, you have the most commonly tested pair down.",
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
  "examProblems": [
    {
      "id": "math-ucti-ex1",
      "type": "computational",
      "statement": "What is the exact value of $\\sin 150°$?",
      "choices": [
        { "id": "c1", "text": "$-\\frac{1}{2}$" },
        { "id": "c2", "text": "$-\\frac{\\sqrt{3}}{2}$" },
        { "id": "c3", "text": "$\\frac{\\sqrt{3}}{2}$" },
        { "id": "c4", "text": "$\\frac{1}{2}$" }
      ],
      "correctAnswerId": "c4",
      "difficulty": "easy",
      "eli5": "150° is in the second quadrant. Its reference angle is $180° - 150° = 30°$. Sine of 30° is $1/2$. In Q2, sine is positive (y-coordinates are positive above the x-axis), so $\\sin 150° = +1/2$. The trap is picking the negative version — sine is only negative in Q3 and Q4. Also don't confuse $\\sin 30°$ with $\\cos 30°$ which is $\\sqrt{3}/2$.",
      "hint": "Find the reference angle for 150°, then determine the sign from the quadrant.",
      "steps": [
        { "text": "Reference angle:", "latex": "180° - 150° = 30°" },
        { "text": "In Q2, sine is positive:", "latex": "\\sin 150° = +\\sin 30° = \\frac{1}{2}" }
      ],
      "handbookPage": "p. 38",
      "handbookFormula": "\\sin 30° = \\frac{1}{2}",
      "videoUrl": null,
      "traps": [
        "Applying a negative sign — sine is positive in Q2",
        "Using $\\cos 30° = \\sqrt{3}/2$ instead of $\\sin 30° = 1/2$"
      ],
      "diagram": null
    },
    {
      "id": "math-ucti-ex2",
      "type": "computational",
      "statement": "If $\\cos\\theta = \\frac{7}{25}$ and $\\theta$ is in the fourth quadrant, what is $\\sin\\theta$?",
      "choices": [
        { "id": "c1", "text": "$\\frac{24}{25}$" },
        { "id": "c2", "text": "$-\\frac{7}{25}$" },
        { "id": "c3", "text": "$-\\frac{24}{25}$" },
        { "id": "c4", "text": "$\\frac{18}{25}$" }
      ],
      "correctAnswerId": "c3",
      "difficulty": "medium",
      "eli5": "Start with the Pythagorean identity: $\\sin^2\\theta = 1 - \\cos^2\\theta = 1 - 49/625 = 576/625$. Square root gives $\\pm 24/25$. Now check the quadrant: Q4 means y is negative, so sine is negative. The answer is $-24/25$ (Choice C). Choice A is the positive root — that's Q1, not Q4. Always let the quadrant tell you the sign.",
      "hint": "Use $\\sin^2\\theta + \\cos^2\\theta = 1$, then pick the sign from the quadrant.",
      "steps": [
        { "text": "Apply the Pythagorean identity:", "latex": "\\sin^2\\theta = 1 - \\cos^2\\theta = 1 - \\frac{49}{625} = \\frac{576}{625}" },
        { "text": "Take the square root:", "latex": "\\sin\\theta = \\pm\\frac{24}{25}" },
        { "text": "In Q4, sine is negative:", "latex": "\\sin\\theta = -\\frac{24}{25}" }
      ],
      "handbookPage": "p. 38",
      "handbookFormula": "\\sin^2\\theta + \\cos^2\\theta = 1",
      "videoUrl": null,
      "traps": [
        "Choosing the positive root and ignoring the quadrant",
        "Arithmetic error: 625 - 49 = 576, not 576/25"
      ],
      "diagram": null
    },
    {
      "id": "math-ucti-ex3",
      "type": "computational",
      "statement": "If $\\cos\\theta = \\frac{3}{5}$ and $\\theta$ is in the first quadrant, what is the value of $\\cos 2\\theta$?",
      "choices": [
        { "id": "c1", "text": "$-\\frac{7}{25}$" },
        { "id": "c2", "text": "$\\frac{6}{5}$" },
        { "id": "c3", "text": "$\\frac{7}{25}$" },
        { "id": "c4", "text": "$\\frac{9}{25}$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "Use the double-angle formula $\\cos 2\\theta = 2\\cos^2\\theta - 1$. Plug in: $2(9/25) - 1 = 18/25 - 25/25 = -7/25$. Choice B is wrong because it just doubles cos — that's not how double-angle works. Choice D uses $\\cos^2\\theta$ without the doubling and subtraction. The negative result is totally fine — it means $2\\theta$ lands in Q2 or Q3 where cosine is negative.",
      "hint": "The double-angle formula $\\cos 2\\theta = 2\\cos^2\\theta - 1$ only needs $\\cos\\theta$.",
      "steps": [
        { "text": "Apply the double-angle formula:", "latex": "\\cos 2\\theta = 2\\cos^2\\theta - 1" },
        { "text": "Substitute:", "latex": "\\cos 2\\theta = 2\\left(\\frac{3}{5}\\right)^2 - 1 = 2 \\cdot \\frac{9}{25} - 1 = \\frac{18}{25} - \\frac{25}{25} = -\\frac{7}{25}" }
      ],
      "handbookPage": "p. 38",
      "handbookFormula": "\\cos 2\\theta = 2\\cos^2\\theta - 1",
      "videoUrl": null,
      "traps": [
        "Just doubling the cosine value (2 times 3/5 = 6/5) instead of using the double-angle formula",
        "Using the wrong form of the double-angle identity"
      ],
      "diagram": null
    },
    {
      "id": "math-ucti-ex4",
      "type": "conceptual",
      "statement": "In which quadrants is the tangent function positive?",
      "choices": [
        { "id": "c1", "text": "Quadrants I and II" },
        { "id": "c2", "text": "Quadrants I and III" },
        { "id": "c3", "text": "Quadrants II and IV" },
        { "id": "c4", "text": "Quadrants I and IV" }
      ],
      "correctAnswerId": "c2",
      "difficulty": "hard",
      "eli5": "Tangent is sine divided by cosine. It's positive when both have the same sign. In Q1, both sin and cos are positive — positive/positive = positive. In Q3, both are negative — negative/negative = positive. In Q2 and Q4, they have opposite signs, so tangent is negative. The mnemonic 'All Students Take Calculus' tells you which trig functions are positive in each quadrant: All (Q1), Sine (Q2), Tangent (Q3), Cosine (Q4).",
      "hint": "Tangent = sin/cos. In which quadrants do sine and cosine share the same sign?",
      "steps": [
        { "text": "Recall $\\tan\\theta = \\frac{\\sin\\theta}{\\cos\\theta}$. It's positive when sin and cos have the same sign.", "latex": null },
        { "text": "Q1: sin > 0, cos > 0 — tan > 0.", "latex": null },
        { "text": "Q3: sin < 0, cos < 0 — tan > 0.", "latex": null },
        { "text": "Q2 and Q4 have opposite signs for sin and cos, so tan < 0.", "latex": null }
      ],
      "handbookPage": "p. 38",
      "handbookFormula": "\\tan\\theta = \\frac{\\sin\\theta}{\\cos\\theta}",
      "videoUrl": null,
      "traps": [
        "Confusing tangent sign rules with sine or cosine sign rules",
        "Thinking tangent is positive wherever sine is positive"
      ],
      "diagram": null
    }
  ]
};
