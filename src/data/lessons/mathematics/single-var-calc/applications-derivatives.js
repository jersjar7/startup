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
      "eli5": "Take the derivative, set it to zero, solve for x. That's it. The second derivative is -4, which is negative — concave down — so it's a max, not a min. Since the leading coefficient is negative, the parabola opens downward, so of course it's a max. Choice C (x = 8) is what you get if you forget the factor of 2 when differentiating -2x². Always double-check your power rule on the leading term.",
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
        "Forgetting the coefficient when differentiating -2x² (getting -2x instead of -4x)",
        "Reporting the max value of f(x) instead of the x-location"
      ],
      "diagram": null
    },
    {
      "id": "math-ad-q2",
      "statement": "A civil engineer models the cost per meter of a retaining wall as $C(h) = 3h^2 - 36h + 150$, where $h$ is the wall height in meters. What wall height minimizes the cost, and what is the minimum cost?",
      "choices": [
        {
          "id": "c1",
          "text": "$h = 6\\,\\text{m}$, $C = 42\\,\\text{\\$/m}$"
        },
        {
          "id": "c2",
          "text": "$h = 6\\,\\text{m}$, $C = 150\\,\\text{\\$/m}$"
        },
        {
          "id": "c3",
          "text": "$h = 12\\,\\text{m}$, $C = 42\\,\\text{\\$/m}$"
        },
        {
          "id": "c4",
          "text": "$h = 3\\,\\text{m}$, $C = 93\\,\\text{\\$/m}$"
        }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "Same process — derivative, set to zero, solve. You get h = 6. The second derivative is positive (6 > 0), so it's concave up — a minimum. The extra step is plugging h = 6 back into the original function to get the cost. Choice B is the trap for students who find the right h but give the constant term (150) as the cost instead of actually evaluating C(6). Always plug back in.",
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
          "latex": "C(6) = 3(36) - 36(6) + 150 = 108 - 216 + 150 = 42\\,\\text{\\$/m}"
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
          "text": "$x = 4\\,\\text{m}$"
        },
        {
          "id": "c3",
          "text": "$x = 6\\,\\text{m}$"
        },
        {
          "id": "c4",
          "text": "$x = 3\\,\\text{m}$"
        }
      ],
      "correctAnswerId": "c2",
      "difficulty": "hard",
      "eli5": "An inflection point is where the curve changes from bending one way to bending the other — concave up to concave down or vice versa. Set the SECOND derivative to zero, not the first. That's the most common mistake: students set y' = 0 and find critical points instead. Choice A (x = 2) and choice C (x = 6) are the critical points where y' = 0 — those are max/min locations, not inflection points. The inflection point is where y'' = 0 and actually changes sign.",
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
      "diagram": null
    }
  ],
  "examProblems": [
    {
      "id": "math-ad-ex1",
      "type": "computational",
      "statement": "Find the $x$-value at which $f(x) = x^3 - 6x^2 + 9x + 2$ has a local maximum.",
      "choices": [
        { "id": "c1", "text": "$x = 1$" },
        { "id": "c2", "text": "$x = 3$" },
        { "id": "c3", "text": "$x = 0$" },
        { "id": "c4", "text": "$x = 2$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "easy",
      "eli5": "Take the derivative: $f'(x) = 3x^2 - 12x + 9 = 3(x-1)(x-3)$. Setting it to zero gives $x = 1$ and $x = 3$. Now use the second derivative test: $f''(x) = 6x - 12$. At $x = 1$: $f''(1) = -6 < 0$ — concave down, so it's a max. At $x = 3$: $f''(3) = 6 > 0$ — concave up, so it's a min. The question asks for the max, so $x = 1$.",
      "hint": "Set $f'(x) = 0$ to find critical points, then use $f''(x)$ to classify each one.",
      "steps": [
        { "text": "Find the first derivative:", "latex": "f'(x) = 3x^2 - 12x + 9 = 3(x-1)(x-3)" },
        { "text": "Critical points: $x = 1$ and $x = 3$.", "latex": null },
        { "text": "Second derivative test:", "latex": "f''(x) = 6x - 12" },
        { "text": "At $x = 1$: $f''(1) = 6 - 12 = -6 < 0$ — local maximum.", "latex": null }
      ],
      "handbookPage": "p. 46",
      "handbookFormula": "f'(a) = 0 \\text{ and } f''(a) < 0 \\implies \\text{maximum}",
      "videoUrl": null,
      "traps": [
        "Reporting the local minimum (x = 3) instead of the local maximum (x = 1)",
        "Forgetting to factor and making an error solving the quadratic"
      ],
      "diagram": null
    },
    {
      "id": "math-ad-ex2",
      "type": "computational",
      "statement": "A civil engineer models the total cost of a drainage pipe as $C(d) = 500d + \\frac{20000}{d}$, where $d$ is the diameter in meters. What diameter minimizes the cost?",
      "choices": [
        { "id": "c1", "text": "$d = 40\\,\\text{m}$" },
        { "id": "c2", "text": "$d = \\sqrt{40}\\,\\text{m} \\approx 6.32\\,\\text{m}$" },
        { "id": "c3", "text": "$d = 20\\,\\text{m}$" },
        { "id": "c4", "text": "$d = 4\\,\\text{m}$" }
      ],
      "correctAnswerId": "c2",
      "difficulty": "medium",
      "eli5": "Rewrite $20000/d$ as $20000d^{-1}$, then differentiate: $C'(d) = 500 - 20000d^{-2}$. Set to zero: $500 = 20000/d^2$, so $d^2 = 40$ and $d = \\sqrt{40} \\approx 6.32$. The second derivative is $40000/d^3$, which is positive for any positive $d$, confirming a minimum. Choice A divides 20000 by 500 without solving the equation correctly.",
      "hint": "Rewrite $20000/d$ as $20000d^{-1}$ before differentiating, then set $C'(d) = 0$.",
      "steps": [
        { "text": "Differentiate:", "latex": "C'(d) = 500 - \\frac{20000}{d^2}" },
        { "text": "Set to zero:", "latex": "500 = \\frac{20000}{d^2} \\implies d^2 = \\frac{20000}{500} = 40" },
        { "text": "Solve:", "latex": "d = \\sqrt{40} \\approx 6.32\\,\\text{m}" },
        { "text": "Confirm minimum:", "latex": "C''(d) = \\frac{40000}{d^3} > 0 \\text{ for } d > 0 \\implies \\text{minimum}" }
      ],
      "handbookPage": "p. 46",
      "handbookFormula": "f'(a) = 0 \\text{ and } f''(a) > 0 \\implies \\text{minimum}",
      "videoUrl": null,
      "traps": [
        "Forgetting to apply the power rule to 20000/d — it's -20000/d^2, not -20000",
        "Dividing 20000 by 500 to get 40 but forgetting to take the square root"
      ],
      "diagram": null
    },
    {
      "id": "math-ad-ex3",
      "type": "computational",
      "statement": "Find the inflection point of $f(x) = 2x^3 - 9x^2 + 12x - 4$.",
      "choices": [
        { "id": "c1", "text": "$x = 1$" },
        { "id": "c2", "text": "$x = 2$" },
        { "id": "c3", "text": "$x = 1.5$" },
        { "id": "c4", "text": "$x = 3$" }
      ],
      "correctAnswerId": "c3",
      "difficulty": "medium",
      "eli5": "An inflection point is where the second derivative equals zero and changes sign. First derivative: $6x^2 - 18x + 12$. Second derivative: $12x - 18$. Set to zero: $x = 18/12 = 1.5$. Check sign change: $f''(1) = -6 < 0$ and $f''(2) = 6 > 0$ — yes, it changes sign. Choices A and B ($x = 1$ and $x = 2$) are the critical points where $f'(x) = 0$ — the classic mistake of using the first derivative instead of the second.",
      "hint": "Set the second derivative (not the first) to zero.",
      "steps": [
        { "text": "First derivative:", "latex": "f'(x) = 6x^2 - 18x + 12" },
        { "text": "Second derivative:", "latex": "f''(x) = 12x - 18" },
        { "text": "Set to zero:", "latex": "12x - 18 = 0 \\implies x = 1.5" },
        { "text": "Verify sign change: $f''(1) = -6$ and $f''(2) = 6$ — sign changes, confirming inflection point.", "latex": null }
      ],
      "handbookPage": "p. 46",
      "handbookFormula": "f''(a) = 0 \\text{ and } f''(x) \\text{ changes sign} \\implies \\text{inflection point}",
      "videoUrl": null,
      "traps": [
        "Using f'(x) = 0 instead of f''(x) = 0 — that gives critical points, not inflection points",
        "Arithmetic error in solving 12x = 18"
      ],
      "diagram": null
    },
    {
      "id": "math-ad-ex4",
      "type": "conceptual",
      "statement": "At a critical point where $f'(a) = 0$, the second derivative test is inconclusive when:",
      "choices": [
        { "id": "c1", "text": "$f''(a) > 0$" },
        { "id": "c2", "text": "$f''(a) < 0$" },
        { "id": "c3", "text": "$f''(a) = 0$" },
        { "id": "c4", "text": "$f''(a) \\neq 0$" }
      ],
      "correctAnswerId": "c3",
      "difficulty": "hard",
      "eli5": "The second derivative test classifies critical points as max ($f'' < 0$), min ($f'' > 0$), or inconclusive ($f'' = 0$). When the second derivative is zero, the test fails — you can't tell if it's a max, min, or neither. Consider $f(x) = x^4$: $f'(0) = 0$ and $f''(0) = 0$, but it's a minimum. Meanwhile $f(x) = x^3$: $f'(0) = 0$ and $f''(0) = 0$, but it's neither a max nor a min. Same second derivative value, different conclusions — that's why it's called inconclusive.",
      "hint": "The second derivative test gives three outcomes depending on the sign of $f''(a)$. What if the sign is neither positive nor negative?",
      "steps": [
        { "text": "The second derivative test says:", "latex": null },
        { "text": "$f''(a) > 0$ means local minimum (concave up).", "latex": null },
        { "text": "$f''(a) < 0$ means local maximum (concave down).", "latex": null },
        { "text": "$f''(a) = 0$ means the test is inconclusive — you need another method (first derivative test or higher-order derivatives).", "latex": null }
      ],
      "handbookPage": "p. 46",
      "handbookFormula": "f''(a) = 0 \\implies \\text{test is inconclusive}",
      "videoUrl": null,
      "traps": [
        "Thinking f''(a) = 0 always means inflection point — it could be a flat max/min like x^4",
        "Confusing 'inconclusive' with 'does not exist'"
      ],
      "diagram": null
    }
  ]
};
