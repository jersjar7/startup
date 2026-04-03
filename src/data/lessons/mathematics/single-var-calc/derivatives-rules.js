export default {
  "id": "derivatives-rules",
  "name": "Derivatives & Derivative Rules",
  "subtopicId": "single-var-calc",
  "application": "Civil engineers use derivatives any time they need a rate of change — the slope of a deflection curve to find beam rotation, the rate of flow change in a pipe to detect surges, or the velocity of a settling particle in a sedimentation tank. On the FE, derivative questions are usually 'apply the right rule' problems: you see a function, pick the correct derivative rule from the handbook table, and crank through the algebra. The chain rule shows up the most because the FE loves composite functions like sin(3x²) or e^(-0.5t).",
  "content": [
    {
      "type": "text",
      "body": "The derivative of $y = f(x)$ gives the instantaneous rate of change. The handbook has a full table of 27 derivative formulas — you don't memorize them, you look them up. But you do need to know which rule to apply."
    },
    {
      "type": "heading",
      "body": "Power Rule"
    },
    {
      "type": "formula",
      "latex": "\\frac{d}{dx}(x^n) = nx^{n-1}"
    },
    {
      "type": "heading",
      "body": "Product Rule"
    },
    {
      "type": "formula",
      "latex": "\\frac{d}{dx}(uv) = u\\frac{dv}{dx} + v\\frac{du}{dx}",
      "label": "Two functions multiplied together"
    },
    {
      "type": "heading",
      "body": "Quotient Rule"
    },
    {
      "type": "formula",
      "latex": "\\frac{d}{dx}\\!\\left(\\frac{u}{v}\\right) = \\frac{v\\,\\frac{du}{dx} - u\\,\\frac{dv}{dx}}{v^2}",
      "label": "lo d-hi minus hi d-lo over lo-lo"
    },
    {
      "type": "heading",
      "body": "Chain Rule"
    },
    {
      "type": "formula",
      "latex": "\\frac{d}{dx}[f(g(x))] = f'(g(x)) \\cdot g'(x)",
      "label": "Derivative of outer times derivative of inner"
    },
    {
      "type": "heading",
      "body": "Common Derivatives"
    },
    {
      "type": "formula",
      "latex": "\\frac{d}{dx}(\\sin u) = \\cos u \\cdot \\frac{du}{dx}",
      "label": "Trig — always chain rule"
    },
    {
      "type": "formula",
      "latex": "\\frac{d}{dx}(e^u) = e^u \\cdot \\frac{du}{dx}",
      "label": "Exponential — always chain rule"
    },
    {
      "type": "formula",
      "latex": "\\frac{d}{dx}(\\ln u) = \\frac{1}{u} \\cdot \\frac{du}{dx}",
      "label": "Natural log — always chain rule"
    },
    {
      "type": "callout",
      "variant": "tip",
      "body": "Almost every FE derivative problem is a chain rule problem in disguise. Ask yourself: is the argument anything other than plain $x$? If yes, chain rule."
    },
    {
      "type": "callout",
      "variant": "warning",
      "body": "The quotient rule is the #1 sign-error generator on the FE. The numerator is $v\\,du - u\\,dv$, not the other way around. A mnemonic: 'lo d-hi minus hi d-lo' — the denominator function ($v$, the 'lo') goes first."
    }
  ],
  "illustration": null,
  "problems": [
    {
      "id": "math-dr-q1",
      "statement": "Find the derivative of $f(x) = (3x + 5)^4$.",
      "choices": [
        {
          "id": "c1",
          "text": "$4(3x + 5)^3$"
        },
        {
          "id": "c2",
          "text": "$12(3x + 5)^3$"
        },
        {
          "id": "c3",
          "text": "$12(3x + 5)^4$"
        },
        {
          "id": "c4",
          "text": "$4(3)^3$"
        }
      ],
      "correctAnswerId": "c2",
      "difficulty": "easy",
      "eli5": "The power rule says bring the exponent down and subtract one from the power. But the argument isn't just x — it's 3x + 5 — so you have to chain rule it. That means you also multiply by the derivative of the inside, which is 3. The most common mistake is forgetting that extra factor of 3. Choice A is exactly what you get if you skip the chain rule.",
      "hint": "The argument isn't plain x — what extra factor does the chain rule add?",
      "steps": [
        {
          "text": "Recognize this as a chain rule problem: the outer function is $u^4$ and the inner function is $u = 3x + 5$.",
          "latex": null
        },
        {
          "text": "Differentiate the outer function:",
          "latex": "4(3x + 5)^3"
        },
        {
          "text": "Multiply by the derivative of the inner function:",
          "latex": "4(3x + 5)^3 \\cdot 3 = 12(3x + 5)^3"
        }
      ],
      "handbookPage": "p. 49",
      "handbookFormula": "\\frac{d}{dx}(u^n) = nu^{n-1}\\frac{du}{dx}",
      "videoUrl": null,
      "traps": [
        "Forgetting the chain rule and omitting the factor of 3",
        "Leaving the exponent as 4 instead of reducing to 3"
      ],
      "diagram": null
    },
    {
      "id": "math-dr-q2",
      "statement": "Find the derivative of $f(x) = x^2 e^{3x}$.",
      "choices": [
        {
          "id": "c1",
          "text": "$2xe^{3x}$"
        },
        {
          "id": "c2",
          "text": "$6x^2 e^{3x}$"
        },
        {
          "id": "c3",
          "text": "$e^{3x}(2x + 3x^2)$"
        },
        {
          "id": "c4",
          "text": "$e^{3x}(2x + x^2)$"
        }
      ],
      "correctAnswerId": "c3",
      "difficulty": "medium",
      "eli5": "Two functions multiplied together means product rule. The tricky part is that e^(3x) also needs the chain rule — its derivative is 3e^(3x), not just e^(3x). Choice D is what you get if you forget that chain rule factor of 3 on the exponential. Choice A only differentiates the x² part and ignores the product rule entirely. Always ask: am I using BOTH terms of the product rule?",
      "hint": "Two functions multiplied means product rule. And $e^{3x}$ needs the chain rule for its own derivative.",
      "steps": [
        {
          "text": "Identify $u = x^2$ and $v = e^{3x}$. This needs the product rule.",
          "latex": null
        },
        {
          "text": "Find each derivative: $du/dx = 2x$ and $dv/dx = 3e^{3x}$ (chain rule on the exponential).",
          "latex": null
        },
        {
          "text": "Apply the product rule:",
          "latex": "f'(x) = x^2 \\cdot 3e^{3x} + e^{3x} \\cdot 2x"
        },
        {
          "text": "Factor out $e^{3x}$:",
          "latex": "f'(x) = e^{3x}(3x^2 + 2x)"
        }
      ],
      "handbookPage": "p. 49",
      "handbookFormula": "\\frac{d}{dx}(uv) = u\\frac{dv}{dx} + v\\frac{du}{dx}",
      "videoUrl": null,
      "traps": [
        "Forgetting the chain rule on e^(3x) (missing the factor of 3)",
        "Only differentiating one factor and ignoring the product rule"
      ],
      "diagram": null
    },
    {
      "id": "math-dr-q3",
      "statement": "Find the derivative of $f(x) = \\frac{\\sin x}{x^2 + 1}$.",
      "choices": [
        {
          "id": "c1",
          "text": "$\\frac{\\cos x}{2x}$"
        },
        {
          "id": "c2",
          "text": "$\\frac{(x^2 + 1)\\cos x + 2x\\sin x}{(x^2 + 1)^2}$"
        },
        {
          "id": "c3",
          "text": "$\\frac{(x^2 + 1)\\cos x - 2x\\sin x}{(x^2 + 1)^2}$"
        },
        {
          "id": "c4",
          "text": "$\\frac{2x\\sin x - (x^2 + 1)\\cos x}{(x^2 + 1)^2}$"
        }
      ],
      "correctAnswerId": "c3",
      "difficulty": "hard",
      "eli5": "Quotient rule: 'lo d-hi minus hi d-lo over lo-lo.' The denominator function (x² + 1) goes first in the numerator — it multiplies the derivative of the top (cos x). Then subtract the top (sin x) times the derivative of the bottom (2x). The classic trap is flipping the subtraction order. Choice B has a plus where there should be a minus. Choice D has the terms in the wrong order entirely. The mnemonic saves you: lo d-hi MINUS hi d-lo.",
      "hint": "'Lo d-hi minus hi d-lo over lo-lo' — the bottom function goes first in the numerator.",
      "steps": [
        {
          "text": "Identify $u = \\sin x$ and $v = x^2 + 1$. This needs the quotient rule.",
          "latex": null
        },
        {
          "text": "Find each derivative: $du/dx = \\cos x$ and $dv/dx = 2x$.",
          "latex": null
        },
        {
          "text": "Apply the quotient rule:",
          "latex": "f'(x) = \\frac{(x^2 + 1)\\cos x - \\sin x \\cdot 2x}{(x^2 + 1)^2}"
        }
      ],
      "handbookPage": "p. 49",
      "handbookFormula": "\\frac{d}{dx}\\!\\left(\\frac{u}{v}\\right) = \\frac{v\\,\\frac{du}{dx} - u\\,\\frac{dv}{dx}}{v^2}",
      "videoUrl": null,
      "traps": [
        "Flipping the subtraction order in the quotient rule numerator",
        "Forgetting to square the denominator",
        "Simplifying the denominator instead of leaving it as (x² + 1)²"
      ],
      "diagram": null
    }
  ],
  "examProblems": [
    {
      "id": "math-dr-ex1",
      "type": "computational",
      "statement": "Find the derivative of $f(x) = \\ln(5x^2 + 1)$.",
      "choices": [
        { "id": "c1", "text": "$\\frac{1}{5x^2 + 1}$" },
        { "id": "c2", "text": "$\\frac{10x}{5x^2 + 1}$" },
        { "id": "c3", "text": "$\\frac{5x}{5x^2 + 1}$" },
        { "id": "c4", "text": "$\\frac{2x}{5x^2 + 1}$" }
      ],
      "correctAnswerId": "c2",
      "difficulty": "easy",
      "eli5": "The derivative of $\\ln(u)$ is $1/u$ times $du/dx$ — chain rule. The outer derivative gives $1/(5x^2 + 1)$, and the inner derivative is $10x$. Multiply them together. Choice A is what you get if you skip the chain rule entirely. Choice C misses the factor of 2 from differentiating $x^2$.",
      "hint": "The argument is not plain $x$ — what does the chain rule add?",
      "steps": [
        { "text": "Identify the chain rule: outer function is $\\ln(u)$, inner function is $u = 5x^2 + 1$.", "latex": null },
        { "text": "Derivative of the outer:", "latex": "\\frac{1}{5x^2 + 1}" },
        { "text": "Multiply by derivative of the inner:", "latex": "\\frac{1}{5x^2 + 1} \\cdot 10x = \\frac{10x}{5x^2 + 1}" }
      ],
      "handbookPage": "p. 49",
      "handbookFormula": "\\frac{d}{dx}(\\ln u) = \\frac{1}{u} \\cdot \\frac{du}{dx}",
      "videoUrl": null,
      "traps": [
        "Forgetting the chain rule and omitting the inner derivative",
        "Getting the inner derivative wrong — d/dx(5x^2) = 10x, not 5x"
      ],
      "diagram": null
    },
    {
      "id": "math-dr-ex2",
      "type": "computational",
      "statement": "Find the derivative of $g(t) = t^3 \\sin(2t)$.",
      "choices": [
        { "id": "c1", "text": "$3t^2 \\sin(2t) + 2t^3 \\cos(2t)$" },
        { "id": "c2", "text": "$3t^2 \\cos(2t)$" },
        { "id": "c3", "text": "$6t^2 \\cos(2t)$" },
        { "id": "c4", "text": "$3t^2 \\sin(2t) + t^3 \\cos(2t)$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "Two functions multiplied means product rule. And $\\sin(2t)$ needs the chain rule for its derivative — you get $\\cos(2t) \\cdot 2$, not just $\\cos(2t)$. Choice D is the classic trap: it applies the product rule correctly but forgets the chain rule factor of 2 on the trig part. Choice B only differentiates one factor. Always check: did I use BOTH product rule terms, and did I chain rule the inner function?",
      "hint": "Product rule first, then chain rule on $\\sin(2t)$.",
      "steps": [
        { "text": "Identify $u = t^3$ and $v = \\sin(2t)$.", "latex": null },
        { "text": "Derivatives: $du/dt = 3t^2$ and $dv/dt = 2\\cos(2t)$ (chain rule).", "latex": null },
        { "text": "Apply the product rule:", "latex": "g'(t) = t^3 \\cdot 2\\cos(2t) + \\sin(2t) \\cdot 3t^2" },
        { "text": "Simplify:", "latex": "g'(t) = 3t^2 \\sin(2t) + 2t^3 \\cos(2t)" }
      ],
      "handbookPage": "p. 49",
      "handbookFormula": "\\frac{d}{dx}(uv) = u\\frac{dv}{dx} + v\\frac{du}{dx}",
      "videoUrl": null,
      "traps": [
        "Forgetting the chain rule factor of 2 when differentiating sin(2t)",
        "Only differentiating one of the two factors"
      ],
      "diagram": null
    },
    {
      "id": "math-dr-ex3",
      "type": "computational",
      "statement": "Find the derivative of $h(x) = \\frac{e^x}{x + 3}$.",
      "choices": [
        { "id": "c1", "text": "$\\frac{e^x(x + 2)}{(x + 3)^2}$" },
        { "id": "c2", "text": "$\\frac{e^x}{(x + 3)^2}$" },
        { "id": "c3", "text": "$\\frac{e^x(x + 4)}{(x + 3)^2}$" },
        { "id": "c4", "text": "$\\frac{e^x}{x + 3} - \\frac{e^x}{(x + 3)^2}$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "Quotient rule: lo d-hi minus hi d-lo over lo-lo. The denominator ($x + 3$) times the derivative of the numerator ($e^x$) minus the numerator ($e^x$) times the derivative of the denominator (1), all over $(x + 3)^2$. Factor out $e^x$: you get $e^x(x + 3 - 1)/(x + 3)^2 = e^x(x + 2)/(x + 3)^2$. Choice D is correct but unsimplified — on the FE, always check if your answer matches a simplified form in the choices.",
      "hint": "Apply the quotient rule, then factor $e^x$ from the numerator.",
      "steps": [
        { "text": "Identify $u = e^x$ and $v = x + 3$.", "latex": null },
        { "text": "Apply the quotient rule:", "latex": "h'(x) = \\frac{(x+3)e^x - e^x \\cdot 1}{(x+3)^2}" },
        { "text": "Factor $e^x$ from the numerator:", "latex": "h'(x) = \\frac{e^x(x + 3 - 1)}{(x+3)^2} = \\frac{e^x(x+2)}{(x+3)^2}" }
      ],
      "handbookPage": "p. 49",
      "handbookFormula": "\\frac{d}{dx}\\!\\left(\\frac{u}{v}\\right) = \\frac{v\\,\\frac{du}{dx} - u\\,\\frac{dv}{dx}}{v^2}",
      "videoUrl": null,
      "traps": [
        "Flipping the subtraction in the quotient rule — it's v du - u dv, not u dv - v du",
        "Forgetting to factor and not matching any answer choice"
      ],
      "diagram": null
    },
    {
      "id": "math-dr-ex4",
      "type": "conceptual",
      "statement": "The derivative of $\\sin(3x^2)$ requires which rule(s)?",
      "choices": [
        { "id": "c1", "text": "Power rule only" },
        { "id": "c2", "text": "Chain rule applied once" },
        { "id": "c3", "text": "Chain rule applied twice (nested)" },
        { "id": "c4", "text": "Product rule and chain rule" }
      ],
      "correctAnswerId": "c3",
      "difficulty": "hard",
      "eli5": "There are two layers of composition here. The outermost function is $\\sin(\\cdot)$, and the inner function is $3x^2$. To differentiate $\\sin(u)$ you get $\\cos(u) \\cdot du/dx$. But $u = 3x^2$, and differentiating that uses the power rule (which is itself a form of chain rule applied to the $x^2$). So the chain rule fires twice: once for $\\sin \\to \\cos$, once for $3x^2 \\to 6x$. There's no product of two separate functions of $x$, so the product rule doesn't apply here.",
      "hint": "Count the layers of composition: how many functions are nested inside each other?",
      "steps": [
        { "text": "Outer function: $\\sin(u)$ where $u = 3x^2$.", "latex": null },
        { "text": "First chain rule application: $\\cos(3x^2) \\cdot \\frac{d}{dx}(3x^2)$.", "latex": null },
        { "text": "Second chain rule application (power rule on $x^2$):", "latex": "\\frac{d}{dx}(3x^2) = 6x" },
        { "text": "Full result:", "latex": "\\frac{d}{dx}[\\sin(3x^2)] = 6x\\cos(3x^2)" }
      ],
      "handbookPage": "p. 49",
      "handbookFormula": "\\frac{d}{dx}[f(g(x))] = f'(g(x)) \\cdot g'(x)",
      "videoUrl": null,
      "traps": [
        "Thinking a single chain rule application is enough — the inner function 3x^2 also needs differentiation",
        "Confusing this with a product rule situation — sin(3x^2) is a composition, not a product"
      ],
      "diagram": null
    }
  ]
};
