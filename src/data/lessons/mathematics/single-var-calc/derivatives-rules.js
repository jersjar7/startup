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
      "eli5": "Quotient rule: 'lo d-hi minus hi d-lo over lo-lo.' The denominator function ($x^2 + 1$) goes first in the numerator — it multiplies the derivative of the top ($\\cos x$). Then subtract the top ($\\sin x$) times the derivative of the bottom ($2x$). The classic trap is flipping the subtraction order. Choice B has a plus where there should be a minus. Choice D has the terms in the wrong order entirely. The mnemonic saves you: lo d-hi MINUS hi d-lo.",
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
};
