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
      "eli5": "You're standing 50 m from a building and looking up at 35 degrees. You know the ground distance (adjacent) and want the height (opposite) — that's tangent. Multiply 50 by tan(35°) and you're done. The trap is using sin or cos instead.",
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
      "diagram": null
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
      "diagram": null
    }
  ]
};
