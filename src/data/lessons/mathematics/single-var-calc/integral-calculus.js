export default {
  "id": "integral-calculus",
  "name": "Integral Calculus",
  "subtopicId": "single-var-calc",
  "application": "Civil engineers integrate constantly — computing the area under a load diagram to find total force, calculating earthwork volumes from cross-section data, finding the total flow through a culvert over time, or determining the deflection of a beam from its moment equation. The FE gives you a function and asks for an antiderivative or a definite integral. You have the integral table in the handbook, so the real skill is recognizing which formula fits and applying substitution or integration by parts when it doesn't match directly.",
  "content": [
    {
      "type": "text",
      "body": "Integration is the reverse of differentiation. On the FE, you either evaluate a definite integral (get a number) or find an indefinite integral (get a function + C). The handbook gives you 27 integral formulas — your job is pattern matching."
    },
    {
      "type": "heading",
      "body": "Indefinite Integral"
    },
    {
      "type": "formula",
      "latex": "\\int f(x)\\,dx = F(x) + C"
    },
    {
      "type": "text",
      "body": "Where $F'(x) = f(x)$. The $+C$ matters on the exam — wrong answer choices often omit it."
    },
    {
      "type": "heading",
      "body": "Power Rule for Integration"
    },
    {
      "type": "formula",
      "latex": "\\int x^n\\,dx = \\frac{x^{n+1}}{n+1} + C, \\quad n \\neq -1"
    },
    {
      "type": "text",
      "body": "This is the workhorse. When $n = -1$, it becomes $\\int \\frac{1}{x}\\,dx = \\ln|x| + C$."
    },
    {
      "type": "heading",
      "body": "Integration by Parts"
    },
    {
      "type": "formula",
      "latex": "\\int u\\,dv = uv - \\int v\\,du"
    },
    {
      "type": "text",
      "body": "Use when the integrand is a product of two different types (e.g., $x\\,e^x$, $x\\,\\sin x$). Pick $u$ using LIATE: Logs, Inverse trig, Algebraic, Trig, Exponential — earlier in the list = better choice for $u$."
    },
    {
      "type": "heading",
      "body": "U-Substitution"
    },
    {
      "type": "text",
      "body": "If you see a composite function $f(g(x)) \\cdot g'(x)$, let $u = g(x)$, then $du = g'(x)\\,dx$. This converts the integral into $\\int f(u)\\,du$, which is usually a standard form."
    },
    {
      "type": "heading",
      "body": "Definite Integral"
    },
    {
      "type": "formula",
      "latex": "\\int_a^b f(x)\\,dx = F(b) - F(a)"
    },
    {
      "type": "text",
      "body": "Find the antiderivative, plug in the upper limit, subtract the lower limit. No $+C$ needed — it cancels."
    },
    {
      "type": "callout",
      "variant": "tip",
      "body": "LIATE for integration by parts: Logs → Inverse trig → Algebraic → Trig → Exponential. Pick $u$ from whatever appears earliest in this list."
    },
    {
      "type": "callout",
      "variant": "exam",
      "body": "The FE handbook has the integral table on p. 50. You don't need to memorize all 27 formulas — but you DO need to recognize when substitution or by-parts is needed to get an integrand into a form that matches the table."
    }
  ],
  "illustration": null,
  "problems": [
    {
      "id": "math-ic-q1",
      "statement": "A retaining wall footing exerts a linearly varying pressure on the soil given by $q(x) = 3x^2$ kPa, where $x$ is in meters from the toe. Find the total force per unit width over the first 2 m of the footing.",
      "choices": [
        {
          "id": "c1",
          "text": "$4$ kN/m"
        },
        {
          "id": "c2",
          "text": "$8$ kN/m"
        },
        {
          "id": "c3",
          "text": "$12$ kN/m"
        },
        {
          "id": "c4",
          "text": "$6$ kN/m"
        }
      ],
      "correctAnswerId": "c2",
      "difficulty": "easy",
      "eli5": "Total force from a varying pressure is just the integral of the pressure function over the loaded length. Power rule: bring the exponent up by 1 and divide. The 3 and the 1/3 cancel perfectly here — clean answer, no tricks.",
      "hint": "Integrate the pressure function from 0 to 2 using the power rule.",
      "steps": [
        {
          "text": "Total force = area under the pressure curve:",
          "latex": "F = \\int_0^2 3x^2\\,dx"
        },
        {
          "text": "Apply the power rule:",
          "latex": "\\int 3x^2\\,dx = 3 \\cdot \\frac{x^3}{3} = x^3"
        },
        {
          "text": "Evaluate the definite integral:",
          "latex": "F = 2^3 - 0^3 = 8 \\text{ kN/m}"
        }
      ],
      "handbookPage": "p. 50",
      "handbookFormula": "\\int x^n\\,dx = \\frac{x^{n+1}}{n+1} + C",
      "videoUrl": null,
      "traps": [
        "Forgetting to evaluate at both limits (plugging in only the upper bound)",
        "Confusing pressure (kPa) with force (kN/m) — the integral of pressure over length gives force per unit width"
      ],
      "diagram": null
    },
    {
      "id": "math-ic-q2",
      "statement": "Evaluate $\\int_0^1 x\\,e^{2x}\\,dx$.",
      "choices": [
        {
          "id": "c1",
          "text": "$\\frac{e^2 + 1}{4}$"
        },
        {
          "id": "c2",
          "text": "$\\frac{e^2 - 1}{4}$"
        },
        {
          "id": "c3",
          "text": "$\\frac{e^2}{2}$"
        },
        {
          "id": "c4",
          "text": "$\\frac{e^2 + 1}{2}$"
        }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "You've got $x$ times $e^{2x}$ — two different types multiplied together, so it's integration by parts. LIATE says pick $u = x$ (algebraic) since it comes before exponential. Then $dv = e^{2x}\\,dx$ and you integrate that to get $v$. Watch the factor of 1/2 from integrating $e^{2x}$ — that's where most errors happen.",
      "hint": "LIATE: $x$ is algebraic (A), $e^{2x}$ is exponential (E). Algebraic comes first — let $u = x$.",
      "steps": [
        {
          "text": "Use integration by parts:",
          "latex": "\\int u\\,dv = uv - \\int v\\,du"
        },
        {
          "text": "Let $u = x$, $dv = e^{2x}\\,dx$. Then $du = dx$, $v = \\frac{e^{2x}}{2}$.",
          "latex": null
        },
        {
          "text": "Apply the formula:",
          "latex": "\\left[\\frac{x\\,e^{2x}}{2}\\right]_0^1 - \\int_0^1 \\frac{e^{2x}}{2}\\,dx"
        },
        {
          "text": "First term:",
          "latex": "\\frac{1 \\cdot e^2}{2} - 0 = \\frac{e^2}{2}"
        },
        {
          "text": "Second term:",
          "latex": "\\frac{1}{2} \\cdot \\left[\\frac{e^{2x}}{2}\\right]_0^1 = \\frac{1}{4}(e^2 - 1)"
        },
        {
          "text": "Combine:",
          "latex": "\\frac{e^2}{2} - \\frac{e^2 - 1}{4} = \\frac{2e^2 - e^2 + 1}{4} = \\frac{e^2 + 1}{4}"
        }
      ],
      "handbookPage": "p. 50",
      "handbookFormula": "\\int u\\,dv = uv - \\int v\\,du",
      "videoUrl": null,
      "traps": [
        "Forgetting the 1/2 factor when integrating $e^{2x}$ (the antiderivative is $\\frac{e^{2x}}{2}$, not $e^{2x}$)",
        "Picking $u$ and $dv$ backwards — if you let $u = e^{2x}$, the integral gets harder, not easier"
      ],
      "diagram": null
    },
    {
      "id": "math-ic-q3",
      "statement": "Evaluate $\\int_0^{\\pi/2} \\sin^3 x\\,\\cos x\\,dx$.",
      "choices": [
        {
          "id": "c1",
          "text": "$\\frac{1}{3}$"
        },
        {
          "id": "c2",
          "text": "$\\frac{1}{2}$"
        },
        {
          "id": "c3",
          "text": "$\\frac{1}{4}$"
        },
        {
          "id": "c4",
          "text": "$\\frac{1}{5}$"
        }
      ],
      "correctAnswerId": "c3",
      "difficulty": "hard",
      "eli5": "Whenever you see $\\sin^n x \\cdot \\cos x$ (or $\\cos^n x \\cdot \\sin x$), it's screaming for u-sub. The $\\cos x$ is the derivative of $\\sin x$ — that's the $g'(x)$ that makes substitution work. After substituting, you're left with a basic power rule integral. Don't forget to change the limits when it's a definite integral.",
      "hint": "Notice that $\\cos x$ is the derivative of $\\sin x$. Let $u = \\sin x$.",
      "steps": [
        {
          "text": "Recognize the pattern: $\\sin^3 x \\cdot \\cos x = f(g(x)) \\cdot g'(x)$ where $g(x) = \\sin x$.",
          "latex": null
        },
        {
          "text": "Let $u = \\sin x$, then $du = \\cos x\\,dx$.",
          "latex": null
        },
        {
          "text": "Change limits: when $x = 0$, $u = 0$; when $x = \\pi/2$, $u = 1$.",
          "latex": null
        },
        {
          "text": "Integral becomes:",
          "latex": "\\int_0^1 u^3\\,du"
        },
        {
          "text": "Apply the power rule:",
          "latex": "\\left[\\frac{u^4}{4}\\right]_0^1 = \\frac{1}{4} - 0 = \\frac{1}{4}"
        }
      ],
      "handbookPage": "p. 50",
      "handbookFormula": "\\int x^n\\,dx = \\frac{x^{n+1}}{n+1} + C",
      "videoUrl": null,
      "traps": [
        "Forgetting to change the integration limits when substituting (going back to $x$ limits with a $u$ antiderivative)",
        "Mixing up which function is $u$ and which is $du$ — the one with the higher power ($\\sin^3 x$) stays, its derivative ($\\cos x\\,dx$) becomes $du$"
      ],
      "diagram": null
    }
  ],
  "examProblems": [
    {
      "id": "math-ic-ex1",
      "type": "computational",
      "statement": "Evaluate $\\int_1^4 (2x + 3)\\,dx$.",
      "choices": [
        { "id": "c1", "text": "$24$" },
        { "id": "c2", "text": "$27$" },
        { "id": "c3", "text": "$21$" },
        { "id": "c4", "text": "$30$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "easy",
      "eli5": "Integrate term by term: the antiderivative of $2x$ is $x^2$ and the antiderivative of $3$ is $3x$. Evaluate from 1 to 4: $(16 + 12) - (1 + 3) = 28 - 4 = 24$. The trap is forgetting to evaluate at the lower limit — if you only plug in $x = 4$ you get 28, which isn't even a choice, but arithmetic mistakes can land you elsewhere.",
      "hint": "Find the antiderivative, then evaluate at the upper and lower limits and subtract.",
      "steps": [
        { "text": "Find the antiderivative:", "latex": "\\int (2x + 3)\\,dx = x^2 + 3x" },
        { "text": "Evaluate at upper limit:", "latex": "F(4) = 16 + 12 = 28" },
        { "text": "Evaluate at lower limit:", "latex": "F(1) = 1 + 3 = 4" },
        { "text": "Subtract:", "latex": "28 - 4 = 24" }
      ],
      "handbookPage": "p. 50",
      "handbookFormula": "\\int_a^b f(x)\\,dx = F(b) - F(a)",
      "videoUrl": null,
      "traps": [
        "Forgetting to evaluate at the lower limit",
        "Antiderivative error — the antiderivative of $2x$ is $x^2$, not $2x^2$"
      ],
      "diagram": null
    },
    {
      "id": "math-ic-ex2",
      "type": "computational",
      "statement": "Evaluate $\\int_0^2 4xe^{x^2}\\,dx$.",
      "choices": [
        { "id": "c1", "text": "$2(e^4 - 1)$" },
        { "id": "c2", "text": "$4(e^4 - 1)$" },
        { "id": "c3", "text": "$e^4 - 1$" },
        { "id": "c4", "text": "$2e^4$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "The $x$ out front and the $x^2$ in the exponent are screaming for u-substitution. Let $u = x^2$, so $du = 2x\\,dx$. The $4x\\,dx$ becomes $2\\,du$. The integral simplifies to $2\\int e^u\\,du = 2e^u$. Change limits: when $x = 0$, $u = 0$; when $x = 2$, $u = 4$. So you get $2(e^4 - e^0) = 2(e^4 - 1)$.",
      "hint": "The $x$ in $4x\\,dx$ and the $x^2$ in the exponent suggest $u = x^2$.",
      "steps": [
        { "text": "Let $u = x^2$, then $du = 2x\\,dx$, so $4x\\,dx = 2\\,du$.", "latex": null },
        { "text": "Change limits: $x = 0 \\to u = 0$; $x = 2 \\to u = 4$.", "latex": null },
        { "text": "Rewrite the integral:", "latex": "2\\int_0^4 e^u\\,du = 2\\left[e^u\\right]_0^4" },
        { "text": "Evaluate:", "latex": "2(e^4 - e^0) = 2(e^4 - 1)" }
      ],
      "handbookPage": "p. 50",
      "handbookFormula": "\\int e^u\\,du = e^u + C",
      "videoUrl": null,
      "traps": [
        "Forgetting to account for the factor of 2 when converting $4x\\,dx$ to $du$",
        "Not changing the limits of integration when substituting"
      ],
      "diagram": null
    },
    {
      "id": "math-ic-ex3",
      "type": "computational",
      "statement": "Evaluate $\\int_0^1 x\\,\\ln x\\,dx$. (Note: $\\lim_{x \\to 0^+} x\\ln x = 0$.)",
      "choices": [
        { "id": "c1", "text": "$-\\frac{1}{4}$" },
        { "id": "c2", "text": "$\\frac{1}{4}$" },
        { "id": "c3", "text": "$-\\frac{1}{2}$" },
        { "id": "c4", "text": "$0$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "This is an integration by parts problem. LIATE says $\\ln x$ (Log) comes before $x$ (Algebraic), so let $u = \\ln x$ and $dv = x\\,dx$. Then $du = dx/x$ and $v = x^2/2$. The formula gives $(x^2/2)\\ln x - \\int x/2\\,dx = (x^2/2)\\ln x - x^2/4$. Evaluate from 0 to 1: at $x = 1$, $\\ln 1 = 0$ so the first term vanishes, leaving $-1/4$. At $x = 0$ both terms go to 0 (given in the hint). So the answer is $-1/4$.",
      "hint": "LIATE: $\\ln x$ is a log (L), which comes first — let $u = \\ln x$.",
      "steps": [
        { "text": "Integration by parts: let $u = \\ln x$, $dv = x\\,dx$.", "latex": null },
        { "text": "Then $du = \\frac{dx}{x}$ and $v = \\frac{x^2}{2}$.", "latex": null },
        { "text": "Apply the formula:", "latex": "\\left[\\frac{x^2}{2}\\ln x\\right]_0^1 - \\int_0^1 \\frac{x^2}{2} \\cdot \\frac{1}{x}\\,dx = \\left[\\frac{x^2}{2}\\ln x\\right]_0^1 - \\int_0^1 \\frac{x}{2}\\,dx" },
        { "text": "First term at $x = 1$: $\\frac{1}{2}\\ln 1 = 0$. At $x = 0$: $0$ (given).", "latex": null },
        { "text": "Second term:", "latex": "\\int_0^1 \\frac{x}{2}\\,dx = \\frac{1}{2} \\cdot \\frac{x^2}{2}\\Big|_0^1 = \\frac{1}{4}" },
        { "text": "Combine:", "latex": "0 - \\frac{1}{4} = -\\frac{1}{4}" }
      ],
      "handbookPage": "p. 50",
      "handbookFormula": "\\int u\\,dv = uv - \\int v\\,du",
      "videoUrl": null,
      "traps": [
        "Choosing $u$ and $dv$ backwards — if you let $u = x$, you would need to integrate $\\ln x$, which is harder",
        "Forgetting the negative sign from the by-parts formula"
      ],
      "diagram": null
    },
    {
      "id": "math-ic-ex4",
      "type": "conceptual",
      "statement": "When evaluating a definite integral, why is the constant of integration $+C$ not needed?",
      "choices": [
        { "id": "c1", "text": "The constant is always zero for definite integrals" },
        { "id": "c2", "text": "The constant cancels when you subtract $F(a)$ from $F(b)$" },
        { "id": "c3", "text": "Definite integrals do not involve antiderivatives" },
        { "id": "c4", "text": "The constant is absorbed into the limits of integration" }
      ],
      "correctAnswerId": "c2",
      "difficulty": "hard",
      "eli5": "When you compute $F(b) - F(a)$, any constant $C$ appears in both terms: $(F(b) + C) - (F(a) + C) = F(b) - F(a)$. The $C$'s cancel out perfectly. It's not that $C = 0$ or that it doesn't exist — it's that it subtracts away. This is a subtle but important distinction. Choice C is flat wrong — definite integrals absolutely use antiderivatives (that's the Fundamental Theorem of Calculus). Choice A is a common misconception.",
      "hint": "Write out $F(b) + C$ and $F(a) + C$ and subtract them — what happens to $C$?",
      "steps": [
        { "text": "The antiderivative is $F(x) + C$.", "latex": null },
        { "text": "Evaluate the definite integral:", "latex": "(F(b) + C) - (F(a) + C) = F(b) - F(a)" },
        { "text": "The $+C$ terms cancel, so the constant does not affect the result.", "latex": null }
      ],
      "handbookPage": "p. 50",
      "handbookFormula": "\\int_a^b f(x)\\,dx = F(b) - F(a)",
      "videoUrl": null,
      "traps": [
        "Thinking $C = 0$ rather than understanding it cancels",
        "Believing definite integrals don't use antiderivatives"
      ],
      "diagram": null
    }
  ]
};
