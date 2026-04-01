export default {
  "id": "vector-basics-unit-vectors",
  "name": "Vector Basics & Unit Vectors",
  "subtopicId": "vector-operations",
  "application": "Vectors are the language of forces in civil engineering. Every time you draw a free body diagram — resolving a cable tension into horizontal and vertical components, adding wind loads on a structure, or combining soil pressure resultants — you're doing vector math. Unit vectors let you express direction independently of magnitude, which is essential for writing force equilibrium equations in 2D and 3D. On the FE, vector basics show up directly in statics and dynamics problems. If you can add, subtract, and normalize vectors quickly, you'll save time on at least 5-10 questions.",
  "content": [
    { "type": "text", "body": "A vector has both magnitude and direction. On the FE, vectors are usually written in component form using unit vectors $\\hat{i}$, $\\hat{j}$, $\\hat{k}$ along the $x$, $y$, $z$ axes." },
    { "type": "heading", "body": "Vector in Component Form" },
    { "type": "formula", "latex": "\\vec{A} = A_x\\hat{i} + A_y\\hat{j} + A_z\\hat{k}" },
    { "type": "heading", "body": "Magnitude of a Vector" },
    { "type": "formula", "latex": "|\\vec{A}| = \\sqrt{A_x^2 + A_y^2 + A_z^2}" },
    { "type": "heading", "body": "Unit Vector" },
    { "type": "formula", "latex": "\\hat{u}_A = \\frac{\\vec{A}}{|\\vec{A}|}" },
    { "type": "text", "body": "A unit vector points in the same direction as $\\vec{A}$ but has magnitude 1. Multiply it by any scalar to get a vector of that length in that direction." },
    { "type": "heading", "body": "Vector Addition" },
    { "type": "formula", "latex": "\\vec{A} + \\vec{B} = (A_x + B_x)\\hat{i} + (A_y + B_y)\\hat{j} + (A_z + B_z)\\hat{k}" },
    { "type": "text", "body": "Add component by component. Subtraction works the same way — subtract each component." },
    { "type": "heading", "body": "Scalar Multiplication" },
    { "type": "text", "body": "Multiplying a vector by a scalar $c$ scales every component: $c\\vec{A} = cA_x\\hat{i} + cA_y\\hat{j} + cA_z\\hat{k}$. If $c$ is negative, the vector reverses direction." },
    { "type": "callout", "variant": "tip", "body": "To express a force along a known direction: find the unit vector in that direction, then multiply by the force magnitude. This is how you resolve 3D forces into components: $\\vec{F} = F\\,\\hat{u}$." },
    { "type": "callout", "variant": "warning", "body": "Don't confuse magnitude with a component. $|\\vec{A}|$ uses the square root of the sum of squares. $A_x$ alone is just the projection onto the $x$-axis — it can be negative." }
  ],
  "illustration": null,
  "problems": [
    {
      "id": "math-vbu-q1",
      "statement": "A surveyor measures a displacement of $\\vec{d} = 30\\hat{i} + 40\\hat{j}$ meters from a benchmark. What is the total distance from the benchmark?",
      "choices": [
        { "id": "c1", "text": "$70$ m" },
        { "id": "c2", "text": "$50$ m" },
        { "id": "c3", "text": "$35$ m" },
        { "id": "c4", "text": "$25$ m" }
      ],
      "correctAnswerId": "c2",
      "difficulty": "easy",
      "eli5": "Distance is the magnitude of the displacement vector. Square each component, add them, take the square root. This is a 3-4-5 right triangle scaled by 10 — if you recognize the Pythagorean triple you can skip the calculator entirely.",
      "hint": "The total distance is the magnitude of the vector, not the sum of components.",
      "steps": [
        { "text": "Apply the magnitude formula:", "latex": "|\\vec{d}| = \\sqrt{30^2 + 40^2}" },
        { "text": "Compute:", "latex": "|\\vec{d}| = \\sqrt{900 + 1600} = \\sqrt{2500} = 50 \\text{ m}" }
      ],
      "handbookPage": "p. 94",
      "handbookFormula": "|\\vec{A}| = \\sqrt{A_x^2 + A_y^2 + A_z^2}",
      "videoUrl": null,
      "traps": [
        "Adding components directly (30 + 40 = 70) instead of using the magnitude formula",
        "Forgetting to square root — 900 + 1600 = 2500 is not the answer, √2500 = 50 is"
      ],
      "diagram": null
    },
    {
      "id": "math-vbu-q2",
      "statement": "A force acts along the direction from point $A(1, 2, 2)$ to point $B(4, 6, 2)$. What is the unit vector from $A$ to $B$?",
      "choices": [
        { "id": "c1", "text": "$0.6\\hat{i} + 0.8\\hat{j} + 0\\hat{k}$" },
        { "id": "c2", "text": "$3\\hat{i} + 4\\hat{j} + 0\\hat{k}$" },
        { "id": "c3", "text": "$0.5\\hat{i} + 0.5\\hat{j} + 0\\hat{k}$" },
        { "id": "c4", "text": "$0.75\\hat{i} + 1.0\\hat{j} + 0\\hat{k}$" }
      ],
      "correctAnswerId": "c1",
      "difficulty": "medium",
      "eli5": "Two steps: first get the direction vector by subtracting coordinates (B − A), then divide every component by the magnitude. Choice B is the direction vector before normalizing — that's the most common mistake. Always check that your unit vector's magnitude equals 1: √(0.6² + 0.8²) = √(0.36 + 0.64) = 1. ✓",
      "hint": "Subtract A from B to get the direction vector, then divide by its magnitude.",
      "steps": [
        { "text": "Find the direction vector:", "latex": "\\vec{AB} = (4-1)\\hat{i} + (6-2)\\hat{j} + (2-2)\\hat{k} = 3\\hat{i} + 4\\hat{j} + 0\\hat{k}" },
        { "text": "Find its magnitude:", "latex": "|\\vec{AB}| = \\sqrt{3^2 + 4^2 + 0^2} = \\sqrt{25} = 5" },
        { "text": "Divide by magnitude:", "latex": "\\hat{u} = \\frac{3}{5}\\hat{i} + \\frac{4}{5}\\hat{j} + 0\\hat{k} = 0.6\\hat{i} + 0.8\\hat{j}" }
      ],
      "handbookPage": "p. 94",
      "handbookFormula": "\\hat{u}_A = \\frac{\\vec{A}}{|\\vec{A}|}",
      "videoUrl": null,
      "traps": [
        "Forgetting to divide by the magnitude — choice B is the raw direction vector, not the unit vector",
        "Subtracting in the wrong order (A − B instead of B − A) — this reverses the direction"
      ],
      "diagram": null
    },
    {
      "id": "math-vbu-q3",
      "statement": "Three forces act on a gusset plate: $\\vec{F}_1 = 500\\hat{i} + 0\\hat{j}$ N, $\\vec{F}_2 = -200\\hat{i} + 300\\hat{j}$ N, and $\\vec{F}_3 = 0\\hat{i} - 400\\hat{j}$ N. What is the magnitude of the resultant force?",
      "choices": [
        { "id": "c1", "text": "$500$ N" },
        { "id": "c2", "text": "$200$ N" },
        { "id": "c3", "text": "$316$ N" },
        { "id": "c4", "text": "$412$ N" }
      ],
      "correctAnswerId": "c3",
      "difficulty": "hard",
      "eli5": "Vector addition is component-by-component — add all the x's together, add all the y's together. Then the resultant magnitude is √(Rx² + Ry²). The trap is adding magnitudes directly (500 + 500 + 400 = 1400) — that only works if all forces point the same direction, which they never do in real problems. Here √100000 = 100√10 ≈ 316 N.",
      "hint": "Add the x-components and y-components separately, then find the magnitude of the resultant vector.",
      "steps": [
        { "text": "Add $x$-components:", "latex": "R_x = 500 + (-200) + 0 = 300 \\text{ N}" },
        { "text": "Add $y$-components:", "latex": "R_y = 0 + 300 + (-400) = -100 \\text{ N}" },
        { "text": "Resultant magnitude:", "latex": "|\\vec{R}| = \\sqrt{300^2 + (-100)^2} = \\sqrt{90000 + 10000} = \\sqrt{100000} \\approx 316 \\text{ N}" }
      ],
      "handbookPage": "p. 94",
      "handbookFormula": "|\\vec{A}| = \\sqrt{A_x^2 + A_y^2}",
      "videoUrl": null,
      "traps": [
        "Adding magnitudes directly instead of adding components — forces in opposite directions partially cancel",
        "Forgetting the negative signs on components — F₂ₓ = -200 and F₃ᵧ = -400 are critical"
      ],
      "diagram": null
    }
  ]
};
