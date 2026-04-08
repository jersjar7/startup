export default {
  "id": "lhopitals-rule",
  "name": "L'Hopital's Rule",
  "subtopicId": "single-var-calc",
  "application": "L'Hopital's Rule is a one-trick tool — but it appears on the FE almost every cycle. Whenever you plug a limit value into a fraction and get 0/0 or ∞/∞, you differentiate the top and bottom separately and try the limit again. Civil engineers encounter these indeterminate forms when analyzing boundary conditions in hydraulics (flow at a critical depth transition), evaluating limiting cases in structural deflection formulas, and checking asymptotic behavior of decay functions. It's a fast 1-2 minute problem if you recognize the setup.",
  "content": [
    { "type": "text", "body": "L'Hopital's Rule handles limits that produce the indeterminate forms $\\frac{0}{0}$ or $\\frac{\\infty}{\\infty}$. If direct substitution gives either form, differentiate the numerator and denominator separately — then try the limit again." },
    { "type": "heading", "body": "L'Hopital's Rule" },
    { "type": "formula", "latex": "\\text{If } \\lim_{x \\to a}\\frac{f(x)}{g(x)} = \\frac{0}{0} \\text{ or } \\frac{\\infty}{\\infty}, \\text{ then } \\lim_{x \\to a}\\frac{f(x)}{g(x)} = \\lim_{x \\to a}\\frac{f'(x)}{g'(x)}" },
    { "type": "text", "body": "You differentiate the numerator and denominator independently — this is NOT the quotient rule. You're replacing $f$ with $f'$ and $g$ with $g'$, then re-evaluating the limit." },
    { "type": "heading", "body": "When to Apply" },
    { "type": "text", "body": "Step 1: Plug in the limit value. If you get $\\frac{0}{0}$ or $\\frac{\\infty}{\\infty}$, apply L'Hopital's. If you get a real number, you're done — no rule needed. If you get $\\frac{\\text{nonzero}}{0}$, the limit is $\\pm\\infty$ (or DNE), not an indeterminate form." },
    { "type": "heading", "body": "Repeated Application" },
    { "type": "text", "body": "If after one round of differentiation the limit is still $\\frac{0}{0}$ or $\\frac{\\infty}{\\infty}$, apply the rule again. Keep going until you get a determinate form. Most FE problems resolve in 1-2 rounds." },
    { "type": "callout", "variant": "tip", "body": "Always check the form BEFORE differentiating. If direct substitution gives a real number, L'Hopital's doesn't apply — and using it anyway will give a wrong answer." },
    { "type": "callout", "variant": "warning", "body": "This is NOT the quotient rule. You differentiate the top alone and the bottom alone. Do not apply $\\frac{f'g - fg'}{g^2}$ — that's for derivatives of fractions, not limits of fractions." }
  ],
  "illustration": null,
  "problems": [
    {
      "id": "math-lh-q1",
      "statement": "Evaluate $\\lim_{x \\to 0}\\frac{\\sin x}{x}$.",
      "choices": [
        { "id": "c1", "text": "$0$" },
        { "id": "c2", "text": "$1$" },
        { "id": "c3", "text": "$\\infty$" },
        { "id": "c4", "text": "Does not exist" }
      ],
      "correctAnswerId": "c2",
      "difficulty": "easy",
      "eli5": "Plug in $x = 0$ and you get $0/0$ — that is the signal to use L'Hopital's. Derivative of $\\sin x$ is $\\cos x$, derivative of $x$ is 1. Now plug in 0 again: $\\cos(0) = 1$. Done in one round. This is probably the most classic L'Hopital's example you will ever see.",
      "hint": "Direct substitution gives 0/0. Differentiate the numerator and denominator separately.",
      "steps": [
        { "text": "Direct substitution:", "latex": "\\frac{\\sin 0}{0} = \\frac{0}{0} \\text{ — indeterminate}" },
        { "text": "Apply L'Hopital's — differentiate top and bottom:", "latex": "\\lim_{x \\to 0}\\frac{\\cos x}{1}" },
        { "text": "Evaluate:", "latex": "\\frac{\\cos 0}{1} = \\frac{1}{1} = 1" }
      ],
      "handbookPage": "p. 48",
      "handbookFormula": "\\lim_{x \\to a}\\frac{f(x)}{g(x)} = \\lim_{x \\to a}\\frac{f'(x)}{g'(x)}",
      "videoUrl": null,
      "traps": [
        "Trying to simplify sin x / x algebraically instead of just applying the rule",
        "Applying the quotient rule instead of differentiating top and bottom independently"
      ],
      "diagram": null
    },
    {
      "id": "math-lh-q2",
      "statement": "Evaluate $\\lim_{x \\to 0}\\frac{e^x - x - 1}{x^2}$.",
      "choices": [
        { "id": "c1", "text": "$0$" },
        { "id": "c2", "text": "$1$" },
        { "id": "c3", "text": "$\\frac{1}{2}$" },
        { "id": "c4", "text": "$2$" }
      ],
      "correctAnswerId": "c3",
      "difficulty": "medium",
      "eli5": "First try gives 0/0, so you differentiate top and bottom. But the second try also gives 0/0 — apply the rule again. Third try: e^x / 2 evaluated at 0 gives 1/2. Two rounds is the most the FE will usually ask for. If you're on round 3+, you probably made a derivative error earlier.",
      "hint": "After the first application you still get 0/0. Apply L'Hopital's a second time.",
      "steps": [
        { "text": "Direct substitution:", "latex": "\\frac{e^0 - 0 - 1}{0^2} = \\frac{0}{0} \\text{ — indeterminate}" },
        { "text": "First round — differentiate top and bottom:", "latex": "\\lim_{x \\to 0}\\frac{e^x - 1}{2x}" },
        { "text": "Substitute again:", "latex": "\\frac{1 - 1}{0} = \\frac{0}{0} \\text{ — still indeterminate}" },
        { "text": "Second round:", "latex": "\\lim_{x \\to 0}\\frac{e^x}{2}" },
        { "text": "Evaluate:", "latex": "\\frac{e^0}{2} = \\frac{1}{2}" }
      ],
      "handbookPage": "p. 48",
      "handbookFormula": "\\lim_{x \\to a}\\frac{f(x)}{g(x)} = \\lim_{x \\to a}\\frac{f'(x)}{g'(x)}",
      "videoUrl": null,
      "traps": [
        "Stopping after the first round when the result is still indeterminate",
        "Forgetting to differentiate the constant -1 in e^x - 1 (its derivative is 0, which simplifies things)"
      ],
      "diagram": null
    },
    {
      "id": "math-lh-q3",
      "statement": "Evaluate $\\lim_{x \\to 0}\\frac{e^x}{x}$.",
      "choices": [
        { "id": "c1", "text": "$1$" },
        { "id": "c2", "text": "$0$" },
        { "id": "c3", "text": "$\\infty$" },
        { "id": "c4", "text": "Does not exist" }
      ],
      "correctAnswerId": "c4",
      "difficulty": "hard",
      "eli5": "This is a trap problem. You see a fraction with $x \\to 0$ and want to reach for L'Hopital's — but check the form first! $e^0 / 0 = 1/0$, which is NOT indeterminate. It is a 'blow up' form. The numerator is a finite nonzero number and the denominator goes to zero, so the function goes to $\\pm\\infty$. Since it goes to $+\\infty$ from the right and $-\\infty$ from the left, the limit DNE.",
      "hint": "Before applying L'Hopital's, check: does direct substitution actually give 0/0 or ∞/∞?",
      "steps": [
        { "text": "Direct substitution:", "latex": "\\frac{e^0}{0} = \\frac{1}{0} \\text{ — NOT } \\frac{0}{0} \\text{ or } \\frac{\\infty}{\\infty}" },
        { "text": "L'Hopital's Rule does NOT apply here.", "latex": null },
        { "text": "Analyze one-sided limits: as $x \\to 0^+$, $\\frac{e^x}{x} \\to +\\infty$; as $x \\to 0^-$, $\\frac{e^x}{x} \\to -\\infty$.", "latex": null },
        { "text": "Since left and right limits disagree, the two-sided limit does not exist.", "latex": null }
      ],
      "handbookPage": "p. 48",
      "handbookFormula": "\\lim_{x \\to a}\\frac{f(x)}{g(x)} = \\lim_{x \\to a}\\frac{f'(x)}{g'(x)}",
      "videoUrl": null,
      "traps": [
        "Blindly applying L'Hopital's without checking the indeterminate form — applying it here gives lim e^x/1 = 1, which is WRONG",
        "Choosing ∞ instead of DNE — the one-sided limits must agree for the two-sided limit to exist"
      ],
      "diagram": null
    }
  ],
};
