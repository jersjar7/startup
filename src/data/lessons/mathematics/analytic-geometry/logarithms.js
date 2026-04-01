export default {
  "id": "logarithms",
  "name": "Logarithms",
  "subtopicId": "analytic-geometry",
  "application": "Logarithms show up across multiple FE Civil topics — computing the time for a contaminant to decay to safe levels in environmental engineering, finding the number of compounding periods in engineering economics, and working with the pH scale in water quality. On the FE, log questions tend to be algebra problems: simplify an expression using log rules, change bases, or solve an equation where the unknown is in the exponent. The formulas are all in the handbook — the skill is knowing which identity to apply.",
  "content": [
    {
      "type": "text",
      "body": "A logarithm answers the question: what power do I raise the base to in order to get this number?"
    },
    {
      "type": "heading",
      "body": "Definition"
    },
    {
      "type": "formula",
      "latex": "\\log_b(x) = c \\quad\\Longleftrightarrow\\quad b^c = x"
    },
    {
      "type": "heading",
      "body": "Two Common Bases"
    },
    {
      "type": "text",
      "body": "$\\ln x$ means base $e$ (natural log). $\\log x$ means base 10 on the FE."
    },
    {
      "type": "heading",
      "body": "Base Change Formula"
    },
    {
      "type": "formula",
      "latex": "\\log_b x = \\frac{\\log_a x}{\\log_a b}",
      "label": "Convert between any two bases"
    },
    {
      "type": "text",
      "body": "The most useful form: $\\ln x = 2.302585 \\cdot \\log_{10} x$."
    },
    {
      "type": "heading",
      "body": "Key Identities"
    },
    {
      "type": "formula",
      "latex": "\\log(xy) = \\log x + \\log y",
      "label": "Product rule"
    },
    {
      "type": "formula",
      "latex": "\\log\\!\\left(\\frac{x}{y}\\right) = \\log x - \\log y",
      "label": "Quotient rule"
    },
    {
      "type": "formula",
      "latex": "\\log(x^c) = c\\,\\log x",
      "label": "Power rule"
    },
    {
      "type": "formula",
      "latex": "\\log_b b = 1 \\qquad \\log 1 = 0",
      "label": "Special values"
    },
    {
      "type": "callout",
      "variant": "tip",
      "body": "Most FE log problems boil down to one move: use the power rule to pull the exponent down, then solve the resulting linear equation."
    },
    {
      "type": "callout",
      "variant": "warning",
      "body": "There is no log rule for $\\log(x + y)$. Students who try to split a sum inside a log lose easy points. Only products, quotients, and powers have rules."
    }
  ],
  "illustration": null,
  "problems": [
    {
      "id": "math-log-q1",
      "statement": "Solve for $x$: $\\log_{10}(10^x) = 3.5$",
      "choices": [
        {
          "id": "c1",
          "text": "35"
        },
        {
          "id": "c2",
          "text": "3.5"
        },
        {
          "id": "c3",
          "text": "1,000"
        },
        {
          "id": "c4",
          "text": "0.35"
        }
      ],
      "correctAnswerId": "c2",
      "difficulty": "easy",
      "eli5": "The power rule says you can pull the exponent out front: log(10^x) = x log(10). And log base 10 of 10 equals 1 because \"10 to the what power gives 10? The answer is 1.\" So the whole thing simplifies to just x = 3.5. The trap is overthinking it — some students try to compute 10^3.5 and get confused. The log and the exponent with the same base just cancel.",
      "hint": "What happens when the base of the log matches the base of the exponent?",
      "steps": [
        {
          "text": "Apply the power rule:",
          "latex": "\\log_{10}(10^x) = x \\cdot \\log_{10}(10)"
        },
        {
          "text": "Since $\\log_{10}(10) = 1$:",
          "latex": "x \\cdot 1 = 3.5"
        },
        {
          "text": "Therefore:",
          "latex": "x = 3.5"
        }
      ],
      "handbookPage": "p. 36",
      "handbookFormula": "\\log_b b^n = n",
      "videoUrl": null,
      "traps": [
        "Computing 10^3.5 instead of recognizing the identity",
        "Multiplying 10 by 3.5"
      ],
      "diagram": null
    },
    {
      "id": "math-log-q2",
      "statement": "A contaminant in a groundwater well decays according to $C = C_0 \\cdot e^{-0.03t}$, where $t$ is in days. How many days until the concentration drops to 25% of its initial value?",
      "choices": [
        {
          "id": "c1",
          "text": "8.3 days"
        },
        {
          "id": "c2",
          "text": "33.3 days"
        },
        {
          "id": "c3",
          "text": "46.2 days"
        },
        {
          "id": "c4",
          "text": "75.0 days"
        }
      ],
      "correctAnswerId": "c3",
      "difficulty": "medium",
      "eli5": "You need to \"undo\" the exponential, and the natural log does exactly that — ln(e^something) = something. So take ln of both sides to bring the exponent down. The main trap is forgetting to divide out C_0 first, or getting confused by the negatives. Both the ln(0.25) and the -0.03 are negative, so they cancel and t comes out positive — which makes sense because time can't be negative.",
      "hint": "Divide both sides by $C_0$ first, then take the natural log to isolate $t$.",
      "steps": [
        {
          "text": "Set $C = 0.25 C_0$ and divide both sides by $C_0$:",
          "latex": "0.25 = e^{-0.03t}"
        },
        {
          "text": "Take the natural log of both sides:",
          "latex": "\\ln(0.25) = -0.03t"
        },
        {
          "text": "Evaluate $\\ln(0.25)$:",
          "latex": "-1.386 = -0.03t"
        },
        {
          "text": "Solve for $t$:",
          "latex": "t = \\frac{-1.386}{-0.03} = 46.2\\,\\text{days}"
        }
      ],
      "handbookPage": "p. 36",
      "handbookFormula": "\\log_b(x) = c \\iff b^c = x",
      "videoUrl": null,
      "traps": [
        "Forgetting to divide by C_0 before taking the log",
        "Sign error with the two negatives giving a negative time"
      ],
      "diagram": null
    },
    {
      "id": "math-log-q3",
      "statement": "Simplify the expression: $\\log_2(32) - \\log_2(4) + \\log_2(8)$",
      "choices": [
        {
          "id": "c1",
          "text": "5"
        },
        {
          "id": "c2",
          "text": "36"
        },
        {
          "id": "c3",
          "text": "6"
        },
        {
          "id": "c4",
          "text": "8"
        }
      ],
      "correctAnswerId": "c3",
      "difficulty": "hard",
      "eli5": "Three terms with the same base — combine them. Subtraction means divide, addition means multiply: log_2(32/4 * 8) = log_2(64). Then ask: 2 to the what power gives 64? Count the doublings: 2, 4, 8, 16, 32, 64 — that's 6. The trap is trying to evaluate each log separately and then doing regular arithmetic on the results without being careful. You can do it that way too (5 - 2 + 3 = 6), but combining first is faster and less error-prone. The sneaky distractor is 36 — which is what you get if you multiply the separate values (5 x 2 x 3) instead of adding them.",
      "hint": "Combine the logs into a single log using the product and quotient rules before evaluating.",
      "steps": [
        {
          "text": "Combine using log rules — quotient and product:",
          "latex": "\\log_2(32) - \\log_2(4) + \\log_2(8) = \\log_2\\!\\left(\\frac{32 \\cdot 8}{4}\\right)"
        },
        {
          "text": "Simplify inside the log:",
          "latex": "\\frac{32 \\cdot 8}{4} = \\frac{256}{4} = 64"
        },
        {
          "text": "Evaluate:",
          "latex": "\\log_2(64) = 6 \\quad\\text{because } 2^6 = 64"
        }
      ],
      "handbookPage": "pp. 36-37",
      "handbookFormula": "\\log(xy) = \\log x + \\log y \\quad\\text{and}\\quad \\log(x/y) = \\log x - \\log y",
      "videoUrl": null,
      "traps": [
        "Multiplying the individual log values instead of adding them",
        "Misapplying the quotient rule order"
      ],
      "diagram": null
    }
  ]
};
