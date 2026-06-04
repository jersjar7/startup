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
      "eli5": "Multiply matching components and add: x with x, y with y. That's it. The negative sign on B_x = -2 is critical — (3)(-2) = -6, not +6. Then add (4)(5) = 20. Total: 14. The choice -6 is just the first term without adding the second.",
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
      "hint": "Use $\\cos\\theta = (\\vec{A} \\cdot \\vec{B}) / (|\\vec{A}||\\vec{B}|)$ and solve for $\\theta$.",
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
        "Getting $\\cos\\theta = 1/\\sqrt{2}$ but reporting $\\theta = 1/\\sqrt{2}$ without taking $\\cos^{-1}$"
      ],
      "diagram": null
    },
    {
      "id": "math-dpa-q3",
      "statement": "A force $\\vec{F} = 300\\hat{i} + 600\\hat{j} - 300\\hat{k}$ N acts at a joint. A structural member runs from the joint in the direction $\\vec{d} = 2\\hat{i} + 2\\hat{j} + 1\\hat{k}$. What is the component of the force along the member?",
      "choices": [
        { "id": "c1", "text": "$900$ N" },
        { "id": "c2", "text": "$1500$ N" },
        { "id": "c3", "text": "$300$ N" },
        { "id": "c4", "text": "$500$ N" }
      ],
      "correctAnswerId": "c4",
      "difficulty": "hard",
      "eli5": "The scalar projection tells you how much of the force acts along the member's axis. Compute the dot product (which mixes all three components), then divide by the magnitude of the direction vector — not the force vector. The 1500 N option is the raw dot product without dividing — the most common mistake. The 900 N option is the sum of force component magnitudes, which ignores direction entirely.",
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
};
