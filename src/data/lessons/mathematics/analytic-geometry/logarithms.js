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
  ],
  "examProblems": [
    {
      "id": "math-log-ex1",
      "type": "computational",
      "statement": "Solve for $x$: $3^x = 81$.",
      "choices": [
        { "id": "c1", "text": "$3$" },
        { "id": "c2", "text": "$4$" },
        { "id": "c3", "text": "$27$" },
        { "id": "c4", "text": "$5$" }
      ],
      "correctAnswerId": "c2",
      "difficulty": "easy",
      "eli5": "Rewrite the equation in log form: $x = \\log_3(81)$. You're asking '3 to what power gives 81?' Count: $3^1 = 3$, $3^2 = 9$, $3^3 = 27$, $3^4 = 81$. So $x = 4$. Alternatively, take $\\log$ of both sides and use the power rule to bring $x$ down. Either way, the answer is 4. The trap is confusing 81 with $3^3 = 27$.",
      "hint": "Rewrite the equation as a logarithm: $x = \\log_3(81)$.",
      "steps": [
        { "text": "Rewrite in log form:", "latex": "x = \\log_3(81)" },
        { "text": "Recognize that $3^4 = 81$:", "latex": "x = 4" }
      ],
      "handbookPage": "p. 36",
      "handbookFormula": "\\log_b(x) = c \\iff b^c = x",
      "videoUrl": null,
      "traps": [
        "Confusing powers of 3 — 3^3 = 27, not 81",
        "Dividing 81 by 3 repeatedly but losing count"
      ],
      "diagram": null
    },
    {
      "id": "math-log-ex2",
      "type": "computational",
      "statement": "Simplify: $\\ln(e^4) + \\ln(e^{-1})$.",
      "choices": [
        { "id": "c1", "text": "$3$" },
        { "id": "c2", "text": "$4$" },
        { "id": "c3", "text": "$5$" },
        { "id": "c4", "text": "$-4$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "Use the identity $\\ln(e^n) = n$ on each term. The first term gives 4, the second gives $-1$. Add them: $4 + (-1) = 3$. You could also combine first using the product rule: $\\ln(e^4 \\cdot e^{-1}) = \\ln(e^3) = 3$. Either path works. The trap is multiplying the exponents instead of adding them ($4 \\times -1 = -4$), which is Choice D.",
      "hint": "Apply $\\ln(e^n) = n$ to each term, then add the results.",
      "steps": [
        { "text": "Apply the identity to each term:", "latex": "\\ln(e^4) = 4 \\quad\\text{and}\\quad \\ln(e^{-1}) = -1" },
        { "text": "Add:", "latex": "4 + (-1) = 3" }
      ],
      "handbookPage": "p. 36",
      "handbookFormula": "\\ln(e^n) = n",
      "videoUrl": null,
      "traps": [
        "Multiplying the exponents (4 times -1) instead of adding",
        "Dropping the negative sign on the second term"
      ],
      "diagram": null
    },
    {
      "id": "math-log-ex3",
      "type": "computational",
      "statement": "An investment doubles in value according to $2 = e^{0.06t}$, where $t$ is in years. How many years does it take to double?",
      "choices": [
        { "id": "c1", "text": "$8.3$ years" },
        { "id": "c2", "text": "$11.6$ years" },
        { "id": "c3", "text": "$16.7$ years" },
        { "id": "c4", "text": "$33.3$ years" }
      ],
      "correctAnswerId": "c2",
      "difficulty": "medium",
      "eli5": "Take the natural log of both sides to bring the exponent down: $\\ln(2) = 0.06t$. Then divide: $t = \\ln(2) / 0.06 = 0.6931 / 0.06 = 11.6$ years. The main mistake is using $\\log_{10}(2)$ instead of $\\ln(2)$ — those are different numbers. Since the base of the exponent is $e$, you need the natural log to cancel it.",
      "hint": "Take $\\ln$ of both sides to undo the exponential, then isolate $t$.",
      "steps": [
        { "text": "Take natural log of both sides:", "latex": "\\ln(2) = 0.06t" },
        { "text": "Solve for $t$:", "latex": "t = \\frac{\\ln(2)}{0.06} = \\frac{0.6931}{0.06} = 11.6\\,\\text{years}" }
      ],
      "handbookPage": "p. 36",
      "handbookFormula": "\\ln(e^x) = x",
      "videoUrl": null,
      "traps": [
        "Using log base 10 instead of natural log",
        "Dividing 0.06 by ln(2) instead of the other way around"
      ],
      "diagram": null
    },
    {
      "id": "math-log-ex4",
      "type": "conceptual",
      "statement": "Which of the following is a valid logarithmic identity?",
      "choices": [
        { "id": "c1", "text": "$\\log(x + y) = \\log x + \\log y$" },
        { "id": "c2", "text": "$\\log(x - y) = \\log x - \\log y$" },
        { "id": "c3", "text": "$\\log(x^c) = c \\cdot \\log x$" },
        { "id": "c4", "text": "$\\log(xy) = \\log x \\cdot \\log y$" }
      ],
      "correctAnswerId": "c3",
      "difficulty": "hard",
      "eli5": "The power rule says you can pull an exponent out as a coefficient: $\\log(x^c) = c \\cdot \\log x$. The other three choices are the most common log mistakes students make. There is NO log rule for sums ($x + y$) or differences ($x - y$) inside a log. And the product rule says $\\log(xy) = \\log x + \\log y$ (addition), not multiplication. If you remember only one thing: logs turn multiplication into addition and powers into multiplication — never sums into anything.",
      "hint": "Only products, quotients, and powers have log identities. Sums and differences inside a log cannot be split.",
      "steps": [
        { "text": "The power rule states:", "latex": "\\log(x^c) = c \\cdot \\log x" },
        { "text": "Choice A is wrong: $\\log(x + y) \\neq \\log x + \\log y$ — no identity for sums.", "latex": null },
        { "text": "Choice B is wrong: $\\log(x - y) \\neq \\log x - \\log y$ — no identity for differences.", "latex": null },
        { "text": "Choice D is wrong: the product rule gives addition, not multiplication: $\\log(xy) = \\log x + \\log y$.", "latex": null }
      ],
      "handbookPage": "p. 36",
      "handbookFormula": "\\log(x^c) = c\\,\\log x",
      "videoUrl": null,
      "traps": [
        "Confusing the product rule — log(xy) = log x + log y, not log x times log y",
        "Thinking log(x + y) can be split — there is no identity for sums inside a log"
      ],
      "diagram": null
    }
  ]
};
