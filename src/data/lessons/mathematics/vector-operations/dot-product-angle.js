export default {
  "id": "dot-product-angle",
  "name": "Dot Product & Angle Between Vectors",
  "subtopicId": "vector-operations",
  "application": "The dot product is how civil engineers find the angle between two forces, compute the component of one force along another direction, and check whether two vectors are perpendicular. In structural analysis, you use it to find the projection of a load onto a member axis. In surveying, it helps find the angle between two traverse legs. On the FE, dot product questions are quick if you know the two formulas — the component formula and the cosine formula — and when to use each.",
  "content": [
    { "type": "text", "body": "The dot product takes two vectors and returns a scalar. It has two equivalent formulas — one for computing, one for finding angles." },
    { "type": "heading", "body": "Dot Product (Component Form)" },
    { "type": "formula", "latex": "\\vec{A} \\cdot \\vec{B} = A_xB_x + A_yB_y + A_zB_z" },
    { "type": "text", "body": "Multiply matching components and add. This is the formula you use to compute the number." },
    { "type": "heading", "body": "Dot Product (Angle Form)" },
    { "type": "formula", "latex": "\\vec{A} \\cdot \\vec{B} = |\\vec{A}||\\vec{B}|\\cos\\theta" },
    { "type": "text", "body": "This is the formula you use to find the angle. Rearrange: $\\cos\\theta = \\frac{\\vec{A} \\cdot \\vec{B}}{|\\vec{A}||\\vec{B}|}$." },
    { "type": "heading", "body": "Scalar Projection" },
    { "type": "formula", "latex": "\\text{proj}_{\\vec{B}}\\vec{A} = \\frac{\\vec{A} \\cdot \\vec{B}}{|\\vec{B}|}" },
    { "type": "text", "body": "This gives the signed length of $\\vec{A}$'s shadow onto $\\vec{B}$. Positive means same general direction, negative means opposite." },
    { "type": "heading", "body": "Perpendicularity Test" },
    { "type": "text", "body": "If $\\vec{A} \\cdot \\vec{B} = 0$, the vectors are perpendicular. This is the fastest way to check orthogonality." },
    { "type": "callout", "variant": "tip", "body": "Typical FE workflow: compute the dot product using components, compute both magnitudes, then plug into the angle formula to get $\\cos\\theta$, then $\\theta = \\cos^{-1}(\\ldots)$." },
    { "type": "callout", "variant": "exam", "body": "The dot product always returns a scalar (a number), never a vector. If the answer has $\\hat{i}$, $\\hat{j}$, or $\\hat{k}$ in it, you're doing the cross product, not the dot product." }
  ],
  "illustration": null,
  "problems": [
    {
      "id": "math-dpa-q1",
      "statement": "Given $\\vec{A} = 3\\hat{i} + 4\\hat{j}$ and $\\vec{B} = -2\\hat{i} + 5\\hat{j}$, compute $\\vec{A} \\cdot \\vec{B}$.",
      "choices": [
        { "id": "c1", "text": "$26$" },
        { "id": "c2", "text": "$-26$" },
        { "id": "c3", "text": "$14$" },
        { "id": "c4", "text": "$-6$" }
      ],
      "correctAnswerId": "c3",
      "difficulty": "easy",
      "eli5": "Multiply matching components and add: x with x, y with y. That's it. The negative sign on B_x = -2 is critical — (3)(-2) = -6, not +6. Then add (4)(5) = 20. Total: 14. Choice D is just the first term without adding the second.",
      "hint": "Multiply x-components together, multiply y-components together, then add.",
      "steps": [
        { "text": "Apply the component formula:", "latex": "\\vec{A} \\cdot \\vec{B} = (3)(-2) + (4)(5)" },
        { "text": "Compute:", "latex": "= -6 + 20 = 14" }
      ],
      "handbookPage": "p. 94",
      "handbookFormula": "\\vec{A} \\cdot \\vec{B} = A_xB_x + A_yB_y + A_zB_z",
      "videoUrl": null,
      "traps": [
        "Dropping the negative sign: (3)(-2) = -6, not +6",
        "Cross-multiplying components (A_x B_y) instead of matching (A_x B_x) — that's the cross product pattern"
      ],
      "diagram": null
    },
    {
      "id": "math-dpa-q2",
      "statement": "Find the angle between $\\vec{A} = 1\\hat{i} + 0\\hat{j} + 0\\hat{k}$ and $\\vec{B} = 1\\hat{i} + 1\\hat{j} + 0\\hat{k}$.",
      "choices": [
        { "id": "c1", "text": "$30°$" },
        { "id": "c2", "text": "$45°$" },
        { "id": "c3", "text": "$60°$" },
        { "id": "c4", "text": "$90°$" }
      ],
      "correctAnswerId": "c2",
      "difficulty": "medium",
      "eli5": "This is the standard three-step workflow: (1) compute the dot product with components, (2) compute both magnitudes, (3) divide and take inverse cosine. Vector A points along the x-axis, vector B points at 45° in the xy-plane — so the answer makes geometric sense. Always sanity-check your angle.",
      "hint": "Use cos θ = (A · B) / (|A||B|) and solve for θ.",
      "steps": [
        { "text": "Dot product:", "latex": "\\vec{A} \\cdot \\vec{B} = (1)(1) + (0)(1) + (0)(0) = 1" },
        { "text": "Magnitudes:", "latex": "|\\vec{A}| = 1, \\quad |\\vec{B}| = \\sqrt{1^2 + 1^2} = \\sqrt{2}" },
        { "text": "Apply angle formula:", "latex": "\\cos\\theta = \\frac{1}{1 \\cdot \\sqrt{2}} = \\frac{1}{\\sqrt{2}}" },
        { "text": "Solve:", "latex": "\\theta = \\cos^{-1}\\!\\left(\\frac{1}{\\sqrt{2}}\\right) = 45°" }
      ],
      "handbookPage": "p. 94",
      "handbookFormula": "\\vec{A} \\cdot \\vec{B} = |\\vec{A}||\\vec{B}|\\cos\\theta",
      "videoUrl": null,
      "traps": [
        "Forgetting to compute magnitudes and dividing dot product by component sums instead",
        "Getting cos θ = 1/√2 but reporting θ = 1/√2 without taking cos⁻¹"
      ],
      "diagram": null
    },
    {
      "id": "math-dpa-q3",
      "statement": "A force $\\vec{F} = 300\\hat{i} + 600\\hat{j} - 300\\hat{k}$ N acts at a joint. A structural member runs from the joint in the direction $\\vec{d} = 2\\hat{i} + 2\\hat{j} + 1\\hat{k}$. What is the component of the force along the member?",
      "choices": [
        { "id": "c1", "text": "$900$ N" },
        { "id": "c2", "text": "$500$ N" },
        { "id": "c3", "text": "$300$ N" },
        { "id": "c4", "text": "$1500$ N" }
      ],
      "correctAnswerId": "c2",
      "difficulty": "hard",
      "eli5": "The scalar projection tells you how much of the force acts along the member's axis. Compute the dot product (which mixes all three components), then divide by the magnitude of the direction vector — not the force vector. Choice D (1500) is the raw dot product without dividing — the most common mistake. Choice A (900) is the sum of force component magnitudes, which ignores direction entirely.",
      "hint": "The component of F along d is (F · d) / |d| — divide by the magnitude of the direction, not the force.",
      "steps": [
        { "text": "Dot product:", "latex": "\\vec{F} \\cdot \\vec{d} = (300)(2) + (600)(2) + (-300)(1) = 600 + 1200 - 300 = 1500" },
        { "text": "Magnitude of direction:", "latex": "|\\vec{d}| = \\sqrt{4 + 4 + 1} = 3" },
        { "text": "Scalar projection:", "latex": "\\frac{\\vec{F} \\cdot \\vec{d}}{|\\vec{d}|} = \\frac{1500}{3} = 500 \\text{ N}" }
      ],
      "handbookPage": "p. 94",
      "handbookFormula": "\\text{proj}_{\\vec{B}}\\vec{A} = \\frac{\\vec{A} \\cdot \\vec{B}}{|\\vec{B}|}",
      "videoUrl": null,
      "traps": [
        "Using the raw dot product (1500) without dividing by |d| — the projection requires normalization",
        "Dividing by |F| instead of |d| — you project onto the direction vector, not the force"
      ],
      "diagram": null
    }
  ],
  "examProblems": [
    {
      "id": "math-dpa-ex1",
      "type": "computational",
      "statement": "Compute $\\vec{P} \\cdot \\vec{Q}$ where $\\vec{P} = 5\\hat{i} - 3\\hat{j} + 2\\hat{k}$ and $\\vec{Q} = -1\\hat{i} + 4\\hat{j} + 6\\hat{k}$.",
      "choices": [
        { "id": "c1", "text": "$-5$" },
        { "id": "c2", "text": "$-29$" },
        { "id": "c3", "text": "$5$" },
        { "id": "c4", "text": "$29$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "easy",
      "eli5": "Multiply matching components and add: $(5)(-1) + (-3)(4) + (2)(6) = -5 - 12 + 12 = -5$. Watch the signs carefully — the negative components produce negative products. The $-12$ and $+12$ cancel, leaving just $-5$ from the first pair. A negative dot product means the vectors point in generally opposite directions (the angle between them is obtuse).",
      "hint": "Multiply x with x, y with y, z with z, then add all three products.",
      "steps": [
        { "text": "Apply the component formula:", "latex": "\\vec{P} \\cdot \\vec{Q} = (5)(-1) + (-3)(4) + (2)(6)" },
        { "text": "Compute each term:", "latex": "= -5 - 12 + 12 = -5" }
      ],
      "handbookPage": "p. 55",
      "handbookFormula": "\\vec{A} \\cdot \\vec{B} = A_xB_x + A_yB_y + A_zB_z",
      "videoUrl": null,
      "traps": [
        "Dropping the negative signs during multiplication",
        "Cross-multiplying components (x with y) instead of matching (x with x)"
      ],
      "diagram": null
    },
    {
      "id": "math-dpa-ex2",
      "type": "computational",
      "statement": "Find the angle between $\\vec{A} = 2\\hat{i} + 2\\hat{j} + 1\\hat{k}$ and $\\vec{B} = 0\\hat{i} + 3\\hat{j} + 4\\hat{k}$.",
      "choices": [
        { "id": "c1", "text": "$45.6°$" },
        { "id": "c2", "text": "$48.2°$" },
        { "id": "c3", "text": "$38.2°$" },
        { "id": "c4", "text": "$71.1°$" }
      ],
      "correctAnswerId": "c2",
      "difficulty": "medium",
      "eli5": "Three steps: (1) dot product: $(2)(0) + (2)(3) + (1)(4) = 0 + 6 + 4 = 10$, (2) magnitudes: $|\\vec{A}| = \\sqrt{4 + 4 + 1} = 3$ and $|\\vec{B}| = \\sqrt{0 + 9 + 16} = 5$, (3) $\\cos\\theta = 10/(3 \\times 5) = 10/15 = 0.6667$, so $\\theta = \\cos^{-1}(0.6667) \\approx 48.2°$. The trap is forgetting to compute both magnitudes and dividing by just one of them. Always do all three steps in order.",
      "hint": "Compute the dot product, both magnitudes, then use the angle formula.",
      "steps": [
        { "text": "Dot product:", "latex": "\\vec{A} \\cdot \\vec{B} = (2)(0) + (2)(3) + (1)(4) = 0 + 6 + 4 = 10" },
        { "text": "Magnitudes:", "latex": "|\\vec{A}| = \\sqrt{4 + 4 + 1} = 3, \\quad |\\vec{B}| = \\sqrt{0 + 9 + 16} = 5" },
        { "text": "Angle formula:", "latex": "\\cos\\theta = \\frac{10}{3 \\times 5} = \\frac{10}{15} = 0.6667" },
        { "text": "Solve:", "latex": "\\theta = \\cos^{-1}(0.6667) = 48.2°" }
      ],
      "handbookPage": "p. 55",
      "handbookFormula": "\\cos\\theta = \\frac{\\vec{A} \\cdot \\vec{B}}{|\\vec{A}||\\vec{B}|}",
      "videoUrl": null,
      "traps": [
        "Forgetting to divide by both magnitudes",
        "Arithmetic error in the dot product — every component pair matters"
      ],
      "diagram": null
    },
    {
      "id": "math-dpa-ex3",
      "type": "computational",
      "statement": "A load $\\vec{F} = 200\\hat{i} + 400\\hat{j} + 100\\hat{k}$ N acts at a joint. A beam runs in the direction $\\vec{d} = 4\\hat{i} + 0\\hat{j} + 3\\hat{k}$. What is the scalar projection of the force onto the beam?",
      "choices": [
        { "id": "c1", "text": "$220$ N" },
        { "id": "c2", "text": "$1100$ N" },
        { "id": "c3", "text": "$140$ N" },
        { "id": "c4", "text": "$500$ N" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "The scalar projection is $(\\vec{F} \\cdot \\vec{d}) / |\\vec{d}|$. Dot product: $(200)(4) + (400)(0) + (100)(3) = 800 + 0 + 300 = 1100$. Magnitude of $\\vec{d}$: $\\sqrt{16 + 0 + 9} = 5$. Projection: $1100/5 = 220$ N. Choice B (1100) is the raw dot product without dividing — the most common mistake. Always divide by the magnitude of the direction vector.",
      "hint": "Scalar projection = (F dot d) / |d|. Divide by the magnitude of the direction, not the force.",
      "steps": [
        { "text": "Dot product:", "latex": "\\vec{F} \\cdot \\vec{d} = (200)(4) + (400)(0) + (100)(3) = 1100" },
        { "text": "Magnitude of direction:", "latex": "|\\vec{d}| = \\sqrt{16 + 0 + 9} = 5" },
        { "text": "Scalar projection:", "latex": "\\frac{1100}{5} = 220 \\text{ N}" }
      ],
      "handbookPage": "p. 55",
      "handbookFormula": "\\text{proj}_{\\vec{B}}\\vec{A} = \\frac{\\vec{A} \\cdot \\vec{B}}{|\\vec{B}|}",
      "videoUrl": null,
      "traps": [
        "Using the raw dot product without dividing by |d|",
        "Dividing by |F| instead of |d|"
      ],
      "diagram": null
    },
    {
      "id": "math-dpa-ex4",
      "type": "conceptual",
      "statement": "Two vectors $\\vec{A}$ and $\\vec{B}$ have a dot product of zero. What can you conclude?",
      "choices": [
        { "id": "c1", "text": "One or both vectors are zero vectors, or the vectors are perpendicular" },
        { "id": "c2", "text": "The vectors are parallel" },
        { "id": "c3", "text": "The vectors have equal magnitude" },
        { "id": "c4", "text": "The vectors point in opposite directions" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "hard",
      "eli5": "The dot product formula says $\\vec{A} \\cdot \\vec{B} = |A||B|\\cos\\theta$. This equals zero when $\\cos\\theta = 0$ (meaning $\\theta = 90°$, so perpendicular) OR when one of the magnitudes is zero (a zero vector). Most problems assume nonzero vectors, so the quick answer is 'perpendicular.' But technically, the zero vector is dotted with anything and gives zero, so the complete answer includes that case. Parallel vectors have $\\cos\\theta = \\pm 1$, giving a nonzero dot product (unless one is the zero vector).",
      "hint": "The angle formula $A \\cdot B = |A||B|\\cos\\theta$ — when does this equal zero?",
      "steps": [
        { "text": "From the angle formula: $\\vec{A} \\cdot \\vec{B} = |\\vec{A}||\\vec{B}|\\cos\\theta = 0$.", "latex": null },
        { "text": "This happens when $|\\vec{A}| = 0$, or $|\\vec{B}| = 0$, or $\\cos\\theta = 0$ (i.e., $\\theta = 90°$).", "latex": null },
        { "text": "If both vectors are nonzero, a zero dot product means they are perpendicular (orthogonal).", "latex": null }
      ],
      "handbookPage": "p. 55",
      "handbookFormula": "\\vec{A} \\cdot \\vec{B} = |\\vec{A}||\\vec{B}|\\cos\\theta",
      "videoUrl": null,
      "traps": [
        "Assuming zero dot product always means perpendicular — it could also mean a zero vector is involved",
        "Confusing zero dot product (perpendicular) with zero cross product (parallel)"
      ],
      "diagram": null
    }
  ]
};
