export default {
  "id": "applications-derivatives",
  "name": "Applications of Derivatives",
  "subtopicId": "single-var-calc",
  "application": "Civil engineers use max/min analysis constantly — finding where bending moment is maximum along a beam, optimizing the dimensions of a channel for maximum flow, or locating the peak elevation on a vertical highway curve. Inflection points tell you where a beam changes from bending one way to the other. On the FE, these problems are formulaic: take the derivative, set it equal to zero, solve, and use the second derivative to classify. They're free points if you don't make sign errors.",
  "content": [
    {
      "type": "text",
      "body": "To find where a function reaches its highest or lowest value, set the first derivative equal to zero and solve. The second derivative tells you which one it is."
    },
    {
      "type": "heading",
      "body": "Test for a Maximum"
    },
    {
      "type": "formula",
      "latex": "f'(a) = 0 \\quad\\text{and}\\quad f''(a) < 0 \\quad\\Rightarrow\\quad \\text{maximum at } x = a",
      "label": "Concave down = hilltop"
    },
    {
      "type": "heading",
      "body": "Test for a Minimum"
    },
    {
      "type": "formula",
      "latex": "f'(a) = 0 \\quad\\text{and}\\quad f''(a) > 0 \\quad\\Rightarrow\\quad \\text{minimum at } x = a",
      "label": "Concave up = valley"
    },
    {
      "type": "heading",
      "body": "Test for Inflection Point"
    },
    {
      "type": "text",
      "body": "$f''(a) = 0$ and $f''(x)$ changes sign through $x = a$."
    },
    {
      "type": "callout",
      "variant": "tip",
      "body": "Memory trick: second derivative negative means the curve frowns (concave down) — that's a max. Second derivative positive means the curve smiles (concave up) — that's a min."
    },
    {
      "type": "callout",
      "variant": "exam",
      "body": "The FE almost always gives you a polynomial or a simple function. Take the derivative, set it to zero, factor or use the quadratic formula, then plug critical points into the second derivative. Don't skip the second derivative test — some problems have both a max and a min."
    }
  ],
  "illustration": null,
  "problems": [
    {
      "id": "math-ad-q1",
      "statement": "Find the value of $x$ at which $f(x) = -2x^2 + 16x - 5$ reaches its maximum.",
      "choices": [
        {
          "id": "c1",
          "text": "$x = 2$"
        },
        {
          "id": "c2",
          "text": "$x = 4$"
        },
        {
          "id": "c3",
          "text": "$x = 8$"
        },
        {
          "id": "c4",
          "text": "$x = 16$"
        }
      ],
      "correctAnswerId": "c2",
      "difficulty": "easy",
      "eli5": "Take the derivative, set it to zero, solve for $x$. That is it. The second derivative is $-4$, which is negative — concave down — so it is a max, not a min. Since the leading coefficient is negative, the parabola opens downward, so of course it is a max. The choice $x = 8$ is what you get if you forget the factor of 2 when differentiating $-2x^2$. Always double-check your power rule on the leading term.",
      "hint": "Set $f'(x) = 0$ and solve. Is the parabola opening up or down?",
      "steps": [
        {
          "text": "Take the first derivative:",
          "latex": "f'(x) = -4x + 16"
        },
        {
          "text": "Set it equal to zero:",
          "latex": "-4x + 16 = 0 \\implies x = 4"
        },
        {
          "text": "Confirm it's a max:",
          "latex": "f''(x) = -4 < 0 \\quad\\text{(concave down, maximum)}"
        }
      ],
      "handbookPage": "p. 46",
      "handbookFormula": "f'(a) = 0 \\text{ and } f''(a) < 0 \\implies \\text{maximum}",
      "videoUrl": null,
      "traps": [
        "Forgetting the coefficient when differentiating $-2x^2$ (getting $-2x$ instead of $-4x$)",
        "Reporting the max value of $f(x)$ instead of the $x$-location"
      ],
      "diagram": null
    },
    {
      "id": "math-ad-q2",
      "statement": "A civil engineer models the cost per meter of a retaining wall as $C(h) = 3h^2 - 36h + 150$, where $h$ is the wall height in meters. What wall height minimizes the cost, and what is the minimum cost?",
      "choices": [
        {
          "id": "c1",
          "text": "$h = 6\\,\\text{m}$, $C = 42\\,\\text{/m}$"
        },
        {
          "id": "c2",
          "text": "$h = 6\\,\\text{m}$, $C = 150\\,\\text{/m}$"
        },
        {
          "id": "c3",
          "text": "$h = 12\\,\\text{m}$, $C = 42\\,\\text{/m}$"
        },
        {
          "id": "c4",
          "text": "$h = 3\\,\\text{m}$, $C = 93\\,\\text{/m}$"
        }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "Same process — derivative, set to zero, solve. You get $h = 6$. The second derivative is positive ($6 > 0$), so it is concave up — a minimum. The extra step is plugging $h = 6$ back into the original function to get the cost. The choice giving C = 150/m is the trap for students who find the right $h$ but give the constant term (150) as the cost instead of actually evaluating $C(6)$. Always plug back in.",
      "hint": "After finding where $C'(h) = 0$, plug that value back into the original $C(h)$ to find the minimum cost.",
      "steps": [
        {
          "text": "Take the first derivative:",
          "latex": "C'(h) = 6h - 36"
        },
        {
          "text": "Set it equal to zero:",
          "latex": "6h - 36 = 0 \\implies h = 6"
        },
        {
          "text": "Confirm it's a min:",
          "latex": "C''(h) = 6 > 0 \\quad\\text{(concave up, minimum)}"
        },
        {
          "text": "Find the minimum cost:",
          "latex": "C(6) = 3(36) - 36(6) + 150 = 108 - 216 + 150 = 42\\,\\text{dollars/m}"
        }
      ],
      "handbookPage": "p. 46",
      "handbookFormula": "f'(a) = 0 \\text{ and } f''(a) > 0 \\implies \\text{minimum}",
      "videoUrl": null,
      "traps": [
        "Giving the constant term as the min cost instead of evaluating C(6)",
        "Arithmetic error in evaluating the quadratic at h = 6"
      ],
      "diagram": null
    },
    {
      "id": "math-ad-q3",
      "statement": "A beam deflection curve is modeled by $y(x) = x^3 - 12x^2 + 36x$, where $x$ is in meters along the beam and $y$ is deflection. At what point does the curvature of the beam change direction (inflection point)?",
      "choices": [
        {
          "id": "c1",
          "text": "$x = 2\\,\\text{m}$"
        },
        {
          "id": "c2",
          "text": "$x = 3\\,\\text{m}$"
        },
        {
          "id": "c3",
          "text": "$x = 6\\,\\text{m}$"
        },
        {
          "id": "c4",
          "text": "$x = 4\\,\\text{m}$"
        }
      ],
      "correctAnswerId": "c4",
      "difficulty": "hard",
      "eli5": "An inflection point is where the curve changes from bending one way to bending the other — concave up to concave down or vice versa. Set the SECOND derivative to zero, not the first. That is the most common mistake: students set y' = 0 and find critical points instead. The choices x = 2 m and x = 6 m are the critical points where y' = 0 — those are max/min locations, not inflection points. The inflection point is where y'' = 0 and actually changes sign.",
      "hint": "Inflection points come from the second derivative, not the first. Set $y''(x) = 0$.",
      "steps": [
        {
          "text": "Take the first derivative:",
          "latex": "y'(x) = 3x^2 - 24x + 36"
        },
        {
          "text": "Take the second derivative:",
          "latex": "y''(x) = 6x - 24"
        },
        {
          "text": "Set the second derivative to zero:",
          "latex": "6x - 24 = 0 \\implies x = 4"
        },
        {
          "text": "Verify sign change: $y''(3) = -6 < 0$ and $y''(5) = 6 > 0$ — sign changes, confirming inflection point.",
          "latex": null
        }
      ],
      "handbookPage": "p. 46",
      "handbookFormula": "f''(a) = 0 \\text{ and } f''(x) \\text{ changes sign} \\implies \\text{inflection point}",
      "videoUrl": null,
      "traps": [
        "Setting y'(x) = 0 instead of y''(x) = 0 (finding critical points instead of inflection points)",
        "Not verifying that y'' actually changes sign at the candidate point"
      ],
      "diagram": { "component": "BeamInflection", "props": { "length": 12 } }
    }
  ],
};
